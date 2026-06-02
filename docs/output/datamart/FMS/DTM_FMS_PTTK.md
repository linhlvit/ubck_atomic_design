## 3.2.1 Luồng đồng bộ dữ liệu cho nhóm báo cáo Quản lý quỹ

### 3.2.1.1 Thông tin chung luồng đồng bộ

- tên job:
- nguồn dữ liệu (hệ thống nguồn): FMS, ECAT, QLRR, GSGD
- cách thức truy xuất đồng bộ dữ liệu:
- tần suất đồng bộ dữ liệu:
- dung lượng dữ liệu sẽ thực hiện đồng bộ:
- thời gian lưu trữ dữ liệu:
- thư mục lưu trữ dữ liệu trên kho dữ liệu:

---

### 3.2.1.2 Luồng nghiệp vụ

#### 3.2.1.2.1 Nhóm thông tin Thống kê thị trường toàn phần

```mermaid
flowchart LR
    subgraph Staging
        S1["FMS.SECURITIES"]
        S2["FMS.FUNDS"]
        S3["FMS.FORBRCH"]
        S4["FMS.AGENCIES"]
        S6["FMS.RPTVALUES"]
        SE1["ECAT.ECAT_29_HolidayInfo"]
    end

    subgraph Atomic
        SV1["Fund Management Company"]
        SV2["Investment Fund"]
        SV3["Foreign Fund Management Organization Unit"]
        SV4["Fund Distribution Agent"]
        SV6["Report Import Value"]
        SV7["Calendar Date"]
    end

    subgraph Datamart
        G1["Fact Fund Management Company Snapshot"]
        G2["Calendar Date Dimension"]
    end

    S1 --> SV1
    S2 --> SV2
    S3 --> SV3
    S4 --> SV4
    S6 --> SV6
    SE1 --> SV7

    SV1 --> G1
    SV2 --> G1
    SV3 --> G1
    SV4 --> G1
    SV6 --> G1
    SV7 --> G2

    G2 --> G1
```

**Mục đích:** Cung cấp bảng `Fact Fund Management Company Snapshot` phục vụ Tab TỔNG QUAN CTQLQ — Nhóm 1, tổng hợp các chỉ tiêu thống kê toàn thị trường quản lý quỹ theo tháng gồm số lượng CTQLQ, quỹ đầu tư, VPĐD, chi nhánh, đại lý phân phối, quỹ hưu trí và tổng AUM toàn thị trường.

**Mô tả luồng:**

Staging → Atomic:
- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS
- **Foreign Fund Management Organization Unit:** Bảng lưu thông tin văn phòng đại diện và chi nhánh công ty quản lý quỹ nước ngoài tại Việt Nam lấy thông tin từ bảng FMS.FORBRCH
- **Fund Distribution Agent:** Bảng lưu thông tin đại lý phân phối chứng chỉ quỹ lấy thông tin từ bảng FMS.AGENCIES
- **Report Import Value:** Bảng lưu giá trị các chỉ tiêu báo cáo định kỳ lấy thông tin từ bảng FMS.RPTVALUES
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

Atomic → Datamart:
- **Fact Fund Management Company Snapshot:** Bảng sự kiện tổng hợp thông tin thống kê toàn thị trường quản lý quỹ — grain 1 snapshot × 1 tháng, không có chiều phân tích theo từng CTQLQ
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian

---

#### 3.2.1.2.2 Nhóm thông tin Số liệu hợp đồng ủy thác danh mục per CTQLQ

```mermaid
flowchart LR
    subgraph Staging
        S1["FMS.RPTMEMBER"]
        S2["FMS.RPTVALUES"]
        S3["FMS.SECURITIES"]
        SE1["ECAT.ECAT_29_HolidayInfo"]
    end

    subgraph Atomic
        SV1["Member Periodic Report"]
        SV2["Report Import Value"]
        SV3["Fund Management Company"]
        SV4["Calendar Date"]
    end

    subgraph Datamart
        G1["Fact Discretionary Investment Contract Snapshot"]
        G2["Fund Management Company Dimension"]
        G3["Calendar Date Dimension"]
    end

    S1 --> SV1
    S2 --> SV2
    S3 --> SV3
    SE1 --> SV4

    SV1 --> G1
    SV2 --> G1
    SV3 --> G2
    SV4 --> G3

    G2 --> G1
    G3 --> G1
```

**Mục đích:** Cung cấp bảng `Fact Discretionary Investment Contract Snapshot` phục vụ Tab TỔNG QUAN CTQLQ — Nhóm 2, tổng hợp số lượng và giá trị thị trường hợp đồng ủy thác danh mục đầu tư per CTQLQ theo tháng, phân theo cá nhân và tổ chức.

**Mô tả luồng:**

Staging → Atomic:
- **Member Periodic Report:** Bảng lưu thông tin kỳ báo cáo định kỳ của thành viên lấy thông tin từ bảng FMS.RPTMEMBER
- **Report Import Value:** Bảng lưu giá trị các chỉ tiêu báo cáo định kỳ lấy thông tin từ bảng FMS.RPTVALUES
- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

Atomic → Datamart:
- **Fact Discretionary Investment Contract Snapshot:** Bảng sự kiện tổng hợp thông tin số lượng và giá trị hợp đồng UTDM per CTQLQ × kỳ báo cáo
- **Fund Management Company Dimension:** Bảng lưu thông tin công ty quản lý quỹ (SCD2)
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian

---

#### 3.2.1.2.3 Nhóm thông tin Hồ sơ CTQLQ — Fund Management Company Profile

```mermaid
flowchart LR
    subgraph Staging
        S1["FMS.SECURITIES"]
        S2["FMS.FUNDS"]
        S4["FMS.RPTVALUES"]
        S5["FMS.RANK"]
        S6["FMS.RATINGPD"]
        S7["FMS.INVESACC"]
        S8["FMS.INVES"]
    end

    subgraph Atomic
        SV1["Fund Management Company"]
        SV2["Investment Fund"]
        SV4["Report Import Value"]
        SV5["Member Rating"]
        SV6["Member Rating Period"]
        SV7["Discretionary Investment Account"]
        SV8["Discretionary Investment Investor"]
    end

    subgraph Datamart
        G1["Fund Management Company Profile"]
    end

    S1 --> SV1
    S2 --> SV2
    S4 --> SV4
    S5 --> SV5
    S6 --> SV6
    S7 --> SV7
    S8 --> SV8

    SV1 --> G1
    SV4 --> G1
    SV5 --> G1
    SV6 --> G1
```

**Mục đích:** Cung cấp bảng `Fund Management Company Profile` phục vụ Tab TỔNG QUAN CTQLQ — Nhóm 3, hiển thị bảng flat chính với đầy đủ chỉ tiêu per CTQLQ (AUM, số quỹ, số HĐUTDM, CAR, lợi nhuận, vốn điều lệ, vốn CSH, xếp loại CAMEL).

**Mô tả luồng:**

Staging → Atomic:
- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS
- **Report Import Value:** Bảng lưu giá trị các chỉ tiêu báo cáo định kỳ (AUM, lợi nhuận, vốn CSH) lấy thông tin từ bảng FMS.RPTVALUES
- **Member Rating:** Bảng lưu kết quả xếp loại CAMEL của thành viên lấy thông tin từ bảng FMS.RANK
- **Member Rating Period:** Bảng lưu thông tin kỳ đánh giá xếp loại lấy thông tin từ bảng FMS.RATINGPD
- **Discretionary Investment Account:** Bảng lưu thông tin hợp đồng ủy thác danh mục đầu tư lấy thông tin từ bảng FMS.INVESACC
- **Discretionary Investment Investor:** Bảng lưu thông tin nhà đầu tư ủy thác lấy thông tin từ bảng FMS.INVES

Atomic → Datamart:
- **Fund Management Company Profile:** Bảng tác nghiệp lưu danh sách CTQLQ ở trạng thái mới nhất, 1 dòng per CTQLQ tại tháng slicer

---

#### 3.2.1.2.4 Nhóm thông tin Hồ sơ CTQLQ — Fund Management Company Fund List

```mermaid
flowchart LR
    subgraph Staging
        S1["FMS.SECURITIES"]
        S2["FMS.FUNDS"]
        S4["FMS.RPTVALUES"]
        S5["FMS.RANK"]
        S6["FMS.RATINGPD"]
        S7["FMS.INVESACC"]
        S8["FMS.INVES"]
    end

    subgraph Atomic
        SV1["Fund Management Company"]
        SV2["Investment Fund"]
        SV4["Report Import Value"]
        SV5["Member Rating"]
        SV6["Member Rating Period"]
        SV7["Discretionary Investment Account"]
        SV8["Discretionary Investment Investor"]
    end

    subgraph Datamart
        G2["Fund Management Company Fund List"]
    end

    S1 --> SV1
    S2 --> SV2
    S4 --> SV4
    S5 --> SV5
    S6 --> SV6
    S7 --> SV7
    S8 --> SV8

    SV1 --> G2
    SV2 --> G2
    SV4 --> G2
```

**Mục đích:** Cung cấp bảng `Fund Management Company Fund List` phục vụ popup drill-down danh sách quỹ theo CTQLQ tại Tab TỔNG QUAN CTQLQ — Nhóm 3.

**Mô tả luồng:**

Staging → Atomic:
- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS
- **Report Import Value:** Bảng lưu giá trị các chỉ tiêu báo cáo định kỳ (NAV quỹ) lấy thông tin từ bảng FMS.RPTVALUES
- **Member Rating:** Bảng lưu kết quả xếp loại CAMEL của thành viên lấy thông tin từ bảng FMS.RANK
- **Member Rating Period:** Bảng lưu thông tin kỳ đánh giá xếp loại lấy thông tin từ bảng FMS.RATINGPD
- **Discretionary Investment Account:** Bảng lưu thông tin hợp đồng ủy thác danh mục đầu tư lấy thông tin từ bảng FMS.INVESACC
- **Discretionary Investment Investor:** Bảng lưu thông tin nhà đầu tư ủy thác lấy thông tin từ bảng FMS.INVES

Atomic → Datamart:
- **Fund Management Company Fund List:** Bảng tác nghiệp lưu danh sách quỹ per CTQLQ ở trạng thái mới nhất, 1 dòng per quỹ × tháng slicer

---

#### 3.2.1.2.5 Nhóm thông tin Hồ sơ CTQLQ — Fund Management Company Contract List

```mermaid
flowchart LR
    subgraph Staging
        S1["FMS.SECURITIES"]
        S2["FMS.FUNDS"]
        S4["FMS.RPTVALUES"]
        S5["FMS.RANK"]
        S6["FMS.RATINGPD"]
        S7["FMS.INVESACC"]
        S8["FMS.INVES"]
    end

    subgraph Atomic
        SV1["Fund Management Company"]
        SV2["Investment Fund"]
        SV4["Report Import Value"]
        SV5["Member Rating"]
        SV6["Member Rating Period"]
        SV7["Discretionary Investment Account"]
        SV8["Discretionary Investment Investor"]
    end

    subgraph Datamart
        G3["Fund Management Company Contract List"]
    end

    S1 --> SV1
    S2 --> SV2
    S4 --> SV4
    S5 --> SV5
    S6 --> SV6
    S7 --> SV7
    S8 --> SV8

    SV1 --> G3
    SV7 --> G3
    SV8 --> G3
```

**Mục đích:** Cung cấp bảng `Fund Management Company Contract List` phục vụ popup drill-down danh sách hợp đồng UTDM theo CTQLQ tại Tab TỔNG QUAN CTQLQ — Nhóm 3.

**Mô tả luồng:**

Staging → Atomic:
- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS
- **Report Import Value:** Bảng lưu giá trị các chỉ tiêu báo cáo định kỳ lấy thông tin từ bảng FMS.RPTVALUES
- **Member Rating:** Bảng lưu kết quả xếp loại CAMEL của thành viên lấy thông tin từ bảng FMS.RANK
- **Member Rating Period:** Bảng lưu thông tin kỳ đánh giá xếp loại lấy thông tin từ bảng FMS.RATINGPD
- **Discretionary Investment Account:** Bảng lưu thông tin hợp đồng ủy thác danh mục đầu tư lấy thông tin từ bảng FMS.INVESACC
- **Discretionary Investment Investor:** Bảng lưu thông tin nhà đầu tư ủy thác lấy thông tin từ bảng FMS.INVES

Atomic → Datamart:
- **Fund Management Company Contract List:** Bảng tác nghiệp lưu danh sách hợp đồng UTDM per CTQLQ ở trạng thái mới nhất, 1 dòng per hợp đồng ủy thác danh mục đầu tư active tại tháng slicer

---

#### 3.2.1.2.6 Nhóm thông tin NAV quỹ theo kỳ và cross-module QLRR

```mermaid
flowchart LR
    subgraph Staging
        S1["FMS.RPTMEMBER"]
        S2["FMS.RPTVALUES"]
        S3["FMS.FUNDS"]
        S4["FMS.SECURITIES"]
        S5["QLRR.risk_indicator"]
        S6["QLRR.risk_indicator_value"]
        SE1["ECAT.ECAT_29_HolidayInfo"]
    end

    subgraph Atomic
        SV1["Member Periodic Report"]
        SV2["Report Import Value"]
        SV3["Investment Fund"]
        SV4["Fund Management Company"]
        SV5["Risk Indicator"]
        SV6["Risk Indicator Value"]
        SV7["Calendar Date"]
    end

    subgraph Datamart
        G1["Fact Investment Fund NAV Snapshot"]
        G2["Investment Fund Dimension"]
        G3["Fund Management Company Dimension"]
        G4["Calendar Date Dimension"]
    end

    S1 --> SV1
    S2 --> SV2
    S3 --> SV3
    S4 --> SV4
    S5 --> SV5
    S6 --> SV6
    SE1 --> SV7

    SV1 --> G1
    SV2 --> G1
    SV5 --> G1
    SV6 --> G1
    SV3 --> G2
    SV4 --> G3
    SV7 --> G4

    G2 --> G1
    G3 --> G1
    G4 --> G1
```

**Mục đích:** Cung cấp bảng `Fact Investment Fund NAV Snapshot` phục vụ Tab QUỸ ĐẦU TƯ — Nhóm 4, 5, 6, 9, gồm biểu đồ tổng NAV và tỷ lệ NAV/GDP, phân bổ tài sản, biến động NAV theo tháng và so sánh NAV/CCQ với VN-Index và lãi suất liên ngân hàng qua đêm.

**Mô tả luồng:**

Staging → Atomic:
- **Member Periodic Report:** Bảng lưu thông tin kỳ báo cáo định kỳ của thành viên lấy thông tin từ bảng FMS.RPTMEMBER
- **Report Import Value:** Bảng lưu giá trị các chỉ tiêu báo cáo định kỳ (NAV, phân bổ tài sản) lấy thông tin từ bảng FMS.RPTVALUES
- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS
- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Risk Indicator:** Bảng lưu thông tin danh mục chỉ tiêu rủi ro và kinh tế vĩ mô (GDP, VN-Index, lãi suất LNH) lấy thông tin từ bảng QLRR.risk_indicator
- **Risk Indicator Value:** Bảng lưu giá trị các chỉ tiêu rủi ro theo kỳ lấy thông tin từ bảng QLRR.risk_indicator_value
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

Atomic → Datamart:
- **Fact Investment Fund NAV Snapshot:** Bảng sự kiện tổng hợp thông tin NAV, phân bổ tài sản của từng quỹ per kỳ báo cáo, kết hợp chỉ tiêu kinh tế vĩ mô (GDP, VN-Index, lãi suất LNH qua đêm) từ cross-module QLRR
- **Investment Fund Dimension:** Bảng lưu thông tin quỹ đầu tư (SCD2)
- **Fund Management Company Dimension:** Bảng lưu thông tin công ty quản lý quỹ (SCD2)
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian

---

#### 3.2.1.2.7 Nhóm thông tin Số lượng quỹ theo loại hình

```mermaid
flowchart LR
    subgraph Staging
        S1["FMS.FUNDS"]
        SE1["ECAT.ECAT_29_HolidayInfo"]
    end

    subgraph Atomic
        SV1["Investment Fund"]
        SV2["Calendar Date"]
    end

    subgraph Datamart
        G1["Fact Investment Fund Count Snapshot"]
        G2["Calendar Date Dimension"]
    end

    S1 --> SV1
    SE1 --> SV2

    SV1 --> G1
    SV2 --> G2

    G2 --> G1
```

**Mục đích:** Cung cấp bảng `Fact Investment Fund Count Snapshot` phục vụ Tab QUỸ ĐẦU TƯ — Nhóm 7, thống kê số lượng quỹ đầu tư theo từng loại hình (quỹ mở, ETF, đóng, BĐS, thành viên, TTTTT, TP hạ tầng, hưu trí) theo năm.

**Mô tả luồng:**

Staging → Atomic:
- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

Atomic → Datamart:
- **Fact Investment Fund Count Snapshot:** Bảng sự kiện tổng hợp thông tin đếm quỹ theo từng loại hình — grain 1 snapshot toàn thị trường × 1 năm
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian

---

#### 3.2.1.2.8 Nhóm thông tin Số lượng chứng chỉ quỹ lưu hành per quỹ

```mermaid
flowchart LR
    subgraph Staging
        S1["FMS.FUNDS"]
        S2["FMS.TRANSFERMBF"]
        SE1["ECAT.ECAT_29_HolidayInfo"]
    end

    subgraph Atomic
        SV1["Investment Fund"]
        SV2["Investment Fund Certificate Transfer"]
        SV3["Calendar Date"]
    end

    subgraph Datamart
        G1["Fact Investment Fund CCQ Snapshot"]
        G2["Investment Fund Dimension"]
        G3["Calendar Date Dimension"]
    end

    S1 --> SV1
    S2 --> SV2
    SE1 --> SV3

    SV1 --> G1
    SV2 --> G1
    SV1 --> G2
    SV3 --> G3

    G2 --> G1
    G3 --> G1
```

**Mục đích:** Cung cấp bảng `Fact Investment Fund CCQ Snapshot` phục vụ Tab QUỸ ĐẦU TƯ — Nhóm 8, thống kê số lượng chứng chỉ quỹ lưu hành per quỹ theo tháng, tính từ tích lũy giao dịch chuyển nhượng.

**Mô tả luồng:**

Staging → Atomic:
- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS
- **Investment Fund Certificate Transfer:** Bảng lưu thông tin giao dịch chuyển nhượng chứng chỉ quỹ (mua/bán tích lũy) lấy thông tin từ bảng FMS.TRANSFERMBF
- **Calendar Date:** Bảng lưu thông tin lịch ngày lấy thông tin từ bảng ECAT.ECAT_29_HolidayInfo

Atomic → Datamart:
- **Fact Investment Fund CCQ Snapshot:** Bảng sự kiện tổng hợp thông tin số lượng CCQ lưu hành per quỹ × kỳ snapshot, tính bằng tổng mua trừ tổng bán
- **Investment Fund Dimension:** Bảng lưu thông tin quỹ đầu tư (SCD2)
- **Calendar Date Dimension:** Bảng lưu thông tin thời gian

---

#### 3.2.1.2.9 Nhóm thông tin Danh sách quỹ đầu tư

```mermaid
flowchart LR
    subgraph Staging
        S1["FMS.FUNDS"]
        S2["FMS.SECURITIES"]
        S3["FMS.RPTMEMBER"]
        S4["FMS.RPTVALUES"]
    end

    subgraph Atomic
        SV1["Investment Fund"]
        SV2["Fund Management Company"]
        SV3["Member Periodic Report"]
        SV4["Report Import Value"]
    end

    subgraph Datamart
        G1["Investment Fund Profile"]
    end

    S1 --> SV1
    S2 --> SV2
    S3 --> SV3
    S4 --> SV4

    SV1 --> G1
    SV2 --> G1
    SV3 --> G1
    SV4 --> G1
```

**Mục đích:** Cung cấp bảng `Investment Fund Profile` phục vụ Tab QUỸ ĐẦU TƯ — Nhóm 10, hiển thị danh sách quỹ đầu tư với các chỉ tiêu NAV, lợi nhuận YTD và số lượng CCQ lưu hành tại tháng slicer.

**Mô tả luồng:**

Staging → Atomic:
- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS
- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Member Periodic Report:** Bảng lưu thông tin kỳ báo cáo định kỳ lấy thông tin từ bảng FMS.RPTMEMBER
- **Report Import Value:** Bảng lưu giá trị các chỉ tiêu báo cáo định kỳ (NAV, lợi nhuận) lấy thông tin từ bảng FMS.RPTVALUES

Atomic → Datamart:
- **Investment Fund Profile:** Bảng tác nghiệp lưu danh sách quỹ đầu tư ở trạng thái mới nhất, 1 dòng per quỹ × tháng slicer

---

#### 3.2.1.2.10 Nhóm thông tin Pass-through báo cáo

```mermaid
flowchart LR
    subgraph Staging
        S1["FMS.RPTVALUES"]
        S2["FMS.RPTMEMBER"]
        S3["FMS.SECURITIES"]
        S4["FMS.FUNDS"]
    end

    subgraph Atomic
        SV1["Report Import Value"]
        SV2["Member Periodic Report"]
        SV3["Fund Management Company"]
        SV4["Investment Fund"]
    end

    subgraph Datamart
        G1["Report Pass-through View"]
    end

    S1 --> SV1
    S2 --> SV2
    S3 --> SV3
    S4 --> SV4

    SV1 --> G1
    SV2 --> G1
    SV3 --> G1
    SV4 --> G1
```

**Mục đích:** Cung cấp bảng `Report Pass-through View` phục vụ Tab DATA EXPLORER — Nhóm 12–16, cho phép tra cứu toàn bộ giá trị từng dòng chỉ tiêu báo cáo định kỳ của CTQLQ và quỹ đầu tư theo biểu mẫu và kỳ.

**Mô tả luồng:**

Staging → Atomic:
- **Report Import Value:** Bảng lưu giá trị các chỉ tiêu báo cáo định kỳ lấy thông tin từ bảng FMS.RPTVALUES
- **Member Periodic Report:** Bảng lưu thông tin kỳ báo cáo định kỳ lấy thông tin từ bảng FMS.RPTMEMBER
- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Investment Fund:** Bảng lưu thông tin quỹ đầu tư lấy thông tin từ bảng FMS.FUNDS

Atomic → Datamart:
- **Report Pass-through View:** Bảng tác nghiệp lưu danh sách toàn bộ giá trị chỉ tiêu báo cáo dạng flat ở trạng thái mới nhất, 1 dòng per CTQLQ/Quỹ × biểu mẫu × kỳ × dòng chỉ tiêu

---

#### 3.2.1.2.11 Nhóm thông tin Báo cáo giao dịch nhân viên CTQLQ

```mermaid
flowchart LR
    subgraph Staging
        S1["FMS.TLProfiles"]
        S2["FMS.SECURITIES"]
        S3["GSGD.investor_account"]
    end

    subgraph Atomic
        SV1["Fund Management Company Key Person"]
        SV2["Involved Party Alternative Identification"]
        SV3["Fund Management Company"]
        SV4["Investor Trading Account"]
    end

    subgraph Datamart
        G1["Fund Management Company Staff Trade Report"]
    end

    S1 --> SV1
    S1 --> SV2
    S2 --> SV3
    S3 --> SV4

    SV1 --> G1
    SV2 --> G1
    SV3 --> G1
    SV4 --> G1
```

**Mục đích:** Cung cấp bảng `Fund Management Company Staff Trade Report` phục vụ Tab BÁO CÁO / CÔNG TY QLQ — Nhóm 11, hiển thị danh sách nhân viên CTQLQ và tài khoản giao dịch chứng khoán tương ứng (cross-module FMS × GSGD).

**Mô tả luồng:**

Staging → Atomic:
- **Fund Management Company Key Person:** Bảng lưu thông tin nhân viên chủ chốt của công ty quản lý quỹ lấy thông tin từ bảng FMS.TLProfiles
- **Involved Party Alternative Identification:** Bảng lưu thông tin giấy tờ định danh thay thế (CCCD/Hộ chiếu) của nhân viên, dùng làm join key sang GSGD, lấy thông tin từ bảng FMS.TLProfiles
- **Fund Management Company:** Bảng lưu thông tin công ty quản lý quỹ lấy thông tin từ bảng FMS.SECURITIES
- **Investor Trading Account:** Bảng lưu thông tin tài khoản giao dịch chứng khoán lấy thông tin từ bảng GSGD.investor_account

Atomic → Datamart:
- **Fund Management Company Staff Trade Report:** Bảng tác nghiệp lưu danh sách nhân viên CTQLQ kèm tài khoản giao dịch chứng khoán ở trạng thái mới nhất, 1 dòng per nhân viên × tài khoản GDCK
