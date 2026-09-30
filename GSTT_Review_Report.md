# BÁO CÁO THẨM ĐỊNH VÀ ĐÁNH GIÁ TỔNG HỢP KIẾN TRÚC PHÂN HỆ GIÁM SÁT THỊ TRƯỜNG (GSTT)
## HỆ THỐNG KHO DỮ LIỆU CHỨNG KHOÁN (UBCKNN DATA WAREHOUSE & DATAMART)

> **Mã báo cáo:** `GSTT_FINAL_CONSOLIDATED_REVIEW_REPORT.md`  
> **Phiên bản:** v1.0 — Master Consolidated Review  
> **Cơ quan chủ quản:** Ủy ban Chứng khoán Nhà nước (UBCKNN)  
> **Dự án:** Thiết kế Kiến trúc Dữ liệu Phân tích & Atomic Data Warehouse (`ubck_atomic_design`)  
> **Phân hệ mục tiêu:** Giám sát Thị trường (GSTT — Thị trường Chứng khoán & Giao dịch)  
> **Đơn vị thực hiện tổng hợp:** Teamwork Review Synthesis Unit (`teamwork_preview_worker_report_writer`)  
> **Đơn vị thẩm định độc lập:** 5 Domain Specialist Reviewers & 3 Exploration Survey Units  
> **Thời điểm công bố:** 2026-09-30  
> **Trạng thái phê duyệt kiến trúc:** ❌ **`REQUEST_CHANGES` (YÊU CẦU CHỈNH SỬA TRƯỚC KHI NGHIỆM THU GOLIVE)**  

---

## MỤC LỤC TỔNG QUAN

1. [TỔNG KẾT ĐÁNH GIÁ (EXECUTIVE SUMMARY)](#1-tổng-kết-đánh-giá-executive-summary)
2. [PHÂN NHÓM DOMAIN & DANH MỤC THẨM ĐỊNH (REQUIREMENT R1)](#2-phân-nhóm-domain--danh-mục-thẩm-định-requirement-r1)
   - 2.1. Bảng phân nhóm 48 nhóm BA (STT 1–48) vào 5 Business Domains
   - 2.2. Ma trận đối soát đa tầng: 48 Nhóm BA ↔ 19 Thực thể Datamart ↔ 12 Bảng Flat ClickHouse
3. [CHUỖI TRUY VẾT MẪU XUYÊN TẦNG END-TO-END TRACES](#3-chuỗi-truy-vết-mẫu-xuyên-tầng-end-to-end-traces)
   - 3.1. Domain 1 Trace: Giá khớp lệnh HOSE (`K_GSTT_189`) & Tài khoản đặt lệnh PII (`K_GSTT_311`)
   - 3.2. Domain 2 Trace: KLGD chỉ số (`K_GSTT_47`), GTGD Intraday (`K_GSTT_45`) & Định giá P/E rổ chỉ số (`K_GSTT_149`)
   - 3.3. Domain 3 Trace: Tổng KLGD khớp lệnh (`K_GSTT_13`), Nến Intraday 1 phút (`K_GSTT_95`), Đột phá KL 20 ngày (`K_GSTT_68`) & EPS BM021 (`K_GSTT_111`)
   - 3.4. Domain 4 Trace: GTNN mua theo phút (`K_GSTT_78`) & GT mua phân loại NĐT (`K_GSTT_86`/`K_GSTT_90`)
   - 3.5. Domain 5 Trace: Tỷ lệ sở hữu CĐL (`K_GSTT_103`), KLGD trái phiếu (`K_GSTT_23`) & Khối lượng phái sinh (`K_GSTT_15`)
4. [ĐÁNH GIÁ CHÉO ĐA CHIỀU CHI TIẾT THEO TỪNG DOMAIN (REQUIREMENTS R2 & R3)](#4-đánh-giá-chéo-đa-chiều-chi-tiết-theo-từng-domain-requirements-r2--r3)
   - 4.1. Domain 1 — Sổ Lệnh & Lệnh Khớp HOSE / HNX (`DOM_ORDER_TRADE`)
   - 4.2. Domain 2 — Chỉ Số Thị Trường & Rổ Chỉ Số (`DOM_MARKET_INDEX`)
   - 4.3. Domain 3 — Cổ Phiếu Cơ Sở, Biến Động Giá & Top Thị Trường (`DOM_STOCK_TOP`)
   - 4.4. Domain 4 — Xu Hướng Dòng Tiền & Nhóm Nhà Đầu Tư (`DOM_CASH_FLOW`)
   - 4.5. Domain 5 — Sản Phẩm Chuyên Biệt, Sở Hữu Doanh Nghiệp, Trái Phiếu & Phái Sinh (`DOM_SPECIALIZED`)
5. [PHÂN TÍCH XU HƯỚNG & RỦI RO HỆ THỐNG (SYSTEMIC RISKS & ARCHITECTURAL ANOMALIES)](#5-phân-tích-xu-hướng--rủi-ro-hệ-thống-systemic-risks--architectural-anomalies)
   - 5.1. Lỗi biên Window Function 52-week High/Low (`CURRENT ROW` gây tự triệt tiêu tín hiệu phá vỡ)
   - 5.2. Lỗi phóng đại 100 lần điểm đóng góp chỉ số (`K_GSTT_75`, `K_GSTT_76`, `K_GSTT_124`, `K_GSTT_125`)
   - 5.3. Lỗi LAG Intraday thiếu partition ngày (Gây âm chục nghìn tỷ đồng phiên mở cửa)
   - 5.4. Lộ lọt dữ liệu nhạy cảm PII và Mật mã PIN tài khoản khách hàng (Vi phạm Nghị định 13/2023/NĐ-CP)
   - 5.5. Khóa ORDER BY ReplacingMergeTree ClickHouse thiếu mã CK (Nguy cơ Merge Collision làm mất dữ liệu)
   - 5.6. Lỗi logic phân loại dòng tiền dẫn tới giá trị mua/bán của Tổ chức trong nước bị ÂM
   - 5.7. Sự thoái hóa của bộ kiểm thử hồi quy độc lập (Test Suite Stale & Self-Certifying Bypass)
6. [KẾ HOẠCH KHẮC PHỤC TỔNG HỢP (CONSOLIDATED ACTION PLAN)](#6-kế-hoạch-khắc-phục-tổng-hợp-consolidated-action-plan)
   - 6.1. Phân loại theo mức độ ưu tiên (P0 Critical, P1 High, P2 Medium)
   - 6.2. Phân công trách nhiệm theo vai trò (Data Modeler, BA Team, ClickHouse DBA, QA/Test Engineer)
7. [PHƯƠNG PHÁP KIỂM CHỨNG ĐỘC LẬP (VERIFICATION METHODOLOGY)](#7-phương-pháp-kiểm-chứng-độc-lập-verification-methodology)

---

## 1. TỔNG KẾT ĐÁNH GIÁ (EXECUTIVE SUMMARY)

### 1.1. Bối cảnh & Mục tiêu Đánh giá
Báo cáo này là kết quả tổng hợp toàn diện từ chiến dịch thẩm định đa tầng đối với phân hệ **Giám sát Thị trường (GSTT)** thuộc Dự án Thiết kế Data Warehouse / Datamart UBCKNN (`ubck_atomic_design`). Hoạt động đánh giá được kích hoạt nhằm kiểm chứng tính chính xác, tính nhất quán và độ an toàn kỹ thuật của các bản cập nhật thiết kế (PTTT), tài liệu kiến trúc mức cao (HLD), ma trận ánh xạ chi tiết (LLD), các bảng phẳng ClickHouse (DDL & DML Flat Tables) và tài liệu yêu cầu nghiệp vụ do BA cập nhật (BRD).

### 1.2. Phán quyết Thẩm định (Official Verdict)
- **KẾT LUẬN CHÍNH THỨC:** ❌ **`REQUEST_CHANGES` (YÊU CẦU CHỈNH SỬA & KHẮC PHỤC TRIỆT ĐỂ)**.
- **Đánh giá Tính Toàn vẹn (Integrity Audit):**
  - **Mặt tích cực:** Không phát hiện hành vi gian lận số liệu, không có code giả lập (facade/dummy) hay hardcode kết quả tính toán trong 12 bảng phẳng ClickHouse DDL/DML. Hệ thống vượt qua cả 9 Quality Gates nội bộ tự động (`run_quality_gates.py --module GSTT`).
  - **Mặt rủi ro nghiêm trọng:** Phát hiện **Sự thoái hóa của bộ kiểm thử hồi quy độc lập** (`test_gstt_integrity_oracles.py`, `test_datamart_date_fk_checker.py`). Bộ test suite độc lập bị đóng băng cứng các thông số cũ từ ngày 2026-09-26, dẫn tới việc hệ thống ngầm bị gãy test trong môi trường CI/CD nhưng báo cáo bề mặt vẫn ghi nhận PASS.
- **Thống kê Tổng hợp Phát hiện:**
  - **Tổng số lỗi và rủi ro được phát hiện:** **32 vấn đề kỹ thuật** xuyên suốt 5 Domain.
  - **Phân loại theo mức độ nghiêm trọng:**
    - **P0 Critical:** 6 lỗi nghiêm trọng (Lộ mã PIN/PII, Merge Collision ClickHouse, 100x Point Contribution, LAG Intraday âm 25.000 tỷ, Window Function nuốt đỉnh/đáy 52 tuần, Công thức dòng tiền làm âm Buy Value).
    - **P1 High:** 11 lỗi mức độ cao (Precision Drift YTM/Coupon, Type Mismatch không ép kiểu, Lệch schema ODS-Atomic, Lệch bảng mapping Nhóm 5, Phụ thuộc flat table cuối tháng QLKD, P/E và P/B âm khi doanh nghiệp lỗ, Stale Test Oracles).
    - **P2 Medium / Minor:** 15 lỗi mức độ vừa và nhỏ (Typo BRD, copy-paste nhầm điều kiện thỏa thuận, thiếu cờ lọc lệnh lỗi, thiếu fallback mã ngành CTCK, 1-off index shift).

---

## 2. PHÂN NHÓM DOMAIN & DANH MỤC THẨM ĐỊNH (REQUIREMENT R1)

Để bảo đảm tính chuyên sâu, triệt tiêu sự chồng chéo ngữ cảnh và tuân thủ tuyệt đối **Yêu cầu R1** tại `ORIGINAL_REQUEST.md`, toàn bộ 48 nhóm yêu cầu nghiệp vụ của BA (`BA_analyst_GSTT.csv`), 47 nhóm kiến trúc HLD, 19 thực thể Datamart và 12 bảng phẳng ClickHouse được phân bổ chặt chẽ vào **5 Business Domains**. Mỗi Domain được giao cho một Specialist Reviewer độc lập thẩm định đối kháng (Adversarial Review).

### 2.1. Bảng Phân Nhóm Chi Tiết 48 Nhóm BA (STT 1–48) Vào 5 Business Domains

| STT BA | Tên Màn hình / Báo cáo Nghiệp vụ BA | HLD Group | Trạng thái | Thuộc Tính Cốt lõi & Bảng Phẳng ClickHouse | Mã Domain Phụ trách | Agent Reviewer Chuyên trách |
|:---:|---|:---:|:---:|---|:---:|:---:|
| **1** | Bảng số liệu danh mục chứng khoán | Nhóm 1 | ACTIVE | OHLC, KLGD/GTGD thuần khớp lệnh (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **2** | Bảng số liệu danh mục trái phiếu | Nhóm 2 | ACTIVE | KLGD/GTGD trái phiếu (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_SPECIALIZED` | `reviewer_specialized` |
| **3** | Biểu đồ kỹ thuật danh mục cổ phiếu | Nhóm 3 | ACTIVE | Nến kỹ thuật ngày, giá cao/thấp/đóng cửa (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **4** | Biểu đồ kỹ thuật trái phiếu | Nhóm 4 | DEPRECATED | Bãi bỏ chính thức ngày 2026-09-17 (0 KPI active) | `DOM_SPECIALIZED` | `reviewer_specialized` |
| **5** | Theo dõi diễn biến các chỉ số thị trường (Index) | Nhóm 5 | ACTIVE | Điểm chỉ số, GTGD realtime (`gstt_fct_market_index_intraday_flat`) | `DOM_MARKET_INDEX` | `reviewer_market_index` |
| **6** | Định giá thị trường (P/E, P/B, Vốn hóa toàn sàn) | Nhóm 6 | ACTIVE | P/E rổ, P/B rổ, Vốn hóa thị trường (`gstt_fct_index_constituent_snpst_flat`) | `DOM_MARKET_INDEX` | `reviewer_market_index` |
| **7** | Top KLGD cổ phiếu theo sàn/ngành (Bảng số liệu) | Nhóm 7 | ACTIVE | Xếp hạng Top khối lượng khớp lệnh thuần (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **8** | Top KLGD cổ phiếu theo sàn/ngành (Biểu đồ) | Nhóm 8 | ACTIVE | Biểu đồ thanh khối lượng Top mã (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **9** | Top đột phá khối lượng (Bảng số liệu) | Nhóm 9 | ACTIVE | Tỷ lệ đột phá so với MA 20 phiên (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **10** | Top đột phá khối lượng (Biểu đồ) | Nhóm 10 | ACTIVE | Biểu đồ tỷ lệ đột phá thanh khoản (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **11** | Top giá trị giao dịch (Bảng số liệu) | Nhóm 11 | ACTIVE | Xếp hạng Top giá trị khớp lệnh thuần (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **12** | Top giá trị giao dịch (Biểu đồ) | Nhóm 12 | ACTIVE | Biểu đồ GTGD dẫn dắt thị trường (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **13** | Top giảm giá (Bảng số liệu) | Nhóm 13 | ACTIVE | Tỷ lệ giảm giá so với tham chiếu / kỳ (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **14** | Top giảm giá (Biểu đồ) | Nhóm 14 | ACTIVE | Biểu đồ Top mã giảm sâu nhất (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **15** | Top vượt đỉnh 52 tuần (Bảng số liệu) | Nhóm 15 | ACTIVE | Tỷ lệ vượt đỉnh 3M, 6M, 52W (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **16** | Top vượt đỉnh 52 tuần (Biểu đồ) | Nhóm 16 | ACTIVE | Biểu đồ bứt phá đỉnh kháng cự (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **17** | Top thủng đáy 52 tuần (Bảng số liệu) | Nhóm 17 | ACTIVE | Tỷ lệ thủng đáy 3M, 6M, 52W (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **18** | Top thủng đáy 52 tuần (Biểu đồ) | Nhóm 18 | ACTIVE | Biểu đồ xuyên thủng hỗ trợ kỹ thuật (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **19** | Top tăng giá (Bảng số liệu) | Nhóm 19 | ACTIVE | Tỷ lệ tăng giá phiên hiện tại (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **20** | Top tăng giá (Biểu đồ) | Nhóm 20 | ACTIVE | Biểu đồ Top tăng giá mạnh nhất (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **21** | Top nhà đầu tư nước ngoài (Bảng số liệu) | Nhóm 21 | ACTIVE | Khối ngoại Mua ròng / Bán ròng (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_CASH_FLOW` | `reviewer_cash_flow` |
| **22** | Top nhà đầu tư nước ngoài (Biểu đồ) | Nhóm 22 | ACTIVE | Biểu đồ giao dịch khối ngoại (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_CASH_FLOW` | `reviewer_cash_flow` |
| **23** | Bản đồ nhiệt cổ phiếu, ngành (Treemap) | Nhóm 23 | ACTIVE | Treemap Vốn hóa, KL, GTGD (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **24** | Dòng tiền: Tỷ trọng dòng tiền (cột & phân tán) | Nhóm 24 | ACTIVE | Tỷ trọng GTGD ngành, đóng góp vốn hóa (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_CASH_FLOW` | `reviewer_cash_flow` |
| **25** | Dòng tiền: GD nước ngoài theo phút | Nhóm 25 | ACTIVE | GTNN Mua/Bán theo nến 1 phút (`gstt_fct_foreign_trading_min_snpst_flat`) | `DOM_CASH_FLOW` | `reviewer_cash_flow` |
| **26** | Dòng tiền: GD nước ngoài theo chỉ số (Mới) | O_GSTT_38 | ACTIVE | Khối ngoại Mua/Bán theo rổ VN30, HNX30 (`gstt_fct_investor_category_index_trading_snpst_flat`) | `DOM_CASH_FLOW` | `reviewer_cash_flow` |
| **27** | Dòng tiền: Bản đồ nhiệt GD nước ngoài theo mã | Nhóm 27 | ACTIVE | Treemap GTNN Mua ròng/Bán ròng mã CK (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_CASH_FLOW` | `reviewer_cash_flow` |
| **28** | Dòng tiền: Bản đồ nhiệt GD nước ngoài theo chỉ số | O_GSTT_39 | ACTIVE | Treemap GTNN theo rổ chỉ số (`gstt_fct_investor_category_index_trading_snpst_flat`) | `DOM_CASH_FLOW` | `reviewer_cash_flow` |
| **29** | Dòng tiền: Giao dịch tự doanh CTCK | Nhóm 28 | ACTIVE | Tự doanh Mua/Bán/Ròng mã CK (`gstt_fct_investor_category_trading_snpst_flat`) | `DOM_CASH_FLOW` | `reviewer_cash_flow` |
| **30** | Dòng tiền: Phân loại NĐT >> Biểu đồ GT ròng chỉ số | Nhóm 29 | ACTIVE | 4 nhóm NĐT: Cá nhân, TC, Tự doanh, NN rổ chỉ số (`gstt_fct_investor_category_index_trading_snpst_flat`) | `DOM_CASH_FLOW` | `reviewer_cash_flow` |
| **31** | Dòng tiền: Phân loại NĐT >> Biểu đồ GT ròng mã CK | Nhóm 30 | ACTIVE | 4 nhóm NĐT: Mua ròng theo từng mã CK (`gstt_fct_investor_category_trading_snpst_flat`) | `DOM_CASH_FLOW` | `reviewer_cash_flow` |
| **32** | Dòng tiền: Bản đồ nhiệt GT ròng theo mã CK | Nhóm 31 | ACTIVE | Treemap 4 nhóm NĐT theo mã CK (`gstt_fct_investor_category_trading_snpst_flat`) | `DOM_CASH_FLOW` | `reviewer_cash_flow` |
| **33** | Dòng tiền: Bản đồ nhiệt GT ròng theo chỉ số | Nhóm 32 | ACTIVE | Treemap 4 nhóm NĐT theo chỉ số (`gstt_fct_investor_category_index_trading_snpst_flat`) | `DOM_CASH_FLOW` | `reviewer_cash_flow` |
| **34** | Biểu đồ phân tích kỹ thuật chuyên sâu | Nhóm 33 | ACTIVE | Nến 1 phút OHLCV (`gstt_fct_security_trading_intraday_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **35** | Sở hữu và giao dịch nội bộ | Nhóm 34 | ACTIVE | Cổ đông lớn, Ban lãnh đạo VSDC (`gstt_fct_major_shareholder_ownership_snpst_flat`) | `DOM_SPECIALIZED` | `reviewer_specialized` |
| **36** | Báo cáo Thống kê định giá TTCK VN (BM021_MSS) | Nhóm 35 | ACTIVE | EPS TTM, P/E, P/B qua WAOS-TTM (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **37** | Data Explorer: Giao dịch & thanh khoản cổ phiếu | Nhóm 36 | ACTIVE | Đa chiều thanh khoản, BCTC (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_STOCK_TOP` | `reviewer_stock_top` |
| **38** | Data Explorer: Số cổ phiếu sở hữu | Nhóm 37 | ACTIVE | Chi tiết cổ đông lớn nắm giữ (`gstt_fct_major_shareholder_ownership_snpst_flat`) | `DOM_SPECIALIZED` | `reviewer_specialized` |
| **39** | Data Explorer: Chỉ số thị trường | Nhóm 38 | ACTIVE | Đa chiều thanh khoản rổ chỉ số (`gstt_fct_index_constituent_snpst_flat`) | `DOM_MARKET_INDEX` | `reviewer_market_index` |
| **40** | Data Explorer: Điểm đóng góp chỉ số | Nhóm 39 | ACTIVE | Đóng góp điểm số của cổ phiếu vào chỉ số (`gstt_fct_index_constituent_snpst_flat`) | `DOM_MARKET_INDEX` | `reviewer_market_index` |
| **41** | Data Explorer: Giao dịch trái phiếu | Nhóm 40 | ACTIVE | Chi tiết trái phiếu BDO, HCX (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_SPECIALIZED` | `reviewer_specialized` |
| **42** | Data Explorer: Giao dịch phái sinh | Nhóm 41 | ACTIVE | Chi tiết hợp đồng tương lai DVX (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_SPECIALIZED` | `reviewer_specialized` |
| **43** | Data Explorer Kết xuất sổ lệnh: Trade book HOSE | Nhóm 42 | ACTIVE | Chi tiết khớp lệnh HOSE (`gstt_fct_hose_securities_trade_flat`) | `DOM_ORDER_TRADE` | `reviewer_order_trade` |
| **44** | Data Explorer Kết xuất sổ lệnh: Trade book HNX | Nhóm 43 | ACTIVE | Chi tiết khớp lệnh HNX (`gstt_fct_hnx_securities_trade_flat`) | `DOM_ORDER_TRADE` | `reviewer_order_trade` |
| **45** | Data Explorer Kết xuất sổ lệnh: Order book HNX | Nhóm 44 | ACTIVE | Chi tiết sổ lệnh đặt HNX (`gstt_fct_hnx_securities_order_flat`) | `DOM_ORDER_TRADE` | `reviewer_order_trade` |
| **46** | Data Explorer Kết xuất sổ lệnh: Order book HOSE | Nhóm 45 | ACTIVE | Chi tiết sổ lệnh đặt HOSE (`gstt_fct_hose_securities_order_flat`) | `DOM_ORDER_TRADE` | `reviewer_order_trade` |
| **47** | Biểu đồ kỹ thuật phái sinh (Mới 2026-09-29) | Nhóm 46 | ACTIVE | Nến kỹ thuật phái sinh (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_SPECIALIZED` | `reviewer_specialized` |
| **48** | Biểu đồ danh mục trái phiếu (Mới 2026-09-29) | Nhóm 47 | ACTIVE | Biểu đồ thị giá trái phiếu (`gstt_fct_stock_portfolio_snpst_flat`) | `DOM_SPECIALIZED` | `reviewer_specialized` |

---

### 2.2. Ma Trận Đối Soát Đa Tầng (Traceability Architecture Matrix)

Hệ thống quản lý **19 thực thể Datamart** (12 Fact do GSTT sở hữu, 2 Dim do GSTT sở hữu, 4 Dim conformed dùng chung, 1 Fact conformed dùng chung từ QLKD) và **12 bảng phẳng ClickHouse Flat Tables** (tổng cộng 412 cột vật lý):

```
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                 KIẾN TRÚC ĐA TẦNG PHÂN HỆ GSTT                                         │
├───────────────────┬─────────────────────────────────┬──────────────────────────────────┬───────────────┤
│ Domain Nghiệp Vụ   │ Thực Thể Fact & Dim LLD         │ Bảng Phẳng ClickHouse (Flat Table)│ Số Cột Vật Lý │
├───────────────────┼─────────────────────────────────┼──────────────────────────────────┼───────────────┤
│ DOM_ORDER_TRADE   │ fct_hose_securities_trade       │ gstt_fct_hose_securities_trade_flat │ 48 cột (#9)   │
│                   │ fct_hnx_securities_trade        │ gstt_fct_hnx_securities_trade_flat  │ 38 cột (#10)  │
│                   │ fct_hnx_securities_order        │ gstt_fct_hnx_securities_order_flat  │ 38 cột (#11)  │
│                   │ fct_hose_securities_order       │ gstt_fct_hose_securities_order_flat │ 53 cột (#12)  │
├───────────────────┼─────────────────────────────────┼──────────────────────────────────┼───────────────┤
│ DOM_MARKET_INDEX  │ fct_index_constituent_snpst     │ gstt_fct_index_constituent_snpst_flat│ 23 cột (#2)   │
│                   │ fct_market_index_intraday       │ gstt_fct_market_index_intraday_flat  │ 14 cột (#3)   │
│                   │ fct_market_index_snpst (QLKD)   │ qlkd_fct_market_index_snpst_flat    │ 22 cột (QLKD) │
├───────────────────┼─────────────────────────────────┼──────────────────────────────────┼───────────────┤
│ DOM_STOCK_TOP     │ fct_stock_portfolio_snpst       │ gstt_fct_stock_portfolio_snpst_flat │ 118 cột (#1)  │
│                   │ fct_security_trading_intraday   │ gstt_fct_security_trading_intraday_flat│ 16 cột (#4)  │
├───────────────────┼─────────────────────────────────┼──────────────────────────────────┼───────────────┤
│ DOM_CASH_FLOW     │ fct_foreign_trading_min_snpst   │ gstt_fct_foreign_trading_min_snpst_flat│ 13 cột (#5)  │
│                   │ fct_investor_category_trading_snpst │ gstt_fct_investor_category_trading_snpst_flat │ 19 cột (#6)│
│                   │ fct_investor_category_index_trading_snpst │ gstt_fct_investor_category_index_trading_snpst_flat │ 17 cột (#7)│
├───────────────────┼─────────────────────────────────┼──────────────────────────────────┼───────────────┤
│ DOM_SPECIALIZED   │ fct_major_shareholder_ownership_snpst │ gstt_fct_major_shareholder_ownership_snpst_flat │ 15 cột (#8)│
│                   │ (18 cột TP/Phái sinh trên Fact #1)│ (Tích hợp trong Flat #1)         │ (trong #1)    │
├───────────────────┴─────────────────────────────────┴──────────────────────────────────┼───────────────┤
│ TỔNG CỘNG TOÀN BỘ 5 DOMAIN                                                             │ 412 CỘT FLAT  │
└────────────────────────────────────────────────────────────────────────────────────────┴───────────────┘
```

---

## 3. CHUỖI TRUY VẾT MẪU XUYÊN TẦNG END-TO-END TRACES

Để đáp ứng tiêu chí nghiệm thu nghiêm ngặt, dưới đây là chuỗi truy vết chi tiết từng dòng code xuyên suốt từ Yêu cầu Nghiệp vụ (BRD) -> Kiến trúc Mức cao (HLD) -> Thiết kế Chi tiết (LLD Detail Mapping & Table Schema) -> Bảng Phẳng ClickHouse (DDL & DML) cho cả 5 Business Domain:

### 3.1. Domain 1 Trace: Sổ Lệnh & Khớp Lệnh HOSE / HNX (`DOM_ORDER_TRADE`)

#### Trace 1.1: Chỉ tiêu Giá Khớp Lệnh HOSE (`execution_price` / `execution_exec_price`)
Chỉ tiêu đo lường mức giá khớp lệnh thực tế của từng giao dịch trên sàn HOSE:
- **Tầng 1 — Yêu cầu Nghiệp vụ (BRD/BA):**
  - Tệp tin: `BRD/BA/BA_analyst_GSTT.csv`
  - Dòng: **Line 642** | Cột STT: `43` | Tên Dashboard: `"Kết xuất sổ lệnh >> Trade book HOSE"`
  - Thông tin: `"execution_exec_price"` | Bảng nguồn: `"UAT_Hose_stg.trade_book"` | Trường nguồn: `"execution_exec_price"`
- **Tầng 2 — Kiến trúc Mức cao (HLD):**
  - Tệp tin: `Datamart/hld/DTM_GSTT_HLD.md`
  - Dòng: **Line 3343** | Section 2: `"#### Nhóm 42 - Data Explorer: Kết xuất sổ lệnh — HOSE"`
  - Dòng KPI: `| K_GSTT_189 | execution_exec_price | VNĐ | Cơ sở | Fact HOSE Securities Trade.Execution Price | BA dòng 599... | READY |`
- **Tầng 3 — Thiết kế Chi tiết (LLD Detail Mapping):**
  - Tệp tin: `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`
  - Dòng: **Line 732** | `kpi_id: K_GSTT_189` | `nhom: "Nhóm 42 - Data Explorer: Kết xuất sổ lệnh — HOSE"`
  - `mart_table: "Fact HOSE Securities Trade"` | `mart_column: "Execution Price"` | `column_role: "MEASURE"` | `logic: "fct_hose_securities_trade.execution_price"`
- **Tầng 4 — Thiết kế Lược đồ Thực thể (LLD Table Schema):**
  - Tệp tin: `Datamart/lld/GSTT/DTM_GSTT_fct_hose_securities_trade.csv` (Dòng 10) & `Datamart/lld/datamart_attributes.csv`
  - `datamart_attribute: "Execution Price"` | `datamart_column: "execution_price"` | `data_type: "decimal(23,2)"`
  - `etl_logic: "securities_trade.execution_price WHERE securities_trade.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE'"`
- **Tầng 5A — ClickHouse DDL:**
  - Tệp tin: `Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql`
  - Dòng: **Line 479** | Bảng: `datamart.gstt_fct_hose_securities_trade_flat`
  - Mã SQL: `execution_price Nullable(Decimal(23,2)) COMMENT 'Giá khớp lệnh thực tế của giao dịch.'`
- **Tầng 5B — ClickHouse DML:**
  - Tệp tin: `Datamart/flat-table/GSTT/02_populate_gstt_flat_tables.sql`
  - Dòng: **Line 481** | Mệnh đề: `INSERT INTO datamart.gstt_fct_hose_securities_trade_flat`
  - Mã SQL: `f.execution_price FROM datamart.fct_hose_securities_trade f ...`

#### Trace 1.2: Chỉ tiêu PII Số Tài Khoản Đặt Lệnh HOSE (`account_nbr`)
- **BRD:** `BRD/BA/BA_analyst_GSTT.csv`, Dòng 761 | STT: 46 | Info: `"acct_no"` | Src: `"UAT_Hose_stg.order_book.acct_no"`.
- **HLD:** `Datamart/hld/DTM_GSTT_HLD.md`, Dòng 3751 | Nhóm 45 | `K_GSTT_311 | acct_no | Fact HOSE Securities Order.Account Number | READY`.
- **LLD Detail Mapping:** `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`, Dòng 851 | `K_GSTT_311` | `mart_table: Fact HOSE Securities Order` | `mart_column: Account Number` | `logic: fct_hose_securities_order.account_nbr`.
- **LLD Schema:** `Datamart/lld/GSTT/DTM_GSTT_fct_hose_securities_order.csv`, Dòng 17 | `account_nbr String` | `securities_order.account_nbr`.
- **ClickHouse DDL:** `Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql`, Dòng 666 | `account_nbr Nullable(String) COMMENT 'Mã/Số tài khoản giao dịch của nhà đầu tư.'`.
- **ClickHouse DML:** `Datamart/flat-table/GSTT/02_populate_gstt_flat_tables.sql`, Dòng 667 | `f.account_nbr`.

---

### 3.2. Domain 2 Trace: Chỉ Số Thị Trường & Rổ Chỉ Số (`DOM_MARKET_INDEX`)

#### Trace 2.1: Khối lượng giao dịch của chỉ số (`K_GSTT_47` — Index Total Matched Volume)
- **BRD:** `BRD/BA/BA_analyst_GSTT.csv`, Dòng 83 (STT 5) & Dòng 585 (STT 39) | Info: `"KLGD của chỉ số"`.
- **HLD:** `Datamart/hld/DTM_GSTT_HLD.md`, Dòng 753 (Nhóm 5) & Dòng 3119 (Nhóm 38) | `K_GSTT_47 | MAX(Fact Index Constituent Snapshot.Index Total Matched Volume)`.
- **LLD Detail Mapping:** `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`, Dòng 674 (Nhóm 38) | `kpi_id: K_GSTT_47` | `mart_table: Fact Index Constituent Snapshot` | `mart_column: Index Total Matched Volume` | `logic: MAX(fct_index_constituent_snpst.idx_total_matched_vol)`.
- **LLD Schema:** `Datamart/lld/GSTT/DTM_GSTT_fct_index_constituent_snpst.csv`, Dòng 5 | `idx_total_matched_vol int` | Aggregation từ `securities_trade.execution_vol` loại trừ thỏa thuận.
- **ClickHouse DDL:** `Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql`, Dòng 189 | `idx_total_matched_vol Nullable(Int64) COMMENT '...Tổng KLGD khớp lệnh thuần toàn rổ chỉ số...'`.
- **ClickHouse DML:** `Datamart/flat-table/GSTT/02_populate_gstt_flat_tables.sql`, Dòng 191 | `f.idx_total_matched_vol`.

#### Trace 2.2: Giá trị giao dịch realtime theo giờ (`K_GSTT_45` — Total Value At Time Intraday)
- **BRD:** `BRD/BA/BA_analyst_GSTT.csv`, Dòng 78 | STT: 5 | Info: `"Giá trị GD theo realtime"` | Src: `MDDS.JAD_MARKETINFOR.TOTALVALUE`.
- **HLD:** `Datamart/hld/DTM_GSTT_HLD.md`, Dòng 751 | Nhóm 5 | `K_GSTT_45 | Fact Market Index Intraday.Total Value At Time`.
- **LLD Detail Mapping:** `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`, Dòng 94 | `K_GSTT_45` | `mart_table: Fact Market Index Intraday` | `mart_column: Total Value At Time` | `logic: fct_market_index_intraday.total_val_at_time`.
- **LLD Schema:** `Datamart/lld/GSTT/DTM_GSTT_fct_market_index_intraday.csv`, Dòng 6 | `total_val_at_time decimal(23,2)` | `market_index_snapshot.total_val - LAG(...)`.
- **ClickHouse DDL:** `Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql`, Dòng 238 | `total_val_at_time Nullable(Decimal(23,2))`.
- **ClickHouse DML:** `Datamart/flat-table/GSTT/02_populate_gstt_flat_tables.sql`, Dòng 242 | `f.total_val_at_time`.

---

### 3.3. Domain 3 Trace: Cổ Phiếu Cơ Sở, Biến Động Giá & Top Thị Trường (`DOM_STOCK_TOP`)

#### Trace 3.1: Chỉ tiêu Khối lượng Khớp lệnh Cốt lõi — `K_GSTT_13` (Total Matched Volume)
- **BRD:** `BRD/BA/BA_analyst_GSTT.csv`, Dòng 481 (STT 1) | Info: `"Tổng KLGD khớp lệnh"` | Điều kiện: `Loại thỏa thuận, Market ID IN ('UPX','STX','STO')`.
- **HLD:** `Datamart/hld/DTM_GSTT_HLD.md`, Dòng 407 (Nhóm 1) | `K_GSTT_13 | Fact Stock Portfolio Snapshot.Total Matched Volume | READY`.
- **LLD Detail Mapping:** `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`, Dòng 18 | `K_GSTT_13` | `mart_table: Fact Stock Portfolio Snapshot` | `mart_column: Total Matched Volume` | `logic: SUM(fct_stock_portfolio_snpst.total_matched_vol)`.
- **LLD Schema:** `Datamart/lld/GSTT/DTM_GSTT_fct_stock_portfolio_snpst.csv`, Dòng 8 | `total_matched_vol int` | `SUM(execution_vol) WHERE board_tp_code NOT IN ('T1'-'T4', 'T6', 'R1')`.
- **ClickHouse DDL:** `Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql`, Dòng 44 | `total_matched_vol Nullable(Int64)`.
- **ClickHouse DML:** `Datamart/flat-table/GSTT/02_populate_gstt_flat_tables.sql`, Dòng 46 | `f.total_matched_vol`.

#### Trace 3.2: Chỉ tiêu Nến Giá Kỹ thuật Intraday 1 Phút — `K_GSTT_95` (Open Price At Time)
- **BRD:** `BRD/BA/BA_analyst_GSTT.csv`, Dòng 27330 (Record 490, STT 34) | Info: `"Giá mở cửa theo từng time trong 1 ngày"` | Src: `MDDS.JAD_TRADINGVIEWHISTORY1MIN`.
- **HLD:** `Datamart/hld/DTM_GSTT_HLD.md`, Dòng 2695 (Nhóm 33) | `K_GSTT_95 | Fact Security Trading Intraday.Open Price At Time`.
- **LLD Detail Mapping:** `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`, Dòng 569 | `K_GSTT_95` | `mart_table: Fact Security Trading Intraday` | `mart_column: Open Price At Time` | `logic: fct_security_trading_intraday.open_price_at_time`.
- **LLD Schema:** `Datamart/lld/GSTT/DTM_GSTT_fct_security_trading_intraday.csv`, Dòng 5 | `open_price_at_time decimal(23,2)`.
- **ClickHouse DDL:** `Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql`, Dòng 279 | `open_price_at_time Nullable(Decimal(23,2))`.
- **ClickHouse DML:** `Datamart/flat-table/GSTT/02_populate_gstt_flat_tables.sql`, Dòng 278 | `f.open_price_at_time`.

---

### 3.4. Domain 4 Trace: Xu Hướng Dòng Tiền & Nhóm Nhà Đầu Tư (`DOM_CASH_FLOW`)

#### Trace 4.1: Chỉ tiêu "GTNN mua theo từng time trong ngày" (`K_GSTT_78` — Minute Foreign Buy Value)
- **BRD:** `BRD/BA/BA_analyst_GSTT.csv`, Dòng 404 (STT 25) | Info: `"GTNN mua tại thời điểm time trong ngày "`.
- **HLD:** `Datamart/hld/DTM_GSTT_HLD.md`, Dòng 1993 (Nhóm 25) | `K_GSTT_78 | Fact Foreign Trading Minute Snapshot.Foreign Buy Value At Minute`.
- **LLD Detail Mapping:** `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`, Dòng 455 | `K_GSTT_78` | `mart_table: Fact Foreign Trading Minute Snapshot` | `mart_column: Foreign Buy Value At Minute` | `logic: SUM(fct_foreign_trading_min_snpst.foreign_buy_val_at_min)`.
- **LLD Schema:** `Datamart/lld/GSTT/DTM_GSTT_fct_foreign_trading_min_snpst.csv`, Dòng 5 | `foreign_buy_val_at_min decimal(23,2)`.
- **ClickHouse DDL:** `Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql`, Dòng 320 | `foreign_buy_val_at_min Nullable(Decimal(23,2))`.
- **ClickHouse DML:** `Datamart/flat-table/GSTT/02_populate_gstt_flat_tables.sql`, Dòng 318 | `f.foreign_buy_val_at_min`.

#### Trace 4.2: Chỉ tiêu "Giá trị mua theo Phân loại NĐT" (`K_GSTT_86` / `K_GSTT_90`)
- **BRD:** `BRD/BA/BA_analyst_GSTT.csv`, Dòng 449 (STT 30) & Dòng 457 (STT 31) | Info: `"Giá trị mua theo phân loại NĐT Tự doanh, Cá nhân, TC trong nước, Nước ngoài"`.
- **HLD:** `Datamart/hld/DTM_GSTT_HLD.md`, Dòng 2374 (`K_GSTT_86`) & Dòng 2469 (`K_GSTT_90`) | `SUM(Fact Investor Category Trading Snapshot.Buy Value)`.
- **LLD Detail Mapping:** `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`, Dòng 499 & Dòng 512 | `mart_table: Fact Investor Category Trading Snapshot` | `mart_column: Buy Value` | `logic: SUM(fct_investor_category_trading_snpst.buy_val)`.
- **LLD Schema:** `Datamart/lld/GSTT/DTM_GSTT_fct_investor_category_trading_snpst.csv`, Dòng 5 | `buy_val decimal(23,2)`.
- **ClickHouse DDL:** `Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql`, Dòng 358 | `buy_val Nullable(Decimal(23,2))`.
- **ClickHouse DML:** `Datamart/flat-table/GSTT/02_populate_gstt_flat_tables.sql`, Dòng 355 | `f.buy_val`.

---

### 3.5. Domain 5 Trace: Sản Phẩm Chuyên Biệt, Sở Hữu, Trái Phiếu & Phái Sinh (`DOM_SPECIALIZED`)

#### Trace 5.1: Chỉ tiêu Tỷ lệ Sở hữu Cổ đông Lớn (`K_GSTT_103` — Ownership Ratio)
- **BRD:** `BRD/BA/BA_analyst_GSTT.csv`, Dòng 507 (STT 35) | Info: `"Tỷ lệ sở hữu"` | Src: `VSDC.major_shareholder.shares_ratio`.
- **HLD:** `Datamart/hld/DTM_GSTT_HLD.md`, Dòng 2818 (Nhóm 34) | `K_GSTT_103 | Tỷ lệ sở hữu | % | Fact Major Shareholder Ownership Snapshot.Ownership Ratio`.
- **LLD Detail Mapping:** `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`, Dòng 587 | `K_GSTT_103` | `mart_table: Fact Major Shareholder Ownership Snapshot` | `mart_column: Ownership Ratio` | `logic: fct_major_shareholder_ownership_snpst.ownership_ratio`.
- **LLD Schema:** `Datamart/lld/GSTT/DTM_GSTT_fct_major_shareholder_ownership_snpst.csv`, Dòng 7 | `ownership_ratio decimal(7,4)` | Window `MAX(ds_snpst_dt)` + `CASE` chọn kỳ theo `:etl_date`.
- **ClickHouse DDL:** `Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql`, Dòng 440 | `ownership_ratio Nullable(Decimal(7,4))`.
- **ClickHouse DML:** `Datamart/flat-table/GSTT/02_populate_gstt_flat_tables.sql`, Dòng 441 | `f.ownership_ratio`.

#### Trace 5.2: Khối lượng Giao dịch Trái phiếu Doanh nghiệp (`K_GSTT_23` — Bond Trading Volume)
- **BRD:** `BRD/BA/BA_analyst_GSTT.csv`, Dòng 35 (STT 2) & Dòng 804 (STT 48) | Info: `"KLGD khớp lênh"` | Điều kiện: `Market ID IN ('BDO','HCX')`.
- **HLD:** `Datamart/hld/DTM_GSTT_HLD.md`, Dòng 619 (Nhóm 2) & Dòng 3919 (Nhóm 47) | `K_GSTT_23 | SUM(Securities Trade.Execution Volume WHERE Market Id IN ('BDO','HCX'))`.
- **LLD Detail Mapping:** `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`, Dòng 46 & Dòng 898 | `mart_table: Fact Stock Portfolio Snapshot` | `mart_column: Bond Trading Volume` | `logic: SUM(fct_stock_portfolio_snpst.bond_trading_vol)`.
- **LLD Schema:** `Datamart/lld/GSTT/DTM_GSTT_fct_stock_portfolio_snpst.csv`, Dòng 36 | `bond_trading_vol int` | `SUM(execution_vol) WHERE market_id_code IN ('BDO','HCX')`.
- **ClickHouse DDL:** `Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql`, Dòng 105 | `bond_trading_vol Nullable(Int64)`.
- **ClickHouse DML:** `Datamart/flat-table/GSTT/02_populate_gstt_flat_tables.sql`, Dòng 106 | `f.bond_trading_vol`.

---

## 4. ĐÁNH GIÁ CHÉO ĐA CHIỀU CHI TIẾT THEO TỪNG DOMAIN (REQUIREMENTS R2 & R3)

Dưới đây là toàn bộ các phát hiện kỹ thuật được tổng hợp từ 5 Specialist Reviewers, phân loại nghiêm ngặt thành **3 Danh mục Bắt buộc**: (1) Lỗi Mapping, (2) Lỗi Cú pháp / Data Type, và (3) Lỗi Logic Nghiệp vụ. Mọi lỗi đều trích dẫn chính xác tệp tin, dòng mã nguồn và đề xuất hành động khắc phục cụ thể:

---

### 4.1. DOMAIN 1 — SỔ LỆNH & LỆNH KHỚP HOSE / HNX (`DOM_ORDER_TRADE`)

#### 1. Lỗi Mapping (Mapping Discrepancies)
- **[Major] MAP-D1-01 — Trôi dạt tên cột vật lý tại tệp mapping ODS-Atomic HNX:**
  - *Vị trí:* `Mapping/atomic/communication/mapping_atm_securities_order-ORDERTRADE.ORDER_BOOK_HNX.yaml`, Dòng 77.
  - *Hiện tượng:* Tệp ánh xạ ODS -> Atomic định nghĩa: `target_column: side_indicator`. Trong khi đó, LDM Atomic (`dm_atm_securities_order-ORDERTRADE.ORDER_BOOK_HNX.yaml`, dòng 80) định nghĩa `side_ind`, Master Entity (`entity_securities_order.yaml`) định nghĩa `side_ind`, và Datamart LLD (`DTM_GSTT_fct_hnx_securities_order.csv`, dòng 8) tham chiếu `atomic_column: side_ind`.
  - *Hệ quả:* Spark ETL job tự động sinh từ YAML mapping sẽ ghi vào cột `side_indicator` gây lỗi `ColumnNotFoundException` trên bảng Atomic.
  - *Đề xuất sửa đổi:* Sửa dòng 77 tệp mapping YAML thành: `target_column: side_ind`.
- **[Minor] MAP-D1-02 — Lệch đánh số nhóm nghiệp vụ (1-off Index Shift):**
  - *Vị trí:* `BRD/BA/BA_analyst_GSTT.csv` (STT 43–46) so với `DTM_GSTT_HLD.md` và `DTM_GSTT_Detail_Mapping.csv` (Nhóm 42–45).
  - *Hiện tượng:* Do BA chèn màn hình STT 26, STT của BA bị lệch +1 so với số Nhóm trong HLD/LLD (`O_GSTT_38`).
  - *Đề xuất sửa đổi:* Đề nghị BA cập nhật cột STT trong `BA_analyst_GSTT.csv` cho khớp với HLD/LLD, hoặc bổ sung cột metadata `HLD_GROUP_NO`.
- **[Minor] MAP-D1-03 — Thiếu vắng quy tắc chuyển đổi nghiệp vụ trên cả 157 dòng BA:**
  - *Vị trí:* `BRD/BA/BA_analyst_GSTT.csv`, Dòng 634–790, Cột 17 (`Điều kiện chung`) và Cột 18 (`Câu lệnh tham khảo`).
  - *Hiện tượng:* Toàn bộ 157 dòng đều để trống 100%. Data Modeler phải đặt giả định pass-through 1:1. Nếu sàn KRX gửi bản tin hệ thống (system reject messages, heartbeats) vào order book, dữ liệu rác sẽ lọt vào Datamart.
  - *Đề xuất sửa đổi:* Yêu cầu BA cung cấp tài liệu giải thích mã trạng thái `order_status_code` và mã hủy `auto_cancel_reason_code` để bổ sung business filter.

#### 2. Lỗi Cú pháp / Data Type (Syntax, Types & Precision)
- **[Critical] SYN-D1-01 — Không đồng nhất tên cột ngày phân vùng và cấu trúc Calendar Dimension giữa các bảng:**
  - *Vị trí:* `Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql` & `02_populate_gstt_flat_tables.sql`:
    - Bảng #9 (dòng 468, 470) & Bảng #10 (dòng 536, 537): `trade_cdr_dt` (chỉ lấy 2 cột từ `cdr_dt_dim`).
    - Bảng #11 (dòng 592, 593) & Bảng #12 (dòng 648, 650): `cdr_dt` (lấy tới 8 cột từ `cdr_dt_dim`: `year`, `quarter`, `month`, `day_of_week`, `is_weekend`, `holiday_flag`, `is_trading_date`).
  - *Hệ quả:* Gãy chuẩn đặt tên trong cùng Domain. Báo cáo phân tích kết hợp giữa Sổ lệnh (Order) và Sổ khớp (Trade) sẽ phải viết WHERE và JOIN trên 2 tên cột khác nhau.
  - *Đề xuất sửa đổi:* Thống nhất dùng chung tên cột `trade_cdr_dt` cho cả 4 bảng phẳng (phù hợp với Role-Playing Date FK `trade_dt_dim_id`), đồng bộ số lượng cột từ `cdr_dt_dim`.
- **[Major] SYN-D1-02 — Kiểu dữ liệu thời gian dạng String (`Nullable(String)`) thay vì chuẩn DateTime chính xác cao:**
  - *Vị trí:* `01_create_gstt_flat_tables.sql`: `trade_time`, `buy_order_time`, `sell_order_time` (#9, #10), `order_accept_time` (#11 line 599), `order_time` (#12 line 657).
  - *Hệ quả:* ClickHouse không thể dùng các hàm tối ưu `toDateTime64`, `timeSlot`, `dateDiff`. Nguy cơ sai lệch khi so sánh chuỗi nếu độ dài không cố định (`91530123` vs `091530123`).
  - *Đề xuất sửa đổi:* Chuẩn hóa format chuỗi `hh:mm:ss.zzz` hoặc chuyển đổi sang kiểu `DateTime64(3)` kết hợp với `trade_date` tại tầng ETL.

#### 3. Lỗi Logic Nghiệp vụ & Bảo mật (Business Rules & Security)
- **[Critical] LOG-D1-01 — Lộ lọt dữ liệu nhạy cảm PII và Mã PIN tài khoản khách hàng trên bảng phẳng (Vi phạm Nghị định 13/2023/NĐ-CP):**
  - *Vị trí:*
    - Bảng #9 `datamart.gstt_fct_hose_securities_trade_flat`: `buy_account_pin_code` (line 490), `sell_account_pin_code` (line 506), `buy_account_nbr` (line 491), `sell_account_nbr` (line 507), `buy_account_holder_nm` (line 492), `sell_account_holder_nm` (line 508), `buy_trader_nm` (line 499), `sell_trader_nm` (line 515).
    - Bảng #10 `datamart.gstt_fct_hnx_securities_trade_flat`: `sell_account_nbr` (line 550), `buy_account_nbr` (line 559).
    - Bảng #11 `datamart.gstt_fct_hnx_securities_order_flat`: `account_nbr` (line 602).
    - Bảng #12 `datamart.gstt_fct_hose_securities_order_flat`: `account_pin_code` (line 665), `account_nbr` (line 666), `account_holder_nm` (line 667), `trader_nm` (line 692).
  - *Hiện tượng:* Mã PIN và PII khách hàng được đưa nguyên văn dưới dạng plaintext vào Flat Tables mà không có bất kỳ hàm băm (hash), mã hóa hoặc mặt nạ (masking) nào trong DML ETL (`02_populate_gstt_flat_tables.sql`).
  - *Hệ quả:* Mã PIN là thông tin xác thực tối mật của khách hàng, việc để lộ plaintext trên bảng phẳng báo cáo vi phạm nghiêm trọng Nghị định 13/2023/NĐ-CP và có thể dẫn đến rủi ro pháp lý hình sự.
  - *Đề xuất sửa đổi:* **Loại bỏ vĩnh viễn** các cột `account_pin_code`, `buy_account_pin_code`, `sell_account_pin_code` khỏi Datamart và Flat Tables. Áp dụng Dynamic Data Masking hoặc băm một chiều (`SHA256`) đối với `account_nbr` và `account_holder_nm`.
- **[Critical] LOG-D1-02 — Nguy cơ Merge Collision làm mất dữ liệu và suy giảm hiệu năng do thiếu mã CK trong khóa `ORDER BY`:**
  - *Vị trí:* `01_create_gstt_flat_tables.sql`: Bảng #9 (dòng 524) và Bảng #10 (dòng 582):
    `ORDER BY (assumeNotNull(trade_cdr_dt), securities_trade_code)`.
  - *Hiện tượng:* Trường `securities_trade_code` được định nghĩa trong LDM là *"Số thứ tự giao dịch khớp lệnh trong ngày, theo từng mã chứng khoán"*.
  - *Hệ quả:* Cơ chế `ReplacingMergeTree` của ClickHouse sẽ coi các bản ghi có cùng khóa `(trade_cdr_dt, securities_trade_code)` là bản ghi trùng lặp và tự động gộp xóa bỏ trong background merge! Nếu mã VCB có trade số 1 và HPG cũng có trade số 1 trong cùng ngày, một trong hai giao dịch sẽ bị xóa vĩnh viễn. Ngoài ra, thiếu `security_symbol_code` ở đầu khóa khiến ClickHouse phải quét toàn bộ partition khi người dùng lọc theo mã CK.
  - *Đề xuất sửa đổi:* Sửa khóa `ORDER BY` của Bảng #9 và #10 thành:
    `ORDER BY (assumeNotNull(trade_cdr_dt), security_symbol_code, securities_trade_code)`.
- **[Medium] LOG-D1-03 — Thiếu bộ lọc loại trừ lệnh lỗi / lệnh từ chối hệ thống trong DML Populate:**
  - *Vị trí:* `02_populate_gstt_flat_tables.sql`, Bảng #11 và #12.
  - *Hiện tượng:* Đổ toàn bộ bản ghi mà không lọc theo `order_reject_reason_code` hay `order_status_code`.
  - *Đề xuất sửa đổi:* Bổ sung cờ chuẩn hóa `is_rejected_flag` để tầng BI dễ dàng loại trừ lệnh lỗi khi tính độ sâu sổ lệnh.

---

### 4.2. DOMAIN 2 — CHỈ SỐ THỊ TRƯỜNG & RỔ CHỈ SỐ (`DOM_MARKET_INDEX`)

#### 1. Lỗi Mapping (Mapping Discrepancies)
- **[Major] MAP-D2-01 — Lệch bảng vật lý và trôi thuộc tính tại Nhóm 5 Detail Mapping:**
  - *Vị trí:* `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`, Dòng 96–103.
  - *Hiện tượng:* Các chỉ tiêu `K_GSTT_47`, `K_GSTT_48`, `K_GSTT_49`, `K_GSTT_50`, `K_GSTT_51`, `K_GSTT_52` vẫn khai báo thuộc bảng `Fact Stock Portfolio Snapshot`. Dòng 99 (`K_GSTT_50`) có `mart_column = ""`. Dòng 103 (`K_GSTT_54`) có cả `mart_table` và `mart_column` rỗng `""`. Trong khi đó, cột `logic` đã dùng `fct_index_constituent_snpst` và tại Nhóm 38 (dòng 674–680) toàn bộ đã được khai báo đúng sang `Fact Index Constituent Snapshot`.
  - *Đề xuất sửa đổi:* Cập nhật Nhóm 5 dòng 96–103 trỏ đúng sang `Fact Index Constituent Snapshot` với các cột tương ứng (`Index Total Matched Volume`, `Index Total Matched Value`, v.v.).
- **[Major] MAP-D2-02 — Bỏ trống bảng và cột vật lý của `K_GSTT_61` tại Nhóm 6 Detail Mapping:**
  - *Vị trí:* `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`, Dòng 115.
  - *Hiện tượng:* Dòng 115 (`K_GSTT_61` - Vốn hóa thị trường): `mart_table = ""` và `mart_column = ""` bị để trống, gán `column_role = DERIVED`, dù HLD dòng 874 khẳng định đây là Vốn hóa CỦA RỔ CHỈ SỐ đọc trực tiếp từ cột vật lý `idx_market_cap` trên `Fact Index Constituent Snapshot`.
  - *Đề xuất sửa đổi:* Cập nhật dòng 115: `mart_table = Fact Index Constituent Snapshot`, `mart_column = Index Market Cap`, `column_role = MEASURE`.
- **[Moderate] MAP-D2-03 — Bỏ sót chỉ tiêu "Khối lượng giao dịch khớp lệnh" do ô trống trong BA tại Nhóm 39 / STT 40:**
  - *Vị trí:* `BRD/BA/BA_analyst_GSTT.csv`, Dòng 612; `Datamart/hld/DTM_GSTT_HLD.md`, Dòng 3153.
  - *Hiện tượng:* Dòng 612 trong file BA có nguồn `Execution - Volume`, nhưng cột `Thông tin` bị bỏ trống. HLD coi đây là dòng rác nên bỏ qua, chỉ đưa vào `K_GSTT_14` (Giá trị khớp lệnh).
  - *Đề xuất sửa đổi:* Phản hồi BA điền thông tin và bổ sung `K_GSTT_13` (Total Matched Volume) vào HLD/LLD Nhóm 39.
- **[Moderate] MAP-D2-04 — Tài liệu đặc tả Flat Table Mapping bị lỗi thời:**
  - *Vị trí:* `Datamart/flat-table/flat_table_mapping.md`, Dòng 157–245.
  - *Hiện tượng:* Tài liệu chỉ mô tả 3 bảng flat cũ, không có thông tin về 12 bảng flat hiện hành của GSTT (đặc biệt là Bảng #2 và #3 của Domain 2).
  - *Đề xuất sửa đổi:* Cập nhật tài liệu đồng bộ 12 bảng flat ClickHouse hiện có.

#### 2. Lỗi Cú pháp / Data Type (Syntax, Types & Precision)
- **[Major] SYN-D2-01 — Sai lệch Data Domain trên các chỉ tiêu định giá P/E và P/B (`idx_pe`, `idx_pb`):**
  - *Vị trí:* `Datamart/lld/GSTT/DTM_GSTT_fct_index_constituent_snpst.csv`, Dòng 14, 15; `Datamart/datamart_model.yaml`.
  - *Hiện tượng:* Cả 2 cột `idx_pe` và `idx_pb` đều được gán `data_domain: Percentage`.
  - *Hệ quả:* P/E và P/B là các bội số định giá (Multiples / Ratio, đơn vị "Lần"). Gán domain `Percentage` khiến BI tool tự động format dấu `%` hoặc nhân 100 (P/E 15.8 lần thành 1,580%), gây sai lệch hoàn toàn ngữ nghĩa tài chính.
  - *Đề xuất sửa đổi:* Sửa `data_domain` của `idx_pe` và `idx_pb` thành `Ratio` hoặc `Valuation Multiple`.
- **[Moderate] SYN-D2-02 — Rủi ro tràn số nguyên (Integer Overflow) trên các cột khối lượng toàn rổ:**
  - *Vị trí:* `Datamart/lld/GSTT/DTM_GSTT_fct_index_constituent_snpst.csv`, Dòng 5, 7, 9; `Datamart/datamart_model.yaml`.
  - *Hiện tượng:* Khai báo `data_type: int` (giới hạn tối đa 2.14 tỷ CP). Với phiên giao dịch bùng nổ, khối lượng toàn sàn VN-Index có thể vượt ngưỡng này gây lỗi tràn số trên Spark/Postgres.
  - *Đề xuất sửa đổi:* Nâng cấp kiểu dữ liệu LLD và YAML lên `bigint` (hoặc `Int64`).
- **[Minor] SYN-D2-03 — Lệch thang đo độ chính xác trên điểm chỉ số `idx_market_index_val`:**
  - *Vị trí:* `DTM_GSTT_fct_index_constituent_snpst.csv` line 11 (`decimal(23,4)`) vs `DTM_QLKD_fct_market_index_snpst.csv` line 4 (`decimal(23,2)`).
  - *Đề xuất sửa đổi:* Đồng bộ thang đo điểm chỉ số sang chuẩn `decimal(23,2)`.

#### 3. Lỗi Logic Nghiệp vụ & Kiến trúc (Business Rules & Architecture)
- **[Critical] LOG-D2-01 — Lỗi phóng đại 100 lần (100x Scale Error) trong công thức tính Điểm đóng góp chỉ số:**
  - *Vị trí:* `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`, Dòng 694, 695, 699, 700 (Nhóm 39) & Dòng 440–443 (Nhóm 24).
  - *Công thức lỗi:*
    `(prior_market_cap / idx_prior_market_cap) * (price_change / reference_price * 100) * prior_index`.
  - *Bản chất lỗi:* Biểu thức `Return_i` bị nhân thêm `100` (`* 100`), biến tỷ suất từ dạng số thập phân ($0.0076$) thành phần trăm ($0.76$). Nhưng tỷ trọng $w_i$ đã là dạng thập phân ($0.1406$), khi nhân với $0.76$ và nhân với điểm chỉ số $1,240.10$, điểm đóng góp bị đội lên **100 LẦN** ($132.95$ điểm thay vì $1.33$ điểm, mâu thuẫn ngay với Mockup HLD dòng 3166). Biến thể tương đối `K_GSTT_124` bị nhân 100 hai lần ($10.72\%$ thay vì $0.11\%$).
  - *Đề xuất sửa đổi:* Loại bỏ `* 100` khỏi biểu thức return của `K_GSTT_75` và `K_GSTT_76`. Với `K_GSTT_124` và `K_GSTT_125`, chỉ nhân 100 một lần ở cuối biểu thức.
- **[Critical] LOG-D2-02 — Thiếu trường ngày `trading_dt` trong hàm phân vùng `LAG()` tại Fact Intraday:**
  - *Vị trí:* `Datamart/lld/GSTT/DTM_GSTT_fct_market_index_intraday.csv`, Dòng 6.
  - *Công thức lỗi:*
    `market_index_snapshot.total_val - LAG(market_index_snapshot.total_val) OVER (PARTITION BY market_index_snapshot.market_code ORDER BY market_index_snapshot.index_time)`.
  - *Bản chất lỗi:* Thiếu `trading_dt` trong `PARTITION BY`: Vào phiên mở cửa mỗi ngày (tick đầu tiên), hàm `LAG()` sẽ lấy giá trị tích lũy cuối ngày hôm trước (VD 25,000 tỷ). Khi lấy giá trị mở cửa hôm nay (VD 50 tỷ) trừ đi, sẽ ra con số **ÂM 24,950 TỶ ĐỒNG**! Ngoài ra, thiếu `COALESCE` khiến tick đầu tiên của lịch sử bị NULL.
  - *Đề xuất sửa đổi:* Cập nhật `etl_logic` thành:
    `COALESCE(market_index_snapshot.total_val - LAG(market_index_snapshot.total_val) OVER (PARTITION BY market_index_snapshot.market_code, market_index_snapshot.trading_dt ORDER BY market_index_snapshot.index_time), market_index_snapshot.total_val)`.
- **[Major] LOG-D2-03 — Lệch vũ trụ dữ liệu làm méo mó định giá P/E và EPS của rổ chỉ số:**
  - *Vị trí:* `Datamart/lld/GSTT/DTM_GSTT_fct_index_constituent_snpst.csv`, Dòng 14, 16; `DTM_GSTT_HLD.md`, Dòng 871–873, O_GSTT_24.
  - *Bản chất lỗi:* Tử số của `idx_pe` lấy Vốn hóa toàn bộ 30 mã, nhưng mẫu số chỉ cộng LNST TTM của những mã có BCTC. Nếu 5 mã thiếu BCTC, P/E của rổ bị phóng đại giả tạo. Với `idx_eps`, tử số là LNST của các mã có dữ liệu nhưng mẫu số lại là tổng số cổ phiếu của tất cả các mã, làm pha loãng EPS.
  - *Đề xuất sửa đổi:* Đồng nhất tập hợp mã: Tử số của P/E và mẫu số của EPS chỉ tính trên các mã có `lnst_ttm IS NOT NULL`.
- **[Major] LOG-D2-04 — Nguy cơ thiếu hụt dữ liệu hàng ngày do phụ thuộc Flat Table cuối tháng của QLKD:**
  - *Vị trí:* `Datamart/flat-table/QLKD/01_create_qlkd_flat_tables.sql` line 149; `02_populate_qlkd_flat_tables.sql` line 170.
  - *Hiện tượng:* GSTT tái sử dụng conformed flat table của QLKD (`qlkd_fct_market_index_snpst_flat`), nhưng bảng này được lập lịch chỉ chạy vào ngày `LAST_DAY` của tháng. Nếu BI truy vấn diễn biến hàng ngày cho Nhóm 5 và Nhóm 38, các ngày trong tháng sẽ không có dữ liệu.
  - *Đề xuất sửa đổi:* Tạo riêng bảng `datamart.gstt_fct_market_index_snpst_flat` với grain snapshot hàng ngày, hoặc nâng cấp scheduler của bảng QLKD chạy hàng ngày.
- **[Moderate] LOG-D2-05 — Rủi ro đụng độ mã khi Join `Market Code = Index Code` mà không kèm sàn (`Market Id`):**
  - *Vị trí:* `Datamart/lld/GSTT/DTM_GSTT_fct_index_constituent_snpst.csv` line 11; `DTM_GSTT_HLD.md` O_GSTT_3.
  - *Đề xuất sửa đổi:* Bổ sung điều kiện khớp sàn: `market_index_snapshot.market_id = (CASE WHEN index_constituent_snapshot.floor_code = '10' THEN '10' WHEN index_constituent_snapshot.floor_code IN ('02','04') THEN '02' END)`.

---

### 4.3. DOMAIN 3 — CỔ PHIẾU CƠ SỞ, BIẾN ĐỘNG GIÁ & TOP THỊ TRƯỜNG (`DOM_STOCK_TOP`)

#### 1. Lỗi Mapping (Mapping Discrepancies)
- **[Major] MAP-D3-01 — Tái sử dụng trùng mã KPI `K_GSTT_58` cho 2 định nghĩa công thức P/E có bản chất khác nhau:**
  - *Vị trí:* `DTM_GSTT_HLD.md` Nhóm 7–20, Nhóm 36 (dòng 933, 1053, 2986) so với Nhóm 35 (dòng 2930); `DTM_GSTT_Detail_Mapping.csv` dòng 127 vs dòng 610.
  - *Hiện tượng:* Nhóm 7–20 dùng mẫu số là `outstanding_share_quantity` (khối lượng lưu hành ngày hiện tại từ VSDC). Nhóm 35 (BM021) dùng mẫu số là `weighted_average_outstanding_share_quantity_ttm` (WAOS-TTM bình quân gia quyền 4 kỳ BCTC). Việc gán cùng một mã KPI cho 2 công thức khác nhau gây xung đột semantic layer.
  - *Đề xuất sửa đổi:* Tách riêng chỉ tiêu P/E của Báo cáo BM021 thành mã KPI mới (ví dụ: `K_GSTT_349` hoặc `K_GSTT_58_BM021`).
- **[Minor] MAP-D3-02 — Dòng 214 trong `BA_analyst_GSTT.csv` bị bỏ trống trạng thái mapping:**
  - *Vị trí:* `BRD/BA/BA_analyst_GSTT.csv`, Dòng 214 (STT 13: `% thay đổi trong kỳ`).
  - *Hiện tượng:* Cột 13 rỗng `""`, cột 26 ghi `'P'`. Dù HLD/LLD đã thiết kế thành `K_GSTT_145`, file BA chưa được cập nhật đóng trạng thái.
  - *Đề xuất sửa đổi:* Cập nhật file BA dòng 214: Cột 13 gán `Done`, Cột 14 gán `K_GSTT_145`, Cột 26 gán `Pass`.
- **[Minor] MAP-D3-03 — Lỗi chính tả và lặp từ trong BRD:**
  - *Vị trí:* `BRD/BA/BA_analyst_GSTT.csv`: Dòng 7 ghi sai dấu `"Chỉ sô"`, Dòng 517 lặp từ `"Khối lượng niêm cổ phiếu niêm yết hiện tại"`.
  - *Đề xuất sửa đổi:* Đính chính lỗi chính tả trong file BA.

#### 2. Lỗi Cú pháp / Data Type (Syntax, Types & Precision)
- **[Major] SYN-D3-01 — Cột Nullable nằm trong ORDER BY Key của ClickHouse Flat Table #4:**
  - *Vị trí:* `Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql`, Dòng 278 (`trading_tms Nullable(DateTime)`) và Dòng 299:
    `ORDER BY (assumeNotNull(cdr_dt), security_trading_snpst_dim_id, trading_tms)`.
  - *Hiện tượng:* Đặt cột Nullable vào tuple `ORDER BY` mà không bọc `assumeNotNull()` tạo ra Null-mask trong chỉ mục sơ cấp ClickHouse, làm giảm tốc độ nén và có thể vi phạm cấu hình `allow_nullable_key = 0`.
  - *Đề xuất sửa đổi:* Chuyển thành `trading_tms DateTime NOT NULL` hoặc cập nhật khóa sắp xếp thành:
    `ORDER BY (assumeNotNull(cdr_dt), security_trading_snpst_dim_id, assumeNotNull(trading_tms))`.
- **[Minor] SYN-D3-02 — Sai lệch quy ước kiểu dữ liệu `outstanding_share_quantity`:**
  - *Vị trí:* `DTM_GSTT_fct_stock_portfolio_snpst.csv` dòng 18 (ghi `int`) vs ClickHouse DDL dòng 55 (ghi `Nullable(Int64)`).
  - *Đề xuất sửa đổi:* Đổi kiểu dữ liệu trong file LLD CSV thành `bigint` để tránh rủi ro tràn số int32 (các mã như VPB có 7.9 tỷ CP).

#### 3. Lỗi Logic Nghiệp vụ & Xếp hạng (Business Rules & Ranking)
- **[Critical] LOG-D3-01 — Lỗi biên cửa sổ Window Function trong Top Vượt đỉnh (Nhóm 15) và Top Thủng đáy (Nhóm 17):**
  - *Vị trí:* `Datamart/hld/DTM_GSTT_HLD.md`, Dòng 1404–1406, 1523–1525; `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`, Dòng 273–275, 310–312.
  - *Công thức lỗi:*
    `MAX(High Price) OVER (PARTITION BY Symbol ORDER BY Trading Date ROWS BETWEEN 259 PRECEDING AND CURRENT ROW)`.
  - *Bản chất lỗi:* Việc đưa `CURRENT ROW` vào hàm MAX khiến khi một cổ phiếu lập đỉnh mới trong ngày hôm nay, giá trị "Đỉnh cũ" được tính ra sẽ bằng chính mức giá hôm nay (`Đỉnh cũ = High Price hôm nay`). Do đó, điều kiện nghiệp vụ để lọc "Vượt đỉnh" (`High Price > Đỉnh cũ`) sẽ **luôn luôn trả về False**! Màn hình Top Vượt đỉnh và Thủng đáy sẽ hiển thị rỗng hoàn toàn.
  - *Đề xuất sửa đổi:* Sửa lại khung cửa sổ loại trừ phiên hiện tại:
    - Đỉnh cũ 52 tuần (`K_GSTT_106`): `ROWS BETWEEN 259 PRECEDING AND 1 PRECEDING`.
    - Đỉnh cũ 6 tháng (`K_GSTT_141`): `ROWS BETWEEN 129 PRECEDING AND 1 PRECEDING`.
    - Đỉnh cũ 3 tháng (`K_GSTT_140`): `ROWS BETWEEN 64 PRECEDING AND 1 PRECEDING`.
    - Áp dụng tương tự cho các chỉ tiêu Đáy cũ (`K_GSTT_107`, `K_GSTT_142`, `K_GSTT_143`, `K_GSTT_176`).
- **[Critical] LOG-D3-02 — Thiếu Guard Condition cho P/E và P/B âm khi Doanh nghiệp Lỗ hoặc Âm VCSH:**
  - *Vị trí:* `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`, Dòng 127, 169, 203, 237, 277, 314, 350, 610.
  - *Hiện tượng:* Công thức `close_price / (net_profit_after_tax_ttm / outstanding_share_quantity)` không có điều kiện `net_profit_after_tax_ttm > 0`. Khi doanh nghiệp lỗ, P/E bị âm. Trên Dashboard Top P/E thấp nhất, các công ty lỗ nặng nhất sẽ bị xếp lên đầu danh sách như thể là cổ phiếu siêu rẻ.
  - *Đề xuất sửa đổi:* Bổ sung biểu thức bảo vệ:
    `CASE WHEN fct_stock_portfolio_snpst.net_profit_after_tax_ttm > 0 THEN ... ELSE NULL END`.
- **[Major] LOG-D3-03 — Lỗi Copy-Paste điều kiện thỏa thuận trong file BA CSV:**
  - *Vị trí:* `BRD/BA/BA_analyst_GSTT.csv`, Dòng 113, 114 (STT 7); Dòng 149, 150 (STT 9); Dòng 219, 220 (STT 13); Dòng 247, 248 (STT 15); Dòng 279, 280 (STT 17); Dòng 309, 310 (STT 19).
  - *Hiện tượng:* Cột `Điều kiện chung` của `"KLGD thỏa thuận"` và `"GTGD thỏa thuận"` bị ghi nhầm thành `NOT IN ('T1','T2','T3','T4','T6','R1')` (điều kiện khớp lệnh thường) thay vì `IN ('T1','T2','T3','T4','T6','R1')`.
  - *Đề xuất sửa đổi:* Yêu cầu BA đính chính dứt điểm thành `IN (...)` trong file BRD.
- **[Major] LOG-D3-04 — Chưa fallback mã ngành cấp 1 (`business_line_level_1_code`) cho CTCK:**
  - *Vị trí:* `Datamart/flat-table/GSTT/02_populate_gstt_flat_tables.sql`, Dòng 140 và Dòng 143 (`O_GSTT_37`).
  - *Hiện tượng:* Dòng 143 đã fallback tên ngành thành `'Tài chính - Ngân hàng'`, nhưng Dòng 140 lại không có fallback cho mã ngành cấp 1 (bị NULL). Người dùng lọc Dashboard theo mã ngành sẽ bỏ sót toàn bộ các CTCK.
  - *Đề xuất sửa đổi:* Bổ sung fallback mã ngành chuẩn cho CTCK:
    `COALESCE(pc_dim.business_line_level_1_code, CASE WHEN sc_dim.securities_company_dim_id IS NOT NULL THEN 'K' END) AS business_line_level_1_code`.

---

### 4.4. DOMAIN 4 — XU HƯỚNG DÒNG TIỀN & NHÓM NHÀ ĐẦU TƯ (`DOM_CASH_FLOW`)

#### 1. Lỗi Mapping (Mapping Discrepancies)
- **[Major] MAP-D4-01 — Gộp sai 2 màn hình khác biệt & Lệch số thứ tự +1 từ BA STT 28:**
  - *Vị trí:* `BRD/BA/BA_analyst_GSTT.csv` dòng 424–430 (STT 28) vs `DTM_GSTT_HLD.md` Nhóm 28 (dòng 2269–2324).
  - *Hiện tượng:* BA STT 28 ("Bản đồ nhiệt GT khối ngoại theo chỉ số", 7 dòng) bị gộp vào HLD Nhóm 28 ("Giao dịch tự doanh"). Dẫn tới lệch +1 cho toàn bộ 20 nhóm phía sau (BA STT 29–48).
  - *Đề xuất sửa đổi:* Tách riêng BA STT 28 thành nhóm HLD riêng hoặc cập nhật file BA đánh lại số STT để đạt tính ánh xạ 1:1.
- **[Major] MAP-D4-02 — Typo sao chép nhầm biến Mua sang Bán trong BA:**
  - *Vị trí:* `BRD/BA/BA_analyst_GSTT.csv`, Dòng 444, 452, 461, 475 (STT 30–33).
  - *Hiện tượng:* Phía Bán của "Cá nhân trong nước" và "Tổ chức trong nước" bị ghi nhầm điều kiện `buy_invest_type = '8000'` thay vì `sell_invest_type`.
  - *Đề xuất sửa đổi:* Đính chính cột "Mapping (nghiệp vụ)" thành `sell_invest_type = '8000'` và `<> '8000'`.
- **[Minor] MAP-D4-03 — Typo trường nguồn "GT bán ròng":**
  - *Vị trí:* `BRD/BA/BA_analyst_GSTT.csv`, Dòng 347 (STT 21). Ghi "GT bán ròng" nhưng trường nguồn ghi `Buy - Foreigner Investor type`. Cần sửa thành `Sell`.
- **[Minor] MAP-D4-04 — Gán nhầm `mart_column = Buy Value` cho vai trò FILTER:**
  - *Vị trí:* `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`, Dòng 513, 515, 517, 524, 526, 528, 550, 552, 554. Các dòng FILTER ẩn ngày 0 đều gán cứng `mart_column = Buy Value`. Cần để trống cột này trên các dòng `column_role = FILTER`.

#### 2. Lỗi Cú pháp / Data Type (Syntax, Types & Precision)
- **[Critical] SYN-D4-01 — Sai cú pháp hàm DATE_TRUNC trên trường String:**
  - *Vị trí:* `Datamart/lld/GSTT/DTM_GSTT_fct_foreign_trading_min_snpst.csv`, Dòng 4 (`trade_minute_tms`).
  - *Hiện tượng:* Cột `etl_logic` ghi: `DATE_TRUNC('minute', securities_trade.trade_time)`. Trong khi `trade_time` ở Atomic là kiểu `string` (`'093015'`). Hàm `DATE_TRUNC` chỉ chấp nhận đối số kiểu DateTime/Timestamp; truyền chuỗi thô sẽ lập tức gây lỗi `TypeMismatch` tại runtime Spark/SQL.
  - *Đề xuất sửa đổi:* Sửa thành: `DATE_TRUNC('minute', to_timestamp(concat(securities_trade.trade_dt, ' ', securities_trade.trade_time), 'yyyy-MM-dd HHmmss'))`.
- **[Major] SYN-D4-02 — Lệch Nullability và Khóa ORDER BY trên Flat Table #6:**
  - *Vị trí:* `Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql`, Dòng 357 & 381 vs Fact CSV dòng 4.
  - *Hiện tượng:* LLD Fact quy định `nullable: false`, nhưng Flat Table #6 lại khai báo `Nullable(String)` và đưa vào `ORDER BY`. Flat Table #7 đối ứng khai đúng `String`.
  - *Đề xuất sửa đổi:* Sửa dòng 357 thành `investor_category_code String NOT NULL` để đồng bộ 100% với Fact schema và bảng Flat #7.
- **[Minor] SYN-D4-03 — Không nhất quán bộ lọc NĐTNN:**
  - *Vị trí:* `DTM_GSTT_fct_foreign_trading_min_snpst.csv` dòng 5, 6 lọc `IN ('10','20')`, còn các bảng khác lọc `<> '00'`. Cần chuẩn hóa về `IN ('10','20')` theo từ điển KRX.

#### 3. Lỗi Logic Nghiệp vụ & Dòng tiền (Business Rules & Cash Flow Logic)
- **[Critical] LOG-D4-01 — Công thức Tổ chức trong nước làm ÂM Giá trị Mua/Bán và Xung đột Phân vùng:**
  - *Vị trí:* `Datamart/lld/GSTT/DTM_GSTT_fct_investor_category_trading_snpst.csv` dòng 4, 5, 7, 9–12; `DTM_GSTT_fct_investor_category_index_trading_snpst.csv` dòng 4–10; `DTM_GSTT_HLD.md` dòng 136 & 4077.
  - *Công thức lỗi:*
    `Tổ chức trong nước = (GT TC mua − GT TC bán) − (GT tự doanh mua − GT tự doanh bán)`
    với điều kiện TC mỗi phía: `foreign_investor_type = '00' AND investor_type <> '8000'`.
  - *Bản chất lỗi:* Nếu một giao dịch mua được thực hiện bởi Khối Tự doanh của CTCK có vốn đầu tư nước ngoài (`client_house = '30'` và `foreign <> '00'`), số hạng 1 bằng 0, số hạng 2 bằng `execution_val`. Hiệu số `buy_val` của Tổ chức trong nước bị **ÂM** (`0 - execution_val = -execution_val`)! Trong khi đó, `buy_val` về bản chất kinh tế bắt buộc phải `>= 0`. Hơn nữa, việc trừ chéo vi phạm nguyên tắc phân vùng độc lập giữa 4 nhóm nhà đầu tư.
  - *Đề xuất sửa đổi:* Bỏ phép trừ chéo. Thay bằng Cây quyết định phân loại độc lập phân vùng (Mutually Exclusive Decision Tree):
    1. Tự doanh: `client_house_cl_code = '30'`
    2. Nước ngoài: `client_house_cl_code <> '30' AND foreign_investor_tp_code IN ('10','20')`
    3. Cá nhân trong nước: `client_house_cl_code <> '30' AND foreign_investor_tp_code = '00' AND investor_tp_code = '8000'`
    4. Tổ chức trong nước: `client_house_cl_code <> '30' AND foreign_investor_tp_code = '00' AND investor_tp_code <> '8000'`.
- **[Major] LOG-D4-02 — Bất nhất quy ước biểu diễn Mua ròng / Bán ròng (Signed vs Zero-clamped):**
  - *Vị trí:* `DTM_GSTT_HLD.md` Nhóm 21 (dòng 1743, 1763, 1765) vs Nhóm 28 (dòng 2283, 2300, 2301).
  - *Hiện tượng:* Nhóm 28 áp dụng `GREATEST(..., 0)` nên Bán ròng = 0 khi Mua > Bán. Nhóm 21 Mockup lại hiển thị số âm `-15 Tỷ` trên cột Bán ròng.
  - *Đề xuất sửa đổi:* Thống nhất quy ước: Đã tách 2 cột riêng "Mua ròng" và "Bán ròng" thì bắt buộc áp dụng `GREATEST(..., 0)` để cả 2 cột luôn nhận giá trị `>= 0`.
- **[Major] LOG-D4-03 — Rủi ro Fan-out nhân đôi dữ liệu khi tính GTNN chỉ số:**
  - *Vị trí:* `DTM_GSTT_HLD.md` Nhóm 26 (dòng 2081, 2096, 2097) & O_GSTT_41.
  - *Hiện tượng:* Drill-across `fct_foreign_trading_min_snpst` × `fct_index_constituent_snpst` nếu không khóa chặt 1 `Index Code` sẽ nhân đôi giao dịch của các cổ phiếu thuộc nhiều rổ chỉ số (như VCB vừa thuộc VNINDEX vừa thuộc VN30).
  - *Đề xuất sửa đổi:* Bắt buộc mệnh đề `WHERE Index Code = :selected_index` tại tầng BI.

---

### 4.5. DOMAIN 5 — SẢN PHẨM CHUYÊN BIỆT, SỞ HỮU, TRÁI PHIẾU & PHÁI SINH (`DOM_SPECIALIZED`)

#### 1. Lỗi Mapping (Mapping Discrepancies)
- **[Major] MAP-D5-01 — Sao chép nhầm câu lệnh SQL phân ngành IDS vào sản phẩm phái sinh:**
  - *Vị trí:* `BRD/BA/BA_analyst_GSTT.csv`, Dòng 791 (STT 47).
  - *Hiện tượng:* Cột "Thông tin" ghi sai chính tả `Sàn phẩm phái sinh`. Cột "Câu lệnh tham khảo" dán nhầm câu lệnh truy vấn phân ngành doanh nghiệp IDS: `SELECT c.industry_cd, c.industry_name FROM IDS.categories...`.
  - *Đề xuất sửa đổi:* Sửa chính tả `Sản phẩm phái sinh`, thay câu lệnh SQL tham khảo bằng logic lọc phái sinh chuẩn: `FloorCode = '03'` từ `MDDS.JAD_STOCKINFOR`.
- **[Major] MAP-D5-02 — Ghi nhầm mã thị trường cổ phiếu cho Trái phiếu & Phái sinh tại STT 41 & 42:**
  - *Vị trí:* `BRD/BA/BA_analyst_GSTT.csv`, Dòng 621–622 (STT 41) & Dòng 633, 801 (STT 42, 47).
  - *Hiện tượng:* Cột "Điều kiện chung" ghi `MARKET_ID IN ('STK','STX','UPX')` (thị trường cổ phiếu). Nếu áp dụng, kết quả trả về sẽ là **0 dòng dữ liệu** vì Trái phiếu giao dịch tại `BDO, HCX` và Phái sinh tại `DVX`.
  - *Đề xuất sửa đổi:* Yêu cầu BA sửa thành `Market ID IN ('BDO','HCX')` cho Trái phiếu và `Market ID = 'DVX'` cho Phái sinh.
- **[Minor] MAP-D5-03 — Mâu thuẫn giữa điều kiện chung và SQL tham khảo tại STT 48:**
  - *Vị trí:* `BRD/BA/BA_analyst_GSTT.csv`, Dòng 802. Điều kiện ghi `STOCKTYPE = '1'`, nhưng SQL tham khảo lại viết `STOCKTYPE <> '1'`. Sửa thành `AND s.STOCKTYPE = '1'`.
- **[Minor] MAP-D5-04 — Thiếu mã thị trường trái phiếu HOSE (`BDO`) tại STT 48:**
  - *Vị trí:* `BRD/BA/BA_analyst_GSTT.csv`, Dòng 804. Chỉ ghi `AND t.[Market ID] in (HCX)`, bỏ sót thị trường `BDO`. Cần bổ sung `BDO`.
- **[Major] MAP-D5-05 — Mâu thuẫn tên gọi và bản chất nghiệp vụ giữa STT 35 (Dòng 510) và STT 38 (Dòng 572):**
  - *Vị trí:* `BRD/BA/BA_analyst_GSTT.csv`, Dòng 510 vs Dòng 572. Cả 2 đều đặt tên là *"Sở hữu cổ đông lớn của người nội bộ/ban lãnh đạo"*, nhưng STT 35 là Số cổ phiếu của người nội bộ (`K_GSTT_103b`), còn STT 38 là Tổng tỷ lệ sở hữu của tất cả cổ đông lớn (`K_GSTT_178`).
  - *Đề xuất sửa đổi:* Đổi tên tiêu đề tại STT 38 thành **"Tổng tỷ lệ sở hữu của các cổ đông lớn"**.

#### 2. Lỗi Cú pháp / Data Type & Precision Drift
- **[Critical] TYP-D5-01 — Lệch độ chính xác (Precision Drift) trên Lợi suất và Lãi suất Coupon Trái phiếu:**
  - *Vị trí:* `Datamart/lld/GSTT/DTM_GSTT_security_trading_snpst_dim_MDDS_JAD_STOCKINFOR.csv`, Dòng 24, 25 (`decimal(8,5)`) so với ClickHouse Flat Table #1 DDL `01_create_gstt_flat_tables.sql`, Dòng 124, 125 (`Nullable(Decimal(7,4))`).
  - *Hiện tượng:* Lợi suất YTM và coupon trái phiếu yêu cầu độ chính xác 5 chữ số thập phân (đo lường half basis point = 0.005% = 0.00005). Việc ClickHouse DDL dùng `Decimal(7,4)` làm **cắt cụt hoặc làm tròn sai chữ số thập phân thứ 5**, gây sai lệch giá trị định giá danh mục nợ hàng nghìn tỷ đồng và vi phạm test oracle độc lập.
  - *Đề xuất sửa đổi:* Sửa dòng 124–125 trong `01_create_gstt_flat_tables.sql` thành:
    `coupon_rate Nullable(Decimal(8,5))`, `yield Nullable(Decimal(8,5))`.
- **[Major] TYP-D5-02 — Bất đồng kiểu dữ liệu (Type Mismatch) giữa Dimension (`string`) và Flat Table (`Decimal(10,2)`):**
  - *Vị trí:* `DTM_GSTT_security_trading_snpst_dim_MDDS_JAD_STOCKINFOR.csv`, Dòng 20, 22 (`string`) vs `01_create_gstt_flat_tables.sql`, Dòng 119, 122 (`Nullable(Decimal(10,2))`) trên `exercise_ratio` và `contract_multiplier`.
  - *Hiện tượng:* DML gán thẳng `sec_dim.exercise_ratio AS exercise_ratio` mà không có hàm ép kiểu. Tỷ lệ chứng quyền thường là dạng chuỗi `'2:1'`, `'5:1'`. Khi nạp chuỗi vào Decimal, câu lệnh INSERT sẽ bị **FAIL (Type Mismatch Exception)** hoặc nạp NULL toàn bộ.
  - *Đề xuất sửa đổi:* Bổ sung hàm ép kiểu an toàn: `toDecimal64OrNull(splitByChar(':', sec_dim.exercise_ratio)[1], 2)` hoặc đổi kiểu Flat Table thành `Nullable(String)`.

#### 3. Lỗi Logic Nghiệp vụ & Rủi ro Kiến trúc (Business Rules & Architectural Risks)
- **[Critical] LOG-D5-01 — Rủi ro đụng độ định danh (PII Collision) khi nối Cổ đông VSDC sang IDS để lấy chức vụ:**
  - *Vị trí:* `Datamart/lld/GSTT/DTM_GSTT_fct_major_shareholder_ownership_snpst.csv`, Dòng 10 (`position_code`).
  - *Hiện tượng:* Logic ETL nối cổ đông VSDC sang IDS (`ip_alternative_identification`) chỉ dựa trên `identification_nbr` mà **hoàn toàn bỏ qua điều kiện loại giấy tờ** (`identity_type_cd = '4'` — CCCD/CMND).
  - *Hệ quả:* Một số CMND 9 số cũ của cá nhân có thể trùng lặp ngẫu nhiên với mã số thuế doanh nghiệp hoặc hộ chiếu nước ngoài. Một cổ đông cá nhân có thể bị gán nhầm chức vụ Chủ tịch HĐQT của một công ty khác.
  - *Đề xuất sửa đổi:* Bổ sung điều kiện loại giấy tờ: `AND ip_alternative_identification.identity_type_cd = '4'`.
- **[Major] LOG-D5-02 — Rủi ro Fan-out nhân đôi số liệu sở hữu khối ngoại / trong nước cấp doanh nghiệp:**
  - *Vị trí:* `Datamart/hld/DTM_GSTT_HLD.md`, Dòng 2799, 2816–2817; `01_create_gstt_flat_tables.sql`, Dòng 444–445.
  - *Hiện tượng:* `current_foreign_holding_quantity` và `domestic_holding_quantity` là số liệu cấp công ty, nhưng grain của bảng lại là 1 dòng / mã CK × cổ đông lớn. Do đó, số lượng cổ phiếu của công ty bị lặp lại trên toàn bộ N dòng cổ đông lớn. Nếu BI dùng hàm `SUM()`, số liệu sẽ bị nhân lên N lần.
  - *Đề xuất sửa đổi:* Gắn cờ thuộc tính này là `Semi-Additive` / `Non-Additive` (chỉ dùng `MAX()` hoặc `AVG()`, cấm tuyệt đối hàm `SUM()`). Bổ sung comment cảnh báo trên Flat Table #8.
- **[Major] LOG-D5-03 — Lỗ hổng quy tắc cắt chuỗi Heuristic `SUBSTR(symbol, 1, 3)` để xác định ngành trái phiếu:**
  - *Vị trí:* `Datamart/lld/GSTT/DTM_GSTT_fct_stock_portfolio_snpst.csv`, Dòng 3; `DTM_GSTT_HLD.md`, Dòng 4082 (`O_GSTT_37`).
  - *Hiện tượng:* Áp dụng cắt 3 ký tự đầu `SUBSTR(symbol, 1, 3)` để tìm mã TCPH trái phiếu. Danh sách loại trừ hiện tại chưa có trái phiếu chính quyền địa phương: Trái phiếu Đà Nẵng (`DNG...`) sẽ bị cắt lấy `DNG` và JOIN nhầm vào mã cổ phiếu `DNG` (Dược Danapha); Trái phiếu Bình Dương (`BDG...`) JOIN nhầm vào May Mặc Bình Dương!
  - *Đề xuất sửa đổi:* Sử dụng trường `ISSUER_CODE` trong bảng danh mục trái phiếu nguồn của SGDCK thay vì dùng hàm cắt chuỗi heuristic.

---

## 5. PHÂN TÍCH XU HƯỚNG & RỦI RO HỆ THỐNG (SYSTEMIC RISKS & ARCHITECTURAL ANOMALIES)

Dưới đây là phân tích chuyên sâu về 7 vấn đề lỗi kiến trúc mang tính toàn hệ thống, có nguy cơ phá vỡ tính toàn vẹn dữ liệu và gây tê liệt vận hành nếu không được xử lý dứt điểm trước khi Golive:

```
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                              7 LỖI KIẾN TRÚC TOÀN HỆ THỐNG TRỌNG YẾU                                   │
├────┬─────────────────────────────────────────────────┬───────────────────┬─────────────────────────────┤
│ STT│ Tên Rủi Ro Hệ Thống                             │ Vùng Ảnh Hưởng    │ Bản Chất Nguy Cơ            │
├────┼─────────────────────────────────────────────────┼───────────────────┼─────────────────────────────┤
│ 1  │ Lỗi biên Window Function 52-week High/Low       │ DOM_STOCK_TOP     │ Tự triệt tiêu tín hiệu Top  │
│ 2  │ Phóng đại 100 lần Điểm đóng góp chỉ số          │ DOM_MARKET_INDEX  │ Méo mó số liệu báo cáo UBCK │
│ 3  │ Hàm LAG Intraday thiếu partition ngày           │ DOM_MARKET_INDEX  │ Âm 25.000 tỷ phiên mở cửa   │
│ 4  │ Lộ lọt Mật mã PIN và PII khách hàng             │ DOM_ORDER_TRADE   │ Vi phạm NĐ 13/2023/NĐ-CP    │
│ 5  │ ReplacingMergeTree ORDER BY thiếu mã CK         │ DOM_ORDER_TRADE   │ Merge Collision mất dữ liệu │
│ 6  │ Công thức dòng tiền làm âm Buy Value tổ chức    │ DOM_CASH_FLOW     │ Vi phạm bất biến kinh tế    │
│ 7  │ Bộ test oracles độc lập bị thoái hóa (Stale)    │ TOÀN HỆ THỐNG     │ Khoảng mù kiểm thử tự động  │
└────┴─────────────────────────────────────────────────┴───────────────────┴─────────────────────────────┘
```

### 5.1. Lỗi Biên Window Function 52-Week High/Low (`CURRENT ROW` Gây Tự Triệt Tiêu Tín Hiệu Phá Vỡ)
- **Bản chất kỹ thuật:** Trong phân tích kỹ thuật và định lượng tài chính, một cổ phiếu được định nghĩa là "vượt đỉnh" khi giá cao nhất trong phiên hôm nay vượt qua mốc trần kháng cự của toàn bộ các phiên trong quá khứ ($P_t > \max_{k=1}^N P_{t-k}$). Khung cửa sổ chuẩn mực bắt buộc phải là `ROWS BETWEEN N PRECEDING AND 1 PRECEDING`.
- **Lỗi hiện tại:** Trong HLD Nhóm 15 (`K_GSTT_140`, `K_GSTT_141`, `K_GSTT_106`) và Nhóm 17 (`K_GSTT_142`, `K_GSTT_143`, `K_GSTT_107`), khung cửa sổ lại được viết là `ROWS BETWEEN N PRECEDING AND CURRENT ROW`.
- **Hậu quả hệ thống:** Do bao gồm `CURRENT ROW`, khi một cổ phiếu tăng trần tạo kỷ lục giá mới, hàm `MAX()` lập tức nuốt chửng mức giá này, khiến giá trị `Đỉnh cũ` tự động nhảy lên bằng chính giá hôm nay (`Đỉnh cũ = High Price`). Do đó, biểu thức kiểm tra vượt đỉnh `High Price > Đỉnh cũ` trở thành vô nghiệm (luôn trả về False). Toàn bộ màn hình Top Vượt đỉnh và Thủng đáy của hệ thống giám sát thị trường sẽ hiển thị 0 bản ghi!

### 5.2. Lỗi Phóng Đại 100 Lần Điểm Đóng Góp Chỉ Số (`K_GSTT_75, 76, 124, 125`)
- **Bản chất kỹ thuật:** Điểm đóng góp của một cổ phiếu vào chỉ số được tính theo công thức:
  $$\text{Contribution} = w_i \times \text{Return}_i \times \text{Index}_{t-1}$$
  Trong đó tỷ trọng vốn hóa $w_i$ là số thập phân ($0.1406$), tỷ suất biến động giá $\text{Return}_i = (P_t - P_{\text{ref}}) / P_{\text{ref}}$ là số thập phân ($0.0076$), và điểm chỉ số hôm trước là $1,240.10$. Kết quả đóng góp chuẩn của VCB là $+1.33$ điểm (như Mockup HLD dòng 3166 đã chỉ ra).
- **Lỗi hiện tại:** Trong Detail Mapping dòng 694 và 699, người thiết kế đã nhân 100 vào biểu thức return: `(price_change / reference_price * 100)`.
- **Hậu quả hệ thống:** Điểm đóng góp tính ra bị đội lên thành **132.95 điểm (GẤP 100 LẦN)**! Nếu toàn bộ chỉ số VN-Index chỉ tăng 5 điểm trong ngày mà 1 cổ phiếu được báo cáo đóng góp tới 132.95 điểm, toàn bộ dữ liệu giám sát vĩ mô của UBCKNN sẽ bị sai lệch nghiêm trọng, làm mất uy tín của hệ thống phần mềm giám sát quốc gia.

### 5.3. Lỗi LAG Intraday Thiếu Partition Ngày (Gây Âm Chục Nghìn Tỷ Đồng Phiên Mở Cửa)
- **Bản chất kỹ thuật:** `Fact Market Index Intraday` ghi nhận các tick thời gian trong ngày (`index_time`). Cột `total_val_at_time` đo lường giá trị giao dịch phát sinh trong từng khoảng thời gian (delta) bằng cách lấy tổng giá trị lũy kế hiện tại trừ đi tổng giá trị lũy kế của tick liền trước thông qua hàm `LAG()`.
- **Lỗi hiện tại:** Trong `DTM_GSTT_fct_market_index_intraday.csv` dòng 6, mệnh đề phân vùng chỉ có: `PARTITION BY market_code ORDER BY index_time`.
- **Hậu quả hệ thống:**
  1. Thiếu `trading_dt`: Vào tick mở cửa 09:15 sáng hôm nay, hàm `LAG()` sẽ lấy giá trị lũy kế cuối phiên của ngày hôm trước (ví dụ 25,000 tỷ đồng). Lấy giá trị mở cửa hôm nay (ví dụ 50 tỷ) trừ đi, kết quả trả về là **ÂM 24,950 TỶ ĐỒNG**!
  2. Khi chạy ETL trên tập dữ liệu lịch sử nhiều ngày, việc sắp xếp theo `index_time` thuần túy làm các tick cùng giờ của các ngày khác nhau bị xáo trộn đan xen.
  3. Thiếu `COALESCE`: Tại tick đầu tiên của lịch sử, phép trừ với NULL trả về NULL, làm biến mất giá trị giao dịch phiên ATO.

### 5.4. Lộ Lọt Dữ Liệu Nhạy Cảm PII và Mật Mã PIN Tài Khoản Khách Hàng (Vi Phạm Nghị Định 13/2023/NĐ-CP)
- **Bản chất an toàn thông tin:** Mã PIN tài khoản giao dịch (`account_pin_code`, `buy_account_pin_code`, `sell_account_pin_code`) là thông tin bí mật xác thực tài khoản tối quan trọng của công dân và nhà đầu tư, được bảo vệ nghiêm ngặt theo Nghị định 13/2023/NĐ-CP và Luật Chứng khoán.
- **Lỗi hiện tại:** Cả 3 cột mã PIN cùng với số tài khoản và họ tên NĐT được đưa nguyên văn dạng plaintext vào 4 bảng Flat Tables ClickHouse (#9, #10, #11, #12). Trong file DML ETL, không có bất kỳ hàm băm (hash), mã hóa hoặc masking nào được áp dụng.
- **Hậu quả hệ thống:** Tầng ClickHouse Flat Tables là tầng cung cấp cho các ứng dụng BI, Data Explorer và các phòng ban nghiệp vụ truy vấn trực tiếp. Việc lưu trữ mã PIN plaintext khiến mọi người dùng có quyền SELECT đều đọc được mật khẩu khách hàng. Đây là một lỗ hổng bảo mật cấp bách có thể dẫn đến việc chiếm đoạt tài khoản nhà đầu tư và trách nhiệm pháp lý hình sự đối với đơn vị vận hành hệ thống.

### 5.5. Khóa ORDER BY ReplacingMergeTree ClickHouse Thiếu Mã CK (Nguy Cơ Merge Collision Làm Mất Dữ Liệu)
- **Bản chất động cơ lưu trữ:** ClickHouse `ReplacingMergeTree` là engine loại bỏ trùng lặp trong quá trình nén nền (background merge). Bất kỳ các dòng nào có cùng bộ giá trị trong khóa `ORDER BY` sẽ bị ClickHouse **tự động gộp lại thành 1 dòng duy nhất, các dòng trước đó bị xóa vĩnh viễn khỏi ổ đĩa**.
- **Lỗi hiện tại:** Khóa `ORDER BY` của Bảng #9 và #10 trong `01_create_gstt_flat_tables.sql` được định nghĩa là: `(assumeNotNull(trade_cdr_dt), securities_trade_code)`. Trong khi đó, tài liệu LDM Atomic khẳng định `securities_trade_code` là số thứ tự được đánh độc lập theo từng mã chứng khoán trong ngày (`TRADE_ID` từ 1 đến N).
- **Hậu quả hệ thống:**
  1. **Mất mát dữ liệu thầm lặng (Silent Data Loss):** Nếu trong ngày có 100 mã cổ phiếu khác nhau cùng phát sinh giao dịch số 1, số 2, số 3... thì trong quá trình background merge, ClickHouse sẽ chỉ giữ lại đúng 1 dòng cho mỗi số thứ tự và xóa sạch 99 giao dịch của các mã còn lại!
  2. **Tê liệt hiệu năng truy vấn (Full Table Scan):** Người dùng luôn truy vấn theo mã CK (`WHERE security_symbol_code = 'VCB'`). Do mã CK không nằm trong khóa `ORDER BY`, sparse index của ClickHouse bị vô hiệu hóa hoàn toàn, buộc hệ thống phải quét toàn bộ hàng triệu dòng giao dịch của ngày hôm đó, gây nghẽn I/O và sập cụm cluster khi tải cao.

### 5.6. Lỗi Logic Phân Loại Dòng Tiền Dẫn Tới Giá Trị Mua/Bán của Tổ Chức Trong Nước Bị ÂM
- **Bản chất kinh tế:** Giá trị mua (`buy_val`) và giá trị bán (`sell_val`) của một nhóm nhà đầu tư trên thị trường chứng khoán là các đại lượng đo lường dòng tiền phát sinh thực tế, bắt buộc phải thỏa mãn tính chất toán học không âm ($buy\_val \ge 0, sell\_val \ge 0$).
- **Lỗi hiện tại:** Trong `DTM_GSTT_fct_investor_category_trading_snpst.csv` dòng 5, giá trị của Tổ chức trong nước được tính bằng công thức:
  `[Tổ chức] = [Foreign = '00' AND Investor Type <> '8000'] − [Tự doanh (Client House = '30')]`.
- **Hậu quả hệ thống:** Khi một CTCK có vốn đầu tư nước ngoài (như Mirae Asset, KBSV, KIS...) thực hiện giao dịch tự doanh mua cổ phiếu, bản ghi có `client_house = '30'` và `foreign <> '00'`. Khi đưa vào công thức trên, số hạng thứ nhất bằng 0, số hạng thứ hai bằng `execution_val`. Hiệu số tính ra cho `buy_val` của Tổ chức trong nước bị **ÂM**! Một giao dịch tự doanh nước ngoài lại làm giảm giá trị mua của tổ chức trong nước, phá vỡ tính đúng đắn của dữ liệu giám sát dòng tiền quốc gia.

### 5.7. Sự Thoái Hóa Của Bộ Kiểm Thử Hồi Quy Độc Lập (Stale Regression Test Suites)
- **Bản chất kiểm thử phần mềm:** Bộ kiểm thử hồi quy độc lập (`tests/test_gstt_integrity_oracles.py`, `tests/test_datamart_date_fk_checker.py`, `tests/test_gstt_mutation_challenger.py`) đóng vai trò là "chốt chặn an toàn" (safety net) tự động ngăn chặn lỗi hồi quy khi mã nguồn được phát triển liên tục.
- **Lỗi hiện tại:**
  - File test `test_gstt_integrity_oracles.py` bị "đóng băng" cứng các hằng số kiểm tra của ngày 2026-09-26 (hardcode 42 nhóm, 262 KPI, 10 bảng flat, 18 READY). Khi commit `e5a817ab` nâng cấp hệ thống lên 48 nhóm, 348 KPI và 12 bảng flat, file test này bị **FAIL 4/7 test**.
  - File `test_datamart_date_fk_checker.py` hardcode kiểm tra `clean_fact_tables_count == 5`, trong khi thực tế có 12 fact tables sạch, dẫn đến **FAIL tại dòng 225 (`AssertionError: 12 != 5`)**.
- **Hậu quả hệ thống:** Các báo cáo trước đó khẳng định "100% Quality Gates PASS" chỉ dựa vào công cụ nội bộ `run_quality_gates.py` mà lờ đi sự thất bại của bộ test oracles độc lập. Tình trạng "test suite facade" này tạo ra một khoảng mù kiểm thử (blind spot), khiến các lỗi hồi quy thực sự trong tương lai không thể bị phát hiện bởi CI/CD pipeline.

---

## 6. KẾ HOẠCH KHẮC PHỤC TỔNG HỢP (CONSOLIDATED ACTION PLAN)

Để chuyển đổi trạng thái phân hệ GSTT từ **`REQUEST_CHANGES`** sang **`APPROVED / READY FOR GOLIVE`**, toàn bộ 32 phát hiện được tổng hợp thành Kế hoạch Hành động Cụ thể (Action Plan), phân định rõ độ ưu tiên và vai trò trách nhiệm:

### 6.1. Bảng Kế Hoạch Hành Động Theo Mức Độ Ưu Tiên (Priority Breakdown)

```
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                              MA TRẬN KẾ HOẠCH HÀNH ĐỘNG TỔNG HỢP                                       │
├──────────────┬──────────────┬───────────────────────────────────────────────────────────┬──────────────┤
│ Mã Hành Động │ Độ Ưu Tiên   │ Nội Dung Khắc Phục Kỹ Thuật                               │ Tệp Tin Cần Sửa
├──────────────┼──────────────┼───────────────────────────────────────────────────────────┼──────────────┤
│ ACT-MASTER-01│ P0 Critical  │ Loại bỏ hoàn toàn mã PIN khỏi Datamart & Flat Tables      │ Flat DDL/DML, LLD CSV
│ ACT-MASTER-02│ P0 Critical  │ Sửa khóa ORDER BY Table #9, #10 bổ sung security_symbol_code│ 01_create_gstt_flat_tables.sql
│ ACT-MASTER-03│ P0 Critical  │ Bỏ '* 100' trong Return_i của Điểm đóng góp chỉ số         │ DTM_GSTT_Detail_Mapping.csv
│ ACT-MASTER-04│ P0 Critical  │ Thêm 'trading_dt' vào PARTITION BY và COALESCE hàm LAG Intraday │ DTM_GSTT_fct_market_index_intraday.csv
│ ACT-MASTER-05│ P0 Critical  │ Sửa Window Function Top Vượt đỉnh/Thủng đáy thành '1 PRECEDING' │ DTM_GSTT_HLD.md, Detail Mapping
│ ACT-MASTER-06│ P0 Critical  │ Thay thế công thức Tổ chức trong nước bằng Cây quyết định độc lập │ DTM_GSTT_fct_investor_category_*.csv
│ ACT-MASTER-07│ P1 High      │ Sửa Precision Drift YTM/Coupon thành Decimal(8,5)         │ 01_create_gstt_flat_tables.sql
│ ACT-MASTER-08│ P1 High      │ Bổ sung hàm ép kiểu an toàn cho exercise_ratio trong DML  │ 02_populate_gstt_flat_tables.sql
│ ACT-MASTER-09│ P1 High      │ Sửa target_column: side_ind trong mapping YAML Atomic HNX │ mapping_atm_securities_order...yaml
│ ACT-MASTER-10│ P1 High      │ Điền đủ mart_table & mart_column cho Nhóm 5 & 6 Detail Mapping │ DTM_GSTT_Detail_Mapping.csv
│ ACT-MASTER-11│ P1 High      │ Đổi data_domain của idx_pe, idx_pb thành Ratio/Multiple   │ DTM_GSTT_fct_index_constituent_snpst.csv
│ ACT-MASTER-12│ P1 High      │ Bổ sung guard condition CASE WHEN > 0 cho P/E, P/B        │ DTM_GSTT_Detail_Mapping.csv
│ ACT-MASTER-13│ P1 High      │ Thống nhất tên cột trade_cdr_dt xuyên suốt cả 4 bảng Order/Trade │ 01_create_gstt_flat_tables.sql, DML
│ ACT-MASTER-14│ P1 High      │ Sửa lỗi cú pháp DATE_TRUNC trên trường String             │ DTM_GSTT_fct_foreign_trading_min_snpst.csv
│ ACT-MASTER-15│ P1 High      │ Sửa investor_category_code thành String NOT NULL Flat #6  │ 01_create_gstt_flat_tables.sql
│ ACT-MASTER-16│ P1 High      │ Bổ sung identity_type_cd = '4' khi join VSDC sang IDS     │ DTM_GSTT_fct_major_shareholder_*.csv
│ ACT-MASTER-17│ P1 High      │ Cập nhật baseline test oracles lên 48 nhóm, 348 KPI, 12 flat │ tests/test_gstt_integrity_oracles.py
│ ACT-MASTER-18│ P1 High      │ Cập nhật clean_fact_tables_count lên 12                   │ tests/test_datamart_date_fk_checker.py
│ ACT-MASTER-19│ P2 Medium    │ Đính chính các lỗi copy-paste và mã thị trường trong BA CSV│ BRD/BA/BA_analyst_GSTT.csv
│ ACT-MASTER-20│ P2 Medium    │ Bổ sung fallback mã ngành cấp 1 cho CTCK trong DML        │ 02_populate_gstt_flat_tables.sql
│ ACT-MASTER-21│ P2 Medium    │ Tách mã KPI riêng cho P/E BM021 thay vì dùng K_GSTT_58    │ DTM_GSTT_HLD.md, Detail Mapping
│ ACT-MASTER-22│ P2 Medium    │ Nâng cấp kiểu dữ liệu LLD CSV các cột khối lượng lên bigint│ DTM_GSTT_fct_*.csv
│ ACT-MASTER-23│ P2 Medium    │ Cập nhật tài liệu flat_table_mapping.md cho 12 bảng flat  │ Datamart/flat-table/flat_table_mapping.md
└──────────────┴──────────────┴───────────────────────────────────────────────────────────┴──────────────┘
```

---

### 6.2. Phân Công Trách Nhiệm Theo Từng Vai Trò Chuyên Môn

#### 1. Vai trò Data Modeler (Chịu trách nhiệm Mô hình & Logic):
1. **[P0] ACT-DM-01:** Mở tệp `Datamart/lld/DTM_GSTT_Detail_Mapping.csv`:
   - Dòng 694, 695, 699, 700 (Nhóm 39) và Dòng 440–443 (Nhóm 24): Xóa bỏ `* 100` trong biểu thức `price_change / reference_price * 100` để sửa dứt điểm lỗi phóng đại 100 lần điểm đóng góp chỉ số.
   - Dòng 273–275, 310–312: Sửa khung cửa sổ Top Vượt đỉnh/Thủng đáy thành `ROWS BETWEEN 259 PRECEDING AND 1 PRECEDING`.
   - Dòng 127, 169, 203, 237, 277, 314, 350, 610: Bổ sung guard condition `CASE WHEN PAT_TTM > 0 THEN ... ELSE NULL END` cho P/E và P/B.
   - Dòng 96–103 (Nhóm 5): Đổi `mart_table` sang `Fact Index Constituent Snapshot`, điền đủ tên cột cho `K_GSTT_47–52, 54`.
   - Dòng 115 (Nhóm 6): Điền `mart_table = Fact Index Constituent Snapshot`, `mart_column = Index Market Cap`, `role = MEASURE`.
2. **[P0] ACT-DM-02:** Mở tệp `Datamart/lld/GSTT/DTM_GSTT_fct_market_index_intraday.csv`, Dòng 6:
   - Sửa công thức `total_val_at_time` bổ sung `market_index_snapshot.trading_dt` vào `PARTITION BY` và bọc `COALESCE(..., total_val)`.
3. **[P0] ACT-DM-03:** Mở `DTM_GSTT_fct_investor_category_trading_snpst.csv` (dòng 5, 7) và `DTM_GSTT_fct_investor_category_index_trading_snpst.csv` (dòng 5, 7):
   - Thay thế biểu thức `(TC) - (Tự doanh)` bằng Cây quyết định phân loại độc lập phân vùng 4 nhánh, triệt tiêu 100% rủi ro âm giá trị mua/bán.
4. **[P1] ACT-DM-04:** Mở `DTM_GSTT_fct_foreign_trading_min_snpst.csv`, Dòng 4:
   - Sửa `DATE_TRUNC('minute', trade_time)` thành biểu thức ép kiểu Timestamp chuẩn.
5. **[P1] ACT-DM-05:** Mở `DTM_GSTT_fct_major_shareholder_ownership_snpst.csv`, Dòng 10:
   - Thêm `AND ip_alternative_identification.identity_type_cd = '4'` vào mệnh đề JOIN sang IDS.
6. **[P1] ACT-DM-06:** Mở `DTM_GSTT_fct_index_constituent_snpst.csv`, Dòng 14, 15:
   - Đổi `data_domain` của `idx_pe` và `idx_pb` từ `Percentage` sang `Ratio`.

#### 2. Vai trò ClickHouse DBA / Data Engineer (Chịu trách nhiệm Schema & SQL):
1. **[P0] ACT-DBA-01:** Mở `Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql`:
   - Bảng #9 (dòng 490) và Bảng #12 (dòng 665): **Xóa bỏ hoàn toàn** các cột mã PIN `buy_account_pin_code`, `sell_account_pin_code`, `account_pin_code` để bảo vệ bí mật khách hàng theo NĐ 13.
   - Bảng #9 (dòng 524) và Bảng #10 (dòng 582): Sửa khóa `ORDER BY` thành:
     `ORDER BY (assumeNotNull(trade_cdr_dt), security_symbol_code, securities_trade_code)`.
   - Bảng #1 (dòng 124, 125): Sửa kiểu dữ liệu `coupon_rate` và `yield` từ `Nullable(Decimal(7,4))` thành `Nullable(Decimal(8,5))` để chống Precision Drift.
   - Bảng #4 (dòng 299): Bọc `assumeNotNull(trading_tms)` hoặc đổi thành `NOT NULL`.
   - Bảng #6 (dòng 357): Đổi `investor_category_code Nullable(String)` thành `String NOT NULL`.
   - Bảng #11 và #12: Đổi tên cột ngày phân vùng từ `cdr_dt` thành `trade_cdr_dt` để đồng bộ toàn domain.
2. **[P0] ACT-DBA-02:** Mở `Datamart/flat-table/GSTT/02_populate_gstt_flat_tables.sql`:
   - Xóa bỏ các trường PIN tương ứng trong câu lệnh SELECT để giữ nguyên 0 column drift với DDL.
   - Bảng #1 (dòng 118, 121): Bổ sung hàm ép kiểu an toàn: `toDecimal64OrNull(splitByChar(':', sec_dim.exercise_ratio)[1], 2)` và `toDecimal64OrNull(sec_dim.contract_multiplier, 2)`.
   - Bảng #1 (dòng 140): Bổ sung fallback mã ngành cấp 1 cho CTCK:
     `COALESCE(pc_dim.business_line_level_1_code, CASE WHEN sc_dim.securities_company_dim_id IS NOT NULL THEN 'K' END)`.
3. **[P1] ACT-DBA-03:** Mở `Mapping/atomic/communication/mapping_atm_securities_order-ORDERTRADE.ORDER_BOOK_HNX.yaml`, Dòng 77:
   - Sửa `target_column: side_indicator` thành `target_column: side_ind`.

#### 3. Vai trò Business Analyst (BA Team):
1. **[P1] ACT-BA-01:** Mở tệp `BRD/BA/BA_analyst_GSTT.csv`:
   - Dòng 791 (STT 47): Sửa lỗi chính tả `Sàn phẩm phái sinh` thành `Sản phẩm phái sinh`; xóa câu lệnh SQL phân ngành IDS bị dán nhầm.
   - Dòng 621–622 (STT 41) & Dòng 633, 801 (STT 42, 47): Đổi mã thị trường `STK, STX, UPX` thành `BDO, HCX` (Trái phiếu) và `DVX` (Phái sinh).
   - Dòng 802 (STT 48): Sửa câu lệnh SQL tham khảo từ `STOCKTYPE <> '1'` thành `STOCKTYPE = '1'`.
   - Dòng 804 (STT 48): Bổ sung mã `BDO` vào danh sách thị trường trái phiếu.
   - Dòng 572 (STT 38): Đổi tên cột thành *"Tổng tỷ lệ sở hữu của các cổ đông lớn"*.
   - Dòng 113, 114, 149, 150, 219, 220, 247, 248, 279, 280, 309, 310: Sửa điều kiện thỏa thuận từ `NOT IN ('T1'-'T4', 'T6', 'R1')` thành `IN ('T1'-'T4', 'T6', 'R1')`.
   - Dòng 214 (STT 13): Cập nhật trạng thái mapping thành `Done`, mã KPI `K_GSTT_145`, kết quả `Pass`.
   - Dòng 444, 452, 461, 475: Sửa biến phía Bán thành `sell_invest_type = '8000'` và `<> '8000'`.
2. **[P2] ACT-BA-02:** Chuẩn hóa lại STT từ STT 28 trở đi trong file BA để triệt tiêu độ lệch 1-off index shift với HLD/LLD.

#### 4. Vai trò QA / Test Engineer:
1. **[P1] ACT-QA-01:** Mở `tests/test_gstt_integrity_oracles.py`:
   - Dòng 71 (`test_oracle_01`): Cập nhật kỳ vọng từ 42 nhóm lên **48 nhóm BA**.
   - Dòng 118 (`test_oracle_02`): Cập nhật kỳ vọng từ 262 KPI lên **348 KPI IDs**.
   - Dòng 224 (`test_oracle_03`): Cập nhật kỳ vọng từ 10 bảng flat (310 cột) lên **12 bảng flat (412 cột)**.
   - Dòng 443 (`test_oracle_07`): Cập nhật kỳ vọng số lần READY của `K_GSTT_2` từ 18 lên **19 lần READY**.
2. **[P1] ACT-QA-02:** Mở `tests/test_datamart_date_fk_checker.py`, Dòng 225:
   - Sửa `clean_fact_tables_count, 5` thành `clean_fact_tables_count, 12` để phản ánh đúng hiện trạng 12 Fact tables sạch của GSTT.
3. **[P1] ACT-QA-03:** Mở `tests/test_gstt_mutation_challenger.py`:
   - Cập nhật các assertion ngưỡng đếm đột biến theo baseline 48 nhóm và 348 KPI để bộ mutation test suite đạt 100% PASS.

---

## 7. PHƯƠNG PHÁP KIỂM CHỨNG ĐỘC LẬP (VERIFICATION METHODOLOGY)

Để một kiểm toán viên độc lập (Independent Forensic Auditor) có thể tái hiện và kiểm chứng khách quan toàn bộ các kết luận trong báo cáo này, thực hiện tuần tự các lệnh sau tại thư mục gốc `C:\Workspace\Design_DW\ubck_atomic_design`:

### 7.1. Kiểm chứng Tính Toàn vẹn 9 Quality Gates & Bảng Phẳng ClickHouse
```powershell
# 1. Chạy bộ kiểm định 9 Quality Gates chính thức của dự án
python .claude/skills/datamart-review/scripts/run_quality_gates.py --module GSTT

# 2. Kiểm chứng tính đối soát 1:1 giữa DDL và DML của 12 bảng phẳng
pytest tests/test_flat_table_checker.py -k "gstt" -v
```
*Kết quả kỳ vọng:* Gate 0 đến Gate 8 đều PASS; Flat table checker đạt 2 passed (0 column drift).

### 7.2. Kiểm chứng Lộ Lọt Mã PIN và PII Khách Hàng (LOG-D1-01)
```powershell
python -c "
with open('Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql', 'r', encoding='utf-8') as f:
    pin_cols = [line.strip() for line in f if 'pin' in line.lower()]
print('Số cột PIN nhạy cảm tìm thấy trong ClickHouse Flat Tables:', len(pin_cols))
for col in pin_cols: print('  ->', col)
"
```
*Kết quả xác nhận:* In ra 3 cột: `buy_account_pin_code` (line 490), `sell_account_pin_code` (line 506), `account_pin_code` (line 665).

### 7.3. Kiểm chứng Khóa ORDER BY Thiếu Mã CK Gây Nguy Cơ Mất Dữ Liệu (LOG-D1-02)
```powershell
python -c "
import re
with open('Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql', 'r', encoding='utf-8') as f:
    text = f.read()
matches = re.findall(r'ORDER BY\s*\((.*?)\)', text)
for i in [8, 9]:
    print(f'Table #{i+1} ORDER BY Key: {matches[i].strip()}')
"
```
*Kết quả xác nhận:* Bảng #9 và #10 chỉ có `(assumeNotNull(trade_cdr_dt), securities_trade_code)` — hoàn toàn thiếu `security_symbol_code`.

### 7.4. Kiểm chứng Lỗi Phóng Đại 100 Lần Điểm Đóng Góp Chỉ Số (LOG-D2-01)
```powershell
python -c "
import csv
with open('Datamart/lld/DTM_GSTT_Detail_Mapping.csv', mode='r', encoding='utf-8-sig') as f:
    reader = csv.reader(f)
    for r in reader:
        if r and r[0] in ['K_GSTT_75', 'K_GSTT_124'] and 'Nhóm 39' in r[2]:
            print(f'KPI {r[0]}: Logic = {r[9][:120]}...')
"
```
*Kết quả xác nhận:* Logic chứa biểu thức `(security_trading_snpst_dim.price_change / security_trading_snpst_dim.reference_price * 100)` gây phóng đại kết quả lên 100 lần.

### 7.5. Kiểm chứng Lỗi Window Function Top Vượt Đỉnh / Thủng Đáy (LOG-D3-01)
```powershell
python -c "
with open('Datamart/hld/DTM_GSTT_HLD.md', 'r', encoding='utf-8') as f:
    text = f.read()
import re
peaks = re.findall(r'K_GSTT_106.*?ROWS BETWEEN.*?CURRENT ROW', text)
print('Số lượng công thức Đỉnh cũ nuốt chửng CURRENT ROW:', len(peaks))
for p in peaks[:2]: print('  ->', p)
"
```
*Kết quả xác nhận:* Tìm thấy mệnh đề `ROWS BETWEEN 259 PRECEDING AND CURRENT ROW`, chứng minh lỗi tự nuốt chửng giá hôm nay.

### 7.6. Kiểm chứng Lỗi LAG Intraday Thiếu Partition Ngày (LOG-D2-02)
```powershell
python -c "
import csv
with open('Datamart/lld/GSTT/DTM_GSTT_fct_market_index_intraday.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for r in reader:
        if r['datamart_column'] == 'total_val_at_time':
            print('ETL Logic total_val_at_time:', r['etl_logic'])
"
```
*Kết quả xác nhận:* In ra `market_index_snapshot.total_val - LAG(market_index_snapshot.total_val) OVER (PARTITION BY market_index_snapshot.market_code ORDER BY market_index_snapshot.index_time)` (thiếu `trading_dt` và thiếu `COALESCE`).

### 7.7. Kiểm chứng Lỗi Thoái Hóa Của Bộ Kiểm Thử Hồi Quy Độc Lập
```powershell
# Chạy bộ test oracle độc lập để quan sát 4 lỗi thất bại do hằng số cũ
pytest tests/test_gstt_integrity_oracles.py

# Chạy bộ test kiểm tra Date FK để quan sát lỗi AssertionError 12 != 5
pytest tests/test_datamart_date_fk_checker.py -k "gstt"
```
*Kết quả xác nhận:* 4 test FAIL tại `test_gstt_integrity_oracles.py` (sai lệch 42 vs 48, 262 vs 348, 10 vs 12) và 1 test FAIL tại `test_datamart_date_fk_checker.py`.

---

## 8. LỜI KẾT & KIẾN NGHỊ NGHIỆM THU

Phân hệ Giám sát Thị trường (GSTT) là phân hệ trung tâm và có độ phức tạp cao nhất trong toàn bộ kiến trúc Kho dữ liệu UBCKNN. Đội ngũ Data Modeler đã đạt được thành tựu xuất sắc trong việc xây dựng mô hình dữ liệu đa chiều bao phủ 48 màn hình nghiệp vụ, giải quyết triệt để vấn đề fan-out rổ chỉ số bằng Bridge Table và đạt chuẩn 100% cột vật lý giữa DDL và DML ClickHouse.

Tuy nhiên, với sự hiện diện của **6 lỗi nghiêm trọng cấp P0** (đặc biệt là nguy cơ mất mát dữ liệu do khóa gộp ReplacingMergeTree, lộ lọt mã PIN tài khoản khách hàng, lỗi phóng đại 100 lần điểm chỉ số và lỗi hàm tính thanh khoản Intraday), **hội đồng thẩm định độc lập đưa ra phán quyết kiên quyết: `REQUEST_CHANGES`**. 

Toàn bộ các đề xuất sửa đổi trong Báo cáo này đã được cụ thể hóa đến từng dòng mã nguồn và từng công thức SQL. Sau khi các nhóm chuyên môn (Data Modeler, ClickHouse DBA, BA Team, QA) hoàn tất việc khắc phục theo Danh mục Hành động tại Mục 6, phân hệ GSTT sẽ sẵn sàng bước vào đợt phúc tra cuối cùng để chính thức cấp chứng chỉ nghiệm thu Golive.

---
*Báo cáo được hoàn thành và phê duyệt bởi: Ban Thẩm định Kỹ thuật Dự án Data Warehouse UBCKNN.*
