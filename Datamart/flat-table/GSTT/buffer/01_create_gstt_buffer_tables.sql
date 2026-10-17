-- ============================================================
-- GSTT Buffer Tables — CREATE (tầng phục vụ chart template)
-- Module: Giám sát Thị trường (GSTT)
-- Nguồn thiết kế: buffer_chart_templates_v4.sql (46 template tự tách) — mỗi template 1 bảng, KHÔNG gộp.
-- Sinh: 2026-10-17 (bản nháp chưa chạy thử trên ClickHouse, cần review trước khi chạy production).
-- 46 bảng mart.buffer_<template>, tên giữ nguyên file tham chiếu để SQL chart (bước 2) trỏ lại cùng tên.
--
-- Quy ước (khác file tham chiếu, có chủ đích):
--   * Engine ReplicatedMergeTree() ON CLUSTER 'my_cluster' — khớp flat hiện tại (file tham chiếu dùng MergeTree thường).
--   * Cột liệt kê tường minh = cột bước 2 của template đọc + cột trong biểu thức dẫn xuất/WHERE + khoá;
--     KHÔNG SELECT * (hết trùng tên cột is_trading_date, security_trading_snpst_dim_id, snpst_dt_dim_id khi join rổ chỉ số).
--   * Kiểu cột copy nguyên từ flat nguồn; cột dẫn xuất tính bằng toFloat64 (chia Decimal không mất scale).
--   * Điều kiện lọc universe (loại trái phiếu/phái sinh...) copy nguyên từ file tham chiếu — chưa chuẩn hoá (xem O_GSTT_74 dự kiến).
--   * Không thuộc LLD/Entities: đây là tầng phục vụ phía sau flat, không phải Fact/Operational; 34 cột dẫn xuất không có KPI.
--   * Bước 2 của 18 template join rổ chỉ số (dinh-gia, tong-quan, top-dot-pha/gt/kl/nn x3, top-thung-day, top-vuot-dinh theo-chi-so/theo-san)
--     phải bỏ tiền tố s./b./idx. khi trỏ vào bảng này (bảng đã phẳng, không còn alias).
-- ============================================================

CREATE DATABASE IF NOT EXISTS mart ON CLUSTER 'my_cluster';

-- ============================================================
-- 1. [2399] heat-map  →  mart.buffer_heat_map
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: floor_code IN ('10','02','04') AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND (ifNull(public_company_dim_id, '') != '' OR ifNull(securities_company_dim_id, '') != '')
--    Grain: giữ grain flat nguồn
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_heat_map ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    public_company_dim_id               String                    COMMENT 'gstt_fct_stock_portfolio_snpst_flat.public_company_dim_id',
    securities_company_dim_id           String                    COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_dim_id',
    outstanding_share_quantity          Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    foreign_buy_vol                     Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_vol',
    foreign_sell_vol                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_vol',
    foreign_buy_val                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_val',
    foreign_sell_val                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_val',
    security_full_nm                    Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                          Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                         Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    ceiling_price                       Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.ceiling_price',
    floor_price                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_price',
    reference_price                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                        Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm     Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2399] heat-map — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: floor_code IN (\'10\',\'02\',\'04\') AND NOT ((floor_code = \'02\' AND stock_tp_code IN (\'1\',\'4\')) OR (floor_code = \'10\' AND stock_tp_code = \'1\')) AND (ifNull(public_company_dim_id, \'\') != \'\' OR ifNull(securities_company_dim_id, \'\') != \'\'); nạp theo ngày'
;


-- ============================================================
-- 2. [2391] bm021-mss-dinh-gia  →  mart.buffer_bm021_mss_dinh_gia
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: pct_bien_dong_ngay
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_bm021_mss_dinh_gia ON CLUSTER 'my_cluster'
(
    cdr_dt                                                        Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                                        Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    outstanding_share_quantity                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax                                          Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax',
    net_profit_after_tax_ttm                                      Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    weighted_average_outstanding_share_quantity                   Nullable(Decimal(23,4))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.weighted_average_outstanding_share_quantity',
    weighted_average_outstanding_share_quantity_ttm               Nullable(Decimal(23,4))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.weighted_average_outstanding_share_quantity_ttm',
    owner_equity_weighted_average_outstanding_share_quantity      Nullable(Decimal(23,4))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity_weighted_average_outstanding_share_quantity',
    owner_equity_weighted_average_outstanding_share_quantity_ttm  Nullable(Decimal(23,4))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity_weighted_average_outstanding_share_quantity_ttm',
    owner_equity_average_4_quarter                                Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity_average_4_quarter',
    floor_code                                                    Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                                 Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    listed_share_count                                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.listed_share_count',
    first_trading_dt                                              Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.first_trading_dt',
    high_price                                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.high_price',
    low_price                                                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.low_price',
    reference_price                                               Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                                   Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    pct_bien_dong_ngay                                            Nullable(Float64)         COMMENT '[CỘT MỚI] (high_price - low_price) / nullIf(reference_price, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2391] bm021-mss-dinh-gia — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 3. [2351] chi-so-eod  →  mart.buffer_chi_so_eod
--    Nguồn: datamart.qlkd_fct_market_index_snpst_flat
--    Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
--    Grain: giữ grain flat nguồn
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_chi_so_eod ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'qlkd_fct_market_index_snpst_flat.cdr_dt',
    market_code                         Nullable(String)          COMMENT 'qlkd_fct_market_index_snpst_flat.market_code',
    market_index_val                    Nullable(Decimal(23,2))   COMMENT 'qlkd_fct_market_index_snpst_flat.market_index_val',
    open_index                          Nullable(Decimal(23,2))   COMMENT 'qlkd_fct_market_index_snpst_flat.open_index',
    high_index                          Nullable(Decimal(23,2))   COMMENT 'qlkd_fct_market_index_snpst_flat.high_index',
    low_index                           Nullable(Decimal(23,2))   COMMENT 'qlkd_fct_market_index_snpst_flat.low_index',
    prior_index                         Nullable(Decimal(23,2))   COMMENT 'qlkd_fct_market_index_snpst_flat.prior_index',
    index_change                        Nullable(Decimal(23,2))   COMMENT 'qlkd_fct_market_index_snpst_flat.index_change',
    index_percent_change                Nullable(Decimal(5,2))    COMMENT 'qlkd_fct_market_index_snpst_flat.index_percent_change',
    advances_count                      Nullable(Int64)           COMMENT 'qlkd_fct_market_index_snpst_flat.advances_count',
    declines_count                      Nullable(Int64)           COMMENT 'qlkd_fct_market_index_snpst_flat.declines_count',
    no_change_count                     Nullable(Int64)           COMMENT 'qlkd_fct_market_index_snpst_flat.no_change_count',
    ceiling_count                       Nullable(Int64)           COMMENT 'qlkd_fct_market_index_snpst_flat.ceiling_count',
    floor_count                         Nullable(Int64)           COMMENT 'qlkd_fct_market_index_snpst_flat.floor_count',
    index_nm                            Nullable(String)          COMMENT 'qlkd_fct_market_index_snpst_flat.index_nm'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(market_code))
COMMENT 'Buffer chart template [2351] chi-so-eod — nguồn qlkd_fct_market_index_snpst_flat; lọc: không lọc thêm (chỉ lọc ngày); nạp theo ngày'
;


-- ============================================================
-- 4. [2350] chi-so-history  →  mart.buffer_chi_so_history
--    Nguồn: datamart.gstt_fct_market_index_intraday_flat
--    Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
--    Grain: giữ grain flat nguồn
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_chi_so_history ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_market_index_intraday_flat.cdr_dt',
    market_code                         Nullable(String)          COMMENT 'gstt_fct_market_index_intraday_flat.market_code',
    index_time                          Nullable(String)          COMMENT 'gstt_fct_market_index_intraday_flat.index_time',
    market_index_val_at_time            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_market_index_intraday_flat.market_index_val_at_time'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(market_code), assumeNotNull(index_time))
COMMENT 'Buffer chart template [2350] chi-so-history — nguồn gstt_fct_market_index_intraday_flat; lọc: không lọc thêm (chỉ lọc ngày); nạp theo ngày'
;


-- ============================================================
-- 5. [2349] chi-so-realtime  →  mart.buffer_chi_so_realtime
--    Nguồn: datamart.gstt_fct_market_index_intraday_flat
--    Universe/lọc tĩnh: substring(index_time, 1, 5) BETWEEN '09:00' AND '14:45'
--    Grain: giữ grain flat nguồn
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_chi_so_realtime ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_market_index_intraday_flat.cdr_dt',
    market_code                         Nullable(String)          COMMENT 'gstt_fct_market_index_intraday_flat.market_code',
    index_time                          Nullable(String)          COMMENT 'gstt_fct_market_index_intraday_flat.index_time',
    market_index_val_at_time            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_market_index_intraday_flat.market_index_val_at_time',
    total_val_at_time                   Nullable(Decimal(23,2))   COMMENT 'gstt_fct_market_index_intraday_flat.total_val_at_time'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(market_code), assumeNotNull(index_time))
COMMENT 'Buffer chart template [2349] chi-so-realtime — nguồn gstt_fct_market_index_intraday_flat; lọc: substring(index_time, 1, 5) BETWEEN \'09:00\' AND \'14:45\'; nạp theo ngày'
;


-- ============================================================
-- 6. [2352] dinh-gia  →  mart.buffer_dinh_gia
--    Nguồn: datamart.gstt_fct_index_constituent_snpst_flat, datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: 1 dòng / mã CK / chỉ số / ngày (INNER JOIN: chỉ mã thuộc rổ)
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_dinh_gia ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_index_constituent_snpst_flat.cdr_dt',
    symbol                              Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.symbol',
    index_code                          Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    outstanding_share_quantity          Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax                Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax',
    owner_equity                        Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    floor_code                          Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    close_price                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    idx_market_index_val                Nullable(Decimal(23,4))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_market_index_val',
    idx_market_cap                      Nullable(Decimal(23,2))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_market_cap',
    idx_pe                              Nullable(Decimal(10,2))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_pe',
    idx_pb                              Nullable(Decimal(10,2))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_pb',
    idx_eps                             Nullable(Decimal(23,2))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_eps'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2352] dinh-gia — nguồn gstt_fct_index_constituent_snpst_flat, gstt_fct_stock_portfolio_snpst_flat; lọc: U_EQ không loại sàn 03; nạp theo ngày'
;


-- ============================================================
-- 7. [2336] bang-co-phieu  →  mart.buffer_bang_co_phieu
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: vi_the_gia_trong_bien_do
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_bang_co_phieu ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    total_matched_vol                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                   Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_derivative_vol                Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_derivative_vol',
    total_derivative_val                Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_derivative_val',
    total_negotiated_vol                Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    foreign_net_vol                     Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_net_vol',
    foreign_buy_vol                     Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_vol',
    foreign_sell_vol                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_vol',
    foreign_buy_val                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_val',
    foreign_sell_val                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_val',
    security_full_nm                    Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                          Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                         Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    open_price                          Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.open_price',
    high_price                          Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.high_price',
    low_price                           Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.low_price',
    reference_price                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                        Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm     Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    vi_the_gia_trong_bien_do            Nullable(Float64)         COMMENT '[CỘT MỚI] (close_price - low_price) / nullIf(high_price - low_price, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2336] bang-co-phieu — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 8. [2338] bang-phai-sinh  →  mart.buffer_bang_phai_sinh
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_DER (sàn 03)
--    Grain: giữ grain flat nguồn
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_bang_phai_sinh ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    total_derivative_vol                Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_derivative_vol',
    total_derivative_negotiated_vol     Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_derivative_negotiated_vol',
    total_derivative_val                Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_derivative_val',
    total_derivative_negotiated_val     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_derivative_negotiated_val',
    foreign_net_derivative_vol          Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_net_derivative_vol',
    foreign_buy_vol                     Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_vol',
    foreign_sell_vol                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_vol',
    foreign_buy_val                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_val',
    foreign_sell_val                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_val',
    security_full_nm                    Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                          Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    underlying_symbol                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.underlying_symbol',
    maturity_dt                         Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.maturity_dt',
    reference_price                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                        Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2338] bang-phai-sinh — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_DER (sàn 03); nạp theo ngày'
;


-- ============================================================
-- 9. [2341] ngay-nghi-giao-dich  →  mart.buffer_ngay_nghi_giao_dich
--    Nguồn: datamart.cdr_dt_flat
--    Universe/lọc tĩnh: is_trading_date != 'Y'
--    Grain: giữ grain flat nguồn
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_ngay_nghi_giao_dich ON CLUSTER 'my_cluster'
(
    cdr_dt                              Date                      COMMENT 'cdr_dt_flat.cdr_dt',
    is_trading_date                     String                    COMMENT 'cdr_dt_flat.is_trading_date'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt))
COMMENT 'Buffer chart template [2341] ngay-nghi-giao-dich — nguồn cdr_dt_flat; lọc: is_trading_date != \'Y\'; nạp theo ngày'
;


-- ============================================================
-- 10. [2379] nuoc-ngoai  →  mart.buffer_nuoc_ngoai
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: ty_le_mua_rong_nn_klgd
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_nuoc_ngoai ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    total_matched_vol                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    foreign_buy_vol                     Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_vol',
    foreign_sell_vol                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_vol',
    foreign_buy_val                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_val',
    foreign_sell_val                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_val',
    security_full_nm                    Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                          Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    open_price                          Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.open_price',
    high_price                          Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.high_price',
    low_price                           Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.low_price',
    ceiling_price                       Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.ceiling_price',
    floor_price                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_price',
    reference_price                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                        Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    ty_le_mua_rong_nn_klgd              Nullable(Float64)         COMMENT '[CỘT MỚI] (foreign_buy_vol - foreign_sell_vol) / nullIf(total_matched_vol, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2379] nuoc-ngoai — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 11. [2380] nuoc-ngoai-gtnn  →  mart.buffer_nuoc_ngoai_gtnn
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: ty_le_mua_rong_nn_gtgd
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_nuoc_ngoai_gtnn ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    total_matched_val                   Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    foreign_buy_val                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_val',
    foreign_sell_val                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_val',
    floor_code                          Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    ty_le_mua_rong_nn_gtgd              Nullable(Float64)         COMMENT '[CỘT MỚI] (foreign_buy_val - foreign_sell_val) / nullIf(total_matched_val, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2380] nuoc-ngoai-gtnn — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 12. [2381] nuoc-ngoai-gtnn-intraday  →  mart.buffer_nuoc_ngoai_gtnn_intraday
--    Nguồn: datamart.gstt_fct_foreign_trading_min_snpst_flat
--    Universe/lọc tĩnh: NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03' AND (toHour(trade_minute_tms) * 60 + toMinute(trade_minute_tms)) BETWEEN 540 AND 885
--    Grain: giữ grain flat nguồn
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_nuoc_ngoai_gtnn_intraday ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_foreign_trading_min_snpst_flat.cdr_dt',
    symbol                              Nullable(String)          COMMENT 'gstt_fct_foreign_trading_min_snpst_flat.symbol',
    trade_minute_tms                    Nullable(DateTime)        COMMENT 'gstt_fct_foreign_trading_min_snpst_flat.trade_minute_tms',
    foreign_buy_val_at_min              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_foreign_trading_min_snpst_flat.foreign_buy_val_at_min',
    foreign_sell_val_at_min             Nullable(Decimal(23,2))   COMMENT 'gstt_fct_foreign_trading_min_snpst_flat.foreign_sell_val_at_min',
    floor_code                          Nullable(String)          COMMENT 'gstt_fct_foreign_trading_min_snpst_flat.floor_code',
    stock_tp_code                       Nullable(String)          COMMENT 'gstt_fct_foreign_trading_min_snpst_flat.stock_tp_code'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(trade_minute_tms))
COMMENT 'Buffer chart template [2381] nuoc-ngoai-gtnn-intraday — nguồn gstt_fct_foreign_trading_min_snpst_flat; lọc: NOT ((floor_code = \'02\' AND stock_tp_code IN (\'1\',\'4\')) OR (floor_code = \'10\' AND stock_tp_code = \'1\')) AND floor_code != \'03\' AND (toHour(trade_minute_tms) * 60 + toMinute(trade_minute_tms)) BETWEEN 540 AND 885; nạp theo ngày'
;


-- ============================================================
-- 13. [2382] nuoc-ngoai-theo-chi-so  →  mart.buffer_nuoc_ngoai_theo_chi_so
--    Nguồn: datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: ty_trong_freefloat_tren_tong_von_hoa_idx
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_nuoc_ngoai_theo_chi_so ON CLUSTER 'my_cluster'
(
    cdr_dt                                    Nullable(Date)            COMMENT 'gstt_fct_index_constituent_snpst_flat.cdr_dt',
    symbol                                    Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.symbol',
    index_code                                Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    idx_foreign_net_vol                       Nullable(Int64)           COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_foreign_net_vol',
    idx_foreign_net_val                       Nullable(Decimal(23,2))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_foreign_net_val',
    idx_market_cap                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_market_cap',
    idx_free_float_market_cap                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_free_float_market_cap',
    ty_trong_freefloat_tren_tong_von_hoa_idx  Nullable(Float64)         COMMENT '[CỘT MỚI] idx_free_float_market_cap / nullIf(idx_market_cap, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2382] nuoc-ngoai-theo-chi-so — nguồn gstt_fct_index_constituent_snpst_flat; lọc: không lọc thêm (chỉ lọc ngày); nạp theo ngày'
;


-- ============================================================
-- 14. [2383] nuoc-ngoai-theo-chi-so-intraday  →  mart.buffer_nuoc_ngoai_theo_chi_so_intraday
--    Nguồn: datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: dinh_gia_theo_pe_pb
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_nuoc_ngoai_theo_chi_so_intraday ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_index_constituent_snpst_flat.cdr_dt',
    symbol                              Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.symbol',
    index_code                          Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    idx_pe                              Nullable(Decimal(10,2))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_pe',
    idx_pb                              Nullable(Decimal(10,2))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_pb',
    dinh_gia_theo_pe_pb                 Nullable(Float64)         COMMENT '[CỘT MỚI] idx_pe / nullIf(idx_pb, 0)'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2383] nuoc-ngoai-theo-chi-so-intraday — nguồn gstt_fct_index_constituent_snpst_flat; lọc: không lọc thêm (chỉ lọc ngày); nạp theo ngày'
;


-- ============================================================
-- 15. [2385] phan-loai-ndt  →  mart.buffer_phan_loai_ndt
--    Nguồn: datamart.gstt_fct_investor_category_trading_snpst_flat
--    Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
--    Grain: giữ grain flat nguồn
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_phan_loai_ndt ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_investor_category_trading_snpst_flat.cdr_dt',
    symbol                              Nullable(String)          COMMENT 'gstt_fct_investor_category_trading_snpst_flat.symbol',
    investor_category_code              Nullable(String)          COMMENT 'gstt_fct_investor_category_trading_snpst_flat.investor_category_code',
    buy_val                             Nullable(Decimal(23,2))   COMMENT 'gstt_fct_investor_category_trading_snpst_flat.buy_val',
    sell_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_investor_category_trading_snpst_flat.sell_val',
    matched_buy_val                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_investor_category_trading_snpst_flat.matched_buy_val',
    matched_sell_val                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_investor_category_trading_snpst_flat.matched_sell_val'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(investor_category_code))
COMMENT 'Buffer chart template [2385] phan-loai-ndt — nguồn gstt_fct_investor_category_trading_snpst_flat; lọc: không lọc thêm (chỉ lọc ngày); nạp theo ngày'
;


-- ============================================================
-- 16. [2387] phan-loai-ndt-heatmap  →  mart.buffer_phan_loai_ndt_heatmap
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: gia_tri_binh_quan_mot_lenh
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_phan_loai_ndt_heatmap ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    total_matched_vol                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                   Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    security_full_nm                    Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                          Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    ceiling_price                       Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.ceiling_price',
    floor_price                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_price',
    reference_price                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                        Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    gia_tri_binh_quan_mot_lenh          Nullable(Float64)         COMMENT '[CỘT MỚI] total_matched_val / nullIf(total_matched_vol, 0)'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2387] phan-loai-ndt-heatmap — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 17. [2386] phan-loai-ndt-index  →  mart.buffer_phan_loai_ndt_index
--    Nguồn: datamart.gstt_fct_investor_category_index_trading_snpst_flat
--    Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
--    Grain: giữ grain flat nguồn
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_phan_loai_ndt_index ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_investor_category_index_trading_snpst_flat.cdr_dt',
    index_code                          Nullable(String)          COMMENT 'gstt_fct_investor_category_index_trading_snpst_flat.index_code',
    investor_category_code              String                    COMMENT 'gstt_fct_investor_category_index_trading_snpst_flat.investor_category_code',
    buy_val                             Nullable(Decimal(23,2))   COMMENT 'gstt_fct_investor_category_index_trading_snpst_flat.buy_val',
    sell_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_investor_category_index_trading_snpst_flat.sell_val',
    matched_buy_val                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_investor_category_index_trading_snpst_flat.matched_buy_val',
    matched_sell_val                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_investor_category_index_trading_snpst_flat.matched_sell_val',
    market_index_val                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_investor_category_index_trading_snpst_flat.market_index_val'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(index_code), assumeNotNull(investor_category_code))
COMMENT 'Buffer chart template [2386] phan-loai-ndt-index — nguồn gstt_fct_investor_category_index_trading_snpst_flat; lọc: không lọc thêm (chỉ lọc ngày); nạp theo ngày'
;


-- ============================================================
-- 18. [2378] tong-quan  →  mart.buffer_tong_quan
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: chenh_lech_von_hoa_freefloat_vs_thuong
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_tong_quan ON CLUSTER 'my_cluster'
(
    cdr_dt                                  Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                              Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_vol                               Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                               Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                       Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                       Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    outstanding_share_quantity              Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    free_float_share_quantity               Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.free_float_share_quantity',
    security_full_nm                        Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                           Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    open_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.open_price',
    high_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.high_price',
    low_price                               Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.low_price',
    reference_price                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                             Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    idx_market_cap                          Nullable(Decimal(23,2))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_market_cap',
    idx_free_float_market_cap               Nullable(Decimal(23,2))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_free_float_market_cap',
    chenh_lech_von_hoa_freefloat_vs_thuong  Nullable(Float64)         COMMENT '[CỘT MỚI] close_price * (outstanding_share_quantity - free_float_share_quantity)'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2378] tong-quan — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 19. [2384] tu-doanh  →  mart.buffer_tu_doanh
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: bien_do_so_voi_tran
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_tu_doanh ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    proprietary_buy_val                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.proprietary_buy_val',
    proprietary_sell_val                Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.proprietary_sell_val',
    proprietary_buy_vol                 Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.proprietary_buy_vol',
    proprietary_sell_vol                Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.proprietary_sell_vol',
    security_full_nm                    Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                          Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    ceiling_price                       Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.ceiling_price',
    floor_price                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_price',
    reference_price                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                        Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    bien_do_so_voi_tran                 Nullable(Float64)         COMMENT '[CỘT MỚI] (ceiling_price - close_price) / nullIf(ceiling_price - floor_price, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2384] tu-doanh — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 20. [2397] co-dong-lon  →  mart.buffer_co_dong_lon
--    Nguồn: datamart.ndtnn_fct_public_company_foreign_ownership_snpst_flat
--    Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
--    Grain: giữ grain flat nguồn
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_co_dong_lon ON CLUSTER 'my_cluster'
(
    snpst_cdr_dt                        Nullable(Date)            COMMENT 'ndtnn_fct_public_company_foreign_ownership_snpst_flat.snpst_cdr_dt',
    equity_ticker_symbol                Nullable(String)          COMMENT 'ndtnn_fct_public_company_foreign_ownership_snpst_flat.equity_ticker_symbol',
    ticker_symbol                       String                    COMMENT 'ndtnn_fct_public_company_foreign_ownership_snpst_flat.ticker_symbol',
    total_issued_share_quantity         Nullable(Int64)           COMMENT 'ndtnn_fct_public_company_foreign_ownership_snpst_flat.total_issued_share_quantity',
    current_foreign_holding_quantity    Nullable(Int64)           COMMENT 'ndtnn_fct_public_company_foreign_ownership_snpst_flat.current_foreign_holding_quantity'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), assumeNotNull(equity_ticker_symbol))
COMMENT 'Buffer chart template [2397] co-dong-lon — nguồn ndtnn_fct_public_company_foreign_ownership_snpst_flat; lọc: không lọc thêm (chỉ lọc ngày); nạp theo ngày'
;


-- ============================================================
-- 21. [2371] top-dot-pha-theo-chi-so  →  mart.buffer_top_dot_pha_theo_chi_so
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: ty_trong_gtgd_phai_sinh
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_dot_pha_theo_chi_so ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_derivative_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_derivative_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    ty_trong_gtgd_phai_sinh                      Nullable(Float64)         COMMENT '[CỘT MỚI] total_derivative_val / nullIf(total_matched_val, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2371] top-dot-pha-theo-chi-so — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 22. [2370] top-dot-pha-theo-san  →  mart.buffer_top_dot_pha_theo_san
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_dot_pha_theo_san ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2370] top-dot-pha-theo-san — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ không loại sàn 03; nạp theo ngày'
;


-- ============================================================
-- 23. [2369] top-dot-pha-toan-tt  →  mart.buffer_top_dot_pha_toan_tt
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: chenh_lech_gia_dong_vs_mo_cua_pct
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_dot_pha_toan_tt ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    open_price                                   Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.open_price',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    chenh_lech_gia_dong_vs_mo_cua_pct            Nullable(Float64)         COMMENT '[CỘT MỚI] (close_price - open_price) / nullIf(open_price, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2369] top-dot-pha-toan-tt — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 24. [2362] top-giam-gia-theo-chi-so  →  mart.buffer_top_giam_gia_theo_chi_so
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: bien_do_so_voi_san
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_giam_gia_theo_chi_so ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    total_vol                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    fct_close_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.fct_close_price',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    ceiling_price                                Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.ceiling_price',
    floor_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_price',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    bien_do_so_voi_san                           Nullable(Float64)         COMMENT '[CỘT MỚI] (close_price - floor_price) / nullIf(ceiling_price - floor_price, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2362] top-giam-gia-theo-chi-so — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 25. [2361] top-giam-gia-theo-san  →  mart.buffer_top_giam_gia_theo_san
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: ty_trong_thoa_thuan
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_giam_gia_theo_san ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    total_vol                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    fct_close_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.fct_close_price',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    ty_trong_thoa_thuan                          Nullable(Float64)         COMMENT '[CỘT MỚI] total_negotiated_vol / nullIf(total_matched_vol + total_negotiated_vol, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2361] top-giam-gia-theo-san — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_EQ không loại sàn 03; nạp theo ngày'
;


-- ============================================================
-- 26. [2360] top-giam-gia-toan-tt  →  mart.buffer_top_giam_gia_toan_tt
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: pe_uoc_tinh
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_giam_gia_toan_tt ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    total_vol                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    fct_close_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.fct_close_price',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    pe_uoc_tinh                                  Nullable(Float64)         COMMENT '[CỘT MỚI] close_price * outstanding_share_quantity / nullIf(net_profit_after_tax_ttm, 0)'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2360] top-giam-gia-toan-tt — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 27. [2377] top-gt-theo-chi-so  →  mart.buffer_top_gt_theo_chi_so
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: ty_trong_von_hoa_trong_chi_so
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_gt_theo_chi_so ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_vol                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    idx_market_cap                               Nullable(Decimal(23,2))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_market_cap',
    ty_trong_von_hoa_trong_chi_so                Nullable(Float64)         COMMENT '[CỘT MỚI] (close_price * outstanding_share_quantity) / nullIf(idx_market_cap, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2377] top-gt-theo-chi-so — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 28. [2376] top-gt-theo-san  →  mart.buffer_top_gt_theo_san
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: ty_trong_gtgd_tren_von_hoa
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_gt_theo_san ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_vol                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    ty_trong_gtgd_tren_von_hoa                   Nullable(Float64)         COMMENT '[CỘT MỚI] total_matched_val / nullIf(close_price * outstanding_share_quantity, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2376] top-gt-theo-san — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ không loại sàn 03; nạp theo ngày'
;


-- ============================================================
-- 29. [2375] top-gt-toan-tt  →  mart.buffer_top_gt_toan_tt
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: dong_gop_von_hoa_freefloat_idx
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_gt_toan_tt ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_vol                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    free_float_share_quantity                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.free_float_share_quantity',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    idx_free_float_market_cap                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_free_float_market_cap',
    dong_gop_von_hoa_freefloat_idx               Nullable(Float64)         COMMENT '[CỘT MỚI] (close_price * free_float_share_quantity) / nullIf(idx_free_float_market_cap, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2375] top-gt-toan-tt — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 30. [2356] top-kl-theo-chi-so  →  mart.buffer_top_kl_theo_chi_so
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: ty_trong_klgd_tren_idx_level
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_kl_theo_chi_so ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_vol                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    idx_market_index_val                         Nullable(Decimal(23,4))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_market_index_val',
    ty_trong_klgd_tren_idx_level                 Nullable(Float64)         COMMENT '[CỘT MỚI] total_matched_vol / nullIf(idx_market_index_val, 0)'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2356] top-kl-theo-chi-so — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 31. [2355] top-kl-theo-san  →  mart.buffer_top_kl_theo_san
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: ty_trong_gtgd_nn_tren_tong_gtgd
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_kl_theo_san ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_vol                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    foreign_buy_val                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_val',
    foreign_sell_val                             Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_val',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    ty_trong_gtgd_nn_tren_tong_gtgd              Nullable(Float64)         COMMENT '[CỘT MỚI] (foreign_buy_val + foreign_sell_val) / nullIf(total_matched_val, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2355] top-kl-theo-san — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ không loại sàn 03; nạp theo ngày'
;


-- ============================================================
-- 32. [2354] top-kl-toan-tt  →  mart.buffer_top_kl_toan_tt
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: bien_dao_dong_so_voi_idx_level
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_kl_toan_tt ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_vol                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    high_price                                   Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.high_price',
    low_price                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.low_price',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    idx_market_index_val                         Nullable(Decimal(23,4))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_market_index_val',
    bien_dao_dong_so_voi_idx_level               Nullable(Float64)         COMMENT '[CỘT MỚI] (high_price - low_price) / nullIf(idx_market_index_val, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2354] top-kl-toan-tt — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 33. [2374] top-nn-theo-chi-so  →  mart.buffer_top_nn_theo_chi_so
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: eps_vs_chi_so_eps
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_nn_theo_chi_so ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_vol                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    foreign_buy_vol                              Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_vol',
    foreign_sell_vol                             Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_vol',
    foreign_buy_val                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_val',
    foreign_sell_val                             Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_val',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    idx_eps                                      Nullable(Decimal(23,2))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_eps',
    eps_vs_chi_so_eps                            Nullable(Float64)         COMMENT '[CỘT MỚI] (net_profit_after_tax_ttm / nullIf(outstanding_share_quantity, 0)) - idx_eps'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2374] top-nn-theo-chi-so — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 34. [2373] top-nn-theo-san  →  mart.buffer_top_nn_theo_san
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: ty_trong_klgd_nn_tren_tong_klgd
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_nn_theo_san ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_vol                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    foreign_buy_vol                              Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_vol',
    foreign_sell_vol                             Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_vol',
    foreign_buy_val                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_val',
    foreign_sell_val                             Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_val',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    ty_trong_klgd_nn_tren_tong_klgd              Nullable(Float64)         COMMENT '[CỘT MỚI] (foreign_buy_vol + foreign_sell_vol) / nullIf(total_matched_vol, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2373] top-nn-theo-san — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ không loại sàn 03; nạp theo ngày'
;


-- ============================================================
-- 35. [2372] top-nn-toan-tt  →  mart.buffer_top_nn_toan_tt
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: ty_le_von_hoa_so_voi_idx_level
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_nn_toan_tt ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_vol                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    foreign_buy_vol                              Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_vol',
    foreign_sell_vol                             Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_vol',
    foreign_buy_val                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_buy_val',
    foreign_sell_val                             Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.foreign_sell_val',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    idx_market_index_val                         Nullable(Decimal(23,4))   COMMENT 'gstt_fct_index_constituent_snpst_flat.idx_market_index_val',
    ty_le_von_hoa_so_voi_idx_level               Nullable(Float64)         COMMENT '[CỘT MỚI] (close_price * outstanding_share_quantity) / nullIf(idx_market_index_val, 0)'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2372] top-nn-toan-tt — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 36. [2359] top-tang-gia-theo-chi-so  →  mart.buffer_top_tang_gia_theo_chi_so
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: pb_uoc_tinh
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_tang_gia_theo_chi_so ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    total_vol                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    fct_close_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.fct_close_price',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    pb_uoc_tinh                                  Nullable(Float64)         COMMENT '[CỘT MỚI] close_price * outstanding_share_quantity / nullIf(owner_equity, 0)'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2359] top-tang-gia-theo-chi-so — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 37. [2358] top-tang-gia-theo-san  →  mart.buffer_top_tang_gia_theo_san
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: chenh_lech_gia_tran_san
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_tang_gia_theo_san ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    total_vol                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    fct_close_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.fct_close_price',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    ceiling_price                                Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.ceiling_price',
    floor_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_price',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    chenh_lech_gia_tran_san                      Nullable(Decimal(23,2))   COMMENT '[CỘT MỚI] ceiling_price - floor_price'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2358] top-tang-gia-theo-san — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_EQ không loại sàn 03; nạp theo ngày'
;


-- ============================================================
-- 38. [2357] top-tang-gia-toan-tt  →  mart.buffer_top_tang_gia_toan_tt
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: von_hoa_free_float
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_tang_gia_toan_tt ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    total_vol                                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_vol',
    total_val                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_val',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    fct_close_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.fct_close_price',
    free_float_share_quantity                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.free_float_share_quantity',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    von_hoa_free_float                           Nullable(Float64)         COMMENT '[CỘT MỚI] close_price * free_float_share_quantity'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2357] top-tang-gia-toan-tt — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 39. [2368] top-thung-day-theo-chi-so  →  mart.buffer_top_thung_day_theo_chi_so
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: khoang_cach_den_gia_san_pct
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_thung_day_theo_chi_so ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    high_price                                   Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.high_price',
    low_price                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.low_price',
    floor_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_price',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    khoang_cach_den_gia_san_pct                  Nullable(Float64)         COMMENT '[CỘT MỚI] (close_price - floor_price) / nullIf(floor_price, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2368] top-thung-day-theo-chi-so — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 40. [2367] top-thung-day-theo-san  →  mart.buffer_top_thung_day_theo_san
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: do_sau_thung_day_pct
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_thung_day_theo_san ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    high_price                                   Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.high_price',
    low_price                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.low_price',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    do_sau_thung_day_pct                         Nullable(Float64)         COMMENT '[CỘT MỚI] (reference_price - low_price) / nullIf(reference_price, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2367] top-thung-day-theo-san — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ không loại sàn 03; nạp theo ngày'
;


-- ============================================================
-- 41. [2366] top-thung-day-toan-tt  →  mart.buffer_top_thung_day_toan_tt
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: thanh_khoan_theo_freefloat
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_thung_day_toan_tt ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    free_float_share_quantity                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.free_float_share_quantity',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    high_price                                   Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.high_price',
    low_price                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.low_price',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    thanh_khoan_theo_freefloat                   Nullable(Float64)         COMMENT '[CỘT MỚI] total_matched_vol / nullIf(free_float_share_quantity, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2366] top-thung-day-toan-tt — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 42. [2365] top-vuot-dinh-theo-chi-so  →  mart.buffer_top_vuot_dinh_theo_chi_so
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: khoang_cach_den_gia_tran_pct
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_vuot_dinh_theo_chi_so ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    high_price                                   Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.high_price',
    low_price                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.low_price',
    ceiling_price                                Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.ceiling_price',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    khoang_cach_den_gia_tran_pct                 Nullable(Float64)         COMMENT '[CỘT MỚI] (ceiling_price - close_price) / nullIf(close_price, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2365] top-vuot-dinh-theo-chi-so — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 43. [2364] top-vuot-dinh-theo-san  →  mart.buffer_top_vuot_dinh_theo_san
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: do_cao_vuot_dinh_pct
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_vuot_dinh_theo_san ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    index_code                                   Nullable(String)          COMMENT 'gstt_fct_index_constituent_snpst_flat.index_code',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    high_price                                   Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.high_price',
    low_price                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.low_price',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    do_cao_vuot_dinh_pct                         Nullable(Float64)         COMMENT '[CỘT MỚI] (high_price - reference_price) / nullIf(reference_price, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol), assumeNotNull(index_code))
COMMENT 'Buffer chart template [2364] top-vuot-dinh-theo-san — nguồn gstt_fct_stock_portfolio_snpst_flat, gstt_fct_index_constituent_snpst_flat; lọc: U_EQ không loại sàn 03; nạp theo ngày'
;


-- ============================================================
-- 44. [2363] top-vuot-dinh-toan-tt  →  mart.buffer_top_vuot_dinh_toan_tt
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: ty_trong_klgd_phai_sinh
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_top_vuot_dinh_toan_tt ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    total_matched_vol                            Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_matched_val                            Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_val',
    total_derivative_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_derivative_vol',
    total_negotiated_vol                         Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    total_negotiated_val                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_val',
    outstanding_share_quantity                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.outstanding_share_quantity',
    net_profit_after_tax_ttm                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.net_profit_after_tax_ttm',
    owner_equity                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.owner_equity',
    securities_company_net_profit_after_tax_ttm  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_net_profit_after_tax_ttm',
    securities_company_owner_equity              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.securities_company_owner_equity',
    security_full_nm                             Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                                   Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                                Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    stock_tp_nm                                  Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_nm',
    high_price                                   Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.high_price',
    low_price                                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.low_price',
    reference_price                              Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                                  Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    ty_trong_klgd_phai_sinh                      Nullable(Float64)         COMMENT '[CỘT MỚI] total_derivative_vol / nullIf(total_matched_vol, 0) * 100'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2363] top-vuot-dinh-toan-tt — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03); nạp theo ngày'
;


-- ============================================================
-- 45. [2337] bang-trai-phieu  →  mart.buffer_bang_trai_phieu
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_BOND (stock_tp_code=1, sàn 04/10/03/02)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: klgd_rong
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_bang_trai_phieu ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    total_matched_vol                   Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_matched_vol',
    total_negotiated_vol                Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.total_negotiated_vol',
    bond_trading_vol                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.bond_trading_vol',
    bond_negotiated_vol                 Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.bond_negotiated_vol',
    bond_trading_val                    Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.bond_trading_val',
    bond_negotiated_val                 Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.bond_negotiated_val',
    security_full_nm                    Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.security_full_nm',
    floor_code                          Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    issuer_nm                           Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.issuer_nm',
    maturity_dt                         Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.maturity_dt',
    coupon_rate                         Nullable(Decimal(7,4))    COMMENT 'gstt_fct_stock_portfolio_snpst_flat.coupon_rate',
    yield                               Nullable(Decimal(7,4))    COMMENT 'gstt_fct_stock_portfolio_snpst_flat.yield',
    open_price                          Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.open_price',
    reference_price                     Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.reference_price',
    close_price                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    price_change                        Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.price_change',
    classification_business_line_nm     Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.classification_business_line_nm',
    klgd_rong                           Nullable(Int64)           COMMENT '[CỘT MỚI] total_matched_vol - total_negotiated_vol'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), assumeNotNull(symbol))
COMMENT 'Buffer chart template [2337] bang-trai-phieu — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_BOND (stock_tp_code=1, sàn 04/10/03/02); nạp theo ngày'
;


-- ============================================================
-- 46. [2392] lich-su-gia-khoi-luong  →  mart.buffer_lich_su_gia_khoi_luong
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_BOND (stock_tp_code=1, sàn 04/10/03/02)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: bien_dong_gia_tuyet_doi
-- ============================================================
CREATE TABLE IF NOT EXISTS mart.buffer_lich_su_gia_khoi_luong ON CLUSTER 'my_cluster'
(
    cdr_dt                              Nullable(Date)            COMMENT 'gstt_fct_stock_portfolio_snpst_flat.cdr_dt',
    symbol                              Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.symbol',
    bond_trading_vol                    Nullable(Int64)           COMMENT 'gstt_fct_stock_portfolio_snpst_flat.bond_trading_vol',
    floor_code                          Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.floor_code',
    stock_tp_code                       Nullable(String)          COMMENT 'gstt_fct_stock_portfolio_snpst_flat.stock_tp_code',
    high_price                          Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.high_price',
    low_price                           Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.low_price',
    close_price                         Nullable(Decimal(23,2))   COMMENT 'gstt_fct_stock_portfolio_snpst_flat.close_price',
    bien_dong_gia_tuyet_doi             Nullable(Decimal(23,2))   COMMENT '[CỘT MỚI] high_price - low_price'
)
ENGINE = ReplicatedMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(symbol), assumeNotNull(cdr_dt))
COMMENT 'Buffer chart template [2392] lich-su-gia-khoi-luong — nguồn gstt_fct_stock_portfolio_snpst_flat; lọc: U_BOND (stock_tp_code=1, sàn 04/10/03/02); nạp theo ngày'
;
