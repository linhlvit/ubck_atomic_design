# Entities — Datamart TKNB (Thống kê nội bộ)

## Ghi chú thiết kế

Toàn bộ 21 bảng là `operational` (bảng phẳng theo từng báo cáo — EAV `item_code` hoặc danh sách) — module TKNB không có Fact Star Schema, không tách Dimension dùng chung (theo quyết định thiết kế ghi ở đầu `DTM_TKNB_HLD.md`, Section 3.2/3.4 đều ghi "Không có"). Không có FK/relationship giữa các bảng — mỗi bảng độc lập hoàn toàn theo layout báo cáo gốc, nên **không vẽ erDiagram** (không có đường quan hệ nào để thể hiện).

## Bảng entity tóm tắt (21 bảng, sắp theo thứ tự Nhóm trong HLD)

| STT | Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|---|
| 1 | Stock Trading Report (HNX01) | Operational | new | Báo cáo giao dịch thị trường cổ phiếu HNX theo kỳ | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo | K_TKNB_1–108 |
| 3 | Derivative Trading Report (HNX03) | Operational | new | Báo cáo giao dịch thị trường CKPS (HNX) theo kỳ | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo | K_TKNB_274–286 |
| 4 | Market Scale Report (HNX04) | Operational | new | Báo cáo tổng hợp quy mô TTCK HNX | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo/1 period_type | K_TKNB_290–471 |
| 6 | Corp Bond Trading Report (HNX07) | Operational | new | Báo cáo giao dịch TPDN niêm yết trên HNX theo kỳ | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo | K_TKNB_497–519 |
| 10 | Stock Trading Report (HSX01) | Operational | new | Báo cáo giao dịch thị trường cổ phiếu HOSE theo kỳ | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo | K_TKNB_571–695 |
| 11 | Listing Trading Report (HSX02) | Operational | new | Báo cáo niêm yết và giao dịch chứng khoán HOSE kỳ tháng | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo/1 period_type | K_TKNB_696–792 |
| 12 | Proprietary Trading Report (HSX04) | Operational | new | Báo cáo giao dịch tự doanh của CTCK trên HOSE theo kỳ | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo | K_TKNB_793–820 |
| 14 | CW Outstanding Report (TTLK10) | Operational | new | Danh sách chứng quyền đang lưu hành | 1 dòng/1 mã chứng quyền/1 kỳ báo cáo | K_TKNB_843–845 |
| 15 | Offering Result Report (0513.H.UBCK.QG) | Operational | new | Báo cáo kết quả thực hiện phát hành chứng khoán | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo | K_TKNB_846–874 |
| 16 | Market Summary Report (TK-04.BTC) | Operational | new | Báo cáo tổng hợp TTCK theo quý/lũy kế | 1 dòng/1 chỉ tiêu/1 kỳ gốc (period_marker) | K_TKNB_875–917 |
| 17 | Market Annual Report (TK_NienGiam) | Operational | new | Niên giám thống kê thị trường chứng khoán theo năm | 1 dòng/1 chỉ tiêu/1 năm báo cáo | K_TKNB_918–1011 |
| 18 | Market Trading Report (BM030a) | Operational | new | Thống kê giao dịch toàn thị trường cổ phiếu theo ngày (cộng gộp HOSE+HNX+UPCoM) | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo | K_TKNB_1012–1022 |
| 20 | Corp Bond Trading Report (BM030c) | Operational | new | Thống kê giao dịch toàn thị trường TPDN niêm yết theo ngày (cộng gộp 2 sàn) | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo | K_TKNB_1037–1045 |
| 22 | Fund Cert ETF CW Trading Report (BM030e) | Operational | new | Thống kê giao dịch thị trường CCQ/ETF/CW toàn thị trường theo ngày | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo | K_TKNB_1053–1067 |
| 23 | Foreign Proprietary Trading Report (BM031a) | Operational | new | Giao dịch NĐTNN/tự doanh thị trường cổ phiếu theo ngày, breakdown theo chỉ số | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo | K_TKNB_1068–1093 |
| 24 | Gov Bond Foreign Proprietary Trading Report (BM031b) | Operational | new | Giao dịch NĐTNN/tự doanh thị trường TPCP theo ngày | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo | K_TKNB_1094–1112 |
| 25 | Corp Bond Foreign Proprietary Trading Report (BM031c) | Operational | new | Giao dịch NĐTNN/tự doanh thị trường TPDN niêm yết theo ngày | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo | K_TKNB_1113–1122 |
| 26 | Fund Cert ETF CW Foreign Proprietary Trading Report (BM031d) | Operational | new | Giao dịch NĐTNN/tự doanh thị trường CCQ/ETF/CW theo ngày | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo | K_TKNB_1123–1173 |
| 27 | Derivatives Foreign Proprietary Trading Report (BM031f) | Operational | new | Thống kê giao dịch thị trường CKPS (NĐTNN/tự doanh) theo ngày | 1 dòng/1 chỉ tiêu/1 kỳ báo cáo | K_TKNB_1174–1186 |
| 28 | Security Trading Detail Report (BM035) | Operational | new | Thống kê giao dịch chi tiết theo TỪNG MÃ chứng khoán theo ngày | 1 dòng/1 chỉ tiêu/1 mã CK/1 kỳ báo cáo | K_TKNB_1187–1239 |
| 29 | Derivatives Security Detail Report (BM043) | Operational | new | Thị trường CKPS chi tiết theo từng mã hợp đồng theo ngày | 1 dòng/1 chỉ tiêu/1 mã CK/1 kỳ báo cáo | K_TKNB_1240–1255 |

## Nguồn Atomic theo bảng

| Datamart Entity | source_table (Atomic physical_name) |
|---|---|
| Stock Trading Report (HNX01) | market_index_snapshot / security_trading_snapshot / securities_trade |
| Derivative Trading Report (HNX03) | security_trading_snapshot / securities_trade |
| Market Scale Report (HNX04) | securities_trade / security_trading_snapshot |
| Corp Bond Trading Report (HNX07) | securities_trade |
| Stock Trading Report (HSX01) | market_index_snapshot / securities_trade / security_trading_snapshot |
| Listing Trading Report (HSX02) | market_index_snapshot / securities_trade / security_trading_snapshot |
| Proprietary Trading Report (HSX04) | securities_trade / security_trading_snapshot |
| CW Outstanding Report (TTLK10) | sc_disclosure_securities_offering |
| Offering Result Report (0513.H.UBCK.QG) | pc_securities_offering_result |
| Market Summary Report (TK-04.BTC) | securities_trade |
| Market Annual Report (TK_NienGiam) | market_index_snapshot / securities_trade / security_trading_snapshot / public_company / securities_company / fund_management_company |
| Market Trading Report (BM030a) | market_index_snapshot / securities_trade |
| Corp Bond Trading Report (BM030c) | securities_trade |
| Fund Cert ETF CW Trading Report (BM030e) | securities_trade / security_trading_snapshot |
| Foreign Proprietary Trading Report (BM031a) | securities_trade / index_constituent_snapshot / market_index_snapshot |
| Gov Bond Foreign Proprietary Trading Report (BM031b) | securities_trade |
| Corp Bond Foreign Proprietary Trading Report (BM031c) | securities_trade |
| Fund Cert ETF CW Foreign Proprietary Trading Report (BM031d) | securities_trade / security_trading_snapshot |
| Derivatives Foreign Proprietary Trading Report (BM031f) | securities_trade / security_trading_snapshot |
| Security Trading Detail Report (BM035) | securities_trade / security_trading_snapshot |
| Derivatives Security Detail Report (BM043) | securities_trade / security_trading_snapshot |
