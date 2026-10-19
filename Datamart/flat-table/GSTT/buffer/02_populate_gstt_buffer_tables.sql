-- ============================================================
-- GSTT Buffer Tables — POPULATE (tầng phục vụ chart template)
-- Module: Giám sát Thị trường (GSTT)
-- Sinh: 2026-10-17, cập nhật tên bảng theo buffer_chart_templates_v5.sql 2026-10-19 (bản nháp chưa chạy thử).
-- 45 khối DELETE + INSERT, 1-1 với file 01; khối [2341] bị tắt (comment-out) như v5.
-- ETL daily: mỗi bảng DELETE đúng ngày chạy rồi INSERT lại (idempotent — chạy lại / backfill không trùng).
-- Thứ tự: chạy SAU khi các flat nguồn đã nạp xong cùng ngày: 02_populate_gstt_flat_tables.sql (GSTT),
--   flat QLKD (qlkd_fct_market_index_snpst_flat), flat NDTNN (ndtnn_fct_public_company_foreign_ownership_snpst_flat),
--   flat Common (cdr_dt_flat).
-- Tham số ngày chạy theo quy ước repo (etl_date), file tham chiếu dùng {ngay:Date}.
-- Join rổ chỉ số dùng SETTINGS join_use_nulls = 1 để mã không thuộc rổ nào ra cột rổ NULL, không phụ thuộc cấu hình server.
-- ============================================================

-- ============================================================
-- 1. [2399] heat-map  →  mart.gstt_fct_stock_heatmap_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: floor_code IN ('10','02','04') AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND (ifNull(public_company_dim_id, '') != '' OR ifNull(securities_company_dim_id, '') != '')
--    Grain: giữ grain flat nguồn
-- ============================================================
DELETE FROM mart.gstt_fct_stock_heatmap_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_stock_heatmap_flat
SELECT
    cdr_dt,
    symbol,
    public_company_dim_id,
    securities_company_dim_id,
    outstanding_share_quantity,
    foreign_buy_vol,
    foreign_sell_vol,
    foreign_buy_val,
    foreign_sell_val,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    ceiling_price,
    floor_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND floor_code IN ('10','02','04') AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND (ifNull(public_company_dim_id, '') != '' OR ifNull(securities_company_dim_id, '') != '');


-- ============================================================
-- 2. [2391] bm021-mss-dinh-gia  →  mart.gstt_fct_valuation_report_bm021_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: pct_bien_dong_ngay
-- ============================================================
DELETE FROM mart.gstt_fct_valuation_report_bm021_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_valuation_report_bm021_flat
SELECT
    cdr_dt,
    symbol,
    outstanding_share_quantity,
    net_profit_after_tax,
    net_profit_after_tax_ttm,
    owner_equity,
    weighted_average_outstanding_share_quantity,
    weighted_average_outstanding_share_quantity_ttm,
    owner_equity_weighted_average_outstanding_share_quantity,
    owner_equity_weighted_average_outstanding_share_quantity_ttm,
    owner_equity_average_4_quarter,
    floor_code,
    stock_tp_code,
    listed_share_count,
    first_trading_dt,
    high_price,
    low_price,
    reference_price,
    close_price,
    (toFloat64(high_price) - toFloat64(low_price)) / nullIf(toFloat64(reference_price), 0) * 100 AS pct_bien_dong_ngay
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03';


-- ============================================================
-- 3. [2351] chi-so-eod  →  mart.qlkd_fct_index_eod_flat
--    Nguồn: datamart.qlkd_fct_market_index_snpst_flat
--    Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
--    Grain: giữ grain flat nguồn
-- ============================================================
DELETE FROM mart.qlkd_fct_index_eod_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.qlkd_fct_index_eod_flat
SELECT
    cdr_dt,
    market_code,
    market_index_val,
    open_index,
    high_index,
    low_index,
    prior_index,
    index_change,
    index_percent_change,
    advances_count,
    declines_count,
    no_change_count,
    ceiling_count,
    floor_count,
    index_nm
FROM datamart.qlkd_fct_market_index_snpst_flat
WHERE cdr_dt = :etl_date;


-- ============================================================
-- 4. [2350] chi-so-history  →  mart.gstt_fct_index_history_flat
--    Nguồn: datamart.gstt_fct_market_index_intraday_flat
--    Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
--    Grain: giữ grain flat nguồn
-- ============================================================
DELETE FROM mart.gstt_fct_index_history_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_index_history_flat
SELECT
    cdr_dt,
    market_code,
    index_time,
    market_index_val_at_time
FROM datamart.gstt_fct_market_index_intraday_flat
WHERE cdr_dt = :etl_date;


-- ============================================================
-- 5. [2349] chi-so-realtime  →  mart.gstt_fct_index_realtime_flat
--    Nguồn: datamart.gstt_fct_market_index_intraday_flat
--    Universe/lọc tĩnh: substring(index_time, 1, 5) BETWEEN '09:00' AND '14:45'
--    Grain: giữ grain flat nguồn
-- ============================================================
DELETE FROM mart.gstt_fct_index_realtime_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_index_realtime_flat
SELECT
    cdr_dt,
    market_code,
    index_time,
    market_index_val_at_time,
    total_val_at_time
FROM datamart.gstt_fct_market_index_intraday_flat
WHERE cdr_dt = :etl_date
  AND substring(index_time, 1, 5) BETWEEN '09:00' AND '14:45';


-- ============================================================
-- 6. [2352] dinh-gia  →  mart.gstt_fct_index_valuation_flat
--    Nguồn: datamart.gstt_fct_index_constituent_snpst_flat, datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: 1 dòng / mã CK / chỉ số / ngày (INNER JOIN: chỉ mã thuộc rổ)
-- ============================================================
DELETE FROM mart.gstt_fct_index_valuation_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_index_valuation_flat
SELECT
    idx.cdr_dt AS cdr_dt,
    idx.symbol AS symbol,
    index_code,
    outstanding_share_quantity,
    net_profit_after_tax,
    owner_equity,
    floor_code,
    stock_tp_code,
    close_price,
    idx_market_index_val,
    idx_market_cap,
    idx_pe,
    idx_pb,
    idx_eps
FROM datamart.gstt_fct_index_constituent_snpst_flat idx
     JOIN datamart.gstt_fct_stock_portfolio_snpst_flat s
       ON s.symbol = idx.symbol AND s.cdr_dt = idx.cdr_dt
WHERE idx.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1'))
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 7. [2336] bang-co-phieu  →  mart.gstt_fct_stock_list_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: vi_the_gia_trong_bien_do
-- ============================================================
DELETE FROM mart.gstt_fct_stock_list_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_stock_list_flat
SELECT
    cdr_dt,
    symbol,
    total_matched_vol,
    total_matched_val,
    total_derivative_vol,
    total_derivative_val,
    total_negotiated_vol,
    total_negotiated_val,
    foreign_net_vol,
    foreign_buy_vol,
    foreign_sell_vol,
    foreign_buy_val,
    foreign_sell_val,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    open_price,
    high_price,
    low_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    (toFloat64(close_price) - toFloat64(low_price)) / nullIf(toFloat64(high_price) - toFloat64(low_price), 0) * 100 AS vi_the_gia_trong_bien_do
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03';


-- ============================================================
-- 8. [2338] bang-phai-sinh  →  mart.gstt_fct_derivative_list_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_DER (sàn 03)
--    Grain: giữ grain flat nguồn
-- ============================================================
DELETE FROM mart.gstt_fct_derivative_list_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_derivative_list_flat
SELECT
    cdr_dt,
    symbol,
    total_derivative_vol,
    total_derivative_negotiated_vol,
    total_derivative_val,
    total_derivative_negotiated_val,
    foreign_net_derivative_vol,
    foreign_buy_vol,
    foreign_sell_vol,
    foreign_buy_val,
    foreign_sell_val,
    security_full_nm,
    floor_code,
    underlying_symbol,
    maturity_dt,
    reference_price,
    close_price,
    price_change
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND floor_code = '03';


-- ============================================================
-- 9. [2341] ngay-nghi-giao-dich  →  mart.cdr_fct_non_trading_day_flat
--    Nguồn: datamart.cdr_dt_flat
--    Universe/lọc tĩnh: is_trading_date != 'Y'
--    Grain: giữ grain flat nguồn
-- ============================================================
-- [v5] KHỐI BỊ TẮT: buffer_chart_templates_v5.sql comment-out cả DDL + nạp + bước 2 của [2341] (mart.cdr_fct_non_trading_day_flat không được tạo). Chưa rõ chart [2341] đọc từ đâu — cần GSTT xác nhận.
-- DELETE FROM mart.cdr_fct_non_trading_day_flat ON CLUSTER 'my_cluster'
-- WHERE cdr_dt = :etl_date;
-- INSERT INTO mart.cdr_fct_non_trading_day_flat
-- SELECT
--     cdr_dt,
--     is_trading_date
-- FROM datamart.cdr_dt_flat
-- WHERE cdr_dt = :etl_date
--   AND is_trading_date != 'Y';


-- ============================================================
-- 10. [2379] nuoc-ngoai  →  mart.gstt_fct_foreign_trading_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: ty_le_mua_rong_nn_klgd
-- ============================================================
DELETE FROM mart.gstt_fct_foreign_trading_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_foreign_trading_flat
SELECT
    cdr_dt,
    symbol,
    total_matched_vol,
    foreign_buy_vol,
    foreign_sell_vol,
    foreign_buy_val,
    foreign_sell_val,
    security_full_nm,
    floor_code,
    stock_tp_code,
    open_price,
    high_price,
    low_price,
    ceiling_price,
    floor_price,
    reference_price,
    close_price,
    price_change,
    (toFloat64(foreign_buy_vol) - toFloat64(foreign_sell_vol)) / nullIf(toFloat64(total_matched_vol), 0) * 100 AS ty_le_mua_rong_nn_klgd
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03';


-- ============================================================
-- 11. [2380] nuoc-ngoai-gtnn  →  mart.gstt_fct_foreign_trading_value_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: ty_le_mua_rong_nn_gtgd
-- ============================================================
DELETE FROM mart.gstt_fct_foreign_trading_value_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_foreign_trading_value_flat
SELECT
    cdr_dt,
    symbol,
    total_matched_val,
    foreign_buy_val,
    foreign_sell_val,
    floor_code,
    stock_tp_code,
    (toFloat64(foreign_buy_val) - toFloat64(foreign_sell_val)) / nullIf(toFloat64(total_matched_val), 0) * 100 AS ty_le_mua_rong_nn_gtgd
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03';


-- ============================================================
-- 12. [2381] nuoc-ngoai-gtnn-intraday  →  mart.gstt_fct_foreign_trading_value_intraday_flat
--    Nguồn: datamart.gstt_fct_foreign_trading_min_snpst_flat
--    Universe/lọc tĩnh: NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03' AND (toHour(trade_minute_tms) * 60 + toMinute(trade_minute_tms)) BETWEEN 540 AND 885
--    Grain: giữ grain flat nguồn
-- ============================================================
DELETE FROM mart.gstt_fct_foreign_trading_value_intraday_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_foreign_trading_value_intraday_flat
SELECT
    cdr_dt,
    symbol,
    trade_minute_tms,
    foreign_buy_val_at_min,
    foreign_sell_val_at_min,
    floor_code,
    stock_tp_code
FROM datamart.gstt_fct_foreign_trading_min_snpst_flat
WHERE cdr_dt = :etl_date
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03' AND (toHour(trade_minute_tms) * 60 + toMinute(trade_minute_tms)) BETWEEN 540 AND 885;


-- ============================================================
-- 13. [2382] nuoc-ngoai-theo-chi-so  →  mart.gstt_fct_foreign_trading_by_index_flat
--    Nguồn: datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: ty_trong_freefloat_tren_tong_von_hoa_idx
-- ============================================================
DELETE FROM mart.gstt_fct_foreign_trading_by_index_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_foreign_trading_by_index_flat
SELECT
    cdr_dt,
    symbol,
    index_code,
    idx_foreign_net_vol,
    idx_foreign_net_val,
    idx_market_cap,
    idx_free_float_market_cap,
    toFloat64(idx_free_float_market_cap) / nullIf(toFloat64(idx_market_cap), 0) * 100 AS ty_trong_freefloat_tren_tong_von_hoa_idx
FROM datamart.gstt_fct_index_constituent_snpst_flat
WHERE cdr_dt = :etl_date;


-- ============================================================
-- 14. [2383] nuoc-ngoai-theo-chi-so-intraday  →  mart.gstt_fct_foreign_trading_by_index_intraday_flat
--    Nguồn: datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: dinh_gia_theo_pe_pb
-- ============================================================
DELETE FROM mart.gstt_fct_foreign_trading_by_index_intraday_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_foreign_trading_by_index_intraday_flat
SELECT
    cdr_dt,
    symbol,
    index_code,
    idx_pe,
    idx_pb,
    toFloat64(idx_pe) / nullIf(toFloat64(idx_pb), 0) AS dinh_gia_theo_pe_pb
FROM datamart.gstt_fct_index_constituent_snpst_flat
WHERE cdr_dt = :etl_date;


-- ============================================================
-- 15. [2385] phan-loai-ndt  →  mart.gstt_fct_investor_category_trading_flat
--    Nguồn: datamart.gstt_fct_investor_category_trading_snpst_flat
--    Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
--    Grain: giữ grain flat nguồn
-- ============================================================
DELETE FROM mart.gstt_fct_investor_category_trading_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_investor_category_trading_flat
SELECT
    cdr_dt,
    symbol,
    investor_category_code,
    buy_val,
    sell_val,
    matched_buy_val,
    matched_sell_val
FROM datamart.gstt_fct_investor_category_trading_snpst_flat
WHERE cdr_dt = :etl_date;


-- ============================================================
-- 16. [2387] phan-loai-ndt-heatmap  →  mart.gstt_fct_investor_category_heatmap_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: gia_tri_binh_quan_mot_lenh
-- ============================================================
DELETE FROM mart.gstt_fct_investor_category_heatmap_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_investor_category_heatmap_flat
SELECT
    cdr_dt,
    symbol,
    total_matched_vol,
    total_matched_val,
    security_full_nm,
    floor_code,
    stock_tp_code,
    ceiling_price,
    floor_price,
    reference_price,
    close_price,
    price_change,
    toFloat64(total_matched_val) / nullIf(toFloat64(total_matched_vol), 0) AS gia_tri_binh_quan_mot_lenh
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03';


-- ============================================================
-- 17. [2386] phan-loai-ndt-index  →  mart.gstt_fct_investor_category_index_trading_flat
--    Nguồn: datamart.gstt_fct_investor_category_index_trading_snpst_flat
--    Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
--    Grain: giữ grain flat nguồn
-- ============================================================
DELETE FROM mart.gstt_fct_investor_category_index_trading_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_investor_category_index_trading_flat
SELECT
    cdr_dt,
    index_code,
    investor_category_code,
    buy_val,
    sell_val,
    matched_buy_val,
    matched_sell_val,
    market_index_val
FROM datamart.gstt_fct_investor_category_index_trading_snpst_flat
WHERE cdr_dt = :etl_date;


-- ============================================================
-- 18. [2378] tong-quan  →  mart.gstt_fct_market_overview_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: chenh_lech_von_hoa_freefloat_vs_thuong
-- ============================================================
DELETE FROM mart.gstt_fct_market_overview_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_market_overview_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    outstanding_share_quantity,
    free_float_share_quantity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    open_price,
    high_price,
    low_price,
    reference_price,
    close_price,
    price_change,
    idx_market_cap,
    idx_free_float_market_cap,
    toFloat64(close_price) * (toFloat64(outstanding_share_quantity) - toFloat64(free_float_share_quantity)) AS chenh_lech_von_hoa_freefloat_vs_thuong
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1')) AND s.floor_code != '03'
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 19. [2384] tu-doanh  →  mart.gstt_fct_proprietary_trading_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: bien_do_so_voi_tran
-- ============================================================
DELETE FROM mart.gstt_fct_proprietary_trading_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_proprietary_trading_flat
SELECT
    cdr_dt,
    symbol,
    proprietary_buy_val,
    proprietary_sell_val,
    proprietary_buy_vol,
    proprietary_sell_vol,
    security_full_nm,
    floor_code,
    stock_tp_code,
    ceiling_price,
    floor_price,
    reference_price,
    close_price,
    price_change,
    (toFloat64(ceiling_price) - toFloat64(close_price)) / nullIf(toFloat64(ceiling_price) - toFloat64(floor_price), 0) * 100 AS bien_do_so_voi_tran
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03';


-- ============================================================
-- 20. [2397] co-dong-lon  →  mart.ndtnn_fct_major_shareholder_flat
--    Nguồn: datamart.ndtnn_fct_public_company_foreign_ownership_snpst_flat
--    Universe/lọc tĩnh: không lọc thêm (chỉ lọc ngày)
--    Grain: giữ grain flat nguồn
-- ============================================================
DELETE FROM mart.ndtnn_fct_major_shareholder_flat ON CLUSTER 'my_cluster'
WHERE snpst_cdr_dt = :etl_date;
INSERT INTO mart.ndtnn_fct_major_shareholder_flat
SELECT
    snpst_cdr_dt,
    equity_ticker_symbol,
    ticker_symbol,
    total_issued_share_quantity,
    current_foreign_holding_quantity
FROM datamart.ndtnn_fct_public_company_foreign_ownership_snpst_flat
WHERE snpst_cdr_dt = :etl_date;


-- ============================================================
-- 21. [2371] top-dot-pha-theo-chi-so  →  mart.gstt_fct_breakout_by_index_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: ty_trong_gtgd_phai_sinh
-- ============================================================
DELETE FROM mart.gstt_fct_breakout_by_index_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_breakout_by_index_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_matched_vol,
    total_matched_val,
    total_derivative_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    toFloat64(total_derivative_val) / nullIf(toFloat64(total_matched_val), 0) * 100 AS ty_trong_gtgd_phai_sinh
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1')) AND s.floor_code != '03'
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 22. [2370] top-dot-pha-theo-san  →  mart.gstt_fct_breakout_by_exchange_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
-- ============================================================
DELETE FROM mart.gstt_fct_breakout_by_exchange_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_breakout_by_exchange_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1'))
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 23. [2369] top-dot-pha-toan-tt  →  mart.gstt_fct_breakout_market_wide_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: chenh_lech_gia_dong_vs_mo_cua_pct
-- ============================================================
DELETE FROM mart.gstt_fct_breakout_market_wide_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_breakout_market_wide_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    open_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    (toFloat64(close_price) - toFloat64(open_price)) / nullIf(toFloat64(open_price), 0) * 100 AS chenh_lech_gia_dong_vs_mo_cua_pct
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1')) AND s.floor_code != '03'
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 24. [2362] top-giam-gia-theo-chi-so  →  mart.gstt_fct_top_losers_by_index_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: bien_do_so_voi_san
-- ============================================================
DELETE FROM mart.gstt_fct_top_losers_by_index_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_top_losers_by_index_flat
SELECT
    cdr_dt,
    symbol,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    fct_close_price,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    ceiling_price,
    floor_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    (toFloat64(close_price) - toFloat64(floor_price)) / nullIf(toFloat64(ceiling_price) - toFloat64(floor_price), 0) * 100 AS bien_do_so_voi_san
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03';


-- ============================================================
-- 25. [2361] top-giam-gia-theo-san  →  mart.gstt_fct_top_losers_by_exchange_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: ty_trong_thoa_thuan
-- ============================================================
DELETE FROM mart.gstt_fct_top_losers_by_exchange_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_top_losers_by_exchange_flat
SELECT
    cdr_dt,
    symbol,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    fct_close_price,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    toFloat64(total_negotiated_vol) / nullIf(toFloat64(total_matched_vol) + toFloat64(total_negotiated_vol), 0) * 100 AS ty_trong_thoa_thuan
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1'));


-- ============================================================
-- 26. [2360] top-giam-gia-toan-tt  →  mart.gstt_fct_top_losers_market_wide_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: pe_uoc_tinh
-- ============================================================
DELETE FROM mart.gstt_fct_top_losers_market_wide_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_top_losers_market_wide_flat
SELECT
    cdr_dt,
    symbol,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    fct_close_price,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    toFloat64(close_price) * toFloat64(outstanding_share_quantity) / nullIf(toFloat64(net_profit_after_tax_ttm), 0) AS pe_uoc_tinh
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03';


-- ============================================================
-- 27. [2377] top-gt-theo-chi-so  →  mart.gstt_fct_top_value_by_index_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: ty_trong_von_hoa_trong_chi_so
-- ============================================================
DELETE FROM mart.gstt_fct_top_value_by_index_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_top_value_by_index_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    idx_market_cap,
    toFloat64(close_price) * toFloat64(outstanding_share_quantity) / nullIf(toFloat64(idx_market_cap), 0) * 100 AS ty_trong_von_hoa_trong_chi_so
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1')) AND s.floor_code != '03'
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 28. [2376] top-gt-theo-san  →  mart.gstt_fct_top_value_by_exchange_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: ty_trong_gtgd_tren_von_hoa
-- ============================================================
DELETE FROM mart.gstt_fct_top_value_by_exchange_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_top_value_by_exchange_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    toFloat64(total_matched_val) / nullIf(toFloat64(close_price) * toFloat64(outstanding_share_quantity), 0) * 100 AS ty_trong_gtgd_tren_von_hoa
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1'))
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 29. [2375] top-gt-toan-tt  →  mart.gstt_fct_top_value_market_wide_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: dong_gop_von_hoa_freefloat_idx
-- ============================================================
DELETE FROM mart.gstt_fct_top_value_market_wide_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_top_value_market_wide_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    free_float_share_quantity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    idx_free_float_market_cap,
    toFloat64(close_price) * toFloat64(free_float_share_quantity) / nullIf(toFloat64(idx_free_float_market_cap), 0) * 100 AS dong_gop_von_hoa_freefloat_idx
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1')) AND s.floor_code != '03'
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 30. [2356] top-kl-theo-chi-so  →  mart.gstt_fct_top_volume_by_index_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: ty_trong_klgd_tren_idx_level
-- ============================================================
DELETE FROM mart.gstt_fct_top_volume_by_index_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_top_volume_by_index_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    idx_market_index_val,
    toFloat64(total_matched_vol) / nullIf(toFloat64(idx_market_index_val), 0) AS ty_trong_klgd_tren_idx_level
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1')) AND s.floor_code != '03'
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 31. [2355] top-kl-theo-san  →  mart.gstt_fct_top_volume_by_exchange_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: ty_trong_gtgd_nn_tren_tong_gtgd
-- ============================================================
DELETE FROM mart.gstt_fct_top_volume_by_exchange_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_top_volume_by_exchange_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    foreign_buy_val,
    foreign_sell_val,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    (toFloat64(foreign_buy_val) + toFloat64(foreign_sell_val)) / nullIf(toFloat64(total_matched_val), 0) * 100 AS ty_trong_gtgd_nn_tren_tong_gtgd
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1'))
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 32. [2354] top-kl-toan-tt  →  mart.gstt_fct_top_volume_market_wide_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: bien_dao_dong_so_voi_idx_level
-- ============================================================
DELETE FROM mart.gstt_fct_top_volume_market_wide_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_top_volume_market_wide_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    high_price,
    low_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    idx_market_index_val,
    (toFloat64(high_price) - toFloat64(low_price)) / nullIf(toFloat64(idx_market_index_val), 0) * 100 AS bien_dao_dong_so_voi_idx_level
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1')) AND s.floor_code != '03'
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 33. [2374] top-nn-theo-chi-so  →  mart.gstt_fct_top_foreign_trading_by_index_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: eps_vs_chi_so_eps
-- ============================================================
DELETE FROM mart.gstt_fct_top_foreign_trading_by_index_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_top_foreign_trading_by_index_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    foreign_buy_vol,
    foreign_sell_vol,
    foreign_buy_val,
    foreign_sell_val,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    idx_eps,
    toFloat64(net_profit_after_tax_ttm) / nullIf(toFloat64(outstanding_share_quantity), 0) - toFloat64(idx_eps) AS eps_vs_chi_so_eps
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1')) AND s.floor_code != '03'
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 34. [2373] top-nn-theo-san  →  mart.gstt_fct_top_foreign_trading_by_exchange_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: ty_trong_klgd_nn_tren_tong_klgd
-- ============================================================
DELETE FROM mart.gstt_fct_top_foreign_trading_by_exchange_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_top_foreign_trading_by_exchange_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    foreign_buy_vol,
    foreign_sell_vol,
    foreign_buy_val,
    foreign_sell_val,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    (toFloat64(foreign_buy_vol) + toFloat64(foreign_sell_vol)) / nullIf(toFloat64(total_matched_vol), 0) * 100 AS ty_trong_klgd_nn_tren_tong_klgd
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1'))
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 35. [2372] top-nn-toan-tt  →  mart.gstt_fct_top_foreign_trading_market_wide_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: ty_le_von_hoa_so_voi_idx_level
-- ============================================================
DELETE FROM mart.gstt_fct_top_foreign_trading_market_wide_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_top_foreign_trading_market_wide_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    foreign_buy_vol,
    foreign_sell_vol,
    foreign_buy_val,
    foreign_sell_val,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    idx_market_index_val,
    toFloat64(close_price) * toFloat64(outstanding_share_quantity) / nullIf(toFloat64(idx_market_index_val), 0) AS ty_le_von_hoa_so_voi_idx_level
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1')) AND s.floor_code != '03'
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 36. [2359] top-tang-gia-theo-chi-so  →  mart.gstt_fct_top_gainers_by_index_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: pb_uoc_tinh
-- ============================================================
DELETE FROM mart.gstt_fct_top_gainers_by_index_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_top_gainers_by_index_flat
SELECT
    cdr_dt,
    symbol,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    fct_close_price,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    toFloat64(close_price) * toFloat64(outstanding_share_quantity) / nullIf(toFloat64(owner_equity), 0) AS pb_uoc_tinh
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03';


-- ============================================================
-- 37. [2358] top-tang-gia-theo-san  →  mart.gstt_fct_top_gainers_by_exchange_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: chenh_lech_gia_tran_san
-- ============================================================
DELETE FROM mart.gstt_fct_top_gainers_by_exchange_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_top_gainers_by_exchange_flat
SELECT
    cdr_dt,
    symbol,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    fct_close_price,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    ceiling_price,
    floor_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    ceiling_price - floor_price AS chenh_lech_gia_tran_san
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1'));


-- ============================================================
-- 38. [2357] top-tang-gia-toan-tt  →  mart.gstt_fct_top_gainers_market_wide_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: von_hoa_free_float
-- ============================================================
DELETE FROM mart.gstt_fct_top_gainers_market_wide_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_top_gainers_market_wide_flat
SELECT
    cdr_dt,
    symbol,
    total_vol,
    total_val,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    fct_close_price,
    free_float_share_quantity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    toFloat64(close_price) * toFloat64(free_float_share_quantity) AS von_hoa_free_float
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03';


-- ============================================================
-- 39. [2368] top-thung-day-theo-chi-so  →  mart.gstt_fct_new_low_by_index_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: khoang_cach_den_gia_san_pct
-- ============================================================
DELETE FROM mart.gstt_fct_new_low_by_index_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_new_low_by_index_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    high_price,
    low_price,
    floor_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    (toFloat64(close_price) - toFloat64(floor_price)) / nullIf(toFloat64(floor_price), 0) * 100 AS khoang_cach_den_gia_san_pct
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1')) AND s.floor_code != '03'
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 40. [2367] top-thung-day-theo-san  →  mart.gstt_fct_new_low_by_exchange_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: do_sau_thung_day_pct
-- ============================================================
DELETE FROM mart.gstt_fct_new_low_by_exchange_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_new_low_by_exchange_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    high_price,
    low_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    (toFloat64(reference_price) - toFloat64(low_price)) / nullIf(toFloat64(reference_price), 0) * 100 AS do_sau_thung_day_pct
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1'))
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 41. [2366] top-thung-day-toan-tt  →  mart.gstt_fct_new_low_market_wide_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: thanh_khoan_theo_freefloat
-- ============================================================
DELETE FROM mart.gstt_fct_new_low_market_wide_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_new_low_market_wide_flat
SELECT
    cdr_dt,
    symbol,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    free_float_share_quantity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    high_price,
    low_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    toFloat64(total_matched_vol) / nullIf(toFloat64(free_float_share_quantity), 0) * 100 AS thanh_khoan_theo_freefloat
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03';


-- ============================================================
-- 42. [2365] top-vuot-dinh-theo-chi-so  →  mart.gstt_fct_new_high_by_index_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: khoang_cach_den_gia_tran_pct
-- ============================================================
DELETE FROM mart.gstt_fct_new_high_by_index_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_new_high_by_index_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    high_price,
    low_price,
    ceiling_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    (toFloat64(ceiling_price) - toFloat64(close_price)) / nullIf(toFloat64(close_price), 0) * 100 AS khoang_cach_den_gia_tran_pct
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1')) AND s.floor_code != '03'
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 43. [2364] top-vuot-dinh-theo-san  →  mart.gstt_fct_new_high_by_exchange_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat, datamart.gstt_fct_index_constituent_snpst_flat
--    Universe/lọc tĩnh: U_EQ không loại sàn 03
--    Grain: 1 dòng / mã CK / chỉ số / ngày (mã không thuộc rổ nào: 1 dòng, cột rổ NULL)
--    Cột dẫn xuất: do_cao_vuot_dinh_pct
-- ============================================================
DELETE FROM mart.gstt_fct_new_high_by_exchange_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_new_high_by_exchange_flat
SELECT
    s.cdr_dt AS cdr_dt,
    s.symbol AS symbol,
    index_code,
    total_matched_vol,
    total_matched_val,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    high_price,
    low_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    (toFloat64(high_price) - toFloat64(reference_price)) / nullIf(toFloat64(reference_price), 0) * 100 AS do_cao_vuot_dinh_pct
FROM datamart.gstt_fct_stock_portfolio_snpst_flat s
     LEFT JOIN datamart.gstt_fct_index_constituent_snpst_flat b
       ON b.symbol = s.symbol AND b.cdr_dt = s.cdr_dt
WHERE s.cdr_dt = :etl_date
  AND NOT ((s.floor_code = '02' AND s.stock_tp_code IN ('1','4')) OR (s.floor_code = '10' AND s.stock_tp_code = '1'))
SETTINGS join_use_nulls = 1;


-- ============================================================
-- 44. [2363] top-vuot-dinh-toan-tt  →  mart.gstt_fct_new_high_market_wide_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_EQ (cổ phiếu/CCQ/CW: loại trái phiếu HOSE/HNX, phái sinh HNX, sàn 03)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: ty_trong_klgd_phai_sinh
-- ============================================================
DELETE FROM mart.gstt_fct_new_high_market_wide_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_new_high_market_wide_flat
SELECT
    cdr_dt,
    symbol,
    total_matched_vol,
    total_matched_val,
    total_derivative_vol,
    total_negotiated_vol,
    total_negotiated_val,
    outstanding_share_quantity,
    net_profit_after_tax_ttm,
    owner_equity,
    securities_company_net_profit_after_tax_ttm,
    securities_company_owner_equity,
    security_full_nm,
    floor_code,
    stock_tp_code,
    stock_tp_nm,
    high_price,
    low_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    toFloat64(total_derivative_vol) / nullIf(toFloat64(total_matched_vol), 0) * 100 AS ty_trong_klgd_phai_sinh
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1')) AND floor_code != '03';


-- ============================================================
-- 45. [2337] bang-trai-phieu  →  mart.gstt_fct_bond_list_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_BOND (stock_tp_code=1, sàn 04/10/03/02)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: klgd_rong
-- ============================================================
DELETE FROM mart.gstt_fct_bond_list_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_bond_list_flat
SELECT
    cdr_dt,
    symbol,
    total_matched_vol,
    total_negotiated_vol,
    bond_trading_vol,
    bond_negotiated_vol,
    bond_trading_val,
    bond_negotiated_val,
    security_full_nm,
    floor_code,
    stock_tp_code,
    issuer_nm,
    maturity_dt,
    coupon_rate,
    yield,
    open_price,
    reference_price,
    close_price,
    price_change,
    classification_business_line_nm,
    total_matched_vol - total_negotiated_vol AS klgd_rong
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND stock_tp_code = '1' AND floor_code IN ('04','10','03','02');


-- ============================================================
-- 46. [2392] lich-su-gia-khoi-luong  →  mart.gstt_fct_price_volume_history_flat
--    Nguồn: datamart.gstt_fct_stock_portfolio_snpst_flat
--    Universe/lọc tĩnh: U_BOND (stock_tp_code=1, sàn 04/10/03/02)
--    Grain: giữ grain flat nguồn
--    Cột dẫn xuất: bien_dong_gia_tuyet_doi
-- ============================================================
DELETE FROM mart.gstt_fct_price_volume_history_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO mart.gstt_fct_price_volume_history_flat
SELECT
    cdr_dt,
    symbol,
    bond_trading_vol,
    floor_code,
    stock_tp_code,
    high_price,
    low_price,
    close_price,
    high_price - low_price AS bien_dong_gia_tuyet_doi
FROM datamart.gstt_fct_stock_portfolio_snpst_flat
WHERE cdr_dt = :etl_date
  AND stock_tp_code = '1' AND floor_code IN ('04','10','03','02');
