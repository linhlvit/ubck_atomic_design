# Data Mart HLD — Phân hệ Nhà Đầu Tư Nước Ngoài (NDTNN)

**Phiên bản:** 2.6
**Ngày:** 22/05/2026

---

## Quy ước trạng thái

| Ký hiệu | Ý nghĩa |
|---|---|
| READY | Atomic đủ — thiết kế đầy đủ |
| PENDING | Atomic chưa có — placeholder + lý do |

---

## Section 1 — Data Lineage: Source → Atomic → Data Mart

##### Cụm 1a: Giao dịch NĐTNN toàn thị trường (Securities Foreign Trading Snapshot)

Phục vụ Tab GIAO DỊCH Nhóm 1 — Box 1 (Tỷ lệ tham gia, Tổng GT mua/bán/toàn thị trường) và Nhóm 2 (Tổng GT mua/bán ròng + Lũy kế + Top ngành/mã).

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        S1["ORDERTRADE.TRADE_BOOK_HOSE"]
        S2["ORDERTRADE.TRADE_BOOK_HNX"]
        S3["IDS.COMPANY_PROFILES"]
        S4["IDS.CATEGORIES"]
    end

    subgraph SIL["Atomic"]
        SV1["Securities Trade"]
        SV2["Public Company"]
        SV3["Classification Business Line"]
    end

    subgraph Datamart["Datamart"]
        G1["Fact Securities Foreign Trading Snapshot"]
        G2["Public Company Dimension"]
    end

    S1 --> SV1
    S2 --> SV1
    S3 --> SV2
    S4 --> SV3

    SV1 --> G1
    SV2 --> G2
    SV3 --> G2
    G2 --> G1
```

---

##### Cụm 1b: Đăng ký NĐT nước ngoài (Foreign Investor Registration) — PENDING

**Trạng thái:** PENDING — xem Nhóm 1 Box 2–4 (Section 2). Nguồn thực tế là báo cáo định kỳ PLVI-TT51 (VSDC, kỳ tháng), không phải `FIMS.INVESTOR.DateCreated` như thiết kế trước đây. Giữ lại Cụm này ở trạng thái tham khảo — không dùng làm nguồn chính thức cho đến khi xác nhận generic store TT51 tương ứng.

---

##### Cụm 2: Hồ sơ 360° NĐT nước ngoài (Foreign Investor 360 Profile)

Phục vụ Tab NĐTNN 360 — Danh sách tìm kiếm + Sub-tab A Hồ sơ định danh.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        S1["FIMS.INVESTOR"]
        S2["FIMS.BANKMONI"]
    end

    subgraph SIL["Atomic"]
        SV1["Foreign Investor"]
        SV2["Custodian Bank"]
    end

    subgraph Datamart["Datamart"]
        G1["Foreign Investor 360 Profile"]
    end

    S1 --> SV1
    S2 --> SV2

    SV1 --> G1
    SV2 --> G1
```

---

##### Cụm 3a: Danh mục chứng khoán NĐTNN (Fact Foreign Investor Portfolio Snapshot) — PENDING

**Trạng thái:** PENDING — xem Nhóm 6 (Section 2). Entity Atomic `Foreign Investor Stock Portfolio Snapshot` ghi trong thiết kế cũ **không tồn tại** trong `DataModel/working/Atomic/lld/manifest.yaml` hiện hành — `FIMS.CATEGORIESSTOCK` thực chất đã gộp vào entity `Foreign Investor Securities Account` (table_type Fundamental, current-state 1 tài khoản × 1 CTCK, KHÔNG phải Fact Snapshot theo tháng, không có `Portfolio Market Value`). Ngoài ra 6/7 KPI của Nhóm 6 đánh dấu Dữ liệu động (nguồn thật là báo cáo PLIII-TT51/2021/TT-BTC, kỳ tháng) — xem chi tiết Nhóm 6. Giữ lại Cụm này ở trạng thái tham khảo — không dùng `Foreign Investor Securities Account` làm nguồn chính thức cho Fact Snapshot này cho đến khi xác nhận nguồn giá trị thị trường danh mục (Portfolio Market Value) qua generic store TT51.

---

##### Cụm 3b: Foreign Investor Dimension / Public Company Dimension (READY — dùng chung nhiều Nhóm)

**Trạng thái:** READY — 2 entity này vẫn READY, dùng chung cho các Nhóm khác của module (Nhóm 2, 4, 9...).

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        S2["FIMS.INVESTOR"]
        S4["IDS.company_profiles"]
        S5["IDS.company_detail"]
    end

    subgraph SIL["Atomic"]
        SV2["Foreign Investor"]
        SV4["Public Company"]
    end

    subgraph Datamart["Datamart"]
        G2["Foreign Investor Dimension"]
        G6["Public Company Dimension"]
    end

    S2 --> SV2
    S4 --> SV4
    S5 --> SV4

    SV2 --> G2
    SV4 --> G6
```

---

##### Cụm 3c: Quốc gia NĐTNN (Geographic Area Dimension) — PENDING

**Trạng thái:** PENDING — thiết kế cũ ghi nguồn `FIMS.NATIONAL` cho `Geographic Area`, nhưng đối chiếu `DataModel/working/Atomic/lld/manifest.yaml`, entity `Geographic Area` (approved) chỉ có nguồn từ `ECAT.COUNTRY/REGION/PROVINCE_NEW/WARD_NEW` — không có entry nào từ `FIMS`/`FIMS.NATIONAL`. Quốc gia/quốc tịch của NĐTNN trong FIMS chưa được xác nhận map vào Atomic `Geographic Area` — cần entity nguồn riêng hoặc xác nhận bảng FIMS thật lưu quốc tịch NĐT (nghi ngờ tên "NATIONAL" trong thiết kế cũ cũng sai/lỗi thời, cần Data Modeler xác nhận tên bảng FIMS thật). Không dùng `Geographic Area` (nguồn ECAT) làm nguồn chính thức cho Chiều "Quốc gia NĐTNN" cho đến khi xác nhận đúng bảng nguồn FIMS.

---

##### Cụm 4: Lịch sử tuân thủ NĐTNN (Investor Compliance History)

Phục vụ Tab NĐTNN 360 — Sub-tab C Lịch sử tuân thủ (STT=13). Atomic từ phân hệ Thanh Tra, nguồn `PENALTY_DECISION*`/`PENALTY_TYPE` — **sửa Kịch bản D** (2026-07-23): nguồn cũ ghi `GS_HO_SO`/`GS_VAN_BAN_XU_LY` (entity `Surveillance Enforcement Case`/`Decision`) không khớp BA thật — xem O_NDTNN_26.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        S1["THANHTRA.PENALTY_DECISION"]
        S2["THANHTRA.PENALTY_DECISION_SUBJECT"]
        S3["THANHTRA.PENALTY_DECISION_SUBJECT_BEHAVIOR"]
        S4["THANHTRA.PENALTY_TYPE"]
    end

    subgraph SIL["Atomic"]
        SV1["Penalty Decision"]
        SV2["Penalty Decision Subject"]
        SV3["Penalty Decision Subject Behavior"]
        SV4["Penalty Type"]
    end

    subgraph Datamart["Datamart"]
        G1["Investor Compliance History"]
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

---

##### Cụm 5a: Dòng vốn đầu tư gián tiếp (Foreign Investor Capital Flow) — PENDING

**Trạng thái:** PENDING — xem Nhóm 3, 4, 5 (Section 2) + Nhóm 11a (Data Explorer). Toàn bộ measure "Dòng vốn/tiền vào/ra/ròng" đánh dấu Dữ liệu động — nguồn thực tế là báo cáo định kỳ PLIV-TT51 (Ngân hàng lưu ký gửi, kỳ nửa tháng), chưa thống nhất quy tắc khai thác trong generic store TT51 (Cụm 7). `Foreign Investor` vẫn READY (dùng chung Nhóm 2/4/6/9) — riêng `Geographic Area` giờ cũng PENDING (xem Cụm 3c — nguồn ECAT, không có entry FIMS, không dùng được cho Chiều quốc gia NĐTNN) — không dùng `Member Report Value`/`Member Regulatory Report` làm nguồn chính thức cho Fact động này cho đến khi xác nhận Report Code/Cell Code tương ứng.

---

##### Cụm 5b: Foreign Investor Dimension (READY — dùng chung nhiều Nhóm)

**Trạng thái:** READY — `Foreign Investor` vẫn READY, dùng chung Nhóm 2/4/6/9. Không còn Fact READY nào join tới ở trạng thái hiện tại (Fact chính từng dùng, `Fact Foreign Investor Portfolio Snapshot`, đã chuyển PENDING — xem Cụm 3a/O_NDTNN_21) — Dimension vẫn giữ READY vì bản thân entity Atomic không phụ thuộc trạng thái Fact.

---

##### Cụm 5c: Chỉ số thị trường (Market Index Snapshot)

Phục vụ Tab GIÁM SÁT DÒNG VỐN Nhóm 5 — Điểm đóng cửa VN-Index (K_NDTNN_24b).

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        S1["MDDS.JAD_MARKETINFOR"]
    end

    subgraph SIL["Atomic"]
        SV1["Market Index Snapshot"]
    end

    subgraph Datamart["Datamart"]
        G1["Fact Market Index Snapshot"]
    end

    S1 --> SV1

    SV1 --> G1
```

---

##### Cụm 6: Giới hạn sở hữu nước ngoài — ROOM (Fact Public Company Foreign Ownership Snapshot) — PENDING

**Trạng thái:** PENDING — xem Nhóm 9 (Section 2) + O_NDTNN_22. BA STT=9 xác nhận toàn bộ 6/6 dòng nguồn là báo cáo BM67 "Quản lý thông tin nhà đầu tư nước ngoài" (VSDC, chưa số hoá CSDL) hoặc Dữ liệu động — **không dùng** `Public Company Foreign Ownership Limit` (IDS.FOREIGN_OWNER_LIMIT) hay `Foreign Investor Securities Account` (FIMS) dù 2 entity này có sẵn và khớp khái niệm nghiệp vụ (Room tối đa, Ownership Rate). Giữ lại Cụm này ở trạng thái tham khảo — không dùng làm nguồn chính thức cho đến khi Data Modeler xác nhận nguồn go-live là BM67 (cần số hoá) hay entity IDS/FIMS đã có.

---

##### Cụm 7: Báo cáo TT51 — Generic Store (NDTNN Regulatory Report Store) — PENDING

**Trạng thái:** PENDING — xem Nhóm 12 + Nhóm 19-43 (Section 2) + O_NDTNN_25/O_NDTNN_27. Nhóm 12 (STT=18) và 25 Nhóm mới Nhóm 19-43 (STT=19-43, cùng pattern Data Explorer Pass-through PLII/III/IV/V/VI/VII/VIII/IX/X-TT51, TT96) đều xác nhận 100% dòng BA là Dữ liệu động → PENDING theo gate rule, dù `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS) đã có LLD draft. Giữ lại Cụm này ở trạng thái tham khảo — không dùng làm nguồn chính thức cho đến khi xác nhận 26 Report Code/Cell Code tương ứng (1 cho mỗi loại báo cáo, cùng gốc rễ Nhóm 3/4/5/6/9/11b).

---

##### Cụm 8: Báo cáo giao dịch NĐTNN theo loại chứng khoán (partial — Fact Securities Foreign Trading Snapshot)

Phục vụ Tab BÁO CÁO Nhóm 14 — bổ sung cột `Security_Type_Code` (Cổ phiếu/Trái phiếu/Tổng) vào `Fact Securities Foreign Trading Snapshot` đã có (Cụm 1a) — không tạo Fact mới.

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        S1["ORDERTRADE.TRADE_BOOK_HOSE"]
        S2["ORDERTRADE.TRADE_BOOK_HNX"]
    end

    subgraph SIL["Atomic"]
        SV1["Securities Trade"]
    end

    subgraph Datamart["Datamart"]
        G1["Fact Securities Foreign Trading Snapshot"]
    end

    S1 --> SV1
    S2 --> SV1

    SV1 --> G1
```

---

##### Cụm 9: Báo cáo chi tiết giao dịch NĐTNN theo tài khoản (Securities Foreign Investor Trade Detail)

Phục vụ Tab BÁO CÁO Nhóm 15 — grain 1 giao dịch × 1 tài khoản NĐT, khác grain Cụm 1a/8 (không pre-aggregate).

```mermaid
flowchart LR
    subgraph SRC["Staging"]
        S1["ORDERTRADE.TRADE_BOOK_HOSE"]
        S2["ORDERTRADE.TRADE_BOOK_HNX"]
    end

    subgraph SIL["Atomic"]
        SV1["Securities Trade"]
    end

    subgraph Datamart["Datamart"]
        G1["Fact Securities Foreign Investor Trade Detail"]
    end

    S1 --> SV1
    S2 --> SV1

    SV1 --> G1
```

---

## Section 2 — Tổng quan báo cáo

### Tab: GIAO DỊCH

**Slicer chung:** Ngày (date picker — ví dụ: 12/31/2024)

---

#### Nhóm 1 — KPI Cards tổng quan

**Mockup:**

| Tỷ lệ tham gia | Tăng trưởng NĐT mới | Tăng trưởng NĐT Cá nhân mới | Tăng trưởng NĐT Tổ chức mới |
|:---:|:---:|:---:|:---:|
| **12.4** % | **2,450** Mã | **1,830** Mã | **620** Mã |

---

> Phân loại: **Phân tích**
> Atomic (Box 1): `Securities Trade` ← ORDERTRADE.TRADE_BOOK_HOSE / ORDERTRADE.TRADE_BOOK_HNX — **READY**
> Atomic (Box 2-4): xem dòng PENDING trong bảng KPI dưới đây
> Loại dữ liệu: Dữ liệu tĩnh (Box 1, BA đã chốt logic mapping + SQL tham khảo đầy đủ) / Dữ liệu động (Box 2-4)

**Source:** `Fact Securities Foreign Trading Snapshot` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên | Đơn vị | Tính chất | Công thức / Mô tả | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_2 | Tổng giá trị mua của NĐTNN | Tỷ đồng | Cơ sở | `SUM(Foreign_Buy_Value)` GROUP BY `Trade Date Dimension Id` WHERE `Trade Date = :pdate` (SUM xuyên suốt mọi mã CK trong ngày) | Grain Fact = 1 mã CK × 1 ngày (xem Nhóm 2) — Box 1 pre-aggregate SUM lên cấp "1 ngày toàn thị trường" | READY |
| K_NDTNN_3 | Tổng giá trị bán của NĐTNN | Tỷ đồng | Cơ sở | `SUM(Foreign_Sell_Value)` GROUP BY `Trade Date Dimension Id` WHERE `Trade Date = :pdate` (SUM xuyên suốt mọi mã CK trong ngày) | Pre-aggregate như trên | READY |
| K_NDTNN_4 | Tổng giá trị giao dịch toàn thị trường | Tỷ đồng | Cơ sở | `SUM(Total_Market_Value)` GROUP BY `Trade Date Dimension Id` WHERE `Trade Date = :pdate` (SUM xuyên suốt mọi mã CK trong ngày, không lọc theo NĐT) | Pre-aggregate như trên | READY |
| K_NDTNN_1 | Tỷ lệ tham gia | % | Phái sinh | `(K_NDTNN_2 + K_NDTNN_3) × 100 / (K_NDTNN_4 × 2)` | Derived từ K_NDTNN_2/3/4 cùng ngày | READY |
| K_NDTNN_5 | Tăng trưởng NĐT mới | — | Phái sinh | TBD — chờ Atomic | **Lý do pending:** Dữ liệu động — nguồn thực tế báo cáo định kỳ PLVI-TT51/2021/TT-BTC (VSDC, kỳ tháng), COUNT "Mã số giao dịch chứng khoán" tại Mục "I. Thông tin chung" (Dòng Tổng, cột "Tổng số lượng tới thời điểm báo cáo") — không phải COUNT event FIMS.INVESTOR.DateCreated như thiết kế cũ (xem O_NDTNN_1). **Atomic cần bổ sung:** xác nhận báo cáo PLVI-TT51 thuộc generic store `Member Regulatory Report`/`Member Report Value` (Cụm 7) hay cần entity riêng — cần Report Code/Cell Code. **Mart dự kiến:** `Fact Foreign Investor Registration Report` (tên tạm) — grain 1 kỳ báo cáo (tháng) × 1 phân loại NĐT | PENDING |
| K_NDTNN_6 | Tăng trưởng NĐT Cá nhân mới | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn với K_NDTNN_5 — Dòng "Cá nhân" trong báo cáo PLVI-TT51 | PENDING |
| K_NDTNN_7 | Tăng trưởng NĐT Tổ chức mới | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn với K_NDTNN_5 — Dòng "Tổ chức" trong báo cáo PLVI-TT51 | PENDING |
| K_NDTNN_5_YOY | YoY% NĐT mới | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn với K_NDTNN_5 — YoY dựa trên cùng chỉ tiêu | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| Tăng trưởng NĐT mới / Cá nhân / Tổ chức / YoY | Báo cáo PLVI-TT51/2021/TT-BTC (VSDC, kỳ tháng) | Member Regulatory Report / Member Report Value (Cụm 7 — cần xác nhận Report Code) | TBD |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        int Date_Dimension_Id PK
        date Full_Date
        int Year
        int Month
        int Day_Of_Year
    }
    Fact_Securities_Foreign_Trading_Snapshot {
        int Trade_Date_Dimension_Id FK
        varchar Security_Symbol_Code
        float Foreign_Buy_Value
        float Foreign_Sell_Value
        float Total_Market_Value
    }

    Calendar_Date_Dimension ||--o{ Fact_Securities_Foreign_Trading_Snapshot : "Trade Date Dimension Id"
```

> **Lưu ý grain:** Fact có grain "1 mã CK × 1 ngày" (mở rộng ở Nhóm 2 để phục vụ Top ngành/mã). Box 1 (K_NDTNN_1-4) hiển thị số toàn thị trường — không phân theo mã CK — nên công thức phải `GROUP BY Trade_Date_Dimension_Id` (SUM xuyên suốt `Security_Symbol_Code`), không SUM trực tiếp theo dòng.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Fact Securities Foreign Trading Snapshot"]
        G2["Calendar Date Dimension"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_NDTNN_1-4: Tab GIAO DICH - Nhom 1 - Ty le tham gia"]
    end
    G1 --> R1
    G2 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Securities Foreign Trading Snapshot | 1 row = 1 mã CK × 1 ngày giao dịch (ETL pre-aggregate SUM Execution Value từ Securities Trade theo mã CK, tách theo Buy/Sell Foreign Investor Type Code) — xem Nhóm 2 cho chi tiết đầy đủ |
| Calendar Date Dimension | 1 row = 1 ngày giao dịch |

---

#### Nhóm 2 — Tổng giá trị mua/bán ròng của NĐTNN

**Mockup:**

| Bar chart | Lũy kế mua/bán ròng |
|:---|---:|
| Trục X: Tháng (Jan → Oct) | -8,300 B |
| Trục Y: Giá trị (tỉ đồng) | (lũy kế kỳ chọn) |

| TOP NGÀNH BÁN RÒNG | | TOP NGÀNH MUA RÒNG | | TOP MÃ BÁN RÒNG | | TOP MÃ MUA RÒNG | |
|:---|---:|:---|---:|:---|---:|:---|---:|
| Bất động sản | -1200B | Ngân hàng | +4500B | VHM | -700B | HPG | +3300B |
| Thực phẩm | -450B | Thép / Tài nguyên | +2800B | MSN | -400B | VCB | +600B |

**Slicer:** Từ ngày — Đến ngày (date range picker)

---

> Phân loại: **Phân tích**
> Atomic: `Securities Trade` ← ORDERTRADE.TRADE_BOOK_HOSE/HNX — **READY** (dùng chung Nhóm 1)
> Atomic (Ngành): `Classification Business Line` ← IDS.CATEGORIES — **READY (draft)**
> Atomic (Mã CK → Ngành): `Public Company` ← IDS.COMPANY_PROFILES — **READY (draft, working)** — join qua `Equity Ticker Symbol` = `Security Symbol Code`, và `Business Line Level 1/2 Code` → `Classification Business Line Code`
> Loại dữ liệu: Dữ liệu tĩnh

**Source:** `Fact Securities Foreign Trading Snapshot` → `Calendar Date Dimension`, `Public Company Dimension` (join `Classification Business Line` cho Top ngành)

**Bảng KPI:**

| KPI ID | Tên | Đơn vị | Tính chất | Công thức / Mô tả | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_9 | Ngành | — | Chiều | `Public_Company_Dimension.Classification_Business_Line_Name` (đã đệm sẵn từ join `Public_Company_Dimension.Business_Line_Level1_Code` = `Classification_Business_Line.cl_business_line_code` lúc ETL populate Dimension) | Dùng GROUP BY cho Top ngành (K_NDTNN_12/13/16) | READY |
| K_NDTNN_10 | Mã CK | — | Chiều | `Fact_Securities_Foreign_Trading_Snapshot.Security_Symbol_Code` | Dùng GROUP BY cho Top mã (K_NDTNN_14/15) | READY |
| K_NDTNN_8 | Giá trị mua/bán ròng | Tỷ đồng | Phái sinh | `Foreign_Buy_Value − Foreign_Sell_Value` per mã CK × ngày; nếu group theo Tháng: `SUM(Foreign_Buy_Value − Foreign_Sell_Value)` GROUP BY Tháng | Bar chart trục X = Tháng | READY |
| K_NDTNN_11 | Lũy kế mua/bán ròng | Tỷ đồng | Phái sinh | `SUM(Foreign_Buy_Value) − SUM(Foreign_Sell_Value)` WHERE `Trade_Date_Dimension_Id` BETWEEN `:pdate` AND `:pdate1` (SUM xuyên suốt mọi mã CK trong khoảng ngày) | — | READY |
| K_NDTNN_12 | Top 5 ngành bán ròng | Tỷ đồng | Phái sinh | `SUM(Foreign_Sell_Value)` WHERE `Trade_Date = :pdate` GROUP BY `Public_Company_Dimension.Classification_Business_Line_Name` ORDER BY SUM DESC FETCH FIRST 5 ROWS ONLY | Join `Fact` → `Public_Company_Dimension` | READY |
| K_NDTNN_13 | Top 5 ngành mua ròng | Tỷ đồng | Phái sinh | `SUM(Foreign_Buy_Value)` WHERE `Trade_Date = :pdate` GROUP BY `Public_Company_Dimension.Classification_Business_Line_Name` ORDER BY SUM DESC FETCH FIRST 5 ROWS ONLY | Join như trên | READY |
| K_NDTNN_14 | Top 5 mã bán ròng | Tỷ đồng | Phái sinh | `SUM(Foreign_Sell_Value) − SUM(Foreign_Buy_Value)` WHERE `Trade_Date` BETWEEN `:pdate` AND `:pdate1` GROUP BY `Security_Symbol_Code` ORDER BY kết quả DESC FETCH FIRST 5 ROWS ONLY | — | READY |
| K_NDTNN_15 | Top 5 mã mua ròng | Tỷ đồng | Phái sinh | `SUM(Foreign_Buy_Value) − SUM(Foreign_Sell_Value)` WHERE `Trade_Date` BETWEEN `:pdate` AND `:pdate1` GROUP BY `Security_Symbol_Code` ORDER BY kết quả DESC FETCH FIRST 5 ROWS ONLY | — | READY |
| K_NDTNN_16 | Tỷ trọng theo ngành | % | Phái sinh | `ROUND(SUM(Foreign_Buy_Value + Foreign_Sell_Value) / NULLIF(SUM(Total_Market_Value)*2, 0) * 100, 2)` WHERE `Trade_Date = :pdate` GROUP BY `Public_Company_Dimension.Classification_Business_Line_Name` — mẫu số SUM theo TOÀN NGÀNH (mọi mã CK cùng ngành) | Khác K_NDTNN_159 — mẫu số theo ngành, không phải theo mã | READY |
| K_NDTNN_159 | Top mã tỷ trọng cao | % | Phái sinh | `ROUND(SUM(Foreign_Buy_Value + Foreign_Sell_Value) / NULLIF(SUM(Total_Market_Value)*2, 0) * 100, 2)` WHERE `Trade_Date = :pdate` GROUP BY `Security_Symbol_Code` ORDER BY kết quả DESC FETCH FIRST 5 ROWS ONLY | Mẫu số SUM theo TỪNG MÃ CK (1 mã × 1 ngày, không cần GROUP thêm vì Fact đã ở đúng grain này). BA Mã=22 (STT=2) — đổi từ K_NDTNN_22 vì ID đó đã dùng cho "Giá trị mua/bán ròng" ở Nhóm 5 (STT=5) | READY |
| K_NDTNN_2 (reuse) | Tổng giá trị mua của NĐTNN | Tỷ đồng | Cơ sở | `SUM(Foreign_Buy_Value)` GROUP BY `Trade_Date_Dimension_Id` WHERE `Trade_Date = :pdate` | Reuse từ Nhóm 1 | READY |
| K_NDTNN_3 (reuse) | Tổng giá trị bán của NĐTNN | Tỷ đồng | Cơ sở | `SUM(Foreign_Sell_Value)` GROUP BY `Trade_Date_Dimension_Id` WHERE `Trade_Date = :pdate` | Reuse từ Nhóm 1 | READY |
| K_NDTNN_4 (reuse) | Tổng giá trị giao dịch toàn thị trường | Tỷ đồng | Cơ sở | `SUM(Total_Market_Value)` GROUP BY `Trade_Date_Dimension_Id` WHERE `Trade_Date = :pdate` | Reuse từ Nhóm 1 | READY |
| K_NDTNN_1 (reuse) | Tỷ trọng giao dịch theo ngày | % | Phái sinh | `(K_NDTNN_2 + K_NDTNN_3) × 100 / (K_NDTNN_4 × 2)` | Reuse từ Nhóm 1 — tên hiển thị khác ("Tỷ trọng GD theo ngày" thay vì "Tỷ lệ tham gia") nhưng cùng công thức | READY |
| — (=K_NDTNN_2+3, reuse) | Tổng giá trị giao dịch NĐTNN | Tỷ đồng | Phái sinh | `K_NDTNN_2 + K_NDTNN_3` cùng ngày | Reuse công thức từ Nhóm 1, không cấp KPI_ID mới (derived thuần từ 2 KPI cùng bảng) | READY |
| K_NDTNN_158 | Tỷ trọng TB phiên | % | Phái sinh | `AVG(ty_trong_ngay)` WHERE `Trade_Date` BETWEEN `:pdate` AND `:pdate1`, trong đó `ty_trong_ngay = (Foreign_Buy_Value + Foreign_Sell_Value) / (Total_Market_Value × 2) × 100` tính theo từng ngày (SUM xuyên mọi mã CK trong ngày đó trước khi tính tỷ trọng ngày, rồi AVG qua các ngày) | BA note "Tái sử dụng logic từ chỉ tiêu đã mapping ở nhóm trước" (= công thức K_NDTNN_1, nhưng là KPI độc lập — không note "Trùng" nên cấp ID riêng theo đúng dải liên tục tiếp theo, không chèn giữa dải 1-157). Cần xác nhận `Trade_Date` là ngày GD thực tế hay ngày khớp lệnh — BA tự ghi chú nghi vấn này | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        int Date_Dimension_Id PK
        date Full_Date
        int Year
        int Month
        int Day_Of_Year
    }
    Public_Company_Dimension {
        int Public_Company_Dimension_Id PK
        varchar Security_Symbol_Code
        string Public_Company_Name
        varchar Business_Line_Level1_Code
        varchar Business_Line_Level2_Code
        varchar Classification_Business_Line_Name
        string Source_System_Code
    }
    Fact_Securities_Foreign_Trading_Snapshot {
        int Trade_Date_Dimension_Id FK
        int Public_Company_Dimension_Id FK
        varchar Security_Symbol_Code
        float Foreign_Buy_Value
        float Foreign_Sell_Value
        float Total_Market_Value
    }

    Calendar_Date_Dimension ||--o{ Fact_Securities_Foreign_Trading_Snapshot : "Trade Date Dimension Id"
    Public_Company_Dimension ||--o{ Fact_Securities_Foreign_Trading_Snapshot : "Public Company Dimension Id"
```

> **Ghi chú thiết kế:** `Public_Company_Dimension.Classification_Business_Line_Name` là ETL-derived — join `Public Company.Business_Line_Level1/2_Code` sang `Classification Business Line.cl_business_line_code` lúc populate Dimension, lưu đệm tên ngành để tránh join 3 tầng khi query Top ngành.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Fact Securities Foreign Trading Snapshot"]
        G2["Public Company Dimension"]
        G3["Calendar Date Dimension"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_NDTNN_8-16,158-159: Tab GIAO DICH - Nhom 2 - Tong GT mua ban rong"]
    end
    G1 --> R1
    G2 --> R1
    G3 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Securities Foreign Trading Snapshot | 1 row = 1 mã CK × 1 ngày giao dịch (ETL pre-aggregate SUM Execution Value từ Securities Trade theo mã CK, tách theo Buy/Sell Foreign Investor Type Code) |
| Public Company Dimension | 1 row = 1 mã CK niêm yết (SCD2) — bao gồm Classification Business Line Name đệm sẵn |
| Calendar Date Dimension | 1 row = 1 ngày giao dịch |

---

### Tab: GIÁM SÁT DÒNG VỐN

**Slicer chung:** Từ ngày — Đến ngày (date range picker)

---

#### Nhóm 3 — KPI Cards: Dòng tiền vào / ra / ròng (STT=3)

**Mockup:**

| Dòng tiền vào | Dòng tiền ra | Dòng tiền ròng |
|:---:|:---:|:---:|
| **1,284.3** Tỉ đồng | **1,736.8** Tỉ đồng | **-452.5** Tỉ đồng |

**Slicer:** Từ ngày — Đến ngày (date range picker)

---

> Phân loại: **Phân tích**
> Atomic: xem cột Ghi chú trong bảng KPI dưới đây
> Loại dữ liệu: Dữ liệu động (cả 3 dòng)

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_23 | Dòng tiền vào | — | Phái sinh | TBD — chờ Atomic | **Lý do pending:** Dữ liệu động — nguồn báo cáo định kỳ PLIV-TT51/2021/TT-BTC (Báo cáo hoạt động chu chuyển vốn NĐTNN, Ngân hàng lưu ký gửi, kỳ NỬA THÁNG), cột "GT dòng vốn vào" tại Dòng "Tổng = (1)+(2)". Note BA: "Báo cáo tại ngày (lấy ngày cuối tháng)". **Atomic cần bổ sung:** xác nhận báo cáo PLIV-TT51 thuộc generic store `Member Regulatory Report`/`Member Report Value` (Cụm 7) hay cần entity riêng — cần Report Code/Cell Code. Không dùng lại thiết kế cũ (`Fact Foreign Investor Capital Flow` ← FIMS.RPTVALUES/RPTMEMBER trực tiếp) vì chưa xác nhận đúng mapping. **Mart dự kiến:** `Fact Foreign Investor Capital Flow Report` (tên tạm) — grain 1 kỳ báo cáo (nửa tháng) × 1 chiều dòng vốn | PENDING |
| K_NDTNN_24 | Dòng tiền ra | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn với K_NDTNN_23 — cột "GT ngoại tệ đổi ra VND" | PENDING |
| K_NDTNN_25 | Dòng tiền ròng | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn với K_NDTNN_23 — Dòng tiền vào − Dòng tiền ra | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| Dòng tiền vào / ra / ròng | Báo cáo PLIV-TT51/2021/TT-BTC (Ngân hàng lưu ký, kỳ nửa tháng) | Member Regulatory Report / Member Report Value (Cụm 7 — cần xác nhận Report Code) | TBD |

---

#### Nhóm 4 — Dòng vốn đầu tư gián tiếp nước ngoài (STT=4)

**Mockup** *(theo screenshot — stacked bar theo tháng + 4 bảng Top)*:

| Stacked bar | Trục X | Trục Y | Legend |
|:---|:---|:---|:---|
| Dòng vốn ròng theo loại hình NĐT | Tháng T1→T12 | Tỉ đồng | Cá nhân / Quỹ / Tổ chức khác quỹ |

**Slicer:** Từ ngày — Đến ngày + Loại hình NĐTNN + Quốc gia

---

> Phân loại: **Phân tích**
> Atomic: xem cột Ghi chú trong bảng KPI dưới đây
> Loại dữ liệu: Dữ liệu động (8/10 dòng) / Dữ liệu tĩnh (2 Chiều — Loại hình NĐTNN, Quốc gia — dùng filter/GROUP BY cho measure động, không tự đứng độc lập)

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_160 | Loại hình NĐTNN | — | Chiều | TBD — chờ Atomic | Dùng filter K_NDTNN_27/28/29. Atomic `Foreign Investor Dimension.Investor Object Type Code` đã READY (dùng chung Nhóm 6) nhưng chưa join được vì Fact động (K_26-33) của Nhóm này chưa sẵn sàng | PENDING |
| K_NDTNN_161 | Quốc gia | — | Chiều | TBD — chờ Atomic | Dùng GROUP BY K_NDTNN_30/31. Atomic `Geographic Area Dimension.Geographic Area Name` đã READY (dùng chung Nhóm 6) nhưng chưa join được vì Fact động của Nhóm này chưa sẵn sàng | PENDING |
| K_NDTNN_26 | Dòng vốn ròng | — | Phái sinh | TBD — chờ Atomic | **Lý do pending:** Dữ liệu động — nguồn báo cáo định kỳ PLIV-TT51 (Ngân hàng lưu ký, kỳ nửa tháng) như Nhóm 3, chưa thống nhất quy tắc khai thác generic store TT51. **Atomic cần bổ sung:** xem Nhóm 3 (Member Regulatory Report/Member Report Value — cần Report Code). **Mart dự kiến:** `Fact Foreign Investor Capital Flow Report` (tên tạm, xem Nhóm 3) — grain 1 kỳ báo cáo (nửa tháng) × 1 NĐT × 1 quốc gia. Khi sẵn sàng join `Foreign Investor Dimension`+`Geographic Area Dimension` (đã READY, không cần Dimension mới) | PENDING |
| K_NDTNN_27 | Dòng vốn ròng — Quỹ | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_26 — filter Loại hình = Quỹ (K_NDTNN_160) | PENDING |
| K_NDTNN_28 | Dòng vốn ròng — Cá nhân | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_26 — filter Loại hình = Cá nhân (K_NDTNN_160) | PENDING |
| K_NDTNN_29 | Dòng vốn ròng — Tổ chức khác quỹ | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_26 — filter Loại hình = Tổ chức khác quỹ (K_NDTNN_160) | PENDING |
| K_NDTNN_30 | Top 5 quốc gia vào ròng | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_26 — GROUP BY Quốc gia (K_NDTNN_161), TOP 5 dòng vào ròng DESC | PENDING |
| K_NDTNN_31 | Top 5 quốc gia rút ròng | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_26 — GROUP BY Quốc gia (K_NDTNN_161), TOP 5 dòng rút ròng | PENDING |
| K_NDTNN_32 | Top 5 NĐT vào ròng | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_26 — GROUP BY NĐT, TOP 5 dòng vào ròng DESC | PENDING |
| K_NDTNN_33 | Top 5 NĐT rút ròng | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_26 — GROUP BY NĐT, TOP 5 dòng rút ròng | PENDING |

---

#### Nhóm 5 — Tương quan Net Flow & VN-Index (STT=5)

**Mockup** *(theo screenshot — 3 series line chart dual Y-axis)*:

| Series | Nguồn | Trục Y |
|:---|:---|:---|
| MUA/BÁN RÒNG (đỏ) | Securities Trade (ORDERTRADE) | Trái (Tỉ đồng) |
| DÒNG TIỀN RÒNG (xanh lá) | Báo cáo PLIV-TT51 (Ngân hàng lưu ký) | Trái (Tỉ đồng) |
| VN-INDEX (tím) | MDDS (JAD_MARKETINFOR) | Phải (Điểm) |

> **Ghi chú thiết kế:** 3 series từ 3 fact riêng biệt — presentation layer chịu trách nhiệm query độc lập và align theo trục ngày/tháng.

---

> Phân loại: **Phân tích**
> Atomic (Giá trị mua/bán ròng): `Securities Trade` ← ORDERTRADE.TRADE_BOOK_HOSE/HNX — **READY** (dùng chung Nhóm 1/2)
> Atomic (VN-Index): `Market Index Snapshot` ← MDDS.JAD_MARKETINFOR — **READY (approved)**
> Atomic (Dòng tiền ròng lũy kế): xem cột Ghi chú trong bảng KPI dưới đây
> Loại dữ liệu: Dữ liệu tĩnh (Giá trị mua/bán ròng, VN-Index) / Dữ liệu động (Dòng tiền ròng lũy kế — reuse K_NDTNN_25 Nhóm 3)

**Source:** `Fact Securities Foreign Trading Snapshot` (reuse Nhóm 2) + `Fact Market Index Snapshot` (mới) → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên | Đơn vị | Tính chất | Công thức / Mô tả | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_22 | Giá trị mua/bán ròng | Tỷ đồng | Phái sinh | `SUM(Foreign_Buy_Value) − SUM(Foreign_Sell_Value)` GROUP BY `Trade_Date_Dimension_Id` (SUM xuyên suốt mọi mã CK trong ngày) | Cùng công thức K_NDTNN_8 (Nhóm 2) — BA độ chi tiết Ngày, không phải tháng như thiết kế cũ. Reuse `Fact Securities Foreign Trading Snapshot`, không cần bản pre-aggregate mới | READY |
| K_NDTNN_24b | Điểm đóng cửa chỉ số (VN-Index) | Điểm | Cơ sở | `Market_Index_Value` WHERE `Market_Id = '10'` AND `Market_Code = 'HOSE'`, lấy bản ghi có `Index_Time` lớn nhất (MAX) trong mỗi `Trading_Date` (ROW_NUMBER PARTITION BY Market_Id, Market_Code, Trading_Date ORDER BY Index_Time DESC, lấy rn=1) | Atomic `Market Index Snapshot` grain = 1 lần chụp/chỉ số — ETL lấy giá trị chốt cuối phiên mỗi ngày. Filter đúng theo SQL BA (`Market_Id`+`Market_Code`, KHÔNG dùng `Index_Type_Code` — scheme `MDDS_INDEX_TYPE` chưa profile giá trị, xem Open Issue) | READY |
| K_NDTNN_25b | Dòng tiền ròng lũy kế (tháng) (reuse công thức từ K_NDTNN_25 — Nhóm 3) | — | Phái sinh | TBD — chờ Atomic | **Lý do pending:** Reuse K_NDTNN_25 (Nhóm 3), giờ K_NDTNN_25 PENDING (Dữ liệu động — xem Nhóm 3) nên K_NDTNN_25b PENDING theo. **Atomic cần bổ sung:** xem Nhóm 3. **Mart dự kiến:** `Fact Foreign Investor Capital Flow Report` (tên tạm, xem Nhóm 3) — grain 1 tháng | PENDING |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        int Date_Dimension_Id PK
        date Full_Date
        int Year
        int Month
        int Day_Of_Year
    }
    Fact_Market_Index_Snapshot {
        int Trading_Date_Dimension_Id FK
        varchar Market_Id
        varchar Market_Code
        float Market_Index_Value
    }

    Calendar_Date_Dimension ||--o{ Fact_Market_Index_Snapshot : "Trading Date Dimension Id"
```

> **Ghi chú:** K_NDTNN_22 reuse trực tiếp `Fact Securities Foreign Trading Snapshot` (xem Star Schema Nhóm 2) — không cần erDiagram riêng. K_NDTNN_24b cần Fact mới `Fact Market Index Snapshot` (Fact Snapshot, grain 1 ngày × 1 chỉ số, ETL lấy bản ghi cuối phiên từ `Market Index Snapshot` Atomic).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Fact Securities Foreign Trading Snapshot"]
        G2["Fact Market Index Snapshot"]
        G3["Calendar Date Dimension"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_NDTNN_22,24b: Tab GIAM SAT DONG VON - Nhom 5 - Tuong quan Net Flow VN-Index"]
    end
    G1 --> R1
    G2 --> R1
    G3 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Securities Foreign Trading Snapshot | 1 row = 1 mã CK × 1 ngày giao dịch (reuse từ Nhóm 2) |
| Fact Market Index Snapshot | 1 row = 1 chỉ số (VN-Index/HNX-Index/UPCOM-Index) × 1 ngày (ETL lấy bản ghi cuối phiên từ `Market Index Snapshot`) |
| Calendar Date Dimension | 1 row = 1 ngày |

---

### Tab: DANH MỤC

**Slicer chung:** Kỳ (Tháng + Năm) cho danh mục / Ngày (date picker) cho ROOM

---

#### Nhóm 6 - Thống kê danh mục (STT=6)

> Phân loại: **Phân tích**
> Atomic (Loại hình nhà đầu tư): `Foreign Investor` ← FIMS.INVESTOR/INVESTORTYPE — **READY (draft)**
> Atomic (Tổng GTDM + Top quốc gia/NĐT): xem cột Ghi chú trong bảng KPI dưới đây
> Loại dữ liệu: Dữ liệu tĩnh (Loại hình nhà đầu tư) / Dữ liệu động (6 KPI còn lại)

**Mockup:**

| Tổng GTDM | Danh mục Cá nhân | Danh mục Quỹ | Danh mục Tổ chức khác quỹ |
|:---:|:---:|:---:|:---:|
| **1,315** Tỉ đồng | **284.6** Tỉ đồng | **752.3** Tỉ đồng | **278.1** Tỉ đồng |

**Bảng KPI:**

| KPI ID | Tên | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_162 | Loại hình nhà đầu tư | — | Chiều | `Foreign_Investor.Investor_Type_Code` (từ `FIMS.INVESTOR.InvestorTypeId`) | Dùng filter K_NDTNN_35/36/37. Atomic `Foreign Investor` đã READY (draft), dùng chung Nhóm 2/4/9 | READY |
| K_NDTNN_34 | Tổng giá trị danh mục | — | Phái sinh | TBD — chờ Atomic | **Lý do pending:** Dữ liệu động — nguồn báo cáo định kỳ PLIII-TT51/2021/TT-BTC (Báo cáo thống kê danh mục lưu ký NĐTNN, do CTCK và Ngân hàng lưu ký gửi, kỳ THÁNG), Mục "II. Báo cáo cơ cấu danh mục theo tỷ trọng đầu tư của tổ chức và cá nhân", Dòng "Tổng = (1)+(2)", Cột "Tổng giá trị danh mục". **Atomic cần bổ sung:** xác nhận báo cáo PLIII-TT51 thuộc generic store `Member Regulatory Report`/`Member Report Value` (Cụm 7) hay cần entity riêng — cần Report Code/Cell Code Mục II. Atomic `Foreign Investor Securities Account` (gộp SECURITIESACCOUNT+CATEGORIESSTOCK, table_type Fundamental) KHÔNG dùng được — chỉ có Current Holding Quantity/Ownership Rate current-state, không có Portfolio Market Value theo tháng. **Mart dự kiến:** `Fact Foreign Investor Portfolio Value Report` (tên tạm) — grain 1 kỳ báo cáo (tháng) × 1 NĐT | PENDING |
| K_NDTNN_35 | Danh mục Cá nhân | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_34 — Dòng "Tổng(2)-Cá nhân" | PENDING |
| K_NDTNN_36 | Danh mục Quỹ | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_34 — Subset Tổng(1) lọc Loại hình = Quỹ (K_NDTNN_162) | PENDING |
| K_NDTNN_37 | Danh mục Tổ chức khác quỹ | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_34 — Subset Tổng(1) lọc Loại hình khác Quỹ (K_NDTNN_162) | PENDING |
| K_NDTNN_38 | Top 5 quốc gia theo GTDM | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn với K_NDTNN_34 — GROUP BY Quốc tịch, TOP 5 DESC. **Atomic cần bổ sung thêm:** Chiều Quốc gia chưa có nguồn xác nhận — xem O_NDTNN_21 (Cụm 3c, `Geographic Area` chỉ có nguồn ECAT, không có FIMS) | PENDING |
| K_NDTNN_39 | Top 5 NĐT theo GTDM | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_34 — GROUP BY Tên khách hàng, TOP 5 DESC | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| Tổng giá trị danh mục / Cá nhân / Quỹ / Tổ chức khác quỹ / Top 5 quốc gia / Top 5 NĐT | Báo cáo PLIII-TT51/2021/TT-BTC (CTCK + Ngân hàng lưu ký, kỳ tháng) | Member Regulatory Report / Member Report Value (Cụm 7 — cần xác nhận Report Code Mục II) | TBD |

---

#### Nhóm 7 - Cơ cấu danh mục theo loại hình tài sản (STT=7)

> Phân loại: **Phân tích**
> Atomic: xem cột Ghi chú trong bảng KPI dưới đây
> Loại dữ liệu: Dữ liệu động (toàn bộ 7/7 dòng BA)

**Mockup:**

```mermaid
pie showData
    title Cơ cấu danh mục theo loại hình tài sản (T4/2023)
    "Cổ phiếu, CCQ niêm yết" : 55
    "Trái phiếu" : 19
    "UPCoM" : 10
    "Vốn góp, CP tu & CK khác" : 8
    "Tiền & tương đương tiền" : 8
```

**Bảng KPI:**

| KPI ID | Tên | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_163 | Giá trị tài sản | — | Cơ sở | TBD — chờ Atomic | **Lý do pending:** Dữ liệu động — Bảng nguồn BA ghi `CATEGORIESSTOCK.Quantity` + `SECURITIES.ClosingPrice` (độ chi tiết Tháng), nhưng đối chiếu Atomic thì `CATEGORIESSTOCK` đã gộp vào `Foreign Investor Securities Account` (Fundamental, current-state, không phải Snapshot theo tháng) — không dùng được để tính giá trị tài sản theo tháng. **Atomic cần bổ sung:** xem Nhóm 6 (measure tương tự "Tổng giá trị danh mục", cùng nghi vấn nguồn PLIII-TT51). **Mart dự kiến:** chung Fact với Nhóm 6 (`Fact Foreign Investor Portfolio Value Report`, tên tạm) | PENDING |
| K_NDTNN_164 | Loại tài sản | — | Chiều | TBD — chờ Atomic | Dùng filter K_NDTNN_40-44. Bảng nguồn BA `RELATEDPROPERTIES.Name` (filter `Deleted=0`) — đã tra Atomic: `RELATEDPROPERTIES` chỉ được model hóa cho scheme `FIMS_RELATED_PROPERTY` ("Hình thức liên quan trong ủy quyền CBTT/giao dịch", dùng bởi `Info Disclosure Authorization`/`Trading Authorization`) — KHÔNG liên quan "Loại tài sản danh mục đầu tư". Đây là bảng lookup dùng chung nhiều mục đích trong FIMS, giá trị "Loại tài sản" (Cổ phiếu/Trái phiếu/UPCoM...) chưa được model hóa riêng trong Atomic. **Atomic cần bổ sung:** entity/scheme riêng cho phân loại tài sản danh mục đầu tư NĐTNN | PENDING |
| K_NDTNN_40 | GT tài sản — Cổ phiếu/CCQ niêm yết | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_163 — subset filter Loại tài sản = Cổ phiếu/CCQ niêm yết (K_NDTNN_164), nguồn báo cáo PLIII-TT51 Mục II, Cột "Cổ phiếu/CCQ niêm yết" | PENDING |
| K_NDTNN_41 | GT tài sản — Trái phiếu | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_163 — subset filter Loại tài sản = Trái phiếu, nguồn báo cáo PLIII-TT51 Mục II, Cột "Trái phiếu" (SUM 3 loại trái phiếu theo BA note) | PENDING |
| K_NDTNN_42 | GT tài sản — UPCoM | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_163 — subset filter Loại tài sản = UPCoM, nguồn báo cáo PLIII-TT51 Mục II, Cột "Cổ phiếu công ty đại chúng đăng ký giao dịch (upcom)" | PENDING |
| K_NDTNN_43 | GT tài sản — Vốn góp/CP tư/CK khác | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_163 — subset filter Loại tài sản = Vốn góp/mua CP/quỹ thành viên/CK khác, nguồn báo cáo PLIII-TT51 Mục II | PENDING |
| K_NDTNN_44 | GT tài sản — Tiền và tương đương | — | Phái sinh | TBD — chờ Atomic | Cùng lý do/nguồn/mart dự kiến với K_NDTNN_163 — subset filter Loại tài sản = Tiền và tương đương, nguồn báo cáo PLIII-TT51 Mục II. BA note: "Lấy từ báo cáo NHLK" | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Tên KPI | Bảng nguồn (BA) | Atomic entity dự kiến | Atomic table dự kiến |
|---|---|---|---|
| Giá trị tài sản / GT tài sản theo loại (5 subset) | Báo cáo PLIII-TT51/2021/TT-BTC (CTCK + Ngân hàng lưu ký, kỳ tháng) | Member Regulatory Report / Member Report Value (Cụm 7 — cần xác nhận Report Code Mục II) | TBD |
| Loại tài sản (Chiều) | FIMS.RELATEDPROPERTIES (dùng chung — cần entity/scheme riêng cho ngữ cảnh danh mục đầu tư) | TBD (không dùng scheme `FIMS_RELATED_PROPERTY` hiện có — sai ngữ cảnh) | TBD |

---

#### Nhóm 8 - Phân ngành của NĐTNN (STT=8)

> Phân loại: **Phân tích** (1 dòng Chiều READY) + **Chỉ tiêu phái sinh** (1 dòng PENDING)
> Atomic:
> - `Classification Business Line` (IDS.CATEGORIES, draft) — **READY**. Join chain 2 bước: `Public Company.Business_Line_Level1_Code` → `Classification Business Line.cl_business_line_code` → lấy `Classification Business Line Name`.
> - `Public Company` (IDS.COMPANY_PROFILES, draft) — READY, dùng làm cầu nối (Business Line Level1/2 Id/Code).
> - `Foreign Investor Securities Account` (FIMS.SECURITIESACCOUNT+CATEGORIESSTOCK, draft) — có `Current Holding Quantity`, KHÔNG có giá đóng cửa/market value.

**Ghi chú thiết kế:**
- **Sửa O_NDTNN_12:** `Industry Category Dimension` (tên cũ) KHÔNG ETL-derived trực tiếp từ `Public Company` như thiết kế trước — `Public Company` chỉ có `Business Line Level 1/2 Id/Code` (FK), tên ngành thật nằm ở entity riêng `Classification Business Line` (nguồn `IDS.CATEGORIES`, gộp với `ECAT.BUSINESS_LINE_LEVEL_1/2`).
- **Reuse (Lớp 3/4 — Section 3 Check Reuse):** `Public Company Dimension` đã thiết kế đầy đủ ở Nhóm 2 (Section 2), có sẵn cột `Classification_Business_Line_Name` đệm sẵn qua đúng join chain 2 bước này (xem Nhóm 2, dòng K_NDTNN_9). Nhóm 8 **reuse thẳng** `Public Company Dimension`, KHÔNG tạo Dimension `Industry Category`/`Business Line` mới — tránh trùng lặp 2 Dimension cùng chứa 1 thông tin.
- **Sửa O_NDTNN_21:** Bỏ `Fact Foreign Investor Portfolio Snapshot` (entity ảo, không tồn tại trong manifest) khỏi Source — measure "Giá trị tài sản" (đã khai sinh K_NDTNN_163 ở Nhóm 7, PENDING) chưa có nguồn giá đóng cửa trong FIMS/IDS, nên KPI "Tỷ trọng theo ngành" (cần chia theo giá trị tài sản, không phải theo số lượng cổ phiếu) tiếp tục PENDING — cùng gốc rễ thiếu measure với Nhóm 7.

**Mockup:**

```mermaid
pie showData
    title Tỷ trọng danh mục NĐTNN theo nhóm ngành (T4/2026)
    "Ngân hàng" : 35.4
    "Bất động sản" : 22.1
    "Sản xuất" : 15.2
    "Bán lẻ" : 8.5
    "Công nghệ" : 7.4
    "Dầu khí" : 4.2
    "Khác" : 7.2
```

**Source:** `Public Company Dimension` (reuse từ Nhóm 2)

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_51a | Nhóm ngành | — | Chiều | `Public_Company_Dimension.Classification_Business_Line_Name` | Reuse `Public Company Dimension` từ Nhóm 2 (đã đệm sẵn tên ngành qua join `Business_Line_Level1_Code` → `Classification Business Line.cl_business_line_code`, IDS.CATEGORIES). Sửa O_NDTNN_12 — không tạo Dimension riêng | READY |
| K_NDTNN_51 | Tỷ trọng danh mục theo ngành | % | Derived | TBD — chờ Atomic | Lý do pending: thiếu measure "Giá trị tài sản NĐTNN" (Quantity × giá đóng cửa) — `Foreign Investor Securities Account` chỉ có `Current Holding Quantity`, không có giá đóng cửa trong hệ thống nguồn FIMS/IDS mà BA khai báo (giống O_NDTNN_21 mục Nhóm 7 — K_NDTNN_163 cũng PENDING vì lý do này). Atomic cần bổ sung: field giá đóng cửa chứng khoán trong FIMS/IDS, hoặc xác nhận cross-module join với `Security Trading Snapshot` (MDDS). Mart dự kiến: `Fact Foreign Investor Portfolio Snapshot` (grain 1 NĐT × 1 mã CK × 1 kỳ) | PENDING |

**Star Schema:** Reuse nguyên trạng `Public Company Dimension` — xem erDiagram tại Nhóm 2 (Section 2), không định nghĩa lại.

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Public Company Dimension"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_NDTNN_51a: Tab DANH MUC - Nhom 8 Phan nganh"]
    end
    G1 --> R1
```

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| CATEGORIESSTOCK, SECURITIES | Fact Foreign Investor Portfolio Snapshot (chưa thiết kế) | TBD | Cần measure giá đóng cửa chứng khoán — chưa có nguồn Atomic trong FIMS/IDS (xem O_NDTNN_21) |

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Public Company Dimension | 1 row = 1 mã CK niêm yết (SCD2) — reuse từ Nhóm 2, đã bao gồm Classification Business Line Name đệm sẵn |

---

#### Nhóm 9 - Sở hữu NĐT nước ngoài ROOM (STT=9)

> Phân loại: **Phân tích** (100% PENDING)
> Atomic tham khảo: `Public Company Foreign Ownership Limit` (IDS.FOREIGN_OWNER_LIMIT, draft) — có `Maximum Foreign Ownership Rate Percentage`, khớp khái niệm "Room tối đa" nhưng KHÔNG dùng được vì BA chỉ định nguồn khác (xem Ghi chú thiết kế). `Foreign Investor Securities Account` (FIMS, draft) — có `Current Holding Quantity`, cũng không dùng được vì cùng lý do.

**Ghi chú thiết kế:**
- **Sửa O_NDTNN_21:** Bỏ hẳn `Fact Foreign Ownership Snapshot` với measure `SUM(Ownership Rate)` từ entity ảo `Foreign Investor Stock Portfolio Snapshot` (không tồn tại trong manifest).
- **Rà soát BA xác nhận toàn bộ 6/6 dòng của Nhóm 9 đều PENDING** — không phải do thiếu Atomic, mà do BA chỉ định rõ nguồn là **báo cáo BM67 "Quản lý thông tin nhà đầu tư nước ngoài"** (báo cáo thủ công VSDC, chưa số hoá CSDL) hoặc đánh dấu "Dữ liệu động". Xem O_NDTNN_22 — Atomic đã có sẵn entity số hoá tương đương cho 2/6 khái niệm (Room tối đa, Ownership Rate) nhưng KHÔNG dùng theo đúng gate rule "Loại dữ liệu", vì BA yêu cầu nguồn báo cáo thủ công chứ không phải entity đã số hoá.
- **"Mã CK" (dòng 1):** BA ghi nguồn `FIMS.SECURITIES.SecuritiesTypeId` — không tìm thấy bảng `FIMS.SECURITIES` nào trong manifest (chỉ 6 source table FIMS đã xác nhận từ Nhóm 6/7/8, không có SECURITIES) — cùng gap "không có bảng giá/danh mục chứng khoán trong FIMS" đã ghi nhận ở Nhóm 8. Giữ nguyên PENDING theo đúng gate rule (Loại dữ liệu = Dữ liệu động), không suy diễn thêm.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_45 | Mã CK | — | Chiều | TBD — chờ Atomic | Lý do pending: nguồn `FIMS.SECURITIES.SecuritiesTypeId` — không có bảng `FIMS.SECURITIES` trong manifest (cùng gap Nhóm 8). Dữ liệu động — chưa thống nhất quy tắc khai thác. Mart dự kiến: `Fact Public Company Foreign Ownership Snapshot` (grain 1 mã CK × 1 ngày) | PENDING |
| K_NDTNN_46 | Tỷ lệ sở hữu (theo mã CK) | % | Cơ sở | TBD — chờ Atomic | Lý do pending: BA chỉ định nguồn báo cáo BM67 VSDC (Dữ liệu động), công thức "Số lượng CP NĐTNN nắm giữ × 100 / Tổng số CP phát hành". Atomic cần bổ sung: xác nhận generic store TT51/BM67 tương ứng. Tham khảo — entity `Foreign Investor Securities Account` (FIMS) có `Current Holding Quantity` nhưng không dùng vì BA yêu cầu nguồn BM67 khác (xem O_NDTNN_22). Mart dự kiến: `Fact Public Company Foreign Ownership Snapshot` | PENDING |
| K_NDTNN_47 | Room còn lại (theo mã CK) | % | Derived | TBD — chờ Atomic | Lý do pending: nguồn BM67 VSDC, "Chưa có CSDL - Map biểu mẫu", công thức "Số lượng CP còn được phép nắm giữ × 100 / Tổng số CP phát hành". Atomic cần bổ sung: số hoá biểu mẫu BM67. Mart dự kiến: `Fact Public Company Foreign Ownership Snapshot` | PENDING |
| K_NDTNN_48 | Room tối đa | % | Cơ sở | TBD — chờ Atomic | Lý do pending: nguồn BM67 VSDC, "Chưa có CSDL - Map biểu mẫu", trường "Tỷ lệ sở hữu nước ngoài tối đa (%)". Tham khảo — entity `Public Company Foreign Ownership Limit` (IDS.FOREIGN_OWNER_LIMIT) có `Maximum Foreign Ownership Rate Percentage` khớp khái niệm nhưng không dùng vì BA yêu cầu nguồn BM67 khác (xem O_NDTNN_22). Mart dự kiến: `Fact Public Company Foreign Ownership Snapshot` | PENDING |
| K_NDTNN_49 | Top 5 mã có room còn lại thấp nhất | — | Derived | TBD — chờ Atomic | Lý do pending: cùng nguồn/công thức K_NDTNN_47 (BM67 VSDC), Dữ liệu động, ORDER BY Room còn lại ASC FETCH FIRST 5 ROWS. Atomic cần bổ sung: xem K_NDTNN_47. Mart dự kiến: `Fact Public Company Foreign Ownership Snapshot` | PENDING |
| K_NDTNN_50 | Room theo ngành (%) | % | Derived | TBD — chờ Atomic | Lý do pending: `SUM(Quantity NĐT)/SUM(Tổng CP tối đa NĐT có thể sở hữu) × 100%` GROUP BY `Classification Business Line` (IDS.CATEGORIES.INDUSTRY_NAME) — Dữ liệu động, nguồn tổng CP tối đa vẫn là BM67. Atomic cần bổ sung: xem K_NDTNN_46/48. Chiều Ngành có thể reuse `Public Company Dimension` (xem Nhóm 8) khi Fact sẵn sàng. Mart dự kiến: `Fact Public Company Foreign Ownership Snapshot` | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| FIMS.SECURITIES | Fact Public Company Foreign Ownership Snapshot (chưa thiết kế) | TBD | Không tìm thấy bảng `FIMS.SECURITIES` trong manifest — cùng gap Nhóm 8 |
| BM 67_Quản lý thông tin nhà đầu tư nước ngoài | Fact Public Company Foreign Ownership Snapshot (chưa thiết kế) | TBD | Báo cáo thủ công VSDC, chưa số hoá CSDL — xem O_NDTNN_22 (2 nguồn khác nhau cùng khái niệm Room) |
| IDS.CATEGORIES | — (reuse Public Company Dimension khi Fact sẵn sàng) | cl_business_line | Đã READY (Classification Business Line), chỉ chờ Fact chính |

---

#### Nhóm 10 - Cảnh báo ngưỡng Room còn lại của NĐTNN (STT=10)

> Phân loại: **Phân tích** (100% PENDING)
> Atomic: đồng bộ với Nhóm 9 — xem O_NDTNN_22.

**Ghi chú thiết kế:** BA đánh giá "Trùng" — reuse trực tiếp K_NDTNN_48 (Nhóm 9, "Room tối đa"... thực chất công thức trùng K_NDTNN_47 "Room còn lại (theo mã CK)"), filter thêm điều kiện `Room còn lại = 0`. Trạng thái đồng bộ theo KPI gốc: K_NDTNN_47 đang PENDING (Nhóm 9, 100% PENDING) → Nhóm 10 cũng PENDING.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_47 (reuse) | Room còn lại (cổ phiếu) | — | Derived | TBD — chờ Atomic | Reuse từ Nhóm 9 (K_NDTNN_47 "Room còn lại (theo mã CK)"), filter `WHERE Room còn lại = 0` — danh sách mã CK "kín room". Trạng thái đồng bộ với gốc — xem O_NDTNN_22 | PENDING |

---

### Tab: NĐTNN 360

**Mô tả chung:** Tra cứu hồ sơ 360° của từng NĐT nước ngoài. Chọn NĐT qua thanh tìm kiếm (Mã FII hoặc Tên NĐT) → hiển thị 3 sub-tab: Hồ sơ định danh / Biến động tài sản / Lịch sử tuân thủ.

**Slicer chung:** Mã FII hoặc Tên NĐT (search box) + Date picker.

---

#### Danh sách tìm kiếm NĐT

**Mockup:**

| # | Tên NĐT | Mã MSGD | Quốc gia | Loại hình | |
|---|---|---|---|---|---|
| 01 | Công ty A | FII001 | UK/VN | INSTITUTIONAL | 360° → |
| 02 | Quỹ tín dụng B | FII002 | Taiwan | INSTITUTIONAL | 360° → |

**Source:** `Foreign Investor 360 Profile`

**Bảng KPI:**

| KPI ID | Tên | Tính chất | Mô tả |
|---|---|---|---|
| K_NDTNN_L1 | Tên NĐT | Attribute | `Foreign Investor 360 Profile.Investor Name` |
| K_NDTNN_L2 | Mã MSGD | Attribute | `Foreign Investor 360 Profile.Investor Code` (= Transaction Code) |
| K_NDTNN_L3 | Quốc gia | Attribute | `Foreign Investor 360 Profile.Nationality Code` |
| K_NDTNN_L4 | Loại hình | Attribute | `Foreign Investor 360 Profile.Investor Type Code` |

---

#### Sub-tab A: Hồ sơ định danh — READY

> Phân loại: **Tác nghiệp**
> Atomic: `Foreign Investor` (FIMS.INVESTOR) + `Custodian Bank` (FIMS.BANKMONI) — **READY**

**Mockup:**

| THÔNG TIN CƠ BẢN | | ĐẠI DIỆN GIAO DỊCH |
|---|---|---|
| QUỐC TỊCH | UK/VN | NGUYỄN VĂN A |
| MÃ SỐ GIAO DỊCH (MSGD) | FII001 | CCCD: 0123xxxx5678 |
| NGÂN HÀNG LƯU KÝ | Ngân hàng A | Status: Verified |
| LOẠI HÌNH NĐT | Institutional | |

**Source:** `Foreign Investor 360 Profile` — lookup 1 NĐT theo Mã FII.

**Bảng KPI:**

| KPI ID | Tên | Tính chất | Mô tả — column trong bảng tác nghiệp |
|---|---|---|---|
| K_NDTNN_P1 | Quốc tịch | Attribute | `Nationality Code` — từ FIMS.INVESTOR.NaId lookup |
| K_NDTNN_P2 | Mã số giao dịch (MSGD) | Attribute | `Investor Code` = Transaction Code — FIMS.INVESTOR.TransactionCode |
| K_NDTNN_P3 | Ngân hàng lưu ký | Attribute | `Custodian Bank Name` — denorm từ FIMS.BANKMONI.Name qua INVESTOR.BankAddId |
| K_NDTNN_P4 | Loại hình NĐT | Attribute | `Investor Type Code` — FIMS.INVESTOR.InvestorTypeId |
| K_NDTNN_P5 | Đại diện giao dịch | Attribute | `Director Name` — FIMS.INVESTOR.Director |

**Schema bảng tác nghiệp:**

> `Investor_Id` — PK surrogate (ETL generated). `Investor_Code` — BK (FIMS.INVESTOR.TransactionCode), join anchor ETL debug.

```mermaid
erDiagram
    Foreign_Investor_360_Profile {
        string Investor_Id PK
        varchar Investor_Code
        string Investor_Name
        string English_Name
        varchar Investor_Object_Type_Code
        varchar Investor_Type_Code
        varchar Nationality_Code
        string Custodian_Bank_Name
        string Director_Name
        varchar Life_Cycle_Status_Code
        date Created_Date
    }

```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Foreign Investor 360 Profile"]
    end
    subgraph RPT["Báo cáo"]
        R1["NDTNN 360 - Danh sach tim kiem - K_NDTNN_L1 L2 L3 L4"]
        R2["NDTNN 360 - Sub-tab A Ho so dinh danh - K_NDTNN_P1 P2 P3 P4 P5"]
    end
    G1 --> R1
    G1 --> R2
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Foreign Investor 360 Profile | 1 row = 1 NĐT NN (trạng thái mới nhất) |

---

#### Sub-tab B: Biến động tài sản — READY

> Phân loại: **Phân tích**
> Atomic: `Foreign Investor Stock Portfolio Snapshot` (FIMS.CATEGORIESSTOCK) — **READY**

**Mockup:**

```
GIÁ TRỊ DANH MỤC HIỆN TẠI
125,000 B

LỊCH SỬ BIẾN ĐỘNG TÀI SẢN (12 THÁNG)
Line chart — Trục X: T1 đến T12 / Trục Y: Giá trị (tỉ đồng)
```

**Source:** `Fact Foreign Investor Portfolio Snapshot` → `Foreign Investor Dimension`, `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên | Đơn vị | Tính chất | Công thức / Mô tả |
|---|---|---|---|---|
| K_NDTNN_A1 | Giá trị danh mục hiện tại | Tỉ đồng | Stock (Base) | `SUM(Portfolio Market Value)` WHERE `Investor Dimension Id = selected` AND `Snapshot Date = MAX(Snapshot Date)` |
| K_NDTNN_A2 | Lịch sử giá trị danh mục 12 tháng | Tỉ đồng | Stock (Base) | `SUM(Portfolio Market Value)` WHERE `Investor Dimension Id = selected` GROUP BY Snapshot Date, lấy 12 tháng gần nhất |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        int Date_Dimension_Id PK
        date Full_Date
        int Year
        int Month
    }
    Foreign_Investor_Dimension {
        int Investor_Dimension_Id PK
        int Investor_Id
        string Investor_Name
        varchar Investor_Object_Type_Code
    }
    Fact_Foreign_Investor_Portfolio_Snapshot {
        int Snapshot_Date_Dimension_Id FK
        int Investor_Dimension_Id FK
        int Country_Dimension_Id FK
        int Asset_Category_Dimension_Id FK
        int Industry_Category_Dimension_Id FK
        varchar Stock_Code
        float Quantity
        float Ownership_Rate
        float Portfolio_Market_Value
    }

    Calendar_Date_Dimension ||--o{ Fact_Foreign_Investor_Portfolio_Snapshot : "Snapshot Date Dimension Id"
    Foreign_Investor_Dimension ||--o{ Fact_Foreign_Investor_Portfolio_Snapshot : "Investor Dimension Id"
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Fact Foreign Investor Portfolio Snapshot"]
        G2["Foreign Investor Dimension"]
        G3["Calendar Date Dimension"]
    end
    subgraph RPT["Báo cáo"]
        R1["NDTNN 360 - Sub-tab B Bien dong tai san - K_NDTNN_A1 A2"]
    end
    G1 --> R1
    G2 --> R1
    G3 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Foreign Investor Portfolio Snapshot | 1 row = 1 NĐT NN × 1 mã tài sản × 1 tháng snapshot |
| Foreign Investor Dimension | 1 row = 1 NĐT NN (SCD2) |
| Calendar Date Dimension | 1 row = 1 ngày (ngày cuối tháng = Snapshot Date) |

---

#### Sub-tab C: Lịch sử tuân thủ (STT=13)

> Phân loại: **Tác nghiệp** (5/6 KPI READY, 1 Out-of-scope)
> Atomic: `Penalty Decision` (THANHTRA.PENALTY_DECISION, approved) + `Penalty Decision Subject` (approved) + `Penalty Decision Subject Behavior` (approved) + `Penalty Type` (approved) — **READY**
> **Sửa Kịch bản D:** Header cũ dùng entity `Surveillance Enforcement Case`/`Surveillance Enforcement Decision` (TT.GS_HO_SO/GS_VAN_BAN_XU_LY) — BA STT=13 thực tế xác nhận nguồn hoàn toàn khác: `PENALTY_DECISION*`/`PENALTY_TYPE` (THANHTRA). Đã tra lại đúng entity approved — xem O_NDTNN_26.

**Mockup:**

| NGÀY QUYẾT ĐỊNH | PHÂN LOẠI | NỘI DUNG / TRÍCH YẾU | MỨC ĐỘ | TRẠNG THÁI |
|:---|:---|:---|:---|:---|
| 15/10/2023 | REMINDER | Chậm báo cáo tỷ trọng sở hữu | LOW | Resolved |
| 12/05/2023 | ADMINISTRATIVE SANCTION | Giao dịch không công bố đúng thời hạn | MEDIUM | Penalty Paid |

**Source:** `Investor Compliance History` — denormalize từ `Penalty Decision` + `Penalty Decision Subject` + `Penalty Decision Subject Behavior` + `Penalty Type`, filter theo Subject = NĐT đang chọn.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_192 | Thông tin nhà đầu tư | — | Cơ sở | `Penalty_Decision_Subject.Subject_Name` | Đánh giá BA "Trùng" — tên/MSGD NĐTNN, dùng chung hồ sơ 360 | READY |
| K_NDTNN_193 | Ngày quyết định | — | Cơ sở | `Penalty_Decision.Issued_Date` | — | READY |
| K_NDTNN_194 | Phân loại | — | Cơ sở | `Penalty_Type.Penalty_Type_Name` — join qua `Penalty_Decision_Subject_Behavior.Penalty_Type_Id` | Phân loại hình thức xử lý (nhắc nhở/xử phạt hành chính...) | READY |
| K_NDTNN_195 | Nội dung/Trích yếu | — | Cơ sở | `Penalty_Decision_Subject_Behavior.Description` | — | READY |
| K_NDTNN_196 | Mức độ | — | Cơ sở | — | **Out-of-scope** — BA tự ghi chú "không có trường thông tin xác định mức độ vi phạm" (giá trị NULL), đề xuất trao đổi với BA để loại bỏ trường này khỏi màn hình | Out-of-scope |
| K_NDTNN_197 | Trạng thái | — | Cơ sở | `Penalty_Decision.Life_Cycle_Status_Code` | Trạng thái xử lý (đã khắc phục/đã nộp phạt...) | READY |

**Star Schema:**

```mermaid
erDiagram
    Investor_Compliance_History {
        string Investor_Compliance_History_Id PK
        varchar Subject_Name
        date Issued_Date
        varchar Penalty_Type_Name
        string Description
        varchar Life_Cycle_Status_Code
        string Source_System_Code
    }
```

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Investor Compliance History"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_NDTNN_192-195,197: NDTNN 360 - Sub-tab C Lich su tuan thu"]
    end
    G1 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Investor Compliance History | 1 row = 1 hành vi vi phạm × 1 đối tượng bị xử phạt (denormalize Penalty Decision + Subject + Subject Behavior + Penalty Type) |

---

### Tab: BÁO CÁO

**Slicer chung:** Kỳ báo cáo (Năm / Quý / Tháng), Loại báo cáo

#### Nhóm 14 - Báo cáo thống kê tình hình giao dịch của NĐTNN trên thị trường chứng khoán (STT=14)

> Phân loại: **Phân tích** (9/12 KPI READY)
> Atomic: `Securities Trade` (ORDERTRADE.TRADE_BOOK_HOSE/HNX) — **READY**, cùng entity đã dùng Nhóm 1/2. Field xác nhận: `Market Id Code` (scheme `ORDERTRADE_MARKET_ID`: STO=HoSE Stock, BDO=HoSE Bond, STX=HNX Stock, BDX/HCX=HNX Bond), `Buy/Sell Foreign Investor Type Code`, `Execution Value`.
> **Sửa lỗi lệch STT (cùng gốc O_NDTNN_17/18):** Nội dung "Nhóm 10" trước đây (header "Báo cáo thống kê tình hình giao dịch NĐTNN") thực chất là BA STT=14, bị đặt sai số — xem O_NDTNN_23.

**Ghi chú thiết kế:** 12 dòng BA chia 4 nhóm loại CK (Cổ phiếu/Trái phiếu/CCQ/Tổng) × 3 chỉ tiêu (Mua/Bán/Ròng). Cổ phiếu = `Market_Id_Code IN ('STO','STX','UPX')`; Trái phiếu = `Market_Id_Code IN ('BDO','BDX','HCX')`; Tổng = không filter Market_Id_Code — cả 9 dòng này dùng field có sẵn trên `Securities Trade` → READY. CCQ cần join thêm `MDDS.JAD_STOCKINFOR.Stock_Type_Code='3'` (cross-module, BA tự ghi chú "[M-01] Cần bổ sung bảng danh mục loại CK để filter CCQ") → PENDING, xem O_NDTNN_24.

**Reuse (BƯỚC 3 — Lớp 3/4):** `Fact Securities Foreign Trading Snapshot` (Nhóm 1/2, grain 1 mã CK × 1 ngày) đã có `Foreign_Buy_Value`/`Foreign_Sell_Value` nhưng chưa breakdown theo loại CK — **partial**: bổ sung cột `Security_Type_Code` (ETL-derived từ `Market_Id_Code`, scheme mới `NDTNN_SECURITY_TYPE`: STOCK/BOND/FUND) vào Fact hiện có, không tạo Fact mới.

**Source:** `Fact Securities Foreign Trading Snapshot` (bổ sung `Security_Type_Code`) → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_165 | Cổ phiếu - GT NĐTNN mua chứng khoán | Triệu VNĐ | Cơ sở | `SUM(Foreign_Buy_Value)` WHERE `Security_Type_Code='STOCK'` GROUP BY kỳ | Filter Market_Id_Code IN (STO,STX,UPX) | READY |
| K_NDTNN_166 | Cổ phiếu - GT NĐTNN bán chứng khoán | Triệu VNĐ | Cơ sở | `SUM(Foreign_Sell_Value)` WHERE `Security_Type_Code='STOCK'` GROUP BY kỳ | Filter Market_Id_Code IN (STO,STX,UPX) | READY |
| K_NDTNN_167 | Cổ phiếu - GT NĐTNN mua/bán ròng chứng khoán | Triệu VNĐ | Derived | `K_NDTNN_165 - K_NDTNN_166` | — | READY |
| K_NDTNN_168 | Trái phiếu - GT NĐTNN mua chứng khoán | Triệu VNĐ | Cơ sở | `SUM(Foreign_Buy_Value)` WHERE `Security_Type_Code='BOND'` GROUP BY kỳ | Filter Market_Id_Code IN (BDO,BDX,HCX) | READY |
| K_NDTNN_169 | Trái phiếu - GT NĐTNN bán chứng khoán | Triệu VNĐ | Cơ sở | `SUM(Foreign_Sell_Value)` WHERE `Security_Type_Code='BOND'` GROUP BY kỳ | Filter Market_Id_Code IN (BDO,BDX,HCX) | READY |
| K_NDTNN_170 | Trái phiếu - GT NĐTNN mua/bán ròng chứng khoán | Triệu VNĐ | Derived | `K_NDTNN_168 - K_NDTNN_169` | — | READY |
| K_NDTNN_171 | CCQ - GT NĐTNN mua chứng khoán | Triệu VNĐ | Cơ sở | TBD — chờ Atomic | Lý do pending: cần join `MDDS.JAD_STOCKINFOR.Stock_Type_Code='3'` (cross-module, chưa xác nhận thiết kế) — xem O_NDTNN_24. Mart dự kiến: bổ sung FK Security Trading Snapshot vào Fact | PENDING |
| K_NDTNN_172 | CCQ - GT NĐTNN bán chứng khoán | Triệu VNĐ | Cơ sở | TBD — chờ Atomic | Cùng lý do K_NDTNN_171 | PENDING |
| K_NDTNN_173 | CCQ - GT NĐTNN mua/bán ròng chứng khoán | Triệu VNĐ | Derived | TBD — chờ Atomic | Cùng lý do K_NDTNN_171 | PENDING |
| K_NDTNN_174 | Tổng - GT NĐTNN mua chứng khoán | Triệu VNĐ | Cơ sở | `SUM(Foreign_Buy_Value)` GROUP BY kỳ (mọi Market_Id_Code) | — | READY |
| K_NDTNN_175 | Tổng - GT NĐTNN bán chứng khoán | Triệu VNĐ | Cơ sở | `SUM(Foreign_Sell_Value)` GROUP BY kỳ (mọi Market_Id_Code) | — | READY |
| K_NDTNN_176 | Tổng - GT NĐTNN mua/bán ròng chứng khoán | Triệu VNĐ | Derived | `K_NDTNN_174 - K_NDTNN_175` | — | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        int Date_Dimension_Id PK
        date Full_Date
        int Year
        int Month
    }
    Fact_Securities_Foreign_Trading_Snapshot {
        int Trade_Date_Dimension_Id FK
        varchar Security_Symbol_Code
        varchar Security_Type_Code
        float Foreign_Buy_Value
        float Foreign_Sell_Value
        float Total_Market_Value
    }

    Calendar_Date_Dimension ||--o{ Fact_Securities_Foreign_Trading_Snapshot : "Trade Date Dimension Id"
```

> **Ghi chú thiết kế:** `Security_Type_Code` là cột bổ sung (partial) vào `Fact Securities Foreign Trading Snapshot` đã có — ETL-derived từ `Market_Id_Code` lúc populate Fact, scheme `NDTNN_SECURITY_TYPE` (STOCK/BOND/FUND). Không ảnh hưởng công thức KPI đã READY ở Nhóm 1/2 (các KPI đó không filter theo cột này).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Fact Securities Foreign Trading Snapshot"]
        G2["Calendar Date Dimension"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_NDTNN_165-170,174-176: Tab BAO CAO - Nhom 14 - Bao cao thong ke tong hop"]
    end
    G1 --> R1
    G2 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Securities Foreign Trading Snapshot | 1 row = 1 mã CK × 1 ngày giao dịch (bổ sung Security_Type_Code cho Nhóm 14, không đổi grain gốc) |
| Calendar Date Dimension | 1 row = 1 ngày giao dịch |

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| MDDS.JAD_STOCKINFOR | Security Trading Snapshot (đã READY, khác module) | security_trading_snapshot | Cross-module join chưa xác nhận thiết kế cho lọc CCQ — xem O_NDTNN_24 |

---

#### Nhóm 15 - Báo cáo thống kê tình hình giao dịch của NĐTNN trên thị trường chứng khoán – biểu chi tiết (STT=15)

> Phân loại: **Phân tích** (100% READY)
> Atomic: `Securities Trade` (ORDERTRADE.TRADE_BOOK_HOSE/HNX) — **READY**, field `Buy/Sell Account Number`, `Security Symbol Code`, `Execution Volume`, `Execution Value`, `Buy/Sell Foreign Investor Type Code`.
> **Sửa lỗi lệch STT (cùng gốc O_NDTNN_17/18):** Nội dung "Nhóm 10b" trước đây thực chất là BA STT=15, bị đặt sai số — xem O_NDTNN_23.

**Reuse (BƯỚC 3 — Lớp 3/4):** Grain BA yêu cầu là 1 giao dịch/lệnh khớp × 1 tài khoản NĐT (KHÔNG pre-aggregate) — khác hẳn grain `Fact Securities Foreign Trading Snapshot` (1 mã CK × 1 ngày, đã pre-aggregate). Không thể partial — **new**: `Fact Securities Foreign Investor Trade Detail`.

**Source:** `Fact Securities Foreign Investor Trade Detail` → `Calendar Date Dimension`

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_177 | Tài khoản giao dịch NĐTNN | — | Chiều | `Fact_Securities_Foreign_Investor_Trade_Detail.Account_Number` | Từ Buy/Sell Account Number (HNX) hoặc Buy/Sell Acct No (HOSE), filter theo Buy/Sell Foreign Investor Type Code | READY |
| K_NDTNN_178 | Mã CK | — | Chiều | `Fact_Securities_Foreign_Investor_Trade_Detail.Security_Symbol_Code` | Từ Issue Code (HNX) hoặc Symbol (HOSE) | READY |
| K_NDTNN_179 | KL mua chứng khoán | CP | Cơ sở | `Execution_Volume` WHERE Buy Foreign Investor Type Code IN ('10','20') hoặc Buy Invest Type='7000' | — | READY |
| K_NDTNN_180 | KL bán CK | CP | Cơ sở | `Execution_Volume` WHERE Sell Foreign Investor Type Code IN ('10','20') hoặc Sell Invest Type='7000' | — | READY |
| K_NDTNN_181 | GT mua chứng khoán | Triệu VNĐ | Cơ sở | `Execution_Value` (HNX: Trade_price×Trade_quantity) WHERE điều kiện MUA | — | READY |
| K_NDTNN_182 | GT bán chứng khoán | Triệu VNĐ | Cơ sở | `Execution_Value` (HNX: Trade_price×Trade_quantity) WHERE điều kiện BÁN | — | READY |

**Star Schema:**

```mermaid
erDiagram
    Calendar_Date_Dimension {
        int Date_Dimension_Id PK
        date Full_Date
        int Year
        int Month
    }
    Fact_Securities_Foreign_Investor_Trade_Detail {
        int Trade_Date_Dimension_Id FK
        varchar Account_Number
        varchar Security_Symbol_Code
        float Execution_Volume
        float Execution_Value
        string Trade_Direction_Code
    }

    Calendar_Date_Dimension ||--o{ Fact_Securities_Foreign_Investor_Trade_Detail : "Trade Date Dimension Id"
```

> **Ghi chú thiết kế:** `Trade_Direction_Code` (Buy/Sell) ETL-derived — 1 row per giao dịch × 1 bên (Buy hoặc Sell), tách từ `Securities Trade` (1 row per lệnh khớp có cả Buy và Sell). `Account_Number` lấy theo bên tương ứng (Buy_Account_Number nếu Trade_Direction=Buy, Sell_Account_Number nếu Trade_Direction=Sell).

**Lineage Mart → Báo cáo:**

```mermaid
flowchart LR
    subgraph Datamart["Datamart"]
        G1["Fact Securities Foreign Investor Trade Detail"]
        G2["Calendar Date Dimension"]
    end
    subgraph RPT["Báo cáo"]
        R1["K_NDTNN_177-182: Tab BAO CAO - Nhom 15 - Bao cao thong ke chi tiet"]
    end
    G1 --> R1
    G2 --> R1
```

**Bảng grain:**

| Tên bảng | Grain |
|---|---|
| Fact Securities Foreign Investor Trade Detail | 1 row = 1 giao dịch/lệnh khớp × 1 tài khoản NĐT × 1 bên (Buy/Sell) |
| Calendar Date Dimension | 1 row = 1 ngày giao dịch |

---

### Tab: DATA EXPLORER

**Mô tả tổng thể:** Data Explorer là tab tra cứu và xuất dữ liệu báo cáo nộp vào FIMS theo các biểu mẫu TT51/2021/TT-BTC.

---

#### Nhóm 11a - Data Explorer Dòng vốn ròng của NĐTNN (STT=16)

> Phân loại: **Phân tích** (100% PENDING)
> Atomic: cùng gốc Nhóm 3/5 — `Member Regulatory Report`/`Member Report Value` (Cụm 7), chưa xác nhận Report Code cho báo cáo PLIV-TT51.
> **Đổi format KPI ID:** `K_NDTNN_DE1a-e` (format cũ, không đúng naming convention `K_{MODULE}_{N}`) → đổi thành `K_NDTNN_183-187` (số liên tục theo max hiện có). Module chưa có Attributes/Detail Mapping LLD nên đổi ID an toàn, không ảnh hưởng file khác.

**Mockup:**

| Tháng | Quốc gia | Nhà đầu tư | Vốn vào ròng (Tỉ đồng) | Vốn rút ròng (Tỉ đồng) |
|---|---|---|---|---|
| T1/2024 | Hàn Quốc | GD437560 | +3.300 | 0 |
| T1/2024 | Nhật Bản | GD426069 | 0 | -700 |

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_183 | Tháng | — | Chiều | TBD — chờ Atomic | Đánh giá BA "Trùng" — cùng khái niệm Chiều thời gian đã dùng Nhóm 3/4/5. Dữ liệu động — nguồn `RPTMEMBER.PeriodValue`. Mart dự kiến: `Fact Foreign Investor Capital Flow Report` (tên tạm, xem Nhóm 3) | PENDING |
| K_NDTNN_184 | Quốc gia | — | Chiều | TBD — chờ Atomic | Đánh giá BA "Trùng" — GROUP BY Quốc tịch. Dữ liệu động — nguồn báo cáo PLIV-TT51 (Ngân hàng lưu ký, kỳ nửa tháng). Chiều Quốc gia chưa có Atomic nguồn xác nhận (xem O_NDTNN_21, Geographic Area chỉ có nguồn ECAT). Mart dự kiến: `Fact Foreign Investor Capital Flow Report` | PENDING |
| K_NDTNN_185 | Nhà đầu tư | — | Chiều | TBD — chờ Atomic | Đánh giá BA "Trùng" — GROUP BY Tên nhà đầu tư. Dữ liệu động, cùng nguồn PLIV-TT51. Mart dự kiến: `Fact Foreign Investor Capital Flow Report` | PENDING |
| K_NDTNN_186 | Vốn đầu tư vào ròng | Tỷ đồng | Derived | TBD — chờ Atomic | Đánh giá BA "Trùng" — filter theo `RPTVALUES.Code`, cột "GT dòng vốn vào (3)". Dữ liệu động — cùng nguồn/lý do pending K_NDTNN_23 (Nhóm 3). Mart dự kiến: `Fact Foreign Investor Capital Flow Report` | PENDING |
| K_NDTNN_187 | Vốn đầu tư rút ròng | Tỷ đồng | Derived | TBD — chờ Atomic | Đánh giá BA "Trùng" — filter theo `RPTVALUES.Code`, cột "GT dòng vốn vào (3)" (BA note dùng chung cột, khác điều kiện lọc Code). Dữ liệu động. Mart dự kiến: `Fact Foreign Investor Capital Flow Report` | PENDING |

**Atomic cần bổ sung:** Xem Nhóm 3 (Member Regulatory Report/Member Report Value — cần xác nhận Report Code báo cáo PLIV-TT51).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| RPTMEMBER, Báo cáo PLIV-TT51/2021/TT-BTC | Member Regulatory Report / Member Report Value (Cụm 7) | TBD | Cần xác nhận Report Code — xem Nhóm 3/5, O_NDTNN_16 |

---

#### Nhóm 11b - Data Explorer Tổng giá trị danh mục của NĐTNN (STT=17)

> Phân loại: **Phân tích** (100% PENDING)
> Atomic tham khảo: `Foreign Investor Securities Account` (FIMS, draft) — có `Current Holding Quantity`, KHÔNG có `Portfolio Market Value` (giống gốc rễ Nhóm 6/7 — xem O_NDTNN_21).
> **Sửa O_NDTNN_21 + lỗi lệch STT:** Header cũ ghi sai STT ("không STT") và dùng entity ảo `Foreign Investor Stock Portfolio Snapshot` (không tồn tại) đánh READY — BA thực tế xác nhận STT=17, toàn bộ 4/4 dòng Dữ liệu động (nguồn báo cáo PLIII-TT51, cùng gốc rễ Nhóm 6) → PENDING.

**Mockup:**

| Tháng | Quốc gia | Tên NĐT | Tổng GTDM (Tỉ đồng) |
|---|---|---|---|
| T1/2024 | Hàn Quốc | GD437560 | 4.500 |
| T1/2024 | Nhật Bản | GD426069 | 2.800 |

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_188 | Tháng | — | Chiều | TBD — chờ Atomic | Đánh giá BA "Trùng" — nguồn `RPTMEMBER.PeriodValue`, filter `WHERE tên báo cáo = ""`. Dữ liệu động. Mart dự kiến: `Fact Public Company Financial Report Value`/generic store TT51 (xem Nhóm 6) | PENDING |
| K_NDTNN_189 | Quốc gia | — | Chiều | TBD — chờ Atomic | Đánh giá BA "Trùng" — GROUP BY Quốc tịch, nguồn báo cáo PLIII-TT51 Mục II. Dữ liệu động. Chiều Quốc gia cũng chưa có Atomic nguồn xác nhận (xem O_NDTNN_21, Geographic Area chỉ có nguồn ECAT) | PENDING |
| K_NDTNN_190 | Tên NĐT | — | Chiều | TBD — chờ Atomic | Đánh giá BA "Trùng" — GROUP BY Tên khách hàng, cùng nguồn PLIII-TT51 Mục II | PENDING |
| K_NDTNN_191 | Tổng giá trị danh mục | Tỷ đồng | Cơ sở | TBD — chờ Atomic | Đánh giá BA "Trùng" — cột "Tổng giá trị danh mục", hàng "Tổng=(1)+(2)". Cùng lý do/nguồn K_NDTNN_34 (Nhóm 6) — Atomic `Foreign Investor Securities Account` KHÔNG có Portfolio Market Value | PENDING |

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| Báo cáo PLIII-TT51/2021/TT-BTC (Mục II) | Member Regulatory Report / Member Report Value (Cụm 7) | TBD | Cần xác nhận Report Code Mục II — cùng gốc Nhóm 6 (K_NDTNN_34) |

---

#### Nhóm 12 - Data Explorer Pass-through PLV-TT51 (STT=18)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS) — draft.
> **Sửa gating "Loại dữ liệu" + KPI thừa không có dòng BA:** HLD cũ đánh READY toàn bộ (đúng gốc rễ đã sửa ở Nhóm 6/7/9/11b) — BA STT=18 xác nhận **toàn bộ 6/6 dòng đều Dữ liệu động** → PENDING theo gate rule. Đồng thời "Giá trị" (K_NDTNN_DE8/K_NDTNN_58 cũ) **không có dòng BA tương ứng** — BA chỉ có 6 dòng (Loại/Kỳ/Mã/Tên báo cáo + Mã/Tên chỉ tiêu), không có dòng "Giá trị" độc lập nào — đã loại khỏi bảng KPI theo xác nhận Data Modeler (2026-07-23). Xem O_NDTNN_25.
> **Đổi format KPI ID:** `K_NDTNN_DE3-DE7b` (Nhóm 12 cũ) và `K_NDTNN_52-57` (block "Bổ sung Loại 1", trùng nội dung) — cả 2 bộ ID đều dùng chung 1 nội dung. Giữ ID nhỏ hơn đã khai sinh trước (`K_NDTNN_52-57`), xóa hẳn bộ `DE3-DE7b` trùng lặp.

**Mockup:**

| Loại báo cáo | Kỳ báo cáo | Mã báo cáo | Tên báo cáo | Mã chỉ tiêu | Tên chỉ tiêu |
|---|---|---|---|---|---|
| Định kỳ | Tháng 3/2026 | RPT-001 | Hoạt động QL DMĐT (PLV-TT51) | CT_01 | Tổng tài sản |

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_52 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_53 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_54 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_55 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn tên báo cáo (PLV-TT51/2021/TT-BTC — Hoạt động QL DMĐT/chỉ định đầu tư). Dữ liệu động | PENDING |
| K_NDTNN_56 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_57 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code cho PLV-TT51 (xem Cụm 7).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code PLV-TT51 |

---
#### Nhóm 19 - CTCK - Báo cáo thống kê danh mục lưu ký NĐTNN, tổ chức phát hành CCLK tại nước ngoài (PLIII-TT51/2021/TT-BTC) (STT=19)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_198 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_199 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_200 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_201 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "CTCK - Báo cáo thống kê danh mục lưu ký NĐTNN, tổ chức phát hành CCLK tại nước ngoài (PLIII-TT51/2021/TT-BTC)". Dữ liệu động | PENDING |
| K_NDTNN_202 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_203 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 20 - CTCK - Hoạt động quản lý danh mục đầu tư/chỉ định đầu tư cho NĐTNN (PLV-TT51/2021/TT-BTC) (STT=20)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_204 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_205 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_206 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_207 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "CTCK - Hoạt động quản lý danh mục đầu tư/chỉ định đầu tư cho NĐTNN (PLV-TT51/2021/TT-BTC)". Dữ liệu động | PENDING |
| K_NDTNN_208 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_209 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 21 - Ngân hàng lưu ký - Báo cáo thống kê danh mục lưu ký NĐTNN, tổ chức phát hành CCLK tại nước ngoài (PLIII-TT51/2011/TT-BTC) (STT=21)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_210 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_211 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_212 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_213 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "Ngân hàng lưu ký - Báo cáo thống kê danh mục lưu ký NĐTNN, tổ chức phát hành CCLK tại nước ngoài (PLIII-TT51/2011/TT-BTC)". Dữ liệu động | PENDING |
| K_NDTNN_214 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_215 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 22 - Ngân hàng lưu ký - Báo cáo hoạt động chu chuyển vốn của NĐTNN, tổ chức phát hành CCLK tại nước ngoài (PLIV-TT51/2021/TT-BTC) (STT=22)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_216 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_217 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_218 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_219 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "Ngân hàng lưu ký - Báo cáo hoạt động chu chuyển vốn của NĐTNN, tổ chức phát hành CCLK tại nước ngoài (PLIV-TT51/2021/TT-BTC)". Dữ liệu động | PENDING |
| K_NDTNN_220 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_221 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 23 - Ngân hàng lưu ký - Báo cáo số liệu hoạt động NĐTNN (STT=23)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_222 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_223 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_224 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_225 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "Ngân hàng lưu ký - Báo cáo số liệu hoạt động NĐTNN". Dữ liệu động | PENDING |
| K_NDTNN_226 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_227 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 24 - Ngân hàng lưu ký - Báo cáo Hoạt động lưu ký chứng khoán của NĐTNN (STT=24)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_228 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_229 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_230 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_231 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "Ngân hàng lưu ký - Báo cáo Hoạt động lưu ký chứng khoán của NĐTNN". Dữ liệu động | PENDING |
| K_NDTNN_232 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_233 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 25 - Đại diện CBTT - Giấy chỉ định/ủy quyền thực hiện CBTT của NĐTNN hoặc nhóm NĐTNN có liên quan (STT=25)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_234 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_235 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_236 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_237 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "Đại diện CBTT - Giấy chỉ định/ủy quyền thực hiện CBTT của NĐTNN hoặc nhóm NĐTNN có liên quan". Dữ liệu động | PENDING |
| K_NDTNN_238 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_239 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 26 - Đại diện CBTT - Báo cáo về sở hữu của nhóm NĐTNN có liên quan là cổ đông lớn, NĐT nắm giữ từ 5% trở lên CP/CCQ đóng (PLIX-TT96/2020/TT-BTC) (STT=26)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_240 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_241 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_242 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_243 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "Đại diện CBTT - Báo cáo về sở hữu của nhóm NĐTNN có liên quan là cổ đông lớn, NĐT nắm giữ từ 5% trở lên CP/CCQ đóng (PLIX-TT96/2020/TT-BTC)". Dữ liệu động | PENDING |
| K_NDTNN_244 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_245 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 27 - Đại diện CBTT - Báo cáo thay đổi về sở hữu của nhóm NĐTNN có liên quan là cổ đông lớn, NĐT nắm giữ từ 5% trở lên CP/CCQ đóng (PLX-TT96/2020/TT-BTC) (STT=27)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_246 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_247 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_248 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_249 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "Đại diện CBTT - Báo cáo thay đổi về sở hữu của nhóm NĐTNN có liên quan là cổ đông lớn, NĐT nắm giữ từ 5% trở lên CP/CCQ đóng (PLX-TT96/2020/TT-BTC)". Dữ liệu động | PENDING |
| K_NDTNN_250 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_251 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 28 - Đại diện CBTT - Báo cáo về ngày trở thành/không còn là cổ đông lớn, NĐT nắm giữ từ 5% trở lên CP/CCQ đóng (STT=28)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_252 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_253 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_254 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_255 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "Đại diện CBTT - Báo cáo về ngày trở thành/không còn là cổ đông lớn, NĐT nắm giữ từ 5% trở lên CP/CCQ đóng". Dữ liệu động | PENDING |
| K_NDTNN_256 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_257 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 29 - Đại diện CBTT - Báo cáo về thay đổi sở hữu của cổ đông lớn, NĐT nắm giữ từ 5% trở lên CP/CCQ đóng (STT=29)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_258 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_259 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_260 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_261 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "Đại diện CBTT - Báo cáo về thay đổi sở hữu của cổ đông lớn, NĐT nắm giữ từ 5% trở lên CP/CCQ đóng". Dữ liệu động | PENDING |
| K_NDTNN_262 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_263 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 30 - Đại diện CBTT - Cập nhật thay đổi về danh sách nhóm NĐTNN có liên quan (PLII-TT51/2021/TT-BTC) (STT=30)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_264 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_265 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_266 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_267 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "Đại diện CBTT - Cập nhật thay đổi về danh sách nhóm NĐTNN có liên quan (PLII-TT51/2021/TT-BTC)". Dữ liệu động | PENDING |
| K_NDTNN_268 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_269 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 31 - Đại diện giao dịch - Báo cáo tình hình hoạt động đầu tư của NĐTNN (PLVIII-TT51/2021/TT-BTC) (STT=31)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_270 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_271 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_272 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_273 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "Đại diện giao dịch - Báo cáo tình hình hoạt động đầu tư của NĐTNN (PLVIII-TT51/2021/TT-BTC)". Dữ liệu động | PENDING |
| K_NDTNN_274 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_275 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 32 - NĐTNN - Báo cáo về ngày trở thành/không còn là cổ đông lớn, NĐT nắm giữ từ 5% trở lên CP/CCQ đóng (STT=32)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_276 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_277 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_278 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_279 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "NĐTNN - Báo cáo về ngày trở thành/không còn là cổ đông lớn, NĐT nắm giữ từ 5% trở lên CP/CCQ đóng". Dữ liệu động | PENDING |
| K_NDTNN_280 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_281 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 33 - NĐTNN - Báo cáo về thay đổi sở hữu của cổ đông lớn, NĐT nắm giữ từ 5% trở lên CP/CCQ đóng (STT=33)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_282 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_283 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_284 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_285 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "NĐTNN - Báo cáo về thay đổi sở hữu của cổ đông lớn, NĐT nắm giữ từ 5% trở lên CP/CCQ đóng". Dữ liệu động | PENDING |
| K_NDTNN_286 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_287 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 34 - NĐTNN - Thông báo giao dịch CP/CCQ/chứng quyền có bảo đảm của người nội bộ và người có liên quan (STT=34)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_288 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_289 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_290 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_291 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "NĐTNN - Thông báo giao dịch CP/CCQ/chứng quyền có bảo đảm của người nội bộ và người có liên quan". Dữ liệu động | PENDING |
| K_NDTNN_292 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_293 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 35 - NĐTNN - Thông báo giao dịch trái phiếu chuyển đổi, quyền mua CP/CCQ, quyền mua TPCĐ của người nội bộ và người có liên quan (STT=35)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_294 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_295 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_296 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_297 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "NĐTNN - Thông báo giao dịch trái phiếu chuyển đổi, quyền mua CP/CCQ, quyền mua TPCĐ của người nội bộ và người có liên quan". Dữ liệu động | PENDING |
| K_NDTNN_298 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_299 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 36 - NĐTNN - Báo cáo kết quả giao dịch CP/CCQ/chứng quyền có bảo đảm của người nội bộ và người có liên quan (STT=36)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_300 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_301 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_302 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_303 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "NĐTNN - Báo cáo kết quả giao dịch CP/CCQ/chứng quyền có bảo đảm của người nội bộ và người có liên quan". Dữ liệu động | PENDING |
| K_NDTNN_304 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_305 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 37 - NĐTNN - Báo cáo kết quả giao dịch TPCĐ, quyền mua CP/CCQ, quyền mua TPCĐ của người nội bộ và người có liên quan (STT=37)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_306 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_307 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_308 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_309 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "NĐTNN - Báo cáo kết quả giao dịch TPCĐ, quyền mua CP/CCQ, quyền mua TPCĐ của người nội bộ và người có liên quan". Dữ liệu động | PENDING |
| K_NDTNN_310 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_311 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 38 - SGDCK - Báo cáo tình hình giao dịch của NĐTNN, tổ chức phát hành CCLK tại nước ngoài (PLVII-TT51/2021/TT-BTC) (STT=38)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_312 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_313 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_314 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_315 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "SGDCK - Báo cáo tình hình giao dịch của NĐTNN, tổ chức phát hành CCLK tại nước ngoài (PLVII-TT51/2021/TT-BTC)". Dữ liệu động | PENDING |
| K_NDTNN_316 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_317 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 39 - VSDC - Báo cáo hoạt động cấp mã số giao dịch (PLVI-TT51/2021/TT-BTC) (STT=39)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_318 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_319 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_320 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_321 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "VSDC - Báo cáo hoạt động cấp mã số giao dịch (PLVI-TT51/2021/TT-BTC)". Dữ liệu động | PENDING |
| K_NDTNN_322 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_323 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 40 - VSDC - Báo cáo danh mục của từng NĐT nước ngoài (STT=40)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_324 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_325 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_326 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_327 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "VSDC - Báo cáo danh mục của từng NĐT nước ngoài". Dữ liệu động | PENDING |
| K_NDTNN_328 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_329 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 41 - VSDC - Báo cáo thống kê tình hình nắm giữ chứng khoán của NĐTNN (STT=41)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_330 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_331 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_332 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_333 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "VSDC - Báo cáo thống kê tình hình nắm giữ chứng khoán của NĐTNN". Dữ liệu động | PENDING |
| K_NDTNN_334 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_335 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 42 - VSDC - Báo cáo thống kê tình hình phát hành chứng khoán ra công chúng, phát hành thêm chứng khoán đã niêm yết/đăng ký giao dịch (STT=42)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_336 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_337 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_338 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_339 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "VSDC - Báo cáo thống kê tình hình phát hành chứng khoán ra công chúng, phát hành thêm chứng khoán đã niêm yết/đăng ký giao dịch". Dữ liệu động | PENDING |
| K_NDTNN_340 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_341 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

#### Nhóm 43 - VSDC - Báo cáo thống kê tình hình chia cổ tức cho NĐTNN (STT=43)

> Phân loại: **Tác nghiệp** (100% PENDING)
> Atomic tham khảo: `Member Regulatory Report`/`Member Report Value`/`Report Template` (FIMS, draft) — generic store TT51 (Cụm 7), cùng pattern Nhóm 12 (STT=18). Cần xác nhận Report Code riêng cho báo cáo này — xem O_NDTNN_27.

**Bảng KPI:**

| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |
|---|---|---|---|---|---|---|
| K_NDTNN_342 | Loại báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `REPORTTYPE.NAME`/`RPTMEMBER.REPORTTypeID`. Dữ liệu động. Mart dự kiến: `NDTNN Regulatory Report Store` (Cụm 7) | PENDING |
| K_NDTNN_343 | Kỳ báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.PeriodType`. Dữ liệu động | PENDING |
| K_NDTNN_344 | Mã báo cáo | — | Chiều | TBD — chờ Atomic | Nguồn `RPTMEMBER.RPID`. Dữ liệu động | PENDING |
| K_NDTNN_345 | Tên báo cáo | — | Chiều | TBD — chờ Atomic | Tên cố định: "VSDC - Báo cáo thống kê tình hình chia cổ tức cho NĐTNN". Dữ liệu động | PENDING |
| K_NDTNN_346 | Mã chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.MA_CHI_TIEU`. Dữ liệu động | PENDING |
| K_NDTNN_347 | Tên chỉ tiêu | — | Chiều | TBD — chờ Atomic | Nguồn `RPT_FIELD_CATALOG.TEN_CHI_TIEU`. Dữ liệu động | PENDING |

**Atomic cần bổ sung:** `Member Regulatory Report` + `Member Report Value` + `Report Template` (FIMS) — cần xác nhận Report Code riêng cho báo cáo này (xem Cụm 7, O_NDTNN_27).

**Bảng mapping nguồn (Atomic Placeholder):**

| Bảng nguồn BA | Atomic entity dự kiến | Atomic table dự kiến | Ghi chú |
|---|---|---|---|
| REPORTTYPE, RPTMEMBER, RPT_FIELD_CATALOG | Member Regulatory Report / Member Report Value / Report Template (Cụm 7) | TBD | Cần xác nhận Report Code — xem O_NDTNN_27 |

---

## Section 3 — Mô hình tổng thể (READY only)

```mermaid
graph TB
    classDef dim fill:#E6F1FB,stroke:#185FA5,color:#0C447C
    classDef fact fill:#FAECE7,stroke:#993C1D,color:#4A1B0C
    classDef oper fill:#E8F5E9,stroke:#2E7D32,color:#1B5E20

    DIM_DATE["Calendar Date Dimension"]:::dim
    DIM_INVESTOR["Foreign Investor Dimension"]:::dim
    DIM_GEO["Geographic Area Dimension"]:::dim
    DIM_ASSET["Asset Category Dimension"]:::dim
    DIM_PUBCO["Public Company Dimension"]:::dim

    FACT_TRADE["Fact Securities Foreign Trading Snapshot"]:::fact
    FACT_MKTIDX["Fact Market Index Snapshot"]:::fact

    OPR_PROFILE["Foreign Investor 360 Profile"]:::oper
    OPR_COMPLY["Investor Compliance History"]:::oper

    DIM_DATE --> FACT_TRADE
    DIM_PUBCO --> FACT_TRADE

    DIM_DATE --> FACT_MKTIDX
```

> **Ghi chú:** `Foreign Investor Dimension`, `Geographic Area Dimension`, `Asset Category Dimension` tạm thời không xuất hiện trong graph này vì Fact duy nhất dùng chúng (`Fact Foreign Investor Portfolio Snapshot`, Nhóm 6) đã chuyển PENDING — xem O_NDTNN_21. Các Dimension này vẫn READY (dùng chung Nhóm 2/4/9), chỉ chưa có Fact READY nào join tới ở trạng thái hiện tại. `Industry Category Dimension` (tên cũ) đã bỏ hẳn khỏi mô hình — Nhóm 8 (nơi duy nhất định nghĩa entity này) đã chuyển sang reuse `Public Company Dimension` thay thế (xem O_NDTNN_12). `Fact Foreign Ownership Snapshot` (tên cũ, entity ảo) đã bỏ khỏi mô hình — Nhóm 9 (nơi duy nhất định nghĩa Fact này) đã chuyển 100% PENDING, thay bằng `Fact Public Company Foreign Ownership Snapshot` (xem O_NDTNN_21/O_NDTNN_22). `NDTNN Regulatory Report Store` đã bỏ khỏi mô hình — Nhóm 12 (nơi duy nhất định nghĩa bảng tác nghiệp này) đã chuyển 100% PENDING (xem O_NDTNN_25).

### Bảng Phân tích (Star Schema)

| Tên bảng Datamart | Mô tả | Fact Pattern | Grain | Nguồn Atomic chính |
|---|---|---|---|---|
| Fact Securities Foreign Trading Snapshot | Snapshot giá trị mua/bán của NĐTNN theo mã CK và toàn thị trường theo ngày (đã bổ sung Security_Type_Code cho Nhóm 14) | Fact Snapshot | 1 mã CK × 1 ngày giao dịch | Securities Trade (ORDERTRADE) |
| Fact Market Index Snapshot | Snapshot chỉ số thị trường (VN-Index/HNX-Index/UPCOM-Index) cuối phiên theo ngày | Fact Snapshot | 1 chỉ số × 1 ngày (ETL lấy bản ghi cuối phiên) | Market Index Snapshot (MDDS.JAD_MARKETINFOR) |
| Fact Securities Foreign Investor Trade Detail | Chi tiết giao dịch NĐTNN theo tài khoản (biểu chi tiết Nhóm 15) | Fact Append | 1 giao dịch/lệnh khớp × 1 tài khoản NĐT × 1 bên (Buy/Sell) | Securities Trade (ORDERTRADE) |

### Bảng Tác nghiệp (Denormalized)

| Tên bảng Datamart | Mô tả | Grain | Nguồn Atomic chính |
|---|---|---|---|
| Foreign Investor 360 Profile | Hồ sơ định danh 360° của NĐTNN — trạng thái mới nhất | 1 row = 1 NĐT NN (trạng thái mới nhất) | Foreign Investor (FIMS) + Custodian Bank (FIMS) |
| Investor Compliance History | Lịch sử tuân thủ và xử phạt của NĐTNN | 1 row = 1 hành vi vi phạm × 1 đối tượng bị xử phạt | Penalty Decision + Subject + Subject Behavior + Penalty Type (Thanh Tra) |

### Bảng Dimension

*Tất cả Dimension áp dụng SCD Type 4A.*

| Tên bảng Datamart | Mô tả | Grain | Nguồn Atomic chính | Conformed |
|---|---|---|---|---|
| Calendar Date Dimension | Lịch ngày — ETL tự sinh trên mart | 1 row = 1 ngày | ETL generated | Có |
| Foreign Investor Dimension | Thông tin định danh NĐT nước ngoài | 1 row = 1 NĐT NN (SCD2) | Foreign Investor (FIMS) | Có |
| Geographic Area Dimension | Thông tin quốc gia / quốc tịch | 1 row = 1 quốc gia (SCD2) | Geographic Area (FIMS) | Có |
| Asset Category Dimension | Loại hình tài sản đầu tư (5 giá trị) | 1 row = 1 loại tài sản (SCD2) | Classification Value (FIMS_SECURITIES_TYPE) | Không |
| Public Company Dimension | Công ty đại chúng — mã CK + nhóm ngành (đệm Classification Business Line Name qua join Business Line Level 1/2 Code) | 1 row = 1 công ty đại chúng (SCD2) | Public Company (IDS.COMPANY_PROFILES) + Classification Business Line (IDS.CATEGORIES) | Có |

---

## Section 4 — Reuse Analysis

`Datamart/datamart_model.yaml` chưa có entity nào của module NDTNN tại thời điểm thiết kế — toàn bộ bảng là `new`, trừ `Calendar Date Dimension` (Lớp 1 — Conformed Dimension Whitelist, luôn reuse `cdr_dt_dim`).

| Datamart Entity | datamart_table | reuse_status | Ghi chú |
|---|---|---|---|
| Fact Securities Foreign Trading Snapshot | fct_scr_forgn_trd_snpst | partial | Đã có từ Nhóm 2 — Nhóm 14 bổ sung cột `Security_Type_Code` (ETL-derived từ Market_Id_Code, scheme mới NDTNN_SECURITY_TYPE) |
| Fact Securities Foreign Investor Trade Detail | fct_scr_forgn_invtr_trd_dtl | new | Chưa có trong master — nguồn Securities Trade (ORDERTRADE), grain chi tiết hơn Fact ở trên (1 giao dịch × 1 tài khoản NĐT, không pre-aggregate) — Nhóm 15 |
| Fact Foreign Investor Portfolio Snapshot | fct_forgn_invtr_port_snpst | n/a | **Bỏ khỏi Section 3/4** — Nhóm 6 (nơi duy nhất định nghĩa Fact này) đã chuyển 100% PENDING vì Atomic nguồn sai (entity không tồn tại) + Dữ liệu động. Chờ thiết kế lại theo generic store TT51 — xem O_NDTNN_21 |
| Fact Public Company Foreign Ownership Snapshot | fct_pc_forgn_ownr_snpst | n/a | **Bỏ khỏi Section 3/4** — Nhóm 9 (nơi duy nhất định nghĩa Fact này) đã chuyển 100% PENDING: BA yêu cầu nguồn báo cáo BM67 VSDC (chưa số hoá) thay vì entity IDS/FIMS đã có sẵn — xem O_NDTNN_21/O_NDTNN_22 |
| Fact Market Index Snapshot | fct_mkt_idx_snpst | new | Chưa có trong master — nguồn Market Index Snapshot (MDDS.JAD_MARKETINFOR), phục vụ Nhóm 5 (K_NDTNN_24b) |
| Foreign Investor 360 Profile | opr_forgn_invtr_360_prfl | new | Chưa có trong master |
| Investor Compliance History | opr_invtr_cmpl_hist | new | Chưa có trong master |
| NDTNN Regulatory Report Store | opr_ndtnn_rgltr_rpt_str | n/a | **Bỏ khỏi Section 3/4** — Nhóm 12 (nơi duy nhất định nghĩa bảng này) đã chuyển 100% PENDING vì Dữ liệu động — xem O_NDTNN_25 |
| Calendar Date Dimension | cdr_dt_dim | reuse | Conformed Dim toàn hệ thống — đã có sẵn từ module khác |
| Foreign Investor Dimension | dim_forgn_invtr | new | Chưa có trong master |
| Geographic Area Dimension | dim_geo_area | new | Chưa có trong master |
| Asset Category Dimension | dim_asst_ctg | new | Chưa có trong master |
| Public Company Dimension | dim_pub_co | new | Chưa có trong master — nguồn Public Company (IDS.COMPANY_PROFILES) + Classification Business Line (IDS.CATEGORIES), dùng chung Nhóm 2, 8 và Nhóm 9 |

---

## Section 5 — Vấn đề mở

| ID | Vấn đề | Giả định hiện tại | KPI liên quan | Trạng thái |
|---|---|---|---|---|
| O_NDTNN_1 | **Registration Date — nguồn sai:** Thiết kế cũ dùng `FIMS.INVESTOR.DateCreated` làm Registration Date. BA xác nhận nguồn thực tế là báo cáo định kỳ PLVI-TT51 (VSDC, kỳ tháng), không phải FIMS.INVESTOR. | Đã đổi Box 2–4 (Nhóm 1) sang PENDING, chờ xác nhận generic store TT51 tương ứng — xem Nhóm 1 Section 2. | K_NDTNN_5–7 | Closed — nguồn xác định lại, PENDING chờ Atomic |
| O_NDTNN_2 | **Investor Object Type mapping:** `FIMS.INVESTOR.ObjectType` là INT (1=Cá nhân / 2=Tổ chức). Không còn áp dụng cho K_NDTNN_6/7 (đã đổi nguồn sang báo cáo VSDC — phân loại Cá nhân/Tổ chức lấy trực tiếp từ Dòng báo cáo, không qua ObjectType). Giữ lại tham khảo nếu sau này cần đối chiếu chéo với FIMS.INVESTOR. | Không áp dụng cho thiết kế hiện tại của K_NDTNN_6/7. | K_NDTNN_6, K_NDTNN_7 | Closed — không còn áp dụng |
| O_NDTNN_3a | **Tỷ lệ tham gia + GT mua/bán/toàn TT (STT 1–4):** Atomic `Securities Trade` (ORDERTRADE.TRADE_BOOK_HOSE/HNX) đã xác nhận READY. | Đã thiết kế `Fact Securities Foreign Trading Snapshot` — xem Nhóm 1 Box 1 (Section 2), Cụm 1a (Section 1). | K_NDTNN_1–4 | Closed |
| O_NDTNN_3c | **GT mua/bán ròng + Lũy kế + Top ngành/mã (STT 8, 9, 10, 11, 13, 14, 15, 16, 21, 22 — Nhóm 2):** Atomic `Securities Trade` READY (dùng chung Nhóm 1). Ngành xác nhận nguồn `Classification Business Line` (IDS.CATEGORIES), Mã CK join qua `Public Company.Equity Ticker Symbol` (IDS.COMPANY_PROFILES). Lưu ý: BA Mã=22 "Top mã tỷ trọng cao" cấp KPI_ID K_NDTNN_159 (không phải K_NDTNN_22 — số đó đã dùng cho "Giá trị mua/bán ròng" ở Nhóm 5, STT=5). BA dòng không mã "Tỷ trọng TB phiên" cấp K_NDTNN_158. | Đã thiết kế `Fact Securities Foreign Trading Snapshot` (grain mở rộng 1 mã CK × 1 ngày) + `Public Company Dimension` (reuse từ Nhóm 9) — xem Nhóm 2 Section 2. | K_NDTNN_8, 9, 10, 11, 12, 13, 14, 15, 16, 158, 159 | Closed |
| O_NDTNN_3d | **K_NDTNN_17-21 ("Nhóm 3 — Tỷ trọng giao dịch NĐTNN", Tab GIAO DỊCH) không truy được về BA hiện hành:** Đối chiếu lại cột STT thật (cột 0) trong `BA_analyst_NDTNN.csv` — con số "17–21" ghi trong header cũ thực chất là cột **Mã** (mã KPI) của các Dashboard/Data Explorer khác hoàn toàn không liên quan (STT=16 Data Explorer Dòng vốn ròng, STT=17 Data Explorer Tổng giá trị danh mục...), không phải STT của 1 Nhóm "Tỷ trọng giao dịch" nào. Xác nhận đây là thiết kế cũ trước khi BA tái cấu trúc — nội dung 5 KPI (Tỷ trọng TB phiên, Tỷ trọng GD theo ngày, Tỷ trọng theo ngành, Top mã tỷ trọng cao, Tổng GT GD NĐTNN theo ngày) đã được phủ đủ 100% ở Nhóm 2 hiện hành (K_NDTNN_158, K_NDTNN_1 reuse, K_NDTNN_16, K_NDTNN_159, K_NDTNN_4/21). | **Đã xóa** toàn bộ Nhóm 3 "Tỷ trọng giao dịch NĐTNN" (Tab GIAO DỊCH) — cả block chính lẫn block trùng lặp "Bổ sung Loại 1" — nội dung đã có đầy đủ ở Nhóm 2. | K_NDTNN_17, 18, 19, 20, 21 | Closed — đã xóa, nội dung trùng Nhóm 2 |
| O_NDTNN_13 | **`Source_System_Code` thiếu trên nhiều Dimension (lỗi cấu trúc có sẵn từ bản gốc, phát hiện khi chạy Bước 5B mục #3 sau sửa Nhóm 2):** `Foreign_Investor_Dimension`, `Geographic_Area_Dimension`, `Asset_Category_Dimension`, `Industry_Category_Dimension`, và block `Public_Company_Dimension` ở Nhóm 9 (Section 2) đều thiếu trường `Source_System_Code` trong erDiagram — vi phạm checklist erDiagram chuẩn. Đã tự sửa riêng block `Public_Company_Dimension` mới thêm ở Nhóm 2 (Section 2) vì thuộc phạm vi đang xử lý; các Dimension khác chưa sửa vì ngoài phạm vi Nhóm 2. | Chưa sửa — cần rà soát lại toàn bộ erDiagram Dimension trong file khi review đến đúng Nhóm tương ứng (Nhóm 4, 6, 7, 8, 9, NĐT 360). | K_NDTNN_5-7 (PENDING), 26-33, 34-44, 51 | Open — chờ rà soát toàn file |
| O_NDTNN_17 | **Số Nhóm trong Section 2 không khớp STT thật của BA (Tab GIÁM SÁT DÒNG VỐN) — phát hiện khi user chỉ ra 2026-07-22:** Nguyên tắc bắt buộc "Nhóm trong HLD = STT trong BA analyst (tuyệt đối)" bị vi phạm — HLD cũ đánh `Nhóm 4` cho nội dung STT=5 (Tương quan Net Flow & VN-Index) và `Nhóm 5` cho nội dung STT=4 (Dòng vốn đầu tư gián tiếp), đảo ngược thứ tự thật. Cùng lúc phát hiện K_NDTNN_22 (Giá trị mua/bán ròng) và K_NDTNN_24b (Điểm đóng cửa VN-Index) bị PENDING sai: BA độ chi tiết Ngày (không phải tháng như thiết kế cũ), Dữ liệu tĩnh, Atomic `Securities Trade` (K_22, dùng chung Nhóm 1/2) và `Market Index Snapshot` ← MDDS.JAD_MARKETINFOR (K_24b, approved) đều đã READY. | Đã đổi số: Nhóm 4 = STT4 (Dòng vốn đầu tư gián tiếp), Nhóm 5 = STT5 (Tương quan Net Flow & VN-Index). Đã chuyển K_NDTNN_22 và K_NDTNN_24b sang READY (Fact Securities Foreign Trading Snapshot reuse Nhóm 2 + Fact Market Index Snapshot mới). Xóa block "Bổ sung Loại 1" trùng lặp (Tab GIÁM SÁT DÒNG VỐN — Nhóm 4 cũ) vì nội dung đã lỗi thời hoàn toàn. Còn Nhóm 6-9 (đang ghi "không STT" nhưng có STT=6,7,8,9 thật) và Nhóm 12 chưa rà — xem O_NDTNN_18. | K_NDTNN_22, 24b, 25b, 160, 161, 26-33 | Closed — đã đổi số Nhóm 4↔5 và sửa 2 KPI PENDING sai |
| O_NDTNN_18 | **Nghi ngờ lệch STT tương tự ở Nhóm 6-9 và Nhóm 12 — đã xác nhận đúng cho toàn bộ Nhóm 6-12; phát hiện thêm 25 STT (19-43) hoàn toàn chưa có Nhóm HLD nào:** Nhóm 6 xác nhận STT=6, Nhóm 7 xác nhận STT=7 (Cơ cấu tài sản), Nhóm 8 xác nhận STT=8 (Phân ngành), Nhóm 9 xác nhận STT=9 (ROOM) — cả 4 đã sửa xong header đúng STT. "Nhóm 10" cũ (Tab BÁO CÁO, "Báo cáo thống kê tình hình giao dịch NĐTNN") xác nhận thực chất là STT=14+15, đã tách và đổi số đúng — xem O_NDTNN_23. STT=10 thật (Room còn lại, Tab DANH MỤC) đã bổ sung đúng vị trí. Nhóm 11b xác nhận STT=17 (đã sai "không STT" + entity ảo, đã sửa — xem O_NDTNN_21). Nhóm 12 xác nhận STT=18 (Data Explorer Pass-through PLV-TT51, tên Dashboard "CTQLQ, CN CTQLQ nước ngoài...") — đã sửa gating "Loại dữ liệu" sai (READY→PENDING) — xem O_NDTNN_25. **[Cập nhật 2026-07-23]** Rà soát toàn bộ BA (43 STT) phát hiện thêm STT 19-43 (25 STT, 150 dòng BA) — cùng pattern Data Explorer Pass-through hệt Nhóm 12, nhưng HOÀN TOÀN chưa có Nhóm HLD nào (khác 8 block "Bổ sung Loại 2" hiện có trong file — đó là nội dung cũ trùng lặp Nhóm 1-9, không liên quan STT 19-43). Đây là hệ quả cùng gốc với O_NDTNN_17, cùng phạm vi với O_NDTNN_21. | Đã xử lý toàn bộ Nhóm 6-12 + khai sinh mới Nhóm 19-43 (100% PENDING, K_NDTNN_198-347) — xem O_NDTNN_27. | K_NDTNN_198-347 (Nhóm 19-43, mới khai sinh) | Closed — đã xử lý hết phạm vi Nhóm 6-12 + khai sinh Nhóm 19-43 |
| O_NDTNN_19 | **K_NDTNN_24b (Điểm đóng cửa VN-Index, Nhóm 5) — chưa xác nhận `Market_Id='10'`+`Market_Code='HOSE'` chỉ trả về đúng 1 chỉ số/ngày:** BA SQL tham khảo chỉ filter `marketId='10'` + `marketCode='HOSE'`, không filter theo loại chỉ số (`Index_Type_Code`/`INDEXTYPECODE`) — scheme `MDDS_INDEX_TYPE` (`classification_schemes.yaml`) tồn tại nhưng `values: []` chưa profile. Giả định hiện tại: combo `Market_Id='10'`+`Market_Code='HOSE'` là duy nhất và tương ứng VN-Index (không có nhiều chỉ số khác cùng combo này trong 1 ngày) — CHƯA xác nhận với BA/profile dữ liệu thật. Nếu 1 ngày có nhiều dòng cùng `Market_Id`+`Market_Code` khác `Index_Time` do nhiều chỉ số khác nhau publish cùng lúc (không chỉ do nhiều lần cập nhật trong phiên) thì công thức `ROW_NUMBER... rn=1` sẽ lấy nhầm chỉ số. | Tạm dùng đúng theo SQL BA (không filter thêm `Index_Type_Code` vì BA không yêu cầu) — cần profile dữ liệu MDDS.JAD_MARKETINFOR thật hoặc hỏi BA xác nhận trước khi go-live. | K_NDTNN_24b | Open — chờ xác nhận profile dữ liệu |
| O_NDTNN_4 | **Industry source — đã xác định là IDS:** BA ghi `IDS - GSĐC` nhưng ngành nghề công ty đại chúng nằm trong `Public Company` (IDS.company_profiles → category_l1_id/l2_id). Atomic READY. Join chain: FIMS.CATEGORIESSTOCK (mã CK) → `Public Company` (IDS, có ngành) → `Industry Category Dimension`. | Thiết kế theo IDS — `Industry Category Dimension` READY. | STT 13–14, Nhóm 8 | Closed |
| O_NDTNN_5 | **[Cập nhật 2026-07-23] Portfolio Market Value source — xác nhận rõ nguyên nhân gốc khi review Nhóm 6:** Atomic `CATEGORIESSTOCK` (nay đã gộp vào entity `Foreign Investor Securities Account`, table_type Fundamental) chỉ có `Current Holding Quantity`/`Current Ownership Rate` (current-state, không phải Snapshot theo tháng) — không có giá trị thị trường tính sẵn, và bản thân entity cũng không đúng grain cho Fact Snapshot theo tháng. Xem O_NDTNN_21 để biết toàn bộ phân tích. | Đã xác nhận: measure "Tổng giá trị danh mục" (Nhóm 6) thực chất là Dữ liệu động, nguồn thật là báo cáo PLIII-TT51 (generic store TT51), không phải tính từ CATEGORIESSTOCK × giá SGDCK như giả định cũ. | K_NDTNN_34–44, A1–A2 | Closed — nguyên nhân xác định lại, xem O_NDTNN_21 |
| O_NDTNN_6 | **[Cập nhật 2026-07-23] Atomic Thanh Tra — giả định nguồn cũ sai, xem O_NDTNN_26:** Giả định trước đây "`Surveillance Enforcement Case` + `Surveillance Enforcement Decision`" không đúng — rà soát BA STT=13 xác nhận nguồn thật là `PENALTY_DECISION*`/`PENALTY_TYPE` (THANHTRA, approved). | Đã sửa `Investor Compliance History` dùng đúng entity `Penalty Decision`/`Penalty Decision Subject`/`Penalty Decision Subject Behavior`/`Penalty Type` — xem O_NDTNN_26. | K_NDTNN_192-197 | Closed — nguyên nhân xác định lại, xem O_NDTNN_26 |
| O_NDTNN_7 | **FK NĐT trong GS_HO_SO:** Atomic chỉ có `Subject Name` (text tự do — `GS_HO_SO.TEN_DOI_TUONG`) — không có FK sang `FIMS.INVESTOR`. ETL phải resolve qua text matching hoặc lookup bảng khác. | Tạm giả định resolve qua Subject Name match với `INVESTOR.name`. | K_NDTNN_C1–C5 | Open |
| O_NDTNN_8 | **Phân loại và Mức độ trên Sub-tab C:** Mockup hiển thị `REMINDER / ADMINISTRATIVE SANCTION` và `LOW / MEDIUM / HIGH` nhưng Atomic GS_ chỉ có scheme `TT_CASE_STATUS`. | C2 = `Decision Status Code` (`dcsn_st_code`) — loại hình quyết định. C4/C5 = `Case Status Code` (`case_st_code`) — mức độ và tiến độ hồ sơ cha. C4 và C5 cùng cột nguồn nhưng ngữ nghĩa hiển thị khác nhau — BA Thanh Tra xác nhận scheme đủ phân biệt. | K_NDTNN_C2, K_NDTNN_C4, K_NDTNN_C5 | Confirmed |
| O_NDTNN_9 | **[Cập nhật 2026-07-23] Asset Category scheme — không còn áp dụng:** Giả định cũ dùng scheme `FIMS_SECURITIES_TYPE` cho 5 loại tài sản (K_NDTNN_40-44) không còn đúng — đối chiếu BA Nhóm 7 xác nhận toàn bộ measure là Dữ liệu động (nguồn báo cáo PLIII-TT51), Chiều "Loại tài sản" thật sự lấy từ `FIMS.RELATEDPROPERTIES` (không phải `FIMS_SECURITIES_TYPE`) nhưng bảng này cũng chưa được model hóa đúng ngữ cảnh danh mục đầu tư trong Atomic (chỉ có scheme `FIMS_RELATED_PROPERTY` cho ngữ cảnh ủy quyền CBTT/giao dịch, khác hẳn). Xem O_NDTNN_21. | Không dùng `FIMS_SECURITIES_TYPE` — cần entity/scheme Atomic riêng cho phân loại tài sản danh mục đầu tư NĐTNN, xác nhận qua generic store TT51. | K_NDTNN_40–44, 163, 164 | Closed — giả định cũ sai, xem O_NDTNN_21 |
| O_NDTNN_10 | **[Cập nhật 2026-07-23] ROOM source — giả định cũ sai, xem O_NDTNN_22:** Giả định trước đây "IDS.foreign_owner_limit là nguồn chính thức, K_NDTNN_45–49 READY" không còn đúng — rà soát BA STT=9 (Nhóm 9) xác nhận toàn bộ 6/6 dòng đều PENDING, nguồn thật là báo cáo BM67 VSDC (chưa số hoá) hoặc Dữ liệu động, không phải trực tiếp từ IDS.FOREIGN_OWNER_LIMIT/FIMS. | Đã chuyển toàn bộ Nhóm 9 (K_NDTNN_45–50) sang PENDING — xem O_NDTNN_22 để biết chi tiết 2 nguồn khác nhau cùng khái niệm. | K_NDTNN_45–50 | Closed — nguyên nhân xác định lại, xem O_NDTNN_22 |
| O_NDTNN_11 | **[Superseded bởi O_NDTNN_22] Room theo ngành (K_NDTNN_50):** Vấn đề gốc (thiếu nguồn tổng CP lưu hành) không còn là gốc rễ chính — toàn bộ Nhóm 9 đã PENDING vì BA yêu cầu nguồn BM67 VSDC, không riêng K_NDTNN_50. | Không còn áp dụng riêng lẻ — xem O_NDTNN_22 cho toàn bộ Nhóm 9. | K_NDTNN_50 | Closed — superseded bởi O_NDTNN_22 |
| O_NDTNN_12 | **[Đã sửa qua Nhóm 8, 2026-07-23] `Industry Category Dimension` — sai tên field + thiếu 1 bước join, phát hiện khi review Nhóm 2 (2026-07-22):** Header Nhóm 8 (cũ) ghi "Atomic: `Public Company` (IDS.company_profiles + IDS.company_detail)" — `company_detail` không tồn tại trong Atomic (chỉ có `IDS.COMPANY_PROFILES`, xem `DataModel/working/Atomic/lld/IDS/lld_IDS_COMPANY_PROFILES.yaml`, entity `Public Company`, draft). Entity này có `Business Line Level 1/2 Id/Code` (FK, từ `CATEGORY_L1_ID/L2_ID`) — **không tự chứa tên ngành**. Tên ngành thật nằm ở entity riêng `Classification Business Line` (physical_name `cl_business_line`, nguồn `IDS.CATEGORIES` + `ECAT.BUSINESS_LINE_LEVEL_1/2`, draft), có `Classification Business Line Code/Name`. erDiagram cũ tự đặt field `Industry_Category_Code`/`Industry_Category_Name` không khớp attribute thật nào của cả 2 entity trên — vi phạm rule "tên trường erDiagram phải khớp attribute.name YAML". | Nhóm 8 đã sửa: bỏ hẳn `Industry Category Dimension` (tên/field tự đặt sai), **reuse thẳng `Public Company Dimension`** (đã thiết kế đầy đủ ở Nhóm 2, có sẵn cột `Classification_Business_Line_Name` đệm đúng qua join chain 2 bước `Public Company.Business_Line_Level1_Code` → `Classification Business Line.cl_business_line_code`) — không tạo Dimension riêng mới. K_NDTNN_51a (Chiều Nhóm ngành) chuyển READY. Nhóm 9 chưa rà — xem O_NDTNN_21. | K_NDTNN_51a (Nhóm 8, đã sửa); mọi KPI dùng chiều ngành ở Nhóm 9 (chưa rà) | Closed cho Nhóm 8 — còn Nhóm 9 xem O_NDTNN_21 |
| O_NDTNN_14 | **[SUPERSEDED bởi O_NDTNN_20] Header READY/PENDING không đồng nhất text mô tả (phát hiện 2026-07-22, user chỉ ra):** 3 style khác nhau cho cùng 1 cấp heading `##### READY`/`##### PENDING`. Vấn đề gốc không còn áp dụng — xem O_NDTNN_20 (đổi thiết kế: bỏ hẳn header con `##### READY`/`##### PENDING`, gộp 1 bảng KPI duy nhất/Nhóm). | Không còn áp dụng — thiết kế mới không còn header con để "đồng nhất style" nữa, đã thay bằng cột Trạng thái trong 1 bảng KPI chung. | Toàn bộ header READY/PENDING trong file (Nhóm 1-5 đã sửa, còn 6-12 + block Loại 1/2 chờ xử lý — xem O_NDTNN_20) | Closed — superseded bởi thay đổi thiết kế O_NDTNN_20 |
| O_NDTNN_20 | **Thay đổi thiết kế: bỏ tách Block READY/PENDING riêng, gộp 1 bảng KPI duy nhất/Nhóm (2026-07-23, theo yêu cầu user):** Format cũ (`##### READY`/`##### PENDING` header con, bảng KPI READY 6 cột tách biệt bảng KPI PENDING 4 cột) đã đổi thành 1 bảng KPI 7 cột duy nhất cho mọi Nhóm (KPI ID/Tên/Đơn vị/Tính chất/Công thức/Ghi chú/Trạng thái) — dòng PENDING vẫn nằm trong cùng bảng, cột Ghi chú chứa Lý do pending/Atomic cần bổ sung/Mart dự kiến. Đã sửa `section_structure.md` + `SKILL.md` + `naming_conventions.md` (skill `datamart-hld-design`) phản ánh thiết kế mới. | Đã chuyển đổi Nhóm 1-15 + Nhóm 19-43 + Sub-tab A/C sang format mới, đối chiếu lại số lượng BA↔KPI khớp tuyệt đối (Nhóm 1=7, Nhóm 2=16, Nhóm 3=3, Nhóm 4=10, Nhóm 5=3, Nhóm 6=7, Nhóm 7=7, Nhóm 8=2, Nhóm 9=6, Nhóm 10=1, Nhóm 11a=5, Nhóm 11b=4, Nhóm 12=6, Nhóm 14=12, Nhóm 15=6, Nhóm 19-43=6 mỗi Nhóm, Sub-tab C=6). 8 block "Bổ sung Loại 2" (format cũ) đã xóa hẳn (2026-07-23) sau khi xác nhận trùng lặp 100% với các Nhóm đã thiết kế — xem O_NDTNN_15. | Toàn bộ HLD nay dùng thống nhất 1 format bảng KPI 7 cột — không còn block nào ở format cũ. | Open — chờ user duyệt Phase 1 hoàn chỉnh |
| O_NDTNN_15 | **10 block "Bổ sung Loại 1/2" (trước Section 3) sai cấu trúc + trùng lặp nội dung với Nhóm gốc — phát hiện khi chuẩn hóa header theo yêu cầu user (2026-07-22):** (1) **2 block "Loại 1"** (DANH MỤC Nhóm 9, DATA EXPLORER Nhóm 12) **trùng lặp hoàn toàn** với Nhóm gốc đã có sẵn phía trên trong Section 2 — cùng KPI_ID, cùng nội dung, chỉ khác format bảng. Cả 2 đã xóa (Nhóm 9: 2026-07-23, xem O_NDTNN_22; Nhóm 12: 2026-07-23, xem O_NDTNN_25 — giữ ID K_NDTNN_52-57 từ block Loại 1 làm chính thức, xóa bộ `DE3-DE7b` trùng ở Nhóm 12 gốc). Block thứ 3 (GIAO DỊCH Nhóm 3) đã xóa — xem O_NDTNN_3d. Block thứ 4 (GIÁM SÁT DÒNG VỐN — Nhóm 4/5) đã xóa — xem O_NDTNN_17. (2) **8 block "Loại 2"** (K_NDTNN_59-97, 98-119, 120-130, 131-148, 149-157) dùng header sai cấu trúc `#### Tab: X — Nhóm — Y` (không có STT) — vi phạm chuẩn `### Tab` → `#### Nhóm {STT} - {tên}`. Đối chiếu từng KPI_ID với các Nhóm 1-15/Sub-tab A/C đã thiết kế xác nhận **cả 8/8 block trùng lặp hoàn toàn 100%** — không có nội dung mới nào (K_NDTNN_59-81 ↔ Nhóm 1+2; K_NDTNN_82-97 ↔ Nhóm 3/4/5; K_NDTNN_98-119 ↔ Nhóm 6/7/8/9/10; K_NDTNN_120-130 ↔ Sub-tab A + Sub-tab C; K_NDTNN_131-142 ↔ Nhóm 14; K_NDTNN_143-148 ↔ Nhóm 15; K_NDTNN_149-153 ↔ Nhóm 11a; K_NDTNN_154-157 ↔ Nhóm 11b). | **Toàn bộ 4/4 block "Loại 1" và 8/8 block "Loại 2" đã xóa (2026-07-23)** — không di chuyển nội dung nào sang Section 2 vì xác nhận trùng lặp 100%, không có KPI mới. Toàn bộ ~99 dòng BA "trạng thái mapping trống" đại diện bởi các block này thực chất đã được phủ đủ bởi Nhóm 1-15 + Sub-tab A/C hiện hành. | Không còn KPI nào thuộc phạm vi block Loại 1/2 — toàn bộ đã có KPI_ID chính thức ở Nhóm tương ứng | Closed — đã xóa toàn bộ 4+8 block, xác nhận trùng lặp 100% |
| O_NDTNN_16 | **`Fact Foreign Investor Capital Flow` toàn bộ measure là Dữ liệu động — phát hiện khi review Nhóm 3 (2026-07-22):** BA đánh dấu Dữ liệu động cho toàn bộ measure "Dòng vốn/tiền vào/ra/ròng" ở Nhóm 3 (STT=3, K_NDTNN_23-25), Nhóm 4 (STT=4, K_NDTNN_26-33), Nhóm 5 phần K_NDTNN_25b (STT=5), và Nhóm 11a Data Explorer (STT=16, K_NDTNN_DE1a-e) — tất cả cùng nguồn báo cáo định kỳ PLIV-TT51/2021/TT-BTC (Ngân hàng lưu ký gửi, kỳ nửa tháng). Thiết kế cũ (`Fact Foreign Investor Capital Flow` ← FIMS.RPTVALUES/RPTMEMBER trực tiếp) không phản ánh đúng gating "Loại dữ liệu" — đã chuyển toàn bộ 4 Nhóm liên quan sang PENDING, xóa Fact khỏi Section 3 (Bảng Phân tích). | Đã chuyển Nhóm 3, 4 (K_NDTNN_26-33), 5 (K_NDTNN_25b), 11a sang PENDING — chờ xác nhận Report Code/Cell Code của báo cáo PLIV-TT51 trong generic store TT51 (Cụm 7) trước khi thiết kế lại Fact. Khai sinh mới K_NDTNN_160/161 (Loại hình NĐTNN, Quốc gia — Chiều dùng filter cho measure PENDING của Nhóm 4). Riêng K_NDTNN_22/24b (Nhóm 5) đã xác nhận Dữ liệu tĩnh + Atomic READY — chuyển sang READY, xem O_NDTNN_17. [Cập nhật 2026-07-23] `Geographic Area` KHÔNG còn READY — xem O_NDTNN_21 (nguồn ECAT, không có entry FIMS). | K_NDTNN_23-25, 25b, 26-33, 160-161, DE1a-e | Closed — đã chuyển PENDING, chờ Atomic |
| O_NDTNN_21 | **[GỐC RỄ LỚN] Entity Atomic ảo `Foreign Investor Stock Portfolio Snapshot` dùng lan rộng nhiều Nhóm + nguồn `FIMS.NATIONAL` cho Geographic Area không tồn tại — phát hiện khi review Nhóm 6 (2026-07-23):** (1) HLD (Cụm 3 cũ, Nhóm 6/7, và tham chiếu ở Nhóm 8/9/Sub-tab B/Nhóm 11b) dùng tên entity `Foreign Investor Stock Portfolio Snapshot` (nguồn `FIMS.CATEGORIESSTOCK`) — entity này KHÔNG tồn tại trong `DataModel/working/Atomic/lld/manifest.yaml` hiện hành. Grep xác nhận `CATEGORIESSTOCK` đã gộp vào entity `Foreign Investor Securities Account` (SECURITIESACCOUNT+CATEGORIESSTOCK, quyết định Data Modeler 2026-07-19, `table_type: Fundamental` — current-state 1 tài khoản × 1 CTCK, KHÔNG phải Fact Snapshot theo tháng, không có `Portfolio Market Value`). (2) HLD dùng nguồn `FIMS.NATIONAL` cho `Geographic Area` — nhưng entity `Geographic Area` approved chỉ có nguồn từ `ECAT.COUNTRY/REGION/PROVINCE_NEW/WARD_NEW`, không có entry FIMS nào — Chiều "Quốc gia NĐTNN" chưa có Atomic nguồn xác nhận. (3) Nhóm 7 xác nhận thêm: toàn bộ 7/7 KPI (không có dòng tĩnh nào) đều Dữ liệu động, và Chiều "Loại tài sản" dùng `FIMS.RELATEDPROPERTIES` nhưng bảng này trong Atomic chỉ model hóa cho ngữ cảnh ủy quyền CBTT/giao dịch (`FIMS_RELATED_PROPERTY`), khác hẳn ngữ cảnh "loại tài sản danh mục đầu tư" — cần entity/scheme Atomic riêng. (4) Nhóm 8 xác nhận thêm: KPI "Tỷ trọng theo ngành" (K_NDTNN_51) cùng gốc rễ thiếu measure giá trị tài sản (không có giá đóng cửa trong FIMS/IDS) — PENDING; riêng Chiều "Nhóm ngành" (K_NDTNN_51a) không phụ thuộc entity ảo này, đã sửa xong và READY qua reuse `Public Company Dimension` (xem O_NDTNN_12). (5) Nhóm 9 xác nhận thêm: `Fact Foreign Ownership Snapshot` (tên cũ) dùng `Public Company Foreign Ownership Limit` (IDS) + entity ảo — sai vì BA yêu cầu nguồn báo cáo BM67 VSDC (chưa số hoá), không phải entity IDS/FIMS đã có sẵn — toàn bộ 6/6 KPI PENDING (xem O_NDTNN_22). (6) Nhóm 11b xác nhận thêm: cùng dùng entity ảo, đánh READY sai — BA xác nhận STT=17, toàn bộ 4/4 KPI Dữ liệu động (nguồn PLIII-TT51, cùng gốc Nhóm 6) → PENDING. (7) Đã sửa phạm vi Nhóm 6, 7, 8, 9, 11b + Cụm 3 (tách 3a/3b/3c) + Cụm 6 (PENDING) trong các đợt này. Block "Bổ sung Loại 2 — Tab DANH MỤC — Nhóm — Danh mục" (K_NDTNN_98-119, từng tham chiếu entity ảo) đã xóa hẳn (2026-07-23, xem O_NDTNN_15) — xác nhận trùng lặp 100% với Nhóm 6/7/8/9/10 đã sửa đúng, không còn nội dung sai sót nào tồn đọng. | Đã sửa Nhóm 6 (100% PENDING trừ Chiều Loại hình NĐT) + Nhóm 7 (100% PENDING, khai sinh K_NDTNN_163/164) + Nhóm 8 (1 READY qua reuse Public Company Dimension + 1 PENDING) + Nhóm 9 (100% PENDING, xem O_NDTNN_22) + Nhóm 11b (100% PENDING, đổi STT + KPI ID K_NDTNN_188-191) + Section 1 Cụm 3/Cụm 6 + Section 3/4 (xóa `Fact Foreign Investor Portfolio Snapshot`/`Fact Foreign Ownership Snapshot` khỏi bảng Phân tích/Reuse Analysis). Block "Bổ sung Loại 2" (K_NDTNN_98-119) đã xóa — xem O_NDTNN_15. | K_NDTNN_34-39 (Nhóm 6, đã sửa); K_NDTNN_40-44, 163-164 (Nhóm 7, đã sửa); K_NDTNN_51/51a (Nhóm 8, đã sửa); K_NDTNN_45-50 (Nhóm 9, đã sửa); K_NDTNN_188-191 (Nhóm 11b, đã sửa) | Closed — đã xử lý toàn bộ phạm vi, bao gồm xóa block Loại 2 trùng lặp |
| O_NDTNN_22 | **Nhóm 9 (ROOM) — 2 nguồn khác nhau cùng khái niệm nghiệp vụ, BA ưu tiên báo cáo thủ công BM67 — phát hiện khi review Nhóm 9 (2026-07-23):** BA STT=9 chỉ định rõ nguồn "Room tối đa" và "Tỷ lệ sở hữu (theo mã CK)" là báo cáo **BM67 "Quản lý thông tin nhà đầu tư nước ngoài"** (VSDC, chưa số hoá CSDL cho 2/6 dòng — Loại dữ liệu "Chưa có CSDL - Map biểu mẫu"; 4/6 dòng còn lại "Dữ liệu động"). Tuy nhiên Atomic đã có sẵn 2 entity số hoá tương đương đúng khái niệm: `Public Company Foreign Ownership Limit` (IDS.FOREIGN_OWNER_LIMIT, draft, field `Maximum Foreign Ownership Rate Percentage` = "Room tối đa") và `Foreign Investor Securities Account` (FIMS, draft, `Current Holding Quantity`/`Current Ownership Rate` liên quan "Tỷ lệ sở hữu"). Theo xác nhận Data Modeler (2026-07-23): tuân thủ đúng gate rule theo BA — toàn bộ 6 KPI PENDING, KHÔNG dùng 2 entity IDS/FIMS này để "lách" gate rule dù khái niệm nghiệp vụ khớp, vì đây không phải trường hợp "chưa có Atomic" mà là "BA yêu cầu nguồn báo cáo thủ công khác với entity đã số hoá". | Đã chuyển toàn bộ Nhóm 9 (K_NDTNN_45-50) sang PENDING, ghi rõ trong cột Ghi chú của từng dòng cả nguồn BA yêu cầu (BM67) lẫn entity Atomic tương đương đã có (để không mất thông tin tra cứu). Cần Data Modeler xác nhận thêm: nguồn chính thức cho go-live là BM67 (cần số hoá CSDL mới) hay entity IDS/FIMS đã có (cần đổi lại thiết kế BA). | K_NDTNN_45-50 | Open — chờ Data Modeler xác nhận nguồn go-live chính thức |
| O_NDTNN_23 | **"Nhóm 10" cũ (Tab BÁO CÁO) thực chất là BA STT=14+15, bị đặt sai số — phát hiện khi review Nhóm 10 (2026-07-23):** Header "Nhóm 10 — Báo cáo thống kê tình hình giao dịch NĐTNN" (Tab BÁO CÁO) không khớp BA STT=10 thật (STT=10 là "Room còn lại", Tab DANH MỤC, 1 dòng, Trùng K_NDTNN_48). Nội dung thực chất khớp BA STT=14 (Báo cáo thống kê tổng hợp, 12 dòng) + STT=15 (Báo cáo thống kê chi tiết, 6 dòng) — cùng gốc lỗi lệch STT với O_NDTNN_17/18. | Đã tách và đổi số đúng: "Nhóm 14" (STT=14, 9/12 KPI READY qua partial Fact Securities Foreign Trading Snapshot + Security_Type_Code) và "Nhóm 15" (STT=15, 6/6 KPI READY qua Fact mới Securities Foreign Investor Trade Detail). Đã bổ sung "Nhóm 10" đúng (Tab DANH MỤC, reuse K_NDTNN_47, PENDING). | K_NDTNN_165-176 (Nhóm 14), K_NDTNN_177-182 (Nhóm 15), K_NDTNN_47 (Nhóm 10, reuse) | Closed — đã tách và đổi số đúng |
| O_NDTNN_24 | **Nhóm 14 (STT=14) — 3 dòng CCQ cần cross-module join MDDS chưa xác nhận thiết kế — phát hiện khi review Nhóm 10/14 (2026-07-23):** BA tự ghi chú "[M-01] Cần bổ sung bảng danh mục loại CK để filter CCQ" cho 3 dòng CCQ (Mua/Bán/Ròng) — cần join `Securities Trade.Security_Symbol_Code` (ORDERTRADE) sang `Security Trading Snapshot.Symbol` (MDDS.JAD_STOCKINFOR, approved) filter `Stock_Type_Code='3'`, lấy bản ghi mới nhất theo `Trading_Date`. Đây là cross-module join (ORDERTRADE + MDDS) chưa từng thiết kế cho module NDTNN — khác các Nhóm 9/8 dùng chung 1 module. | Giữ PENDING cho 3 dòng CCQ (K_NDTNN_171-173) — cần Data Modeler xác nhận thiết kế cross-module join trước khi go-live. 9 dòng Cổ phiếu/Trái phiếu/Tổng (không cần CCQ) đã READY. | K_NDTNN_171-173 | Open — chờ xác nhận thiết kế cross-module join MDDS |
| O_NDTNN_25 | **Nhóm 12 (STT=18) — gating "Loại dữ liệu" sai + KPI thừa không có dòng BA — phát hiện khi review Nhóm 12 (2026-07-23):** HLD cũ đánh READY toàn bộ "26 mẫu biểu TT51/2021" (Nhóm 12 gốc + block "Bổ sung Loại 1" trùng lặp K_NDTNN_52-58) dù BA STT=18 xác nhận **toàn bộ 6/6 dòng đều Dữ liệu động**. Đồng thời KPI "Giá trị" (`K_NDTNN_DE8`/`K_NDTNN_58` cũ, Cell Value) **không có dòng BA tương ứng** — BA STT=18 chỉ có 6 dòng (Loại/Kỳ/Mã/Tên báo cáo + Mã/Tên chỉ tiêu), không dòng nào là "Giá trị" độc lập; các STT Data Explorer khác cùng pattern (19, 20...) cũng chỉ 6 dòng, xác nhận đây không phải thiếu sót ngẫu nhiên của riêng STT=18. | Theo xác nhận Data Modeler (2026-07-23): (1) Chuyển toàn bộ Nhóm 12 sang PENDING theo gate rule. (2) Loại bỏ KPI "Giá trị" khỏi bảng KPI — tuân thủ đúng rule "cấm thêm KPI không có dòng BA", dù hợp lý về nghiệp vụ (Pass-through cần measure). (3) Giữ ID `K_NDTNN_52-57` (khai sinh trước, từ block "Bổ sung Loại 1"), xóa bộ `K_NDTNN_DE3-DE7b` trùng lặp ở Nhóm 12 gốc — xem O_NDTNN_15. (4) Xóa `NDTNN Regulatory Report Store` khỏi Section 3 Bảng Tác nghiệp/graph TB, chuyển Cụm 7 (Section 1) sang PENDING. **Đề xuất bổ sung BA:** nếu màn hình Pass-through thực sự cần hiển thị giá trị chỉ tiêu, cần yêu cầu BA bổ sung dòng "Giá trị" vào STT=18 trước khi thiết kế lại. | K_NDTNN_52-57 (Nhóm 12, đã sửa); "Giá trị" (đã loại bỏ, chờ BA xác nhận bổ sung) | Open — chờ BA xác nhận có cần bổ sung dòng "Giá trị" hay không |
| O_NDTNN_26 | **Sub-tab C Lịch sử tuân thủ (STT=13) — entity Atomic sai hoàn toàn, phát hiện khi review theo yêu cầu rà soát BA (2026-07-23):** HLD cũ dùng `Surveillance Enforcement Case` (TT.GS_HO_SO) + `Surveillance Enforcement Decision` (TT.GS_VAN_BAN_XU_LY) — BA STT=13 (6 dòng, 100% Dữ liệu tĩnh) xác nhận nguồn thật hoàn toàn khác: `PENALTY_DECISION` (Ngày quyết định, Trạng thái), `PENALTY_DECISION_SUBJECT` (Thông tin nhà đầu tư), `PENALTY_DECISION_SUBJECT_BEHAVIOR` (Nội dung/Trích yếu), `PENALTY_TYPE` (Phân loại) — cả 4 entity đều `design_status: approved` trong manifest. Đây không phải cùng 1 concept khác tên gọi — 2 bộ entity (GS_* vs PENALTY_*) là 2 luồng nghiệp vụ Thanh Tra khác nhau hoàn toàn (Surveillance case-based workflow vs Penalty decision-based workflow). BA cũng ghi rõ dòng "Mức độ" không có trường nguồn (giá trị NULL, đề xuất loại bỏ khỏi màn hình). | Đã sửa `Investor Compliance History` dùng đúng 4 entity Penalty Decision/Subject/Subject Behavior/Penalty Type — 5/6 KPI READY (K_NDTNN_192-195,197), 1 Out-of-scope (K_NDTNN_196 "Mức độ", theo đúng ghi chú BA). Cập nhật Section 1 Cụm 4, Section 3 Bảng Tác nghiệp, O_NDTNN_6. | K_NDTNN_192-197 | Closed — đã sửa đúng entity Atomic |
| O_NDTNN_27 | **Nhóm 19-43 (STT 19-43) — 25 loại báo cáo Pass-through TT51/TT96 khác nhau, cần xác nhận 25 Report Code riêng biệt — phát hiện khi rà soát toàn bộ BA 43 STT (2026-07-23):** Sau khi phát hiện 25 STT (19-43) chưa có Nhóm HLD (xem O_NDTNN_18), đã khai sinh mới toàn bộ theo đúng pattern Nhóm 12 (STT=18) — mỗi Nhóm 6 KPI (Loại/Kỳ/Mã/Tên báo cáo + Mã/Tên chỉ tiêu), 100% PENDING (Dữ liệu động), reuse chung `NDTNN Regulatory Report Store` (generic store TT51, Cụm 7). Khác Nhóm 12, mỗi Nhóm trong số 25 Nhóm này ứng với 1 loại báo cáo/tổ chức nộp khác nhau (CTCK, Ngân hàng lưu ký, Đại diện CBTT, Đại diện giao dịch, NĐTNN, SGDCK, VSDC — theo các phụ lục PLII/III/IV/V/VI/VII/VIII/IX/X-TT51/2021/TT-BTC và TT96/2020/TT-BTC) — cần xác nhận 25 Report Code riêng biệt (1 cho mỗi loại báo cáo) trong generic store trước khi go-live, không thể dùng chung 1 Report Code cho cả 25 Nhóm. | Đã khai sinh 25 Nhóm mới (Nhóm 19-43), 100% PENDING, K_NDTNN_198-347 (150 KPI, 6 KPI/Nhóm). Cần Data Modeler/BA xác nhận 25 Report Code tương ứng trong `Member Regulatory Report`/`Report Template` trước khi thiết kế lại thành READY. | K_NDTNN_198-347 | Open — chờ xác nhận 25 Report Code riêng biệt |
