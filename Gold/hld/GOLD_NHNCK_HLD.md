# Data Mart Design — Người hành nghề Chứng khoán (NHNCK)

**Phiên bản:** 2.1  
**Ngày:** 14/04/2026  
**Phạm vi:** Toàn bộ phân hệ NHNCK — 9 dashboard/báo cáo (Tài khoản & Số dư chờ Silver source)  
**Mô hình:** Star Schema thuần túy (không snowflake)  
**Thay đổi v2.1:** Tách Fact Employment riêng cho Quá trình hành nghề. Bỏ Code 0 khỏi Relationship Type Dim. Bỏ Fact Account Snapshot (chờ Silver). Tách nhóm Mạng lưới và Hồ sơ theo đúng 1 fact/nhóm.

---

## 1. Tổng quan báo cáo

### 1.1 Dashboard: Tổng quan Người hành nghề chứng khoán toàn thị trường

**Slicer:** Năm (dropdown)

---

#### Nhóm 1 — Các chỉ tiêu tổng hợp thông tin chung

**Mockup:**

| Tổng người hành nghề | Chứng chỉ cấp mới (YTD) | Bị thu hồi | Cảnh báo NHNCK |
| :---: | :---: | :---: | :---: |
| **21,340** ppl | **1,580** CCHN | **95** case | **148** NHN |
| | Cấp mới: 1,290 · Cấp lại: 290 | | |
| YoY +7.7% | YoY +13.7% | YoY +8% | YoY +8.8% |

| CCHN đang hoạt động | CCHN thu hồi 3 năm | CCHN thu hồi vĩnh viễn | CCHN đã bị hủy |
| :---: | :---: | :---: | :---: |
| **20,180** CCHN | **312** CCHN | **98** CCHN | **750** CCHN |
| YoY +7.7% | YoY -12.2% | YoY +11.4% | YoY -5% |

**Source:** K1 từ `Fact Practitioner Snapshot` → `Calendar Date Dimension`; K2–K5 từ `Fact Certificate Snapshot` → `Classification Dimension` (CERTIFICATE_STATUS), `Calendar Date Dimension`; K6 từ `Fact Violation` → `Securities Practitioner Dimension`, `Calendar Date Dimension`

**KPI:**

| # | Tên KPI | Đơn vị | Tính chất | Mô tả |
|---|---------|--------|-----------|-------|
| K_NHNCK_1 | Tổng người hành nghề | Người | Stock | COUNT Practitioner Dimension Id theo năm (Year) |
| K_NHNCK_1_YOY | YoY% | % | Derived | So sánh cùng kỳ K1 |
| K_NHNCK_2 | Chứng chỉ cấp mới (YTD) | CCHN | Flow | COUNT CCHN có Issued In Year Flag = TRUE |
| K_NHNCK_2a | Cấp mới | CCHN | Flow | Issued In Year Flag = TRUE AND Is First Issuance Flag = TRUE |
| K_NHNCK_2b | Cấp lại | CCHN | Flow | Issued In Year Flag = TRUE AND Is First Issuance Flag = FALSE |
| K_NHNCK_2_YOY | YoY% | % | Derived | So sánh cùng kỳ K2 |
| K_NHNCK_3 | Bị thu hồi | Case | ⚠ O1 | Cần xác nhận Stock hay Flow |
| K_NHNCK_3_YOY | YoY% | % | Derived | So sánh cùng kỳ K3 |
| K_NHNCK_4 | CCHN đang hoạt động | CCHN | Stock | Certificate Status Code = 1 theo năm (Year) |
| K_NHNCK_4_YOY | YoY% | % | Derived | So sánh cùng kỳ K4 |
| K_NHNCK_3a | CCHN thu hồi 3 năm | CCHN | Stock | ⚠ O2: chờ Silver bổ sung phân biệt |
| K_NHNCK_3a_YOY | YoY% | % | Derived | So sánh cùng kỳ K3a |
| K_NHNCK_3b | CCHN thu hồi vĩnh viễn | CCHN | Stock | ⚠ O2 |
| K_NHNCK_3b_YOY | YoY% | % | Derived | So sánh cùng kỳ K3b |
| K_NHNCK_5 | CCHN đã bị hủy | CCHN | Stock | Certificate Status Code = 3 theo năm (Year) |
| K_NHNCK_5_YOY | YoY% | % | Derived | So sánh cùng kỳ K5 |
| K_NHNCK_6 | Cảnh báo NHNCK | NHN | Stock | COUNT DISTINCT Practitioner Dimension Id theo năm (Year) |
| K_NHNCK_6_YOY | YoY% | % | Derived | So sánh cùng kỳ K6 |

**Star schema — K1:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Practitioner_Snapshot : "Date Dimension Id"
    Securities_Practitioner_Dimension ||--o{ Fact_Practitioner_Snapshot : "Practitioner Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Practitioner Snapshot | 1 row = 1 NHN × 1 Snapshot Date (daily) |
| Calendar Date Dimension | 1 row = 1 ngày snapshot |
| Securities Practitioner Dimension | 1 row = 1 NHN (SCD2) |

**Star schema — K2–K5:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Certificate_Snapshot : "Date Dimension Id"
    Classification_Dim ||--o{ Fact_Certificate_Snapshot : "Certificate Status Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Certificate Snapshot | 1 row = 1 CCHN × 1 Snapshot Date (daily) |
| Calendar Date Dimension | 1 row = 1 ngày snapshot |
| Classification Dimension (CERTIFICATE_STATUS) | 1 row = 1 trạng thái CCHN |

**Star schema — K6:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Violation : "Date Dimension Id"
    Securities_Practitioner_Dimension ||--o{ Fact_Violation : "Practitioner Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Violation | 1 row = 1 vi phạm NHN (event — 1 row duy nhất) |
| Calendar Date Dimension | 1 row = 1 ngày vi phạm |
| Securities Practitioner Dimension | 1 row = 1 NHN (SCD2) |

---

#### Nhóm 2 — Biểu đồ Trình độ chuyên môn

**Mockup:**

```mermaid
pie title Trình độ chuyên môn
    "Đại học (15,710)" : 84.6
    "Thạc sĩ (2,440)" : 13.1
    "Tiến sĩ (420)" : 2.3
```

**Source:** `Fact Practitioner Snapshot` → `Securities Practitioner Dimension` (Education Level Code)

**KPI:**

| # | Tên KPI | Đơn vị | Tính chất | Mô tả |
|---|---------|--------|-----------|-------|
| K_NHNCK_7 | Số lượng Tiến sĩ | Người | Stock | COUNT Practitioner Dimension Id WHERE Education Level Code = Tiến sĩ |
| K_NHNCK_8 | Số lượng Thạc sĩ | Người | Stock | COUNT Practitioner Dimension Id WHERE Education Level Code = Thạc sĩ |
| K_NHNCK_9 | Số lượng Đại học | Người | Stock | COUNT Practitioner Dimension Id WHERE Education Level Code = Đại học |
| K_NHNCK_10 | Tỷ lệ Tiến sĩ (%) | % | Derived | K7 / K1 × 100 |
| K_NHNCK_11 | Tỷ lệ Thạc sĩ (%) | % | Derived | K8 / K1 × 100 |
| K_NHNCK_12 | Tỷ lệ Đại học (%) | % | Derived | K9 / K1 × 100 |

**Star schema — K7–K12:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Practitioner_Snapshot : "Date Dimension Id"
    Securities_Practitioner_Dimension ||--o{ Fact_Practitioner_Snapshot : "Practitioner Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Practitioner Snapshot | 1 row = 1 NHN × 1 Snapshot Date (daily) |
| Securities Practitioner Dimension | 1 row = 1 NHN (SCD2) |
| Calendar Date Dimension | 1 row = 1 ngày snapshot |

---

#### Nhóm 3 — Biểu đồ Cơ cấu theo loại hình CCHN

**Mockup:**

```mermaid
pie title Cơ cấu theo loại hình chứng chỉ
    "Môi giới (14,200)" : 80.1
    "Phân tích đầu tư (2,580)" : 14.6
    "Quản lý quỹ (940)" : 5.3
```

**Source:** `Fact Certificate Snapshot` → `Classification Dimension` (CERTIFICATE_TYPE), `Classification Dimension` (CERTIFICATE_STATUS)

**KPI:**

| # | Tên KPI | Đơn vị | Tính chất | Mô tả |
|---|---------|--------|-----------|-------|
| K_NHNCK_13 | Số lượng CCHN là Môi giới | CCHN | Stock | Certificate Status Code = 1 AND Certificate Type Code = Môi giới |
| K_NHNCK_14 | Số lượng CCHN là Phân tích đầu tư | CCHN | Stock | Certificate Status Code = 1 AND Certificate Type Code = Phân tích đầu tư |
| K_NHNCK_15 | Số lượng CCHN là Quản lý quỹ | CCHN | Stock | Certificate Status Code = 1 AND Certificate Type Code = Quản lý quỹ |

**Star schema — K13–K15:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Certificate_Snapshot : "Date Dimension Id"
    Classification_Dim ||--o{ Fact_Certificate_Snapshot : "Certificate Type Dimension Id"
    Classification_Dim ||--o{ Fact_Certificate_Snapshot : "Certificate Status Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Certificate Snapshot | 1 row = 1 CCHN × 1 Snapshot Date (daily) |
| Classification Dimension (CERTIFICATE_TYPE) | 1 row = 1 loại chứng chỉ |
| Classification Dimension (CERTIFICATE_STATUS) | 1 row = 1 trạng thái CCHN |
| Calendar Date Dimension | 1 row = 1 ngày snapshot |

---

#### Nhóm 4 — Biểu đồ Phân bổ độ tuổi nhân lực ngành

**Mockup (line chart — 2 đường: Việt Nam / Nước ngoài):**

```mermaid
xychart-beta
    title "Phân bổ độ tuổi nhân lực ngành"
    x-axis ["18-21", "22-30", "31-40", "41-50", "50+"]
    y-axis "Số lượng NHN" 0 --> 11000
    line "Việt Nam" [1200, 5200, 10000, 5100, 1500]
    line "Nước ngoài" [50, 800, 1200, 600, 300]
```

| Nhóm tuổi | 18–21 | 22–30 | 31–40 | 41–50 | 50+ |
|---|:---:|:---:|:---:|:---:|:---:|
| Việt Nam | 1,200 | 5,200 | **10,000** | 5,100 | 1,500 |
| Nước ngoài | 50 | 800 | **1,200** | 600 | 300 |

**Source:** `Fact Practitioner Snapshot` → `Securities Practitioner Dimension` (Date Of Birth, Nationality Code)

**KPI:**

| # | Tên KPI | Đơn vị | Tính chất | Mô tả |
|---|---------|--------|-----------|-------|
| K_NHNCK_16–20 | NHN theo nhóm tuổi VN | Người | Stock | COUNT Practitioner Dimension Id WHERE Nationality Code = 'VN' GROUP BY nhóm tuổi |
| K_NHNCK_21–25 | NHN theo nhóm tuổi nước ngoài | Người | Stock | COUNT Practitioner Dimension Id WHERE Nationality Code ≠ 'VN' GROUP BY nhóm tuổi |

**Star schema — K16–K25:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Practitioner_Snapshot : "Date Dimension Id"
    Securities_Practitioner_Dimension ||--o{ Fact_Practitioner_Snapshot : "Practitioner Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Practitioner Snapshot | 1 row = 1 NHN × 1 Snapshot Date (daily) |
| Securities Practitioner Dimension | 1 row = 1 NHN (SCD2) |
| Calendar Date Dimension | 1 row = 1 ngày snapshot |


---

### 1.2 Dashboard: Tra cứu hồ sơ 360°

**Slicer:** Tìm kiếm (Tên / Số CCHN / Nơi công tác), Loại Chứng chỉ (dropdown)

**Mockup (danh sách thẻ NHN — 1 card = 1 NHN):**

| **Nguyễn Văn A** | **Lê Thị Thu B** | **Trần Minh C** |
| :---: | :---: | :---: |
| 34 tuổi · Việt Nam · Môi giới | 37 tuổi · Việt Nam · Phân tích | 42 tuổi · Nhật · Quản lý quỹ |
| CCHN-2023-001 · TESLA | CCHN-2024-045 · META | CCHN-OLQ-2019-112 · GOOGLE |
| ĐANG HOẠT ĐỘNG | ĐANG HOẠT ĐỘNG | ĐANG HOẠT ĐỘNG |

**Source:** `Fact Practitioner Snapshot` → `Securities Practitioner Dimension` (thông tin cá nhân) + `Securities Organization Reference Dimension` (Nơi công tác — FK trên fact) + `Classification Dimension` (CERTIFICATE_TYPE) (loại CCHN đại diện — FK trên fact)

> **Lưu ý grain:** Dashboard Tra cứu hiển thị ở grain NHN (1 card = 1 người), trong khi 1 NHN có thể có nhiều CCHN. Do đó sử dụng `Fact Practitioner Snapshot` (grain NHN) thay vì `Fact Certificate Snapshot` (grain CCHN). Thông tin CCHN đại diện (số CCHN, loại, trạng thái) được ETL tổng hợp lên fact này theo logic "CCHN đại diện" thống nhất (xem mục 4.1).

**KPI:**

| # | Tên KPI | Đơn vị | Tính chất | Mô tả |
|---|---------|--------|-----------|-------|
| K_NHNCK_26 | Họ tên | Text | Stock | Securities Practitioner Dimension.Full Name |
| K_NHNCK_27 | Ngày sinh | Date | Stock | Securities Practitioner Dimension.Date Of Birth |
| K_NHNCK_28 | Tuổi | Năm | Derived | Year(Snapshot Date) − Year(Date Of Birth) |
| K_NHNCK_29 | Quốc tịch | Text | Stock | Securities Practitioner Dimension.Nationality Name |
| K_NHNCK_30 | Số định danh | Text | Stock | Securities Practitioner Dimension.Identification Number |
| K_NHNCK_31 | Nơi công tác hiện tại | Text | Stock | Securities Organization Reference Dimension.Organization Name (FK trên fact, ETL lookup current employment) |
| K_NHNCK_32 | Loại CCHN | Text | Stock | Classification Dimension.Classification Name (via Certificate Type Dimension Id) (FK từ CCHN đại diện) |
| K_NHNCK_33 | Trạng thái NHNCK | Text | Stock | Fact Practitioner Snapshot.Practitioner Consolidated Status Code (ETL derived từ CCHN đại diện) |

**Star schema — K26–K33:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Practitioner_Snapshot : "Date Dimension Id"
    Securities_Practitioner_Dimension ||--o{ Fact_Practitioner_Snapshot : "Practitioner Dimension Id"
    Securities_Organization_Reference_Dimension ||--o{ Fact_Practitioner_Snapshot : "Organization Dimension Id"
    Classification_Dim ||--o{ Fact_Practitioner_Snapshot : "Certificate Type Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Practitioner Snapshot | 1 row = 1 NHN × 1 Snapshot Date (daily) |
| Securities Practitioner Dimension | 1 row = 1 NHN (SCD2) |
| Securities Organization Reference Dimension | 1 row = 1 tổ chức (SCD2) |
| Classification Dimension (CERTIFICATE_TYPE) | 1 row = 1 loại chứng chỉ |
| Calendar Date Dimension | 1 row = 1 ngày snapshot |

---

### 1.3 Dashboard: Mạng lưới của NHNCK

**Slicer:** Mã NHN (chọn từ trang Tra cứu)

**Mockup:** Đồ thị mạng lưới quan hệ 360° — node: NHN chính (xanh lá) / Người liên quan (xanh dương) / DN niêm yết (xám). Cạnh: nét liền (trực tiếp) / nét đứt (liên thông).

---

#### Nhóm 1 — Quan hệ công tác (NHN ↔ Tổ chức)

**Source:** `Fact Practitioner Employment Snapshot` → `Securities Organization Reference Dimension`, `Organization Reports Dimension`

**KPI:**

| # | Tên KPI | Đơn vị | Tính chất | Mô tả |
|---|---------|--------|-----------|-------|
| K_NHNCK_34 | Đơn vị công tác | Text | Stock | Fact Practitioner Employment Snapshot → Securities Organization Reference Dimension.Organization Name |
| K_NHNCK_35 | Chức vụ / vai trò | Text | Stock | Fact Practitioner Employment Snapshot → Organization Reports Dimension.Position Name |

**Star schema — K34–K35:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Practitioner_Employment_Snapshot : "Date Dimension Id"
    Securities_Practitioner_Dimension ||--o{ Fact_Practitioner_Employment_Snapshot : "Practitioner Dimension Id"
    Organization_Reports_Dimension ||--o{ Fact_Practitioner_Employment_Snapshot : "Organization Reports Dimension Id"
    Securities_Organization_Reference_Dimension ||--o{ Fact_Practitioner_Employment_Snapshot : "Organization Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Practitioner Employment Snapshot | 1 row = 1 NHN × 1 lượt công tác × 1 Snapshot Date |
| Securities Practitioner Dimension | 1 row = 1 NHN (SCD2) |
| Organization Reports Dimension | 1 row = 1 lượt công tác (SCD2) |
| Securities Organization Reference Dimension | 1 row = 1 tổ chức (SCD2) |
| Calendar Date Dimension | 1 row = 1 ngày snapshot |

---

#### Nhóm 2 — Quan hệ gia đình (NHN ↔ Người liên quan)

**Source:** `Fact Practitioner Relationship Snapshot` → `Securities Practitioner Related Party Dimension`, `Classification Dimension` (RELATIONSHIP_TYPE)

**KPI:**

| # | Tên KPI | Đơn vị | Tính chất | Mô tả |
|---|---------|--------|-----------|-------|
| K_NHNCK_36 | Họ tên người liên quan | Text | Stock | Fact Practitioner Relationship Snapshot → Securities Practitioner Related Party Dimension.Related Party Full Name |
| K_NHNCK_37 | Mối quan hệ | Text | Stock | Fact Practitioner Relationship Snapshot → Classification Dimension.Classification Name (via Relationship Type Dimension Id) |
| K_NHNCK_38 | Đơn vị công tác NLQ | Text | Stock | Fact Practitioner Relationship Snapshot → Securities Practitioner Related Party Dimension.Workplace Name |
| K_NHNCK_39 | Chức vụ NLQ | Text | Stock | Fact Practitioner Relationship Snapshot → Securities Practitioner Related Party Dimension.Occupation Name |

**Star schema — K36–K39:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Practitioner_Relationship_Snapshot : "Date Dimension Id"
    Securities_Practitioner_Dimension ||--o{ Fact_Practitioner_Relationship_Snapshot : "Practitioner Dimension Id"
    Securities_Practitioner_Related_Party_Dimension ||--o{ Fact_Practitioner_Relationship_Snapshot : "Related Party Dimension Id"
    Classification_Dim ||--o{ Fact_Practitioner_Relationship_Snapshot : "Relationship Type Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Practitioner Relationship Snapshot | 1 row = 1 NHN × 1 NLQ × 1 Snapshot Date |
| Securities Practitioner Dimension | 1 row = 1 NHN chủ thể (SCD2) |
| Securities Practitioner Related Party Dimension | 1 row = 1 người liên quan (SCD2) |
| Classification Dimension (RELATIONSHIP_TYPE) | 1 row = 1 loại quan hệ gia đình (Code 1–6) |
| Calendar Date Dimension | 1 row = 1 ngày snapshot |

---

### 1.4 Dashboard: Hồ sơ & Danh mục của NHNCK

**Slicer:** Mã NHN (chọn từ trang Tra cứu)

---

#### Nhóm 1 — Vai trò tại DN niêm yết

**Mockup:**

| Tên DN | Vai trò | Trạng thái | Số CP sở hữu |
| :--- | :--- | :--- | ---: |
| XXX | Thành viên HĐQT | ACTIVE | 450,000 CP |
| YYY | Cổ đông lớn | ACTIVE | 2,500,000 CP |
| ZZZ | Cố vấn chiến lược | ACTIVE | 120,000 CP |

**Source:** `Fact Practitioner Employment Snapshot` → `Securities Organization Reference Dimension`, `Organization Reports Dimension`

**KPI:**

| # | Tên KPI | Đơn vị | Tính chất | Mô tả |
|---|---------|--------|-----------|-------|
| K_NHNCK_40 | Tên DN niêm yết | Text | Stock | Fact Practitioner Employment Snapshot → Securities Organization Reference Dimension.Organization Name |
| K_NHNCK_41 | Vai trò | Text | Stock | Fact Practitioner Employment Snapshot → Organization Reports Dimension.Position Name |
| K_NHNCK_42 | Trạng thái | Text | Derived | Fact Practitioner Employment Snapshot → Organization Reports Dimension.Is Current Flag → "ACTIVE" / "INACTIVE" |
| K_NHNCK_43 | Số lượng CP sở hữu | Number | Stock | ⚠ O4: cần cross-module data |

**Star schema — K40–K43:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Practitioner_Employment_Snapshot : "Date Dimension Id"
    Securities_Practitioner_Dimension ||--o{ Fact_Practitioner_Employment_Snapshot : "Practitioner Dimension Id"
    Organization_Reports_Dimension ||--o{ Fact_Practitioner_Employment_Snapshot : "Organization Reports Dimension Id"
    Securities_Organization_Reference_Dimension ||--o{ Fact_Practitioner_Employment_Snapshot : "Organization Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Practitioner Employment Snapshot | 1 row = 1 NHN × 1 lượt công tác × 1 Snapshot Date |
| Securities Practitioner Dimension | 1 row = 1 NHN (SCD2) |
| Organization Reports Dimension | 1 row = 1 lượt công tác (SCD2) |
| Securities Organization Reference Dimension | 1 row = 1 tổ chức (SCD2) |
| Calendar Date Dimension | 1 row = 1 ngày snapshot |

---

#### Nhóm 2 — Mạng lưới người liên quan

**Mockup:**

| Họ tên NLQ | Mối quan hệ | Nghề nghiệp | CCCD/CMND |
| :--- | :--- | :--- | :--- |
| Lê Thị Hồng A | Vợ/Chồng | KD tự do | *** |
| Nguyễn Thế B | Con | Du học sinh | *** |
| Trần Văn C | Vợ/Chồng | GĐ DN tư nhân | *** |

**Source:** `Fact Practitioner Relationship Snapshot` → `Securities Practitioner Related Party Dimension`, `Classification Dimension` (RELATIONSHIP_TYPE)

**KPI:**

| # | Tên KPI | Đơn vị | Tính chất | Mô tả |
|---|---------|--------|-----------|-------|
| K_NHNCK_44 | Họ và tên NLQ | Text | Stock | Fact Practitioner Relationship Snapshot → Securities Practitioner Related Party Dimension.Related Party Full Name |
| K_NHNCK_45 | Mối quan hệ | Text | Stock | Fact Practitioner Relationship Snapshot → Classification Dimension.Classification Name (via Relationship Type Dimension Id) |
| K_NHNCK_46 | Nghề nghiệp NLQ | Text | Stock | Fact Practitioner Relationship Snapshot → Securities Practitioner Related Party Dimension.Occupation Name |
| K_NHNCK_47 | CCCD/CMND/HC NLQ | Text | Stock | Fact Practitioner Relationship Snapshot → Securities Practitioner Related Party Dimension.Identity Reference Code |

**Star schema — K44–K47:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Practitioner_Relationship_Snapshot : "Date Dimension Id"
    Securities_Practitioner_Dimension ||--o{ Fact_Practitioner_Relationship_Snapshot : "Practitioner Dimension Id"
    Securities_Practitioner_Related_Party_Dimension ||--o{ Fact_Practitioner_Relationship_Snapshot : "Related Party Dimension Id"
    Classification_Dim ||--o{ Fact_Practitioner_Relationship_Snapshot : "Relationship Type Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Practitioner Relationship Snapshot | 1 row = 1 NHN × 1 NLQ × 1 Snapshot Date |
| Securities Practitioner Dimension | 1 row = 1 NHN chủ thể (SCD2) |
| Securities Practitioner Related Party Dimension | 1 row = 1 người liên quan (SCD2) |
| Classification Dimension (RELATIONSHIP_TYPE) | 1 row = 1 loại quan hệ gia đình (Code 1–6) |
| Calendar Date Dimension | 1 row = 1 ngày snapshot |

---

#### Nhóm 3 — Tài khoản & Số dư (Cross-Broker)

> ⚠ **Chờ Silver source.** Thiết kế sẽ bổ sung khi có thông tin nguồn dữ liệu tài khoản CK cross-broker. KPI K48–K52 tạm chưa mapping.

---

### 1.5 Dashboard: Quá trình hành nghề của NHNCK

**Slicer:** Mã NHN

**Mockup (timeline dọc):**

| Tổ chức | Vị trí | Từ tháng | Đến tháng |
| :--- | :--- | :---: | :---: |
| 🟢 Tesla | Môi giới CK | 12/05/2023 | Hiện nay |
| Công ty CP CK AAA | Trưởng phòng Môi giới | 12/01/2018 | 11/05/2023 |
| Vụ Giám sát TTCK - UBCKNN | Chuyên viên chính | 30/10/2012 | 11/01/2018 |
| Công ty CP CK XXX | Nhân viên Phân tích | 05/01/2009 | 29/10/2012 |

**Source:** `Fact Practitioner Employment Snapshot` → `Securities Organization Reference Dimension`, `Organization Reports Dimension`

**KPI:**

| # | Tên KPI | Đơn vị | Tính chất | Mô tả |
|---|---------|--------|-----------|-------|
| K_NHNCK_53 | Tổ chức | Text | Stock | Fact Practitioner Employment Snapshot → Securities Organization Reference Dimension.Organization Name |
| K_NHNCK_54 | Vị trí | Text | Stock | Fact Practitioner Employment Snapshot → Organization Reports Dimension.Position Name |
| K_NHNCK_55 | Từ tháng | Date | Stock | Fact Practitioner Employment Snapshot → Organization Reports Dimension.Hire Date |
| K_NHNCK_56 | Đến tháng | Date/Text | Stock | Fact Practitioner Employment Snapshot → Organization Reports Dimension.Termination Date (NULL = "Hiện nay") |
| K_NHNCK_57 | Trạng thái | Text | Derived | Fact Practitioner Employment Snapshot → Organization Reports Dimension.Is Current Flag = TRUE → "Hiện tại" ELSE "Quá khứ" |

**Star schema — K53–K57:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Practitioner_Employment_Snapshot : "Date Dimension Id"
    Securities_Practitioner_Dimension ||--o{ Fact_Practitioner_Employment_Snapshot : "Practitioner Dimension Id"
    Organization_Reports_Dimension ||--o{ Fact_Practitioner_Employment_Snapshot : "Organization Reports Dimension Id"
    Securities_Organization_Reference_Dimension ||--o{ Fact_Practitioner_Employment_Snapshot : "Organization Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Practitioner Employment Snapshot | 1 row = 1 NHN × 1 lượt công tác × 1 Snapshot Date |
| Securities Practitioner Dimension | 1 row = 1 NHN (SCD2) |
| Organization Reports Dimension | 1 row = 1 lượt công tác (SCD2) |
| Securities Organization Reference Dimension | 1 row = 1 tổ chức (SCD2) |
| Calendar Date Dimension | 1 row = 1 ngày snapshot |

---

### 1.6 Dashboard: Lịch sử cấp chứng chỉ của NHNCK

**Slicer:** Mã NHN

**Mockup (bảng chi tiết):**

| Số CCHN | Loại hình hành nghề | Ngày cấp | Ngày thu hồi | Quyết định cấp | Trạng thái |
| :--- | :--- | :---: | :---: | :--- | :--- |
| CCHN-2023-001 | Môi giới CK | 12/05/2023 | | 145/QĐ-UBCK | 🟢 ĐANG HIỆU LỰC |
| CCHN-2020-045 | Phân tích CK | 20/10/2020 | 20/10/2023 | 89/QĐ-UBCK | 🟡 THU HỒI 3 NĂM |
| CCHN-2017-012 | Môi giới CK | 15/01/2017 | 15/01/2020 | 12/QĐ-UBCK | 🔴 THU HỒI VĨNH VIỄN |

**Source:** `Fact Certificate Snapshot` → `Securities Practitioner Dimension`, `Classification Dimension` (CERTIFICATE_TYPE), `Classification Dimension` (CERTIFICATE_STATUS)

**KPI:**

| # | Tên KPI | Đơn vị | Tính chất | Mô tả |
|---|---------|--------|-----------|-------|
| K_NHNCK_58 | Số CCHN | Text | Stock | Fact Certificate Snapshot.Certificate Number |
| K_NHNCK_59 | Loại hình | Text | Stock | Fact Certificate Snapshot → Classification Dimension.Classification Name (via Certificate Type Dimension Id) |
| K_NHNCK_60 | Ngày cấp | Date | Stock | Fact Certificate Snapshot.Certificate Issue Date |
| K_NHNCK_61 | Ngày thu hồi | Date | Stock | Fact Certificate Snapshot.Revocation Date |
| K_NHNCK_62 | Quyết định cấp | Text | Stock | Fact Certificate Snapshot.Issuance Decision Number |
| K_NHNCK_63 | Trạng thái | Text | Stock | Fact Certificate Snapshot → Classification Dimension.Classification Name (via Certificate Status Dimension Id) |

**Star schema — K58–K63:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Certificate_Snapshot : "Date Dimension Id"
    Securities_Practitioner_Dimension ||--o{ Fact_Certificate_Snapshot : "Practitioner Dimension Id"
    Classification_Dim ||--o{ Fact_Certificate_Snapshot : "Certificate Type Dimension Id"
    Classification_Dim ||--o{ Fact_Certificate_Snapshot : "Certificate Status Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Certificate Snapshot | 1 row = 1 CCHN × 1 Snapshot Date |
| Securities Practitioner Dimension | 1 row = 1 NHN (SCD2) |
| Classification Dimension (CERTIFICATE_TYPE) | 1 row = 1 loại chứng chỉ |
| Classification Dimension (CERTIFICATE_STATUS) | 1 row = 1 trạng thái CCHN |
| Calendar Date Dimension | 1 row = 1 ngày snapshot |

---

### 1.7 Dashboard: Lịch sử vi phạm của NHNCK

**Slicer:** Mã NHN

**Mockup:**

| Ngày QĐ | Số QĐ | Nội dung vi phạm | Hình thức xử phạt | Trạng thái |
| :---: | :--- | :--- | :--- | :--- |
| 15/10/2023 | 142/QĐ-XPHC | Thao túng giá CK | 550,000,000 VND | ĐÃ THỰC THI |
| 05/02/2021 | 24/QĐ-UBCK | Chậm công bố TT sở hữu | Cảnh cáo | ĐÃ BAN HÀNH |
| 12/11/2019 | BC-0012/CTCK | Vi phạm quy trình mở TK | Đình chỉ hành nghề 3 tháng | ĐANG THỰC THI |

**Source:** `Fact Violation` → `Securities Practitioner Dimension`, `Calendar Date Dimension`, `Classification Dimension` (CONDUCT_VIOLATION_TYPE / VIOLATION_STATUS)

**KPI:**

| # | Tên KPI | Đơn vị | Tính chất | Mô tả |
|---|---------|--------|-----------|-------|
| K_NHNCK_71 | Số quyết định | Text | Stock | Fact Violation.Decision Number |
| K_NHNCK_72 | Ngày quyết định | Date | Stock | Fact Violation.Decision Date |
| K_NHNCK_73 | Nội dung vi phạm | Text | Stock | Fact Violation.Violation Note |
| K_NHNCK_74 | Hình thức xử phạt | Text | Stock | Fact Violation.Penalty Description ⚠ O6 |
| K_NHNCK_75 | Trạng thái | Text | Stock | Fact Violation.Violation Execution Status Name ⚠ O7 |

**Star schema — K71–K75:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Violation : "Date Dimension Id"
    Securities_Practitioner_Dimension ||--o{ Fact_Violation : "Practitioner Dimension Id"
    Classification_Dim ||--o{ Fact_Violation : "Conduct Violation Type Dimension Id"
    Classification_Dim ||--o{ Fact_Violation : "Violation Status Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Violation | 1 row = 1 vi phạm (event) |
| Securities Practitioner Dimension | 1 row = 1 NHN (SCD2) |
| Classification Dimension (CONDUCT_VIOLATION_TYPE) | 1 row = 1 loại vi phạm |
| Classification Dimension (VIOLATION_STATUS) | 1 row = 1 trạng thái hiệu lực |
| Calendar Date Dimension | 1 row = 1 ngày vi phạm |

---

### 1.8 Dashboard: Đợt thi sát hạch của NHNCK

**Slicer:** Mã NHN

**Mockup (timeline dọc):**

| Đợt thi | Điểm | Ngày thi | Số QĐ công bố | Trạng thái |
| :--- | :---: | :---: | :--- | :--- |
| 🟢 Đợt 1/2025 | 82 | 15/03/2025 | 45/QĐ-UBCK · 20/03/2025 | ✓ ĐẠT |
| Đợt 2/2024 | 58 | 18/09/2023 | | ✗ KHÔNG ĐẠT |
| 🟢 Đợt 1/2023 | 75 | 18/03/2023 | 28/QĐ-UBCK · 25/03/2023 | ✓ ĐẠT |

**Source:** `Fact Examination Result` → `Securities Practitioner Dimension`, `Examination Session Dimension`, `Classification Dimension` (EXAMINATION_RESULT), `Calendar Date Dimension`

**KPI:**

| # | Tên KPI | Đơn vị | Tính chất | Mô tả |
|---|---------|--------|-----------|-------|
| K_NHNCK_64 | Đợt thi | Text | Stock | Fact Examination Result → Examination Session Dimension.Session Name |
| K_NHNCK_65 | Ngày thi | Date | Stock | Fact Examination Result → Examination Session Dimension.Examination Start Date |
| K_NHNCK_66 | Điểm thi | Text | Stock | Fact Examination Result.Total Score |
| K_NHNCK_67 | Số QĐ công bố | Text | Stock | Fact Examination Result → Examination Session Dimension.Decision Number |
| K_NHNCK_68 | Trạng thái | Text | Stock | Fact Examination Result → Classification Dimension.Classification Name (via Examination Result Dimension Id) |

**Star schema — K64–K68:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Examination_Result : "Date Dimension Id"
    Securities_Practitioner_Dimension ||--o{ Fact_Examination_Result : "Practitioner Dimension Id"
    Examination_Session_Dimension ||--o{ Fact_Examination_Result : "Examination Session Dimension Id"
    Classification_Dim ||--o{ Fact_Examination_Result : "Examination Result Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Examination Result | 1 row = 1 kết quả thi (event) |
| Securities Practitioner Dimension | 1 row = 1 NHN (SCD2) |
| Examination Session Dimension | 1 row = 1 đợt thi (SCD2) |
| Classification Dimension (EXAMINATION_RESULT) | 1 row = 1 kết quả (Đạt / Không đạt / Chưa thi) |
| Calendar Date Dimension | 1 row = 1 ngày thi |

---

### 1.9 Dashboard: Cập nhật kiến thức của NHNCK

**Slicer:** Mã NHN

**Mockup (timeline theo năm):**

| Năm | Số giờ | Kết quả | Trạng thái |
| :--- | :---: | :--- | :--- |
| 🟢 Năm 2024 | 10/8h | LOẠI A | ✓ ĐÃ ĐỦ 8H |
| 🔴 Năm 2023 | 5/8h | CHƯA KIỂM TRA | ✗ CHƯA ĐỦ 8H |
| 🟢 Năm 2021 | 8/8h | LOẠI B | ✓ ĐÃ ĐỦ 8H |

**Source:** `Fact Training Enrollment` → `Securities Practitioner Dimension`, `Professional Training Class Dimension`, `Classification Dimension` (TRAINING_RESULT), `Calendar Date Dimension`

**KPI:**

| # | Tên KPI | Đơn vị | Tính chất | Mô tả |
|---|---------|--------|-----------|-------|
| K_NHNCK_69 | Kết quả kiểm tra / phân loại | Text | Derived | Fact Training Enrollment → Classification Dimension.Classification Name (via Training Result Dimension Id) → aggregate theo Professional Training Class Dimension.Academic Year per NHN |
| K_NHNCK_70 | Trạng thái đủ 8h | Text | Derived | SUM(Fact Training Enrollment.Training Hours) per NHN per Professional Training Class Dimension.Academic Year ≥ 8 → "Đã đủ 8h" ⚠ O9 |

**Star schema — K69–K70:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Training_Enrollment : "Date Dimension Id"
    Securities_Practitioner_Dimension ||--o{ Fact_Training_Enrollment : "Practitioner Dimension Id"
    Professional_Training_Class_Dimension ||--o{ Fact_Training_Enrollment : "Training Class Dimension Id"
    Classification_Dim ||--o{ Fact_Training_Enrollment : "Training Result Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Training Enrollment | 1 row = 1 đăng ký khóa học (event) |
| Securities Practitioner Dimension | 1 row = 1 NHN (SCD2) |
| Professional Training Class Dimension | 1 row = 1 khóa học (SCD2) |
| Classification Dimension (TRAINING_RESULT) | 1 row = 1 kết quả (Đạt / Không đạt) |
| Calendar Date Dimension | 1 row = 1 ngày khóa học |

---

### 1.10 Yêu cầu khai thác dữ liệu (Data Explorer)

**Slicer:** Loại chứng chỉ (MỌI LOẠI CHỨNG CHỈ / Môi giới / Phân tích / QLQ), Trạng thái (ĐANG HOẠT ĐỘNG / ...)

**Mockup (theo screenshot):**

| TÊN CÁN BỘ | SỐ CCHN | LOẠI HÌNH | CÔNG TY | NGÀY CẤP | TRẠNG THÁI |
| :--- | :--- | :--- | :--- | :---: | :--- |
| Nguyễn Văn A | CCHN-2023-001 | MÔI GIỚI | TESLA | 12/05/2023 | 🟢 ĐANG HOẠT ĐỘNG |
| Lê Thị Thu B | CCHN-2024-045 | PHÂN TÍCH | META | 20/10/2022 | 🟢 ĐANG HOẠT ĐỘNG |
| Trần Minh C | CCHN-QLQ-2019-112 | QUẢN LÝ QUỸ | GOOGLE | 05/01/2019 | 🟢 ĐANG HOẠT ĐỘNG |
| Đinh Quốc G | CCHN-QLQ-2020-055 | QUẢN LÝ QUỸ | DEEPSEEK | 22/07/2020 | 🟢 ĐANG HOẠT ĐỘNG |

> KẾT QUẢ: **4 NHN**

**Source:** `Fact Certificate Snapshot` → `Securities Practitioner Dimension`, `Securities Organization Reference Dimension`, `Classification Dimension` (CERTIFICATE_TYPE), `Classification Dimension` (CERTIFICATE_STATUS)

**KPI:**

| # | Tên KPI | Đơn vị | Tính chất | Mô tả |
|---|---------|--------|-----------|-------|
| K_NHNCK_76 | Tên cán bộ | Text | Stock | Fact Certificate Snapshot → Securities Practitioner Dimension.Full Name |
| K_NHNCK_77 | Số CCHN | Text | Stock | Fact Certificate Snapshot.Certificate Number |
| K_NHNCK_78 | Loại hình | Text | Stock | Fact Certificate Snapshot → Classification Dimension.Classification Name (via Certificate Type Dimension Id) |
| K_NHNCK_79 | Công ty | Text | Stock | Fact Certificate Snapshot → Securities Organization Reference Dimension.Organization Name |
| K_NHNCK_80 | Ngày cấp | Date | Stock | Fact Certificate Snapshot.Certificate Issue Date |
| K_NHNCK_81 | Trạng thái | Text | Stock | Fact Certificate Snapshot → Classification Dimension.Classification Name (via Certificate Status Dimension Id) |
| K_NHNCK_82 | Lọc: Loại chứng chỉ | — | Slicer | Fact Certificate Snapshot → Classification Dimension.Classification Code (via Certificate Type Dimension Id) |
| K_NHNCK_83 | Lọc: Trạng thái | — | Slicer | Fact Certificate Snapshot → Classification Dimension.Classification Code (via Certificate Status Dimension Id) |

**Star schema — K76–K83:**

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Certificate_Snapshot : "Date Dimension Id"
    Securities_Practitioner_Dimension ||--o{ Fact_Certificate_Snapshot : "Practitioner Dimension Id"
    Securities_Organization_Reference_Dimension ||--o{ Fact_Certificate_Snapshot : "Organization Dimension Id"
    Classification_Dim ||--o{ Fact_Certificate_Snapshot : "Certificate Type Dimension Id"
    Classification_Dim ||--o{ Fact_Certificate_Snapshot : "Certificate Status Dimension Id"
```

| Tên bảng (Logical) | Grain |
|---|---|
| Fact Certificate Snapshot | 1 row = 1 CCHN × 1 Snapshot Date |
| Securities Practitioner Dimension | 1 row = 1 NHN (SCD2) |
| Securities Organization Reference Dimension | 1 row = 1 tổ chức (SCD2) |
| Classification Dimension (CERTIFICATE_TYPE) | 1 row = 1 loại chứng chỉ |
| Classification Dimension (CERTIFICATE_STATUS) | 1 row = 1 trạng thái CCHN |
| Calendar Date Dimension | 1 row = 1 ngày snapshot |

---

## 2. Mô hình Star Schema

### 2.1 Sơ đồ tổng thể

```mermaid
graph TB
    classDef dim fill:#E6F1FB,stroke:#185FA5,color:#0C447C
    classDef ref fill:#E8F5E9,stroke:#2E7D32,color:#1B5E20
    classDef fact fill:#FAECE7,stroke:#993C1D,color:#4A1B0C

    DIM_DATE["Calendar Date Dimension"]:::dim
    DIM_PRAC["Securities Practitioner Dimension — SCD2"]:::dim
    DIM_ORG["Securities Organization Reference Dimension — SCD2"]:::dim
    DIM_REL_PARTY["Securities Practitioner Related Party Dimension — SCD2"]:::dim
    DIM_EMP_REC["Organization Reports Dimension — SCD2"]:::dim
    DIM_CERT_TYPE["Certificate Type Dimension Id → Classification Dimension"]:::ref
    DIM_CERT_STATUS["Certificate Status Dimension Id → Classification Dimension"]:::ref
    DIM_REL_TYPE["Relationship Type Dimension Id → Classification Dimension"]:::ref
    DIM_VIO_TYPE["Conduct Violation Type Dimension Id → Classification Dimension"]:::ref

    DIM_EXAM_SESSION["Examination Session Dimension — SCD2"]:::dim
    DIM_TRAIN_CLASS["Professional Training Class Dimension — SCD2"]:::dim

    FACT_PRAC["Fact Practitioner Snapshot — 1 NHN × 1 Snapshot Date"]:::fact
    FACT_CERT["Fact Certificate Snapshot — 1 CCHN × 1 Snapshot Date"]:::fact
    FACT_VIO["Fact Violation — 1 vi phạm (event)"]:::fact
    FACT_EMP["Fact Practitioner Employment Snapshot — 1 lượt công tác × 1 Snapshot Date"]:::fact
    FACT_REL["Fact Practitioner Relationship Snapshot — 1 NLQ × 1 Snapshot Date"]:::fact
    FACT_EXAM["Fact Examination Result — 1 kết quả thi (event)"]:::fact
    FACT_TRAIN["Fact Training Enrollment — 1 đăng ký khóa (event)"]:::fact

    DIM_DATE --- FACT_PRAC
    DIM_DATE --- FACT_CERT
    DIM_DATE --- FACT_VIO
    DIM_DATE --- FACT_EMP
    DIM_DATE --- FACT_REL
    DIM_DATE --- FACT_EXAM
    DIM_DATE --- FACT_TRAIN
    DIM_PRAC --- FACT_PRAC
    DIM_PRAC --- FACT_CERT
    DIM_PRAC --- FACT_VIO
    DIM_PRAC --- FACT_EMP
    DIM_PRAC --- FACT_REL
    DIM_PRAC --- FACT_EXAM
    DIM_PRAC --- FACT_TRAIN
    DIM_ORG --- FACT_PRAC
    DIM_ORG --- FACT_CERT
    DIM_ORG --- FACT_EMP
    DIM_EMP_REC --- FACT_EMP
    DIM_REL_PARTY --- FACT_REL
    DIM_CERT_TYPE --- FACT_PRAC
    DIM_CERT_TYPE --- FACT_CERT
    DIM_CERT_STATUS --- FACT_CERT
    DIM_REL_TYPE --- FACT_REL
    DIM_VIO_TYPE --- FACT_VIO
    DIM_VIO_STATUS["Violation Status Dimension Id → Classification Dimension"]:::ref
    DIM_VIO_STATUS --- FACT_VIO
    DIM_EXAM_SESSION --- FACT_EXAM
    DIM_EXAM_RESULT["Examination Result Dimension Id → Classification Dimension"]:::ref
    DIM_EXAM_RESULT --- FACT_EXAM
    DIM_TRAIN_CLASS --- FACT_TRAIN
    DIM_TRAIN_RESULT["Training Result Dimension Id → Classification Dimension"]:::ref
    DIM_TRAIN_RESULT --- FACT_TRAIN
```

### 2.2 Bảng tổng quan

| Fact Table | Grain | KPI phục vụ |
|------------|-------|-------------|
| Fact Practitioner Snapshot | 1 NHN × 1 Snapshot Date (daily) | K1, K7–K12, K16–K33 |
| Fact Certificate Snapshot | 1 CCHN × 1 Snapshot Date (daily) | K2–K5, K13–K15, K58–K63, K76–K83 |
| Fact Violation | 1 vi phạm NHN (event) | K6, K71–K75 |
| Fact Practitioner Employment Snapshot | 1 NHN × 1 lượt công tác × 1 Snapshot Date (daily) | K34–K35, K40–K43, K53–K57 |
| Fact Practitioner Relationship Snapshot | 1 NHN × 1 NLQ × 1 Snapshot Date (daily) | K36–K39, K44–K47 |
| Fact Examination Result | 1 kết quả thi (event) | K64–K68 |
| Fact Training Enrollment | 1 đăng ký khóa (event) | K69–K70 |

| Dimension | Loại | Mô tả |
|-----------|------|-------|
| Calendar Date Dimension | Conformed | Lịch — slicer năm |
| Securities Practitioner Dimension | Conformed (SCD2) | NHN — tên / ngày sinh / quốc tịch / trình độ / trạng thái / số CMND |
| Securities Organization Reference Dimension | Conformed (SCD2) | Tổ chức CK — tên / loại / trạng thái |
| Securities Practitioner Related Party Dimension | Conformed (SCD2) | Người liên quan của NHN — tên / nghề nghiệp / nơi làm việc / quốc tịch |
| Organization Reports Dimension | Conformed (SCD2) | Lượt công tác — chức vụ / phòng ban / ngày bắt đầu / ngày kết thúc |
| Examination Session Dimension | Conformed (SCD2) | Đợt thi sát hạch — tên đợt / năm / ngày thi / QĐ công nhận |
| Professional Training Class Dimension | Conformed (SCD2) | Khóa cập nhật kiến thức — tên khóa / năm học / ngày thi |
| Classification Dimension | Reference (SCD2) | Bảng phân loại chung — gộp tất cả classification value (CERTIFICATE_TYPE / CERTIFICATE_STATUS / RELATIONSHIP_TYPE / CONDUCT_VIOLATION_TYPE / VIOLATION_STATUS / EXAMINATION_RESULT / TRAINING_RESULT / ...). FK trên fact đặt tên theo nghiệp vụ, đều lookup sang bảng này |

---

## 3. Đặc tả Dimension

### 3.1 Calendar Date Dimension

| Attribute | Data Type | Mandatory | Mô tả | Source |
|-----------|-----------|-----------|-------|--------|
| Date Dimension Id | INT | PK | Surrogate key (YYYYMMDD) | Generated |
| Full Date | DATE | BK | Ngày đầy đủ | Generated |
| Year | INT | ✓ | Năm — slicer dashboard | Generated |

**SCD:** Tĩnh.

### 3.2 Securities Practitioner Dimension

| Attribute | Data Type | Mandatory | Mô tả | Source |
|-----------|-----------|-----------|-------|--------|
| Practitioner Dimension Id | INT | PK | Surrogate key | Generated |
| Practitioner Code | VARCHAR | BK | Mã người hành nghề | Securities Practitioner.Practitioner Code (attr_NHNCK_Professionals.csv) |
| Full Name | NVARCHAR | ✓ | Họ và tên | Securities Practitioner.Full Name (attr_NHNCK_Professionals.csv) |
| Date Of Birth | DATE | ✓ | Ngày sinh | Securities Practitioner.Date Of Birth (attr_NHNCK_Professionals.csv) |
| Nationality Code | VARCHAR | ✓ | Quốc tịch | Securities Practitioner.Nationality Code (attr_NHNCK_Professionals.csv) |
| Nationality Name | NVARCHAR | ✓ | Tên quốc tịch | Classification Value (NATIONALITY) |
| Education Level Code | VARCHAR | ✓ | Trình độ học vấn | Securities Practitioner.Education Level Code (attr_NHNCK_Professionals.csv) |
| Education Level Name | NVARCHAR | ✓ | Tên trình độ | Classification Value (EDUCATION_LEVEL) |
| Practice Status Code | VARCHAR | ✓ | Trạng thái hành nghề | Securities Practitioner.Practice Status Code (attr_NHNCK_Professionals.csv) |
| Practice Status Name | NVARCHAR | ✓ | Tên trạng thái | Classification Value (PRACTICE_STATUS) |
| Identification Number | VARCHAR | ✓ | Số CMND/CCCD/Hộ chiếu | Involved Party Alternative Identification.Identification Number (attr_NHNCK_Professionals_IP_Alt_Identification.csv) |
| Effective Date | DATE | ✓ (SCD2) | Ngày hiệu lực | ETL derived |
| End Date | DATE | ✓ (SCD2) | 9999-12-31 = hiện hành | ETL derived |

**SCD:** Type 2 — theo dõi Full Name, Nationality Code, Education Level Code, Practice Status Code.

### 3.3 Securities Organization Reference Dimension

| Attribute | Data Type | Mandatory | Mô tả | Source |
|-----------|-----------|-----------|-------|--------|
| Organization Dimension Id | INT | PK | Surrogate key | Generated |
| Organization Code | VARCHAR | BK | Mã tổ chức | Securities Organization Reference.Securities Organization Reference Code (attr_NHNCK_Organizations.csv) |
| Organization Name | NVARCHAR | ✓ | Tên tổ chức | Securities Organization Reference.Organization Name (attr_NHNCK_Organizations.csv) |
| Organization Type Code | VARCHAR | ✓ | Loại tổ chức | Securities Organization Reference.Organization Type Code (attr_NHNCK_Organizations.csv) |
| Organization Type Name | NVARCHAR | ✓ | Tên loại tổ chức | Classification Value (ORGANIZATION_TYPE) |
| Organization Status Code | VARCHAR | ✓ | Trạng thái | Securities Organization Reference.Organization Status Code (attr_NHNCK_Organizations.csv) |
| Effective Date | DATE | ✓ (SCD2) | Ngày hiệu lực | ETL derived |
| End Date | DATE | ✓ (SCD2) | 9999-12-31 = hiện hành | ETL derived |

**SCD:** Type 2.

### 3.4 Classification Dimension

**Mô tả:** Bảng dimension phân loại chung cho phân hệ NHNCK — gộp tất cả classification value (loại chứng chỉ / trạng thái CCHN / loại quan hệ / loại vi phạm...) vào 1 bảng duy nhất. Surrogate key tự tăng unique toàn bảng → FK từ fact luôn trỏ đúng 1 row, không cần filter theo scheme.

> **Lưu ý tên FK:** Trên các fact table, FK đặt tên theo nghiệp vụ (Certificate Type Dimension Id / Certificate Status Dimension Id / Relationship Type Dimension Id / ...) để rõ ngữ cảnh. Tất cả đều lookup sang bảng Classification Dimension này.

| Attribute | Data Type | Mandatory | Mô tả | Source |
|-----------|-----------|-----------|-------|--------|
| Classification Dimension Id | INT | PK | Surrogate key — tự tăng / unique toàn bảng | Generated |
| Scheme Code | VARCHAR | ✓ | Mã nhóm phân loại — phân biệt scheme | Silver scheme name |
| Classification Code | VARCHAR | BK (cặp) | Mã giá trị trong scheme. BK = Scheme Code + Classification Code | Silver Classification Value |
| Classification Name | NVARCHAR | ✓ | Tên giá trị | Silver Classification Value |
| Effective Date | DATE | ✓ (SCD2) | Ngày hiệu lực | ETL derived |
| End Date | DATE | ✓ (SCD2) | 9999-12-31 = hiện hành | ETL derived |

**SCD:** Type 2.

**Giá trị mẫu (từ Silver):**

| Dim Id | Scheme Code | Code | Name | Silver Source |
|---|---|---|---|---|
| 1 | CERTIFICATE_TYPE | MG | Môi giới | Classification Value (CERTIFICATE_TYPE) |
| 2 | CERTIFICATE_TYPE | PT | Phân tích đầu tư | Classification Value (CERTIFICATE_TYPE) |
| 3 | CERTIFICATE_TYPE | QLQ | Quản lý quỹ | Classification Value (CERTIFICATE_TYPE) |
| 4 | CERTIFICATE_STATUS | 0 | Chưa sử dụng | Classification Value (CERTIFICATE_STATUS) |
| 5 | CERTIFICATE_STATUS | 1 | Đang sử dụng | Classification Value (CERTIFICATE_STATUS) |
| 6 | CERTIFICATE_STATUS | 2 | Thu hồi | Classification Value (CERTIFICATE_STATUS) |
| 7 | CERTIFICATE_STATUS | 3 | Đã hủy | Classification Value (CERTIFICATE_STATUS) |
| 8 | RELATIONSHIP_TYPE | 1 | Vợ/Chồng | Classification Value (RELATIONSHIP_TYPE) — attr_NHNCK_ProfessionalRelationships.csv |
| 9 | RELATIONSHIP_TYPE | 2 | Con | Classification Value (RELATIONSHIP_TYPE) |
| 10 | RELATIONSHIP_TYPE | 3 | Bố | Classification Value (RELATIONSHIP_TYPE) |
| 11 | RELATIONSHIP_TYPE | 4 | Mẹ | Classification Value (RELATIONSHIP_TYPE) |
| 12 | RELATIONSHIP_TYPE | 5 | Ông | Classification Value (RELATIONSHIP_TYPE) |
| 13 | RELATIONSHIP_TYPE | 6 | Bà | Classification Value (RELATIONSHIP_TYPE) |
| 14 | CONDUCT_VIOLATION_TYPE | 1 | Hành chính | Classification Value (CONDUCT_VIOLATION_TYPE) — attr_NHNCK_Violations.csv |
| 15 | CONDUCT_VIOLATION_TYPE | 2 | Pháp luật | Classification Value (CONDUCT_VIOLATION_TYPE) |
| 16 | VIOLATION_STATUS | 1 | Hoạt động | Classification Value (VIOLATION_STATUS) — attr_NHNCK_Violations.csv |
| 17 | VIOLATION_STATUS | 0 | Không hoạt động | Classification Value (VIOLATION_STATUS) |
| 18 | VIOLATION_STATUS | -1 | Đã xóa | Classification Value (VIOLATION_STATUS) |
| 19 | EXAMINATION_RESULT | 1 | Đạt | Classification Value (EXAMINATION_RESULT) — attr_NHNCK_ExamDetails.csv |
| 20 | EXAMINATION_RESULT | 0 | Không đạt | Classification Value (EXAMINATION_RESULT) |
| 21 | TRAINING_RESULT | 1 | Đạt | Classification Value (TRAINING_RESULT) — attr_NHNCK_SpecializationCourseDetails.csv |
| 22 | TRAINING_RESULT | 0 | Không đạt | Classification Value (TRAINING_RESULT) |

**Mapping FK trên fact → Classification Dimension:**

| FK trên fact (tên nghiệp vụ) | Thuộc fact | Lookup scheme |
|---|---|---|
| Certificate Type Dimension Id | Fact Certificate Snapshot / Fact Practitioner Snapshot | CERTIFICATE_TYPE |
| Certificate Status Dimension Id | Fact Certificate Snapshot | CERTIFICATE_STATUS |
| Relationship Type Dimension Id | Fact Practitioner Relationship Snapshot | RELATIONSHIP_TYPE |
| Conduct Violation Type Dimension Id | Fact Violation | CONDUCT_VIOLATION_TYPE |
| Violation Status Dimension Id | Fact Violation | VIOLATION_STATUS |
| Examination Result Dimension Id | Fact Examination Result | EXAMINATION_RESULT |
| Training Result Dimension Id | Fact Training Enrollment | TRAINING_RESULT |

### 3.5 Securities Practitioner Related Party Dimension

| Attribute | Data Type | Mandatory | Mô tả | Source |
|-----------|-----------|-----------|-------|--------|
| Related Party Dimension Id | INT | PK | Surrogate key | Generated |
| Securities Practitioner Related Party Code | VARCHAR | BK | Mã người liên quan | Securities Practitioner Related Party.Securities Practitioner Related Party Code (attr_NHNCK_ProfessionalRelationships.csv) |
| Practitioner Code | VARCHAR | | Mã NHN nếu NLQ là NHN trong hệ thống (NULL nếu không phải NHN) — dùng cho drill-through sang hồ sơ 360° | Securities Practitioner Related Party.Practitioner Code (attr_NHNCK_ProfessionalRelationships.csv) |
| Related Party Full Name | NVARCHAR | ✓ | Họ và tên người liên quan | Securities Practitioner Related Party.Related Party Full Name (attr_NHNCK_ProfessionalRelationships.csv) |
| Occupation Name | NVARCHAR | | Nghề nghiệp | Securities Practitioner Related Party.Occupation Name (attr_NHNCK_ProfessionalRelationships.csv) |
| Workplace Name | NVARCHAR | | Nơi làm việc | Securities Practitioner Related Party.Workplace Name (attr_NHNCK_ProfessionalRelationships.csv) |
| Birth Year | VARCHAR | | Năm sinh | Securities Practitioner Related Party.Birth Year (attr_NHNCK_ProfessionalRelationships.csv) |
| Country Code | VARCHAR | | Quốc gia | Securities Practitioner Related Party.Country Code (attr_NHNCK_ProfessionalRelationships.csv) |
| Identity Reference Code | VARCHAR | | Mã định danh giấy tờ tùy thân | Securities Practitioner Related Party.Identity Reference Code (attr_NHNCK_ProfessionalRelationships.csv) |
| Effective Date | DATE | ✓ (SCD2) | Ngày hiệu lực | ETL derived |
| End Date | DATE | ✓ (SCD2) | 9999-12-31 = hiện hành | ETL derived |

**SCD:** Type 2.

### 3.6 Organization Reports Dimension

| Attribute | Data Type | Mandatory | Mô tả | Source |
|-----------|-----------|-----------|-------|--------|
| Organization Reports Dimension Id | INT | PK | Surrogate key | Generated |
| Organization Employment Report Code | VARCHAR | BK | Mã báo cáo công tác | Securities Practitioner Organization Employment Report.Organization Employment Report Code (attr_NHNCK_OrganizationReports.csv) |
| Position Name | NVARCHAR | | Chức vụ / vị trí công tác | Securities Practitioner Organization Employment Report.Position Name (attr_NHNCK_OrganizationReports.csv) |
| Department Name | NVARCHAR | | Phòng ban | Securities Practitioner Organization Employment Report.Department Name (attr_NHNCK_OrganizationReports.csv) |
| Hire Date | DATE | | Ngày tiếp nhận | Securities Practitioner Organization Employment Report.Hire Date (attr_NHNCK_OrganizationReports.csv) |
| Termination Date | DATE | | Ngày thôi việc (NULL = đang làm) | Securities Practitioner Organization Employment Report.Termination Date (attr_NHNCK_OrganizationReports.csv) |
| Is Current Flag | BOOLEAN | Derived | TRUE = Termination Date IS NULL (đang công tác) | ETL derived |
| Effective Date | DATE | ✓ (SCD2) | Ngày hiệu lực | ETL derived |
| End Date | DATE | ✓ (SCD2) | 9999-12-31 = hiện hành | ETL derived |

**SCD:** Type 2.

### 3.7 Examination Session Dimension

| Attribute | Data Type | Mandatory | Mô tả | Source |
|-----------|-----------|-----------|-------|--------|
| Examination Session Dimension Id | INT | PK | Surrogate key | Generated |
| Examination Assessment Code | VARCHAR | BK | Mã đợt thi | Securities Practitioner Qualification Examination Assessment.Examination Assessment Code (attr_NHNCK_ExamSessions.csv) |
| Session Name | NVARCHAR | ✓ | Tên đợt thi (Đợt 1/2025) | Derived: Session Number + "/" + Examination Year (attr_NHNCK_ExamSessions.csv) |
| Session Number | VARCHAR | | Số thứ tự đợt thi trong năm | Securities Practitioner Qualification Examination Assessment.Session Number (attr_NHNCK_ExamSessions.csv) |
| Examination Year | VARCHAR | | Năm thi | Securities Practitioner Qualification Examination Assessment.Examination Year (attr_NHNCK_ExamSessions.csv) |
| Examination Start Date | DATE | | Ngày bắt đầu thi | Securities Practitioner Qualification Examination Assessment.Examination Start Date (attr_NHNCK_ExamSessions.csv) |
| Examination End Date | DATE | | Ngày kết thúc thi | Securities Practitioner Qualification Examination Assessment.Examination End Date (attr_NHNCK_ExamSessions.csv) |
| Organizer Name | NVARCHAR | | Đơn vị tổ chức | Securities Practitioner Qualification Examination Assessment.Organizer Name (attr_NHNCK_ExamSessions.csv) |
| Decision Number | VARCHAR | | Số QĐ công nhận kết quả | Securities Practitioner License Decision Document.Decision Number (attr_NHNCK_Decisions.csv) — lookup qua License Decision Document Id |
| Decision Date | DATE | | Ngày QĐ công nhận | Securities Practitioner License Decision Document.Signing Date (attr_NHNCK_Decisions.csv) |
| Effective Date | DATE | ✓ (SCD2) | Ngày hiệu lực | ETL derived |
| End Date | DATE | ✓ (SCD2) | 9999-12-31 = hiện hành | ETL derived |

**SCD:** Type 2.

### 3.8 Professional Training Class Dimension

| Attribute | Data Type | Mandatory | Mô tả | Source |
|-----------|-----------|-----------|-------|--------|
| Training Class Dimension Id | INT | PK | Surrogate key | Generated |
| Professional Training Class Code | VARCHAR | BK | Mã khóa học | Securities Practitioner Professional Training Class.Professional Training Class Code (attr_NHNCK_SpecializationCourses.csv) |
| Course Name | NVARCHAR | ✓ | Tên khóa học | Securities Practitioner Professional Training Class.Course Name (attr_NHNCK_SpecializationCourses.csv) |
| Academic Year | VARCHAR | | Năm học | Securities Practitioner Professional Training Class.Academic Year (attr_NHNCK_SpecializationCourses.csv) |
| Exam Date | DATE | | Ngày thi | Securities Practitioner Professional Training Class.Exam Date (attr_NHNCK_SpecializationCourses.csv) |
| Course Code | VARCHAR | | Mã khóa học nghiệp vụ | Securities Practitioner Professional Training Class.Course Code (attr_NHNCK_SpecializationCourses.csv) |
| Effective Date | DATE | ✓ (SCD2) | Ngày hiệu lực | ETL derived |
| End Date | DATE | ✓ (SCD2) | 9999-12-31 = hiện hành | ETL derived |

**SCD:** Type 2.

---

## 4. Đặc tả Fact

### 4.1 Fact Practitioner Snapshot

**Grain:** 1 row = 1 NHN × 1 Snapshot Date (daily).  
**Mô tả:** Full periodic snapshot — batch T chụp toàn bộ NHN có ít nhất 1 CCHN, Snapshot Date = T-1. **v2.0:** Bổ sung thông tin CCHN đại diện + nơi công tác cho Dashboard 1.2 Tra cứu.

> **Logic xác định "CCHN đại diện":** ETL chọn đúng 1 CCHN per NHN theo ưu tiên trạng thái: **Đang sử dụng (1) > Thu hồi 3 năm (2a) > Thu hồi vĩnh viễn (2b) > Đã hủy (3)**. Nếu cùng trạng thái, chọn CCHN có Certificate Issue Date gần nhất. Ba attribute Practitioner Consolidated Status Code / Primary Certificate Number / Certificate Type Dimension Id đều lấy từ cùng 1 dòng CCHN đại diện này — đảm bảo trạng thái, số CCHN, loại hình là thông tin đồng nhất của cùng 1 chứng chỉ.

| Attribute | Data Type | Mandatory | Mô tả | Source |
|-----------|-----------|-----------|-------|--------|
| Snapshot Date | INT | ✓ | Ngày dữ liệu nghiệp vụ (YYYYMMDD) | ETL derived |
| Population Date | TIMESTAMP | ✓ | Thời gian ghi vào Database | ETL load timestamp |
| Date Dimension Id | INT | FK | FK → Calendar Date Dimension | Calendar Date Dimension.Date Dimension Id |
| Practitioner Dimension Id | INT | FK | FK → Securities Practitioner Dimension | Securities Practitioner Dimension.Practitioner Dimension Id |
| Organization Dimension Id | INT | FK | FK → Securities Organization Reference Dimension — nơi công tác hiện tại (ETL lookup từ Employment Report WHERE Termination Date IS NULL) | Securities Organization Reference Dimension.Organization Dimension Id |
| Certificate Type Dimension Id | INT | FK | FK → Classification Dimension (scheme: CERTIFICATE_TYPE) — loại chứng chỉ của **CCHN đại diện** | Classification Dimension.Classification Dimension Id |
| Primary Certificate Number | VARCHAR | Derived | Số chứng chỉ của **CCHN đại diện** — hiển thị CCHN-2023-001 trên card | Securities Practitioner License Certificate Document.Certificate Number (attr_NHNCK_CertificateRecords.csv) — từ CCHN đại diện |
| Practitioner Consolidated Status Code | VARCHAR | Derived | Trạng thái tổng hợp = trạng thái của **CCHN đại diện**. Logic ưu tiên: Đang sử dụng (1) > Thu hồi 3 năm > Thu hồi vĩnh viễn > Đã hủy (3). Nếu NHN có ≥1 CCHN đang sử dụng → Status = "ĐANG HOẠT ĐỘNG" | Securities Practitioner License Certificate Document.Certificate Status Code (attr_NHNCK_CertificateRecords.csv) — từ CCHN đại diện |

**Grain uniqueness:** Snapshot Date + Practitioner Dimension Id.

### 4.2 Fact Certificate Snapshot

**Grain:** 1 row = 1 CCHN × 1 Snapshot Date (daily).  
**Mô tả:** Full periodic snapshot. **v2.0:** Bổ sung FK → Securities Organization Reference Dimension (nơi công tác hiện tại, ETL lookup) + attribute chi tiết cho Lịch sử CCHN / Data Explorer.

| Attribute | Data Type | Mandatory | Mô tả | Source |
|-----------|-----------|-----------|-------|--------|
| Snapshot Date | INT | ✓ | Ngày dữ liệu nghiệp vụ (YYYYMMDD) | ETL derived |
| Population Date | TIMESTAMP | ✓ | Thời gian ghi vào Database | ETL load timestamp |
| Date Dimension Id | INT | FK | FK → Calendar Date Dimension | Calendar Date Dimension.Date Dimension Id |
| Practitioner Dimension Id | INT | FK | FK → Securities Practitioner Dimension | Securities Practitioner Dimension.Practitioner Dimension Id |
| Certificate Type Dimension Id | INT | FK | FK → Classification Dimension (scheme: CERTIFICATE_TYPE) | Classification Dimension.Classification Dimension Id |
| Certificate Status Dimension Id | INT | FK | FK → Classification Dimension (scheme: CERTIFICATE_STATUS) | Classification Dimension.Classification Dimension Id |
| Organization Dimension Id | INT | FK | FK → Securities Organization Reference Dimension (nơi công tác hiện tại — ETL lookup từ Employment Report WHERE Termination Date IS NULL) | Securities Organization Reference Dimension.Organization Dimension Id |
| License Certificate Document Code | VARCHAR | DD | Mã CCHN (grain key) | Securities Practitioner License Certificate Document.License Certificate Document Code (attr_NHNCK_CertificateRecords.csv) |
| Certificate Number | VARCHAR | DD | Số chứng chỉ (hiển thị trên UI) | Securities Practitioner License Certificate Document.Certificate Number (attr_NHNCK_CertificateRecords.csv) |
| Certificate Issue Date | DATE | ✓ | Ngày cấp chứng chỉ | Securities Practitioner License Certificate Document.Certificate Issue Date (attr_NHNCK_CertificateRecords.csv) |
| Revocation Date | DATE | | Ngày thu hồi (NULL = chưa thu hồi) | Securities Practitioner License Certificate Document.Revocation Date (attr_NHNCK_CertificateRecords.csv) |
| Issuance Decision Number | VARCHAR | | Số quyết định cấp | Securities Practitioner License Decision Document.Decision Number (attr_NHNCK_Decisions.csv) — lookup qua Issuance Decision Document Id |
| Issued In Year Flag | BOOLEAN | Derived | TRUE = có sự kiện CẤP year-to-date | Securities Practitioner License Certificate Document Status History.New Status Code (attr_NHNCK_CertificateRecordStatusHistories.csv) |
| Is First Issuance Flag | BOOLEAN | Derived | TRUE = cấp lần đầu, FALSE = cấp lại | Securities Practitioner License Certificate Group Member.Is Reissue Indicator (attr_NHNCK_CertificateRecordGroupMembers.csv) — đảo giá trị |
| Revoked In Year Flag | BOOLEAN | Derived | TRUE = có sự kiện THU HỒI year-to-date | Securities Practitioner License Certificate Document Status History.New Status Code (attr_NHNCK_CertificateRecordStatusHistories.csv) |

**Grain uniqueness:** Snapshot Date + License Certificate Document Code.

### 4.3 Fact Violation

**Grain:** 1 row = 1 vi phạm (event — duy nhất).  
**Mô tả:** Event fact. **v2.0:** Bổ sung attribute chi tiết cho tab Lịch sử vi phạm.

| Attribute | Data Type | Mandatory | Mô tả | Source |
|-----------|-----------|-----------|-------|--------|
| Violation Date | INT | ✓ | Ngày vi phạm (YYYYMMDD) | Securities Practitioner Conduct Violation.Created Timestamp (attr_NHNCK_Violations.csv) |
| Population Date | TIMESTAMP | ✓ | Thời gian ghi vào Database | ETL load timestamp |
| Date Dimension Id | INT | FK | FK → Calendar Date Dimension | Calendar Date Dimension.Date Dimension Id |
| Practitioner Dimension Id | INT | FK | FK → Securities Practitioner Dimension | Securities Practitioner Dimension.Practitioner Dimension Id |
| Conduct Violation Type Dimension Id | INT | FK | FK → Classification Dimension (scheme: CONDUCT_VIOLATION_TYPE) — loại vi phạm (1: Hành chính, 2: Pháp luật) | Classification Dimension.Classification Dimension Id |
| Violation Status Dimension Id | INT | FK | FK → Classification Dimension (scheme: VIOLATION_STATUS) — trạng thái hiệu lực (1: Hoạt động, 0: Không hoạt động, -1: Đã xóa) | Classification Dimension.Classification Dimension Id |
| Conduct Violation Code | VARCHAR | DD | Mã vi phạm (grain key) | Securities Practitioner Conduct Violation.Conduct Violation Code (attr_NHNCK_Violations.csv) |
| Decision Number | VARCHAR | DD | Số quyết định xử phạt | Securities Practitioner License Decision Document.Decision Number (attr_NHNCK_Decisions.csv) — lookup qua License Decision Document Id |
| Decision Date | DATE | | Ngày quyết định | Securities Practitioner License Decision Document.Signing Date (attr_NHNCK_Decisions.csv) |
| Violation Note | NVARCHAR | | Nội dung vi phạm | Securities Practitioner Conduct Violation.Violation Note (attr_NHNCK_Violations.csv) |
| Penalty Description | NVARCHAR | | Hình thức xử phạt | ⚠ O6: Chờ xác nhận Silver attribute |
| Violation Execution Status Code | VARCHAR | | Trạng thái thực thi | ⚠ O7: Chờ xác nhận Silver attribute |

**Grain uniqueness:** Conduct Violation Code.

### 4.4 Fact Practitioner Employment Snapshot

**Grain:** 1 row = 1 NHN × 1 lượt công tác × 1 Snapshot Date (daily).  
**Mô tả:** Factless fact (periodic snapshot) — ghi nhận quan hệ NHN ↔ Tổ chức qua các lượt công tác. Fact chỉ chứa FK, mọi thông tin hiển thị lookup từ dimension.

**Source:** Securities Practitioner Organization Employment Report (attr_NHNCK_OrganizationReports.csv).

| Attribute | Data Type | Mandatory | Mô tả | Source |
|-----------|-----------|-----------|-------|--------|
| Snapshot Date | INT | ✓ | Ngày dữ liệu nghiệp vụ (YYYYMMDD) | ETL derived |
| Population Date | TIMESTAMP | ✓ | Thời gian ghi vào Database | ETL load timestamp |
| Date Dimension Id | INT | FK | FK → Calendar Date Dimension | Calendar Date Dimension.Date Dimension Id |
| Practitioner Dimension Id | INT | FK | FK → Securities Practitioner Dimension — NHN | Securities Practitioner Dimension.Practitioner Dimension Id |
| Organization Reports Dimension Id | INT | FK | FK → Organization Reports Dimension — thông tin lượt công tác (Position / Hire Date / Termination Date) | Organization Reports Dimension.Organization Reports Dimension Id |
| Organization Dimension Id | INT | FK | FK → Securities Organization Reference Dimension — tổ chức công tác | Securities Organization Reference Dimension.Organization Dimension Id |

**Grain uniqueness:** Snapshot Date + Organization Reports Dimension Id.

### 4.5 Fact Practitioner Relationship Snapshot

**Grain:** 1 row = 1 NHN × 1 người liên quan × 1 Snapshot Date (daily).  
**Mô tả:** Factless fact (periodic snapshot) — ghi nhận quan hệ gia đình NHN ↔ NLQ. Fact chỉ chứa FK + DD. Loại quan hệ lookup sang Classification Dimension (scheme: RELATIONSHIP_TYPE, Code 1–6).

**Dữ liệu 2 chiều — lấy as-is từ Silver:** Silver đã đảm bảo khi cả 2 bên đều là NHN, mỗi bên đều có bản ghi quan hệ riêng. ETL chỉ cần load trực tiếp, không cần sinh dòng ngược.

**Source:** Securities Practitioner Related Party (attr_NHNCK_ProfessionalRelationships.csv).

| Attribute | Data Type | Mandatory | Mô tả | Source |
|-----------|-----------|-----------|-------|--------|
| Snapshot Date | INT | ✓ | Ngày dữ liệu nghiệp vụ (YYYYMMDD) | ETL derived |
| Population Date | TIMESTAMP | ✓ | Thời gian ghi vào Database | ETL load timestamp |
| Date Dimension Id | INT | FK | FK → Calendar Date Dimension | Calendar Date Dimension.Date Dimension Id |
| Practitioner Dimension Id | INT | FK | FK → Securities Practitioner Dimension — NHN chủ thể | Securities Practitioner Dimension.Practitioner Dimension Id |
| Related Party Dimension Id | INT | FK | FK → Securities Practitioner Related Party Dimension — người liên quan | Securities Practitioner Related Party Dimension.Related Party Dimension Id |
| Relationship Type Dimension Id | INT | FK | FK → Classification Dimension (scheme: RELATIONSHIP_TYPE) — loại quan hệ gia đình (Code 1–6) | Classification Dimension.Classification Dimension Id |
| Practitioner Relationship Code | VARCHAR | DD | Mã quan hệ (grain key) | Securities Practitioner Related Party.Securities Practitioner Related Party Code (attr_NHNCK_ProfessionalRelationships.csv) |

**Grain uniqueness:** Snapshot Date + Practitioner Relationship Code.

> **Note:** Fact Practitioner Account Snapshot (K48–K52: Tài khoản & Số dư Cross-Broker) — chờ Silver source. Thiết kế sẽ bổ sung khi có thông tin nguồn dữ liệu.

### 4.6 Fact Examination Result

**Grain:** 1 row = 1 kết quả thi (event — duy nhất).  
**Mô tả:** Event fact — kết quả thi sát hạch CCHN. Thông tin đợt thi (tên, năm, QĐ) lookup từ Examination Session Dimension. Kết quả Đạt/Không đạt lookup từ Classification Dimension (EXAMINATION_RESULT).

| Attribute | Data Type | Mandatory | Mô tả | Source |
|-----------|-----------|-----------|-------|--------|
| Examination Date | INT | ✓ | Ngày thi (YYYYMMDD) | Securities Practitioner Qualification Examination Assessment.Examination Start Date (attr_NHNCK_ExamSessions.csv) |
| Population Date | TIMESTAMP | ✓ | ETL load timestamp | ETL load timestamp |
| Date Dimension Id | INT | FK | FK → Calendar Date Dimension | Calendar Date Dimension.Date Dimension Id |
| Practitioner Dimension Id | INT | FK | FK → Securities Practitioner Dimension | Securities Practitioner Dimension.Practitioner Dimension Id |
| Examination Session Dimension Id | INT | FK | FK → Examination Session Dimension — đợt thi (tên đợt / năm / QĐ công nhận) | Examination Session Dimension.Examination Session Dimension Id |
| Examination Result Dimension Id | INT | FK | FK → Classification Dimension (scheme: EXAMINATION_RESULT) — kết quả (Đạt / Không đạt / Chưa thi) | Classification Dimension.Classification Dimension Id |
| Examination Assessment Result Code | VARCHAR | DD | Mã kết quả thi (grain key) | Securities Practitioner Qualification Examination Assessment Result.Examination Assessment Result Code (attr_NHNCK_ExamDetails.csv) |
| Law Score | VARCHAR | | Điểm pháp luật — kết quả cá nhân | Securities Practitioner Qualification Examination Assessment Result.Law Score (attr_NHNCK_ExamDetails.csv) |
| Specialization Score | VARCHAR | | Điểm chuyên môn — kết quả cá nhân | Securities Practitioner Qualification Examination Assessment Result.Specialization Score (attr_NHNCK_ExamDetails.csv) |
| Total Score | VARCHAR | Derived | Tổng điểm — kết quả cá nhân | ETL derived |

**Grain uniqueness:** Examination Assessment Result Code.

### 4.7 Fact Training Enrollment

**Grain:** 1 row = 1 đăng ký khóa (event — duy nhất).  
**Mô tả:** Event fact — kết quả cập nhật kiến thức. Thông tin khóa học (tên, năm) lookup từ Professional Training Class Dimension. Kết quả Đạt/Không đạt lookup từ Classification Dimension (TRAINING_RESULT). Dashboard aggregate theo Academic Year per NHN.

| Attribute | Data Type | Mandatory | Mô tả | Source |
|-----------|-----------|-----------|-------|--------|
| Enrollment Date | INT | ✓ | Ngày sự kiện (YYYYMMDD) | Securities Practitioner Professional Training Class.Exam Date (attr_NHNCK_SpecializationCourses.csv) |
| Population Date | TIMESTAMP | ✓ | ETL load timestamp | ETL load timestamp |
| Date Dimension Id | INT | FK | FK → Calendar Date Dimension | Calendar Date Dimension.Date Dimension Id |
| Practitioner Dimension Id | INT | FK | FK → Securities Practitioner Dimension | Securities Practitioner Dimension.Practitioner Dimension Id |
| Training Class Dimension Id | INT | FK | FK → Professional Training Class Dimension — khóa học (tên khóa / năm học) | Professional Training Class Dimension.Training Class Dimension Id |
| Training Result Dimension Id | INT | FK | FK → Classification Dimension (scheme: TRAINING_RESULT) — kết quả (Đạt / Không đạt) | Classification Dimension.Classification Dimension Id |
| Training Enrollment Code | VARCHAR | DD | Mã đăng ký (grain key) | Securities Practitioner Professional Training Class Enrollment.Professional Training Class Enrollment Code (attr_NHNCK_SpecializationCourseDetails.csv) |
| Assessment Score | VARCHAR | | Điểm kiểm tra — kết quả cá nhân | Securities Practitioner Professional Training Class Enrollment.Assessment Score (attr_NHNCK_SpecializationCourseDetails.csv) |
| Training Hours | DECIMAL | Derived | Số giờ đào tạo ⚠ O9 | ETL derived |

**Grain uniqueness:** Training Enrollment Code.

---

## 5. Vấn đề mở & Giả định

| # | Vấn đề | Giả định hiện tại | KPI liên quan | Status |
|---|--------|-------------------|---------------|--------|
| O1 | K3 "Bị thu hồi" Stock hay Flow? | Tạm giả định Flow (Revoked In Year Flag) | K3 | Open |
| O2 | Certificate Status Code "2: Thu hồi" không phân biệt 3 năm vs vĩnh viễn | Chờ Silver cập nhật | K3a, K3b | Open |
| O3 | BA phản hồi K3a/K3b khi Silver bổ sung | Chờ BA | K3a, K3b | Open |
| O4 | Số lượng CP sở hữu tại DN niêm yết — source ngoài Silver NHNCK | Tạm giữ placeholder. Chờ xác nhận source (VSD/GSDC) | K43 | Open |
| O5 | Tài khoản & Số dư Cross-Broker (K48–K52) — Silver NHNCK không có entity TK CK. Đã bỏ khỏi HLD | Chờ Silver source. Thiết kế bổ sung khi có thông tin | K48–K52 | Open — chờ Silver |
| O6 | "Hình thức xử phạt" — Silver Violations không có Penalty Description riêng | Tạm ghi Penalty Description. Chờ xác nhận Silver attribute | K74 | Open |
| O7 | "Trạng thái thực thi" — Silver chỉ có Violation Status Code (Hoạt động/Không HĐ/Đã xóa) | Tạm ghi Violation Execution Status Code. Chờ xác nhận | K75 | Open |
| O9 | Training Hours — Silver không có trường này | Chờ xác nhận quy tắc tính + nguồn dữ liệu với BA | K70 | Open — chờ BA |
| O11 | Hồ sơ: "% sở hữu" NLQ + "Số lượng CP sở hữu" — source ngoài Silver NHNCK | Chờ Silver source từ module khác (VSD/GSDC). Thiết kế bổ sung khi có thông tin | K43–K47 | Open — chờ Silver |