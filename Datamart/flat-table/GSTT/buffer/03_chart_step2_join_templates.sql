-- ============================================================
-- GSTT Buffer — SQL chart bước 2 đã chỉnh cho 18 template join rổ chỉ số
-- Sinh: 2026-10-17 (bản nháp chưa chạy thử trên ClickHouse).
-- Lý do: buffer_chart_templates_v5.sql (và v4) viết s.cdr_dt / b.index_code / idx.cdr_dt nhưng FROM mart.<phân_hệ>_fct_*_flat không có alias
--        (buffer đã phẳng) nên các tham chiếu có tiền tố không resolve được.
-- Cách chỉnh (cơ học, không đổi logic):
--   1) FROM mart.<bảng buffer>  →  FROM mart.<bảng buffer> AS s
--   2) b.<cột> và idx.<cột>  →  s.<cột>   (mọi cột đã nằm trong cùng 1 bảng buffer)
--   3) s.*, s.index_code AS index_code  →  s.*   (bảng đã có cột index_code, tránh trùng tên)
-- Tham số {...:Date} / {...:String} giữ nguyên như file tham chiếu. Các template khác (27 bật + [2341] đã tắt ở v5) không cần chỉnh.
-- Cập nhật 2026-10-19: đổi tên bảng theo v5; bước 2 của v5 không đổi so với v4 nên các chỉnh cơ học ở trên vẫn đúng.
-- ============================================================

-- ===== [2352] dinh-gia =====
-- Bảng: mart.gstt_fct_index_valuation_flat | đổi: +alias s, 9 tiền tố b./idx. → s.
SELECT
     per_day.cdr_dt AS dt,
     any(per_day.index_code) AS k_gstt_4,
     any(per_day.close_price) AS k_gstt_10,
     any(per_day.idx_market_index_val) AS k_gstt_35,
     SUM(per_day.outstanding_share_quantity) AS k_gstt_55,
     SUM(per_day.net_profit_after_tax) AS k_gstt_56,
     SUM(per_day.owner_equity) AS k_gstt_57,
     any(per_day.idx_pe) AS k_gstt_149,
     any(per_day.idx_pb) AS k_gstt_150,
     any(per_day.idx_eps) AS k_gstt_151,
     any(per_day.idx_market_cap) AS k_gstt_61
 FROM (
     SELECT s.index_code AS index_code, s.cdr_dt AS cdr_dt, s.idx_market_cap AS idx_market_cap,
         s.idx_pe AS idx_pe, s.idx_pb AS idx_pb, s.idx_eps AS idx_eps,
         s.idx_market_index_val AS idx_market_index_val,
         s.close_price AS close_price, s.outstanding_share_quantity AS outstanding_share_quantity,
         s.net_profit_after_tax AS net_profit_after_tax, s.owner_equity AS owner_equity
     FROM mart.gstt_fct_index_valuation_flat AS s
WHERE s.cdr_dt BETWEEN {from_date:Date} AND {to_date:Date} AND
  s.index_code = {selected_index:String}) AS per_day
 GROUP BY per_day.cdr_dt
 ORDER BY per_day.cdr_dt


-- ===== [2378] tong-quan =====
-- Bảng: mart.gstt_fct_market_overview_flat | đổi: +alias s, 3 tiền tố b./idx. → s.
WITH raw AS (
     SELECT s.symbol, s.cdr_dt,
         any(s.security_full_nm) AS security_full_nm,
         any(s.close_price) AS close_price,
         any(s.reference_price) AS reference_price,
         any(s.price_change) AS price_change,
         any(s.open_price) AS open_price,
         any(s.high_price) AS high_price,
         any(s.low_price) AS low_price,
         any(s.total_matched_vol) AS total_vol,
         any(s.total_matched_val) AS total_val,
         any(s.outstanding_share_quantity) AS outstanding_share_quantity,
         any(s.free_float_share_quantity) AS free_float_share_quantity,
         any(s.idx_market_cap) AS idx_market_cap,
         any(s.idx_free_float_market_cap) AS idx_free_float_market_cap
     FROM mart.gstt_fct_market_overview_flat AS s
WHERE s.cdr_dt <= {to_date:Date} AND
  ({segment:String} = '' OR s.index_code = {segment:String})
     GROUP BY s.symbol, s.cdr_dt
 ),
 with_lag AS (
     -- [SỬA 2026-09-21] Bổ sung toFloat64() quanh mọi toán hạng Decimal trước khi nhân/lấy window —
     -- lượt bỏ round()/toDecimal64() trước đó lỡ bỏ luôn toFloat64(), khiến phép CHIA ở with_weight
     -- chạy bằng số học Decimal gốc của ClickHouse (tự động làm tròn về rất ít chữ số thập phân,
     -- có khi về nguyên) thay vì Float64 đầy đủ độ chính xác như ý định ban đầu.
     SELECT *,
         any(toFloat64(close_price) * toFloat64(outstanding_share_quantity)) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN {n_days:UInt32} PRECEDING AND {n_days:UInt32} PRECEDING) AS market_cap_n_ago,
         any(toFloat64(close_price) * toFloat64(free_float_share_quantity)) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN {n_days:UInt32} PRECEDING AND {n_days:UInt32} PRECEDING) AS ff_market_cap_n_ago,
         any(toFloat64(idx_market_cap)) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN {n_days:UInt32} PRECEDING AND {n_days:UInt32} PRECEDING) AS idx_market_cap_n_ago,
         any(toFloat64(idx_free_float_market_cap)) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN {n_days:UInt32} PRECEDING AND {n_days:UInt32} PRECEDING) AS idx_ff_market_cap_n_ago,
         any(toFloat64(reference_price)) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN {n_days:UInt32} PRECEDING AND {n_days:UInt32} PRECEDING) AS reference_price_n_ago
     FROM raw
 ),
 with_weight AS (
     SELECT *,
         market_cap_n_ago / nullIf(idx_market_cap_n_ago, 0) * 100 AS weight_pct,
         ff_market_cap_n_ago / nullIf(idx_ff_market_cap_n_ago, 0) * 100 AS weight_ff_pct,
         (CASE WHEN {n_days:UInt32} = 1
               THEN toFloat64(price_change) / nullIf(toFloat64(reference_price), 0)
               ELSE toFloat64(close_price) / nullIf(reference_price_n_ago, 0) - 1
          END) * 100 AS pct_change,
         -- Giá / Thay đổi (K_GSTT_11) / % thay đổi (K_GSTT_12) HIỂN THỊ luôn là số của NGÀY ĐẾN (to_date),
         -- không phụ thuộc n_days: day_pct_change = price_change / reference_price. pct_change ở trên (theo
         -- n_days) CHỈ dùng nội bộ để tính điểm đóng góp K_GSTT_74/75/76/124/125. FE trước đây tự tính
         -- thay đổi = price * pct / 100 (sai: % tính trên giá tham chiếu, không phải giá đóng cửa).
         toFloat64(price_change) / nullIf(toFloat64(reference_price), 0) * 100 AS day_pct_change
     FROM with_lag
 ),
 vol_daily AS (
     SELECT symbol, cdr_dt, any(total_matched_vol) AS total_vol
     FROM default.gstt_fct_stock_portfolio_snpst_flat
     WHERE NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1'))
     AND floor_code != '03'
     GROUP BY symbol, cdr_dt
 ),
 vol_avg AS (
     SELECT symbol, cdr_dt, total_vol,
         avg(total_vol) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING) AS avg_5d
     FROM vol_daily
 ),
 vol_ratio AS (
     SELECT symbol, floor(total_vol / (CASE WHEN isNaN(avg_5d) OR avg_5d = 0 THEN NULL ELSE avg_5d END) * 100 * 10 + 0.5) / 10 AS k_gstt_65
     FROM vol_avg
     WHERE cdr_dt = {to_date:Date}
 ),
 idx_hist AS (
     SELECT cdr_dt,
         any(market_index_val) OVER (ORDER BY cdr_dt ROWS BETWEEN {n_days:UInt32} PRECEDING AND {n_days:UInt32} PRECEDING) AS idx_level_n_ago
     FROM default.qlkd_fct_market_index_snpst_flat
     WHERE market_code = {segment:String} AND cdr_dt <= {to_date:Date}
 ),
 vol_range AS (
     -- [SỬA 2026-09-21] Đổi từ lọc theo from_date (tham số độc lập, có thể lệch với n_days nếu
     -- caller gửi sai/không đồng bộ — vd from_date=to_date nhưng n_days=5) sang window ROWS BETWEEN
     -- {n_days}-1 PRECEDING AND CURRENT ROW trên CTE `raw` (đúng N phiên gần nhất tính cả to_date,
     -- không phụ thuộc from_date nữa) — cùng cơ chế/cùng mốc t-n đã dùng cho with_lag, tự đúng bất
     -- kể from_date gửi lên là gì.
     SELECT symbol, cdr_dt,
         sum(total_vol) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN {n_days:UInt32} - 1 PRECEDING AND CURRENT ROW) AS total_vol_sum,
         sum(total_val) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN {n_days:UInt32} - 1 PRECEDING AND CURRENT ROW) AS total_val_sum
     FROM raw
 ),
 snapshot AS (
     SELECT * FROM with_weight WHERE cdr_dt = {to_date:Date}
 )
 SELECT
     snapshot.symbol AS symbol,
     any(snapshot.security_full_nm) AS security_full_nm,
     any(snapshot.close_price) AS k_gstt_10,
     any(snapshot.reference_price) AS k_gstt_9,
     any(snapshot.high_price) AS k_gstt_28,
     any(snapshot.low_price) AS k_gstt_29,
     any(snapshot.day_pct_change) AS k_gstt_12,
     any(snapshot.price_change) AS k_gstt_11,
     any(vol_range.total_vol_sum) AS k_gstt_13,
     any(vol_range.total_val_sum) AS k_gstt_14,
     any(snapshot.weight_pct) AS k_gstt_74,
     any(snapshot.weight_pct * snapshot.pct_change / 100) AS k_gstt_124,
     any(snapshot.weight_ff_pct * snapshot.pct_change / 100) AS k_gstt_125,
     -- K_GSTT_75/76 (điểm đóng góp TUYỆT ĐỐI, khác K_GSTT_124/125 là bản % tương đối ở trên)
     -- — mapping: K_GSTT_75 = K_GSTT_124/100 * Index(t-n) — lấy Index(t-n) từ idx_hist (cùng
     -- bảng qlkd_fct_market_index_snpst_flat như trước, mở rộng LAG N phiên thay vì cột
     -- prior_index cố định LAG 1).
     any(snapshot.weight_pct * snapshot.pct_change / 100 * idx_hist.idx_level_n_ago / 100) AS k_gstt_75,
     any(snapshot.weight_ff_pct * snapshot.pct_change / 100 * idx_hist.idx_level_n_ago / 100) AS k_gstt_76,
     any(snapshot.close_price * snapshot.outstanding_share_quantity) AS k_gstt_61,
     any(vol_ratio.k_gstt_65) AS k_gstt_65
 FROM snapshot
 LEFT JOIN vol_range ON vol_range.symbol = snapshot.symbol AND vol_range.cdr_dt = snapshot.cdr_dt
 LEFT JOIN vol_ratio ON vol_ratio.symbol = snapshot.symbol
 LEFT JOIN idx_hist ON idx_hist.cdr_dt = snapshot.cdr_dt
 GROUP BY snapshot.symbol
 ORDER BY k_gstt_14 DESC


-- ===== [2371] top-dot-pha-theo-chi-so =====
-- Bảng: mart.gstt_fct_breakout_by_index_flat | đổi: +alias s, 2 tiền tố b./idx. → s., gộp index_code
WITH filtered AS (
     SELECT s.*
     FROM mart.gstt_fct_breakout_by_index_flat AS s
WHERE ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm)) AND
  ({selected_index:String} = '' OR s.index_code = {selected_index:String})),
 per_day AS (
     SELECT symbol, cdr_dt,
         any(security_full_nm) AS security_full_nm,
         any(classification_business_line_nm) AS classification_business_line_nm,
         any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
         any(close_price) AS close_price,
         any(reference_price) AS reference_price,
         any(price_change) AS price_change,
         any(total_matched_vol) AS total_matched_vol,
         any(total_matched_val) AS total_matched_val,
         any(total_negotiated_vol) AS total_negotiated_vol,
         any(total_negotiated_val) AS total_negotiated_val,
         any(outstanding_share_quantity) AS outstanding_share_quantity,
         any(net_profit_after_tax_ttm) AS net_profit_after_tax_ttm, any(securities_company_net_profit_after_tax_ttm) AS securities_company_net_profit_after_tax_ttm,
         any(owner_equity) AS owner_equity, any(securities_company_owner_equity) AS securities_company_owner_equity
     FROM filtered
     GROUP BY symbol, cdr_dt
 ),
 with_avg AS (
     SELECT symbol, cdr_dt, security_full_nm, classification_business_line_nm, floor_code, stock_tp_nm,
         close_price, reference_price, price_change, total_matched_vol, total_matched_val, total_negotiated_vol, total_negotiated_val, outstanding_share_quantity, net_profit_after_tax_ttm, owner_equity, securities_company_net_profit_after_tax_ttm, securities_company_owner_equity,
         if(count() OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING) < 5, 0/0., avg(coalesce(total_matched_vol, 0)) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING)) AS avg_5d,
         if(count() OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) < 10, 0/0., avg(coalesce(total_matched_vol, 0)) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING)) AS avg_10d,
         if(count() OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 20 PRECEDING AND 1 PRECEDING) < 20, 0/0., avg(coalesce(total_matched_vol, 0)) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 20 PRECEDING AND 1 PRECEDING)) AS avg_20d
     FROM per_day
 )
 SELECT
     symbol, security_full_nm, classification_business_line_nm, floor_code, stock_tp_nm,
     total_matched_vol AS k_gstt_13,
     total_matched_val AS k_gstt_14,
     total_negotiated_vol AS k_gstt_17,
     total_negotiated_val AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     close_price AS k_gstt_10,
     price_change AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(price_change) / nullIf(toFloat64(reference_price), 0) * 100, 4), 2)) AS k_gstt_12,
     if(isNaN(avg_5d), NULL, toFloat64(round(toDecimal64(if(isNaN(avg_5d), 0., avg_5d), 2), 0))) AS k_gstt_64,
     floor(total_matched_vol / (CASE WHEN isNaN(avg_5d) OR avg_5d = 0 THEN NULL ELSE avg_5d END) * 100 * 10 + 0.5) / 10 AS k_gstt_65,
     if(isNaN(avg_10d), NULL, toFloat64(round(toDecimal64(if(isNaN(avg_10d), 0., avg_10d), 2), 0))) AS k_gstt_66,
     floor(total_matched_vol / (CASE WHEN isNaN(avg_10d) OR avg_10d = 0 THEN NULL ELSE avg_10d END) * 100 * 10 + 0.5) / 10 AS k_gstt_67,
     if(isNaN(avg_20d), NULL, toFloat64(round(toDecimal64(if(isNaN(avg_20d), 0., avg_20d), 2), 0))) AS k_gstt_68,
     floor(total_matched_vol / (CASE WHEN isNaN(avg_20d) OR avg_20d = 0 THEN NULL ELSE avg_20d END) * 100 * 10 + 0.5) / 10 AS k_gstt_69,
     outstanding_share_quantity AS k_gstt_55,
     net_profit_after_tax_ttm AS k_gstt_56,
     owner_equity AS k_gstt_57,
     (floor(abs((toFloat64(close_price) * toFloat64(outstanding_share_quantity)) / nullIf(toFloat64(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(close_price) * toFloat64(outstanding_share_quantity)) / nullIf(toFloat64(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm)), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(close_price) * toFloat64(outstanding_share_quantity)) / nullIf(toFloat64(coalesce(owner_equity, securities_company_owner_equity)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(close_price) * toFloat64(outstanding_share_quantity)) / nullIf(toFloat64(coalesce(owner_equity, securities_company_owner_equity)), 0)) AS k_gstt_59,
     close_price * outstanding_share_quantity AS k_gstt_61
 FROM with_avg
 WHERE cdr_dt = {selected_dt:Date}
   AND ( (avg_5d  > 0 AND total_matched_vol > avg_5d  * {min_ratio:Float64})
      OR (avg_10d > 0 AND total_matched_vol > avg_10d * {min_ratio:Float64})
      OR (avg_20d > 0 AND total_matched_vol > avg_20d * {min_ratio:Float64}) )
 ORDER BY greatest(k_gstt_65, k_gstt_67, k_gstt_69) DESC


-- ===== [2370] top-dot-pha-theo-san =====
-- Bảng: mart.gstt_fct_breakout_by_exchange_flat | đổi: +alias s, 1 tiền tố b./idx. → s.
WITH filtered AS (
     SELECT s.symbol, s.cdr_dt, s.security_full_nm, s.classification_business_line_nm, s.floor_code, s.stock_tp_nm,
         s.close_price, s.reference_price, s.price_change, s.total_matched_vol, s.total_matched_val, s.total_negotiated_vol, s.total_negotiated_val,
         s.outstanding_share_quantity, s.net_profit_after_tax_ttm, s.owner_equity, s.securities_company_net_profit_after_tax_ttm, s.securities_company_owner_equity
     FROM mart.gstt_fct_breakout_by_exchange_flat AS s
WHERE (({selected_floor:String} = 'HOSE' AND s.floor_code = '10')
            OR ({selected_floor:String} = 'HNX' AND s.floor_code = '02')
            OR ({selected_floor:String} = 'UPCOM' AND s.floor_code = '04')) AND
  ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm)) AND
  ({selected_index:String} = '' OR s.index_code = {selected_index:String})),
 per_day AS (
     SELECT symbol, cdr_dt,
         any(security_full_nm) AS security_full_nm,
         any(classification_business_line_nm) AS classification_business_line_nm,
         any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
         any(close_price) AS close_price,
         any(reference_price) AS reference_price,
         any(price_change) AS price_change,
         any(total_matched_vol) AS total_matched_vol,
         any(total_matched_val) AS total_matched_val,
         any(total_negotiated_vol) AS total_negotiated_vol,
         any(total_negotiated_val) AS total_negotiated_val,
         any(outstanding_share_quantity) AS outstanding_share_quantity,
         any(net_profit_after_tax_ttm) AS net_profit_after_tax_ttm, any(securities_company_net_profit_after_tax_ttm) AS securities_company_net_profit_after_tax_ttm,
         any(owner_equity) AS owner_equity, any(securities_company_owner_equity) AS securities_company_owner_equity
     FROM filtered
     GROUP BY symbol, cdr_dt
 ),
 with_avg AS (
     SELECT symbol, cdr_dt, security_full_nm, classification_business_line_nm, floor_code, stock_tp_nm,
         close_price, reference_price, price_change, total_matched_vol, total_matched_val, total_negotiated_vol, total_negotiated_val, outstanding_share_quantity, net_profit_after_tax_ttm, owner_equity, securities_company_net_profit_after_tax_ttm, securities_company_owner_equity,
         if(count() OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING) < 5, 0/0., avg(coalesce(total_matched_vol, 0)) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING)) AS avg_5d,
         if(count() OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) < 10, 0/0., avg(coalesce(total_matched_vol, 0)) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING)) AS avg_10d,
         if(count() OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 20 PRECEDING AND 1 PRECEDING) < 20, 0/0., avg(coalesce(total_matched_vol, 0)) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 20 PRECEDING AND 1 PRECEDING)) AS avg_20d
     FROM per_day
 )
 SELECT
     symbol, security_full_nm, classification_business_line_nm, floor_code, stock_tp_nm,
     total_matched_vol AS k_gstt_13,
     total_matched_val AS k_gstt_14,
     total_negotiated_vol AS k_gstt_17,
     total_negotiated_val AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     close_price AS k_gstt_10,
     price_change AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(price_change) / nullIf(toFloat64(reference_price), 0) * 100, 4), 2)) AS k_gstt_12,
     if(isNaN(avg_5d), NULL, toFloat64(round(toDecimal64(if(isNaN(avg_5d), 0., avg_5d), 2), 0))) AS k_gstt_64,
     floor(total_matched_vol / (CASE WHEN isNaN(avg_5d) OR avg_5d = 0 THEN NULL ELSE avg_5d END) * 100 * 10 + 0.5) / 10 AS k_gstt_65,
     if(isNaN(avg_10d), NULL, toFloat64(round(toDecimal64(if(isNaN(avg_10d), 0., avg_10d), 2), 0))) AS k_gstt_66,
     floor(total_matched_vol / (CASE WHEN isNaN(avg_10d) OR avg_10d = 0 THEN NULL ELSE avg_10d END) * 100 * 10 + 0.5) / 10 AS k_gstt_67,
     if(isNaN(avg_20d), NULL, toFloat64(round(toDecimal64(if(isNaN(avg_20d), 0., avg_20d), 2), 0))) AS k_gstt_68,
     floor(total_matched_vol / (CASE WHEN isNaN(avg_20d) OR avg_20d = 0 THEN NULL ELSE avg_20d END) * 100 * 10 + 0.5) / 10 AS k_gstt_69,
     outstanding_share_quantity AS k_gstt_55,
     net_profit_after_tax_ttm AS k_gstt_56,
     owner_equity AS k_gstt_57,
     (floor(abs((toFloat64(close_price) * toFloat64(outstanding_share_quantity)) / nullIf(toFloat64(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(close_price) * toFloat64(outstanding_share_quantity)) / nullIf(toFloat64(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm)), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(close_price) * toFloat64(outstanding_share_quantity)) / nullIf(toFloat64(coalesce(owner_equity, securities_company_owner_equity)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(close_price) * toFloat64(outstanding_share_quantity)) / nullIf(toFloat64(coalesce(owner_equity, securities_company_owner_equity)), 0)) AS k_gstt_59,
     close_price * outstanding_share_quantity AS k_gstt_61
 FROM with_avg
 WHERE cdr_dt = {selected_dt:Date}
   AND ( (avg_5d  > 0 AND total_matched_vol > avg_5d  * {min_ratio:Float64})
      OR (avg_10d > 0 AND total_matched_vol > avg_10d * {min_ratio:Float64})
      OR (avg_20d > 0 AND total_matched_vol > avg_20d * {min_ratio:Float64}) )
 ORDER BY greatest(k_gstt_65, k_gstt_67, k_gstt_69) DESC


-- ===== [2369] top-dot-pha-toan-tt =====
-- Bảng: mart.gstt_fct_breakout_market_wide_flat | đổi: +alias s, 1 tiền tố b./idx. → s., gộp index_code
WITH filtered AS (
     SELECT s.*
     FROM mart.gstt_fct_breakout_market_wide_flat AS s
WHERE ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm))),
 per_day AS (
     SELECT symbol, cdr_dt,
         any(security_full_nm) AS security_full_nm,
         any(classification_business_line_nm) AS classification_business_line_nm,
         any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
         any(close_price) AS close_price,
         any(reference_price) AS reference_price,
         any(price_change) AS price_change,
         any(total_matched_vol) AS total_matched_vol,
         any(total_matched_val) AS total_matched_val,
         any(total_negotiated_vol) AS total_negotiated_vol,
         any(total_negotiated_val) AS total_negotiated_val,
         any(outstanding_share_quantity) AS outstanding_share_quantity,
         any(net_profit_after_tax_ttm) AS net_profit_after_tax_ttm, any(securities_company_net_profit_after_tax_ttm) AS securities_company_net_profit_after_tax_ttm,
         any(owner_equity) AS owner_equity, any(securities_company_owner_equity) AS securities_company_owner_equity
     FROM filtered
     GROUP BY symbol, cdr_dt
 ),
 with_avg AS (
     SELECT symbol, cdr_dt, security_full_nm, classification_business_line_nm, floor_code, stock_tp_nm,
         close_price, reference_price, price_change, total_matched_vol, total_matched_val, total_negotiated_vol, total_negotiated_val, outstanding_share_quantity, net_profit_after_tax_ttm, owner_equity, securities_company_net_profit_after_tax_ttm, securities_company_owner_equity,
         if(count() OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING) < 5, 0/0., avg(coalesce(total_matched_vol, 0)) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING)) AS avg_5d,
         if(count() OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING) < 10, 0/0., avg(coalesce(total_matched_vol, 0)) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 10 PRECEDING AND 1 PRECEDING)) AS avg_10d,
         if(count() OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 20 PRECEDING AND 1 PRECEDING) < 20, 0/0., avg(coalesce(total_matched_vol, 0)) OVER (PARTITION BY symbol ORDER BY cdr_dt ROWS BETWEEN 20 PRECEDING AND 1 PRECEDING)) AS avg_20d
     FROM per_day
 )
 SELECT
     symbol, security_full_nm, classification_business_line_nm, floor_code, stock_tp_nm,
     total_matched_vol AS k_gstt_13,
     total_matched_val AS k_gstt_14,
     total_negotiated_vol AS k_gstt_17,
     total_negotiated_val AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     close_price AS k_gstt_10,
     price_change AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(price_change) / nullIf(toFloat64(reference_price), 0) * 100, 4), 2)) AS k_gstt_12,
     if(isNaN(avg_5d), NULL, toFloat64(round(toDecimal64(if(isNaN(avg_5d), 0., avg_5d), 2), 0))) AS k_gstt_64,
     floor(total_matched_vol / (CASE WHEN isNaN(avg_5d) OR avg_5d = 0 THEN NULL ELSE avg_5d END) * 100 * 10 + 0.5) / 10 AS k_gstt_65,
     if(isNaN(avg_10d), NULL, toFloat64(round(toDecimal64(if(isNaN(avg_10d), 0., avg_10d), 2), 0))) AS k_gstt_66,
     floor(total_matched_vol / (CASE WHEN isNaN(avg_10d) OR avg_10d = 0 THEN NULL ELSE avg_10d END) * 100 * 10 + 0.5) / 10 AS k_gstt_67,
     if(isNaN(avg_20d), NULL, toFloat64(round(toDecimal64(if(isNaN(avg_20d), 0., avg_20d), 2), 0))) AS k_gstt_68,
     floor(total_matched_vol / (CASE WHEN isNaN(avg_20d) OR avg_20d = 0 THEN NULL ELSE avg_20d END) * 100 * 10 + 0.5) / 10 AS k_gstt_69,
     outstanding_share_quantity AS k_gstt_55,
     net_profit_after_tax_ttm AS k_gstt_56,
     owner_equity AS k_gstt_57,
     (floor(abs((toFloat64(close_price) * toFloat64(outstanding_share_quantity)) / nullIf(toFloat64(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(close_price) * toFloat64(outstanding_share_quantity)) / nullIf(toFloat64(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm)), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(close_price) * toFloat64(outstanding_share_quantity)) / nullIf(toFloat64(coalesce(owner_equity, securities_company_owner_equity)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(close_price) * toFloat64(outstanding_share_quantity)) / nullIf(toFloat64(coalesce(owner_equity, securities_company_owner_equity)), 0)) AS k_gstt_59,
     close_price * outstanding_share_quantity AS k_gstt_61
 FROM with_avg
 WHERE cdr_dt = {selected_dt:Date}
   AND ( (avg_5d  > 0 AND total_matched_vol > avg_5d  * {min_ratio:Float64})
      OR (avg_10d > 0 AND total_matched_vol > avg_10d * {min_ratio:Float64})
      OR (avg_20d > 0 AND total_matched_vol > avg_20d * {min_ratio:Float64}) )
 ORDER BY greatest(k_gstt_65, k_gstt_67, k_gstt_69) DESC


-- ===== [2377] top-gt-theo-chi-so =====
-- Bảng: mart.gstt_fct_top_value_by_index_flat | đổi: +alias s, 2 tiền tố b./idx. → s., gộp index_code
WITH filtered AS (
     SELECT s.*
     FROM mart.gstt_fct_top_value_by_index_flat AS s
WHERE s.cdr_dt BETWEEN {from_date:Date} AND {to_date:Date} AND
  ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm)) AND
  ({selected_index:String} = '' OR s.index_code = {selected_index:String})),
 per_day AS (
     SELECT symbol, cdr_dt,
         any(security_full_nm) AS security_full_nm,
         any(classification_business_line_nm) AS classification_business_line_nm,
         any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
         any(total_matched_val) AS total_val,
        any(total_negotiated_vol) AS total_negotiated_vol,
        any(total_negotiated_val) AS total_negotiated_val,
         any(total_matched_vol) AS total_vol,
         any(close_price) AS close_price,
         any(reference_price) AS reference_price,
         any(price_change) AS price_change,
         any(outstanding_share_quantity) AS outstanding_share_quantity,
         any(net_profit_after_tax_ttm) AS net_profit_after_tax_ttm, any(securities_company_net_profit_after_tax_ttm) AS securities_company_net_profit_after_tax_ttm,
         any(owner_equity) AS owner_equity, any(securities_company_owner_equity) AS securities_company_owner_equity,
         groupUniqArray(index_code) AS index_codes
     FROM filtered
     GROUP BY symbol, cdr_dt
 )
 SELECT
     symbol,
     any(security_full_nm) AS security_full_nm,
     any(classification_business_line_nm) AS classification_business_line_nm,
     any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
     arrayStringConcat(arrayDistinct(arrayFlatten(groupArray(index_codes))), ',') AS index_codes,
     SUM(total_val) AS k_gstt_14,
     SUM(total_negotiated_vol) AS k_gstt_17,
     SUM(total_negotiated_val) AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     SUM(total_vol) AS k_gstt_13,
     argMax(close_price, cdr_dt) AS k_gstt_10,
     argMax(price_change, cdr_dt) AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(argMax(price_change, cdr_dt)) / nullIf(toFloat64(argMax(reference_price, cdr_dt)), 0) * 100, 4), 2)) AS k_gstt_12,
     argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_55,
     argMax(net_profit_after_tax_ttm, cdr_dt) AS k_gstt_56,
     argMax(owner_equity, cdr_dt) AS k_gstt_57,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) AS k_gstt_59,
     argMax(close_price, cdr_dt) * argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_61
 FROM per_day
 GROUP BY symbol
 HAVING k_gstt_14 > 0
 ORDER BY k_gstt_14 DESC


-- ===== [2376] top-gt-theo-san =====
-- Bảng: mart.gstt_fct_top_value_by_exchange_flat | đổi: +alias s, 2 tiền tố b./idx. → s.
WITH filtered AS (
     SELECT s.symbol, s.cdr_dt, s.security_full_nm, s.classification_business_line_nm, s.floor_code, s.stock_tp_nm,
         s.total_val, s.total_vol, s.total_matched_vol, s.total_matched_val, s.total_negotiated_vol, s.total_negotiated_val, s.close_price, s.reference_price, s.price_change, s.index_code AS index_code,
         s.outstanding_share_quantity, s.net_profit_after_tax_ttm, s.owner_equity, s.securities_company_net_profit_after_tax_ttm, s.securities_company_owner_equity
     FROM mart.gstt_fct_top_value_by_exchange_flat AS s
WHERE s.cdr_dt BETWEEN {from_date:Date} AND {to_date:Date} AND
  (({selected_floor:String} = 'HOSE' AND s.floor_code = '10')
            OR ({selected_floor:String} = 'HNX' AND s.floor_code = '02')
            OR ({selected_floor:String} = 'UPCOM' AND s.floor_code = '04')) AND
  ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm)) AND
  ({selected_index:String} = '' OR s.index_code = {selected_index:String})),
 per_day AS (
     SELECT symbol, cdr_dt,
         any(security_full_nm) AS security_full_nm,
         any(classification_business_line_nm) AS classification_business_line_nm,
         any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
         any(total_matched_val) AS total_val,
        any(total_negotiated_vol) AS total_negotiated_vol,
        any(total_negotiated_val) AS total_negotiated_val,
         any(total_matched_vol) AS total_vol,
         any(close_price) AS close_price,
         any(reference_price) AS reference_price,
         any(price_change) AS price_change,
         any(outstanding_share_quantity) AS outstanding_share_quantity,
         any(net_profit_after_tax_ttm) AS net_profit_after_tax_ttm, any(securities_company_net_profit_after_tax_ttm) AS securities_company_net_profit_after_tax_ttm,
         any(owner_equity) AS owner_equity, any(securities_company_owner_equity) AS securities_company_owner_equity,
         groupUniqArray(index_code) AS index_codes
     FROM filtered
     GROUP BY symbol, cdr_dt
 )
 SELECT
     symbol,
     any(security_full_nm) AS security_full_nm,
     any(classification_business_line_nm) AS classification_business_line_nm,
     any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
     arrayStringConcat(arrayDistinct(arrayFlatten(groupArray(index_codes))), ',') AS index_codes,
     SUM(total_val) AS k_gstt_14,
     SUM(total_negotiated_vol) AS k_gstt_17,
     SUM(total_negotiated_val) AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     SUM(total_vol) AS k_gstt_13,
     argMax(close_price, cdr_dt) AS k_gstt_10,
     argMax(price_change, cdr_dt) AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(argMax(price_change, cdr_dt)) / nullIf(toFloat64(argMax(reference_price, cdr_dt)), 0) * 100, 4), 2)) AS k_gstt_12,
     argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_55,
     argMax(net_profit_after_tax_ttm, cdr_dt) AS k_gstt_56,
     argMax(owner_equity, cdr_dt) AS k_gstt_57,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) AS k_gstt_59,
     argMax(close_price, cdr_dt) * argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_61
 FROM per_day
 GROUP BY symbol
 HAVING k_gstt_14 > 0
 ORDER BY k_gstt_14 DESC


-- ===== [2375] top-gt-toan-tt =====
-- Bảng: mart.gstt_fct_top_value_market_wide_flat | đổi: +alias s, 1 tiền tố b./idx. → s., gộp index_code
WITH filtered AS (
     SELECT s.*
     FROM mart.gstt_fct_top_value_market_wide_flat AS s
WHERE s.cdr_dt BETWEEN {from_date:Date} AND {to_date:Date} AND
  ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm))),
 per_day AS (
     SELECT symbol, cdr_dt,
         any(security_full_nm) AS security_full_nm,
         any(classification_business_line_nm) AS classification_business_line_nm,
         any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
         any(total_matched_val) AS total_val,
        any(total_negotiated_vol) AS total_negotiated_vol,
        any(total_negotiated_val) AS total_negotiated_val,
         any(total_matched_vol) AS total_vol,
         any(close_price) AS close_price,
         any(reference_price) AS reference_price,
         any(price_change) AS price_change,
         any(outstanding_share_quantity) AS outstanding_share_quantity,
         any(net_profit_after_tax_ttm) AS net_profit_after_tax_ttm, any(securities_company_net_profit_after_tax_ttm) AS securities_company_net_profit_after_tax_ttm,
         any(owner_equity) AS owner_equity, any(securities_company_owner_equity) AS securities_company_owner_equity,
         groupUniqArray(index_code) AS index_codes
     FROM filtered
     GROUP BY symbol, cdr_dt
 )
 SELECT
     symbol,
     any(security_full_nm) AS security_full_nm,
     any(classification_business_line_nm) AS classification_business_line_nm,
     any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
     arrayStringConcat(arrayDistinct(arrayFlatten(groupArray(index_codes))), ',') AS index_codes,
     SUM(total_val) AS k_gstt_14,
     SUM(total_negotiated_vol) AS k_gstt_17,
     SUM(total_negotiated_val) AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     SUM(total_vol) AS k_gstt_13,
     argMax(close_price, cdr_dt) AS k_gstt_10,
     argMax(price_change, cdr_dt) AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(argMax(price_change, cdr_dt)) / nullIf(toFloat64(argMax(reference_price, cdr_dt)), 0) * 100, 4), 2)) AS k_gstt_12,
     argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_55,
     argMax(net_profit_after_tax_ttm, cdr_dt) AS k_gstt_56,
     argMax(owner_equity, cdr_dt) AS k_gstt_57,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) AS k_gstt_59,
     argMax(close_price, cdr_dt) * argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_61
 FROM per_day
 GROUP BY symbol
 HAVING k_gstt_14 > 0
 ORDER BY k_gstt_14 DESC


-- ===== [2356] top-kl-theo-chi-so =====
-- Bảng: mart.gstt_fct_top_volume_by_index_flat | đổi: +alias s, 2 tiền tố b./idx. → s., gộp index_code
WITH filtered AS (
     SELECT s.*
     FROM mart.gstt_fct_top_volume_by_index_flat AS s
WHERE s.cdr_dt BETWEEN {from_date:Date} AND {to_date:Date} AND
  ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm)) AND
  ({selected_index:String} = '' OR s.index_code = {selected_index:String})),
 per_day AS (
     SELECT symbol, cdr_dt,
         any(security_full_nm) AS security_full_nm,
         any(classification_business_line_nm) AS classification_business_line_nm,
         any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
         any(total_matched_vol) AS total_vol,
         any(total_matched_val) AS total_val,
         any(total_negotiated_vol) AS total_negotiated_vol,
         any(total_negotiated_val) AS total_negotiated_val,
         any(close_price) AS close_price,
         any(reference_price) AS reference_price,
         any(price_change) AS price_change,
         any(outstanding_share_quantity) AS outstanding_share_quantity,
         any(net_profit_after_tax_ttm) AS net_profit_after_tax_ttm, any(securities_company_net_profit_after_tax_ttm) AS securities_company_net_profit_after_tax_ttm,
         any(owner_equity) AS owner_equity, any(securities_company_owner_equity) AS securities_company_owner_equity,
         groupUniqArray(index_code) AS index_codes
     FROM filtered
     GROUP BY symbol, cdr_dt
 )
 SELECT
     symbol,
     any(security_full_nm) AS security_full_nm,
     any(classification_business_line_nm) AS classification_business_line_nm,
     any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
     arrayStringConcat(arrayDistinct(arrayFlatten(groupArray(index_codes))), ',') AS index_codes,
     SUM(total_vol) AS k_gstt_13,
     SUM(total_val) AS k_gstt_14,
     SUM(total_negotiated_vol) AS k_gstt_17,
     SUM(total_negotiated_val) AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     argMax(close_price, cdr_dt) AS k_gstt_10,
     argMax(price_change, cdr_dt) AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(argMax(price_change, cdr_dt)) / nullIf(toFloat64(argMax(reference_price, cdr_dt)), 0) * 100, 4), 2)) AS k_gstt_12,
     argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_55,
     argMax(net_profit_after_tax_ttm, cdr_dt) AS k_gstt_56,
     argMax(owner_equity, cdr_dt) AS k_gstt_57,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) AS k_gstt_59,
     argMax(close_price, cdr_dt) * argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_61
 FROM per_day
 GROUP BY symbol
 HAVING k_gstt_13 > 0
 ORDER BY k_gstt_13 DESC


-- ===== [2355] top-kl-theo-san =====
-- Bảng: mart.gstt_fct_top_volume_by_exchange_flat | đổi: +alias s, 2 tiền tố b./idx. → s.
WITH filtered AS (
     SELECT s.symbol, s.cdr_dt, s.security_full_nm, s.classification_business_line_nm, s.floor_code, s.stock_tp_nm,
         s.total_vol, s.total_matched_vol, s.total_matched_val, s.total_negotiated_vol, s.total_negotiated_val, s.close_price, s.reference_price, s.price_change, s.index_code AS index_code,
         s.outstanding_share_quantity, s.net_profit_after_tax_ttm, s.owner_equity, s.securities_company_net_profit_after_tax_ttm, s.securities_company_owner_equity
     FROM mart.gstt_fct_top_volume_by_exchange_flat AS s
WHERE s.cdr_dt BETWEEN {from_date:Date} AND {to_date:Date} AND
  (({selected_floor:String} = 'HOSE' AND s.floor_code = '10')
            OR ({selected_floor:String} = 'HNX' AND s.floor_code = '02')
            OR ({selected_floor:String} = 'UPCOM' AND s.floor_code = '04')) AND
  ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm)) AND
  ({selected_index:String} = '' OR s.index_code = {selected_index:String})),
 per_day AS (
     SELECT symbol, cdr_dt,
         any(security_full_nm) AS security_full_nm,
         any(classification_business_line_nm) AS classification_business_line_nm,
         any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
         any(total_matched_vol) AS total_vol,
         any(total_matched_val) AS total_val,
         any(total_negotiated_vol) AS total_negotiated_vol,
         any(total_negotiated_val) AS total_negotiated_val,
         any(close_price) AS close_price,
         any(reference_price) AS reference_price,
         any(price_change) AS price_change,
         any(outstanding_share_quantity) AS outstanding_share_quantity,
         any(net_profit_after_tax_ttm) AS net_profit_after_tax_ttm, any(securities_company_net_profit_after_tax_ttm) AS securities_company_net_profit_after_tax_ttm,
         any(owner_equity) AS owner_equity, any(securities_company_owner_equity) AS securities_company_owner_equity,
         groupUniqArray(index_code) AS index_codes
     FROM filtered
     GROUP BY symbol, cdr_dt
 )
 SELECT
     symbol,
     any(security_full_nm) AS security_full_nm,
     any(classification_business_line_nm) AS classification_business_line_nm,
     any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
     arrayStringConcat(arrayDistinct(arrayFlatten(groupArray(index_codes))), ',') AS index_codes,
     SUM(total_vol) AS k_gstt_13,
     SUM(total_val) AS k_gstt_14,
     SUM(total_negotiated_vol) AS k_gstt_17,
     SUM(total_negotiated_val) AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     argMax(close_price, cdr_dt) AS k_gstt_10,
     argMax(price_change, cdr_dt) AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(argMax(price_change, cdr_dt)) / nullIf(toFloat64(argMax(reference_price, cdr_dt)), 0) * 100, 4), 2)) AS k_gstt_12,
     argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_55,
     argMax(net_profit_after_tax_ttm, cdr_dt) AS k_gstt_56,
     argMax(owner_equity, cdr_dt) AS k_gstt_57,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) AS k_gstt_59,
     argMax(close_price, cdr_dt) * argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_61
 FROM per_day
 GROUP BY symbol
 HAVING k_gstt_13 > 0
 ORDER BY k_gstt_13 DESC


-- ===== [2354] top-kl-toan-tt =====
-- Bảng: mart.gstt_fct_top_volume_market_wide_flat | đổi: +alias s, 1 tiền tố b./idx. → s., gộp index_code
WITH filtered AS (
     SELECT s.*
     FROM mart.gstt_fct_top_volume_market_wide_flat AS s
WHERE s.cdr_dt BETWEEN {from_date:Date} AND {to_date:Date} AND
  ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm))),
 per_day AS (
     SELECT symbol, cdr_dt,
         any(security_full_nm) AS security_full_nm,
         any(classification_business_line_nm) AS classification_business_line_nm,
         any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
         any(total_matched_vol) AS total_vol,
         any(total_matched_val) AS total_val,
         any(total_negotiated_vol) AS total_negotiated_vol,
         any(total_negotiated_val) AS total_negotiated_val,
         any(close_price) AS close_price,
         any(reference_price) AS reference_price,
         any(price_change) AS price_change,
         any(outstanding_share_quantity) AS outstanding_share_quantity,
         any(net_profit_after_tax_ttm) AS net_profit_after_tax_ttm, any(securities_company_net_profit_after_tax_ttm) AS securities_company_net_profit_after_tax_ttm,
         any(owner_equity) AS owner_equity, any(securities_company_owner_equity) AS securities_company_owner_equity,
         groupUniqArray(index_code) AS index_codes
     FROM filtered
     GROUP BY symbol, cdr_dt
 )
 SELECT
     symbol,
     any(security_full_nm) AS security_full_nm,
     any(classification_business_line_nm) AS classification_business_line_nm,
     any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
     arrayStringConcat(arrayDistinct(arrayFlatten(groupArray(index_codes))), ',') AS index_codes,
     SUM(total_vol) AS k_gstt_13,
     SUM(total_val) AS k_gstt_14,
     SUM(total_negotiated_vol) AS k_gstt_17,
     SUM(total_negotiated_val) AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     argMax(close_price, cdr_dt) AS k_gstt_10,
     argMax(price_change, cdr_dt) AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(argMax(price_change, cdr_dt)) / nullIf(toFloat64(argMax(reference_price, cdr_dt)), 0) * 100, 4), 2)) AS k_gstt_12,
     argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_55,
     argMax(net_profit_after_tax_ttm, cdr_dt) AS k_gstt_56,
     argMax(owner_equity, cdr_dt) AS k_gstt_57,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) AS k_gstt_59,
     argMax(close_price, cdr_dt) * argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_61
 FROM per_day
 GROUP BY symbol
 HAVING k_gstt_13 > 0
 ORDER BY k_gstt_13 DESC


-- ===== [2374] top-nn-theo-chi-so =====
-- Bảng: mart.gstt_fct_top_foreign_trading_by_index_flat | đổi: +alias s, 2 tiền tố b./idx. → s., gộp index_code
WITH filtered AS (
     SELECT s.*
     FROM mart.gstt_fct_top_foreign_trading_by_index_flat AS s
WHERE s.cdr_dt BETWEEN {from_date:Date} AND {to_date:Date} AND
  ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm)) AND
  ({selected_index:String} = '' OR s.index_code = {selected_index:String})),
 per_day AS (
     SELECT symbol, cdr_dt,
         any(security_full_nm) AS security_full_nm,
         any(classification_business_line_nm) AS classification_business_line_nm,
         any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
         any(total_matched_vol) AS total_vol,
         any(total_matched_val) AS total_val,
         any(total_negotiated_vol) AS total_negotiated_vol,
         any(total_negotiated_val) AS total_negotiated_val,
         any(close_price) AS close_price,
         any(reference_price) AS reference_price,
         any(price_change) AS price_change,
         any(foreign_buy_vol) AS foreign_buy_vol,
         any(foreign_sell_vol) AS foreign_sell_vol,
         any(foreign_buy_val) AS foreign_buy_val,
         any(foreign_sell_val) AS foreign_sell_val,
         any(outstanding_share_quantity) AS outstanding_share_quantity,
         any(net_profit_after_tax_ttm) AS net_profit_after_tax_ttm, any(securities_company_net_profit_after_tax_ttm) AS securities_company_net_profit_after_tax_ttm,
         any(owner_equity) AS owner_equity, any(securities_company_owner_equity) AS securities_company_owner_equity,
         groupUniqArray(index_code) AS index_codes
     FROM filtered
     GROUP BY symbol, cdr_dt
 )
 SELECT
     symbol,
     any(security_full_nm) AS security_full_nm,
     any(classification_business_line_nm) AS classification_business_line_nm,
     any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
     arrayStringConcat(arrayDistinct(arrayFlatten(groupArray(index_codes))), ',') AS index_codes,
     SUM(total_vol) AS k_gstt_13,
     SUM(total_val) AS k_gstt_14,
     SUM(total_negotiated_vol) AS k_gstt_17,
     SUM(total_negotiated_val) AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     (SUM(foreign_buy_vol) - SUM(foreign_sell_vol)) AS k_gstt_135,
     (SUM(foreign_buy_vol) - SUM(foreign_sell_vol)) AS k_gstt_136,
     (SUM(foreign_buy_vol) - SUM(foreign_sell_vol)) AS k_gstt_19,
     (SUM(foreign_buy_val) - SUM(foreign_sell_val)) AS k_gstt_137,
     (SUM(foreign_buy_val) - SUM(foreign_sell_val)) AS k_gstt_138,
     SUM(foreign_buy_vol) AS k_gstt_70,
     SUM(foreign_sell_vol) AS k_gstt_71,
     SUM(foreign_buy_val) AS k_gstt_72,
     SUM(foreign_sell_val) AS k_gstt_73,
     argMax(close_price, cdr_dt) AS k_gstt_10,
     argMax(price_change, cdr_dt) AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(argMax(price_change, cdr_dt)) / nullIf(toFloat64(argMax(reference_price, cdr_dt)), 0) * 100, 4), 2)) AS k_gstt_12,
     argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_55,
     argMax(net_profit_after_tax_ttm, cdr_dt) AS k_gstt_56,
     argMax(owner_equity, cdr_dt) AS k_gstt_57,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) AS k_gstt_59,
     argMax(close_price, cdr_dt) * argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_61
 FROM per_day
 GROUP BY symbol
 HAVING multiIf({metric:String} = 'kl_mua', k_gstt_135,
                {metric:String} = 'kl_ban', -k_gstt_136,
                {metric:String} = 'gt_mua', k_gstt_137,
                {metric:String} = 'gt_ban', -k_gstt_138,
                k_gstt_135) > 0
 ORDER BY multiIf({metric:String} = 'kl_mua', k_gstt_135,
                  {metric:String} = 'kl_ban', -k_gstt_136,
                  {metric:String} = 'gt_mua', k_gstt_137,
                  {metric:String} = 'gt_ban', -k_gstt_138,
                  k_gstt_135) DESC


-- ===== [2373] top-nn-theo-san =====
-- Bảng: mart.gstt_fct_top_foreign_trading_by_exchange_flat | đổi: +alias s, 2 tiền tố b./idx. → s.
WITH filtered AS (
     SELECT s.symbol, s.cdr_dt, s.security_full_nm, s.classification_business_line_nm, s.floor_code, s.stock_tp_nm,
         s.total_vol, s.total_matched_vol, s.total_matched_val, s.total_negotiated_vol, s.total_negotiated_val, s.close_price, s.reference_price, s.price_change, s.foreign_buy_vol, s.foreign_sell_vol,
         s.foreign_buy_val, s.foreign_sell_val, s.index_code AS index_code,
         s.outstanding_share_quantity, s.net_profit_after_tax_ttm, s.owner_equity, s.securities_company_net_profit_after_tax_ttm, s.securities_company_owner_equity
     FROM mart.gstt_fct_top_foreign_trading_by_exchange_flat AS s
WHERE s.cdr_dt BETWEEN {from_date:Date} AND {to_date:Date} AND
  (({selected_floor:String} = 'HOSE' AND s.floor_code = '10')
            OR ({selected_floor:String} = 'HNX' AND s.floor_code = '02')
            OR ({selected_floor:String} = 'UPCOM' AND s.floor_code = '04')) AND
  ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm)) AND
  ({selected_index:String} = '' OR s.index_code = {selected_index:String})),
 per_day AS (
     SELECT symbol, cdr_dt,
         any(security_full_nm) AS security_full_nm,
         any(classification_business_line_nm) AS classification_business_line_nm,
         any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
         any(total_matched_vol) AS total_vol,
         any(total_matched_val) AS total_val,
         any(total_negotiated_vol) AS total_negotiated_vol,
         any(total_negotiated_val) AS total_negotiated_val,
         any(close_price) AS close_price,
         any(reference_price) AS reference_price,
         any(price_change) AS price_change,
         any(foreign_buy_vol) AS foreign_buy_vol,
         any(foreign_sell_vol) AS foreign_sell_vol,
         any(foreign_buy_val) AS foreign_buy_val,
         any(foreign_sell_val) AS foreign_sell_val,
         any(outstanding_share_quantity) AS outstanding_share_quantity,
         any(net_profit_after_tax_ttm) AS net_profit_after_tax_ttm, any(securities_company_net_profit_after_tax_ttm) AS securities_company_net_profit_after_tax_ttm,
         any(owner_equity) AS owner_equity, any(securities_company_owner_equity) AS securities_company_owner_equity,
         groupUniqArray(index_code) AS index_codes
     FROM filtered
     GROUP BY symbol, cdr_dt
 )
 SELECT
     symbol,
     any(security_full_nm) AS security_full_nm,
     any(classification_business_line_nm) AS classification_business_line_nm,
     any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
     arrayStringConcat(arrayDistinct(arrayFlatten(groupArray(index_codes))), ',') AS index_codes,
     SUM(total_vol) AS k_gstt_13,
     SUM(total_val) AS k_gstt_14,
     SUM(total_negotiated_vol) AS k_gstt_17,
     SUM(total_negotiated_val) AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     (SUM(foreign_buy_vol) - SUM(foreign_sell_vol)) AS k_gstt_135,
     (SUM(foreign_buy_vol) - SUM(foreign_sell_vol)) AS k_gstt_136,
     (SUM(foreign_buy_vol) - SUM(foreign_sell_vol)) AS k_gstt_19,
     (SUM(foreign_buy_val) - SUM(foreign_sell_val)) AS k_gstt_137,
     (SUM(foreign_buy_val) - SUM(foreign_sell_val)) AS k_gstt_138,
     SUM(foreign_buy_vol) AS k_gstt_70,
     SUM(foreign_sell_vol) AS k_gstt_71,
     SUM(foreign_buy_val) AS k_gstt_72,
     SUM(foreign_sell_val) AS k_gstt_73,
     argMax(close_price, cdr_dt) AS k_gstt_10,
     argMax(price_change, cdr_dt) AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(argMax(price_change, cdr_dt)) / nullIf(toFloat64(argMax(reference_price, cdr_dt)), 0) * 100, 4), 2)) AS k_gstt_12,
     argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_55,
     argMax(net_profit_after_tax_ttm, cdr_dt) AS k_gstt_56,
     argMax(owner_equity, cdr_dt) AS k_gstt_57,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) AS k_gstt_59,
     argMax(close_price, cdr_dt) * argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_61
 FROM per_day
 GROUP BY symbol
 HAVING multiIf({metric:String} = 'kl_mua', k_gstt_135,
                {metric:String} = 'kl_ban', -k_gstt_136,
                {metric:String} = 'gt_mua', k_gstt_137,
                {metric:String} = 'gt_ban', -k_gstt_138,
                k_gstt_135) > 0
 ORDER BY multiIf({metric:String} = 'kl_mua', k_gstt_135,
                  {metric:String} = 'kl_ban', -k_gstt_136,
                  {metric:String} = 'gt_mua', k_gstt_137,
                  {metric:String} = 'gt_ban', -k_gstt_138,
                  k_gstt_135) DESC


-- ===== [2372] top-nn-toan-tt =====
-- Bảng: mart.gstt_fct_top_foreign_trading_market_wide_flat | đổi: +alias s, 1 tiền tố b./idx. → s., gộp index_code
WITH filtered AS (
     SELECT s.*
     FROM mart.gstt_fct_top_foreign_trading_market_wide_flat AS s
WHERE s.cdr_dt BETWEEN {from_date:Date} AND {to_date:Date} AND
  ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm))),
 per_day AS (
     SELECT symbol, cdr_dt,
         any(security_full_nm) AS security_full_nm,
         any(classification_business_line_nm) AS classification_business_line_nm,
         any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
         any(total_matched_vol) AS total_vol,
         any(total_matched_val) AS total_val,
         any(total_negotiated_vol) AS total_negotiated_vol,
         any(total_negotiated_val) AS total_negotiated_val,
         any(close_price) AS close_price,
         any(reference_price) AS reference_price,
         any(price_change) AS price_change,
         any(foreign_buy_vol) AS foreign_buy_vol,
         any(foreign_sell_vol) AS foreign_sell_vol,
         any(foreign_buy_val) AS foreign_buy_val,
         any(foreign_sell_val) AS foreign_sell_val,
         any(outstanding_share_quantity) AS outstanding_share_quantity,
         any(net_profit_after_tax_ttm) AS net_profit_after_tax_ttm, any(securities_company_net_profit_after_tax_ttm) AS securities_company_net_profit_after_tax_ttm,
         any(owner_equity) AS owner_equity, any(securities_company_owner_equity) AS securities_company_owner_equity,
         groupUniqArray(index_code) AS index_codes
     FROM filtered
     GROUP BY symbol, cdr_dt
 )
 SELECT
     symbol,
     any(security_full_nm) AS security_full_nm,
     any(classification_business_line_nm) AS classification_business_line_nm,
     any(floor_code) AS floor_code,
        any(stock_tp_nm) AS stock_tp_nm,
     arrayStringConcat(arrayDistinct(arrayFlatten(groupArray(index_codes))), ',') AS index_codes,
     SUM(total_vol) AS k_gstt_13,
     SUM(total_val) AS k_gstt_14,
     SUM(total_negotiated_vol) AS k_gstt_17,
     SUM(total_negotiated_val) AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     (SUM(foreign_buy_vol) - SUM(foreign_sell_vol)) AS k_gstt_135,
     (SUM(foreign_buy_vol) - SUM(foreign_sell_vol)) AS k_gstt_136,
     (SUM(foreign_buy_vol) - SUM(foreign_sell_vol)) AS k_gstt_19,
     (SUM(foreign_buy_val) - SUM(foreign_sell_val)) AS k_gstt_137,
     (SUM(foreign_buy_val) - SUM(foreign_sell_val)) AS k_gstt_138,
     SUM(foreign_buy_vol) AS k_gstt_70,
     SUM(foreign_sell_vol) AS k_gstt_71,
     SUM(foreign_buy_val) AS k_gstt_72,
     SUM(foreign_sell_val) AS k_gstt_73,
     argMax(close_price, cdr_dt) AS k_gstt_10,
     argMax(price_change, cdr_dt) AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(argMax(price_change, cdr_dt)) / nullIf(toFloat64(argMax(reference_price, cdr_dt)), 0) * 100, 4), 2)) AS k_gstt_12,
     argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_55,
     argMax(net_profit_after_tax_ttm, cdr_dt) AS k_gstt_56,
     argMax(owner_equity, cdr_dt) AS k_gstt_57,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(net_profit_after_tax_ttm, securities_company_net_profit_after_tax_ttm), cdr_dt)), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) * 100 + 0.5) / 100) * sign((toFloat64(argMax(close_price, cdr_dt)) * toFloat64(argMax(outstanding_share_quantity, cdr_dt))) / nullIf(toFloat64(argMax(coalesce(owner_equity, securities_company_owner_equity), cdr_dt)), 0)) AS k_gstt_59,
     argMax(close_price, cdr_dt) * argMax(outstanding_share_quantity, cdr_dt) AS k_gstt_61
 FROM per_day
 GROUP BY symbol
 HAVING multiIf({metric:String} = 'kl_mua', k_gstt_135,
                {metric:String} = 'kl_ban', -k_gstt_136,
                {metric:String} = 'gt_mua', k_gstt_137,
                {metric:String} = 'gt_ban', -k_gstt_138,
                k_gstt_135) > 0
 ORDER BY multiIf({metric:String} = 'kl_mua', k_gstt_135,
                  {metric:String} = 'kl_ban', -k_gstt_136,
                  {metric:String} = 'gt_mua', k_gstt_137,
                  {metric:String} = 'gt_ban', -k_gstt_138,
                  k_gstt_135) DESC


-- ===== [2368] top-thung-day-theo-chi-so =====
-- Bảng: mart.gstt_fct_new_low_by_index_flat | đổi: +alias s, 2 tiền tố b./idx. → s., gộp index_code
WITH cur AS (
     SELECT s.*
     FROM mart.gstt_fct_new_low_by_index_flat AS s
WHERE s.cdr_dt = {selected_dt:Date} AND
  ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm)) AND
  ({selected_index:String} = '' OR s.index_code = {selected_index:String})),
 prev AS (
     SELECT symbol, min(if(low_price > 0, low_price, close_price)) AS prev_min
     FROM default.gstt_fct_stock_portfolio_snpst_flat
     WHERE cdr_dt BETWEEN {from_date:Date} AND {selected_dt:Date} - 1
       AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1'))
       AND ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), stock_tp_nm))
       AND floor_code != '03'
     GROUP BY symbol
 )
 SELECT
     cur.symbol,
     any(cur.security_full_nm) AS security_full_nm,
     any(cur.classification_business_line_nm) AS classification_business_line_nm,
     any(cur.floor_code) AS floor_code,
        any(cur.stock_tp_nm) AS stock_tp_nm,
     any(cur.close_price) AS k_gstt_10,
     any(cur.price_change) AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(any(cur.price_change)) / nullIf(toFloat64(any(cur.reference_price)), 0) * 100, 4), 2)) AS k_gstt_12,
     any(prev.prev_min) AS k_gstt_142,
     any(cur.high_price) AS k_gstt_high_price,
     any(cur.low_price) AS k_gstt_low_price,
     any(cur.total_matched_vol) AS k_gstt_13,
     any(cur.total_matched_val) AS k_gstt_14,
     any(cur.total_negotiated_vol) AS k_gstt_17,
     any(cur.total_negotiated_val) AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     any(cur.outstanding_share_quantity) AS k_gstt_55,
     any(cur.net_profit_after_tax_ttm) AS k_gstt_56,
     any(cur.owner_equity) AS k_gstt_57,
     (floor(abs((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.net_profit_after_tax_ttm), any(cur.securities_company_net_profit_after_tax_ttm))), 0)) * 100 + 0.5) / 100) * sign((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.net_profit_after_tax_ttm), any(cur.securities_company_net_profit_after_tax_ttm))), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.owner_equity), any(cur.securities_company_owner_equity))), 0)) * 100 + 0.5) / 100) * sign((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.owner_equity), any(cur.securities_company_owner_equity))), 0)) AS k_gstt_59,
     any(cur.close_price) * any(cur.outstanding_share_quantity) AS k_gstt_61
 FROM cur
 JOIN prev ON prev.symbol = cur.symbol
 WHERE cur.low_price < prev.prev_min
 GROUP BY cur.symbol
 ORDER BY k_gstt_142 ASC


-- ===== [2367] top-thung-day-theo-san =====
-- Bảng: mart.gstt_fct_new_low_by_exchange_flat | đổi: +alias s, 2 tiền tố b./idx. → s., gộp index_code
WITH cur AS (
     SELECT s.*
     FROM mart.gstt_fct_new_low_by_exchange_flat AS s
WHERE s.cdr_dt = {selected_dt:Date} AND
  (({selected_floor:String} = 'HOSE' AND s.floor_code = '10')
            OR ({selected_floor:String} = 'HNX' AND s.floor_code = '02')
            OR ({selected_floor:String} = 'UPCOM' AND s.floor_code = '04')) AND
  ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm)) AND
  ({selected_index:String} = '' OR s.index_code = {selected_index:String})),
 prev AS (
     SELECT symbol, min(if(low_price > 0, low_price, close_price)) AS prev_min
     FROM default.gstt_fct_stock_portfolio_snpst_flat
     WHERE cdr_dt BETWEEN {from_date:Date} AND {selected_dt:Date} - 1
     GROUP BY symbol
 )
 SELECT
     cur.symbol,
     any(cur.security_full_nm) AS security_full_nm,
     any(cur.classification_business_line_nm) AS classification_business_line_nm,
     any(cur.floor_code) AS floor_code,
        any(cur.stock_tp_nm) AS stock_tp_nm,
     any(cur.close_price) AS k_gstt_10,
     any(cur.price_change) AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(any(cur.price_change)) / nullIf(toFloat64(any(cur.reference_price)), 0) * 100, 4), 2)) AS k_gstt_12,
     any(prev.prev_min) AS k_gstt_142,
     any(cur.high_price) AS k_gstt_high_price,
     any(cur.low_price) AS k_gstt_low_price,
     any(cur.total_matched_vol) AS k_gstt_13,
     any(cur.total_matched_val) AS k_gstt_14,
     any(cur.total_negotiated_vol) AS k_gstt_17,
     any(cur.total_negotiated_val) AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     any(cur.outstanding_share_quantity) AS k_gstt_55,
     any(cur.net_profit_after_tax_ttm) AS k_gstt_56,
     any(cur.owner_equity) AS k_gstt_57,
     (floor(abs((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.net_profit_after_tax_ttm), any(cur.securities_company_net_profit_after_tax_ttm))), 0)) * 100 + 0.5) / 100) * sign((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.net_profit_after_tax_ttm), any(cur.securities_company_net_profit_after_tax_ttm))), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.owner_equity), any(cur.securities_company_owner_equity))), 0)) * 100 + 0.5) / 100) * sign((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.owner_equity), any(cur.securities_company_owner_equity))), 0)) AS k_gstt_59,
     any(cur.close_price) * any(cur.outstanding_share_quantity) AS k_gstt_61
 FROM cur
 JOIN prev ON prev.symbol = cur.symbol
 WHERE cur.low_price < prev.prev_min
 GROUP BY cur.symbol
 ORDER BY k_gstt_142 ASC


-- ===== [2365] top-vuot-dinh-theo-chi-so =====
-- Bảng: mart.gstt_fct_new_high_by_index_flat | đổi: +alias s, 2 tiền tố b./idx. → s., gộp index_code
WITH cur AS (
     SELECT s.*
     FROM mart.gstt_fct_new_high_by_index_flat AS s
WHERE s.cdr_dt = {selected_dt:Date} AND
  ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm)) AND
  ({selected_index:String} = '' OR s.index_code = {selected_index:String})),
 prev AS (
     SELECT symbol, max(if(high_price > 0, high_price, close_price)) AS prev_max
     FROM default.gstt_fct_stock_portfolio_snpst_flat
     WHERE cdr_dt BETWEEN {from_date:Date} AND {selected_dt:Date} - 1
       AND NOT ((floor_code = '02' AND stock_tp_code IN ('1','4')) OR (floor_code = '10' AND stock_tp_code = '1'))
       AND ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), stock_tp_nm))
       AND floor_code != '03'
     GROUP BY symbol
 )
 SELECT
     cur.symbol,
     any(cur.security_full_nm) AS security_full_nm,
     any(cur.classification_business_line_nm) AS classification_business_line_nm,
     any(cur.floor_code) AS floor_code,
        any(cur.stock_tp_nm) AS stock_tp_nm,
     any(cur.close_price) AS k_gstt_10,
     any(cur.price_change) AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(any(cur.price_change)) / nullIf(toFloat64(any(cur.reference_price)), 0) * 100, 4), 2)) AS k_gstt_12,
     any(prev.prev_max) AS k_gstt_140,
     any(cur.high_price) AS k_gstt_high_price,
     any(cur.low_price) AS k_gstt_low_price,
     any(cur.total_matched_vol) AS k_gstt_13,
     any(cur.total_matched_val) AS k_gstt_14,
     any(cur.total_negotiated_vol) AS k_gstt_17,
     any(cur.total_negotiated_val) AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     any(cur.outstanding_share_quantity) AS k_gstt_55,
     any(cur.net_profit_after_tax_ttm) AS k_gstt_56,
     any(cur.owner_equity) AS k_gstt_57,
     (floor(abs((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.net_profit_after_tax_ttm), any(cur.securities_company_net_profit_after_tax_ttm))), 0)) * 100 + 0.5) / 100) * sign((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.net_profit_after_tax_ttm), any(cur.securities_company_net_profit_after_tax_ttm))), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.owner_equity), any(cur.securities_company_owner_equity))), 0)) * 100 + 0.5) / 100) * sign((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.owner_equity), any(cur.securities_company_owner_equity))), 0)) AS k_gstt_59,
     any(cur.close_price) * any(cur.outstanding_share_quantity) AS k_gstt_61
 FROM cur
 JOIN prev ON prev.symbol = cur.symbol
 WHERE cur.high_price > prev.prev_max
 GROUP BY cur.symbol
 ORDER BY k_gstt_140 DESC


-- ===== [2364] top-vuot-dinh-theo-san =====
-- Bảng: mart.gstt_fct_new_high_by_exchange_flat | đổi: +alias s, 2 tiền tố b./idx. → s., gộp index_code
WITH cur AS (
     SELECT s.*
     FROM mart.gstt_fct_new_high_by_exchange_flat AS s
WHERE s.cdr_dt = {selected_dt:Date} AND
  (({selected_floor:String} = 'HOSE' AND s.floor_code = '10')
            OR ({selected_floor:String} = 'HNX' AND s.floor_code = '02')
            OR ({selected_floor:String} = 'UPCOM' AND s.floor_code = '04')) AND
  ({security_type:String} = '' OR has(splitByChar(',', {security_type:String}), s.stock_tp_nm)) AND
  ({selected_index:String} = '' OR s.index_code = {selected_index:String})),
 prev AS (
     SELECT symbol, max(if(high_price > 0, high_price, close_price)) AS prev_max
     FROM default.gstt_fct_stock_portfolio_snpst_flat
     WHERE cdr_dt BETWEEN {from_date:Date} AND {selected_dt:Date} - 1
     GROUP BY symbol
 )
 SELECT
     cur.symbol,
     any(cur.security_full_nm) AS security_full_nm,
     any(cur.classification_business_line_nm) AS classification_business_line_nm,
     any(cur.floor_code) AS floor_code,
        any(cur.stock_tp_nm) AS stock_tp_nm,
     any(cur.close_price) AS k_gstt_10,
     any(cur.price_change) AS k_gstt_11,
     toFloat64(round(toDecimal64(toFloat64(any(cur.price_change)) / nullIf(toFloat64(any(cur.reference_price)), 0) * 100, 4), 2)) AS k_gstt_12,
     any(prev.prev_max) AS k_gstt_140,
     any(cur.high_price) AS k_gstt_high_price,
     any(cur.low_price) AS k_gstt_low_price,
     any(cur.total_matched_vol) AS k_gstt_13,
     any(cur.total_matched_val) AS k_gstt_14,
     any(cur.total_negotiated_vol) AS k_gstt_17,
     any(cur.total_negotiated_val) AS k_gstt_18,
    COALESCE(k_gstt_13, 0) + COALESCE(k_gstt_17, 0) AS k_gstt_146,
    COALESCE(k_gstt_14, 0) + COALESCE(k_gstt_18, 0) AS k_gstt_147,
     any(cur.outstanding_share_quantity) AS k_gstt_55,
     any(cur.net_profit_after_tax_ttm) AS k_gstt_56,
     any(cur.owner_equity) AS k_gstt_57,
     (floor(abs((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.net_profit_after_tax_ttm), any(cur.securities_company_net_profit_after_tax_ttm))), 0)) * 100 + 0.5) / 100) * sign((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.net_profit_after_tax_ttm), any(cur.securities_company_net_profit_after_tax_ttm))), 0)) AS k_gstt_58,
     (floor(abs((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.owner_equity), any(cur.securities_company_owner_equity))), 0)) * 100 + 0.5) / 100) * sign((toFloat64(any(cur.close_price)) * toFloat64(any(cur.outstanding_share_quantity))) / nullIf(toFloat64(coalesce(any(cur.owner_equity), any(cur.securities_company_owner_equity))), 0)) AS k_gstt_59,
     any(cur.close_price) * any(cur.outstanding_share_quantity) AS k_gstt_61
 FROM cur
 JOIN prev ON prev.symbol = cur.symbol
 WHERE cur.high_price > prev.prev_max
 GROUP BY cur.symbol
 ORDER BY k_gstt_140 DESC
