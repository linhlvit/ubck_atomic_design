# HNX HLD — Overview

**Source system:** HNX (Dữ liệu Sở Giao dịch Chứng khoán Hà Nội — vùng staging `uat_hnx_stg`)
**Mô tả:** HNX cung cấp các báo cáo và sổ lệnh của thị trường do Sở quản lý: kết quả đấu giá cổ phiếu, đấu thầu/niêm yết trái phiếu Chính phủ, chào bán/đăng ký giao dịch trái phiếu doanh nghiệp riêng lẻ, quyết định thay đổi niêm yết, thị phần môi giới và sổ lệnh trái phiếu (Outright/Repo/Repo2). Các entity `Share Auction Result`, `Listing Status Change`, `Brokerage Market Share` dùng chung với HOSE; `listed_securities_list` bổ sung nguồn cho entity `Listed Share Information` của VSDC.

---

## Tổng quan Atomic Entities

| Tier | Atomic Entity | BCV Core Object | BCV Concept | table_type | Source Table(s) | Ghi chú |
|---|---|---|---|---|---|---|
| T1 | Additional Gov Bond Listing | Documentation | [Documentation] Regulatory Report | Fact Snapshot | HNX.gov_bond_additional_listing | Sự kiện niêm yết bổ sung trái phiếu Chính phủ |
| T1 | Bond Order Book | Transaction | [Transaction] Financial Market Transaction | Fact Snapshot | HNX.outright_order_book, HNX.repo_order_book, HNX.repo2_order_book | Gộp 3 sổ lệnh, phân biệt `order_book_type` |
| T1 | Bond Trading Registration Status | Documentation | [Documentation] Regulatory Report | Fact Snapshot | HNX.registration_status_change | Trạng thái đăng ký giao dịch trái phiếu |
| T1 | Brokerage Market Share | Documentation | [Documentation] Regulatory Report | Fact Snapshot | HNX.brokerage_market_share, HOSE.brokerage_market_share | Dùng chung HNX + HOSE |
| T1 | Gov Bond Bidding Result | Documentation | [Documentation] Regulatory Report | Fact Snapshot | HNX.gov_bond_offering | Kết quả đấu thầu trái phiếu Chính phủ |
| T1 | Gov Bond Listing | Documentation | [Documentation] Regulatory Report | Fact Snapshot | HNX.gov_bond_listed_list | Danh sách trái phiếu Chính phủ niêm yết |
| T1 | Listing Status Change | Documentation | [Documentation] Regulatory Report | Fact Snapshot | HNX.listing_status_change, HOSE.listing_status_change | Dùng chung HNX + HOSE |
| T1 | Private Corp Bond Offering | Documentation | [Documentation] Regulatory Report | Fact Snapshot | HNX.private_corp_bond_offering | Chào bán trái phiếu doanh nghiệp riêng lẻ |
| T1 | Private Corp Bond Registration | Documentation | [Documentation] Regulatory Report | Fact Snapshot | HNX.private_corp_bond_registration | Đăng ký giao dịch trái phiếu doanh nghiệp |
| T1 | Private Corp Bond Service Organization | Documentation | [Documentation] Regulatory Report | Relative | HNX.private_corp_bond_service_orgs | BM 34 — tổ chức tư vấn, đại lý phát hành, đại lý lưu ký, đại diện NSH và thông tin TPDNRL tương ứng |
| T1 | Private Corp Bond Trading Summary | Documentation | [Documentation] Regulatory Report | Fact Snapshot | HNX.private_corp_bond_trading | Chỉ tiêu giao dịch thị trường |
| T1 | Securities Order | Communication | [Communication] Financial Market Order | Fact Append | HNX.order_book, HOSE.order_book | Sổ lệnh chi tiết từng event lệnh. Dùng chung HNX + HOSE, tham khảo thiết kế ORDERTRADE |
| T1 | Security Market Capitalization | Documentation | [Documentation] Regulatory Report | Fact Snapshot | HNX.market_capitalization | BM 42 — giá, giao dịch và vốn hóa theo mã chứng khoán |
| T1 | Share Auction Result | Documentation | [Documentation] Regulatory Report | Fact Snapshot | HNX.share_auction, HOSE.share_auction | Dùng chung HNX + HOSE |
| T2 | Securities Trade | Transaction | [Transaction] Financial Market Transaction | Fact Append | HNX.trade_book, HOSE.trade_book | Sổ khớp chi tiết từng lần khớp. Dùng chung HNX + HOSE, liên kết BK về `Securities Order` |

**Tổng: 15 Atomic entities** (14 Tier 1, 1 Tier 2)
*(Trong đó: 1 bảng nguồn extend entity của source khác — `HNX.listed_securities_list` → entity `Listed Share Information` (định nghĩa ở VSDC) — không tạo mới)*

---

## Diagram Phân tầng Dependencies (Mermaid)

```mermaid
graph TD
    subgraph T1["Tier 1 — Independent Entities"]
        E1["Share Auction Result"]
        E2["Gov Bond Bidding Result"]
        E3["Gov Bond Listing"]
        E4["Additional Gov Bond Listing"]
        E5["Private Corp Bond Offering"]
        E6["Private Corp Bond Registration"]
        E7["Bond Trading Registration Status"]
        E8["Private Corp Bond Trading Summary"]
        E9["Listing Status Change"]
        E10["Brokerage Market Share"]
        E11["Bond Order Book"]
        E12["Private Corp Bond Service Organization"]
        E13["Security Market Capitalization"]
        E14["Securities Order"]
    end

    subgraph T2["Tier 2 — Liên kết BK về Tier 1"]
        E15["Securities Trade"]
    end

```

---

## Quyết định thiết kế chính

| # | Quyết định | Lý do |
|---|---|---|
| D-01 | Tất cả entity HNX xếp Tier 1, không FK nghiệp vụ giữa các entity | Bảng staging phẳng, không có bảng master; join theo `bond_code`/`ticker_symbol` thực hiện ở Gold |
| D-02 | Gộp `outright_order_book`, `repo_order_book`, `repo2_order_book` thành 1 entity `Bond Order Book`, phân biệt bằng `order_book_type` (ETL-derived) | Cấu trúc 3 bảng gần giống nhau (≈ 42/50/55 cột, trùng ~40 cột); cột đặc thù Repo/Repo2/Outright NULL phía còn lại |
| D-03 | Entity dùng chung HNX + HOSE (`Share Auction Result`, `Listing Status Change`, `Brokerage Market Share`) định nghĩa ở HNX; HOSE bổ sung `source_table` | HNX là source đầu tiên chứa các bảng này (quy tắc không tạo dòng trùng) |
| D-04 | Không dùng prefix `HNX` trong tên entity | Tên entity dùng BCV Term/tên nghiệp vụ, đồng nhất với MDDS D-04 |
| D-05 | Toàn bộ bảng báo cáo/sổ lệnh → `Fact Snapshot` (chỉ định Data Modeler 2026-10-18) | Cùng `VSDC_HLD_Overview` D-05 |
| D-06 | `order_book` (HNX + HOSE) → 1 entity `Securities Order`; `trade_book` (HNX + HOSE) → 1 entity `Securities Trade`; cả hai `Fact Append`. Ngoại lệ của D-05 | Tham khảo thiết kế ORDERTRADE (`Securities Order` / `Securities Trade`, D-01…D-03): 1 dòng = 1 event lệnh / 1 lần khớp, insert-only; khác `Fact Snapshot` của bảng báo cáo theo kỳ |
| D-07 | `Securities Order` và `Bond Order Book` là 2 entity riêng | `Bond Order Book` là sổ lệnh trái phiếu dạng báo cáo (outright/repo/repo2); `order_book` là sổ lệnh chi tiết dạng feed KRX cho mọi loại chứng khoán |
| D-08 | `Securities Trade` lưu cả bên mua và bên bán trên cùng 1 dòng; độc lập, không liên kết FK tới `Securities Order` hay bảng khác (Data Modeler chốt 2026-11-02) | Tham khảo ORDERTRADE D-03/D-04: giữ đúng grain nguồn, khối lượng lớn; resolve surrogate ở Gold nếu cần |
| D-09 | `Securities Order` và `Securities Trade` dùng chung HNX + HOSE, định nghĩa ở HNX; HOSE bổ sung `source_table`; phân biệt nguồn qua `src_stm_code` | Quy tắc D-03; ORDERTRADE D-01/D-02 |
| D-10 | `market_capitalization` → entity riêng `Security Market Capitalization`, `Fact Snapshot` | Báo cáo BM 42 theo mã chứng khoán × ngày, có chỉ tiêu vốn hóa và tỷ trọng; cùng nhóm Regulatory Report với các báo cáo HNX khác |

---

#### 7a. Bảng tổng quan Atomic entities

| Tier | BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | Table Type | BCV Term |
|---|---|---|---|---|---|---|---|---|---|
| T1 | Documentation | [Documentation] Regulatory Report | Documentation | gov_bond_additional_listing | Append | Niêm yết bổ sung/thay đổi niêm yết trái phiếu Chính phủ | Additional Gov Bond Listing | Fact Snapshot | Regulatory Report (9297) — Core Object Documentation theo chỉ định Data Modeler |
| T1 | Transaction | [Transaction] Financial Market Transaction | Transaction | outright_order_book, repo_order_book, repo2_order_book | Append | Sổ lệnh trái phiếu Outright/Repo/Repo2 | Bond Order Book | Fact Snapshot | Financial Market Transaction (13339) — Core Object Transaction theo chỉ định Data Modeler |
| T1 | Documentation | [Documentation] Regulatory Report | Documentation | registration_status_change | Append | Trạng thái đăng ký giao dịch trái phiếu | Bond Trading Registration Status | Fact Snapshot | Regulatory Report (9297) — Core Object Documentation theo chỉ định Data Modeler |
| T1 | Documentation | [Documentation] Regulatory Report | Documentation | brokerage_market_share | Append | Thị phần môi giới theo quý | Brokerage Market Share | Fact Snapshot | Regulatory Report (9297) — Core Object Documentation theo chỉ định Data Modeler |
| T1 | Documentation | [Documentation] Regulatory Report | Documentation | gov_bond_offering | Append | Kết quả đấu thầu trái phiếu Chính phủ | Gov Bond Bidding Result | Fact Snapshot | Regulatory Report (9297) — Core Object Documentation theo chỉ định Data Modeler |
| T1 | Documentation | [Documentation] Regulatory Report | Documentation | gov_bond_listed_list | Append | Danh sách trái phiếu Chính phủ niêm yết | Gov Bond Listing | Fact Snapshot | Regulatory Report (9297) — Core Object Documentation theo chỉ định Data Modeler |
| T1 (extend) | Documentation | [Documentation] Regulatory Report | Documentation | listed_securities_list | Append | Danh sách chứng khoán niêm yết HNX (số lượng niêm yết, giá tham chiếu) — entity `Listed Share Information` định nghĩa ở VSDC | Listed Share Information | Fact Snapshot | Regulatory Report (9297) — Core Object Documentation theo chỉ định Data Modeler |
| T1 | Documentation | [Documentation] Regulatory Report | Documentation | listing_status_change | Append | Quyết định thay đổi niêm yết | Listing Status Change | Fact Snapshot | Regulatory Report (9297) — Core Object Documentation theo chỉ định Data Modeler |
| T1 | Documentation | [Documentation] Regulatory Report | Documentation | private_corp_bond_offering | Append | Chào bán trái phiếu doanh nghiệp riêng lẻ | Private Corp Bond Offering | Fact Snapshot | Regulatory Report (9297) — Core Object Documentation theo chỉ định Data Modeler |
| T1 | Documentation | [Documentation] Regulatory Report | Documentation | private_corp_bond_registration | Append | Đăng ký giao dịch trái phiếu doanh nghiệp riêng lẻ | Private Corp Bond Registration | Fact Snapshot | Regulatory Report (9297) — Core Object Documentation theo chỉ định Data Modeler |
| T1 | Documentation | [Documentation] Regulatory Report | Documentation | private_corp_bond_trading | Append | Chỉ tiêu thống kê giao dịch trái phiếu doanh nghiệp | Private Corp Bond Trading Summary | Fact Snapshot | Regulatory Report (9297) — Core Object Documentation theo chỉ định Data Modeler |
| T1 | Documentation | [Documentation] Regulatory Report | Documentation | share_auction | Append | Kết quả đấu giá cổ phiếu | Share Auction Result | Fact Snapshot | Regulatory Report (9297) — Core Object Documentation theo chỉ định Data Modeler |
| T1 | Documentation | [Documentation] Regulatory Report | Documentation | private_corp_bond_service_orgs | Update | BM 34 — danh sách CTCK là tổ chức tư vấn, đại lý phát hành, đại lý lưu ký, đại diện người sở hữu trái phiếu và thông tin TPDNRL tương ứng | Private Corp Bond Service Organization | Relative | (1) Regulatory Report (9297) — báo cáo theo quy định, cùng nhóm với các báo cáo TPDNRL HNX khác. (2) Cấu trúc trường: mã trái phiếu, tổ chức phát hành, khối lượng, tài sản bảo đảm và các cột tên tổ chức dịch vụ — grain là 1 trái phiếu theo kỳ báo cáo, không phải Involved Party. (3) Chọn Regulatory Report; không tách Involved Party vì các cột tổ chức dịch vụ là Text trong báo cáo |
| T1 | Communication | [Communication] Financial Market Order | Financial Markets Trading | order_book | Update | Sổ lệnh chi tiết HNX — mỗi bản ghi là 1 event lệnh trên sàn HNX (cổ phiếu/UPCOM/TPCP/TPDN/phái sinh); có Iceberg order, Stop order và Quote Request theo chuẩn KRX. Kèm sổ lệnh HOSE (`HOSE.order_book`) cùng cấu trúc | Securities Order | Fact Append | (1) Financial Market Order (8539) — lệnh yêu cầu thực hiện giao dịch công cụ tài chính khi thỏa điều kiện định trước. (2) Cột nguồn: mã lệnh, loại/điều kiện lệnh, giá, khối lượng, thành viên, tài khoản, trạng thái — mỗi dòng là 1 event lệnh. (3) Chọn Financial Market Order (cùng term đã dùng cho ORDERTRADE); phân biệt sàn qua `src_stm_code` |
| T1 | Documentation | [Documentation] Regulatory Report | Documentation | market_capitalization | Update | BM 42 — giá tham chiếu/mở/đóng/cao/thấp, khối lượng và giá trị giao dịch (khớp lệnh, thỏa thuận; lô chẵn, lô lẻ), khối lượng lưu hành, vốn hóa và tỷ trọng theo mã chứng khoán | Security Market Capitalization | Fact Snapshot | (1) Regulatory Report (9297). BCV không có term "Market Capitalization" riêng. (2) Cột nguồn tổng hợp theo mã chứng khoán × ngày báo cáo, dạng báo cáo thống kê. (3) Chọn Regulatory Report theo chỉ định Data Modeler cho báo cáo sàn |
| T2 | Transaction | [Transaction] Financial Market Transaction | Financial Markets Trading | trade_book | Update | Sổ khớp chi tiết HNX — mỗi bản ghi là 1 lần khớp thành công, chứa đồng thời thông tin bên mua và bên bán; có Spread legs cho giao dịch 2 vế. Kèm sổ khớp HOSE (`HOSE.trade_book`) cùng cấu trúc | Securities Trade | Fact Append | (1) Financial Market Transaction (13339) — giao dịch điều chỉnh vị thế nắm giữ công cụ tài chính. (2) Cột nguồn: số hiệu khớp, giá, khối lượng, thông tin bên mua/bán — mỗi dòng là 1 lần khớp. (3) Chọn Financial Market Transaction (cùng term đã dùng cho ORDERTRADE) |

#### 7b. Diagram Atomic tổng (Mermaid)

```mermaid
erDiagram
    Share_Auction_Result {
        string share_auction_result_id PK
    }
    Gov_Bond_Bidding_Result {
        string gov_bond_bidding_result_id PK
    }
    Gov_Bond_Listing {
        string gov_bond_listing_id PK
    }
    Additional_Gov_Bond_Listing {
        string additional_gov_bond_listing_id PK
    }
    Private_Corp_Bond_Offering {
        string private_corp_bond_offering_id PK
    }
    Private_Corp_Bond_Registration {
        string private_corp_bond_registration_id PK
    }
    Bond_Trading_Registration_Status {
        string bond_trading_registration_status_id PK
    }
    Private_Corp_Bond_Trading_Summary {
        string private_corp_bond_trading_summary_id PK
    }
    Listing_Status_Change {
        string listing_status_change_id PK
    }
    Brokerage_Market_Share {
        string brokerage_market_share_id PK
    }
    Bond_Order_Book {
        string bond_order_book_id PK
    }
    Private_Corp_Bond_Service_Organization {
        string private_corp_bond_service_organization_id PK
    }
    Security_Market_Capitalization {
        string security_market_capitalization_id PK
    }
    Securities_Order {
        string securities_order_id PK
        string securities_order_code BK
    }
    Securities_Trade {
        string securities_trade_id PK
        string buy_securities_order_code "FK-BK → Securities Order"
        string sell_securities_order_code "FK-BK → Securities Order"
    }

```

#### 7c. Bảng Classification Value

| Source Table | Mô tả | BCV Term | Xử lý Atomic |
|---|---|---|---|
| — | Không có Classification Value scheme | — | Các cột phân loại giữ dạng Text |

#### 7d. Junction Tables

Không có junction table.

#### 7e. Điểm cần xác nhận

| # | Tier | Câu hỏi | Ảnh hưởng |
|---|---|---|---|
| 1 | T1 | `Share Auction Result`, `Listing Status Change`, `Brokerage Market Share` gộp HNX + HOSE vào 1 entity | Có thể phải tách entity theo sàn nếu cấu trúc phát sinh khác biệt |
| 2 | T1 | `Bond Order Book` gộp 3 bảng, nhiều cột NULL theo loại sổ lệnh | Nullable, ETL pattern theo `order_book_type` |
| 3 | T1 | `HNX.listed_securities_list` bổ sung nguồn cho `Listed Share Information` | Xem `VSDC_HLD_Overview` 7e #3 |
| 4 | T1/T2 | `order_book` và `trade_book` (HNX, HOSE) có Source Table Change Mode = `Update` (mặc định, nguồn không có cột created/updated) nhưng `Securities Order`/`Securities Trade` là `Fact Append` | Cần xác nhận nguồn chỉ thêm mới (đổi Change Mode thành `Append` theo `trade_date`) hay có drop & reload |
| 5 | T1 | `HNX.order_book` có thể chứa lệnh trái phiếu (BDX/HCX) trùng nội dung với `Bond Order Book` (outright/repo/repo2) | Cần xác nhận phạm vi: giữ 2 entity độc lập hay lọc loại chứng khoán |
| 6 | T1/T2 | Cấu trúc `order_book`/`trade_book` mới dùng tên cột theo chuẩn KRX thô (VD `ORDER_RECEPTION_NUMBER`, `REPLACE_CANCEL`, `AUTOMATED_CANCEL`, HOSE `TRADE_NO`, `BUY_BRK_NO`) khác tên cột ORDERTRADE cũ; mô tả cột chỉ tái sử dụng được theo tên cũ | LLD cần đối chiếu từng cột; 5 cột kỹ thuật `YEAR/MONTH/DAY/DS_*` chưa có mô tả |
| 7 | T1 | `Securities Order`/`Securities Trade` dùng chung HNX + HOSE, nhiều cột chỉ có ở 1 sàn (nullable); cột Account PIN (`PIN`) cần quyết định mask | Có thể phải tách entity theo sàn; ảnh hưởng ETL và governance |
| 8 | T1 | `Security Market Capitalization` (HNX) có nội dung giá/giao dịch theo mã × ngày gần với `Security Trading Snapshot` của MDDS | Cần xác nhận không trùng; hiện giữ riêng vì là báo cáo BM 42 |
| 9 | T2 | `Securities Trade` (khớp lệnh HNX/HOSE từ sổ khớp) cùng BCV Concept `Financial Market Transaction` và cùng `Fact Append` với `Security Match Log` của MDDS (tick khớp lệnh) | Cần xác nhận hai nguồn là hai entity độc lập (sổ khớp có thông tin bên mua/bán) hay hợp nhất |

#### 7f. Bảng ngoài scope

| Nhóm | Source Table | Mô tả bảng nguồn | Lý do ngoài scope |
|---|---|---|---|
| Shared Entity | listed_securities_list | Danh sách chứng khoán niêm yết HNX | Dùng entity `Listed Share Information` (định nghĩa ở VSDC) — chỉ bổ sung `source_table`, không tạo entity mới tại HNX |

---

## Entities

> Single source of truth cho metadata entity. `aggregate_atomic.py` parse section này để sinh `atomic_entities.yaml`.

### 1. Additional Gov Bond Listing
**Tier:** 1 | **Source:** `HNX.gov_bond_additional_listing` | **BCV Concept:** [Documentation] Regulatory Report | **BCO:** Documentation | **Table Type:** Fact Snapshot
**Domain Prefix:** (none)
**Description:** Sự kiện niêm yết bổ sung hoặc thay đổi niêm yết của trái phiếu Chính phủ: mã trái phiếu, loại, trạng thái, khối lượng, mệnh giá và ngày thay đổi niêm yết.

**Grain:** 1 dòng = 1 mã trái phiếu × 1 trạng thái niêm yết × 1 ngày thay đổi.

**Attributes chính:** `bond_code`, trạng thái niêm yết, ngày thay đổi (BK), loại trái phiếu, khối lượng, mệnh giá, tháng báo cáo.

### 2. Bond Order Book
**Tier:** 1 | **Source:** `HNX.outright_order_book`, `HNX.repo_order_book`, `HNX.repo2_order_book` | **BCV Concept:** [Transaction] Financial Market Transaction | **BCO:** Transaction | **Table Type:** Fact Snapshot
**Domain Prefix:** (none)
**Description:** Sổ lệnh giao dịch trái phiếu tại HNX theo 3 phương thức Outright, Repo và Repo2: thông tin lệnh, trái phiếu, giá, khối lượng, bên bán, bên mua và thông tin thanh toán.

**Grain:** 1 dòng = 1 lệnh (số hiệu lệnh) × 1 loại sổ lệnh × 1 ngày giao dịch.

**Attributes chính:** `order_nbr` (BK), `order_book_type` (ETL-derived), mã trái phiếu, loại/chiều/trạng thái lệnh, giá, lợi suất, khối lượng, thành viên mua/bán, các cột Repo/Repo2 (kỳ hạn, lãi suất, coupon, thanh toán lần 1/2).

### 3. Bond Trading Registration Status
**Tier:** 1 | **Source:** `HNX.registration_status_change` | **BCV Concept:** [Documentation] Regulatory Report | **BCO:** Documentation | **Table Type:** Fact Snapshot
**Domain Prefix:** (none)
**Description:** Trạng thái đăng ký giao dịch của trái phiếu: mã trái phiếu, tổ chức phát hành, mệnh giá, khối lượng đăng ký giao dịch hiện tại, ngày giao dịch đầu/cuối và trạng thái đăng ký.

**Grain:** 1 dòng = 1 mã trái phiếu × 1 trạng thái đăng ký giao dịch × 1 kỳ báo cáo.

**Attributes chính:** `bond_code`, trạng thái đăng ký giao dịch (BK ghép), mệnh giá, khối lượng, ngày giao dịch đầu/cuối.

### 4. Brokerage Market Share
**Tier:** 1 | **Source:** `HNX.brokerage_market_share`, `HOSE.brokerage_market_share` | **BCV Concept:** [Documentation] Regulatory Report | **BCO:** Documentation | **Table Type:** Fact Snapshot
**Domain Prefix:** (none)
**Description:** Thị phần môi giới của từng công ty chứng khoán thành viên theo quý: tên công ty, mã thành viên, tổng giá trị giao dịch, thị phần theo giá trị và phân loại.

**Grain:** 1 dòng = 1 thành viên môi giới × 1 quý × 1 sàn (nguồn).

**Attributes chính:** `sc_member_code` (BK), tên công ty, tổng giá trị giao dịch, thị phần theo giá trị, phân loại, quý báo cáo, ETL-derived `src_stm_code`.

### 5. Gov Bond Bidding Result
**Tier:** 1 | **Source:** `HNX.gov_bond_offering` | **BCV Concept:** [Documentation] Regulatory Report | **BCO:** Documentation | **Table Type:** Fact Snapshot
**Domain Prefix:** (none)
**Description:** Kết quả đấu thầu phát hành trái phiếu Chính phủ theo đợt: phương thức đấu thầu, mã trái phiếu, tổ chức phát hành, kỳ hạn, giá trị gọi thầu, đặt thầu, trúng thầu và lãi suất.

**Grain:** 1 dòng = 1 đợt đấu thầu × 1 mã trái phiếu.

**Attributes chính:** `bidding_session` (BK), phương thức đấu thầu, mã trái phiếu, loại trái phiếu, ngày/phương thức phát hành, giá trị gọi/đặt/trúng thầu, lãi suất danh nghĩa/trúng thầu.

### 6. Gov Bond Listing
**Tier:** 1 | **Source:** `HNX.gov_bond_listed_list` | **BCV Concept:** [Documentation] Regulatory Report | **BCO:** Documentation | **Table Type:** Fact Snapshot
**Domain Prefix:** (none)
**Description:** Danh sách trái phiếu Chính phủ niêm yết tại HNX: mã, tổ chức phát hành, loại, khối lượng niêm yết, kỳ hạn, hình thức trả lãi, lãi suất, ngày giao dịch đầu tiên và trạng thái.

**Grain:** 1 dòng = 1 mã trái phiếu niêm yết × 1 kỳ báo cáo.

**Attributes chính:** `bond_code` (BK), loại trái phiếu, khối lượng niêm yết, kỳ hạn/kỳ hạn còn lại, hình thức/loại hình trả lãi, lãi suất, trạng thái.

### 7. Listing Status Change
**Tier:** 1 | **Source:** `HNX.listing_status_change`, `HOSE.listing_status_change` | **BCV Concept:** [Documentation] Regulatory Report | **BCO:** Documentation | **Table Type:** Fact Snapshot
**Domain Prefix:** (none)
**Description:** Quyết định thay đổi niêm yết chứng khoán tại Sở Giao dịch: số và ngày quyết định, số lượng/giá trị niêm yết mới, niêm yết bổ sung, hủy niêm yết, chuyển sàn, ngày hiệu lực và lý do.

**Grain:** 1 dòng = 1 quyết định × 1 mã chứng khoán × 1 sàn (nguồn).

**Attributes chính:** `decision_nbr`, `decision_dt`, `ticker_symbol` (BK ghép), số lượng và giá trị niêm yết, ngày hiệu lực, ngày giao dịch đầu/cuối, lý do hủy/chuyển, ETL-derived `src_stm_code`.

### 8. Private Corp Bond Offering
**Tier:** 1 | **Source:** `HNX.private_corp_bond_offering` | **BCV Concept:** [Documentation] Regulatory Report | **BCO:** Documentation | **Table Type:** Fact Snapshot
**Domain Prefix:** (none)
**Description:** Thông tin chào bán trái phiếu doanh nghiệp riêng lẻ: thị trường, ngày đăng tin, tổ chức phát hành, loại hình và ngành doanh nghiệp, mã trái phiếu, kỳ hạn, khối lượng chào bán, mệnh giá, lãi suất phát hành và các cờ điều kiện.

**Grain:** 1 dòng = 1 thông báo chào bán × 1 mã trái phiếu × 1 thị trường.

**Attributes chính:** `bond_code`, thị trường, ngày đăng tin (BK ghép), tổ chức phát hành, kỳ hạn, ngày phát hành/đáo hạn, khối lượng, mệnh giá, lãi suất phát hành, cờ (mua lại/hoán đổi, chuyển đổi, kèm chứng quyền, bảo đảm).

### 9. Private Corp Bond Registration
**Tier:** 1 | **Source:** `HNX.private_corp_bond_registration` | **BCV Concept:** [Documentation] Regulatory Report | **BCO:** Documentation | **Table Type:** Fact Snapshot
**Domain Prefix:** (none)
**Description:** Thông tin đăng ký giao dịch trái phiếu doanh nghiệp riêng lẻ: mã, tổ chức phát hành, mệnh giá, kỳ hạn, các khối lượng phát hành, mua lại, đăng ký giao dịch, lưu hành và ngày giao dịch đầu tiên.

**Grain:** 1 dòng = 1 mã trái phiếu × 1 kỳ báo cáo (ngày/tháng/năm).

**Attributes chính:** `bond_code` (BK), tổ chức phát hành, mệnh giá, kỳ hạn, ngày phát hành/đáo hạn, các khối lượng, lãi suất phát hành, ngày giao dịch đầu tiên.

### 10. Private Corp Bond Service Organization
**Tier:** 1 | **Source:** `HNX.private_corp_bond_service_orgs` | **BCV Concept:** [Documentation] Regulatory Report | **BCO:** Documentation | **Table Type:** Relative
**Domain Prefix:** (none)
**Description:** Báo cáo BM 34 về các tổ chức dịch vụ của trái phiếu doanh nghiệp riêng lẻ: tổ chức tư vấn, đăng ký lưu ký, đại lý phát hành, đại diện người sở hữu trái phiếu, bảo lãnh phát hành, cùng thông tin trái phiếu, khối lượng phát hành và tài sản bảo đảm tương ứng.

**Grain:** 1 dòng = 1 mã trái phiếu × 1 kỳ báo cáo (ngày/tháng/năm).

**Attributes chính:** `bond_code` (BK), tên doanh nghiệp phát hành, mã đăng ký kinh doanh, khối lượng phát hành, tài sản/hình thức/giá trị bảo đảm, các cột tổ chức dịch vụ (tư vấn, đăng ký lưu ký, đại lý phát hành, đại diện NSH, bảo lãnh phát hành), ngày/tháng/năm báo cáo.

### 11. Private Corp Bond Trading Summary
**Tier:** 1 | **Source:** `HNX.private_corp_bond_trading` | **BCV Concept:** [Documentation] Regulatory Report | **BCO:** Documentation | **Table Type:** Fact Snapshot
**Domain Prefix:** (none)
**Description:** Chỉ tiêu thống kê giao dịch trái phiếu doanh nghiệp riêng lẻ theo ngày báo cáo: tên chỉ tiêu, đơn vị tính và giá trị.

**Grain:** 1 dòng = 1 chỉ tiêu × 1 ngày báo cáo.

**Attributes chính:** `indicator_name` (BK), đơn vị tính, giá trị chỉ tiêu, ngày báo cáo.

### 12. Securities Order
**Tier:** 1 | **Source:** `HNX.order_book`, `HOSE.order_book` | **BCV Concept:** [Communication] Financial Market Order | **BCO:** Communication | **Table Type:** Fact Append
**Domain Prefix:** (none)
**Description:** Sổ lệnh chi tiết trên sàn HNX và HOSE: mỗi bản ghi là 1 event lệnh (mới/sửa/hủy) với thị trường, bảng giao dịch, mã chứng khoán, thời điểm nhận lệnh, thành viên, tài khoản, loại và điều kiện lệnh, giá, khối lượng, trạng thái và các thuộc tính đặc thù (Iceberg, Stop order, báo giá RFQ).

**Grain:** 1 dòng = 1 event lệnh × 1 ngày giao dịch × 1 sàn (nguồn).

**Attributes chính:** `order_id` (BK), số hiệu nhận lệnh (BK phụ; reset mỗi ngày), `trade_date`, `market_id`, `board_id`, mã chứng khoán, chiều mua/bán, loại/điều kiện lệnh, giá, khối lượng, khối lượng còn lại, thành viên, số tài khoản (và PIN — cần quyết định mask), loại nhà đầu tư, loại nhà đầu tư nước ngoài, ETL-derived `src_stm_code`.

### 13. Security Market Capitalization
**Tier:** 1 | **Source:** `HNX.market_capitalization` | **BCV Concept:** [Documentation] Regulatory Report | **BCO:** Documentation | **Table Type:** Fact Snapshot
**Domain Prefix:** (none)
**Description:** Báo cáo BM 42 về vốn hóa thị trường HNX theo mã chứng khoán: giá tham chiếu, mở cửa, đóng cửa, trung bình, cao nhất, thấp nhất, thay đổi, khối lượng và giá trị giao dịch (khớp lệnh, thỏa thuận; lô chẵn, lô lẻ), khối lượng lưu hành, giá trị vốn hóa và tỷ trọng.

**Grain:** 1 dòng = 1 mã chứng khoán × 1 ngày báo cáo.

**Attributes chính:** `ticker_symbol` (BK), các mức giá, thay đổi (điểm/%), khối lượng/giá trị giao dịch theo phương thức và loại lô, tổng khối lượng/giá trị, khối lượng lưu hành, giá trị vốn hóa, các tỷ trọng (%), ngày/tháng/năm báo cáo.

### 14. Share Auction Result
**Tier:** 1 | **Source:** `HNX.share_auction`, `HOSE.share_auction` | **BCV Concept:** [Documentation] Regulatory Report | **BCO:** Documentation | **Table Type:** Fact Snapshot
**Domain Prefix:** (none)
**Description:** Kết quả đấu giá cổ phiếu theo tổ chức phát hành và loại đấu giá: số cổ phiếu chào bán, số nhà đầu tư đăng ký và trúng giá (trong nước/nước ngoài, tổ chức/cá nhân), giá khởi điểm, giá trúng bình quân, khối lượng và giá trị trúng giá/bán thực tế.

**Grain:** 1 dòng = 1 tổ chức phát hành × 1 loại đấu giá × 1 kỳ báo cáo × 1 sàn (nguồn).

**Attributes chính:** `issuer_name`, `auction_tp` (BK ghép), số nhà đầu tư/khối lượng/giá trị theo nhóm NĐT, giá khởi điểm, giá trúng bình quân, tháng/năm báo cáo, ETL-derived `src_stm_code`.

### 15. Securities Trade
**Tier:** 2 | **Source:** `HNX.trade_book`, `HOSE.trade_book` | **BCV Concept:** [Transaction] Financial Market Transaction | **BCO:** Transaction | **Table Type:** Fact Append
**Domain Prefix:** (none)
**Description:** Sổ khớp chi tiết trên sàn HNX và HOSE: mỗi bản ghi là 1 lần khớp thành công với thị trường, bảng giao dịch, mã chứng khoán, giá, khối lượng, giá trị khớp và đồng thời thông tin bên mua và bên bán (thành viên, tài khoản, loại nhà đầu tư, giá/khối lượng lệnh), kèm số hiệu lệnh để liên kết về sổ lệnh.

**Grain:** 1 dòng = 1 lần khớp × 1 ngày giao dịch × 1 sàn (nguồn).

**Attributes chính:** số hiệu khớp (BK ghép với `trade_date`, thị trường, mã chứng khoán), giá khớp, khối lượng khớp, giá trị khớp, thông tin bên mua/bán, số hiệu lệnh mua/bán (FK-BK về `Securities Order`), Spread legs (chỉ HNX), ETL-derived `src_stm_code`.
