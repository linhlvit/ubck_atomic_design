# DTM_GSTT_Entities — v2.3

**Phiên bản:** 2.3
**Ngày cập nhật:** 2026-09-14
**Phạm vi:** Star schema diagram theo Fact chính — GSTT module, khớp `DTM_GSTT_HLD.md` v4.15 (49/49 Nhóm)
**Thay đổi v2.7 (2026-09-26):** Bổ sung `Fact HOSE Securities Trade` và `Fact HNX Securities Trade` (mới, Fact Event grain giao dịch khớp — Data Explorer kết xuất sổ lệnh Nhóm 42/43). Nhóm 38–41 (Data Explorer) 100% reuse bảng có sẵn, không thêm entity.
**Thay đổi v2.6 (2026-09-23):** Bổ sung `Fact Investor Category Index Trading Snapshot` (mới, Nhóm 29/32 — grain Chỉ số); `Fact Investor Category Trading Snapshot` nay phục vụ Nhóm 30/31. Đánh số lại Nhóm 30→31 … 35→36 theo BA 2026-09-23 (HLD v4.23).
**Thay đổi v2.5 (2026-09-21):** Bổ sung `Fact Investor Category Trading Snapshot` (mới) — tách phân loại NĐT khỏi `Fact Stock Portfolio Snapshot`, phục vụ Nhóm 29/30 (K_GSTT_85–94).
**Thay đổi v2.4 (2026-09-16):** Đổi nguồn `Outstanding Share Quantity` (trên `Fact Stock Portfolio Snapshot`) và `Index Market Cap` (trên `Fact Index Constituent Snapshot`) từ `pc_share_statistics_hstr` (IDS) sang `listed_share_info` (VSDC `outstanding_shares`, `src_stm_code = 'VSDC_OUTSTANDING_SHARES'`). Đồng bộ hoàn toàn nguồn dữ liệu số lượng cổ phiếu lưu hành & tự do chuyển nhượng về VSDC, khắc phục dứt điểm tình trạng rỗng dữ liệu trên sàn HNX/UPCOM.
**Thay đổi v2.3:** Đổi tên `Index Total Volume`/`Index Total Value` → `Index Total Matched Volume`/`Index Total Matched Value` — review sheet Tổng hợp công thức xác nhận KLGD/GTGD của chỉ số (K_GSTT_47/48) phải loại trừ thỏa thuận, khác BA_analyst_GSTT.csv STT5.
**Thay đổi v2.2:** Bổ sung 8 measure tính sẵn theo rổ chỉ số lên `Fact Index Constituent Snapshot` (Index Total Matched Volume/Value, Index Foreign Net Volume/Value, Index Total Negotiated Volume/Value, Index Market Cap, Index Free Float Market Cap — theo yêu cầu Design, không chấp nhận Bridge thuần 3 FK). Sửa mô tả `Fact Stock Portfolio Snapshot` — nguồn Free Float đổi từ `listed_share_info` (chưa tồn tại) sang `listed_share_info`.
**Thay đổi v2.1:** Tách `Fact Index Constituent Snapshot` (Bridge Factless) khỏi `Fact Stock Portfolio Snapshot` — giải quyết fan-out do 1 mã CK thuộc N rổ chỉ số (Index Constituent Dimension trước đây là FK trực tiếp trên Fact chính). `Index Constituent Dimension` đổi grain còn 1 row/Index Code (thuần mô tả), Symbol/Floor Code/Add Date chuyển sang Fact mới.
**Thay đổi so với v1.3:** Viết lại toàn bộ — bản v1.3 (2026-06-04) theo cấu trúc HLD cũ trước v4.0 (`Fact Security Daily Market Summary`, `Corporate Bond Trading Snapshot Dimension`...) đã lỗi thời, không còn khớp với HLD hiện hành (thiết kế lại toàn bộ theo BA CSV mới, 1 Nhóm = 1 STT). Tổ chức lại theo 4 Fact chính (thay vì liệt kê rời rạc 49 Nhóm) vì phần lớn các Nhóm dùng chung `Fact Stock Portfolio Snapshot`.

---

## Fact Stock Portfolio Snapshot (phục vụ Nhóm 1–3, 5–24, 27–28, 33, 35–36, 39–41, 46–47)

Bảng trung tâm của module — 1 row / mã CK / ngày giao dịch. Phục vụ toàn bộ Tab "Danh mục CK", "Top", "Xu hướng dòng tiền" (Nhóm 1–4, 6–44, 46, 47). **[SỬA 2026-09-14]** Không còn FK rổ chỉ số — xem `Fact Index Constituent Snapshot` bên dưới cho nhu cầu phân tích theo rổ chỉ số.

```mermaid
erDiagram
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Stock_Portfolio_Snapshot : " "
    Public_Company_Dimension ||--o{ Fact_Stock_Portfolio_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Stock_Portfolio_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Stock Portfolio Snapshot | Fact Snapshot | new | Giá, khối lượng/giá trị GD, NĐT nước ngoài/tự doanh/phân loại NĐT, LNST/VCSH/P-E/P-B (PENDING). [SỬA 2026-09-14] + Free_Float_Share_Quantity (nguồn `listed_share_info`, VSDC outstanding_shares — sửa từ `listed_share_info` chưa tồn tại). Bỏ FK Index Constituent Dimension Id | 1 row / mã CK / ngày giao dịch | K_GSTT_1–32, 55–61, 64–92, 98–119, 124–125, 133–143 (xem Bảng grain Section 3.2 HLD) |
| Security Trading Snapshot Dimension | Dimension | new | Hồ sơ mô tả chứng khoán + giá hiện hành (Open/High/Low/Reference/Close) | 1 row / mã CK (SCD4A) | — |
| Public Company Dimension | Dimension | reuse | Mã CK/tên DN/ngành — conformed GSDC/QLCB/NDTNN | 1 row / mã CK (SCD4A) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày — conformed toàn hệ thống | 1 row / ngày | — |

---

## Fact Index Constituent Snapshot (phục vụ Nhóm 1, 3, 5–22, 24, 26, 28–29, 32–33, 36, 38–39 — mọi KPI theo rổ chỉ số)

**[MỚI 2026-09-14]** Bridge — tách khỏi `Fact Stock Portfolio Snapshot` để giải quyết fan-out (1 mã CK thuộc N rổ chỉ số từng gây double-count trên measure của Fact chính). Phục vụ K_GSTT_4 (chọn 1 Chỉ số), K_GSTT_62/63 (Bộ chỉ số thị trường/theo ngành) — join qua `Symbol` + `Trading Date` sang `Fact Stock Portfolio Snapshot` khi cần lấy measure theo mã CK. **[SỬA 2026-09-14, theo yêu cầu Design]** Bổ sung 8 measure tính sẵn theo Index+Date (Index Total Matched Volume/Value, Index Foreign Net Volume/Value, Index Total Negotiated Volume/Value, Index Market Cap, Index Free Float Market Cap) phục vụ K_GSTT_47-52/54/61 + mẫu số K_GSTT_74/76 — giá trị lặp lại trên mọi dòng Symbol cùng Index+Date, dùng MAX()/DISTINCT khi truy vấn.

```mermaid
erDiagram
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Index_Constituent_Snapshot : " "
    Index_Constituent_Dimension ||--o{ Fact_Index_Constituent_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Index_Constituent_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Index Constituent Snapshot | Fact Snapshot (Bridge + measure tính sẵn) | new | Thành viên rổ chỉ số theo ngày + 8 measure tính sẵn theo Index+Date (lặp lại trên mọi dòng Symbol cùng rổ) | 1 row / mã CK / rổ chỉ số / ngày giao dịch | K_GSTT_4, 47–52, 54, 61, 62–63, 74, 76 |
| Security Trading Snapshot Dimension | Dimension | reuse | Hồ sơ mô tả chứng khoán — đã thiết kế ở Nhóm 1 | 1 row / mã CK (SCD4A) | — |
| Index Constituent Dimension | Dimension | new | Mô tả rổ chỉ số (Index Code, Index Id) — [SỬA 2026-09-14] không còn chứa Symbol/Floor Code/Add Date | 1 row / Index Code | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày — conformed toàn hệ thống | 1 row / ngày | — |

---

## Fact Market Index Snapshot (phục vụ Nhóm 5–6, 24, 26, 38–39)

Diễn biến chỉ số thị trường cuối ngày — sở hữu QLKD, GSTT reuse + mở rộng.

```mermaid
erDiagram
    Market_Index_Dimension ||--o{ Fact_Market_Index_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Market_Index_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Market Index Snapshot | Fact Snapshot | partial | Điểm chỉ số, thay đổi, mã tăng/giảm/trần/sàn, KLGD/GTGD thỏa thuận — sở hữu QLKD, GSTT mở rộng 15 measure | 1 row / chỉ số thị trường (market_code) / ngày (bản ghi cuối phiên) | K_GSTT_4, 33, 35–52 |
| Market Index Dimension | Dimension | reuse | Danh mục chỉ số thị trường (VN-Index/HNX/UPCOM/VN30) — conformed sở hữu QLKD | 1 row / combo (Market Id, Market Code) (SCD4A) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày — conformed toàn hệ thống | 1 row / ngày | — |

---

## Fact Market Index Intraday (phục vụ Nhóm 5)

Diễn biến chỉ số thị trường realtime trong ngày — grain khác Fact Market Index Snapshot (theo Index Time thay vì theo ngày).

```mermaid
erDiagram
    Market_Index_Dimension ||--o{ Fact_Market_Index_Intraday : " "
    Calendar_Date_Dimension ||--o{ Fact_Market_Index_Intraday : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Market Index Intraday | Fact Snapshot | new | Giá trị GD và điểm chỉ số theo thời gian thực trong ngày | 1 row / chỉ số thị trường (market_code) / Index Time — FK Calendar Date Dimension qua Trading Date | K_GSTT_34, 45–46 |
| Market Index Dimension | Dimension | reuse | Danh mục chỉ số thị trường — conformed sở hữu QLKD | 1 row / combo (Market Id, Market Code) (SCD4A) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày — conformed toàn hệ thống | 1 row / ngày | — |

---

## Fact Security Trading Intraday (phục vụ Nhóm 34)

Biểu đồ phân tích kỹ thuật theo thời gian trong ngày — grain khác `Security Trading Snapshot Dimension` (theo Trading Timestamp thay vì 1 row/mã CK cuối ngày). `Trading Timestamp` (`trading_tms`) là cột mới bổ sung 2026-08-26 trên Atomic `Security Trading Snapshot` (nối chuỗi `trading_dt` + `' '` + `trading_time` tại tầng ODS) — `Trading Date`/`Trading Time` gốc giữ nguyên không đổi.

```mermaid
erDiagram
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Security_Trading_Intraday : " "
    Calendar_Date_Dimension ||--o{ Fact_Security_Trading_Intraday : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Security Trading Intraday | Fact Snapshot | new | Giá mở/cao/thấp/đóng cửa + khối lượng lũy kế theo từng thời điểm trong ngày | 1 row / mã CK (Symbol) / Trading Timestamp (`trading_tms`) — FK Calendar Date Dimension qua Trading Date | K_GSTT_95–99 |
| Security Trading Snapshot Dimension | Dimension | reuse | Hồ sơ mô tả chứng khoán — đã thiết kế ở Nhóm 1 | 1 row / mã CK (SCD4A) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày — conformed toàn hệ thống | 1 row / ngày | — |

---

## Fact Security Trading Daily (phục vụ Nhóm 3)

**[MỚI 2026-09-30]** Biểu đồ kỹ thuật cổ phiếu ở khung thời gian từ 1 tháng trở lên đọc nến NGÀY (Atomic `market_price_snapshot`, nguồn MDDS.JAD_TRADINGVIEWHISTORY1DAY) thay vì `Security Trading Snapshot Dimension` (1 row/mã CK cuối ngày). Grain 1 row / mã CK (Symbol) / ngày giao dịch; khung trong ngày vẫn dùng `Fact Security Trading Intraday` (Nhóm 34). Xem O_GSTT_51.

```mermaid
erDiagram
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Security_Trading_Daily : " "
    Calendar_Date_Dimension ||--o{ Fact_Security_Trading_Daily : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Security Trading Daily | Fact Snapshot | new | Giá mở/cao/thấp/đóng cửa + khối lượng của nến ngày | 1 row / mã CK (Symbol) / ngày giao dịch — FK Calendar Date Dimension qua Trading Date | K_GSTT_349–353 (Nhóm 3); reuse Nhóm 34, 47, 48 |
| Security Trading Snapshot Dimension | Dimension | reuse | Hồ sơ mô tả chứng khoán — đã thiết kế ở Nhóm 1 | 1 row / mã CK (SCD4A) | — |

---

## Fact Foreign Trading Minute Snapshot (phục vụ Nhóm 25–26)

**[BỔ SUNG 2026-09-11]** Thiết kế thật đã có từ 2026-09-04 (Resolved O_GSTT_8, Attributes + Detail Mapping + HLD đều đã READY) nhưng bị bỏ sót khỏi Entities.csv/.md — bổ sung lại cho khớp, không phải thiết kế mới.

Dòng tiền NĐT nước ngoài theo phút — grain mịn hơn `Fact Stock Portfolio Snapshot` (theo phút thay vì theo ngày). Nguồn `Securities Trade` (per-trade, sổ lệnh HOSE/HNX GROUP BY phút) — khác `Fact Security Trading Intraday` (nguồn `Security Trading Snapshot`, per-tick MDDS).

```mermaid
erDiagram
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Foreign_Trading_Minute_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Foreign_Trading_Minute_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Foreign Trading Minute Snapshot | Fact Snapshot | new | Giá trị mua/bán của NĐT nước ngoài theo phút | 1 row / mã CK (Symbol) / Trade Minute (`trade_minute_tms`) — FK Calendar Date Dimension qua Trade Date | K_GSTT_78–80 |
| Security Trading Snapshot Dimension | Dimension | reuse | Hồ sơ mô tả chứng khoán — đã thiết kế ở Nhóm 1 | 1 row / mã CK (SCD4A) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày — conformed toàn hệ thống | 1 row / ngày | — |

---

## Fact Investor Category Trading Snapshot (phục vụ Nhóm 23, 30–31, 36)

**[MỚI 2026-09-21, theo yêu cầu Data Modeler]** Tách khỏi `Fact Stock Portfolio Snapshot` để có cột vật lý `Investor Category Code` thay vì 4 cụm cột cố định (`Individual_*`/`Domestic_Institution_*`/`Proprietary_*`/`Foreign_*`) + CASE WHEN switch tại tầng BI. Nguồn `Securities Trade.Buy/Sell Investor Type Code` (Cá nhân/Tổ chức trong nước, phân nhánh HOSE/HNX) + `Buy/Sell Client House Classification Code='30'` (Tự doanh) + `Buy/Sell Foreign Investor Type Code IN ('10','20')` (Nước ngoài). Không đổi grain/cột của `Fact Stock Portfolio Snapshot` — Nhóm 21/25/27/36 tiếp tục dùng nguyên các cột đã có, không bị ảnh hưởng.

```mermaid
erDiagram
    Security_Trading_Snapshot_Dimension ||--o{ Fact_Investor_Category_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Investor_Category_Trading_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Investor Category Trading Snapshot | Fact Snapshot | new | Giá trị mua/bán theo Phân loại NĐT (Cá nhân/Tổ chức trong nước/Tự doanh/Nước ngoài), tách riêng khớp lệnh/thỏa thuận | 1 row / mã CK / ngày giao dịch / Phân loại NĐT | K_GSTT_85, 90–92, 153–158 (86–89/93/94/152 DEPRECATED) |
| Security Trading Snapshot Dimension | Dimension | reuse | Hồ sơ mô tả chứng khoán — đã thiết kế ở Nhóm 1 | 1 row / mã CK (SCD4A) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày — conformed toàn hệ thống | 1 row / ngày | — |

---

## Fact Investor Category Index Trading Snapshot (phục vụ Nhóm 30, 32)

**[MỚI 2026-09-23, Data Modeler duyệt]** Giao dịch theo phân loại NĐT ở cấp **Chỉ số** — tách riêng khỏi `Fact Investor Category Trading Snapshot` (cấp Mã CK) để không SUM runtime lệch hạt. Chứa 6 measure GT (Tổng/Khớp lệnh/Thỏa thuận × Mua/Bán) và 3 measure giá chỉ số (broadcast trên 4 dòng Phân loại NĐT — truy vấn dùng MAX). Xem HLD Cụm 1d.

```mermaid
erDiagram
    Index_Constituent_Dimension ||--o{ Fact_Investor_Category_Index_Trading_Snapshot : " "
    Calendar_Date_Dimension ||--o{ Fact_Investor_Category_Index_Trading_Snapshot : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Investor Category Index Trading Snapshot | Fact Snapshot | new | GT mua/bán theo Phân loại NĐT theo rổ chỉ số + điểm/thay đổi/% thay đổi chỉ số | 1 row / Index Code / ngày giao dịch / Phân loại NĐT | K_GSTT_85, 35, 38, 39, 161–169 |
| Index Constituent Dimension | Dimension | reuse | Mô tả rổ chỉ số — đã thiết kế ở Nhóm 1 | 1 row / Index Code (SCD4A) | — |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày — conformed toàn hệ thống | 1 row / ngày | — |

---

## Fact Major Shareholder Ownership Snapshot (phục vụ Nhóm 35, 38)

**[MỚI 2026-09-25, GSTT Nhóm 34 — BA cập nhật nguồn VSDC major_shareholder]** Thay nguồn IDS `Public Company Shareholding` cho Nhóm 34 bằng VSDC `major_shareholder` (Atomic `major_shareholder_ownership`, mapping md) — số liệu theo kỳ đầu/cuối, chọn kỳ theo ngày tham số. `Operational Public Company Shareholding` giữ nguyên cho Nhóm 37.

```mermaid
erDiagram
    Fact_Major_Shareholder_Ownership_Snapshot {
        string Snapshot_Date_Dimension_Id FK
        string Public_Company_Dimension_Id FK
        string Ticker_Symbol
        string Major_Shareholder_Ownership_Id
        string Major_Shareholder_Name
        bigint Ownership_Share_Quantity
        decimal Ownership_Ratio
        date Ownership_Update_Date
        string Position_Code
        string Source_System_Code
    }
    Calendar_Date_Dimension ||--o{ Fact_Major_Shareholder_Ownership_Snapshot : "Snapshot_Date_Dimension_Id"
    Public_Company_Dimension ||--o{ Fact_Major_Shareholder_Ownership_Snapshot : "Public_Company_Dimension_Id"
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Major Shareholder Ownership Snapshot | Fact Snapshot | new | Sở hữu cổ đông lớn theo ngày tham số — mốc as-of chọn theo từng mã [SỬA 2026-10-01] (Sở hữu NN/trong nước đọc từ Fact Public Company Foreign Ownership Snapshot — NDTNN, O_GSTT_50; `position_code` chỉ còn phục vụ Nhóm 38) | 1 row / mã CK × cổ đông lớn × ngày (mốc as-of của mã) | K_GSTT_100–103, 177 (Nhóm 35); K_GSTT_100–104, 177, 178 (Nhóm 38) |

---

## Operational Public Company Insider Ownership (phục vụ Nhóm 35)

**[MỚI 2026-10-01, GSTT Nhóm 35 — BA mapping lại]** Danh sách người nội bộ của công ty đại chúng (vai trò `NNB` — IDS `company_entity_role`) kèm chức vụ (`positions`) và sở hữu (`company_shareholding`). Bảng Tác nghiệp current-state (BA không có tham số ngày; Atomic `pc_shareholding`/`legal_entity_position` là SCD4A) — Data Modeler duyệt 2026-10-01. Không có quan hệ FK Star Schema; lọc theo mã cổ phiếu qua `Equity Ticker Symbol`.

```mermaid
erDiagram
    Operational_Public_Company_Insider_Ownership {
        string Public_Company_Entity_Role_Code PK
        string Public_Company_Code
        string Equity_Ticker_Symbol
        string Legal_Entity_Code
        string Legal_Entity_Name
        bigint Ownership_Quantity
        decimal Ownership_Ratio_Percentage
        date Ownership_Date
        string Position_Code
        string Position_Name
        string Source_System_Code
    }
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Operational Public Company Insider Ownership | Operational | new | Danh sách người nội bộ + chức vụ + sở hữu (nguồn IDS) | 1 row / (công ty đại chúng × người nội bộ NNB hiện hành) | K_GSTT_354–358 |

---

## Fact HOSE Securities Trade (phục vụ Nhóm 43)

**[MỚI 2026-09-26, GSTT Nhóm 42]** Kết xuất nguyên văn sổ lệnh khớp HOSE cho Data Explorer — nguồn Atomic `securities_trade` (nhánh `ORDERTRADE.TRADE_BOOK_HOSE`). Fact Event, FK duy nhất là ngày giao dịch (role-playing `Trade Date Dimension Id`); các cột sổ lệnh là degenerate attribute. Có cột PII — xem O_GSTT_36 (HLD Section 5).

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_HOSE_Securities_Trade : "Trade_Date_Dimension_Id"
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact HOSE Securities Trade | Fact Event | new | Sổ lệnh khớp HOSE — pass-through toàn bộ cột BA yêu cầu (giá/KL/GT khớp, thông tin lệnh mua/bán, CTCK, tài khoản, loại NĐT) | 1 row / giao dịch khớp (Securities Trade Code) / Trade Date | K_GSTT_181–226 |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày — conformed toàn hệ thống | 1 row / ngày | — |

---

## Fact HNX Securities Trade (phục vụ Nhóm 44)

**[MỚI 2026-09-26, GSTT Nhóm 43]** Kết xuất nguyên văn sổ lệnh khớp HNX cho Data Explorer — nguồn Atomic `securities_trade` (nhánh `ORDERTRADE.TRADE_BOOK_HNX`). Fact Event, FK duy nhất là ngày giao dịch (role-playing `Trade Date Dimension Id`); các cột sổ lệnh là degenerate attribute. Có cột PII — xem O_GSTT_36 (HLD Section 5).

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_HNX_Securities_Trade : "Trade_Date_Dimension_Id"
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact HNX Securities Trade | Fact Event | new | Sổ lệnh khớp HNX — pass-through toàn bộ cột BA yêu cầu (giá/KL/GT khớp, thông tin lệnh mua/bán, CTCK, tài khoản, loại NĐT) | 1 row / giao dịch khớp (Securities Trade Code) / Trade Date | K_GSTT_227–262 |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày — conformed toàn hệ thống | 1 row / ngày | — |

---

## Fact HNX Securities Order (phục vụ Nhóm 45)

**[MỚI 2026-09-29, GSTT Nhóm 45]** Kết xuất nguyên văn sổ lệnh order book HNX cho Data Explorer — nguồn Atomic `securities_order` (nhánh `ORDERTRADE.ORDER_BOOK_HNX`). Fact Event, FK duy nhất là ngày giao dịch (role-playing `Trade Date Dimension Id`); các cột sổ lệnh là degenerate attribute. Có cột dữ liệu tài khoản (PII) — xem O_GSTT_36.

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_HNX_Securities_Order : "Trade_Date_Dimension_Id"
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact HNX Securities Order | Fact Event | new | Order book HNX — pass-through 30 cột BA yêu cầu | 1 row / lệnh (Securities Order Code) / Trade Date | K_GSTT_266–295 |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày — conformed toàn hệ thống | 1 row / ngày | — |

---

## Fact HOSE Securities Order (phục vụ Nhóm 46)

**[MỚI 2026-09-29, GSTT Nhóm 46]** Kết xuất nguyên văn sổ lệnh order book HOSE cho Data Explorer — nguồn Atomic `securities_order` (nhánh `ORDERTRADE.ORDER_BOOK_HOSE`). Fact Event, FK duy nhất là ngày giao dịch (role-playing `Trade Date Dimension Id`); các cột sổ lệnh là degenerate attribute. Có cột dữ liệu tài khoản (PII) — xem O_GSTT_36.

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_HOSE_Securities_Order : "Trade_Date_Dimension_Id"
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact HOSE Securities Order | Fact Event | new | Order book HOSE — pass-through 45 cột BA yêu cầu | 1 row / lệnh (Securities Order Code) / Trade Date | K_GSTT_296–340 |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày — conformed toàn hệ thống | 1 row / ngày | — |

---
