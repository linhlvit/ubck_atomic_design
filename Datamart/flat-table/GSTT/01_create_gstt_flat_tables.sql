-- ============================================================
-- GSTT Flat Tables — CREATE
-- Module: Giám sát Thị trường (GSTT)
-- Generated: Phase 3 LLD Datamart
-- Sửa 2026-10-22: #18 gstt_opr_trading_liquidity_explorer_flat — phạm vi sổ lệnh thêm Market ID DVX (phái sinh), HCX (TPDN riêng lẻ) theo BA Nhóm 38 mới (= Nhóm 37 cũ); không đổi cột (O_GSTT_77)
-- Sửa 2026-10-19: #18 gstt_opr_trading_liquidity_explorer_flat bổ sung cột index_nm (tên chỉ số, đặt cuối bảng — ALTER TABLE ... ADD COLUMN index_nm Nullable(String))
-- Sửa 2026-10-16: bổ sung bảng #18 gstt_opr_trading_liquidity_explorer_flat (Fact phẳng Data Explorer Nhóm 37 — O_GSTT_72)
-- 12 bảng: 9 fact + 3 operational (opr_security_ref — mới 2026-10-09, danh mục mã chứng khoán tách từ opr_security_index_constituent_ref; opr_security_index_constituent_ref — mới 2026-10-06, danh mục chỉ số/thành viên rổ Index Code ↔ Symbol ↔ ISIN; opr_public_company_insider_ownership — mới 2026-10-01, Nhóm 35; opr_public_company_shareholding đã bãi bỏ 2026-09-25)
-- Sửa 2026-10-06 (v4.33–v4.36): Nhóm 34 — #3 gstt_fct_instrument_price_intraday_flat (nến phút) và #3a gstt_fct_instrument_price_daily_flat (nến ngày + Doanh thu/LNST) thay gstt_fct_security_trading_intraday_flat; mã CK và chỉ số (BA nguồn JAD_tvhistory1m/1d), dùng chung Nhóm 3, 10, 12, 14, 20, 47 (v4.35); #3b gstt_fct_security_trading_daily_flat chỉ còn Nhóm 48 (K_GSTT_352).
-- Sửa 2026-09-26: bổ sung bảng #7/#8 (Fact HOSE/HNX Securities Trade — Nhóm 43/44 Data Explorer kết xuất sổ lệnh, có cột PII — O_GSTT_36)
-- Sửa 2026-09-23: bổ sung bảng #5b (Fact Investor Category Index Trading Snapshot, Nhóm 30/33 —
-- grain Index Code × ngày × Phân loại NĐT); đánh số lại tham chiếu Nhóm theo BA 37 Nhóm (PTKT → 32, Sở hữu → 33 … Data Explorer → 35/36/37).
-- Sửa 2026-09-14: bổ sung bảng #1b (Fact Index Constituent Snapshot, Bridge Factless) —
-- tách khỏi Fact Stock Portfolio Snapshot để hết fan-out theo rổ chỉ số (xem HLD v4.13)
-- (Fact Market Index Snapshot dùng chung QLKD — flat table đã có ở QLKD, không CREATE lại)
-- Sửa 2026-08-03: bảng cũ (Fact Public Company Shareholding) đã bị loại bỏ —
-- xem ghi chú chi tiết cuối file
-- Sửa 2026-08-26: bổ sung bảng #3 (Fact Security Trading Intraday, Nhóm 45 —
-- Biểu đồ phân tích kỹ thuật, K_GSTT_95-99 chuyển PENDING → READY)
-- Sửa 2026-09-11: bổ sung bảng #4 (Fact Foreign Trading Minute Snapshot, Nhóm 25 —
-- K_GSTT_78-80, Resolved 2026-09-04/O_GSTT_8 nhưng bị bỏ sót khỏi Phase 3 tới nay;
-- phát hiện qua rà soát sau khi sửa join-key sổ lệnh↔MDDS/filter thỏa thuận)
-- Sửa 2026-09-12: bổ sung bảng #5 (Operational Public Company Shareholding, Nhóm 35/38 —
-- đảo ngược O_GSTT_9, thay thế hoàn toàn ghi chú "không có bảng flat" cũ bên dưới)
-- ============================================================


-- ============================================================
-- 1. FACT: gstt_fct_stock_portfolio_snpst_flat
--    Danh mục chứng khoán tổng hợp — 1 row / mã CK / rổ chỉ số (FK nullable) / ngày giao dịch
--    Grain: Periodic Snapshot theo ngày (transaction log — mỗi ngày phiên phát sinh
--    đồng bộ dữ liệu cho toàn bộ mã CK giao dịch)
--    Joins: Calendar Date (snpst_dt_dim_id JOIN) × Security Trading Snapshot Dimension ×
--           Public Company Dimension
--    [SỬA 2026-09-14] Không còn join Index Constituent Dimension — tách sang
--    gstt_fct_index_constituent_snpst_flat riêng (Bridge, xem bảng #1b bên dưới)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_stock_portfolio_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Stock Portfolio Snapshot
    security_trading_snpst_dim_id       String                  COMMENT 'FK → Security Trading Snapshot Dimension',
    public_company_dim_id               String                  COMMENT 'FK → Public Company Dimension',
    securities_company_dim_id           String                  COMMENT '[MỚI 2026-09-28] FK → Securities Company Dimension (cờ CTCK đại chúng; khi Public Company Dimension Id rỗng, Ngành fallback = ngành IDS mã 07000 tra từ Industry Dimension — SỬA 2026-10-07, xem O_GSTT_37)',
    snpst_dt_dim_id                       String                  COMMENT 'FK → Calendar Date Dimension',
    fr_period_end_dt_dim_id             Nullable(String)        COMMENT 'FK → Calendar Date Dimension (Role-Playing: Financial Report Period End Date) — bổ sung 2026-09-08 theo rule GSĐC',
    total_vol                           Nullable(Int64)         COMMENT '[SỬA COMMENT 2026-09-16, không đổi giá trị/ETL] Tổng khối lượng giao dịch cổ phiếu/CCQ 3 sàn — GỘP CẢ khớp lệnh VÀ thỏa thuận, loại trừ phái sinh và trái phiếu. Comment cũ ghi nhầm "khớp lệnh" — phục vụ K_GSTT_146 (Nhóm 37), không phải K_GSTT_13 (đã chuyển sang total_matched_vol)',
    total_val                           Nullable(Decimal(23,2)) COMMENT '[SỬA COMMENT 2026-09-16, không đổi giá trị/ETL] Tổng giá trị giao dịch cổ phiếu/CCQ 3 sàn — GỘP CẢ khớp lệnh VÀ thỏa thuận, loại trừ phái sinh và trái phiếu. Comment cũ ghi nhầm "khớp lệnh" — phục vụ K_GSTT_147 (Nhóm 37), không phải K_GSTT_14 (đã chuyển sang total_matched_val)',
    total_matched_vol                   Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch khớp lệnh thuần (loại trừ thỏa thuận) cổ phiếu/CCQ 3 sàn, loại trừ phái sinh và trái phiếu. [CẬP NHẬT 2026-09-16] Nay là nguồn của K_GSTT_13 (Nhóm 1 và các Nhóm reuse 3/9/10/23/24/29/30)',
    total_matched_val                   Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch khớp lệnh thuần (loại trừ thỏa thuận) cổ phiếu/CCQ 3 sàn, loại trừ phái sinh và trái phiếu. [CẬP NHẬT 2026-09-16] Nay là nguồn của K_GSTT_14 (Nhóm 1 và các Nhóm reuse 3/9/10/23/24/29/30)',
    total_derivative_vol                Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch phái sinh',
    total_derivative_negotiated_vol     Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch thỏa thuận phái sinh (Market ID = DVX, bảng thỏa thuận T1–T4/T6/R1).',

    total_derivative_val                Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch phái sinh',
    total_derivative_negotiated_val     Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch thỏa thuận phái sinh (Market ID = DVX, bảng thỏa thuận T1–T4/T6/R1).',
    total_negotiated_vol                Nullable(Int64)         COMMENT '[SỬA FILTER 2026-09-11] Tổng khối lượng giao dịch thỏa thuận — filter Market Id Code IN (UPX,STX,STK,STO) AND Board Type Code IN (T1-T4,T6,R1), đóng O_GSTT_20',
    total_negotiated_val                Nullable(Decimal(23,2)) COMMENT '[SỬA FILTER 2026-09-11] Tổng giá trị giao dịch thỏa thuận — filter Market Id Code IN (UPX,STX,STK,STO) AND Board Type Code IN (T1-T4,T6,R1), đóng O_GSTT_20',
    foreign_net_vol                     Nullable(Int64)         COMMENT 'Khối lượng mua ròng của nhà đầu tư nước ngoài',
    foreign_net_derivative_vol          Nullable(Int64)         COMMENT '[MỚI 2026-09-17] Khối lượng mua ròng của NĐT nước ngoài trên thị trường phái sinh (Market ID = DVX, khớp lệnh). K_GSTT_148, bổ sung KPI thiếu phát hiện qua rà soát BA↔KPI toàn diện',
    outstanding_share_quantity          Nullable(Int64)         COMMENT 'Số cổ phiếu đang lưu hành — nguồn VSDC listed_share_info (outstanding_shares), bản ghi gần nhất <= ngày GD (lookback, sửa 2026-09-16)',
    revenue                             Nullable(Decimal(23,2)) COMMENT 'Doanh thu — point-in-time theo Ky_bao_cao (rule GSĐC, cập nhật 2026-09-08)',
    net_profit_after_tax                Nullable(Decimal(23,2)) COMMENT 'Lợi nhuận sau thuế — point-in-time theo Ky_bao_cao (rule GSĐC, cập nhật 2026-09-08)',
    net_profit_after_tax_ttm            Nullable(Decimal(23,2)) COMMENT 'LNST TTM 4 quý gần nhất có ngay_ket_thuc <= ngày GD, NULL nếu không đủ 4 kỳ — dùng cho P/E, EPS (rule GSĐC, cập nhật 2026-09-08)',
    owner_equity                        Nullable(Decimal(23,2)) COMMENT 'Vốn chủ sở hữu — quý gần nhất đã công bố có ngay_ket_thuc <= ngày GD (rule GSĐC, cập nhật 2026-09-08)',
    weighted_average_outstanding_share_quantity Nullable(Decimal(23,4)) COMMENT '[MỚI 2026-09-29, sửa Nhóm 36] Số CP lưu hành bình quân gia quyền theo số ngày hiệu lực VSDC (WAOS), khung ngày của kỳ BCTC LNST gần nhất — dùng cho K_GSTT_109/110',
    weighted_average_outstanding_share_quantity_ttm Nullable(Decimal(23,4)) COMMENT '[MỚI 2026-09-29, sửa Nhóm 36] WAOS khung MIN/MAX ngày của 4 kỳ LNST TTM — dùng cho K_GSTT_111/58',
    owner_equity_weighted_average_outstanding_share_quantity Nullable(Decimal(23,4)) COMMENT '[MỚI 2026-09-29, sửa Nhóm 36] WAOS khung ngày của kỳ BCTC VCSH gần nhất (kỳ riêng, độc lập với kỳ LNST) — dùng cho K_GSTT_112',
    owner_equity_weighted_average_outstanding_share_quantity_ttm Nullable(Decimal(23,4)) COMMENT '[MỚI 2026-09-29, sửa Nhóm 36] WAOS khung MIN/MAX ngày của 4 kỳ VCSH — dùng cho K_GSTT_113/59',
    owner_equity_average_4_quarter      Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-29, sửa Nhóm 36 — đảo ngược quyết định 2026-09-04] VCSH bình quân cộng của 4 kỳ BCTC gần nhất (trung bình 4 giá trị rời rạc theo từng quý), NULL nếu thiếu kỳ — dùng cho K_GSTT_113/59',
    foreign_buy_derivative_vol                   Nullable(Int64)         COMMENT '[MỚI 2026-10-15 v4.49, BA STT 1 dòng 26 Tổng KLNN mua của phái sinh (K_GSTT_374)] Khối lượng mua của nhà đầu tư nước ngoài trên thị trường phái sinh (Market ID = DVX, khớp lệnh — Board Type NOT IN (T1,T2,T3,T4,T6,R1); thị trường phái sinh có bảng thỏa thuận riêng, xác nhận 2026-10-15). Nước ngoài = ký tự thứ 4 của số tài khoản mua IN (F,E) — xem O_GSTT_66.',
    foreign_sell_derivative_vol                  Nullable(Int64)         COMMENT '[MỚI 2026-10-15 v4.49, BA STT 1 dòng 27 Tổng KLNN bán của phái sinh (K_GSTT_375)] Khối lượng bán của nhà đầu tư nước ngoài trên thị trường phái sinh (Market ID = DVX, khớp lệnh — Board Type NOT IN (T1,T2,T3,T4,T6,R1); thị trường phái sinh có bảng thỏa thuận riêng, xác nhận 2026-10-15). Nước ngoài = ký tự thứ 4 của số tài khoản bán IN (F,E) — xem O_GSTT_66.',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-10-15, BA bổ sung P/E của CTCK] LNST 4 quý gần nhất của CÔNG TY CHỨNG KHOÁN đại chúng (không có trong IDS) lấy từ BCTC nộp qua SCMS: BCTCHN (hợp nhất) ô TS121 (sheet BCKQHDHN_06622, dòng XI. LỢI NHUẬN KẾ TOÁN SAU THUẾ TNDN, cột Năm nay); BCTCRL (riêng lẻ) ô TS119 (sheet BCKQHDR_06610) chỉ khi CTCK không nộp BCTCHN cùng kỳ. Chỉ có giá trị khi đủ ĐÚNG 4 kỳ quý (RECORD_STATUS 1/2), NULL nếu thiếu — cùng quy tắc `Net Profit After Tax TTM` của doanh nghiệp IDS. Dùng làm phương án dự phòng COALESCE trong K_GSTT_58 (P/E) — KHÔNG thay `net_profit_after_tax_ttm` để không lệch khung kỳ WAOS của EPS/K_GSTT_111. Khác SQL BA (ghi ở O_GSTT_70): (1) BA lọc `SECURITIES_CODE IN (BVS,MBS,SHS,VFS)` — coi là bộ lọc thử, thiết kế áp cho MỌI CTCK đại chúng (cùng điều kiện `pc_ind = 1`, không tạm/dự thảo như `securities_company_dim_id` / K_GSTT_2); (2) BA chọn 1 quý gần nhất chung cho cả nhóm CTCK (`LIMIT 1`), thiết kế chọn quý gần nhất RIÊNG từng CTCK (CTCK nộp trễ vẫn có số kỳ trước — cùng nguyên tắc dữ liệu IDS); (3) `cell_id` không duy nhất giữa các sheet (O_QLKD_34, O_PTTT_28) và Atomic chưa có mã sheet — chấp nhận TS121/TS119/TS359/TS223/TS221 theo biểu mẫu BCTCHN/BCTCRL; (4) điều kiện kỳ theo `sc_periodic_report.end_dt <= ngày giao dịch` đúng SQL BA (khác IDS dùng `submission_dt`). Đơn vị VNĐ (BA chia 1e9 chỉ để hiển thị tỷ).',
    securities_company_owner_equity              Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-10-15, BA bổ sung P/B của CTCK] VCSH của CÔNG TY CHỨNG KHOÁN đại chúng (không có trong IDS) tại kỳ quý gần nhất đã có báo cáo SCMS tính đến ngày giao dịch: BCTCHN ô TS359 (sheet BCTCH_06620, dòng VỐN CHỦ SỞ HỮU (400 = 410 + 420), cột Số cuối năm); BCTCRL: COALESCE(NULLIF(TS223, 0), TS221) (sheet BCTCR_06608, D. VỐN CHỦ SỞ HỮU hoặc dòng (400 = 410 + 420)) chỉ khi CTCK không nộp BCTCHN cùng kỳ. Dùng làm phương án dự phòng COALESCE trong K_GSTT_59 (P/B) — KHÔNG thay `owner_equity` (K_GSTT_57). Khác SQL BA (ghi ở O_GSTT_70): (1) BA lọc `SECURITIES_CODE IN (BVS,MBS,SHS,VFS)` — coi là bộ lọc thử, thiết kế áp cho MỌI CTCK đại chúng (cùng điều kiện `pc_ind = 1`, không tạm/dự thảo như `securities_company_dim_id` / K_GSTT_2); (2) BA chọn 1 quý gần nhất chung cho cả nhóm CTCK (`LIMIT 1`), thiết kế chọn quý gần nhất RIÊNG từng CTCK (CTCK nộp trễ vẫn có số kỳ trước — cùng nguyên tắc dữ liệu IDS); (3) `cell_id` không duy nhất giữa các sheet (O_QLKD_34, O_PTTT_28) và Atomic chưa có mã sheet — chấp nhận TS121/TS119/TS359/TS223/TS221 theo biểu mẫu BCTCHN/BCTCRL; (4) điều kiện kỳ theo `sc_periodic_report.end_dt <= ngày giao dịch` đúng SQL BA (khác IDS dùng `submission_dt`). Đơn vị VNĐ (BA chia 1e9 chỉ để hiển thị tỷ).',
    round_lot_matched_vol                        Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch khớp lệnh lô chẵn cổ phiếu/CCQ 3 sàn (Market ID UPX/STX/STK/STO) — bảng khớp lệnh lô chẵn G1/G2/G3/G6/G7/G8; cùng grain mã CK × ngày với total_matched_vol. [MỚI 2026-10-30 v4.58] BA dòng 27–34 (Tổng KLGD khớp lệnh lô chẵn); xem O_GSTT_78',
    round_lot_matched_val                        Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch khớp lệnh lô chẵn cổ phiếu/CCQ 3 sàn (Market ID UPX/STX/STK/STO) — bảng khớp lệnh lô chẵn G1/G2/G3/G6/G7/G8; cùng grain mã CK × ngày với total_matched_val. [MỚI 2026-10-30 v4.58] BA dòng 27–34 (Tổng GTGD khớp lệnh lô chẵn); xem O_GSTT_78',
    round_lot_negotiated_vol                     Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch thỏa thuận lô chẵn cổ phiếu/CCQ 3 sàn (Market ID UPX/STX/STK/STO) — bảng thỏa thuận lô chẵn T1/T2/T3/T6/R1; cùng grain mã CK × ngày với total_negotiated_vol. [MỚI 2026-10-30 v4.58] BA dòng 27–34 (Tổng KLGD thỏa thuận lô chẵn); xem O_GSTT_78',
    round_lot_negotiated_val                     Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch thỏa thuận lô chẵn cổ phiếu/CCQ 3 sàn (Market ID UPX/STX/STK/STO) — bảng thỏa thuận lô chẵn T1/T2/T3/T6/R1; cùng grain mã CK × ngày với total_negotiated_val. [MỚI 2026-10-30 v4.58] BA dòng 27–34 (Tổng GTGD thỏa thuận lô chẵn); xem O_GSTT_78',
    odd_lot_matched_vol                          Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch khớp lệnh lô lẻ cổ phiếu/CCQ 3 sàn (Market ID UPX/STX/STK/STO) — bảng khớp lệnh lô lẻ G4; cùng grain mã CK × ngày với total_matched_vol. [MỚI 2026-10-30 v4.58] BA dòng 27–34 (Tổng KLGD khớp lệnh lô lẻ); xem O_GSTT_78',
    odd_lot_matched_val                          Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch khớp lệnh lô lẻ cổ phiếu/CCQ 3 sàn (Market ID UPX/STX/STK/STO) — bảng khớp lệnh lô lẻ G4; cùng grain mã CK × ngày với total_matched_val. [MỚI 2026-10-30 v4.58] BA dòng 27–34 (Tổng GTGD khớp lệnh lô lẻ); xem O_GSTT_78',
    odd_lot_negotiated_vol                       Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch thỏa thuận lô lẻ cổ phiếu/CCQ 3 sàn (Market ID UPX/STX/STK/STO) — bảng thỏa thuận lô lẻ T4; cùng grain mã CK × ngày với total_negotiated_vol. [MỚI 2026-10-30 v4.58] BA dòng 27–34 (Tổng KLGD thỏa thuận lô lẻ); xem O_GSTT_78',
    odd_lot_negotiated_val                       Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch thỏa thuận lô lẻ cổ phiếu/CCQ 3 sàn (Market ID UPX/STX/STK/STO) — bảng thỏa thuận lô lẻ T4; cùng grain mã CK × ngày với total_negotiated_val. [MỚI 2026-10-30 v4.58] BA dòng 27–34 (Tổng GTGD thỏa thuận lô lẻ); xem O_GSTT_78',
    derivative_round_lot_matched_vol             Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch khớp lệnh lô chẵn phái sinh (Market ID DVX) — bảng khớp lệnh lô chẵn G1/G2/G3/G6/G7/G8; cùng grain mã CK × ngày với total_matched_vol. [MỚI 2026-10-30 v4.58] BA dòng 40–47 (Tổng KLGD khớp lệnh lô chẵn phái sinh); xem O_GSTT_78',
    derivative_round_lot_matched_val             Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch khớp lệnh lô chẵn phái sinh (Market ID DVX) — bảng khớp lệnh lô chẵn G1/G2/G3/G6/G7/G8; cùng grain mã CK × ngày với total_matched_val. [MỚI 2026-10-30 v4.58] BA dòng 40–47 (Tổng GTGD khớp lệnh lô chẵn phái sinh); xem O_GSTT_78',
    derivative_round_lot_negotiated_vol          Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch thỏa thuận lô chẵn phái sinh (Market ID DVX) — bảng thỏa thuận lô chẵn T1/T2/T3/T6/R1; cùng grain mã CK × ngày với total_negotiated_vol. [MỚI 2026-10-30 v4.58] BA dòng 40–47 (Tổng KLGD thỏa thuận lô chẵn phái sinh); xem O_GSTT_78',
    derivative_round_lot_negotiated_val          Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch thỏa thuận lô chẵn phái sinh (Market ID DVX) — bảng thỏa thuận lô chẵn T1/T2/T3/T6/R1; cùng grain mã CK × ngày với total_negotiated_val. [MỚI 2026-10-30 v4.58] BA dòng 40–47 (Tổng GTGD thỏa thuận lô chẵn phái sinh); xem O_GSTT_78',
    derivative_odd_lot_matched_vol               Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch khớp lệnh lô lẻ phái sinh (Market ID DVX) — bảng khớp lệnh lô lẻ G4; cùng grain mã CK × ngày với total_matched_vol. [MỚI 2026-10-30 v4.58] BA dòng 40–47 (Tổng KLGD khớp lệnh lô lẻ phái sinh); xem O_GSTT_78',
    derivative_odd_lot_matched_val               Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch khớp lệnh lô lẻ phái sinh (Market ID DVX) — bảng khớp lệnh lô lẻ G4; cùng grain mã CK × ngày với total_matched_val. [MỚI 2026-10-30 v4.58] BA dòng 40–47 (Tổng GTGD khớp lệnh lô lẻ phái sinh); xem O_GSTT_78',
    derivative_odd_lot_negotiated_vol            Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch thỏa thuận lô lẻ phái sinh (Market ID DVX) — bảng thỏa thuận lô lẻ T4; cùng grain mã CK × ngày với total_negotiated_vol. [MỚI 2026-10-30 v4.58] BA dòng 40–47 (Tổng KLGD thỏa thuận lô lẻ phái sinh); xem O_GSTT_78',
    derivative_odd_lot_negotiated_val            Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch thỏa thuận lô lẻ phái sinh (Market ID DVX) — bảng thỏa thuận lô lẻ T4; cùng grain mã CK × ngày với total_negotiated_val. [MỚI 2026-10-30 v4.58] BA dòng 40–47 (Tổng GTGD thỏa thuận lô lẻ phái sinh); xem O_GSTT_78',
    open_interest_quantity                       Nullable(Int64)         COMMENT 'Khối lượng hợp đồng mở (OI) cuối ngày của mã phái sinh (VSDC — end_of_day_open_interest), chỉ có giá trị với mã phái sinh (stock_tp_code = 4, sàn 02/03/04); mã khác để NULL. [MỚI 2026-10-30 v4.58] BA Nhóm 1 dòng 20 `Khối lượng mở của phái sinh`; xem O_GSTT_78',
    bond_round_lot_matched_vol                   Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch khớp lệnh lô chẵn trái phiếu (Market ID BDO/HCX) — bảng khớp lệnh lô chẵn G1/G2/G3/G6/G7/G8; cùng grain mã CK × ngày với total_matched_vol. [MỚI 2026-10-30 v4.58] BA dòng 65–72 (Tổng KLGD khớp lệnh lô chẵn trái phiếu); xem O_GSTT_78',
    bond_round_lot_matched_val                   Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch khớp lệnh lô chẵn trái phiếu (Market ID BDO/HCX) — bảng khớp lệnh lô chẵn G1/G2/G3/G6/G7/G8; cùng grain mã CK × ngày với total_matched_val. [MỚI 2026-10-30 v4.58] BA dòng 65–72 (Tổng GTGD khớp lệnh lô chẵn trái phiếu); xem O_GSTT_78',
    bond_round_lot_negotiated_vol                Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch thỏa thuận lô chẵn trái phiếu (Market ID BDO/HCX) — bảng thỏa thuận lô chẵn T1/T2/T3/T6/R1; cùng grain mã CK × ngày với total_negotiated_vol. [MỚI 2026-10-30 v4.58] BA dòng 65–72 (Tổng KLGD thỏa thuận lô chẵn trái phiếu); xem O_GSTT_78',
    bond_round_lot_negotiated_val                Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch thỏa thuận lô chẵn trái phiếu (Market ID BDO/HCX) — bảng thỏa thuận lô chẵn T1/T2/T3/T6/R1; cùng grain mã CK × ngày với total_negotiated_val. [MỚI 2026-10-30 v4.58] BA dòng 65–72 (Tổng GTGD thỏa thuận lô chẵn trái phiếu); xem O_GSTT_78',
    bond_odd_lot_matched_vol                     Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch khớp lệnh lô lẻ trái phiếu (Market ID BDO/HCX) — bảng khớp lệnh lô lẻ G4; cùng grain mã CK × ngày với total_matched_vol. [MỚI 2026-10-30 v4.58] BA dòng 65–72 (Tổng KLGD khớp lệnh lô lẻ trái phiếu); xem O_GSTT_78',
    bond_odd_lot_matched_val                     Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch khớp lệnh lô lẻ trái phiếu (Market ID BDO/HCX) — bảng khớp lệnh lô lẻ G4; cùng grain mã CK × ngày với total_matched_val. [MỚI 2026-10-30 v4.58] BA dòng 65–72 (Tổng GTGD khớp lệnh lô lẻ trái phiếu); xem O_GSTT_78',
    bond_odd_lot_negotiated_vol                  Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch thỏa thuận lô lẻ trái phiếu (Market ID BDO/HCX) — bảng thỏa thuận lô lẻ T4; cùng grain mã CK × ngày với total_negotiated_vol. [MỚI 2026-10-30 v4.58] BA dòng 65–72 (Tổng KLGD thỏa thuận lô lẻ trái phiếu); xem O_GSTT_78',
    bond_odd_lot_negotiated_val                  Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch thỏa thuận lô lẻ trái phiếu (Market ID BDO/HCX) — bảng thỏa thuận lô lẻ T4; cùng grain mã CK × ngày với total_negotiated_val. [MỚI 2026-10-30 v4.58] BA dòng 65–72 (Tổng GTGD thỏa thuận lô lẻ trái phiếu); xem O_GSTT_78',
    fr_period_end_dt                    Nullable(Date)          COMMENT 'Ngày kết thúc của kỳ báo cáo tài chính gần nhất — làm phẳng từ fr_period_end_dt_dim_id (bổ sung 2026-09-08, rule GSĐC)',
    foreign_buy_vol                     Nullable(Int64)         COMMENT 'Khối lượng mua của nhà đầu tư nước ngoài',
    foreign_sell_vol                    Nullable(Int64)         COMMENT 'Khối lượng bán của nhà đầu tư nước ngoài',
    foreign_buy_val                     Nullable(Decimal(23,2)) COMMENT 'Giá trị mua của nhà đầu tư nước ngoài',
    foreign_sell_val                    Nullable(Decimal(23,2)) COMMENT 'Giá trị bán của nhà đầu tư nước ngoài',
    proprietary_buy_val                 Nullable(Decimal(23,2)) COMMENT 'Giá trị mua tự doanh',
    proprietary_sell_val                Nullable(Decimal(23,2)) COMMENT 'Giá trị bán tự doanh',
    proprietary_buy_vol                 Nullable(Int64)         COMMENT 'Khối lượng mua tự doanh',
    proprietary_sell_vol                Nullable(Int64)         COMMENT 'Khối lượng bán tự doanh',
    bond_trading_vol                    Nullable(Int64)         COMMENT 'Khối lượng giao dịch trái phiếu (loại trừ lô lẻ)',
    bond_negotiated_vol                 Nullable(Int64)         COMMENT 'Khối lượng giao dịch thỏa thuận trái phiếu (Market ID IN BDO/HCX, bảng thỏa thuận T1–T4/T6/R1).',
    bond_trading_val                    Nullable(Decimal(23,2)) COMMENT 'Giá trị giao dịch trái phiếu (loại trừ lô lẻ)',
    bond_negotiated_val                 Nullable(Decimal(23,2)) COMMENT 'Giá trị giao dịch thỏa thuận trái phiếu (Market ID IN BDO/HCX, bảng thỏa thuận T1–T4/T6/R1).',
    fct_close_price                     Nullable(Decimal(23,2)) COMMENT '[SỬA 2026-09-07] Giá đóng cửa theo ngày lưu trên Fact (khác close_price ở Security Trading Snapshot Dimension — SCD4A current-state) — bổ sung 2026-09-04, thiếu sót trong flat table trước đây, nay bổ sung để phục vụ window function K_GSTT_106/107/140-143 (Đỉnh/Đáy cũ)',
    fct_high_price                      Nullable(Decimal(23,2)) COMMENT '[SỬA 2026-09-19, lần 4] Giá cao nhất theo ngày lưu trên Fact (khác high_price ở Security Trading Snapshot Dimension — SCD4A current-state) — phục vụ window function K_GSTT_106/140/141 (Đỉnh cũ/Giá cao nhất N tháng), đổi lại từ close_price sau khi đối chiếu lại BA (Nhóm 15/17/36)',
    fct_low_price                       Nullable(Decimal(23,2)) COMMENT '[SỬA 2026-09-19, lần 4] Giá thấp nhất theo ngày lưu trên Fact — phục vụ window function K_GSTT_107/142/143 (Đáy cũ/Giá thấp nhất N tháng)',
    fct_reference_price                 Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-14, đóng O_GSTT_21 — đơn giản hóa theo góp ý Data Modeler] Giá tham chiếu theo ngày lưu trên Fact — đã do sàn tính đúng theo quy tắc riêng từng sàn (HOSE/HNX = Close Price phiên trước, UPCOM = VWAP phiên trước). Phục vụ K_GSTT_145: lấy thẳng dòng tại Từ ngày, không cần self-join/CASE floor',
    fct_open_price                      Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-10-30 v4.58, O_GSTT_78] Giá mở cửa theo ngày lưu trên Fact (khác open_price ở Security Trading Snapshot Dimension — SCD4A current-state) — phục vụ Giá mở cửa theo Đến ngày ở các Nhóm Top có Từ ngày/Đến ngày (BA Nhóm 13/15/17/19/21)',
    fct_ceiling_price                   Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-10-30 v4.58, O_GSTT_78] Giá trần theo ngày lưu trên Fact (khác ceiling_price ở Security Trading Snapshot Dimension — SCD4A current-state) — phục vụ Giá trần theo Đến ngày (K_GSTT_159 ở Nhóm 13)',
    fct_floor_price                     Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-10-30 v4.58, O_GSTT_78] Giá sàn theo ngày lưu trên Fact (khác floor_price ở Security Trading Snapshot Dimension — SCD4A current-state) — phục vụ Giá sàn theo Đến ngày (K_GSTT_160 ở Nhóm 13)',
    market_cap                                   Nullable(Decimal(23,2)) COMMENT 'Vốn hóa mã CK tại ngày giao dịch = Giá tính vốn hóa × Số cổ phiếu đang lưu hành, lưu theo từng ngày trên Fact. Giá tính vốn hóa: HNX/HOSE = giá đóng cửa; UPCOM (floor_code 04) = giá bình quân VWAP ghi trên bản tin cuối ngày của PHIÊN GIAO DỊCH KẾ TIẾP (T+1) — NULL khi chưa có VWAP T+1 (chưa tính vốn hóa), VWAP = 0 thì lấy giá tham chiếu ngày T. Phiên kế tiếp = ngày nhỏ nhất lớn hơn T có trên market_index_snapshot. [MỚI 2026-10-30 v4.58, BA GSTT — Data Modeler chọn thêm cột mức mã CK, O_GSTT_78 mục (a)]. Nguồn của K_GSTT_61 (Vốn hóa mức mã), SUM theo rổ ở idx_market_cap/idx_pe/idx_pb và LAG ở prior_market_cap.',
    free_float_market_cap                        Nullable(Decimal(23,2)) COMMENT 'Vốn hóa mã CK tại ngày giao dịch = Giá tính vốn hóa × Số cổ phiếu tự do chuyển nhượng, lưu theo từng ngày trên Fact. Giá tính vốn hóa: HNX/HOSE = giá đóng cửa; UPCOM (floor_code 04) = giá bình quân VWAP ghi trên bản tin cuối ngày của PHIÊN GIAO DỊCH KẾ TIẾP (T+1) — NULL khi chưa có VWAP T+1 (chưa tính vốn hóa), VWAP = 0 thì lấy giá tham chiếu ngày T. Phiên kế tiếp = ngày nhỏ nhất lớn hơn T có trên market_index_snapshot. [MỚI 2026-10-30 v4.58, BA GSTT — Data Modeler chọn thêm cột mức mã CK, O_GSTT_78 mục (a)]. Nguồn LAG của prior_free_float_market_cap và SUM theo rổ ở idx_free_float_market_cap (Nhóm 24).',
    prior_market_cap                    Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-19, review Nhóm 24, xem O_GSTT_25] Vốn hóa mã CK tại phiên LIỀN TRƯỚC (T-1) — LAG(Close Price × Outstanding Share Quantity), lưu sẵn trên dòng T. Phục vụ K_GSTT_74 (trọng số w_i đúng ngày T-1, sửa bug lấy nhầm vốn hóa ngày T)',
    prior_free_float_market_cap         Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-19, review Nhóm 24, xem O_GSTT_25] Vốn hóa tự do chuyển nhượng mã CK tại phiên LIỀN TRƯỚC (T-1) — LAG(Close Price × Free Float Share Quantity). Phục vụ K_GSTT_76 (trọng số w_ff_i đúng ngày T-1)',
    free_float_share_quantity           Nullable(Int64)         COMMENT '[SỬA 2026-09-14] Khối lượng cổ phiếu tự do chuyển nhượng — nguồn VSDC listed_share_info (outstanding_shares), phục vụ K_GSTT_76/125 (Nhóm 24)',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                     Nullable(String)        COMMENT 'Cờ Y/N — ngày lịch có phải ngày thị trường thực sự mở cửa giao dịch hay không (bổ sung 2026-09-05, partial trên cdr_dt_dim, yêu cầu trực tiếp từ user). Dùng suy ra ngày giao dịch gần nhất = MAX(cdr_dt) WHERE is_trading_date=\'Y\' — tham số lọc mặc định dashboard/báo cáo GSTT (K_GSTT_128)',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    symbol                               Nullable(String)        COMMENT 'Mã chứng khoán — từ Security Trading Snapshot Dimension',
    security_full_nm                    Nullable(String)        COMMENT 'Tên chứng khoán — từ Security Trading Snapshot Dimension',
    floor_code                          Nullable(String)        COMMENT 'Mã sàn — từ Security Trading Snapshot Dimension',
    stock_tp_code                       Nullable(String)        COMMENT 'Loại chứng khoán — từ Security Trading Snapshot Dimension',
    stock_tp_nm                         Nullable(String)        COMMENT 'Tên loại chứng khoán (dẫn xuất theo sàn) — từ Security Trading Snapshot Dimension',
    underlying_symbol                   Nullable(String)        COMMENT 'Chứng khoán cơ sở (CW/phái sinh) — từ Security Trading Snapshot Dimension',
    isin_code                           Nullable(String)        COMMENT 'Mã ISIN — từ Security Trading Snapshot Dimension',
    issuer_nm                           Nullable(String)        COMMENT 'Tổ chức phát hành — từ Security Trading Snapshot Dimension',
    listed_share_count                  Nullable(Int64)         COMMENT 'Khối lượng CK niêm yết — từ Security Trading Snapshot Dimension',
    first_trading_dt                    Nullable(Date)          COMMENT 'Ngày giao dịch đầu tiên — từ Security Trading Snapshot Dimension',
    last_trading_dt                     Nullable(Date)          COMMENT 'Ngày giao dịch cuối cùng — từ Security Trading Snapshot Dimension',
    issue_dt                            Nullable(Date)          COMMENT 'Ngày phát hành — từ Security Trading Snapshot Dimension',
    maturity_dt                         Nullable(Date)          COMMENT 'Ngày đáo hạn — từ Security Trading Snapshot Dimension',
    fund_tp_code                        Nullable(String)        COMMENT 'Loại quỹ (CCQ) — từ Security Trading Snapshot Dimension',
    covered_warrant_tp_code             Nullable(String)        COMMENT 'Loại chứng quyền — từ Security Trading Snapshot Dimension',
    exercise_price                      Nullable(Decimal(23,2)) COMMENT 'Giá thực hiện (CW/phái sinh) — từ Security Trading Snapshot Dimension',
    exercise_ratio                      Nullable(Decimal(10,2)) COMMENT 'Tỷ lệ chuyển đổi — từ Security Trading Snapshot Dimension',
    exercise_style_code                 Nullable(String)        COMMENT 'Kiểu thực hiện quyền — từ Security Trading Snapshot Dimension',
    put_or_call_code                    Nullable(String)        COMMENT 'Quyền chọn mua/bán — từ Security Trading Snapshot Dimension',
    contract_multiplier                 Nullable(Decimal(10,2)) COMMENT 'Hệ số hợp đồng (phái sinh) — từ Security Trading Snapshot Dimension',
    maturity_month_year                 Nullable(String)        COMMENT 'Tháng/năm đáo hạn (phái sinh) — từ Security Trading Snapshot Dimension',
    coupon_rate                         Nullable(Decimal(7,4))  COMMENT 'Lãi suất coupon (trái phiếu) — từ Security Trading Snapshot Dimension',
    yield                                Nullable(Decimal(7,4))  COMMENT 'Lợi suất (trái phiếu) — từ Security Trading Snapshot Dimension',
    open_price                           Nullable(Decimal(23,2)) COMMENT 'Giá mở cửa — từ Security Trading Snapshot Dimension',
    high_price                           Nullable(Decimal(23,2)) COMMENT 'Giá cao nhất — từ Security Trading Snapshot Dimension',
    low_price                            Nullable(Decimal(23,2)) COMMENT 'Giá thấp nhất — từ Security Trading Snapshot Dimension',
    ceiling_price                        Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-22, BA bổ sung gấp] Giá trần (K_GSTT_159) — từ Security Trading Snapshot Dimension',
    floor_price                          Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-22, BA bổ sung gấp] Giá sàn (K_GSTT_160) — từ Security Trading Snapshot Dimension',
    reference_price                     Nullable(Decimal(23,2)) COMMENT 'Giá tham chiếu — từ Security Trading Snapshot Dimension',
    close_price                         Nullable(Decimal(23,2)) COMMENT 'Giá đóng cửa — từ Security Trading Snapshot Dimension',
    price_change                        Nullable(Decimal(23,2)) COMMENT 'Thay đổi giá — từ Security Trading Snapshot Dimension',
    security_trading_snpst_src_stm_code Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Security Trading Snapshot Dimension',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_code                 Nullable(String)        COMMENT 'Mã CTĐC — từ Public Company Dimension',
    equity_ticker_symbol                 Nullable(String)        COMMENT 'Mã cổ phiếu — từ Public Company Dimension',
    public_company_nm                    Nullable(String)        COMMENT 'Tên doanh nghiệp — từ Public Company Dimension',
    equity_listing_exchange_code         Nullable(String)        COMMENT 'Sàn niêm yết — từ Public Company Dimension',
    business_line_level_1_code           Nullable(String)        COMMENT 'Ngành kinh tế cấp 1 — từ Public Company Dimension',
    ids_registration_dt                  Nullable(Date)          COMMENT 'Ngày đăng ký IDS — từ Public Company Dimension',
    public_company_status_code           Nullable(String)        COMMENT 'Trạng thái công ty — từ Public Company Dimension',
    classification_business_line_nm      Nullable(String)        COMMENT 'Tên ngành (đệm sẵn) — từ Public Company Dimension',
    public_company_english_nm            Nullable(String)        COMMENT 'Tên công ty tiếng Anh — từ Public Company Dimension',
    enterprise_tp_code                   Nullable(String)        COMMENT 'Loại hình doanh nghiệp — từ Public Company Dimension',
    public_company_tp_code               Nullable(String)        COMMENT 'Loại công ty đại chúng — từ Public Company Dimension',
    head_office_province_nm              Nullable(String)        COMMENT 'Tỉnh/TP trụ sở chính — từ Public Company Dimension',
    operating_status_code                Nullable(String)        COMMENT 'Trạng thái hoạt động doanh nghiệp — từ Public Company Dimension',
    has_state_ownership_indicator        Nullable(Int64)         COMMENT 'Cờ có vốn nhà nước — từ Public Company Dimension',
    charter_capital_amt                  Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ — từ Public Company Dimension',
    first_registration_dt                Nullable(Date)          COMMENT 'Ngày đăng ký lần đầu — từ Public Company Dimension',
    latest_registration_dt               Nullable(Date)          COMMENT 'Ngày đăng ký thay đổi gần nhất — từ Public Company Dimension',
    latest_registration_province_nm      Nullable(String)        COMMENT 'Tỉnh/TP đăng ký thay đổi gần nhất — từ Public Company Dimension',
    ids_registration_indicator           Nullable(Int64)         COMMENT 'Trạng thái đăng ký IDS — từ Public Company Dimension',
    public_company_form_code             Nullable(String)        COMMENT 'Hình thức trở thành công ty đại chúng — từ Public Company Dimension',
    former_state_owned_indicator         Nullable(Int64)         COMMENT 'Doanh nghiệp nhà nước (trước đây) — từ Public Company Dimension',
    foreign_direct_investment_indicator  Nullable(Int64)         COMMENT 'Doanh nghiệp FDI — từ Public Company Dimension',
    has_parent_company_indicator         Nullable(Int64)         COMMENT 'Có công ty mẹ — từ Public Company Dimension',
    has_subsidiary_indicator             Nullable(Int64)         COMMENT 'Có công ty con — từ Public Company Dimension',
    has_joint_venture_indicator          Nullable(Int64)         COMMENT 'Có liên doanh — từ Public Company Dimension',
    ipo_company_indicator                Nullable(Int64)         COMMENT '1-Công ty đang IPO, 0-Công ty đại chúng — từ Public Company Dimension',
    public_company_src_stm_code          Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Public Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), security_trading_snpst_dim_id)
COMMENT 'Flat table — Fact Stock Portfolio Snapshot × Calendar Date × Security Trading Snapshot Dimension × Public Company Dimension'
;


-- ============================================================
-- 1b. FACT: gstt_fct_index_constituent_snpst_flat
--    [SỬA 2026-09-14] Bridge (3 FK) — thành viên rổ chỉ số theo ngày,
--    1 row / mã CK / rổ chỉ số / ngày giao dịch. Tách khỏi
--    gstt_fct_stock_portfolio_snpst_flat để hết fan-out theo rổ chỉ số
--    (xem HLD v4.13, Cụm 1b). Dùng để lọc/SUM mã CK theo rổ chỉ số —
--    JOIN sang gstt_fct_stock_portfolio_snpst_flat qua symbol + cdr_dt khi cần measure
--    riêng theo mã CK. [SỬA 2026-09-14, theo yêu cầu Design] Bổ sung 8 measure tính sẵn
--    theo Index+Date (idx_*) — giá trị LẶP LẠI trên mọi dòng symbol cùng index_code+cdr_dt,
--    dùng MAX()/DISTINCT khi truy vấn, KHÔNG SUM lại.
--    Joins: Calendar Date (snpst_dt_dim_id JOIN) × Security Trading Snapshot Dimension ×
--           Index Constituent Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_index_constituent_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Index Constituent Snapshot
    security_trading_snpst_dim_id       String                  COMMENT 'FK → Security Trading Snapshot Dimension',
    index_constituent_dim_id            String                  COMMENT 'FK → Index Constituent Dimension',
    snpst_dt_dim_id                     String                  COMMENT 'FK → Calendar Date Dimension',
    idx_total_matched_vol                Nullable(Int64)         COMMENT '[SỬA 2026-09-14, review sheet Tổng hợp công thức] Tổng KLGD khớp lệnh thuần (loại thỏa thuận) toàn rổ chỉ số theo Index+Date — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_total_matched_val                Nullable(Decimal(23,2)) COMMENT '[SỬA 2026-09-14, review sheet Tổng hợp công thức] Tổng GTGD khớp lệnh thuần (loại thỏa thuận) toàn rổ chỉ số theo Index+Date — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_foreign_net_vol                 Nullable(Int64)         COMMENT '[MỚI 2026-09-14] KLNN ròng toàn rổ chỉ số theo Index+Date — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_foreign_net_val                 Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-14] GTNN ròng toàn rổ chỉ số theo Index+Date — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_total_negotiated_vol            Nullable(Int64)         COMMENT '[MỚI 2026-09-14] Tổng KLGD thỏa thuận toàn rổ chỉ số theo Index+Date — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_total_negotiated_val            Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-14] Tổng GTGD thỏa thuận toàn rổ chỉ số theo Index+Date — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_market_index_val                Nullable(Decimal(23,4)) COMMENT '[SỬA 2026-09-23] Điểm chỉ số cuối phiên của rổ theo Index+Date (lookup Market Index Snapshot rn=1 qua market_code = index_code) — lặp lại trên mọi mã CK cùng rổ, không SUM',
    idx_market_cap                      Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-14, SỬA 2026-09-16] Vốn hóa thị trường toàn rổ chỉ số theo Index+Date (nguồn VSDC listed_share_info) — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_free_float_market_cap           Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-14] Vốn hóa tự do chuyển nhượng toàn rổ chỉ số theo Index+Date — lặp lại trên mọi dòng symbol cùng rổ, không SUM lại',
    idx_pe                               Nullable(Decimal(10,2)) COMMENT '[MỚI 2026-09-19, review Nhóm 6] P/E CỦA CHỈ SỐ = SUM(Vốn hóa mã có LNST TTM)/SUM(LNST TTM) theo Index+Date — khác K_GSTT_58 (P/E từng mã, trên fct_stock_portfolio_snpst). Lặp lại trên mọi dòng symbol cùng rổ, không SUM/AVG lại. [SỬA 2026-10-15] Mẫu số cộng thêm LNST TTM của CTCK từ SCMS (O_GSTT_70)',
    idx_pb                               Nullable(Decimal(10,2)) COMMENT '[MỚI 2026-09-19, review Nhóm 6] P/B CỦA CHỈ SỐ = SUM(Vốn hóa mã có VCSH)/SUM(VCSH) theo Index+Date — khác K_GSTT_59 (P/B từng mã). Lặp lại trên mọi dòng symbol cùng rổ, không SUM/AVG lại. [SỬA 2026-10-15] Mẫu số cộng thêm VCSH của CTCK từ SCMS (O_GSTT_70)',
    idx_eps                             Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-19, review Nhóm 6] EPS CỦA CHỈ SỐ = SUM(LNST TTM)/SUM(Số CP lưu hành) theo Index+Date — khác K_GSTT_60 (EPS từng mã); xem O_GSTT_24 về lọc mẫu số. Lặp lại trên mọi dòng symbol cùng rổ, không SUM/AVG lại',
    idx_prior_market_cap                Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-19, review Nhóm 24, xem O_GSTT_25] LAG(idx_market_cap) 1 phiên theo Index Code — Tổng vốn hóa rổ chỉ số tại T-1. Phục vụ K_GSTT_74 (mẫu số trọng số w_i đúng ngày T-1)',
    idx_prior_free_float_market_cap     Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-09-19, review Nhóm 24, xem O_GSTT_25] LAG(idx_free_float_market_cap) 1 phiên theo Index Code — Tổng vốn hóa tự do chuyển nhượng rổ tại T-1. Phục vụ K_GSTT_76 (mẫu số w_ff_i)',
    idx_foreign_buy_vol                          Nullable(Int64)         COMMENT '[MỚI 2026-10-15 v4.49, BA STT 5 dòng 89 (K_GSTT_370)] Khối lượng MUA của NĐT nước ngoài của TOÀN BỘ mã CK thành viên rổ chỉ số (tổng khớp lệnh + thỏa thuận) — SUM GROUP BY Index Code + Trading Date, tính sẵn. Nước ngoài = ký tự thứ 4 của số tài khoản mua IN (F,E). GIÁ TRỊ LẶP LẠI trên mọi dòng Symbol cùng Index+Date — khi truy vấn theo Symbol TUYỆT ĐỐI KHÔNG SUM lại cột này, dùng MAX()/ANY_VALUE() GROUP BY Index Code, Trading Date hoặc SELECT DISTINCT.',
    idx_foreign_sell_vol                         Nullable(Int64)         COMMENT '[MỚI 2026-10-15 v4.49, BA STT 5 dòng 90 (K_GSTT_371)] Khối lượng BÁN của NĐT nước ngoài của TOÀN BỘ mã CK thành viên rổ chỉ số (tổng khớp lệnh + thỏa thuận) — SUM GROUP BY Index Code + Trading Date, tính sẵn. Nước ngoài = ký tự thứ 4 của số tài khoản bán IN (F,E). GIÁ TRỊ LẶP LẠI trên mọi dòng Symbol cùng Index+Date — khi truy vấn theo Symbol TUYỆT ĐỐI KHÔNG SUM lại cột này, dùng MAX()/ANY_VALUE() GROUP BY Index Code, Trading Date hoặc SELECT DISTINCT.',
    idx_foreign_buy_val                          Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-10-15 v4.49, BA STT 5 dòng 92 (K_GSTT_372)] Giá trị MUA của NĐT nước ngoài của TOÀN BỘ mã CK thành viên rổ chỉ số (tổng khớp lệnh + thỏa thuận) — SUM GROUP BY Index Code + Trading Date, tính sẵn. Nước ngoài = ký tự thứ 4 của số tài khoản mua IN (F,E). GIÁ TRỊ LẶP LẠI trên mọi dòng Symbol cùng Index+Date — khi truy vấn theo Symbol TUYỆT ĐỐI KHÔNG SUM lại cột này, dùng MAX()/ANY_VALUE() GROUP BY Index Code, Trading Date hoặc SELECT DISTINCT.',
    idx_foreign_sell_val                         Nullable(Decimal(23,2)) COMMENT '[MỚI 2026-10-15 v4.49, BA STT 5 dòng 93 (K_GSTT_373)] Giá trị BÁN của NĐT nước ngoài của TOÀN BỘ mã CK thành viên rổ chỉ số (tổng khớp lệnh + thỏa thuận) — SUM GROUP BY Index Code + Trading Date, tính sẵn. Nước ngoài = ký tự thứ 4 của số tài khoản bán IN (F,E). GIÁ TRỊ LẶP LẠI trên mọi dòng Symbol cùng Index+Date — khi truy vấn theo Symbol TUYỆT ĐỐI KHÔNG SUM lại cột này, dùng MAX()/ANY_VALUE() GROUP BY Index Code, Trading Date hoặc SELECT DISTINCT.',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                     Nullable(String)        COMMENT '[BỔ SUNG 2026-09-14] Cờ Y/N — ngày lịch có phải ngày thị trường thực sự mở cửa giao dịch hay không — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    symbol                              Nullable(String)        COMMENT 'Mã chứng khoán — từ Security Trading Snapshot Dimension',

    -- From: INDEX CONSTITUENT DIMENSION
    index_code                          Nullable(String)        COMMENT 'Mã rổ chỉ số — từ Index Constituent Dimension',
    index_id                            Nullable(String)        COMMENT 'Id chỉ số — từ Index Constituent Dimension',
    index_nm                            Nullable(String)        COMMENT '[MỚI 2026-09-15] Tên chuẩn của chỉ số (VN-Index/HNX-Index/UPCoM-Index/VN30...) — từ Index Constituent Dimension, JOIN sang Market Index Snapshot theo Market Code = Index Code (không CASE WHEN), cùng nguồn Index Name dùng ở Market Index Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), security_trading_snpst_dim_id, index_constituent_dim_id)
COMMENT 'Flat table — Fact Index Constituent Snapshot (Bridge) × Calendar Date × Security Trading Snapshot Dimension × Index Constituent Dimension'
;


-- ============================================================
-- 2. FACT: gstt_fct_market_index_intraday_flat
--    Diễn biến chỉ số thị trường realtime trong ngày — 1 row / chỉ số thị trường
--    (market_code) / Index Time — KHÔNG lọc rn=1 (khác Fact EOD fct_market_index_snpst)
--    Grain: Transaction/Tick log — nhiều dòng/ngày theo Index Time, có thể append
--    thêm tick mới trong cùng ngày khi ETL chạy nhiều lần/ngày
--    Joins: Calendar Date (trade_dt_dim_id JOIN) × Market Index Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_market_index_intraday_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Market Index Intraday
    market_index_dim_id                 String                  COMMENT 'FK → Market Index Dimension',
    trade_dt_dim_id                       String                  COMMENT 'FK → Calendar Date Dimension',
    index_time                          Nullable(String)        COMMENT 'Thời gian ghi nhận chỉ số trong ngày (DD — grain component)',
    market_index_val_at_time            Nullable(Decimal(23,2)) COMMENT 'Điểm chỉ số tại thời điểm ghi nhận',
    total_val_at_time                   Nullable(Decimal(23,2)) COMMENT 'Giá trị giao dịch phát sinh tại thời điểm ghi nhận',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                     Nullable(String)        COMMENT '[BỔ SUNG 2026-09-14] Cờ Y/N — ngày lịch có phải ngày thị trường thực sự mở cửa giao dịch hay không — từ Calendar Date Dimension',

    -- From: MARKET INDEX DIMENSION
    market_id                           Nullable(String)        COMMENT 'Mã thị trường — từ Market Index Dimension',
    market_code                         Nullable(String)        COMMENT 'Mã sàn/chỉ số (HOSE/HNX/UPCOM/30) — từ Market Index Dimension',
    index_nm                            Nullable(String)        COMMENT 'Tên chuẩn của chỉ số (VN-Index/HNX-Index/UPCoM-Index/VN30...) theo MDDS.JAD_MARKETINFOR.INDEXNAME — từ Market Index Dimension, dùng hiển thị thay market_code',
    index_tp_code                       Nullable(String)        COMMENT 'Loại chỉ số — từ Market Index Dimension',
    tsc_product_group_id                Nullable(String)        COMMENT 'Mã sản phẩm giao dịch (HOSE/HNX/UPCOM) — từ Market Index Dimension',
    market_status_code                  Nullable(String)        COMMENT 'Trạng thái phiên (current-state SCD4A) — từ Market Index Dimension',
    market_index_src_stm_code           Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Market Index Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), market_index_dim_id, index_time)
COMMENT 'Flat table — Fact Market Index Intraday × Calendar Date Dimension × Market Index Dimension'
;


-- ============================================================
-- 3. FACT: gstt_fct_instrument_price_intraday_flat
--    [THIẾT KẾ LẠI 2026-10-06 v4.33] Nhóm 34 — Fact nến PHÚT theo độ mịn cả mã CK VÀ chỉ số: 1 row / Instrument Code / Trading Timestamp.
--    Nguồn Atomic market_price_snapshot (MDDS.JAD_TRADINGVIEWHISTORY1MIN = JAD_tvhistory1m — symbol gồm cả chứng khoán và chỉ số); dùng khi người dùng lọc theo ngày.
--    Thay gstt_fct_security_trading_intraday_flat (bãi bỏ — DROP bảng cũ khi deploy; xem O_GSTT_58). Cặp với #3a (nến ngày).
--    Joins: Calendar Date (trade_dt_dim_id JOIN) × Security Trading Snapshot Dimension (LEFT JOIN — NULL với dòng chỉ số)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_instrument_price_intraday_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Instrument Price Intraday
    security_trading_snpst_dim_id    Nullable(String)         COMMENT 'FK → Security Trading Snapshot Dimension — NULL với dòng chỉ số',
    trade_dt_dim_id                  String                   COMMENT 'FK → Calendar Date Dimension',
    instrument_code                  String                   COMMENT 'Mã chứng khoán HOẶC mã chỉ số (DD — grain component)',
    trading_tms                      Nullable(DateTime)       COMMENT 'Thời điểm nến phút = Trading Date + Processing Time (DD — grain component)',
    open_price                       Nullable(Decimal(23,2))  COMMENT 'Giá mở cửa của nến phút; chỉ số = điểm chỉ số',
    high_price                       Nullable(Decimal(23,2))  COMMENT 'Giá cao nhất của nến phút',
    low_price                        Nullable(Decimal(23,2))  COMMENT 'Giá thấp nhất của nến phút',
    close_price                      Nullable(Decimal(23,2))  COMMENT 'Giá đóng cửa của nến phút',
    vol                              Nullable(Int64)          COMMENT 'Khối lượng khớp của nến phút (phát sinh riêng từng phút, không lũy kế)',
    cumulative_vol_at_time           Nullable(Int64)          COMMENT 'Khối lượng khớp lũy kế từ đầu ngày tại thời điểm nến phút — không phải KL phát sinh riêng tại thời điểm đó',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                     Nullable(String)        COMMENT 'Cờ Y/N — ngày lịch có phải ngày thị trường mở cửa giao dịch — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION (NULL với dòng chỉ số)
    symbol                              Nullable(String)        COMMENT 'Mã chứng khoán — từ Security Trading Snapshot Dimension',
    security_full_nm                    Nullable(String)        COMMENT 'Tên chứng khoán — từ Security Trading Snapshot Dimension',
    floor_code                          Nullable(String)        COMMENT 'Mã sàn — từ Security Trading Snapshot Dimension',
    stock_tp_code                       Nullable(String)        COMMENT 'Loại chứng khoán — từ Security Trading Snapshot Dimension',
    stock_tp_nm                         Nullable(String)        COMMENT 'Tên loại chứng khoán — từ Security Trading Snapshot Dimension',
    security_trading_src_stm_code       Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Security Trading Snapshot Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), instrument_code, assumeNotNull(trading_tms))
COMMENT 'Flat table — Fact Instrument Price Intraday × Calendar Date Dimension × Security Trading Snapshot Dimension (mã CK và chỉ số)'
;


-- ============================================================
-- 3a. FACT: gstt_fct_instrument_price_daily_flat
--    [THIẾT KẾ LẠI 2026-10-06 v4.33] Nhóm 34 — Fact nến NGÀY theo độ mịn cả mã CK VÀ chỉ số: 1 row / Instrument Code / Trade Date, kèm Doanh thu/LNST (NULL với chỉ số).
--    Nguồn Atomic market_price_snapshot (MDDS.JAD_TRADINGVIEWHISTORY1DAY = JAD_tvhistory1d) + IDS báo cáo tài chính; dùng khi người dùng lọc theo tháng. K_GSTT_13 Nhóm 34 = vol nến ngày.
--    Khác gstt_fct_security_trading_daily_flat (Nhóm 3/47/48: chỉ mã CK). Cặp với #3 (nến phút).
--    Joins: Calendar Date (trade_dt_dim_id JOIN) × Security Trading Snapshot Dimension (LEFT JOIN — NULL với dòng chỉ số)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_instrument_price_daily_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Instrument Price Daily
    security_trading_snpst_dim_id    Nullable(String)         COMMENT 'FK → Security Trading Snapshot Dimension — NULL với dòng chỉ số',
    trade_dt_dim_id                  String                   COMMENT 'FK → Calendar Date Dimension (DD — grain component cùng instrument_code)',
    instrument_code                  String                   COMMENT 'Mã chứng khoán HOẶC mã chỉ số (DD — grain component)',
    open_price                       Nullable(Decimal(23,2))  COMMENT 'Giá mở cửa của nến ngày; chỉ số = điểm chỉ số',
    high_price                       Nullable(Decimal(23,2))  COMMENT 'Giá cao nhất của nến ngày',
    low_price                        Nullable(Decimal(23,2))  COMMENT 'Giá thấp nhất của nến ngày',
    close_price                      Nullable(Decimal(23,2))  COMMENT 'Giá đóng cửa của nến ngày',
    vol                              Nullable(Int64)          COMMENT 'Tổng khối lượng khớp trong ngày (JAD_tvhistory1d) — nguồn K_GSTT_13 Nhóm 34',
    revenue                          Nullable(Decimal(23,2))  COMMENT 'Doanh thu kỳ BCTC gần nhất đã công bố — NULL với dòng chỉ số',
    net_profit_after_tax             Nullable(Decimal(23,2))  COMMENT 'LNST kỳ BCTC gần nhất đã công bố — NULL với dòng chỉ số',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                     Nullable(String)        COMMENT 'Cờ Y/N — ngày lịch có phải ngày thị trường mở cửa giao dịch — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION (NULL với dòng chỉ số)
    symbol                              Nullable(String)        COMMENT 'Mã chứng khoán — từ Security Trading Snapshot Dimension',
    security_full_nm                    Nullable(String)        COMMENT 'Tên chứng khoán — từ Security Trading Snapshot Dimension',
    floor_code                          Nullable(String)        COMMENT 'Mã sàn — từ Security Trading Snapshot Dimension',
    stock_tp_code                       Nullable(String)        COMMENT 'Loại chứng khoán — từ Security Trading Snapshot Dimension',
    stock_tp_nm                         Nullable(String)        COMMENT 'Tên loại chứng khoán — từ Security Trading Snapshot Dimension',
    security_trading_src_stm_code       Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Security Trading Snapshot Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), instrument_code)
COMMENT 'Flat table — Fact Instrument Price Daily × Calendar Date Dimension × Security Trading Snapshot Dimension (mã CK và chỉ số)'
;


-- ============================================================
-- 3b. FACT: gstt_fct_security_trading_daily_flat
--    [v4.35 2026-10-06] Chỉ còn dùng cho Nhóm 48 (K_GSTT_352 — Giá đóng cửa trái phiếu); Nhóm 3/34/47 chuyển sang #3 / #3a (mã CK và chỉ số).
--    Nến NGÀY thật MDDS.JAD_TRADINGVIEWHISTORY1DAY (filter src_stm_code='MDDS_JAD_TRADINGVIEWHISTORY1DAY'), grain 1 row / Symbol / Trading Date;
--    cột open/high/low/vol giữ đủ nến nhưng không còn KPI dùng.
--    Joins: Calendar Date (trade_dt_dim_id JOIN) × Security Trading Snapshot Dimension (LEFT)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_security_trading_daily_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Security Trading Daily
    security_trading_snpst_dim_id       String                  COMMENT 'FK → Security Trading Snapshot Dimension',
    trade_dt_dim_id                     String                  COMMENT 'FK → Calendar Date Dimension',
    daily_open_price                    Nullable(Decimal(23,2)) COMMENT 'Giá mở cửa của nến ngày',
    daily_high_price                    Nullable(Decimal(23,2)) COMMENT 'Giá cao nhất của nến ngày',
    daily_low_price                     Nullable(Decimal(23,2)) COMMENT 'Giá thấp nhất của nến ngày',
    daily_close_price                   Nullable(Decimal(23,2)) COMMENT 'Giá đóng cửa của nến ngày',
    daily_vol                           Nullable(Int64)         COMMENT 'Tổng khối lượng khớp trong ngày của nến ngày (nguồn nến TradingView)',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                     Nullable(String)        COMMENT 'Cờ Y/N — ngày lịch có phải ngày thị trường thực sự mở cửa giao dịch hay không — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    symbol                              Nullable(String)        COMMENT 'Mã chứng khoán — từ Security Trading Snapshot Dimension',
    security_full_nm                    Nullable(String)        COMMENT 'Tên chứng khoán — từ Security Trading Snapshot Dimension',
    floor_code                          Nullable(String)        COMMENT 'Mã sàn — từ Security Trading Snapshot Dimension',
    stock_tp_code                       Nullable(String)        COMMENT 'Loại chứng khoán — từ Security Trading Snapshot Dimension',
    stock_tp_nm                         Nullable(String)        COMMENT 'Tên loại chứng khoán — từ Security Trading Snapshot Dimension',
    security_trading_src_stm_code       Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Security Trading Snapshot Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), security_trading_snpst_dim_id)
COMMENT 'Flat table — Fact Security Trading Daily × Calendar Date Dimension × Security Trading Snapshot Dimension'
;


-- ============================================================
-- 4. FACT: gstt_fct_foreign_trading_min_snpst_flat
--    [BỔ SUNG 2026-09-11] Thiết kế thật đã Resolved 2026-09-04 (O_GSTT_8, K_GSTT_78-80)
--    nhưng bị bỏ sót khỏi Phase 3 — bổ sung lại cho khớp Attributes/Detail Mapping/HLD
--    đã có sẵn từ trước, không phải thiết kế mới.
--    Dòng tiền NĐT nước ngoài theo phút — 1 row / mã CK (Symbol) / Trade Minute
--    [SỬA 2026-10-12] Nguồn Security Trading Snapshot (MDDS JAD_STOCKINFOR, per-tick): GTNN LŨY KẾ
--    trong ngày tại cuối phút (snapshot cuối phút, carry-forward) — khớp mapping BA, O_GSTT_41 mục 4
--    [SỬA 2026-10-22] BA STT 25/26 lấy theo sổ lệnh: nguồn Securities Trade, GTNN PHÁT SINH trong phút (không lũy kế) — O_GSTT_75
--    [SỬA 2026-10-30 v4.58] BA quay lại JAD_STOCKINFOR.foreignBuyVal/foreignSellVal — ĐẢO LẠI 2026-10-22: nguồn Security Trading Snapshot, GTNN LŨY KẾ cuối phút (carry-forward) — O_GSTT_78 mục (c)
--    Joins: Calendar Date (snpst_dt_dim_id JOIN) × Security Trading Snapshot Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_foreign_trading_min_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Foreign Trading Minute Snapshot
    security_trading_snpst_dim_id       String                  COMMENT 'FK → Security Trading Snapshot Dimension',
    snpst_dt_dim_id                       String                  COMMENT 'FK → Calendar Date Dimension',
    trade_minute_tms                    Nullable(DateTime)      COMMENT 'Mốc phút xác định grain (DD — grain component), cắt phút của Trading Date + Trading Time trên Security Trading Snapshot (JAD_STOCKINFOR)',
    foreign_buy_val_at_min              Nullable(Decimal(23,2)) COMMENT 'Giá trị mua LŨY KẾ của NĐT nước ngoài từ đầu ngày đến cuối phút (K_GSTT_78, JAD_STOCKINFOR.foreignBuyVal) — không cộng theo thời gian',
    foreign_sell_val_at_min             Nullable(Decimal(23,2)) COMMENT 'Giá trị bán LŨY KẾ của NĐT nước ngoài từ đầu ngày đến cuối phút (K_GSTT_79, JAD_STOCKINFOR.foreignSellVal) — không cộng theo thời gian',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                     Nullable(String)        COMMENT '[BỔ SUNG 2026-09-14] Cờ Y/N — ngày lịch có phải ngày thị trường thực sự mở cửa giao dịch hay không — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    symbol                               Nullable(String)        COMMENT 'Mã chứng khoán — từ Security Trading Snapshot Dimension',
    security_full_nm                    Nullable(String)        COMMENT 'Tên chứng khoán — từ Security Trading Snapshot Dimension',
    floor_code                          Nullable(String)        COMMENT 'Mã sàn — từ Security Trading Snapshot Dimension',
    stock_tp_code                       Nullable(String)        COMMENT 'Loại chứng khoán — từ Security Trading Snapshot Dimension',
    stock_tp_nm                         Nullable(String)        COMMENT 'Tên loại chứng khoán — từ Security Trading Snapshot Dimension',
    foreign_trading_min_src_stm_code    Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Security Trading Snapshot Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), security_trading_snpst_dim_id, trade_minute_tms)
COMMENT 'Flat table — Fact Foreign Trading Minute Snapshot × Calendar Date Dimension × Security Trading Snapshot Dimension'
;


-- ============================================================
-- 5. FACT: gstt_fct_investor_category_trading_snpst_flat
--    [MỚI 2026-09-21, theo yêu cầu Data Modeler] Giá trị mua/bán theo Phân loại NĐT
--    (Cá nhân/Tổ chức trong nước/Tự doanh/Nước ngoài/Không xác định [2026-10-22]), tách khớp lệnh/thỏa thuận —
--    1 row / mã CK / ngày giao dịch / Phân loại NĐT. Tách khỏi Fact Stock Portfolio
--    Snapshot để có cột vật lý Investor Category Code thay vì 4 cụm cột cố định +
--    CASE WHEN. Phục vụ K_GSTT_85/90-92/153-158 (Nhóm 31/32, grain Mã CK — sửa 2026-09-23). Không đổi Fact Stock Portfolio
--    Snapshot — Nhóm 21/25/29/37 không bị ảnh hưởng.
--    Joins: Calendar Date (snpst_dt_dim_id JOIN) × Security Trading Snapshot Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_investor_category_trading_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Investor Category Trading Snapshot
    security_trading_snpst_dim_id       String                  COMMENT 'FK → Security Trading Snapshot Dimension',
    snpst_dt_dim_id                       String                  COMMENT 'FK → Calendar Date Dimension',
    investor_category_code              Nullable(String)        COMMENT 'Phân loại NĐT: CA_NHAN / TO_CHUC_TRONG_NUOC / TU_DOANH / NUOC_NGOAI / KHONG_XAC_DINH [2026-10-22, BA Nhóm 23] (Classification Value)',
    buy_val                             Nullable(Decimal(23,2)) COMMENT 'Giá trị mua theo Phân loại NĐT (khớp lệnh + thỏa thuận) (K_GSTT_86, K_GSTT_90)',
    buy_vol                             Nullable(Int64)         COMMENT 'Khối lượng mua theo Phân loại NĐT (khớp lệnh + thỏa thuận).',
    sell_val                            Nullable(Decimal(23,2)) COMMENT 'Giá trị bán theo Phân loại NĐT (khớp lệnh + thỏa thuận) (K_GSTT_87, K_GSTT_91)',
    sell_vol                            Nullable(Int64)         COMMENT 'Khối lượng bán theo Phân loại NĐT (khớp lệnh + thỏa thuận).',
    matched_buy_val                     Nullable(Decimal(23,2)) COMMENT 'Giá trị mua khớp lệnh thuần theo Phân loại NĐT (K_GSTT_88 tổng mua+bán, K_GSTT_153 riêng mua)',
    matched_sell_val                    Nullable(Decimal(23,2)) COMMENT 'Giá trị bán khớp lệnh thuần theo Phân loại NĐT (K_GSTT_88 tổng mua+bán, K_GSTT_154 riêng bán)',
    negotiated_buy_val                  Nullable(Decimal(23,2)) COMMENT 'Giá trị mua thỏa thuận theo Phân loại NĐT (K_GSTT_89 tổng mua+bán, K_GSTT_156 riêng mua)',
    negotiated_sell_val                 Nullable(Decimal(23,2)) COMMENT 'Giá trị bán thỏa thuận theo Phân loại NĐT (K_GSTT_89 tổng mua+bán, K_GSTT_157 riêng bán)',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                     Nullable(String)        COMMENT 'Cờ Y/N — ngày lịch có phải ngày thị trường thực sự mở cửa giao dịch hay không — từ Calendar Date Dimension',

    -- From: SECURITY TRADING SNAPSHOT DIMENSION
    symbol                               Nullable(String)        COMMENT 'Mã chứng khoán — từ Security Trading Snapshot Dimension',
    security_full_nm                    Nullable(String)        COMMENT 'Tên chứng khoán — từ Security Trading Snapshot Dimension',
    floor_code                          Nullable(String)        COMMENT 'Mã sàn — từ Security Trading Snapshot Dimension',
    stock_tp_code                       Nullable(String)        COMMENT 'Loại chứng khoán — từ Security Trading Snapshot Dimension',
    stock_tp_nm                         Nullable(String)        COMMENT 'Tên loại chứng khoán — từ Security Trading Snapshot Dimension',
    investor_ctgy_trd_src_stm_code      Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Security Trading Snapshot Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), security_trading_snpst_dim_id, investor_category_code)
COMMENT 'Flat table — Fact Investor Category Trading Snapshot × Calendar Date Dimension × Security Trading Snapshot Dimension'
;


-- ============================================================
-- 5b. FACT: gstt_fct_investor_category_index_trading_snpst_flat
--    [MỚI 2026-09-23, Data Modeler duyệt] Giá trị mua/bán theo Phân loại NĐT ở cấp
--    rổ chỉ số (Tổng/Khớp lệnh/Thỏa thuận) + điểm/thay đổi/% thay đổi chỉ số —
--    1 row / Index Code / ngày giao dịch / Phân loại NĐT. Phục vụ Nhóm 30/33
--    (K_GSTT_85, 35, 38, 39, 161-169). Giá chỉ số lặp lại trên 4 Phân loại NĐT → MAX.
--    Joins: Calendar Date (snpst_dt_dim_id JOIN) × Index Constituent Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_investor_category_index_trading_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Investor Category Index Trading Snapshot
    index_constituent_dim_id            String                  COMMENT 'FK → Index Constituent Dimension',
    snpst_dt_dim_id                     String                  COMMENT 'FK → Calendar Date Dimension',
    investor_category_code              String                  COMMENT 'Phân loại NĐT: CA_NHAN / TO_CHUC_TRONG_NUOC / TU_DOANH / NUOC_NGOAI (Classification Value)',
    buy_val                             Nullable(Decimal(23,2)) COMMENT 'Giá trị mua theo Phân loại NĐT của rổ chỉ số (khớp lệnh + thỏa thuận)',
    buy_vol                                      Nullable(Int64)         COMMENT '[MỚI 2026-10-16 v4.51, ma trận chiều × chỉ tiêu Nhóm 37 — O_GSTT_71] Khối lượng mua theo Phân loại NĐT của toàn bộ mã CK thuộc rổ chỉ số (khớp lệnh + thỏa thuận). [SỬA 2026-10-15 v4.49, BA cập nhật phân loại NĐT — thay quy tắc 2026-09-25 Tổ chức = (TC mua − TC bán) − (tự doanh mua − bán)] Mỗi phía mua/bán phân loại ĐỘC LẬP theo số tài khoản: Tự doanh = ký tự thứ 4 của số TK IN (P,E); Nước ngoài = ký tự thứ 4 IN (F,E); Cá nhân trong nước = bản ghi MỚI NHẤT của `discretionary_investment_account` (nguồn VSDC `open_investors`, dedupe theo số TK, mới nhất theo `event_dt` — Data Modeler xác nhận 2026-10-15) có `investment_account_tp_code` = 3; Tổ chức trong nước = 5 (trực tiếp, không còn phép trừ). Các phân loại KHÔNG loại trừ nhau (TK loại E tính ở cả Tự doanh lẫn Nước ngoài). Khớp lệnh = `Board Type Code NOT IN (T1,T2,T3,T4,T6,R1)` (đã có). Xem O_GSTT_66, O_GSTT_67.',
    sell_val                            Nullable(Decimal(23,2)) COMMENT 'Giá trị bán theo Phân loại NĐT của rổ chỉ số (khớp lệnh + thỏa thuận)',
    sell_vol                                     Nullable(Int64)         COMMENT '[MỚI 2026-10-16 v4.51, ma trận chiều × chỉ tiêu Nhóm 37 — O_GSTT_71] Khối lượng bán theo Phân loại NĐT của toàn bộ mã CK thuộc rổ chỉ số (khớp lệnh + thỏa thuận). [SỬA 2026-10-15 v4.49, BA cập nhật phân loại NĐT — thay quy tắc 2026-09-25 Tổ chức = (TC mua − TC bán) − (tự doanh mua − bán)] Mỗi phía mua/bán phân loại ĐỘC LẬP theo số tài khoản: Tự doanh = ký tự thứ 4 của số TK IN (P,E); Nước ngoài = ký tự thứ 4 IN (F,E); Cá nhân trong nước = bản ghi MỚI NHẤT của `discretionary_investment_account` (nguồn VSDC `open_investors`, dedupe theo số TK, mới nhất theo `event_dt` — Data Modeler xác nhận 2026-10-15) có `investment_account_tp_code` = 3; Tổ chức trong nước = 5 (trực tiếp, không còn phép trừ). Các phân loại KHÔNG loại trừ nhau (TK loại E tính ở cả Tự doanh lẫn Nước ngoài). Khớp lệnh = `Board Type Code NOT IN (T1,T2,T3,T4,T6,R1)` (đã có). Xem O_GSTT_66, O_GSTT_67.',
    matched_buy_val                     Nullable(Decimal(23,2)) COMMENT 'Giá trị mua khớp lệnh thuần theo Phân loại NĐT của rổ chỉ số',
    matched_sell_val                    Nullable(Decimal(23,2)) COMMENT 'Giá trị bán khớp lệnh thuần theo Phân loại NĐT của rổ chỉ số',
    negotiated_buy_val                  Nullable(Decimal(23,2)) COMMENT 'Giá trị mua thỏa thuận theo Phân loại NĐT của rổ chỉ số',
    negotiated_sell_val                 Nullable(Decimal(23,2)) COMMENT 'Giá trị bán thỏa thuận theo Phân loại NĐT của rổ chỉ số',
    market_index_val                    Nullable(Decimal(23,2)) COMMENT 'Điểm chỉ số cuối phiên — giá trị chung của rổ, lặp lại trên mọi Phân loại NĐT',
    index_change                        Nullable(Decimal(23,2)) COMMENT 'Thay đổi điểm chỉ số so với cuối ngày hôm trước — giá trị chung của rổ',
    index_percent_change                Nullable(Decimal(5,2))  COMMENT '% thay đổi điểm chỉ số so với cuối ngày hôm trước — giá trị chung của rổ',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                              Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                     Nullable(String)        COMMENT 'Cờ Y/N — ngày lịch có phải ngày thị trường thực sự mở cửa giao dịch hay không — từ Calendar Date Dimension',

    -- From: INDEX CONSTITUENT DIMENSION
    index_code                          Nullable(String)        COMMENT 'Mã rổ chỉ số — từ Index Constituent Dimension',
    index_id                            Nullable(String)        COMMENT 'Id chỉ số — từ Index Constituent Dimension',
    index_nm                            Nullable(String)        COMMENT 'Tên chuẩn của chỉ số (VN-Index/HNX-Index/VN30...) — từ Index Constituent Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), index_constituent_dim_id, investor_category_code)
COMMENT 'Flat table — Fact Investor Category Index Trading Snapshot × Calendar Date Dimension × Index Constituent Dimension'
;


-- ============================================================
-- 6. FACT: gstt_fct_major_shareholder_ownership_snpst_flat
--    Fact Major Shareholder Ownership Snapshot (Nhóm 35 — Sở hữu và giao dịch nội bộ)
--    Joins: Calendar Date × Public Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_major_shareholder_ownership_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Major Shareholder Ownership Snapshot
    snpst_dt_dim_id                     String                  COMMENT 'FK ngày tham số báo cáo',
    public_company_dim_id               Nullable(String)        COMMENT 'FK công ty đại chúng (nullable)',
    ticker_symbol                       String                  COMMENT 'Mã cổ phiếu (K_GSTT_100)',
    major_shareholder_ownership_id      String                  COMMENT 'Định danh cổ đông lớn (không chứa số giấy tờ — PII)',
    major_shareholder_nm                Nullable(String)        COMMENT 'Tên cổ đông (K_GSTT_101)',
    major_shareholder_identification_nbr Nullable(String)       COMMENT 'Khóa định danh cổ đông — số giấy tờ đã mã hóa tại nguồn, khóa kỹ thuật (K_GSTT_359 DEPRECATED 2026-10-15 — BA bỏ tooltip cổ đông → mã)',
    opening_share_quantity                       Nullable(Int64)         COMMENT '[MỚI 2026-10-15 v4.49, GSTT Nhóm 35 — BA bỏ SQL as-of, map 1:1 (K_GSTT_364, BA dòng 538)] Số cổ phiếu sở hữu cổ đông lớn ĐẦU KỲ (VSDC `begin_period_shares`) — lấy 1:1 từ `major_shareholder_ownership.opening_share_quantity`, KHÔNG chọn kỳ theo ngày tham số (khác `Ownership Share Quantity`/`Ownership Ratio`/`Ownership Update Date` as-of, K_GSTT_102/103/177 — nay chỉ còn dùng ở Nhóm 38). Dùng chung điều kiện chọn bản ghi (population) với các cột còn lại của Fact — xem O_GSTT_68.',
    opening_ownership_ratio                      Nullable(Decimal(7,4))  COMMENT '[MỚI 2026-10-15 v4.49, GSTT Nhóm 35 — BA bỏ SQL as-of, map 1:1 (K_GSTT_365, BA dòng 539)] Tỷ lệ sở hữu của cổ đông lớn ĐẦU KỲ (VSDC `begin_period_ratio`) — lấy 1:1 từ `major_shareholder_ownership.opening_ratio`, KHÔNG chọn kỳ theo ngày tham số (khác `Ownership Share Quantity`/`Ownership Ratio`/`Ownership Update Date` as-of, K_GSTT_102/103/177 — nay chỉ còn dùng ở Nhóm 38). Dùng chung điều kiện chọn bản ghi (population) với các cột còn lại của Fact — xem O_GSTT_68.',
    opening_balance_dt                           Nullable(Date)          COMMENT '[MỚI 2026-10-15 v4.49, GSTT Nhóm 35 — BA bỏ SQL as-of, map 1:1 (K_GSTT_366, BA dòng 540)] Ngày chốt số liệu báo cáo ĐẦU KỲ của cổ đông lớn (VSDC `begin_period_date`) — lấy 1:1 từ `major_shareholder_ownership.opening_balance_dt`, KHÔNG chọn kỳ theo ngày tham số (khác `Ownership Share Quantity`/`Ownership Ratio`/`Ownership Update Date` as-of, K_GSTT_102/103/177 — nay chỉ còn dùng ở Nhóm 38). Dùng chung điều kiện chọn bản ghi (population) với các cột còn lại của Fact — xem O_GSTT_68.',
    closing_share_quantity                       Nullable(Int64)         COMMENT '[MỚI 2026-10-15 v4.49, GSTT Nhóm 35 — BA bỏ SQL as-of, map 1:1 (K_GSTT_367, BA dòng 541)] Số cổ phiếu sở hữu cổ đông lớn CUỐI KỲ (VSDC `end_period_shares`) — lấy 1:1 từ `major_shareholder_ownership.closing_share_quantity`, KHÔNG chọn kỳ theo ngày tham số (khác `Ownership Share Quantity`/`Ownership Ratio`/`Ownership Update Date` as-of, K_GSTT_102/103/177 — nay chỉ còn dùng ở Nhóm 38). Dùng chung điều kiện chọn bản ghi (population) với các cột còn lại của Fact — xem O_GSTT_68.',
    closing_balance_dt                           Nullable(Date)          COMMENT '[MỚI 2026-10-15 v4.49, GSTT Nhóm 35 — BA bỏ SQL as-of, map 1:1 (K_GSTT_369, BA dòng 543)] Ngày chốt số liệu báo cáo CUỐI KỲ của cổ đông lớn (VSDC `end_period_date`) — lấy 1:1 từ `major_shareholder_ownership.closing_balance_dt`, KHÔNG chọn kỳ theo ngày tham số (khác `Ownership Share Quantity`/`Ownership Ratio`/`Ownership Update Date` as-of, K_GSTT_102/103/177 — nay chỉ còn dùng ở Nhóm 38). Dùng chung điều kiện chọn bản ghi (population) với các cột còn lại của Fact — xem O_GSTT_68.',
    ownership_share_quantity            Nullable(Int64)         COMMENT 'Số CP sở hữu tại ngày tham số (K_GSTT_102)',
    ownership_ratio                     Nullable(Decimal(7,4))  COMMENT 'Tỷ lệ sở hữu (K_GSTT_103)',
    closing_ownership_ratio             Nullable(Decimal(7,4))  COMMENT 'Tỷ lệ sở hữu cuối kỳ (K_GSTT_178, Nhóm 38)',
    ownership_update_dt                 Nullable(Date)          COMMENT 'Ngày cập nhật (K_GSTT_177)',
    position_code                       Array(String)           COMMENT 'Chức vụ người nội bộ (K_GSTT_104) — groupUniqArray; lọc has(), hiển thị arrayStringConcat()',
    src_stm_code                        String                  COMMENT 'Mã hệ thống nguồn',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                        Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension',

    -- From: PUBLIC COMPANY DIMENSION
    public_company_nm                   Nullable(String)        COMMENT 'Tên công ty — từ Public Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), ticker_symbol, major_shareholder_ownership_id)
COMMENT 'Flat table — Fact Major Shareholder Ownership Snapshot × Calendar Date × Public Company Dimension'
;


-- ============================================================
-- 6b. OPERATIONAL: gstt_opr_public_company_insider_ownership_flat
--    [MỚI 2026-10-01] Nhóm 35 — danh sách người nội bộ (vai trò NNB) của công ty đại chúng
--    kèm chức vụ + sở hữu (K_GSTT_354–358). 1 row / (công ty × người nội bộ), current-state.
--    Nguồn Atomic: pc_entity_role (driving) + legal_entity + pc_shareholding + legal_entity_position
--    + public_company. Không FK Star Schema — Operational denormalized, lọc theo equity_ticker_symbol.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_opr_public_company_insider_ownership_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Public Company Insider Ownership
    public_company_entity_role_code     String                  COMMENT 'PK — mã vai trò người nội bộ tại công ty (Bảng Tác nghiệp)',
    public_company_code                 String                  COMMENT 'Mã công ty đại chúng (khóa nghiệp vụ nội bộ)',
    equity_ticker_symbol                Nullable(String)        COMMENT 'Mã cổ phiếu — khóa lọc danh sách người nội bộ theo mã (K_GSTT_354)',
    legal_entity_code                   String                  COMMENT 'Mã người nội bộ — tooltip lọc theo mã này',
    legal_entity_nm                     Nullable(String)        COMMENT 'Tên người nội bộ (K_GSTT_354)',
    ownership_quantity                  Nullable(Int64)         COMMENT 'Số cổ phiếu người nội bộ nắm giữ (K_GSTT_356) — NULL nếu chưa có dòng sở hữu',
    ownership_ratio_percentage          Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ sở hữu của người nội bộ % (K_GSTT_357)',
    ownership_dt                        Nullable(Date)          COMMENT 'Ngày cập nhật sở hữu của người nội bộ (K_GSTT_358)',
    position_code                       Array(String)           COMMENT 'Mã chức vụ người nội bộ (K_GSTT_355) — groupUniqArray; lọc has()',
    position_nm                         Array(String)           COMMENT 'Tên chức vụ người nội bộ (K_GSTT_355, LOOKUP_VALUE_VN) — hiển thị arrayStringConcat()',
    src_stm_code                        String                  COMMENT 'Mã hệ thống nguồn — IDS_COMPANY_ENTITY_ROLE'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (public_company_entity_role_code)
COMMENT 'Flat table — Operational Public Company Insider Ownership (current-state, 1 row / công ty × người nội bộ)'
;


-- ============================================================
-- 6c. OPERATIONAL: gstt_opr_security_index_constituent_ref_flat
--    [MỚI 2026-10-06] Bảng tham chiếu mã thuộc rổ chỉ số — GSTT lookup Index Code ↔ Symbol ↔ ISIN Code (mã quốc tế).
--    1 row / (rổ chỉ số × mã CK thành viên ở ngày giao dịch mới nhất của rổ), current-state. Phục vụ chiều lọc Chi_so Nhóm 44/45 (K_GSTT_360–361): BI lọc sổ lệnh HNX security_symbol_code IN (symbol, isin_code). Không FK Star Schema.
--    Nguồn Atomic: index_constituent_snapshot (driving) + security_trading_snapshot (isin_code) + market_index_snapshot (index_nm). [SỬA 2026-10-09 v4.42] Các cột loại CK/sàn mã/phái sinh/phân loại/Ngành đã chuyển sang gstt_opr_security_ref_flat (6d).
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_opr_security_index_constituent_ref_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Operational Security Index Constituent Reference
    index_code                  String              COMMENT 'PK — mã rổ chỉ số (Index Code)',
    symbol                      String              COMMENT 'PK — mã chứng khoán thành viên rổ (khóa lookup GSTT)',
    index_constituent_snpst_code String             COMMENT 'GUID id dòng thành viên rổ ở ngày as-of (BK nguồn JAD_CSIDXINFOR.ID) — chỉ để truy vết',
    index_id                    Nullable(String)    COMMENT 'ID nội bộ của chỉ số (JAD_CSIDXINFOR.INDEXID)',
    index_nm                    Nullable(String)    COMMENT 'Tên chuẩn của rổ chỉ số (VN-Index/HNX-Index/VN30...) — NULL nếu thiếu Market Index Snapshot (O_GSTT_3)',
    floor_code                  Nullable(String)    COMMENT 'Mã sàn của CHỈ SỐ (02-HNX, 04-UPCOM, 10-HOSE) (sàn của mã CK: xem gstt_opr_security_ref_flat.floor_code)',
    add_dt                      Nullable(Date)      COMMENT 'Ngày mã chứng khoán được thêm vào rổ chỉ số',
    as_of_dt                    Date                COMMENT 'Ngày giao dịch (TradingDate) mới nhất của rổ chỉ số — mốc hiệu lực danh sách thành viên',
    isin_code                   Nullable(String)    COMMENT 'Mã quốc tế ISIN của mã chứng khoán — NULL nếu symbol chưa có trong MDDS.JAD_STOCKINFOR',
    src_stm_code                String              COMMENT 'Mã hệ thống nguồn — MDDS_JAD_CSIDXINFOR'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (index_code, symbol)
COMMENT 'Flat table — Operational Security Index Constituent Reference (danh mục chỉ số / thành viên rổ, current-state, 1 row / rổ chỉ số × mã CK thành viên; lookup Index Code ↔ Symbol ↔ ISIN Code)'
;


-- ============================================================
-- 6d. OPERATIONAL: gstt_opr_security_ref_flat
--    [MỚI 2026-10-09 v4.42] Danh mục mã chứng khoán — tách từ gstt_opr_security_index_constituent_ref_flat theo yêu cầu Data Modeler.
--    1 row / mã CK (bản ghi mới nhất của symbol trong MDDS.JAD_STOCKINFOR), current-state. Chưa có KPI BA tham chiếu (O_GSTT_63).
--    Nguồn Atomic: security_trading_snapshot (driving) + public_company/securities_company/cl_ids_business_line (Ngành, quy tắc K_GSTT_2).
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_opr_security_ref_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Operational Security Reference
    symbol                      String              COMMENT 'PK — mã chứng khoán (JAD_STOCKINFOR.SYMBOL)',
    security_full_nm            Nullable(String)    COMMENT 'Tên đầy đủ chứng khoán (tiếng Việt) — security_full_nm của bản ghi mới nhất của mã (JAD_STOCKINFOR)',
    isin_code                   Nullable(String)    COMMENT 'Mã quốc tế ISIN của mã chứng khoán',
    as_of_dt                    Date                COMMENT 'Ngày giao dịch (TradingDate) của bản ghi mới nhất của mã — mốc hiệu lực',
    stock_tp_code               Nullable(String)    COMMENT 'Loại chứng khoán thô theo sàn (HNX/UPCOM 1-6; HOSE 1-4) — phân biệt tab bảng giá',
    floor_code                  Nullable(String)    COMMENT 'Mã sàn của MÃ chứng khoán (02-HNX/04-UPCOM/10-HOSE/03-FDS)',
    derivative_product_nm       Nullable(String)    COMMENT 'Loại sản phẩm phái sinh (HĐTL + chứng khoán cơ sở; GB05/GB10 → TPCP) — chỉ sàn 02/04/03',
    security_class_nm           Nullable(String)    COMMENT 'Phân loại CK (nhãn tiếng Việt): Trái phiếu/Cổ phiếu/ETF/Chứng chỉ quỹ/Chứng quyền/Phái sinh/Khác (cùng quy tắc security_trading_snpst_dim.stock_tp_nm; O_GSTT_61)',
    industry_code               Nullable(String)    COMMENT 'Mã ngành cấp 1 (INDUSTRY_CD) — quy tắc K_GSTT_2; CTCK đại chúng fallback 07000',
    industry_nm                 Nullable(String)    COMMENT 'Tên ngành cấp 1 (NNKD) — quy tắc K_GSTT_2',
    src_stm_code                String              COMMENT 'Mã hệ thống nguồn — MDDS_JAD_STOCKINFOR'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (symbol)
COMMENT 'Flat table — Operational Security Reference (danh mục mã chứng khoán, current-state, 1 row / mã CK; tên CK, ISIN, loại CK, sàn, phái sinh, phân loại, ngành)'
;


-- ============================================================
-- 7. FACT: gstt_fct_hose_securities_trade_flat
--    [MỚI 2026-09-26] Nhóm 43 Data Explorer — kết xuất sổ lệnh khớp HOSE.
--    Fact Event, grain 1 row / giao dịch khớp (Securities Trade Code) / Trade Date.
--    Có cột PII (số tài khoản, tên chủ TK, PIN, tên trader) — bắt buộc phân quyền/masking BI (O_GSTT_36).
--    Joins: Calendar Date (trade_dt_dim_id JOIN) — không JOIN Dimension khác.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_hose_securities_trade_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact HOSE Securities Trade
    trade_dt_dim_id                         String                  COMMENT 'FK → Calendar Date Dimension (ngày giao dịch)',
    market_id_code                          Nullable(String)        COMMENT 'Mã thị trường chứng khoán.',
    security_symbol_code                    Nullable(String)        COMMENT 'Mã chứng khoán.',
    currency_code                           Nullable(String)        COMMENT 'Đơn vị tiền tệ.',
    board_tp_code                           Nullable(String)        COMMENT 'Loại bảng giao dịch.',
    securities_trade_code                   String                  COMMENT 'Mã giao dịch khớp — định danh grain 1 dòng/giao dịch. Số thứ tự giao dịch khớp lệnh được ghi nhận trên hệ thống Sàn trong ngày, theo từng mã chứng khoán (Trade ID / BK). BK.',
    trade_time                              Nullable(String)        COMMENT 'Thời gian diễn ra giao dịch khớp lệnh.',
    session_code                            Nullable(String)        COMMENT 'Phiên giao dịch.',
    execution_price                         Nullable(Decimal(23,2)) COMMENT 'Giá khớp lệnh thực tế của giao dịch.',
    execution_price_versus_ltp              Nullable(Decimal(23,2)) COMMENT 'Chênh lệch giữa giá khớp lệnh và giá khớp gần nhất của mã chứng khoán.',
    execution_vol                           Nullable(Int64)         COMMENT 'Khối lượng khớp lệnh.',
    execution_val                           Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch của lệnh khớp.',
    execution_last_traded_price             Nullable(Decimal(23,2)) COMMENT 'Giá khớp gần nhất của mã chứng khoán trên thị trường (Last Traded Price).',
    execution_new_high_low_price_indicator  Nullable(String)        COMMENT 'Đánh dấu nếu lệnh tạo giá khớp cao nhất hoặc thấp nhất mới trong ngày.',
    buy_order_dt                            Nullable(Date)          COMMENT 'Ngày đặt lệnh mua.',
    buy_order_time                          Nullable(String)        COMMENT 'Thời gian đặt lệnh mua.',
    buy_securities_order_code               Nullable(String)        COMMENT 'FK-BK đến Securities Order của lệnh mua (Order Accept Number — BK phụ HOSE).',
    buy_broker_id                           Nullable(String)        COMMENT 'Mã/số công ty chứng khoán thực hiện giao dịch mua.',
    buy_broker_nm                           Nullable(String)        COMMENT 'Tên công ty chứng khoán thực hiện giao dịch mua.',
    buy_account_pin_code                    Nullable(String)        COMMENT '[PII] Mã PIN của tài khoản mua. — hiển thị theo quyết định Data Modeler 2026-09-26, bắt buộc phân quyền/masking tầng BI',
    buy_account_nbr                         Nullable(String)        COMMENT '[PII] Mã/Số tài khoản giao dịch mua của nhà đầu tư. — hiển thị theo quyết định Data Modeler 2026-09-26, bắt buộc phân quyền/masking tầng BI',
    buy_account_holder_nm                   Nullable(String)        COMMENT '[PII] Tên tài khoản giao dịch mua của nhà đầu tư. — hiển thị theo quyết định Data Modeler 2026-09-26, bắt buộc phân quyền/masking tầng BI',
    buy_client_house_cl_code                Nullable(String)        COMMENT 'Phân loại lệnh khách hàng/công ty tự doanh của lệnh mua.',
    buy_investor_tp_code                    Nullable(String)        COMMENT 'Phân loại nhà đầu tư của lệnh mua (raw từ HOSE).',
    buy_foreign_investor_tp_code            Nullable(String)        COMMENT 'Phân loại đầu tư nước ngoài của lệnh mua.',
    buy_order_price                         Nullable(Decimal(23,2)) COMMENT 'Giá đặt mua.',
    buy_order_vol                           Nullable(Int64)         COMMENT 'Khối lượng đặt mua.',
    buy_trader_nbr                          Nullable(String)        COMMENT 'Mã/số định danh người thực hiện đặt mua.',
    buy_trader_nm                           Nullable(String)        COMMENT '[PII] Tên người thực hiện đặt mua. — hiển thị theo quyết định Data Modeler 2026-09-26, bắt buộc phân quyền/masking tầng BI',
    buy_reference_sequence_nbr              Nullable(String)        COMMENT 'Số tham chiếu theo thứ tự đặt mua trong ngày.',
    sell_order_dt                           Nullable(Date)          COMMENT 'Ngày đặt lệnh bán.',
    sell_order_time                         Nullable(String)        COMMENT 'Thời gian đặt lệnh bán.',
    sell_securities_order_code              Nullable(String)        COMMENT 'FK-BK đến Securities Order của lệnh bán (Order Accept Number — BK phụ HOSE).',
    sell_broker_id                          Nullable(String)        COMMENT 'Mã/số công ty chứng khoán thực hiện giao dịch bán.',
    sell_broker_nm                          Nullable(String)        COMMENT 'Tên công ty chứng khoán thực hiện giao dịch bán.',
    sell_account_pin_code                   Nullable(String)        COMMENT '[PII] Mã PIN của tài khoản bán. — hiển thị theo quyết định Data Modeler 2026-09-26, bắt buộc phân quyền/masking tầng BI',
    sell_account_nbr                        Nullable(String)        COMMENT '[PII] Mã/Số tài khoản giao dịch bán của nhà đầu tư. — hiển thị theo quyết định Data Modeler 2026-09-26, bắt buộc phân quyền/masking tầng BI',
    sell_account_holder_nm                  Nullable(String)        COMMENT '[PII] Tên tài khoản giao dịch bán của nhà đầu tư. — hiển thị theo quyết định Data Modeler 2026-09-26, bắt buộc phân quyền/masking tầng BI',
    sell_client_house_cl_code               Nullable(String)        COMMENT 'Phân loại lệnh khách hàng/công ty tự doanh của lệnh bán.',
    sell_investor_tp_code                   Nullable(String)        COMMENT 'Phân loại nhà đầu tư của lệnh bán (raw từ HOSE).',
    sell_foreign_investor_tp_code           Nullable(String)        COMMENT 'Phân loại đầu tư nước ngoài của lệnh bán.',
    sell_order_price                        Nullable(Decimal(23,2)) COMMENT 'Giá đặt bán.',
    sell_order_vol                          Nullable(Int64)         COMMENT 'Khối lượng đặt bán.',
    sell_trader_nbr                         Nullable(String)        COMMENT 'Mã/số định danh người thực hiện đặt bán.',
    sell_trader_nm                          Nullable(String)        COMMENT '[PII] Tên người thực hiện đặt bán. — hiển thị theo quyết định Data Modeler 2026-09-26, bắt buộc phân quyền/masking tầng BI',
    sell_reference_sequence_nbr             Nullable(String)        COMMENT 'Số tham chiếu theo thứ tự đặt bán trong ngày.',

    -- From: CALENDAR DATE DIMENSION
    trade_cdr_dt                            Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                         Nullable(String)        COMMENT 'Cờ Y/N ngày thị trường mở cửa giao dịch — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(trade_cdr_dt))
ORDER BY (assumeNotNull(trade_cdr_dt), securities_trade_code)
COMMENT 'Flat table — Fact HOSE Securities Trade × Calendar Date Dimension'
;


-- ============================================================
-- 8. FACT: gstt_fct_hnx_securities_trade_flat
--    [MỚI 2026-09-26] Nhóm 44 Data Explorer — kết xuất sổ lệnh khớp HNX.
--    Fact Event, grain 1 row / giao dịch khớp (Securities Trade Code) / Trade Date.
--    Có cột PII (số tài khoản, tên chủ TK) — bắt buộc phân quyền/masking BI (O_GSTT_36).
--    Joins: Calendar Date (trade_dt_dim_id JOIN) — không JOIN Dimension khác.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_hnx_securities_trade_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact HNX Securities Trade
    trade_dt_dim_id                         String                  COMMENT 'FK → Calendar Date Dimension (ngày giao dịch)',
    market_id_code                          Nullable(String)        COMMENT 'Mã thị trường chứng khoán.',
    board_tp_code                           Nullable(String)        COMMENT 'Loại bảng giao dịch.',
    security_symbol_code                    Nullable(String)        COMMENT 'Mã định danh của loại chứng khoán đang được giao dịch (unique).',
    securities_trade_code                   String                  COMMENT 'Mã giao dịch khớp — định danh grain 1 dòng/giao dịch. ID của giao dịch — dùng làm unique key, audit, tracking trade (BK). BK.',
    trade_time                              Nullable(String)        COMMENT 'Thời điểm giao dịch xảy ra.',
    execution_price                         Nullable(Decimal(23,2)) COMMENT 'Giá khớp của giao dịch.',
    execution_vol                           Nullable(Int64)         COMMENT 'Khối lượng giao dịch.',
    session_code                            Nullable(String)        COMMENT 'Mã phiên giao dịch.',
    sell_order_action_tp_code               Nullable(String)        COMMENT 'Loại hành động sửa/hủy của lệnh bên bán.',
    sell_broker_id                          Nullable(String)        COMMENT 'Mã định danh công ty chứng khoán thực hiện lệnh bán.',
    sell_account_nbr                        Nullable(String)        COMMENT '[PII] Số tài khoản giao dịch của khách hàng thực hiện lệnh bán. — hiển thị theo quyết định Data Modeler 2026-09-26, bắt buộc phân quyền/masking tầng BI',
    sell_order_tp_code                      Nullable(String)        COMMENT 'Loại lệnh của phía bán.',
    sell_order_condition_code               Nullable(String)        COMMENT 'Điều kiện hiệu lực và cách xử lý của lệnh bán.',
    sell_client_house_cl_code               Nullable(String)        COMMENT 'Lệnh bán của khách hàng hay tự doanh.',
    sell_investor_tp_code                   Nullable(String)        COMMENT 'Phân loại nhà đầu tư bán theo loại hình tổ chức/cá nhân (raw từ HNX).',
    sell_order_vol                          Nullable(Int64)         COMMENT 'Khối lượng đặt bán.',
    sell_order_price                        Nullable(Decimal(23,2)) COMMENT 'Giá đặt bán.',
    buy_broker_id                           Nullable(String)        COMMENT 'Mã/số công ty chứng khoán thực hiện giao dịch mua.',
    buy_order_action_tp_code                Nullable(String)        COMMENT 'Loại hành động sửa/hủy của lệnh bên mua.',
    buy_account_nbr                         Nullable(String)        COMMENT '[PII] Mã tài khoản thực hiện giao dịch mua. — hiển thị theo quyết định Data Modeler 2026-09-26, bắt buộc phân quyền/masking tầng BI',
    buy_order_tp_code                       Nullable(String)        COMMENT 'Loại lệnh mua.',
    buy_order_condition_code                Nullable(String)        COMMENT 'Điều kiện thực hiện lệnh mua.',
    buy_client_house_cl_code                Nullable(String)        COMMENT 'Lệnh mua của khách hàng hay tự doanh.',
    buy_investor_tp_code                    Nullable(String)        COMMENT 'Phân loại nhà đầu tư mua theo loại hình tổ chức/cá nhân (raw từ HNX).',
    buy_order_vol                           Nullable(Int64)         COMMENT 'Khối lượng đặt mua.',
    buy_order_price                         Nullable(Decimal(23,2)) COMMENT 'Giá đặt mua.',
    message_sequence_nbr                    Nullable(Int64)         COMMENT 'Số thứ tự message trong luồng dữ liệu (tăng dần từ 1).',
    sell_securities_order_code              Nullable(String)        COMMENT 'FK-BK đến Securities Order của lệnh bán (Order Reception Number — BK phụ HNX).',
    buy_securities_order_code               Nullable(String)        COMMENT 'FK-BK đến Securities Order của lệnh mua (Order Reception Number — BK phụ HNX).',
    sell_quote_request_tp_code              Nullable(String)        COMMENT 'Mã loại yêu cầu báo giá của bên bán (HNX RFQ).',
    buy_quote_request_tp_code               Nullable(String)        COMMENT 'Mã loại yêu cầu báo giá của bên mua (HNX RFQ).',
    execution_price_spread_first            Nullable(Decimal(23,2)) COMMENT 'Giá khớp của leg thứ nhất trong spread trade (HNX-only: phái sinh/repo 2 vế).',
    execution_price_spread_second           Nullable(Decimal(23,2)) COMMENT 'Giá khớp của leg thứ hai trong spread trade (HNX-only: phái sinh/repo 2 vế).',
    sell_foreign_investor_tp_code           Nullable(String)        COMMENT 'Phân loại loại hình nhà đầu tư nước ngoài tham gia giao dịch bán.',
    buy_foreign_investor_tp_code            Nullable(String)        COMMENT 'Phân loại loại hình nhà đầu tư nước ngoài tham gia giao dịch mua.',

    -- From: CALENDAR DATE DIMENSION
    trade_cdr_dt                            Nullable(Date)          COMMENT 'Ngày giao dịch — từ Calendar Date Dimension',
    is_trading_date                         Nullable(String)        COMMENT 'Cờ Y/N ngày thị trường mở cửa giao dịch — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(trade_cdr_dt))
ORDER BY (assumeNotNull(trade_cdr_dt), securities_trade_code)
COMMENT 'Flat table — Fact HNX Securities Trade × Calendar Date Dimension'
;


-- ==========================================================
-- 11. FACT: gstt_fct_hnx_securities_order_flat
--    fct_hnx_securities_order — sinh tự động từ master registry + Entities.csv
--    Joins: Calendar Date Dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_hnx_securities_order_flat ON CLUSTER 'my_cluster'
(
    -- From: FCT_HNX_SECURITIES_ORDER
    trade_dt_dim_id                              String                  COMMENT 'FK tới Calendar Date Dimension theo ngày giao dịch của lệnh',
    market_id_code                               String                  COMMENT 'Mã thị trường chứng khoán.',
    board_tp_code                                String                  COMMENT 'Loại bảng giao dịch.',
    security_symbol_code                         String                  COMMENT 'Mã định danh của loại chứng khoán (unique, thường là ISIN).',
    order_accept_time                            Nullable(String)        COMMENT 'Thời điểm KRX core system chấp nhận lệnh vào sổ lệnh (hh24misss).',
    broker_id                                    Nullable(String)        COMMENT 'Mã định danh thành viên giao dịch (công ty chứng khoán) do Sở giao dịch cấp.',
    side_ind                                     Nullable(String)        COMMENT 'Hướng lệnh: Mua/Bán.',
    account_nbr                                  Nullable(String)        COMMENT 'Mã định danh tài khoản giao dịch của nhà đầu tư tại công ty chứng khoán.',
    order_tp_code                                Nullable(String)        COMMENT 'Loại lệnh theo giá.',
    order_condition_code                         Nullable(String)        COMMENT 'Điều kiện thực hiện lệnh.',
    client_house_cl_code                         Nullable(String)        COMMENT 'Lệnh của khách hàng hay công ty tự doanh.',
    investor_tp_code                             Nullable(String)        COMMENT 'Phân loại nhà đầu tư theo loại hình tổ chức/cá nhân (raw từ HNX).',
    order_dt                                     Nullable(Date)          COMMENT 'Ngày mà lệnh được ghi nhận theo ngày giao dịch của hệ thống.',
    order_reject_reason_code                     Nullable(String)        COMMENT 'Mã lý do lệnh bị từ chối bởi hệ thống KRX.',
    order_vol                                    Nullable(Int64)         COMMENT 'Số lượng chứng khoán muốn mua hoặc bán trong lệnh.',
    order_price                                  Nullable(Decimal(23,2)) COMMENT 'Mức giá sẵn sàng mua hoặc bán (0 nếu Market/Fixed price/Cancel).',
    public_vol                                   Nullable(Int64)         COMMENT 'Phần khối lượng hiển thị công khai trên sổ lệnh (Iceberg order: pub_qty ≤ order_qty).',
    condition_price                              Nullable(Decimal(23,2)) COMMENT 'Mức giá điều kiện để kích hoạt lệnh Stop order.',
    order_reception_nbr                          Nullable(String)        COMMENT 'Số định danh của lệnh tại thời điểm hệ thống KRX tiếp nhận (duy nhất trong ngày, tăng dần theo issue).',
    original_order_reception_nbr                 Nullable(String)        COMMENT 'Order Reception Number của lệnh gốc mà một lệnh sửa/hủy đang tham chiếu tới.',
    original_order_tp_code                       Nullable(String)        COMMENT 'Loại lệnh của lệnh gốc trước khi bị sửa/hủy.',
    session_code                                 Nullable(String)        COMMENT 'Mã phiên giao dịch.',
    remaining_quantity                           Nullable(Int64)         COMMENT 'Khối lượng còn lại của lệnh chưa được khớp hoặc chưa bị hủy.',
    message_sequence_nbr                         Nullable(Int64)         COMMENT 'Số thứ tự message trong luồng dữ liệu (tăng dần từ 1).',
    order_action_tp_code                         Nullable(String)        COMMENT 'Loại hành động đối với lệnh: Mới / Sửa / Hủy.',
    quote_request_tp_code                        Nullable(String)        COMMENT 'Loại yêu cầu báo giá RFQ (HNX-only).',
    auto_cancel_reason_code                      Nullable(String)        COMMENT 'Mã xác định việc hủy lệnh tự động do cơ chế nào.',
    securities_order_code                        String                  COMMENT 'Mã định danh của lệnh giao dịch (BK chính). BK.',
    original_order_code                          Nullable(String)        COMMENT 'Order ID của lệnh gốc mà một lệnh sửa/hủy đang tham chiếu tới.',
    foreign_investor_tp_code                     Nullable(String)        COMMENT 'Phân loại loại hình nhà đầu tư nước ngoài.',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                       Nullable(Date)          COMMENT 'NK — ngày lịch dùng để join từ Fact — từ Calendar Date Dimension',
    year                                         Nullable(Int64)         COMMENT 'Năm (YYYY) — từ Calendar Date Dimension',
    quarter                                      Nullable(Int64)         COMMENT 'Quý (1–4) — từ Calendar Date Dimension',
    month                                        Nullable(Int64)         COMMENT 'Tháng (1–12) — từ Calendar Date Dimension',
    day_of_week                                  Nullable(Int64)         COMMENT 'Thứ trong tuần (1=Chủ nhật, 7=Thứ bảy) — từ Calendar Date Dimension',
    is_weekend                                   Nullable(String)        COMMENT '(Sửa 2026-07-17) Y nếu là ngày cuối tuần (thứ 7 hoặc CN), N nếu không — từ Calendar Date Dimension',
    holiday_flag                                 Nullable(String)        COMMENT '(Sửa 2026-07-20) Cờ đánh dấu ngày nghỉ — Y nếu là ngày nghỉ, N nếu không. Chỉ đánh dấu nghỉ/không nghỉ, không  — từ Calendar Date Dimension',
    is_trading_date                              Nullable(String)        COMMENT '(Sửa 2026-09-05, partial — thêm từ GSTT, yêu cầu thiết kế trực tiếp từ user) Y nếu ngày lịch là ngày giao dịch — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), securities_order_code)
COMMENT 'Flat table — fct_hnx_securities_order — sinh tự động từ master registry + Entities.csv'
;


-- ==========================================================
-- 12. FACT: gstt_fct_hose_securities_order_flat
--    fct_hose_securities_order — sinh tự động từ master registry + Entities.csv
--    Joins: Calendar Date Dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_fct_hose_securities_order_flat ON CLUSTER 'my_cluster'
(
    -- From: FCT_HOSE_SECURITIES_ORDER
    trade_dt_dim_id                              String                  COMMENT 'FK tới Calendar Date Dimension theo ngày giao dịch của lệnh',
    market_id_code                               String                  COMMENT 'Mã thị trường chứng khoán.',
    security_symbol_code                         String                  COMMENT 'Mã chứng khoán.',
    currency_code                                Nullable(String)        COMMENT 'Đơn vị tiền tệ.',
    board_tp_code                                String                  COMMENT 'Loại bảng giao dịch mà lệnh được phân loại vào.',
    order_dt                                     Nullable(Date)          COMMENT 'Ngày đặt lệnh của người thực hiện giao dịch.',
    order_time                                   Nullable(String)        COMMENT 'Thời gian đặt lệnh của người thực hiện giao dịch.',
    session_code                                 Nullable(String)        COMMENT 'Phiên giao dịch của thị trường chứng khoán.',
    order_action_tp_code                         Nullable(String)        COMMENT 'Loại hành động lệnh: N=Mới / M=Sửa / C=Hủy.',
    order_accept_id                              Nullable(String)        COMMENT 'Số thứ tự giao dịch được ghi nhận trên hệ thống của Sàn trong ngày giao dịch, theo từng mã chứng khoán (BK phụ',
    original_order_accept_id                     Nullable(String)        COMMENT 'Số thứ tự giao dịch ban đầu (trước chỉnh sửa) được ghi nhận trên hệ thống của Sàn.',
    side_ind                                     String                  COMMENT 'Loại lệnh: B=Buy / S=Sell.',
    broker_id                                    Nullable(String)        COMMENT 'Mã/số công ty chứng khoán.',
    broker_nm                                    Nullable(String)        COMMENT 'Tên công ty chứng khoán.',
    account_pin_code                             Nullable(String)        COMMENT 'Mã PIN của tài khoản giao dịch.',
    account_nbr                                  Nullable(String)        COMMENT 'Mã/Số tài khoản giao dịch của nhà đầu tư.',
    account_holder_nm                            Nullable(String)        COMMENT 'Tên nhà đầu tư/chủ tài khoản nhà đầu tư.',
    market_maker_order_ind                       Nullable(String)        COMMENT 'Lệnh đặt của nhà tạo lập thị trường.',
    client_house_cl_code                         Nullable(String)        COMMENT 'Phân loại lệnh khách hàng/công ty tự doanh.',
    investor_tp_code                             Nullable(String)        COMMENT 'Phân loại nhà đầu tư (raw từ HOSE).',
    foreign_investor_tp_code                     Nullable(String)        COMMENT 'Phân loại đầu tư nước ngoài.',
    order_tp_code                                Nullable(String)        COMMENT 'Loại lệnh theo giá.',
    order_price                                  Nullable(Decimal(23,2)) COMMENT 'Giá đặt lệnh.',
    order_vol                                    Nullable(Int64)         COMMENT 'Khối lượng đặt lệnh.',
    order_condition_code                         Nullable(String)        COMMENT 'Điều kiện thực hiện lệnh.',
    last_traded_price                            Nullable(Decimal(23,2)) COMMENT 'Giá khớp gần nhất trên thị trường (LTP).',
    execution_price                              Nullable(Decimal(23,2)) COMMENT 'Giá khớp lệnh thực tế.',
    immediate_matched_vol                        Nullable(Int64)         COMMENT 'Khối lượng khớp ngay khi hệ thống ghi nhận lệnh.',
    matched_vol                                  Nullable(Int64)         COMMENT 'Tổng khối lượng đã khớp của lệnh.',
    remaining_quantity                           Nullable(Int64)         COMMENT 'Khối lượng còn lại chưa khớp của lệnh.',
    order_spread                                 Nullable(Decimal(23,2)) COMMENT 'Chênh lệch giữa giá đặt lệnh và giá khớp gần nhất.',
    matched_ratio                                Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ khớp lệnh.',
    price_change_amt                             Nullable(Decimal(23,2)) COMMENT 'Mức tăng/giảm giá so với tham chiếu theo giá trị.',
    price_change_tick                            Nullable(Int64)         COMMENT 'Mức tăng/giảm theo bước giá.',
    new_high_low_price_ind                       Nullable(String)        COMMENT 'Đánh dấu nếu lệnh tạo giá cao nhất hoặc thấp nhất mới trong ngày.',
    order_status_code                            Nullable(String)        COMMENT 'Trạng thái của lệnh.',
    icd_bug_quantity                             Nullable(Int64)         COMMENT 'Khối lượng lỗi hoặc điều chỉnh trong hệ thống giao dịch.',
    expected_execution_price                     Nullable(Decimal(23,2)) COMMENT 'Giá khớp lệnh dự kiến, dựa trên các giao dịch thị trường trong ngày.',
    expected_execution_vol                       Nullable(Int64)         COMMENT 'Khối lượng khớp lệnh dự kiến, dựa trên các giao dịch thị trường trong ngày.',
    short_sell_tp_code                           Nullable(String)        COMMENT 'Phân loại lệnh bán khống.',
    trader_nbr                                   Nullable(String)        COMMENT 'Mã/số định danh người thực hiện giao dịch.',
    trader_nm                                    Nullable(String)        COMMENT 'Tên người thực hiện giao dịch.',
    reference_sequence_nbr                       Nullable(String)        COMMENT 'Số tham chiếu theo thứ tự giao dịch.',
    securities_order_code                        String                  COMMENT 'Mã định danh của lệnh đặt (Order ID 17 ký tự — BK chính). BK.',
    original_order_code                          Nullable(String)        COMMENT 'Mã định danh của lệnh đặt trước khi chỉnh sửa.',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                       Nullable(Date)          COMMENT 'NK — ngày lịch dùng để join từ Fact — từ Calendar Date Dimension',
    year                                         Nullable(Int64)         COMMENT 'Năm (YYYY) — từ Calendar Date Dimension',
    quarter                                      Nullable(Int64)         COMMENT 'Quý (1–4) — từ Calendar Date Dimension',
    month                                        Nullable(Int64)         COMMENT 'Tháng (1–12) — từ Calendar Date Dimension',
    day_of_week                                  Nullable(Int64)         COMMENT 'Thứ trong tuần (1=Chủ nhật, 7=Thứ bảy) — từ Calendar Date Dimension',
    is_weekend                                   Nullable(String)        COMMENT '(Sửa 2026-07-17) Y nếu là ngày cuối tuần (thứ 7 hoặc CN), N nếu không — từ Calendar Date Dimension',
    holiday_flag                                 Nullable(String)        COMMENT '(Sửa 2026-07-20) Cờ đánh dấu ngày nghỉ — Y nếu là ngày nghỉ, N nếu không. Chỉ đánh dấu nghỉ/không nghỉ, không  — từ Calendar Date Dimension',
    is_trading_date                              Nullable(String)        COMMENT '(Sửa 2026-09-05, partial — thêm từ GSTT, yêu cầu thiết kế trực tiếp từ user) Y nếu ngày lịch là ngày giao dịch — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), securities_order_code)
COMMENT 'Flat table — fct_hose_securities_order — sinh tự động từ master registry + Entities.csv'
;


-- ==========================================================
-- 18. OPERATIONAL: gstt_opr_trading_liquidity_explorer_flat
--    [MỚI 2026-10-16] Operational Trading Liquidity Explorer — bảng phẳng Data Explorer Nhóm 37 (O_GSTT_72)
--    Grain: 1 dòng / mã CK / chỉ số (hoặc dòng 'không theo rổ': index_code = '') / ngày giao dịch; không JOIN dimension.
--    Truy vấn KHÔNG chọn chiều Chỉ số phải lọc index_code = ''; cột idx_* / điểm chỉ số lặp lại trên mỗi mã CK của rổ → gộp MAX theo (index_code, trade_dt)
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.gstt_opr_trading_liquidity_explorer_flat ON CLUSTER 'my_cluster'
(
    -- From: FCT_TRADING_LIQUIDITY_EXPLORER_SNPST
    trade_dt                                     Date                    COMMENT 'Ngày giao dịch (ngày bản tin cuối ngày của mã chứng khoán) — một chiều của grain, lọc/nhóm theo ngày của Data ',
    symbol                                       String                  COMMENT 'Mã chứng khoán — một chiều của grain (1 dòng / mã CK / chỉ số / ngày).',
    index_code                                   String                  COMMENT 'Mã chỉ số (rổ) mà mã chứng khoán thuộc về trong ngày; chuỗi rỗng () = dòng không theo rổ dùng cho truy vấn khô',
    floor_code                                   Nullable(String)        COMMENT 'Mã sàn giao dịch của mã chứng khoán (HOSE/HNX/UPCOM/...) — chiều Sàn của Data Explorer.',
    stock_tp_nm                                  Nullable(String)        COMMENT 'Loại chứng khoán hiển thị (nhãn tiếng Việt, VD Cổ phiếu / Trái phiếu / Chứng chỉ quỹ), dẫn xuất theo mã sàn và mã loại chứng khoán — chiều Phân loại mã chứng khoán của Data Explorer.',
    business_line_level_1_code                   Nullable(String)        COMMENT 'Mã ngành cấp 1 của doanh nghiệp phát hành mã chứng khoán (chiều Ngành). Công ty chứng khoán đại chúng không có',
    classification_business_line_nm              Nullable(String)        COMMENT 'Tên ngành cấp 1 hiển thị (chiều Ngành). Công ty chứng khoán đại chúng không có ngành trong IDS thì dùng tên ng',
    reference_price                              Nullable(Decimal(23,2)) COMMENT 'Giá tham chiếu của mã chứng khoán trong ngày.',
    close_price                                  Nullable(Decimal(23,2)) COMMENT 'Giá đóng cửa của mã chứng khoán trong ngày.',
    open_price                                   Nullable(Decimal(23,2)) COMMENT 'Giá mở cửa của mã chứng khoán trong ngày.',
    high_price                                   Nullable(Decimal(23,2)) COMMENT 'Giá cao nhất của mã chứng khoán trong ngày.',
    low_price                                    Nullable(Decimal(23,2)) COMMENT 'Giá thấp nhất của mã chứng khoán trong ngày.',
    price_change                                 Nullable(Decimal(23,2)) COMMENT 'Mức thay đổi giá so với giá tham chiếu (+/-) trong ngày.',
    total_vol                                    Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch trong ngày của mã chứng khoán (gộp khớp lệnh và thỏa thuận).',
    total_val                                    Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch trong ngày của mã chứng khoán (gộp khớp lệnh và thỏa thuận).',
    total_matched_vol                            Nullable(Int64)         COMMENT 'Khối lượng khớp lệnh thuần trong ngày của mã chứng khoán (loại giao dịch thỏa thuận).',
    total_matched_val                            Nullable(Decimal(23,2)) COMMENT 'Giá trị khớp lệnh thuần trong ngày của mã chứng khoán (loại giao dịch thỏa thuận).',
    total_negotiated_vol                         Nullable(Int64)         COMMENT 'Khối lượng giao dịch thỏa thuận trong ngày của mã chứng khoán.',
    total_negotiated_val                         Nullable(Decimal(23,2)) COMMENT 'Giá trị giao dịch thỏa thuận trong ngày của mã chứng khoán.',
    foreign_buy_vol                              Nullable(Int64)         COMMENT 'Khối lượng mua của nhà đầu tư nước ngoài trong ngày — ký tự thứ 4 của số tài khoản mua IN (F,E).',
    foreign_sell_vol                             Nullable(Int64)         COMMENT 'Khối lượng bán của nhà đầu tư nước ngoài trong ngày — ký tự thứ 4 của số tài khoản bán IN (F,E).',
    foreign_buy_val                              Nullable(Decimal(23,2)) COMMENT 'Giá trị mua của nhà đầu tư nước ngoài trong ngày — ký tự thứ 4 của số tài khoản mua IN (F,E).',
    foreign_sell_val                             Nullable(Decimal(23,2)) COMMENT 'Giá trị bán của nhà đầu tư nước ngoài trong ngày — ký tự thứ 4 của số tài khoản bán IN (F,E).',
    proprietary_buy_vol                          Nullable(Int64)         COMMENT 'Khối lượng mua tự doanh trong ngày — ký tự thứ 4 của số tài khoản mua IN (P,E).',
    proprietary_sell_vol                         Nullable(Int64)         COMMENT 'Khối lượng bán tự doanh trong ngày — ký tự thứ 4 của số tài khoản bán IN (P,E).',
    proprietary_buy_val                          Nullable(Decimal(23,2)) COMMENT 'Giá trị mua tự doanh trong ngày — ký tự thứ 4 của số tài khoản mua IN (P,E).',
    proprietary_sell_val                         Nullable(Decimal(23,2)) COMMENT 'Giá trị bán tự doanh trong ngày — ký tự thứ 4 của số tài khoản bán IN (P,E).',
    domestic_individual_buy_val                  Nullable(Decimal(23,2)) COMMENT 'Giá trị mua của nhà đầu tư cá nhân trong nước (tài khoản loại 3) trong ngày — gồm khớp lệnh và thỏa thuận; phâ',
    domestic_individual_buy_vol                  Nullable(Int64)         COMMENT 'Khối lượng mua của nhà đầu tư cá nhân trong nước (tài khoản loại 3) trong ngày — gồm khớp lệnh và thỏa thuận; ',
    domestic_individual_sell_val                 Nullable(Decimal(23,2)) COMMENT 'Giá trị bán của nhà đầu tư cá nhân trong nước (tài khoản loại 3) trong ngày — gồm khớp lệnh và thỏa thuận; phâ',
    domestic_individual_sell_vol                 Nullable(Int64)         COMMENT 'Khối lượng bán của nhà đầu tư cá nhân trong nước (tài khoản loại 3) trong ngày — gồm khớp lệnh và thỏa thuận; ',
    domestic_institution_buy_val                 Nullable(Decimal(23,2)) COMMENT 'Giá trị mua của nhà đầu tư tổ chức trong nước (tài khoản loại 5) trong ngày — gồm khớp lệnh và thỏa thuận; phâ',
    domestic_institution_buy_vol                 Nullable(Int64)         COMMENT 'Khối lượng mua của nhà đầu tư tổ chức trong nước (tài khoản loại 5) trong ngày — gồm khớp lệnh và thỏa thuận; ',
    domestic_institution_sell_val                Nullable(Decimal(23,2)) COMMENT 'Giá trị bán của nhà đầu tư tổ chức trong nước (tài khoản loại 5) trong ngày — gồm khớp lệnh và thỏa thuận; phâ',
    domestic_institution_sell_vol                Nullable(Int64)         COMMENT 'Khối lượng bán của nhà đầu tư tổ chức trong nước (tài khoản loại 5) trong ngày — gồm khớp lệnh và thỏa thuận; ',
    outstanding_share_quantity                   Nullable(Int64)         COMMENT 'Số cổ phiếu đang lưu hành của mã chứng khoán tại ngày giao dịch — dùng tính vốn hóa, EPS, P/E, P/B.',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2)) COMMENT 'Lợi nhuận sau thuế 4 quý gần nhất (TTM) của doanh nghiệp phát hành theo báo cáo tài chính đã duyệt — dùng tính',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2)) COMMENT 'Lợi nhuận sau thuế 4 quý gần nhất (TTM) của công ty chứng khoán đại chúng theo báo cáo nghiệp vụ — dự phòng ch',
    owner_equity                                 Nullable(Decimal(23,2)) COMMENT 'Vốn chủ sở hữu của doanh nghiệp phát hành tại kỳ báo cáo gần nhất theo báo cáo tài chính đã duyệt — dùng tính ',
    securities_company_owner_equity              Nullable(Decimal(23,2)) COMMENT 'Vốn chủ sở hữu của công ty chứng khoán đại chúng theo báo cáo nghiệp vụ — dự phòng cho P/B khi mã không có báo',
    prior_market_cap                             Nullable(Decimal(23,2)) COMMENT 'Vốn hóa thị trường của mã chứng khoán ở phiên giao dịch trước (giá đóng cửa × số cổ phiếu đang lưu hành) — dùn',
    prior_free_float_market_cap                  Nullable(Decimal(23,2)) COMMENT 'Vốn hóa tự do chuyển nhượng của mã chứng khoán ở phiên giao dịch trước (giá đóng cửa × số cổ phiếu tự do chuyể',
    market_index_val                             Nullable(Decimal(23,2)) COMMENT 'Điểm đóng cửa của chỉ số trong ngày. Cấp chỉ số × ngày — lặp lại trên mỗi mã CK của rổ; NULL ở dòng không theo',
    index_change                                 Nullable(Decimal(23,2)) COMMENT 'Thay đổi điểm của chỉ số so với phiên trước. Cấp chỉ số × ngày — lặp lại trên mỗi mã CK của rổ; NULL ở dòng kh',
    index_percent_change                         Nullable(Decimal(5,2))  COMMENT 'Phần trăm thay đổi của chỉ số so với phiên trước. Cấp chỉ số × ngày — lặp lại trên mỗi mã CK của rổ; NULL ở dò',
    prior_index                                  Nullable(Decimal(23,2)) COMMENT 'Điểm chỉ số phiên trước. Cấp chỉ số × ngày — lặp lại trên mỗi mã CK của rổ; NULL ở dòng không theo rổ.',
    advances_count                               Nullable(Int64)         COMMENT 'Số mã tăng giá trong rổ chỉ số. Cấp chỉ số × ngày — lặp lại trên mỗi mã CK của rổ; NULL ở dòng không theo rổ.',
    declines_count                               Nullable(Int64)         COMMENT 'Số mã giảm giá trong rổ chỉ số. Cấp chỉ số × ngày — lặp lại trên mỗi mã CK của rổ; NULL ở dòng không theo rổ.',
    no_change_count                              Nullable(Int64)         COMMENT 'Số mã đứng giá trong rổ chỉ số. Cấp chỉ số × ngày — lặp lại trên mỗi mã CK của rổ; NULL ở dòng không theo rổ.',
    ceiling_count                                Nullable(Int64)         COMMENT 'Số mã tăng trần trong rổ chỉ số. Cấp chỉ số × ngày — lặp lại trên mỗi mã CK của rổ; NULL ở dòng không theo rổ.',
    floor_count                                  Nullable(Int64)         COMMENT 'Số mã giảm sàn trong rổ chỉ số. Cấp chỉ số × ngày — lặp lại trên mỗi mã CK của rổ; NULL ở dòng không theo rổ.',
    idx_total_matched_vol                        Nullable(Int64)         COMMENT 'Tổng khối lượng khớp lệnh thuần (loại thỏa thuận) của toàn bộ mã CK thành viên rổ chỉ số trong ngày. Lặp lại t',
    idx_total_matched_val                        Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị khớp lệnh thuần (loại thỏa thuận) của toàn bộ mã CK thành viên rổ chỉ số trong ngày. Lặp lại trên',
    idx_total_negotiated_vol                     Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch thỏa thuận của toàn bộ mã CK thành viên rổ chỉ số trong ngày. Lặp lại trên mỗi mã CK',
    idx_total_negotiated_val                     Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch thỏa thuận của toàn bộ mã CK thành viên rổ chỉ số trong ngày. Lặp lại trên mỗi mã CK củ',
    idx_market_cap                               Nullable(Decimal(23,2)) COMMENT 'Vốn hóa thị trường của rổ chỉ số = tổng (giá đóng cửa × số cổ phiếu đang lưu hành) của các mã thành viên. Lặp ',
    idx_free_float_market_cap                    Nullable(Decimal(23,2)) COMMENT 'Vốn hóa tự do chuyển nhượng của rổ chỉ số = tổng (giá đóng cửa × số cổ phiếu tự do chuyển nhượng) của các mã t',
    idx_pe                                       Nullable(Decimal(10,2)) COMMENT 'P/E của rổ chỉ số = tổng vốn hóa các mã thành viên / tổng LNST TTM, làm tròn 2 chữ số. Lặp lại trên mỗi mã CK ',
    idx_pb                                       Nullable(Decimal(10,2)) COMMENT 'P/B của rổ chỉ số = tổng vốn hóa các mã thành viên / tổng vốn chủ sở hữu, làm tròn 2 chữ số. Lặp lại trên mỗi ',
    idx_prior_market_cap                         Nullable(Decimal(23,2)) COMMENT 'Vốn hóa thị trường của rổ chỉ số ở phiên giao dịch trước — dùng tính điểm đóng góp vào chỉ số. Lặp lại trên mỗ',
    idx_prior_free_float_market_cap              Nullable(Decimal(23,2)) COMMENT 'Vốn hóa tự do chuyển nhượng của rổ chỉ số ở phiên giao dịch trước — dùng tính điểm đóng góp vào chỉ số. Lặp lạ',
    idx_foreign_buy_val                          Nullable(Decimal(23,2)) COMMENT 'Giá trị mua của nhà đầu tư nước ngoài trong toàn rổ chỉ số — ký tự thứ 4 của số tài khoản IN (F,E), gồm khớp l',
    idx_foreign_buy_vol                          Nullable(Int64)         COMMENT 'Khối lượng mua của nhà đầu tư nước ngoài trong toàn rổ chỉ số — ký tự thứ 4 của số tài khoản IN (F,E), gồm khớ',
    idx_foreign_sell_val                         Nullable(Decimal(23,2)) COMMENT 'Giá trị bán của nhà đầu tư nước ngoài trong toàn rổ chỉ số — ký tự thứ 4 của số tài khoản IN (F,E), gồm khớp l',
    idx_foreign_sell_vol                         Nullable(Int64)         COMMENT 'Khối lượng bán của nhà đầu tư nước ngoài trong toàn rổ chỉ số — ký tự thứ 4 của số tài khoản IN (F,E), gồm khớ',
    idx_proprietary_buy_val                      Nullable(Decimal(23,2)) COMMENT 'Giá trị mua của tự doanh (ký tự thứ 4 của số TK IN (P,E)) trong toàn rổ chỉ số, theo ngày — gồm khớp lệnh và t',
    idx_proprietary_buy_vol                      Nullable(Int64)         COMMENT 'Khối lượng mua của tự doanh (ký tự thứ 4 của số TK IN (P,E)) trong toàn rổ chỉ số, theo ngày — gồm khớp lệnh v',
    idx_proprietary_sell_val                     Nullable(Decimal(23,2)) COMMENT 'Giá trị bán của tự doanh (ký tự thứ 4 của số TK IN (P,E)) trong toàn rổ chỉ số, theo ngày — gồm khớp lệnh và t',
    idx_proprietary_sell_vol                     Nullable(Int64)         COMMENT 'Khối lượng bán của tự doanh (ký tự thứ 4 của số TK IN (P,E)) trong toàn rổ chỉ số, theo ngày — gồm khớp lệnh v',
    idx_domestic_individual_buy_val              Nullable(Decimal(23,2)) COMMENT 'Giá trị mua của nhà đầu tư cá nhân trong nước (tài khoản loại 3) trong toàn rổ chỉ số, theo ngày — gồm khớp lệ',
    idx_domestic_individual_buy_vol              Nullable(Int64)         COMMENT 'Khối lượng mua của nhà đầu tư cá nhân trong nước (tài khoản loại 3) trong toàn rổ chỉ số, theo ngày — gồm khớp',
    idx_domestic_individual_sell_val             Nullable(Decimal(23,2)) COMMENT 'Giá trị bán của nhà đầu tư cá nhân trong nước (tài khoản loại 3) trong toàn rổ chỉ số, theo ngày — gồm khớp lệ',
    idx_domestic_individual_sell_vol             Nullable(Int64)         COMMENT 'Khối lượng bán của nhà đầu tư cá nhân trong nước (tài khoản loại 3) trong toàn rổ chỉ số, theo ngày — gồm khớp',
    idx_domestic_institution_buy_val             Nullable(Decimal(23,2)) COMMENT 'Giá trị mua của nhà đầu tư tổ chức trong nước (tài khoản loại 5) trong toàn rổ chỉ số, theo ngày — gồm khớp lệ',
    idx_domestic_institution_buy_vol             Nullable(Int64)         COMMENT 'Khối lượng mua của nhà đầu tư tổ chức trong nước (tài khoản loại 5) trong toàn rổ chỉ số, theo ngày — gồm khớp',
    idx_domestic_institution_sell_val            Nullable(Decimal(23,2)) COMMENT 'Giá trị bán của nhà đầu tư tổ chức trong nước (tài khoản loại 5) trong toàn rổ chỉ số, theo ngày — gồm khớp lệ',
    idx_domestic_institution_sell_vol            Nullable(Int64)         COMMENT 'Khối lượng bán của nhà đầu tư tổ chức trong nước (tài khoản loại 5) trong toàn rổ chỉ số, theo ngày — gồm khớp',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu',

    -- [MỚI 2026-10-19] Tên chỉ số — đặt CUỐI để khớp ALTER TABLE ADD COLUMN (INSERT ... SELECT theo vị trí)
    index_nm                                     Nullable(String)        COMMENT 'Tên chuẩn của chỉ số (rổ) — VN-Index/HNX-Index/UPCoM-Index/VN30... — dùng hiển thị chiều Chỉ số của Data Explorer. Lấy từ Market Index Snapshot qua đẳng thức Market Code = Index Code (không join theo tên). Cấp chỉ số × ngày — lặp lại trên mỗi mã CK của rổ; NULL ở dòng không theo rổ (index_code = ) hoặc khi Market Index Snapshot không có market_code tương ứng trong ngày.',
    free_float_market_cap                        Nullable(Decimal(23,2)) COMMENT 'Vốn hóa mã CK tại ngày giao dịch = Giá tính vốn hóa × Số cổ phiếu tự do chuyển nhượng (cùng định nghĩa với Fact Stock Portfolio Snapshot.Free Float Market Cap). Giá tính vốn hóa: HNX/HOSE = giá đóng cửa; UPCOM (floor_code 04) = giá bình quân VWAP ghi trên bản tin cuối ngày của PHIÊN GIAO DỊCH KẾ TIẾP (T+1) — NULL khi chưa có VWAP T+1 (chưa tính vốn hóa), VWAP = 0 thì lấy giá tham chiếu ngày T. Tính trên tập mỗi mã CK 1 dòng/ngày TRƯỚC khi nhân dòng theo rổ chỉ số. [MỚI 2026-10-30 v4.58, BA GSTT — Data Modeler chọn thêm cột mức mã CK, O_GSTT_78 mục (a)].',
    market_cap                                   Nullable(Decimal(23,2)) COMMENT 'Vốn hóa mã CK tại ngày giao dịch = Giá tính vốn hóa × Số cổ phiếu đang lưu hành (cùng định nghĩa với Fact Stock Portfolio Snapshot.Market Cap). Giá tính vốn hóa: HNX/HOSE = giá đóng cửa; UPCOM (floor_code 04) = giá bình quân VWAP ghi trên bản tin cuối ngày của PHIÊN GIAO DỊCH KẾ TIẾP (T+1) — NULL khi chưa có VWAP T+1 (chưa tính vốn hóa), VWAP = 0 thì lấy giá tham chiếu ngày T. Tính trên tập mỗi mã CK 1 dòng/ngày TRƯỚC khi nhân dòng theo rổ chỉ số. [MỚI 2026-10-30 v4.58, BA GSTT — Data Modeler chọn thêm cột mức mã CK, O_GSTT_78 mục (a)].',
    first_trading_dt                             Nullable(Date)          COMMENT 'Ngày giao dịch đầu tiên của mã CK (MDDS JAD_STOCKINFOR.firstTradingDate); cùng định nghĩa Security Trading Snapshot Dimension. [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)]',
    listed_share_count                           Nullable(Int64)         COMMENT 'Khối lượng cổ phiếu niêm yết hiện tại của mã CK (MDDS JAD_STOCKINFOR.listedShare); cùng định nghĩa Security Trading Snapshot Dimension. [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)]',
    net_profit_after_tax                         Nullable(Decimal(23,2)) COMMENT '[SỬA 2026-09-19, dev report SIT — sync 7 phát hiện] Cùng 3 sửa như Revenue (bỏ violation_report, bỏ công thức lùi-kỳ cứng, chốt 1 báo cáo/kỳ trước khi xếp hạng). LNST point-in-time theo BCKQKD (row_desc 60 DN/BH · 21 TD) — khác Net Profit After Tax TTM (dùng riêng cho P/E/EPS ở dashboard Định giá thị trường). Nguồn Atomic: pc_report_submission, fr_value, fr_catalog, fr_row_template, fr_column_template. [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)] Clone từ Fact Stock Portfolio Snapshot.Net Profit After Tax — cùng etl_logic.',
    odd_lot_matched_val                          Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch lô lẻ khớp lệnh cổ phiếu/CCQ (Market ID UPX/STX/STK/STO; Board G4) của mã CK trong ngày — cùng định nghĩa cột Fact Stock Portfolio Snapshot.Odd Lot Matched Value. Mức mã CK (không có biến thể theo rổ chỉ số). [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)]',
    odd_lot_matched_vol                          Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch lô lẻ khớp lệnh cổ phiếu/CCQ (Market ID UPX/STX/STK/STO; Board G4) của mã CK trong ngày — cùng định nghĩa cột Fact Stock Portfolio Snapshot.Odd Lot Matched Volume. Mức mã CK (không có biến thể theo rổ chỉ số). [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)]',
    odd_lot_negotiated_val                       Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch lô lẻ thỏa thuận cổ phiếu/CCQ (Market ID UPX/STX/STK/STO; Board T4) của mã CK trong ngày — cùng định nghĩa cột Fact Stock Portfolio Snapshot.Odd Lot Negotiated Value. Mức mã CK (không có biến thể theo rổ chỉ số). [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)]',
    odd_lot_negotiated_vol                       Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch lô lẻ thỏa thuận cổ phiếu/CCQ (Market ID UPX/STX/STK/STO; Board T4) của mã CK trong ngày — cùng định nghĩa cột Fact Stock Portfolio Snapshot.Odd Lot Negotiated Volume. Mức mã CK (không có biến thể theo rổ chỉ số). [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)]',
    owner_equity_average_4_quarter               Nullable(Decimal(23,2)) COMMENT '[MOI 2026-09-29, sua sau review Nhom 34 — dao nguoc quyet dinh 2026-09-04] VCSH binh quan cong cua 4 ky BCTC gan nhat (trung binh 4 gia tri roi rac theo tung quy, KHONG phai giu nguyen VCSH 1 quy nhu quyet dinh cu da xac nhan sai qua SQL tham khao BA). NULL neu khong du 4 ky. Dung cho tu so K_GSTT_113 (Gia tri so sach binh quan 4 quy gan nhat). [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)] Clone từ Fact Stock Portfolio Snapshot.Owner Equity Average 4 Quarter — cùng etl_logic.',
    owner_equity_weighted_average_outstanding_share_quantity Nullable(Decimal(23,4)) COMMENT '[MOI 2026-09-29, sua sau review Nhom 34] WAOS tinh trong dung khung ngay cua ky BCTC VCSH gan nhat (ky rieng cua Owner Equity, xep hang doc lap voi ky LNST — co the lech ky). Dung cho mau so K_GSTT_112 (Gia tri so sach quy gan nhat). [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)] Clone từ Fact Stock Portfolio Snapshot.Owner Equity Weighted Average Outstanding Share Quantity — cùng etl_logic.',
    owner_equity_weighted_average_outstanding_share_quantity_ttm Nullable(Decimal(23,4)) COMMENT '[MOI 2026-09-29, sua sau review Nhom 34] WAOS tinh trong khung ngay rong hon cua 4 ky VCSH gan nhat (xep hang doc lap voi 4 ky LNST). Dung cho mau so K_GSTT_113 (Gia tri so sach binh quan 4 quy gan nhat). [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)] Clone từ Fact Stock Portfolio Snapshot.Owner Equity Weighted Average Outstanding Share Quantity TTM — cùng etl_logic.',
    round_lot_matched_val                        Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch lô chẵn khớp lệnh cổ phiếu/CCQ (Market ID UPX/STX/STK/STO; Board G1,G2,G3,G6,G7,G8) của mã CK trong ngày — cùng định nghĩa cột Fact Stock Portfolio Snapshot.Round Lot Matched Value. Mức mã CK (không có biến thể theo rổ chỉ số). [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)]',
    round_lot_matched_vol                        Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch lô chẵn khớp lệnh cổ phiếu/CCQ (Market ID UPX/STX/STK/STO; Board G1,G2,G3,G6,G7,G8) của mã CK trong ngày — cùng định nghĩa cột Fact Stock Portfolio Snapshot.Round Lot Matched Volume. Mức mã CK (không có biến thể theo rổ chỉ số). [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)]',
    round_lot_negotiated_val                     Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch lô chẵn thỏa thuận cổ phiếu/CCQ (Market ID UPX/STX/STK/STO; Board T1,T2,T3,T6,R1) của mã CK trong ngày — cùng định nghĩa cột Fact Stock Portfolio Snapshot.Round Lot Negotiated Value. Mức mã CK (không có biến thể theo rổ chỉ số). [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)]',
    round_lot_negotiated_vol                     Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch lô chẵn thỏa thuận cổ phiếu/CCQ (Market ID UPX/STX/STK/STO; Board T1,T2,T3,T6,R1) của mã CK trong ngày — cùng định nghĩa cột Fact Stock Portfolio Snapshot.Round Lot Negotiated Volume. Mức mã CK (không có biến thể theo rổ chỉ số). [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)]',
    weighted_average_outstanding_share_quantity  Nullable(Decimal(23,4)) COMMENT '[MOI 2026-09-29, sua sau review Nhom 34] So co phieu dang luu hanh binh quan gia quyen theo so ngay hieu luc cua tung ban ghi VSDC (WAOS), tinh trong dung khung ngay cua ky BCTC LNST gan nhat (cung ky da chon cho Net Profit After Tax). Thay cho AVG theo ngay giao dich trong quy lich (thiet ke cu, sai, neo vao K_GSTT_30 da DEPRECATED). Dung cho K_GSTT_109 (hien thi) va mau so K_GSTT_110 (EPS quy gan nhat). [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)] Clone từ Fact Stock Portfolio Snapshot.Weighted Average Outstanding Share Quantity — cùng etl_logic.',
    weighted_average_outstanding_share_quantity_ttm Nullable(Decimal(23,4)) COMMENT '[MOI 2026-09-29, sua sau review Nhom 34] WAOS tinh trong khung ngay rong hon, trai tu dau ky som nhat den cuoi ky gan nhat cua 4 ky LNST TTM (cung 4 ky da chon cho Net Profit After Tax TTM). Dung cho mau so K_GSTT_111 (EPS binh quan 4 quy gan nhat). [SỬA 2026-10-30 v4.58, O_GSTT_78 mục (b) — BA đổi cách chọn kỳ LNST TTM] Kỳ gần nhất đã công bố tính đến ngày giao dịch là NĂM (rpt_quarter = 5) → LNST kỳ năm; là QUÝ → cộng 4 quý gần nhất, phải có đủ 4 quý (trước đây chỉ rpt_quarter 1–4 và đủ đúng 4 kỳ). Điều kiện thời gian vẫn là submission_dt <= ngày giao dịch (BA dùng ngày kết thúc kỳ <= ngày xem). [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–834, O_GSTT_78 mục (d)] Clone từ Fact Stock Portfolio Snapshot.Weighted Average Outstanding Share Quantity TTM — cùng etl_logic.',
    idx_odd_lot_matched_val                      Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch lô lẻ khớp lệnh của toàn bộ mã CK thành viên rổ chỉ số trong ngày (Market ID UPX/STX/STK/STO; Board G4). Lặp lại trên mỗi mã CK của rổ — gộp bằng MAX theo chỉ số + ngày, không SUM; NULL ở dòng không theo rổ. [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–818 độ chi tiết Mã CK/Chỉ số, O_GSTT_78]',
    idx_odd_lot_matched_vol                      Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch lô lẻ khớp lệnh của toàn bộ mã CK thành viên rổ chỉ số trong ngày (Market ID UPX/STX/STK/STO; Board G4). Lặp lại trên mỗi mã CK của rổ — gộp bằng MAX theo chỉ số + ngày, không SUM; NULL ở dòng không theo rổ. [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–818 độ chi tiết Mã CK/Chỉ số, O_GSTT_78]',
    idx_odd_lot_negotiated_val                   Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch lô lẻ thỏa thuận của toàn bộ mã CK thành viên rổ chỉ số trong ngày (Market ID UPX/STX/STK/STO; Board T4). Lặp lại trên mỗi mã CK của rổ — gộp bằng MAX theo chỉ số + ngày, không SUM; NULL ở dòng không theo rổ. [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–818 độ chi tiết Mã CK/Chỉ số, O_GSTT_78]',
    idx_odd_lot_negotiated_vol                   Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch lô lẻ thỏa thuận của toàn bộ mã CK thành viên rổ chỉ số trong ngày (Market ID UPX/STX/STK/STO; Board T4). Lặp lại trên mỗi mã CK của rổ — gộp bằng MAX theo chỉ số + ngày, không SUM; NULL ở dòng không theo rổ. [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–818 độ chi tiết Mã CK/Chỉ số, O_GSTT_78]',
    idx_round_lot_matched_val                    Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch lô chẵn khớp lệnh của toàn bộ mã CK thành viên rổ chỉ số trong ngày (Market ID UPX/STX/STK/STO; Board G1,G2,G3,G6,G7,G8). Lặp lại trên mỗi mã CK của rổ — gộp bằng MAX theo chỉ số + ngày, không SUM; NULL ở dòng không theo rổ. [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–818 độ chi tiết Mã CK/Chỉ số, O_GSTT_78]',
    idx_round_lot_matched_vol                    Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch lô chẵn khớp lệnh của toàn bộ mã CK thành viên rổ chỉ số trong ngày (Market ID UPX/STX/STK/STO; Board G1,G2,G3,G6,G7,G8). Lặp lại trên mỗi mã CK của rổ — gộp bằng MAX theo chỉ số + ngày, không SUM; NULL ở dòng không theo rổ. [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–818 độ chi tiết Mã CK/Chỉ số, O_GSTT_78]',
    idx_round_lot_negotiated_val                 Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch lô chẵn thỏa thuận của toàn bộ mã CK thành viên rổ chỉ số trong ngày (Market ID UPX/STX/STK/STO; Board T1,T2,T3,T6,R1). Lặp lại trên mỗi mã CK của rổ — gộp bằng MAX theo chỉ số + ngày, không SUM; NULL ở dòng không theo rổ. [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–818 độ chi tiết Mã CK/Chỉ số, O_GSTT_78]',
    idx_round_lot_negotiated_vol                 Nullable(Int64)         COMMENT 'Tổng khối lượng giao dịch lô chẵn thỏa thuận của toàn bộ mã CK thành viên rổ chỉ số trong ngày (Market ID UPX/STX/STK/STO; Board T1,T2,T3,T6,R1). Lặp lại trên mỗi mã CK của rổ — gộp bằng MAX theo chỉ số + ngày, không SUM; NULL ở dòng không theo rổ. [MỚI 2026-10-30 v4.58, BA STT 38 dòng 811–818 độ chi tiết Mã CK/Chỉ số, O_GSTT_78]'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(trade_dt)
ORDER BY (trade_dt, symbol, index_code)
COMMENT 'Flat table — Operational Trading Liquidity Explorer (Data Explorer Nhóm 37; 1 dòng / mã CK / chỉ số hoặc không theo rổ / ngày; không Dimension)'
;
