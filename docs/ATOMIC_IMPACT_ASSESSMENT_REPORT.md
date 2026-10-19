# BÁO CÁO TOÀN DIỆN ĐÁNH GIÁ TÁC ĐỘNG CẬP NHẬT THIẾT KẾ ATOMIC VÀ LỘ TRÌNH KHẮC PHỤC HỆ THỐNG DATAMART UBCKNN

**Mã tài liệu:** `RPT-DW-UBCK-ATOMIC-IMPACT-20261019-FINAL`  
**Dự án:** Xây dựng Kho Dữ liệu Tập trung & Hệ thống Phân hệ Datamart UBCKNN  
**Cơ quan chủ quản:** Ủy ban Chứng khoán Nhà nước (UBCKNN)  
**Thời điểm công bố:** Ngày 19 tháng 10 năm 2026  
**Phiên bản:** v1.0 (Official Release — Multi-Agent Verified)  
**Tác giả:** Master Report Author (`teamwork_preview_worker`)  
**Cơ sở thẩm định độc lập:** Báo cáo khảo sát M1 (`explorer_m1_atomic`), Báo cáo tác động Group A (`explorer_m2_group_a`), Báo cáo tác động Group B (`explorer_m2_group_b`).  
**Quy chế tuân thủ:** READ-ONLY trên toàn bộ tài liệu thiết kế gốc; bảo đảm tính toàn vẹn và khách quan thực nghiệm 100%.

---

## MỤC LỤC TỔNG QUAN

1. **CHƯƠNG 1: TỔNG QUAN ĐIỀU HÀNH (EXECUTIVE SUMMARY)**
   - 1.1. Bối cảnh nâng cấp thiết kế tầng Atomic (Commit `aff9a023` và `12a55eab`)
   - 1.2. Tổng quan tác động đa chiều trên toàn bộ 11 phân hệ Datamart
   - 1.3. Phân loại 3 nhóm phân hệ chiến lược (Gãy vỡ tham chiếu / Mở khóa PENDING / An toàn)
   - 1.4. Tóm lược số liệu thống kê và kết quả định lượng cốt lõi
2. **CHƯƠNG 2: DANH MỤC CHI TIẾT CÁC THAY ĐỔI ATOMIC (ATOMIC CHANGE CATALOG & SPECIFICATIONS)**
   - 2.1. Bảng Master Catalog 28 bảng Atomic mới và chuẩn hóa
   - 2.2. Chi tiết chuẩn hóa thực thể `THANHTRA.PENALTY_DECISION` (`pd` → `penalty_decision`)
   - 2.3. Bốn cơ chế hợp nhất & liên kết dữ liệu then chốt:
     - 2.3.1. Hợp nhất sổ lệnh giao dịch Trái phiếu HNX (`bond_order_book`)
     - 2.3.2. Chia sẻ thực thể đa sàn HNX / HOSE
     - 2.3.3. Hợp nhất thông tin cổ phiếu niêm yết 3 nguồn (`listed_share_information`)
     - 2.3.4. Danh mục quốc tịch VSDC (`cl_vsdc_nationality`) và kỹ thuật Crosswalk FK
   - 2.4. Quy chuẩn quản lý cột kỹ thuật Staging và cơ chế sinh Surrogate Key
3. **CHƯƠNG 3: MA TRẬN TỔNG QUAN ĐÁNH GIÁ TÁC ĐỘNG 11 PHÂN HỆ DATAMART**
   - 3.1. Bảng ma trận tổng hợp tác động 11 phân hệ (Độ phủ 100%)
   - 3.2. Phân tích phân nhóm tác động:
     - 3.2.1. Nhóm 1: Các phân hệ bị ảnh hưởng gãy vỡ tham chiếu (Breaking Changes)
     - 3.2.2. Nhóm 2: Các phân hệ có cơ hội bổ sung dữ liệu & mở rộng chỉ tiêu (Pending Resolution)
     - 3.2.3. Nhóm 3: Các phân hệ an toàn / không chịu tác động phá vỡ (Safe Subsystems)
4. **CHƯƠNG 4: PHÂN TÍCH TÁC ĐỘNG CHI TIẾT CHO TỪNG PHÂN HỆ (11 PHÂN HỆ ĐỘC LẬP)**
   - 4.1. Phân hệ GSDC (Giám sát công ty đại chúng)
   - 4.2. Phân hệ GSTT (Giám sát giao dịch thị trường)
   - 4.3. Phân hệ NDTNN (Quản lý nhà đầu tư nước ngoài)
   - 4.4. Phân hệ NHNCK (Người hành nghề & Cổ đông lớn)
   - 4.5. Phân hệ PTTT (Phân tích & Phát triển thị trường)
   - 4.6. Phân hệ QLCB (Quản lý chào bán chứng khoán)
   - 4.7. Phân hệ QLKD (Quản lý kinh doanh chứng khoán)
   - 4.8. Phân hệ QLQ (Quản lý quỹ đầu tư chứng khoán)
   - 4.9. Phân hệ TKNB (Thống kê nội bộ UBCKNN)
   - 4.10. Phân hệ TT (Thanh tra chứng khoán)
   - 4.11. Phân hệ VP (Văn phòng / Quản trị điều hành)
5. **CHƯƠNG 5: KẾ HOẠCH HÀNH ĐỘNG & LỘ TRÌNH KHẮC PHỤC (REMEDIATION ROADMAP)**
   - 5.1. Khung phân cấp ưu tiên giải pháp (P1 / P2 / P3)
   - 5.2. Bảng Action Items chi tiết toàn diện (Mã hành động, File, Cột, Giải pháp, Trách nhiệm)
   - 5.3. Quy trình nghiệm thu chất lượng (Quality Gates Checklist) và hướng dẫn thẩm tra

---

## CHƯƠNG 1: TỔNG QUAN ĐIỀU HÀNH (EXECUTIVE SUMMARY)

### 1.1. Bối cảnh nâng cấp thiết kế tầng Atomic

Trong giai đoạn hoàn thiện kiến trúc Kho dữ liệu UBCKNN, tầng Dữ liệu Nguyên tử (Atomic Data Layer) đã trải qua đợt tái cấu trúc và mở rộng lớn nhất từ trước tới nay tại hai commit cốt lõi:

1. **Commit `aff9a023` (Ngày 19/10/2026): Chuẩn hóa tên bảng và thuộc tính Thanh tra:**
   - Chuẩn hóa tên vật lý thực thể `THANHTRA.PENALTY_DECISION` từ tên viết tắt bản thảo `pd` sang tên chuẩn tiếng Anh nghiệp vụ `penalty_decision` (tại file `DataModel/working/Atomic/lld/THANHTRA/lld_THANHTRA_PENALTY_DECISION.yaml`).
   - Cập nhật đồng bộ `atomic_table: 'penalty_decision'` cho toàn bộ 19 thuộc tính nghiệp vụ liên quan trong từ điển dữ liệu tổng hợp `DataModel/working/Atomic/aggregate/atomic_attributes.yaml`.
   - Chuẩn hóa tên bảng liên kết ngoại hối SCMS từ `sc_foreign_ou_x_cl_sc_firm_service_relationship` sang `sc_foreign_organization_unit_x_cl_sc_firm_service_relationship` trong `dm_manifest.yaml` và `atomic_model.yaml`.

2. **Commit `12a55eab` (Ngày 19/10/2026): Bổ sung toàn diện 28 bảng Atomic thị trường:**
   - Bổ sung chính thức 27 tệp đặc tả thiết kế chi tiết (LLD YAML) cho 3 hệ thống nguồn thị trường trọng yếu gồm:
     - **14 bảng nguồn HNX:** Bao gồm thị phần môi giới CTCK, toàn bộ mảng Trái phiếu Chính phủ (TPCP: đấu thầu, niêm yết, niêm yết bổ sung), mảng Trái phiếu Doanh nghiệp riêng lẻ (TPDN: chào bán, đăng ký, thống kê giao dịch, thay đổi trạng thái đăng ký), sổ lệnh giao dịch trái phiếu Outright/Repo, danh sách niêm yết, thay đổi niêm yết và đấu giá cổ phần.
     - **4 bảng nguồn HOSE:** Bao gồm thị phần môi giới CTCK, danh sách niêm yết, thay đổi niêm yết và đấu giá cổ phần.
     - **9 bảng nguồn VSDC (Tổng công ty Lưu ký và Bù trừ Chứng khoán Việt Nam):** Bao gồm vị thế mở cuối ngày phái sinh, sở hữu NĐTNN, cơ cấu cổ phiếu lưu hành, sở hữu cổ đông lớn, tài khoản NĐT mở mới/đóng/cập nhật, danh mục trái phiếu NĐTNN và bảng danh mục quốc tịch.
   - *Làm rõ về số lượng 28 bảng:* Tài liệu mapping ODS gốc (`mapping_vsdc_ods_atm.md`) đánh số bảng từ 1 đến 28. Tuy nhiên, bảng số 7 (`account_opening_closing_status`) đã chính thức được loại bỏ do nguồn dữ liệu ngừng khai thác; đồng thời bảng `NATIONALITY` được chuẩn hóa thành danh mục phân loại `cl_vsdc_nationality`. Do đó, 27 tệp LLD thị trường mới kết hợp cùng 1 bảng `THANHTRA.PENALTY_DECISION` được chuẩn hóa tạo thành tập hợp chuẩn chỉnh gồm đúng **28 bảng thiết kế Atomic** được rà soát.

### 1.2. Tổng quan tác động đa chiều trên toàn bộ 11 phân hệ Datamart

Việc cập nhật tầng Atomic mang tính chất hai mặt đối với hệ thống Datamart:
- **Tác động tích cực (Giải phóng năng lực nghiệp vụ):** Mở khóa hơn **160+ chỉ tiêu báo cáo KPI** vốn bị phong tỏa ở trạng thái PENDING suốt thời gian qua do thiếu hụt nguồn số hóa từ Sở và VSDC (đặc biệt giải quyết dứt điểm 135+ KPI tại TKNB, 10 KPI tại QLQ, tháo gỡ điểm nghẽn trái phiếu O_PTTT_26 tại PTTT, mở khóa thị phần môi giới tại QLKD và mở khóa giám sát cổ đông lớn tại GSTT/GSDC).
- **Tác động tiêu cực (Gãy vỡ tham chiếu kỹ thuật):** Làm phát sinh các lỗi kiểm tra toàn vẹn tham chiếu (Gate 0 Reference Check) tại các phân hệ đã thiết kế trước dựa trên các tên bảng/cột giả định hoặc do sự khác biệt giữa quy ước của Data Modeler Atomic (viết tắt hậu tố `_dt` thay vì `_date`, đưa các cột kỹ thuật staging `ds_snpst_dt`/`ds_etl_pcs_tms` vào vùng quản lý riêng của ETL).

### 1.3. Phân loại 3 nhóm phân hệ chiến lược

Tuân thủ nghiêm ngặt tiêu chí nghiệm thu (Acceptance Criteria), toàn bộ 11 phân hệ Datamart được phân nhóm rõ ràng:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        PHÂN NHÓM 11 PHÂN HỆ DATAMART UBCKNN                            │
├───────────────────────────────┬───────────────────────────────┬────────────────────────┤
│   NHÓM 1: GÃY VỠ THAM CHIẾU   │  NHÓM 2: MỞ KHÓA PENDING      │  NHÓM 3: AN TOÀN       │
│   (Breaking Changes - Fix P1) │  (Pending Resolution - P2/P3) │  (Safe / Zero Impact)  │
├───────────────────────────────┼───────────────────────────────┼────────────────────────┤
│ • GSTT (29 Crit, 13 Warn)     │ • TKNB (135+ KPI Trái phiếu)  │ • TT (0 Crit, 0 Warn)  │
│ • TKNB (29 Crit, 4 Warn)      │ • PTTT (TPDN HNX, O_PTTT_26)  │   Gate 0 PASS 100%     │
│ • NHNCK (14 Crit, 10 Warn)    │ • QLQ (10 KPI Staff Trade)    │                        │
│ • QLQ (13 Crit, 0 Warn)       │ • GSTT (Cổ đông lớn, NĐT)     │ • VP (0 Crit gãy vỡ)   │
│ • QLKD (3 Crit, 0 Warn)       │ • QLKD (Thị phần CTCK Q1-Q4)  │   Nguồn nội bộ độc lập │
│ • PTTT (1 Crit, 3 Warn Atomic)│ • NDTNN (Room ngoại, TP Ngoại)│                        │
│ • GSDC (0 Crit, 1 Warn Atomic)│ • QLCB (Đấu giá, Đối soát CP) │                        │
│                               │ • GSDC (Cổ đông lớn CTĐC mới) │                        │
└───────────────────────────────┴───────────────────────────────┴────────────────────────┘
```

### 1.4. Tóm lược số liệu thống kê cốt lõi

- **Tổng số bảng Atomic khảo sát:** 28 bảng (14 HNX, 4 HOSE, 9 VSDC, 1 THANHTRA).
- **Tổng số phân hệ Datamart được đánh giá:** 11 phân hệ (Độ phủ 100%).
- **Tổng số lỗi Critical Gate 0 do lệch Atomic mới phát hiện:** **89 lỗi Critical** (GSTT: 29, TKNB: 29, NHNCK: 14, QLQ: 13, QLKD: 3, PTTT: 1).
- **Tổng số cảnh báo Warning Gate 0 liên quan đến Atomic:** **40 cảnh báo Warning** (GSTT: 13, NHNCK: 10, NDTNN: 9, TKNB: 4, PTTT: 3, GSDC: 1). *(Toàn hệ thống đo đạc thực tế có 140 Warning Gate 0, gồm 40 Warning do Atomic và 100 Warning cấu trúc/cột kế thừa)*.
- **Tổng số KPI PENDING được tháo gỡ trực tiếp:** **Hơn 160 chỉ tiêu** (TKNB: 135+ KPI; QLQ: 10 KPI; PTTT: 8 KPI; QLKD: 4 KPI; GSTT: 4 KPI).
- **Trạng thái an toàn tuyệt đối:** Phân hệ **TT** (Thanh tra) đạt chuẩn PASS 100% Gate 0; Phân hệ **VP** (Văn phòng) an toàn độc lập.

---

## CHƯƠNG 2: DANH MỤC CHI TIẾT CÁC THAY ĐỔI ATOMIC (ATOMIC CHANGE CATALOG & SPECIFICATIONS)

### 2.1. Bảng Master Catalog 28 bảng Atomic mới và chuẩn hóa

Bảng tổng hợp dưới đây ghi nhận đầy đủ 100% các thực thể Atomic mới hoặc được cập nhật, bao gồm tên nguồn, tên entity, tên bảng vật lý, phân loại bảng, độ mịn dữ liệu (grain), hệ thống khóa và quy mô thuộc tính:

| # | Nguồn | Bảng Nguồn (Source Table) | Tên Entity Atomic | Tên Vật Lý (Physical Name) | Table Type | Grain (Độ mịn dòng) | Khóa Chính (PK) | Khóa Nghiệp Vụ (BK) | Khóa Ngoại / Liên Kết (FK) | Số Cột |
|:---:|:---:|---|---|---|:---:|---|---|---|---|:---:|
| 01 | HNX | `BROKERAGE_MARKET_SHARE` | Brokerage Market Share | `brokerage_market_share` | Fact Snapshot | 1 dòng = 1 CTCK theo quý báo cáo thị phần | `brokerage_market_share_id` | `sc_member_code` | — | 8 |
| 02 | HNX | `GOV_BOND_ADDITIONAL_LISTING` | Additional Gov Bond Listing | `additional_gov_bond_listing` | Fact Snapshot | 1 dòng = 1 sự kiện niêm yết bổ sung TPCP | `additional_gov_bond_listing_id` | `bond_code, listing_status, listing_change_dt` | — | 9 |
| 03 | HNX | `GOV_BOND_LISTED_LIST` | Gov Bond Listing | `gov_bond_listing` | Fact Snapshot | 1 dòng = 1 mã TPCP niêm yết tại HNX kỳ snapshot | `gov_bond_listing_id` | `bond_code` | — | 14 |
| 04 | HNX | `GOV_BOND_OFFERING` | Gov Bond Bidding Result | `gov_bond_bidding_result` | Fact Snapshot | 1 dòng = 1 đợt/phiên đấu thầu phát hành TPCP | `gov_bond_bidding_result_id` | `bidding_session` | — | 16 |
| 05 | HNX | `LISTED_SECURITIES_LIST` | Listed Share Information | `listed_share_information` | Fact Snapshot | 1 dòng = 1 mã CK niêm yết tại HNX kỳ snapshot | `listed_share_information_id` | `ticker_symbol` | — | 8 |
| 06 | HNX | `LISTING_STATUS_CHANGE` | Listing Status Change | `listing_status_change` | Fact Snapshot | 1 dòng = 1 quyết định thay đổi niêm yết CK HNX | `listing_status_change_id` | `decision_nbr, decision_dt, ticker_symbol` | — | 18 |
| 07 | HNX | `OUTRIGHT_ORDER_BOOK` | Bond Order Book | `bond_order_book` | Fact Snapshot | 1 dòng = 1 lệnh mua/bán thẳng Outright TP HNX | `bond_order_book_id` | `order_nbr` | — | 43 |
| 08 | HNX | `PRIVATE_CORP_BOND_OFFERING` | Private Corp Bond Offering | `private_corp_bond_offering` | Fact Snapshot | 1 dòng = 1 đợt đăng tin chào bán TPDN riêng lẻ | `private_corp_bond_offering_id` | `bond_code, market_tp, posting_dt` | — | 29 |
| 09 | HNX | `PRIVATE_CORP_BOND_REGISTRATION` | Private Corp Bond Registration | `private_corp_bond_registration` | Fact Snapshot | 1 dòng = 1 mã TPDN đăng ký giao dịch tại HNX | `private_corp_bond_registration_id` | `bond_code` | — | 22 |
| 10 | HNX | `PRIVATE_CORP_BOND_TRADING` | Private Corp Bond Trading Summary | `private_corp_bond_trading_summary` | Fact Snapshot | 1 dòng = 1 chỉ tiêu thống kê GD TPDN theo ngày | `private_corp_bond_trading_summary_id` | `ind_nm` | — | 6 |
| 11 | HNX | `REGISTRATION_STATUS_CHANGE` | Bond Trading Registration Status | `bond_trading_registration_status` | Fact Snapshot | 1 dòng = 1 sự kiện thay đổi trạng thái ĐKGD TP | `bond_trading_registration_status_id` | `bond_code, trading_registration_status` | — | 11 |
| 12 | HNX | `REPO2_ORDER_BOOK` | Bond Order Book | `bond_order_book` | Fact Snapshot | 1 dòng = 1 lệnh giao dịch Repo 2 sổ lệnh TP HNX | `bond_order_book_id` | `order_nbr` | — | 56 |
| 13 | HNX | `REPO_ORDER_BOOK` | Bond Order Book | `bond_order_book` | Fact Snapshot | 1 dòng = 1 lệnh giao dịch Repo 1 sổ lệnh TP HNX | `bond_order_book_id` | `order_nbr` | — | 51 |
| 14 | HNX | `SHARE_AUCTION` | Share Auction Result | `share_auction_result` | Fact Snapshot | 1 dòng = 1 phiên đấu giá cổ phần theo TCPH HNX | `share_auction_result_id` | `issuer_nm, auction_tp` | — | 24 |
| 15 | HOSE | `BROKERAGE_MARKET_SHARE` | Brokerage Market Share | `brokerage_market_share` | Fact Snapshot | 1 dòng = 1 CTCK theo quý báo cáo thị phần HOSE | `brokerage_market_share_id` | `sc_member_code` | — | 8 |
| 16 | HOSE | `LISTED_SECURITIES_LIST` | Listed Share Information | `listed_share_information` | Fact Snapshot | 1 dòng = 1 mã CK niêm yết tại HOSE kỳ snapshot | `listed_share_information_id` | `ticker_symbol` | — | 8 |
| 17 | HOSE | `LISTING_STATUS_CHANGE` | Listing Status Change | `listing_status_change` | Fact Snapshot | 1 dòng = 1 quyết định thay đổi niêm yết CK HOSE | `listing_status_change_id` | `decision_nbr, decision_dt, ticker_symbol` | — | 18 |
| 18 | HOSE | `SHARE_AUCTION` | Share Auction Result | `share_auction_result` | Fact Snapshot | 1 dòng = 1 phiên đấu giá cổ phần theo TCPH HOSE | `share_auction_result_id` | `issuer_nm, auction_tp` | — | 24 |
| 19 | VSDC | `CLOSED_INVESTORS` | Closed Investor Account | `closed_investor_account` | Fact Snapshot | 1 dòng = 1 tài khoản GDCK đóng trong kỳ | `closed_investor_account_id` | `investor_account_nbr` | nationality_id, nationality_code | 15 |
| 20 | VSDC | `END_OF_DAY_OPEN_INTEREST` | End Of Day Open Interest | `end_of_day_open_interest` | Fact Snapshot | 1 dòng = 1 mã HĐTL vị thế mở cuối ngày | `end_of_day_open_interest_id` | `ticker_symbol` | — | 5 |
| 21 | VSDC | `FOREIGN_INVESTOR_BOND_PORTFOLIO` | Foreign Bond Portfolio | `foreign_bond_portfolio` | Fact Snapshot | 1 dòng = 1 khoản nắm giữ TP của NĐTNN theo tháng | `foreign_bond_portfolio_id` | `foreign_investor_code` | nationality_id, nationality_code | 13 |
| 22 | VSDC | `FOREIGN_INVESTOR_INFO` | Foreign Ownership Information | `foreign_ownership_information` | Fact Snapshot | 1 dòng = 1 mã CK theo ngày chốt sở hữu NĐTNN | `foreign_ownership_information_id` | `ticker_symbol` | — | 10 |
| 23 | VSDC | `MAJOR_SHAREHOLDER` | Major Shareholder Ownership | `major_shareholder_ownership` | Fact Snapshot | 1 dòng = 1 cổ đông lớn theo mã CK và kỳ chốt | `major_shareholder_ownership_id` | `ticker_symbol, identification_nbr` | — | 16 |
| 24 | VSDC | `NATIONALITY` | Classification VSDC Nationality | `cl_vsdc_nationality` | Classification | 1 dòng = 1 quốc tịch trong danh mục quốc tịch VSDC | `cl_vsdc_nationality_id` | `cl_vsdc_nationality_code` | — | 4 |
| 25 | VSDC | `OPEN_INVESTORS` | Open Investor Account | `open_investor_account` | Fact Snapshot | 1 dòng = 1 tài khoản GDCK mở mới trong kỳ | `open_investor_account_id` | `investor_account_nbr` | nationality_id, nationality_code | 14 |
| 26 | VSDC | `OUTSTANDING_SHARES` | Listed Share Information | `listed_share_information` | Fact Snapshot | 1 dòng = 1 mã CP cơ cấu cổ phần phát hành/lưu hành | `listed_share_information_id` | `ticker_symbol` | — | 11 |
| 27 | VSDC | `UPDATED_INVESTORS` | Updated Investor Account | `updated_investor_account` | Fact Snapshot | 1 dòng = 1 tài khoản GDCK cập nhật thông tin kỳ | `updated_investor_account_id` | `investor_account_nbr` | nationality_id, nationality_code | 15 |
| 28 | TT | `PENALTY_DECISION` | Penalty Decision | `penalty_decision` | Fundamental | 1 dòng = 1 quyết định xử phạt vi phạm hành chính | `pd_id` | `pd_code` | violation_case_id, reviewer_officer_id | 32 |

### 2.2. Chi tiết chuẩn hóa thực thể `THANHTRA.PENALTY_DECISION` (`pd` → `penalty_decision`)

- **Bản chất thay đổi:** Trước commit `aff9a023`, file thiết kế LLD của bảng quyết định xử phạt vi phạm hành chính khai báo:
  ```yaml
  # Cũ (trước aff9a023):
  entity_physical_name: "pd"
  ```
  Tên viết tắt này không tuân thủ quy chuẩn đặt tên bảng đầy đủ (Full English Naming Convention) và tạo ra sự mất đồng bộ nghiêm trọng vì toàn bộ tầng Datamart (các phân hệ TT, QLKD, NDTNN) đều đã khai báo truy vấn tới bảng `penalty_decision`.
- **Hành động kỹ thuật trong `aff9a023`:**
  - Sửa `entity_physical_name: "penalty_decision"` trong `DataModel/working/Atomic/lld/THANHTRA/lld_THANHTRA_PENALTY_DECISION.yaml`.
  - Cập nhật đồng bộ trường `atomic_table: "penalty_decision"` cho 19 thuộc tính nghiệp vụ trong `DataModel/working/Atomic/aggregate/atomic_attributes.yaml` (dòng 38854 đến 39152), bao gồm: `pd_id`, `pd_code`, `decision_nbr`, `decision_dt`, `effective_dt`, `violation_case_id`, `violator_tp`, `penalty_type_code`, `total_fine_amt`, `remedial_measure_desc`, `implementation_deadline_dt`,...
- **Đánh giá tác động:** Đây là một thay đổi **khắc phục lỗi đồng bộ (Bug Fix)**. Thay đổi này không làm gãy vỡ Datamart mà ngược lại đã hợp thức hóa và khớp nối 100% các bảng Fact/Dim của phân hệ TT và QLKD với tầng Atomic.

### 2.3. Bốn cơ chế hợp nhất & liên kết dữ liệu then chốt

Kiến trúc sư Dữ liệu (Data Modeler) đã áp dụng 4 cơ chế chuẩn hóa dữ liệu cấp cao trong đợt cập nhật này:

#### 2.3.1. Hợp nhất Sổ lệnh giao dịch Trái phiếu HNX (`bond_order_book`)
- **Nguồn:** 3 bảng staging giao dịch của Sở GDCK Hà Nội gồm `HNX.OUTRIGHT_ORDER_BOOK` (42 cột), `HNX.REPO_ORDER_BOOK` (50 cột) và `HNX.REPO2_ORDER_BOOK` (55 cột).
- **Cơ chế hợp nhất:** Thay vì tạo 3 bảng Atomic riêng biệt, toàn bộ được hợp nhất vào duy nhất một thực thể `Bond Order Book` (tên vật lý: `bond_order_book`).
- **Phân biệt luồng:** Trường ETL-derived `order_book_type` mang giá trị: `'OUTRIGHT'`, `'REPO'`, hoặc `'REPO2'`.
- **Xử lý thuộc tính:** Các trường dùng chung (số hiệu lệnh `order_nbr`, ngày lệnh `order_dt`, giờ lệnh `order_time`, thành viên `member_code`, tiểu khoản `firm_sub_account_nbr`, mã trái phiếu `ticker_symbol`, khối lượng, giá, lợi suất) được map đồng nhất; các cột đặc thù Repo (kỳ hạn repo, ngày thanh toán lần 1/2, lãi suất repo) sẽ nhận giá trị `NULL` đối với lệnh Outright.

#### 2.3.2. Chia sẻ thực thể đa sàn HNX / HOSE
- **Nguồn:** Các bảng nghiệp vụ có cấu trúc tương đồng từ cả hai Sở gồm:
  - `SHARE_AUCTION` (Đấu giá cổ phần): HNX (23 cột) và HOSE (23 cột).
  - `LISTING_STATUS_CHANGE` (Thay đổi trạng thái niêm yết): HNX (17 cột) và HOSE (17 cột).
  - `BROKERAGE_MARKET_SHARE` (Thị phần môi giới CTCK): HNX (7 cột) và HOSE (7 cột).
- **Cơ chế chia sẻ:** Mô hình hóa thành các thực thể Atomic duy nhất (`share_auction_result`, `listing_status_change`, `brokerage_market_share`).
- **Nhận diện nguồn sàn:** Sử dụng cột nguồn `src_stm_code` (`'HNX_SHARE_AUCTION'` vs `'HOSE_SHARE_AUCTION'`). Khi tầng Datamart truy vấn phân tích toàn thị trường hoặc so sánh giữa hai Sở, chỉ cần lọc hoặc gom nhóm theo `src_stm_code`.

#### 2.3.3. Hợp nhất thông tin cổ phiếu niêm yết 3 nguồn (`listed_share_information`)
- **Nguồn:** `VSDC.OUTSTANDING_SHARES` (10 cột) kết hợp với `HNX.LISTED_SECURITIES_LIST` (7 cột) và `HOSE.LISTED_SECURITIES_LIST` (7 cột).
- **Cơ chế hợp nhất:** Tích hợp thành thực thể `Listed Share Information` (`listed_share_information`):
  - Nguồn VSDC cung cấp cấu trúc vốn chủ sở hữu: Tổng số cổ phần phát hành (`total_issued_share_quantity`), cổ phần lưu hành (`outstanding_share_quantity`), cổ phiếu quỹ (`treasury_share_quantity`), cổ phần ưu đãi (`preferential_share_quantity`).
  - Nguồn HNX và HOSE cung cấp khối lượng niêm yết tại Sở (`listed_share_quantity`) và giá tham chiếu ngày giao dịch (`reference_price`).

#### 2.3.4. Danh mục quốc tịch VSDC (`cl_vsdc_nationality`) và kỹ thuật Crosswalk FK
- **Nguồn:** `VSDC.NATIONALITY` (3 cột: `AUTOID`, `CODE`, `NAME`).
- **Cơ chế chuẩn hóa:** Tạo bảng phân loại danh mục `Classification VSDC Nationality` (tên vật lý `cl_vsdc_nationality`).
- **Kỹ thuật Crosswalk:** Các bảng tiêu thụ dữ liệu NĐT của VSDC (`open_investor_account`, `closed_investor_account`, `updated_investor_account`, `foreign_bond_portfolio`) lưu mã quốc tịch dạng ID tự tăng của VSDC (`AUTOID`). Khi nạp vào Atomic, tầng ETL thực hiện tra cứu:
  ```sql
  LEFT JOIN cl_vsdc_nationality ON source.NATIONALITY = cl_vsdc_nationality.cl_vsdc_nationality_id
  ```
  giúp chuẩn hóa mã quốc tịch 2 ký tự ISO và tên quốc gia chính thức.

### 2.4. Quy chuẩn quản lý cột kỹ thuật Staging và cơ chế sinh Surrogate Key

- **Xử lý cột kỹ thuật Staging:** Các trường `DS_SNPST_DT` (ngày snapshot staging) và `DS_ETL_PCS_TMS` (thời điểm ETL xử lý) từ các nguồn HNX/HOSE/VSDC đã được Data Modeler **chủ động loại trừ** khỏi danh sách thuộc tính nghiệp vụ LLD YAML và chuyển ghi chú sang `pending_design.yaml`. Data Modeler quy định các cột này thuộc trách nhiệm quản trị hạ tầng của ETL Developer khi nạp bảng vật lý. Do đó, các file LLD Datamart tham chiếu trực tiếp đến `ds_snpst_dt` sẽ bị báo lỗi Gate 0.
- **Cơ chế sinh Surrogate Key (PK):** Áp dụng thuật toán băm SHA-256 trên tổ hợp `hash_id(source_table, Business_Key)`. Đặc biệt, do Business Key của các bảng Fact Snapshot không chứa ngày chụp, giá trị Khóa chính PK của một đối tượng nghiệp vụ (ví dụ: mã cổ phiếu, số tài khoản NĐT) sẽ **cố định và lặp lại qua các kỳ snapshot**, tạo điều kiện tối ưu để Datamart theo dõi biến động lịch sử xuyên thời gian.

---

## CHƯƠNG 3: MA TRẬN TỔNG QUAN ĐÁNH GIÁ TÁC ĐỘNG 11 PHÂN HỆ DATAMART

### 3.1. Bảng ma trận tổng hợp tác động 11 phân hệ

Dưới đây là bảng ma trận tổng hợp toàn diện hiện trạng tác động trên 11 phân hệ Datamart sau khi đối soát thực nghiệm chéo với 28 bảng Atomic mới:

| Phân Hệ | Tên Đầy Đủ Phân Hệ | Mức Độ Tác Động | Loại Tác Động Chính | Số Lỗi Gãy Vỡ (Critical / Warn) | Tiềm Năng Mở Khóa KPI PENDING | Hiện Trạng Đồng Bộ | Đánh Giá Tóm Tắt |
|:---:|---|:---:|:---:|:---:|:---:|:---:|---|
| **GSTT** | Giám sát thị trường | 🔴 **CAO** | Gãy vỡ tham chiếu & Mở khóa | **29 Critical / 13 Warn** | Mở khóa Nhóm 35, 38 (Cổ đông lớn); Sổ lệnh TP | **60%** (Lệch LLD) | Lệch tên cột `_dt` vs `_date` trên `major_shareholder_ownership`; lệch tên bảng `listed_share_info`. |
| **TKNB** | Thống kê nội bộ | 🔴 **CAO** | Gãy vỡ tham chiếu & Mở khóa cực lớn | **29 Critical / 4 Warn** *(28 Warn tổng)* | **Mở khóa 135+ KPI** (94% blocker TPCP, TPDN) | **45%** (Cần mở rộng) | Tác động mở khóa lớn nhất dự án; vướng lỗi kỹ thuật `ds_snpst_dt` trên TPDN và phái sinh cần sửa LLD. |
| **QLQ** | Quản lý quỹ đầu tư | 🔴 **CAO** | Gãy vỡ tham chiếu & Mở khóa | **13 Critical / 0 Warn** | **Mở khóa 10 KPI** (Nhóm 28 Staff Trade) | **82.5%** | Đường nối tạm `discretionary_investment_account` gây lỗi; thay bằng `open_investor_account` là xong. |
| **NHNCK**| Người hành nghề CK | 🟡 **TRUNG BÌNH** | Gãy vỡ tham chiếu & Hoàn thiện | **14 Critical / 10 Warn** | Đóng câu hỏi O_NHNCK_33; Kiểm soát xung đột | **70%** | Lệch tên `sp_violation` và `major_shareholder_ownership`; cần nối VSDC tài khoản cá nhân. |
| **QLKD** | Quản lý KD chứng khoán | 🟡 **TRUNG BÌNH** | Gãy vỡ kỹ thuật & Mở khóa | **3 Critical / 0 Warn** | **Mở khóa toàn diện Nhóm 17** (Thị phần CTCK) | **90%** (Tiên phong) | Đã chủ động đồng bộ Nhóm 17, 28-30, 40, 44; chỉ vướng 3 lỗi tham chiếu ngày snapshot `ds_snpst_dt`. |
| **PTTT** | Phân tích phát triển TT | 🟡 **TRUNG BÌNH** | Gãy vỡ kỹ thuật & Đột phá nguồn | **1 Critical / 3 Warn** *(do Atomic)* | **Giải quyết O_PTTT_26**; Khôi phục Nhóm 19, 21 | **75%** | Mở ra 90% thanh khoản TPDN HNX; cần sửa lỗi tên bảng `listed_share_info` và cột kỳ hạn (16 Crit / 23 Warn tổng). |
| **GSDC** | Giám sát công ty đại chúng | 🟡 **TRUNG BÌNH** | Lệch tham chiếu bảng & Mở rộng Fact | **0 Critical / 1 Warn** *(55 Warn tổng)* | Xây mới mảng Giám sát Cổ đông lớn VSDC | **80%** | Lỗi `listed_share_info` được xếp là Warning (0 Critical, 55 Warning Gate 0); sửa sang `listed_share_information`. |
| **QLCB** | Quản lý chào bán CK | 🟡 **TRUNG BÌNH** | Cơ hội mở rộng phạm vi (Zero Broken) | **0 Critical / 0 Warn** (Gate 0 PASS) | Bổ sung mảng Đấu giá cổ phần 2 Sở | **100%** (Ready hiện tại)| Không gãy vỡ tham chiếu; sẵn sàng mở rộng đón đầu dữ liệu `share_auction_result`. |
| **NDTNN**| Nhà đầu tư nước ngoài | 🟢 **THẤP** | Cảnh báo tên bảng & Mở rộng | **0 Critical / 9 Warn** | Chuẩn hóa Room ngoại; Thêm TP ngoại | **95%** (Gần hoàn hảo)| Đạt chuẩn cấu trúc cột; chỉ cần sửa tên viết tắt bảng `foreign_ownership_info` trên 9 dòng. |
| **TT** | Thanh tra chứng khoán | ⚪ **AN TOÀN** | Khắc phục rủi ro đồng bộ | **0 Critical / 0 Warn** (Gate 0 PASS) | Sẵn sàng 100% nghiệp vụ | **100%** (Hoàn hảo) | Đồng bộ tuyệt đối; commit `aff9a023` đã chính thức công nhận tên `penalty_decision` mà TT đón đầu. |
| **VP** | Văn phòng / Quản trị | ⚪ **AN TOÀN** | Độc lập kiến trúc | **0 Critical / 0 Warn** *(Atomic)* | Tiềm năng tối ưu nguồn | **90%** (Ổn định) | An toàn tuyệt đối trước biến động Atomic; vận hành dựa trên tầng báo cáo nội bộ độc lập. |

### 3.2. Phân tích phân nhóm tác động

#### 3.2.1. Nhóm 1: Các phân hệ bị ảnh hưởng gãy vỡ tham chiếu (Breaking Changes)
Bao gồm **6 phân hệ có lỗi Critical gãy vỡ**: **GSTT (29), TKNB (29), NHNCK (14), QLQ (13), QLKD (3), PTTT (1)** (tổng cộng **89 lỗi Critical** do Atomic) và **1 phân hệ có Warning lệch tên bảng Atomic**: **GSDC (0 Critical, 1 Warning Atomic / 55 Warning tổng)**.
- **Đặc điểm chung:** Phát sinh lỗi vi phạm `L0-ATOMIC-TABLE-NOT-FOUND` hoặc `L0-ATOMIC-COLUMN-NOT-FOUND` khi chạy bộ kiểm định `check_references.py`.
- **Nguyên nhân cốt lõi:**
  1. *Lệch quy ước đặt tên cột của Data Modeler:* Data Modeler Atomic chuẩn hóa hậu tố ngày tháng là `_dt` (như `opening_balance_dt`, `closing_balance_dt`, `rpt_month`, `maturity_dt`), trong khi LLD Datamart viết là `_date` hoặc `report_month`.
  2. *Quy ước loại trừ cột Staging:* Data Modeler không khai báo các trường kỹ thuật `ds_snpst_dt`/`ds_etl_pcs_tms` trong YAML LLD Atomic, dẫn tới việc các LLD Datamart tham chiếu trực tiếp vào cột này bị chặn lỗi.
  3. *Lệch tên thực thể đầy đủ vs viết tắt:* Datamart sử dụng tên bảng viết tắt bản thảo cũ (`listed_share_info`, `foreign_ownership_info`, `sp_conduct_violation`, `major_shareholder`), trong khi Atomic ban hành tên chuẩn (`listed_share_information`, `foreign_ownership_information`, `sp_violation`, `major_shareholder_ownership`).
  4. *Đường nối tạm thời do thiếu nguồn cũ:* Sử dụng tạm bảng không tương thích (`discretionary_investment_account` của FMS) để làm cầu nối tài khoản giao dịch NĐT.

#### 3.2.2. Nhóm 2: Các phân hệ có cơ hội bổ sung dữ liệu & mở rộng chỉ tiêu (Pending Resolution)
Bao gồm **8 phân hệ**: **TKNB, PTTT, QLQ, GSTT, QLKD, NDTNN, QLCB, GSDC**.
- **Đặc điểm chung:** Tiếp nhận nguồn dữ liệu số hóa trực tiếp từ 2 Sở và VSDC để giải phóng các chỉ tiêu báo cáo nghiệp vụ đang bị tắc nghẽn ở trạng thái PENDING.
- **Giá trị đột phá:**
  - *Thị trường Trái phiếu (HNX):* Cung cấp trọn vẹn dữ liệu sổ lệnh Outright, Repo, Repo 2, đấu thầu và niêm yết TPCP; cung cấp toàn diện mảng TPDN riêng lẻ (chào bán, đăng ký, giao dịch).
  - *Dữ liệu Tài khoản & Cổ đông (VSDC):* Chuẩn hóa mã tài khoản NĐT, phân loại đối tượng NĐT, giám sát cổ đông lớn và tỷ lệ sở hữu nước ngoài chính thức.
  - *Thị phần môi giới (HNX/HOSE):* Số hóa thị phần top CTCK theo quý phục vụ giám sát an toàn tài chính và niên giám thống kê.

#### 3.2.3. Nhóm 3: Các phân hệ an toàn / không chịu tác động phá vỡ (Safe Subsystems)
Bao gồm **2 phân hệ**: **TT (Thanh tra)** và **VP (Văn phòng)**.
- **Phân hệ TT:** Đạt điểm tuyệt đối 100% PASS trên Gate 0. Quyết định đổi tên `pd` sang `penalty_decision` của Atomic đã loại bỏ hoàn toàn nguy cơ lệch pha tiềm ẩn, giúp bảo vệ toàn vẹn thiết kế 7 bảng Fact/Dim của Thanh tra.
- **Phân hệ VP:** Không khai thác trực tiếp dữ liệu thô từ sàn mà tổng hợp thông tin qua tầng báo cáo thống kê nội bộ (`internal_statistical_report`), do đó hoàn toàn miễn nhiễm trước các thay đổi schema của 28 bảng Atomic mới.

---

## CHƯƠNG 4: PHÂN TÍCH TÁC ĐỘNG CHI TIẾT CHO TỪNG PHÂN HỆ (11 PHÂN HỆ ĐỘC LẬP)

### 4.1. Phân hệ GSDC (Giám sát công ty đại chúng)

#### a) Gãy vỡ tham chiếu & Nguyên nhân kỹ thuật
- **File vi phạm:** `Datamart/lld/GSDC/DTM_GSDC_fct_public_company_listed_share_snpst.csv` (dòng 2 đến dòng 7).
- **Hiện tượng lỗi:** Script `check_references.py` báo lỗi:
  ```text
  [!] [L0-ATOMIC-COLUMN-NOT-FOUND] fct_public_company_listed_share_snpst.treasury_share_quantity: 
      Bảng Atomic listed_share_info không tìm thấy trong DataModel/Atomic/ lẫn DataModel/working/Atomic/lld/.
  ```
- **Chuẩn hóa phân loại mức độ nghiêm trọng (Severity Classification):**
  - Trong logic mã nguồn của `reference_checker.py`, lỗi không tìm thấy bảng Atomic được xếp là **WARNING** (ký hiệu hiển thị `[!]`), không phải **CRITICAL** (ký hiệu `[X]`).
  - Do đó, khi chạy Gate 0 (`check_references.py -m GSDC`), phân hệ GSDC trả về **0 lỗi Critical và 55 lỗi Warning** (trong đó có 1 warning về bảng `listed_share_info` chưa khớp tên chuẩn Atomic và 54 warning về các cột kỹ thuật/tham chiếu kế thừa).
- **Nguyên nhân:** File LLD của GSDC khai báo `atomic_table: listed_share_info` (tên viết tắt bản thảo). Trong khi đó, tại commit `12a55eab`, file Atomic ban hành chính thức là `DataModel/working/Atomic/lld/VSDC/lld_VSDC_OUTSTANDING_SHARES.yaml` có:
  ```yaml
  entity_physical_name: "listed_share_information"
  ```
- **Cột ngày chụp:** Tham chiếu `ds_snpst_dt`, trong khi cột ngày của `listed_share_information` là `transaction_dt` (ngày giao dịch/chốt số liệu) hoặc `:etl_date`.

#### b) Cơ hội giải phóng PENDING & Dữ liệu mới có thể tận dụng
1. **Thiết lập phân hệ Giám sát Cổ đông lớn hoàn toàn mới:**
   - Trước đây GSDC hoàn toàn thiếu vắng dữ liệu cổ đông lớn (chỉ giám sát BCTC và vốn nhà nước `pc_state_capital`).
   - Bảng mới `major_shareholder_ownership` (từ `VSDC.MAJOR_SHAREHOLDER`) cung cấp chi tiết: Tên cổ đông lớn (`major_shareholder_nm`), số giấy tờ định danh (`identification_nbr`), số lượng và tỷ lệ đầu kỳ (`opening_share_quantity`, `opening_ratio`), cuối kỳ (`closing_share_quantity`, `closing_ratio`), số cổ phiếu biểu quyết (`voting_share_quantity`), ngày chốt (`closing_balance_dt`).
   - *Đề xuất kiến trúc:* Bổ sung Fact mới `fct_public_company_major_shareholder_snpst` phục vụ giám sát biến động sở hữu trên ngưỡng 5% và nghĩa vụ công bố thông tin theo Thông tư 96/2020/TT-BTC.
2. **Giám sát thay đổi niêm yết:** Tận dụng `listing_status_change` từ 2 Sở để nắm bắt các trường hợp công ty đại chúng bị đưa vào diện kiểm soát, cảnh báo, hoặc hủy niêm yết.

#### c) Hiện trạng đồng bộ & Khoảng cách (Sync Gap)
- Tiến độ đồng bộ: **80%**. Cấu trúc phân hệ vững chắc, chỉ cần sửa 1 file LLD Fact cổ phiếu niêm yết và mở rộng thêm Fact Cổ đông lớn.

---

### 4.2. Phân hệ GSTT (Giám sát giao dịch thị trường)

#### a) Gãy vỡ tham chiếu & Nguyên nhân kỹ thuật
GSTT là phân hệ ghi nhận số lượng lỗi gãy vỡ Gate 0 lớn nhất toàn hệ thống với **29 lỗi CRITICAL và 13 lỗi WARNING**:
- **Tập trung tại file:** `Datamart/lld/GSTT/DTM_GSTT_fct_major_shareholder_ownership_snpst.csv` (29 lỗi CRITICAL).
  - *Lỗi lệch tên cột ngày:* Tham chiếu `opening_balance_date` và `closing_balance_date`, trong khi tên thuộc tính chuẩn trong Atomic `lld_VSDC_MAJOR_SHAREHOLDER.yaml` là `opening_balance_dt` và `closing_balance_dt`.
  - *Lỗi cột kỹ thuật:* Tham chiếu 15 lần trường `major_shareholder_ownership.ds_snpst_dt` trong `etl_logic` và `atomic_column`, trong khi trường này không tồn tại trong danh mục thuộc tính YAML Atomic.
  - *Bằng chứng trích xuất:*
    ```text
    [X] [L0-ATOMIC-COLUMN-NOT-FOUND] DTM_GSTT_fct_major_shareholder_ownership_snpst.csv 
        [fct_major_shareholder_ownership_snpst.ownership_share_quantity]
        Cột Atomic không tồn tại trên `major_shareholder_ownership`: `closing_balance_date` (gợi ý: `closing_balance_dt`)
    [X] [L0-ATOMIC-COLUMN-NOT-FOUND] DTM_GSTT_fct_major_shareholder_ownership_snpst.csv 
        [fct_major_shareholder_ownership_snpst.snpst_dt_dim_id]
        Cột Atomic không tồn tại trên `major_shareholder_ownership`: `ds_snpst_dt`
    ```
- **Lệch tên bảng `listed_share_info` (11 WARNING):**
  - Xuất hiện tại: `DTM_GSTT_fct_index_constituent_snpst.csv`, `DTM_GSTT_fct_stock_portfolio_snpst.csv`, và `DTM_GSTT_opr_trading_liquidity_explorer_MDDS_JAD_STOCKINFOR.csv`. Cần đổi thành `listed_share_information`.
- **Lệch cột phân loại NĐT (2 WARNING):**
  - Tham chiếu `investment_account_tp_code` không tồn tại trên `securities_trade`.

#### b) Cơ hội giải phóng PENDING & Dữ liệu mới có thể tận dụng
1. **Hoàn thiện giám sát Cổ đông lớn (Nhóm 35 & 38):** Sửa lỗi LLD sẽ mở khóa hoàn toàn Dashboard Giám sát Cổ đông lớn và giao dịch nội bộ của GSTT.
2. **Chuẩn hóa phân loại Nhà đầu tư:** Thay thế toàn bộ quy tắc bẫy ký tự tài khoản tạm thời ('P','E','F') bằng liên kết chính thức với bộ 3 bảng tài khoản VSDC (`open_investor_account`, `closed_investor_account`, `updated_investor_account`).
3. **Giám sát giao dịch Trái phiếu HNX:** Tận dụng bảng hợp nhất `bond_order_book` để phát hiện các dấu hiệu thao túng giá hoặc giao dịch bất thường trên thị trường trái phiếu Outright và Repo.

#### c) Hiện trạng đồng bộ & Khoảng cách (Sync Gap)
- Tiến độ đồng bộ: **60%**. HLD đã nâng cấp v4.54, nhưng tầng LLD chi tiết bị lệch nghiêm trọng so với YAML Atomic mới.

---

### 4.3. Phân hệ NDTNN (Quản lý nhà đầu tư nước ngoài)

#### a) Gãy vỡ tham chiếu & Nguyên nhân kỹ thuật
- **File vi phạm:** `Datamart/lld/NDTNN/DTM_NDTNN_fct_public_company_foreign_ownership_snpst.csv`.
- **Số lượng lỗi:** **0 CRITICAL, 9 WARNING**.
- **Nguyên nhân kỹ thuật:** Cả 9 dòng trong file LLD đều khai báo `atomic_table: foreign_ownership_info` (dạng viết tắt), trong khi tên bảng vật lý chuẩn tại `lld_VSDC_FOREIGN_INVESTOR_INFO.yaml` là `foreign_ownership_information`.
- **Đánh giá toàn vẹn:** 100% các cột nghiệp vụ (`total_issued_share_quantity`, `max_foreign_ownership_ratio`, `max_foreign_holding_quantity`, `current_foreign_holding_quantity`, `remaining_foreign_holding_quantity`, `ticker_symbol`) đều khớp chuẩn 1:1 với Atomic.

#### b) Cơ hội giải phóng PENDING & Dữ liệu mới có thể tận dụng
1. **Kiểm soát Room ngoại chính xác từ VSDC:** Bảng `foreign_ownership_information` cung cấp số liệu room ngoại hàng ngày chính thức được VSDC xác nhận, giúp loại bỏ hoàn toàn các sai số do tự tính toán từ giao dịch khớp lệnh.
2. **Mở rộng Giám sát Danh mục Trái phiếu của NĐTNN:** Tận dụng bảng mới `foreign_bond_portfolio` (từ `VSDC.FOREIGN_INVESTOR_BOND_PORTFOLIO`) để giám sát cơ cấu nắm giữ trái phiếu của khối ngoại theo từng tháng, mã trái phiếu và quốc tịch.
3. **Chuẩn hóa Quốc tịch:** Tận dụng bảng danh mục `cl_vsdc_nationality` để đồng bộ hóa mã quốc gia NĐTNN.

#### c) Hiện trạng đồng bộ & Khoảng cách (Sync Gap)
- Tiến độ đồng bộ: **95%**. Đã đạt chuẩn Gate 0 PASS, chỉ cần đổi tên bảng 9 dòng trong file LLD.

---

### 4.4. Phân hệ NHNCK (Người hành nghề & Cổ đông lớn)

#### a) Gãy vỡ tham chiếu & Nguyên nhân kỹ thuật
Ghi nhận **14 lỗi CRITICAL và 10 lỗi WARNING**:
- **Điểm 1 — Bảng vi phạm hành nghề:**
  - Files: `DTM_NHNCK_fct_practitioner_daily_snpst.csv` và `DTM_NHNCK_opr_practitioner_violation_hist_NHNCK_VIOLATIONS.csv`.
  - Tham chiếu `atomic_table: sp_conduct_violation`. Trong khi tên bảng vật lý Atomic đã duyệt trong `dm_atm_sp_violation-NHNCK.VIOLATIONS.yaml` là `sp_violation`.
- **Điểm 2 — Cầu nối tài khoản và cổ đông lớn:**
  - File: `DTM_NHNCK_opr_practitioner_list_company_role_NHNCK_PROFESSIONALS.csv` (dòng 8 đến 11).
  - Dòng 8-9 tham chiếu `discretionary_investment_account` (thiếu cột) do trước đây chưa có bảng tài khoản VSDC.
  - Dòng 10-11 tham chiếu `atomic_table: major_shareholder` (cột `securities_code`, `closing_security_quantity`), trong khi Atomic ban hành là `major_shareholder_ownership` (cột `ticker_symbol`, `closing_share_quantity`).

#### b) Cơ hội giải phóng PENDING & Dữ liệu mới có thể tận dụng
- **Giải quyết triệt để bài toán kiểm soát xung đột lợi ích (Đóng O_NHNCK_33):**
  - Sử dụng số CMND/CCCD của người hành nghề (`identification_nbr`) làm khóa nối sang `open_investor_account` để tra cứu toàn bộ số tài khoản giao dịch chứng khoán đứng tên người hành nghề.
  - Nối sang `major_shareholder_ownership` để kiểm tra người hành nghề có đồng thời là cổ đông lớn của các tổ chức niêm yết hay không, phục vụ giám sát tuân thủ Luật Chứng khoán 2019.

#### c) Hiện trạng đồng bộ & Khoảng cách (Sync Gap)
- Tiến độ đồng bộ: **70%**. Cần sửa đổi 3 file LLD để dứt điểm các lỗi lệch bảng và khóa nối tài khoản.

---

### 4.5. Phân hệ PTTT (Phân tích & Phát triển thị trường)

#### a) Gãy vỡ tham chiếu & Nguyên nhân kỹ thuật
- **Lỗi do Atomic mới (1 CRITICAL, 3 WARNING):**
  1. *Lỗi cột kỹ thuật:* Tại `DTM_PTTT_fct_futures_intraday_snpst.csv` (cột `open_interest_quantity`), `etl_logic` tham chiếu `end_of_day_open_interest.ds_snpst_dt` không tồn tại trong YAML (1 CRITICAL).
  2. *Lỗi lệch tên cột TPDN:* Tại `DTM_PTTT_fct_corporate_bond_maturity_wall.csv`, cột `snpst_dt_dim_id` tham chiếu `report_month` (tên đúng: `rpt_month`); cột `maturity_dt` tham chiếu `maturity_date` (tên đúng: `maturity_dt`) trên `private_corp_bond_offering` (2 WARNING).
  3. *Lỗi tên bảng cổ phiếu:* 4 WARNING do dùng `listed_share_info` thay vì `listed_share_information`.
- **Lỗi tiền định (Pre-existing issues, không do Atomic mới):** 15 CRITICAL trên Fact an toàn vốn/rủi ro do tham chiếu `sc_report_input_value.item_val` (tên đúng: `cell_val`).

#### b) Cơ hội giải phóng PENDING & Dữ liệu mới có thể tận dụng
1. **Giải quyết dứt điểm câu hỏi mở O_PTTT_26 (Bước ngoặt mảng Trái phiếu):**
   - *Vấn đề cũ:* Thiết kế cũ chỉ lọc sàn HOSE (`market_id_code = 'BDO'`), bỏ sót toàn bộ thị trường TPDN riêng lẻ HNX (`HCX`) chiếm >90% thanh khoản.
   - *Giải pháp từ Atomic:* Tận dụng trực tiếp `private_corp_bond_trading_summary` (thống kê giao dịch theo ngày của HNX) và `bond_order_book` (chi tiết lệnh Outright và Repo) để bao phủ toàn diện thị trường nợ Việt Nam.
2. **Khôi phục toàn diện Nhóm 19 (Maturity Wall):**
   - Tận dụng `private_corp_bond_offering` và `private_corp_bond_registration` để khôi phục cấu trúc Fact Lịch biểu đáo hạn TPDN, mở khóa 4 chỉ tiêu True Pending phân rã theo kỳ hạn (<3T, 3-6T, 6-12T, 1-3N, >3N).
3. **Khắc phục lỗi Grain Mismatch Nhóm 21 (TCPH):**
   - Gom nhóm `SUM(bond_outstanding_val) GROUP BY pc_id` từ `private_corp_bond_registration` để khắc phục lỗi nhân bản dòng theo mã trái phiếu.

#### c) Hiện trạng đồng bộ & Khoảng cách (Sync Gap)
- Tiến độ đồng bộ: **75%**. Cần cập nhật LLD theo schema chuẩn và tái cấu trúc Fact TPDN.

---

### 4.6. Phân hệ QLCB (Quản lý chào bán chứng khoán)

#### a) Gãy vỡ tham chiếu & Nguyên nhân kỹ thuật
- **Kết quả kiểm tra Gate 0:** **PASS 100%** (0 lỗi CRITICAL, 0 lỗi WARNING). Toàn bộ 68 dòng LLD và 89 dòng Detail Mapping đều khớp hoàn toàn với các bảng Atomic hiện hữu (IDS, TTHC).
- Không có bất kỳ điểm gãy vỡ tham chiếu nào phát sinh từ commit `aff9a023` và `12a55eab`.

#### b) Cơ hội giải phóng PENDING & Dữ liệu mới có thể tận dụng
1. **Mở rộng năng lực Giám sát Bán đấu giá cổ phần công khai:**
   - Khai thác thực thể `share_auction_result` (từ `HNX.SHARE_AUCTION` và `HOSE.SHARE_AUCTION`).
   - Cung cấp toàn bộ chỉ tiêu: Giá khởi điểm, giá trúng bình quân, lượng chào bán, lượng đặt mua, phân rã NĐT cá nhân/tổ chức, trong nước/nước ngoài, và tổng giá trị thanh toán thực tế.
   - *Đề xuất kiến trúc:* Bổ sung Fact mới `fct_securities_share_auction_snpst`.
2. **Kiểm chứng độc lập Kết quả chào bán tăng vốn:**
   - Sử dụng `listed_share_information` (từ `VSDC.OUTSTANDING_SHARES`) để đối soát chéo số lượng cổ phiếu lưu hành chốt tại VSDC sau đợt chào bán so với số liệu tự báo cáo của doanh nghiệp trong `pc_securities_offering_result`.
3. **Giám sát nghĩa vụ đưa chứng khoán vào giao dịch:** Tận dụng `listing_status_change` để theo dõi thời hạn 30 ngày niêm yết/đăng ký giao dịch sau khi hoàn tất chào bán.

#### c) Hiện trạng đồng bộ & Khoảng cách (Sync Gap)
- Tiến độ đồng bộ: **100%** trên phạm vi hiện tại; sẵn sàng mở rộng nghiệp vụ trong giai đoạn tiếp theo.

---

### 4.7. Phân hệ QLKD (Quản lý kinh doanh chứng khoán)

#### a) Gãy vỡ tham chiếu & Nguyên nhân kỹ thuật
- **File vi phạm:** `Datamart/lld/QLKD/DTM_QLKD_fct_securities_company_brokerage_market_share_snpst.csv` (dòng 2, cột `snpst_dt_dim_id`).
- **Hiện tượng:** Phát sinh **3 lỗi CRITICAL** Gate 0 `L0-ATOMIC-COLUMN-NOT-FOUND`.
- **Nguyên nhân kỹ thuật:** LLD Fact Thị phần môi giới sử dụng `brokerage_market_share.ds_snpst_dt` làm khóa lookup ngày:
  ```csv
  LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = brokerage_market_share.ds_snpst_dt AND brokerage_market_share.ds_snpst_dt = :etl_date
  ```
  Tuy nhiên, trường `ds_snpst_dt` là cột kỹ thuật staging đã bị loại khỏi YAML Atomic. Bảng thị phần môi giới quản lý thời gian theo quý báo cáo `rpt_quarter` (ví dụ: 'Q1/2026').

#### b) Cơ hội giải phóng PENDING & Dữ liệu mới có thể tận dụng
- **Mở khóa toàn diện Nhóm 17 (Thị phần môi giới CTCK theo quý từ 2 Sở):**
  - Thực thể `brokerage_market_share` (kết hợp HNX và HOSE) cung cấp trọn vẹn: Mã CTCK (`sc_member_code`), tên CTCK (`sc_nm`), tổng giá trị giao dịch (`total_trading_val`), thị phần giá trị (`market_share_by_val`), phân loại thị trường (`security_tp_code`: cổ phiếu niêm yết, UPCoM, phái sinh), quý báo cáo (`rpt_quarter`), nguồn Sở (`src_stm_code`).
  - Cho phép hoàn thiện 100% Fact thị phần môi giới CTCK.

#### c) Hiện trạng đồng bộ & Khoảng cách (Sync Gap)
- Tiến độ đồng bộ: **90%** (Tiên phong trong việc đồng bộ thiết kế). Chỉ cần sửa 1 dòng logic lookup ngày tại file LLD Fact thị phần môi giới.

---

### 4.8. Phân hệ QLQ (Quản lý quỹ đầu tư chứng khoán)

#### a) Gãy vỡ tham chiếu & Nguyên nhân kỹ thuật
- **File vi phạm:** `Datamart/lld/QLQ/DTM_QLQ_fund_management_company_staff_trade_rpt_ORDERTRADE.csv`.
- **Hiện tượng:** Phát sinh **13 lỗi CRITICAL** Gate 0 do `etl_logic` tham chiếu:
  `discretionary_investment_account.investment_account_nbr`, `identification_nbr`, `event_dt`.
- **Nguyên nhân gốc rễ:** Do trước đây tầng Atomic thiếu nguồn tài khoản VSDC, người thiết kế Nhóm 28 đã tạm nối qua bảng tài khoản ủy thác FMS. Tại `DTM_QLQ_Detail_Mapping.csv` (dòng 175-182) đã ghi rõ: *"đường nối 2026-10-15 trỏ sai entity. Chờ Atomic bổ sung entity tài khoản giao dịch CK từ VSDC (O_QLQ_39)"*.

#### b) Cơ hội giải phóng PENDING & Dữ liệu mới có thể tận dụng
1. **Giải quyết dứt điểm Blocker Nhóm 28 (10 KPI PENDING):**
   - Các KPI giải phóng: `K_QLQ_106` đến `K_QLQ_115` (Báo cáo thống kê giao dịch của nhân viên công ty QLQ).
   - Nguồn Atomic mới: `open_investor_account` và `updated_investor_account` (từ `VSDC.OPEN_INVESTORS` và `UPDATED_INVESTORS`).
   - Khóa nối chuẩn: Nối số CCCD/CMND nhân viên (`tl_profiles.id_no`) với `open_investor_account.identification_nbr` để lấy ra số tài khoản giao dịch chứng khoán (`investor_account_nbr`), sau đó nối vào sổ lệnh khớp để giám sát toàn bộ giao dịch mua/bán của nhân viên.
   - *Ý nghĩa:* Đóng vĩnh viễn câu hỏi mở `O_QLQ_39` và chuyển 10 KPI sang READY.
2. **Giám sát sở hữu chứng chỉ quỹ của NĐT nước ngoài:** Khai thác `foreign_ownership_information` và `cl_vsdc_nationality`.

#### c) Hiện trạng đồng bộ & Khoảng cách (Sync Gap)
- Tiến độ đồng bộ: **82.5%**. Sau khi cập nhật LLD Nhóm 28, tiến độ hoàn thành sẽ đạt **88.0%**.

---

### 4.9. Phân hệ TKNB (Thống kê nội bộ UBCKNN)

#### a) Gãy vỡ tham chiếu & Nguyên nhân kỹ thuật
Ghi nhận **29 lỗi CRITICAL và 4 lỗi WARNING liên quan trực tiếp đến Atomic** (tổng số 28 cảnh báo Warning đo đạc trên toàn phân hệ):
- **4 File vi phạm Critical:**
  1. `DTM_TKNB_private_corporate_bond_dim_HNX_PRIVATE_CORP_BOND_OFFERING.csv` (15 lỗi Critical).
  2. `DTM_TKNB_fct_private_corporate_bond_international_offering_snpst.csv` (7 lỗi Critical).
  3. `DTM_TKNB_fct_private_corporate_bond_issuance_snpst.csv` (6 lỗi Critical).
  4. `DTM_TKNB_fct_derivatives_security_detail_snpst.csv` (1 lỗi Critical).
- **Nguyên nhân chi tiết:**
  - **Nhóm TPDN riêng lẻ (28 lỗi Critical):** Tham chiếu cột kỹ thuật `ds_snpst_dt` không có trong YAML Atomic trên `private_corp_bond_offering` và `private_corp_bond_registration` (trong khi cột nghiệp vụ là `posting_dt` và `issue_dt`); lệch tên cột mệnh giá: TKNB viết `par_value` (tên đúng trong Atomic LLD là `par_val`).
  - **Nhóm Hợp đồng Phái sinh (1 lỗi Critical):** Tại file `DTM_TKNB_fct_derivatives_security_detail_snpst.csv` (chỉ tiêu `open_interest_quantity`), `etl_logic` tham chiếu `end_of_day_open_interest.ds_snpst_dt`. Bảng `end_of_day_open_interest` là bảng mới của VSDC (commit `12a55eab`), không chứa cột `ds_snpst_dt`.
  - **Nhóm cảnh báo Warning (4 Warning liên quan Atomic/Desync):**
    + 2 Warning do tham chiếu bảng viết tắt `foreign_ownership_info` (tên đúng: `foreign_ownership_information`) tại `DTM_TKNB_fct_security_trading_detail_snpst.csv` (`max_foreign_ownership_ratio`, `remaining_foreign_ownership_ratio`).
    + 2 Warning lệch trạng thái tài liệu `L0-HLD-LLD-STATUS-DESYNC` tại `K_TKNB_396` và `K_TKNB_398` (HLD ghi READY nhưng Detail Mapping để trống mart_table/mart_column).

#### b) Cơ hội giải phóng PENDING & Dữ liệu mới có thể tận dụng
TKNB là phân hệ hưởng lợi **LỚN NHẤT TOÀN DỰ ÁN** từ đợt cập nhật Atomic:
1. **Giải phóng 135+ KPI PENDING về Trái phiếu Chính phủ (TPCP):**
   - Theo tài liệu bàn giao `TKNB_BA_Handoff_Blocked_Sources.md`, TKNB có 142 KPI bị blocked vì thiếu nguồn HNX:
     - **132 KPI** (Nhóm 2 Báo cáo HNX02 và Nhóm 17 Niên giám K_TKNB_936, 949) chờ biểu mẫu HNX.BM24 (Giao dịch TPCP theo Outright và Repo).
     - **2 KPI** (Nhóm 17 K_TKNB_962, 975) chờ HNX.BM25 (Niêm yết bổ sung TPCP).
     - **1 KPI** (Nhóm 17 K_TKNB_993) chờ HNX.BM28 (Danh sách TPCP niêm yết).
   - *Nguồn Atomic mới đáp ứng 100%:*
     - Bảng `bond_order_book` (từ `HNX.OUTRIGHT_ORDER_BOOK`, `REPO_ORDER_BOOK`, `REPO2_ORDER_BOOK`) thay thế hoàn hảo HNX.BM24, giải phóng 132 KPI!
     - Bảng `additional_gov_bond_listing` thay thế HNX.BM25, giải phóng 2 KPI!
     - Bảng `gov_bond_listing` thay thế HNX.BM28, giải phóng 1 KPI!
     - Bảng `gov_bond_bidding_result` bổ sung hoạt động phát hành/đấu thầu TPCP.
2. **Hoàn thiện Thống kê TPDN riêng lẻ:** Bộ bảng `private_corp_bond_*` giải quyết dứt điểm các chỉ tiêu điều chỉnh tăng/giảm đăng ký giao dịch TPDN (K_TKNB_534, K_TKNB_535).
3. **Thống kê Tài khoản NĐT toàn thị trường:** `open_investor_account` và `closed_investor_account` cung cấp số liệu mở/đóng tài khoản NĐT phục vụ Báo cáo tổng hợp TTCK (TK-04.BTC) và Niên giám.

#### c) Hiện trạng đồng bộ & Khoảng cách (Sync Gap)
- Tiến độ đồng bộ: **45%**. Cần tái cấu trúc mapping và xây dựng các Fact mới cho mảng Trái phiếu.

---

### 4.10. Phân hệ TT (Thanh tra chứng khoán)

#### a) Gãy vỡ tham chiếu & Nguyên nhân kỹ thuật
- **Kết quả kiểm tra Gate 0:** **PASS 100% (0 Critical, 0 Warning)**.
- **Phân tích kỹ thuật chuyên sâu:**
  - Trước commit `aff9a023`, file LLD Atomic khai báo tên bảng vật lý viết tắt `pd`.
  - Tuy nhiên, toàn bộ thiết kế Datamart của phân hệ TT (gồm 7 bảng Fact/Dim: `penalty_decision_dim`, `penalty_decision_subject_dim`, `fct_penalty_decision`, `fct_penalty_decision_subject`, `fct_penalty_decision_subject_behavior`, `opr_penalty_decision_list`) đã tiên phong sử dụng tên chuẩn `penalty_decision`.
  - Do đó, commit `aff9a023` đã chính thức đồng bộ tầng Atomic theo chuẩn của Datamart TT, **xóa bỏ hoàn toàn rủi ro gãy vỡ tiềm ẩn**.

#### b) Cơ hội giải phóng PENDING & Dữ liệu mới có thể tận dụng
- Phân hệ TT đã ở trạng thái sẵn sàng 100% về mặt thiết kế dữ liệu. 13 chỉ tiêu pending hiện tại đều là chỉ tiêu phái sinh nội bộ (DERIVED SSCK) thuộc trách nhiệm tính toán của ứng dụng nghiệp vụ, không phụ thuộc vào nguồn dữ liệu bên ngoài.

#### c) Hiện trạng đồng bộ & Khoảng cách (Sync Gap)
- Tiến độ đồng bộ: **100% Hoàn hảo**. Là phân hệ kiểu mẫu của dự án.

---

### 4.11. Phân hệ VP (Văn phòng / Quản trị điều hành)

#### a) Gãy vỡ tham chiếu & Nguyên nhân kỹ thuật
- **Kết quả kiểm tra:** Không có bất kỳ lỗi gãy vỡ bảng Atomic nào.
- **Nguyên nhân kiến trúc:** Phân hệ VP được thiết kế để phục vụ công tác báo cáo quản trị cấp cao của Lãnh đạo Ủy ban, do đó toàn bộ các bảng Fact/Dim đều khai thác gián tiếp thông qua tầng báo cáo thống kê nội bộ tổng hợp (`internal_statistical_report`).
- *Lưu ý:* Các cảnh báo hiện hữu trong phân hệ VP chỉ là cảnh báo lệch trạng thái tài liệu `L0-HLD-LLD-STATUS-DESYNC` (Detail Mapping ghi READY nhưng HLD ghi PENDING kế thừa từ các phiên trước).

#### b) Cơ hội giải phóng PENDING & Dữ liệu mới có thể tận dụng
- Mô hình hoạt động ổn định độc lập. Trong tương lai, nếu có nhu cầu chuyển đổi sang đọc dữ liệu trực tiếp:
  - Nhóm 43 (Đấu giá cổ phần): Có thể chuyển sang đọc trực tiếp từ `share_auction_result`.
  - Nhóm 11-13 (Giao dịch TPDN): Có thể chuyển sang đọc trực tiếp từ `private_corp_bond_trading_summary`.

#### c) Hiện trạng đồng bộ & Khoảng cách (Sync Gap)
- Tiến độ đồng bộ: **90% Ổn định**. Không yêu cầu điều chỉnh gấp.

---

## CHƯƠNG 5: KẾ HOẠCH HÀNH ĐỘNG & LỘ TRÌNH KHẮC PHỤC (REMEDIATION ROADMAP)

### 5.1. Khung phân cấp ưu tiên giải pháp (P1 / P2 / P3)

Để đảm bảo toàn bộ hệ thống Datamart nhanh chóng vượt qua chốt chặn kiểm định chất lượng (Quality Gates 0-8) và tối đa hóa giá trị khai thác dữ liệu mới, lộ trình khắc phục được phân bổ thành 3 cấp độ ưu tiên:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        LỘ TRÌNH KHẮC PHỤC HỆ THỐNG 3 CẤP ĐỘ                           │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 🔴 P1: CRITICAL BLOCKERS (Khắc phục ngay lập tức trong Sprint hiện tại)                │
│    Mục tiêu: Sửa dứt điểm 89 lỗi Critical Gate 0, thông luồng tham chiếu bảng/cột.     │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 🟡 P2: MAJOR ALIGNMENT & PENDING RESOLUTION (Triển khai trong Sprint tiếp theo)        │
│    Mục tiêu: Chuẩn hóa 40 cảnh báo Warning liên quan Atomic, chuyển trạng thái 160+     │
│    KPI PENDING sang READY, đóng vĩnh viễn các câu hỏi mở O_PTTT_26, O_QLQ_39,          │
│    O_NHNCK_33.                                                                         │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 🟢 P3: SCHEMA RECOVERY & ADVANCED EXPANSION (Kế hoạch phát triển tiếp theo)            │
│    Mục tiêu: Thiết kế các bảng Fact/Dim mới (Đấu giá cổ phần QLCB, Cổ đông lớn GSDC,   │
│    Khôi phục Maturity Wall PTTT Nhóm 19, Tái cấu trúc Grain Nhóm 21).                  │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### 5.2. Bảng Action Items chi tiết toàn diện

Bảng danh mục hành động kỹ thuật dưới đây chỉ định chính xác mã hành động, phân hệ, mức độ ưu tiên, file cần điều chỉnh, lỗi kỹ thuật, giải pháp xử lý và bộ phận chịu trách nhiệm:

| Mã Action | Phân Hệ | Mức Ưu Tiên | File Cần Điều Chỉnh | Chi Tiết Lỗi Kỹ Thuật / Vấn Đề | Phương Án Khắc Phục Cụ Thể | Bộ Phận Chịu Trách Nhiệm |
|:---:|:---:|:---:|---|---|---|:---:|
| **ACT-P1-01** | **GSTT** | 🔴 **P1** | `Datamart/lld/GSTT/DTM_GSTT_fct_major_shareholder_ownership_snpst.csv` | Lệch 29 lỗi trên bảng `major_shareholder_ownership` (`opening_balance_date`, `closing_balance_date`, `ds_snpst_dt`). | 1. Đổi `opening_balance_date` → `opening_balance_dt`.<br>2. Đổi `closing_balance_date` → `closing_balance_dt`.<br>3. Bỏ tham chiếu `ds_snpst_dt`, đổi `snpst_dt_dim_id` sang lấy `closing_balance_dt` hoặc `:etl_date`. | Data Modeler (GSTT) |
| **ACT-P1-02**<br>*(ACT-GB-01)* | **TKNB** | 🔴 **P1** | - `DTM_TKNB_fct_private_corporate_bond_international_offering_snpst.csv`<br>- `DTM_TKNB_fct_private_corporate_bond_issuance_snpst.csv`<br>- `DTM_TKNB_private_corporate_bond_dim_HNX_PRIVATE_CORP_BOND_OFFERING.csv`<br>- `DTM_TKNB_fct_derivatives_security_detail_snpst.csv` | Tham chiếu cột kỹ thuật `ds_snpst_dt` không có trong YAML Atomic; lệch tên cột `par_value`; tham chiếu `end_of_day_open_interest.ds_snpst_dt` (29 lỗi Critical tổng cộng). | 1. TPDN: Đổi điều kiện lọc `ds_snpst_dt` sang `posting_dt` hoặc `issue_dt`; đổi `par_value` → `par_val` theo đúng chuẩn LLD Atomic HNX.<br>2. Phái sinh: Tại `DTM_TKNB_fct_derivatives_security_detail_snpst.csv` (cột `open_interest_quantity`), loại bỏ tham chiếu `end_of_day_open_interest.ds_snpst_dt`, chuyển sang lọc theo partition runtime `:etl_date` hoặc `trading_dt`. | Data Modeler (TKNB) |
| **ACT-P1-03** | **NHNCK**| 🔴 **P1** | - `DTM_NHNCK_fct_practitioner_daily_snpst.csv`<br>- `DTM_NHNCK_opr_practitioner_violation_hist_NHNCK_VIOLATIONS.csv` | Tham chiếu `atomic_table: sp_conduct_violation` không tồn tại (8 lỗi Critical). | Đổi `sp_conduct_violation` → `sp_violation` theo đúng manifest `dm_atm_sp_violation-NHNCK.VIOLATIONS.yaml`. | Data Modeler (NHNCK) |
| **ACT-P1-04** | **NHNCK**| 🔴 **P1** | `DTM_NHNCK_opr_practitioner_list_company_role_NHNCK_PROFESSIONALS.csv` | Tham chiếu `discretionary_investment_account` và `major_shareholder` sai schema (6 lỗi Critical). | 1. Dòng 8-9: Chuyển sang `open_investor_account` (cột `investor_account_nbr`, `investor_nm`).<br>2. Dòng 10-11: Chuyển sang `major_shareholder_ownership` (cột `ticker_symbol`, `closing_share_quantity`). | Data Modeler (NHNCK) |
| **ACT-P1-05** | **QLQ** | 🔴 **P1** | `Datamart/lld/QLQ/DTM_QLQ_fund_management_company_staff_trade_rpt_ORDERTRADE.csv` | Đường nối tạm `discretionary_investment_account` gây 13 lỗi Critical Gate 0. | Thay thế toàn bộ liên kết sang `open_investor_account` (nối qua `identification_nbr = tl_profiles.id_no`), đóng câu hỏi mở `O_QLQ_39`. | Data Modeler (QLQ) |
| **ACT-P1-06** | **QLKD** | 🔴 **P1** | `Datamart/lld/QLKD/DTM_QLKD_fct_securities_company_brokerage_market_share_snpst.csv` | Dòng 2 trỏ `brokerage_market_share.ds_snpst_dt` không tồn tại (3 lỗi Critical). | Sửa logic lookup ngày: Dùng hàm `LAST_DAY_OF_QUARTER(rpt_quarter)` hoặc lấy theo runtime date `:etl_date`. Loại bỏ `ds_snpst_dt`. | Data Modeler (QLKD) |
| **ACT-P1-07** | **PTTT** | 🔴 **P1** | `Datamart/lld/PTTT/DTM_PTTT_fct_futures_intraday_snpst.csv` | Cột `open_interest_quantity` trỏ `end_of_day_open_interest.ds_snpst_dt` không tồn tại (1 Critical). | Sửa `etl_logic`: Bỏ điều kiện `end_of_day_open_interest.ds_snpst_dt`, lấy theo runtime partition `:etl_date` hoặc join theo `trading_dt`. | Data Modeler (PTTT) |
| **ACT-P1-08** | **GSDC** | 🟡 **P2 / P1** | `Datamart/lld/GSDC/DTM_GSDC_fct_public_company_listed_share_snpst.csv` | Trỏ tới bảng viết tắt `listed_share_info` và cột `ds_snpst_dt` (0 Critical, 1 Warning do Atomic / 55 Warning Gate 0). | 1. Sửa `atomic_table` từ `listed_share_info` → `listed_share_information`.<br>2. Sửa cột thời gian sang `transaction_dt` hoặc `:etl_date`. | Data Modeler (GSDC) |
| **ACT-P2-01** | **NDTNN**| 🟡 **P2** | `Datamart/lld/NDTNN/DTM_NDTNN_fct_public_company_foreign_ownership_snpst.csv` | 9 dòng khai báo tên bảng viết tắt `foreign_ownership_info` (9 Warning). | Đổi `foreign_ownership_info` → `foreign_ownership_information` đồng bộ trên 9 dòng LLD. | Data Modeler (NDTNN) |
| **ACT-P2-02** | **PTTT** | 🟡 **P2** | `Datamart/lld/PTTT/DTM_PTTT_fct_corporate_bond_maturity_wall.csv` | Lệch tên cột `report_month` và `maturity_date` trên `private_corp_bond_offering` (2 Warning). | 1. Sửa `report_month` → `rpt_month`.<br>2. Sửa `maturity_date` → `maturity_dt`. | Data Modeler (PTTT) |
| **ACT-P2-03** | **PTTT & GSTT**| 🟡 **P2**| - `DTM_PTTT_fct_corporate_bond_sector_snpst.csv`<br>- `DTM_PTTT_fct_corporate_bond_maturity_wall.csv`<br>- `DTM_PTTT_opr_corporate_bond_issuer_credit_monitor.csv`<br>- `DTM_GSTT_fct_index_constituent_snpst.csv`<br>- `DTM_GSTT_fct_stock_portfolio_snpst.csv`<br>- `DTM_GSTT_opr_trading_liquidity_explorer_MDDS_JAD_STOCKINFOR.csv` | Lệch tên bảng viết tắt `listed_share_info` (14 Warning tổng cộng). | Đổi `listed_share_info` → `listed_share_information` đồng bộ trên toàn bộ các file LLD tương ứng. | Data Modeler (PTTT & GSTT) |
| **ACT-P2-04** | **PTTT** | 🟡 **P2** | `Datamart/lld/PTTT/DTM_PTTT_fct_corporate_bond_market_snpst.csv` & HLD | Câu hỏi mở O_PTTT_26: Bộ lọc TPDN chỉ có mã sàn HOSE `market_id_code = 'BDO'`. | Mở rộng bộ lọc sang HNX (`HCX`, `BDX`) và tích hợp nguồn mới `private_corp_bond_trading_summary` và `bond_order_book`. | Data Modeler & BA (PTTT) |
| **ACT-P2-05** | **QLQ** | 🟡 **P2** | `Datamart/lld/DTM_QLQ_Detail_Mapping.csv` & `Datamart/hld/DTM_QLQ_HLD.md` | 10 KPI Nhóm 28 (`K_QLQ_106` - `115`) đang PENDING do chờ VSDC. | Chuyển trạng thái 10 KPI sang READY, hoàn thiện logic mapping qua `open_investor_account`. Đóng O_QLQ_39. | BA & Modeler (QLQ) |
| **ACT-P2-06** | **TKNB** | 🟡 **P2** | `Datamart/hld/DTM_TKNB_HLD.md` & `Datamart/lld/DTM_TKNB_Detail_Mapping.csv` | 135+ KPI Trái phiếu đang bị blocked bởi thiếu biểu mẫu HNX.BM24, BM25, BM28. | Nâng cấp 135+ KPI sang READY bằng cách map vào `bond_order_book`, `gov_bond_listing`, `additional_gov_bond_listing`. | BA & Modeler (TKNB) |
| **ACT-P2-07** | **QLKD** | 🟡 **P2** | `Datamart/lld/DTM_QLKD_Detail_Mapping.csv` | Hoàn thiện logic ETL tính thị phần theo quý Nhóm 17. | Cập nhật logic tính thị phần môi giới kết hợp HNX và HOSE từ `brokerage_market_share`. | Data Modeler (QLKD) |
| **ACT-P3-01** | **PTTT** | 🟢 **P3** | `Datamart/lld/PTTT/DTM_PTTT_fct_corporate_bond_maturity_wall.csv` & HLD Nhóm 19 | Bảng Fact Maturity Wall bị rỗng hóa (3 cột), thiếu các bucket kỳ hạn. | Sử dụng `private_corp_bond_offering` và `registration` để khôi phục các bucket đáo hạn (<3T, 3-6T, 6-12T, 1-3N, >3N). | Data Modeler (PTTT) |
| **ACT-P3-02** | **PTTT** | 🟢 **P3** | `Datamart/lld/PTTT/DTM_PTTT_opr_corporate_bond_issuer_credit_monitor.csv` & HLD Nhóm 21 | Grain mismatch: Khóa chính gán bằng mã trái phiếu thay vì mã TCPH (`pc_id`). | Tái cấu trúc grain: Tổng hợp `SUM(bond_outstanding_val) GROUP BY pc_id` từ `private_corp_bond_registration`. | Data Modeler (PTTT) |
| **ACT-P3-03** | **GSDC** | 🟢 **P3** | `Datamart/hld/DTM_GSDC_HLD.md` & Entities | Thiếu phân hệ giám sát Cổ đông lớn công ty đại chúng. | Thiết kế Fact mới `fct_public_company_major_shareholder_snpst` dựa trên `major_shareholder_ownership`. | Lead Architect & Modeler |
| **ACT-P3-04** | **QLCB** | 🟢 **P3** | `Datamart/hld/DTM_QLCB_HLD.md` & Entities | Chưa bao phủ mảng Đấu giá cổ phần công khai tại 2 Sở. | Thiết kế Fact mới `fct_securities_share_auction_snpst` từ `share_auction_result` (HNX, HOSE). | Lead Architect & Modeler |
| **ACT-P3-05** | **NDTNN**| 🟢 **P3** | `Datamart/hld/DTM_NDTNN_HLD.md` & LLD | Chưa khai thác dữ liệu trái phiếu khối ngoại. | Tích hợp bảng `foreign_bond_portfolio` và `cl_vsdc_nationality` vào Tab Giám sát NĐTNN 360. | Data Modeler (NDTNN) |
| **ACT-P3-06** | **VP** | 🟢 **P3** | `Datamart/hld/DTM_VP_HLD.md` & Detail Mapping | Cảnh báo kế thừa `L0-HLD-LLD-STATUS-DESYNC`. | Đồng bộ trạng thái READY/PENDING giữa HLD và LLD; nghiên cứu lộ trình nối trực tiếp mảng đấu giá. | QA & Modeler (VP) |

### 5.3. Quy trình nghiệm thu chất lượng (Quality Gates Checklist) và hướng dẫn thẩm tra

Sau khi các đội ngũ Modeler và Developer hoàn tất các Action Items trên, việc kiểm định và nghiệm thu chất lượng thiết kế Datamart bắt buộc phải tuân thủ quy trình chạy tự động 9 Quality Gates (Gates 0 đến Gate 8):

1. **Kiểm tra Gate 0 — Cú pháp, Toàn vẹn Tham chiếu Mô hình (Syntax & Reference Integrity):**
   ```powershell
   # Thực thi kiểm tra toàn vẹn tham chiếu trên từng phân hệ:
   python .claude/skills/datamart-review/scripts/check_references.py -m GSTT
   python .claude/skills/datamart-review/scripts/check_references.py -m TKNB
   python .claude/skills/datamart-review/scripts/check_references.py -m QLQ
   python .claude/skills/datamart-review/scripts/check_references.py -m NHNCK
   python .claude/skills/datamart-review/scripts/check_references.py -m QLKD
   python .claude/skills/datamart-review/scripts/check_references.py -m PTTT
   python .claude/skills/datamart-review/scripts/check_references.py -m GSDC
   python .claude/skills/datamart-review/scripts/check_references.py -m NDTNN
   python .claude/skills/datamart-review/scripts/check_references.py -m QLCB
   python .claude/skills/datamart-review/scripts/check_references.py -m TT
   python .claude/skills/datamart-review/scripts/check_references.py -m VP
   ```
   *Tiêu chí nghiệm thu Gate 0:* **100% 11 phân hệ đạt 0 Critical Error.**

2. **Kiểm tra Lint Thiết kế & Chuẩn đặt tên (Design Lint Rules L0 - L24):**
   ```powershell
   # Thực thi kiểm tra Lint theo từng module cụ thể (tham số -m <MODULE> là bắt buộc):
   python .claude/skills/datamart-review/scripts/check_design_lint.py -m GSTT
   python .claude/skills/datamart-review/scripts/check_design_lint.py -m TKNB
   python .claude/skills/datamart-review/scripts/check_design_lint.py -m TT

   # Hoặc thực thi kiểm tra quét toàn bộ 11 phân hệ bằng vòng lặp PowerShell:
   $modules = @("GSTT", "TKNB", "QLQ", "NHNCK", "QLKD", "PTTT", "GSDC", "NDTNN", "QLCB", "TT", "VP")
   foreach ($m in $modules) { python .claude/skills/datamart-review/scripts/check_design_lint.py -m $m }
   ```
   *Tiêu chí nghiệm thu Lint:* Không có vi phạm đặt tên bảng viết tắt (`listed_share_info`, `foreign_ownership_info`) và không có vi phạm thiếu khóa chính PK/BK.

3. **Chạy Runner Tổng hợp Quality Gates Toàn diện:**
   ```powershell
   # Thực thi kiểm tra toàn diện Quality Gates trên từng module:
   python .claude/skills/datamart-review/scripts/run_quality_gates.py -m TT

   # Hoặc thực thi kiểm tra toàn bộ các phân hệ bằng tham số -m all:
   python .claude/skills/datamart-review/scripts/run_quality_gates.py -m all
   ```
   *Tiêu chuẩn đóng đợt rà soát:* Tất cả các phân hệ đạt trạng thái **GATE PASS** sẵn sàng phục vụ triển khai DDL và viết pipeline nạp dữ liệu ETL.

---

## KẾT LUẬN & KIẾN NGHỊ ĐIỀU PHỐI

1. **Khẳng định tính đúng đắn của thiết kế Atomic mới:** Đợt cập nhật commit `aff9a023` và `12a55eab` là bước tiến mang tính nền tảng, hoàn thiện bộ 28 bảng dữ liệu thị trường và chuẩn hóa bảng Thanh tra. Các gãy vỡ tham chiếu phát sinh tại một số phân hệ Datamart là tất yếu và mang tính kỹ thuật, hoàn toàn nằm trong tầm kiểm soát và có phương án khắc phục dứt điểm.
2. **Khai thác tối đa giá trị dữ liệu:** Đề nghị Ban Quản lý Dự án và Orchestrator phê duyệt ngay kế hoạch phân cấp P1/P2/P3 để các nhóm phụ trách phân hệ tiến hành cập nhật file LLD và HLD, giải phóng hơn 160 chỉ tiêu PENDING, nâng tầm năng lực giám sát và phân tích thị trường chứng khoán của UBCKNN.

---
*Báo cáo được tổng hợp, kiểm chứng đa tầng và xuất bản chính thức bởi Master Report Author.*
