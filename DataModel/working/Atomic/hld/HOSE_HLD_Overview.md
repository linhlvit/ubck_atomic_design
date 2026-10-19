# HOSE HLD — Overview

**Source system:** HOSE (Dữ liệu Sở Giao dịch Chứng khoán TP.HCM — vùng staging `uat_hose_stg`)
**Mô tả:** HOSE cung cấp 4 báo cáo có cấu trúc tương tự HNX/VSDC: kết quả đấu giá cổ phiếu, quyết định thay đổi niêm yết, danh sách chứng khoán niêm yết và thị phần môi giới. Không có entity riêng — toàn bộ bổ sung `source_table` cho entity đã định nghĩa ở HNX và VSDC.

---

## Tổng quan Atomic Entities

| Tier | Atomic Entity | BCV Core Object | BCV Concept | table_type | Source Table(s) | Ghi chú |
|---|---|---|---|---|---|---|
| T1 (extend) | Brokerage Market Share | Documentation | [Documentation] Regulatory Report | Fact Snapshot | HOSE.brokerage_market_share | Định nghĩa ở HNX |
| T1 (extend) | Listed Share Information | Documentation | [Documentation] Regulatory Report | Fact Snapshot | HOSE.listed_securities_list | Định nghĩa ở VSDC |
| T1 (extend) | Listing Status Change | Documentation | [Documentation] Regulatory Report | Fact Snapshot | HOSE.listing_status_change | Định nghĩa ở HNX |
| T1 (extend) | Share Auction Result | Documentation | [Documentation] Regulatory Report | Fact Snapshot | HOSE.share_auction | Định nghĩa ở HNX |

**Tổng: 0 Atomic entities mới**
*(Trong đó: 4 bảng nguồn extend `source_table` của entity thuộc source khác — không tạo mới)*

---

## Diagram Phân tầng Dependencies (Mermaid)

```mermaid
graph TD
    subgraph T1["Tier 1 — Extend entity có sẵn"]
        E1["Share Auction Result (HNX)"]
        E2["Listing Status Change (HNX)"]
        E3["Brokerage Market Share (HNX)"]
        E4["Listed Share Information (VSDC)"]
    end
```

---

## Quyết định thiết kế chính

| # | Quyết định | Lý do |
|---|---|---|
| D-01 | Không tạo entity riêng cho HOSE | Cấu trúc cột 4 bảng trùng khớp HNX/VSDC; `src_stm_code` phân biệt nguồn |
| D-02 | Không dùng prefix `HOSE` trong tên entity | Đồng nhất với MDDS D-04 / HNX D-04 |

---

#### 7a. Bảng tổng quan Atomic entities

| Tier | BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | Table Type | BCV Term |
|---|---|---|---|---|---|---|---|---|---|
| T1 (extend) | Documentation | [Documentation] Regulatory Report | Documentation | brokerage_market_share | Append | Thị phần môi giới theo quý tại HOSE | Brokerage Market Share (HNX) | Fact Snapshot | Regulatory Report (9297) — Core Object Documentation theo chỉ định Data Modeler |
| T1 (extend) | Documentation | [Documentation] Regulatory Report | Documentation | listed_securities_list | Append | Danh sách chứng khoán niêm yết HOSE | Listed Share Information (VSDC) | Fact Snapshot | Regulatory Report (9297) — Core Object Documentation theo chỉ định Data Modeler |
| T1 (extend) | Documentation | [Documentation] Regulatory Report | Documentation | listing_status_change | Append | Quyết định thay đổi niêm yết tại HOSE | Listing Status Change (HNX) | Fact Snapshot | Regulatory Report (9297) — Core Object Documentation theo chỉ định Data Modeler |
| T1 (extend) | Documentation | [Documentation] Regulatory Report | Documentation | share_auction | Append | Kết quả đấu giá cổ phiếu tại HOSE | Share Auction Result (HNX) | Fact Snapshot | Regulatory Report (9297) — Core Object Documentation theo chỉ định Data Modeler |

#### 7b. Diagram Atomic tổng (Mermaid)

```mermaid
erDiagram
    Share_Auction_Result {
        string share_auction_result_id PK
    }
    Listing_Status_Change {
        string listing_status_change_id PK
    }
    Listed_Share_Information {
        string listed_share_information_id PK
    }
    Brokerage_Market_Share {
        string brokerage_market_share_id PK
    }
```

#### 7c. Bảng Classification Value

| Source Table | Mô tả | BCV Term | Xử lý Atomic |
|---|---|---|---|
| — | Không có Classification Value scheme | — | Các cột phân loại giữ dạng Text |

#### 7d. Junction Tables

| Source Table | Mô tả | Entity chính | Xử lý trên Atomic |
|---|---|---|---|
| *(Không có junction table trong scope HOSE)* | — | — | — |

#### 7e. Điểm cần xác nhận

| # | Tier | Câu hỏi | Ảnh hưởng |
|---|---|---|---|
| 1 | T1 | 4 bảng HOSE extend entity có sẵn; cần xác nhận không có khác biệt ngữ nghĩa/giá trị so với HNX/VSDC | Có thể phải tách entity riêng nếu khác |

#### 7f. Bảng ngoài scope

| Nhóm | Source Table | Mô tả bảng nguồn | Lý do ngoài scope |
|---|---|---|---|
| Shared Entity | brokerage_market_share | Thị phần môi giới theo quý tại HOSE | Dùng entity `Brokerage Market Share` (định nghĩa ở HNX) — chỉ bổ sung `source_table` |
| Shared Entity | listed_securities_list | Danh sách chứng khoán niêm yết HOSE | Dùng entity `Listed Share Information` (định nghĩa ở VSDC) — chỉ bổ sung `source_table` |
| Shared Entity | listing_status_change | Quyết định thay đổi niêm yết tại HOSE | Dùng entity `Listing Status Change` (định nghĩa ở HNX) — chỉ bổ sung `source_table` |
| Shared Entity | share_auction | Kết quả đấu giá cổ phiếu tại HOSE | Dùng entity `Share Auction Result` (định nghĩa ở HNX) — chỉ bổ sung `source_table` |

---

## Entities

> Không có entity mới trong HOSE — 4 bảng nguồn extend `source_table` của entity thuộc HNX/VSDC (xem Tổng quan và 7f). Section này để trống có chủ đích.
