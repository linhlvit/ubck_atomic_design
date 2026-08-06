-- ============================================================
-- PTTT Flat Tables — CREATE
-- Module: Phân tích thị trường (PTTT)
-- Generated: Phase 3 LLD Datamart
-- 13 bảng: 12 fact (snapshot) + 1 operational
-- ============================================================


-- ============================================================
-- 1. FACT: pttt_fct_market_risk_snpst_flat
--    Chỉ số rủi ro hệ thống tổng hợp theo ngày
--    Grain: 1 row / ngày
--    Joins: Calendar Date (snpst_dt_dim_id JOIN)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_market_risk_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Market Risk Snapshot
    snpst_dt_dim_id                             String                  COMMENT 'FK → Calendar Date Dimension',
    volatility_30_days                          Nullable(Decimal(5,2))  COMMENT 'Biến động giá VN-Index 30 phiên',
    z_score_volatility                          Nullable(Decimal(5,2))  COMMENT 'Z-score Biến động giá',
    z_score_liquidity                           Nullable(Decimal(5,2))  COMMENT 'Z-score Thanh khoản ILLIQ',
    z_score_margin_balance                      Nullable(Decimal(5,2))  COMMENT 'Z-score Dư nợ Margin',
    z_score_interbank_rate                      Nullable(Decimal(5,2))  COMMENT 'Z-score Lãi suất liên ngân hàng',
    z_score_foreign_net_flow                    Nullable(Decimal(5,2))  COMMENT 'Z-score Dòng tiền ròng NĐTNN',
    total_market_cap                            Nullable(Decimal(23,2)) COMMENT 'Tổng vốn hóa thị trường MCAPt',
    margin_to_market_cap_ratio                  Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ Dư nợ Margin / Tổng vốn hóa Mt',
    beta_volatility                             Nullable(Decimal(5,2))  COMMENT 'Hệ số hồi quy β — Biến động chỉ số VN-Index',
    beta_liquidity                              Nullable(Decimal(5,2))  COMMENT 'Hệ số hồi quy β — Thanh khoản',
    beta_margin_balance                         Nullable(Decimal(5,2))  COMMENT 'Hệ số hồi quy β — Dư nợ Margin',
    beta_interbank_rate                         Nullable(Decimal(5,2))  COMMENT 'Hệ số hồi quy β — Lãi suất liên ngân hàng',
    beta_foreign_net_flow                       Nullable(Decimal(5,2))  COMMENT 'Hệ số hồi quy β — Dòng tiền ròng NĐTNN',
    beta_equity_capital_raising                 Nullable(Decimal(5,2))  COMMENT 'Hệ số hồi quy β — Huy động vốn cổ phần',
    beta_intercept                              Nullable(Decimal(5,2))  COMMENT 'Hằng số hồi quy β0',
    epsilon_error_term                          Nullable(Decimal(5,2))  COMMENT 'Sai số hồi quy ε',
    risk_index                                  Nullable(Decimal(5,2))  COMMENT 'Risk Index — Chỉ số rủi ro hệ thống tổng hợp',
    z_score_equity_capital_raising              Nullable(Decimal(5,2))  COMMENT 'Z-score Huy động vốn cổ phần',
    equity_capital_raising_amt                  Nullable(Decimal(23,2)) COMMENT 'Huy động vốn cổ phần thị trường tại ngày t',
    z_score_margin_balance_current              Nullable(Decimal(5,2))  COMMENT 'Z-score Dư nợ Margin — giá trị chuẩn hóa ngày t',
    margin_to_cap_ratio_stddev                  Nullable(Decimal(5,2))  COMMENT 'Độ lệch chuẩn chuỗi tỷ lệ Dư nợ Margin/MCAP',
    margin_to_cap_ratio_current                 Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ Dư nợ Margin / Tổng vốn hóa tại ngày t',
    margin_to_cap_ratio_avg                     Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ Dư nợ Margin / Tổng vốn hóa trung bình',
    index_log_return                            Nullable(Decimal(5,2))  COMMENT 'Log return chỉ số VN-Index ngày t',
    illiquidity_ratio                           Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ thanh khoản ILLIQ ngày t',
    foreign_net_flow                            Nullable(Decimal(23,2)) COMMENT 'Dòng tiền ròng NĐTNN ngày t',
    vnindex_val                                 Nullable(Decimal(23,2)) COMMENT 'Điểm chứng khoán VN-Index ngày t',
    weight_liquidity                            Nullable(Decimal(5,2))  COMMENT 'Trọng số W1 (S_liquidity)',
    weight_stability                            Nullable(Decimal(5,2))  COMMENT 'Trọng số W2 (S_stability)',
    sentiment_index                             Nullable(Decimal(5,2))  COMMENT 'Chỉ số tâm lý giao dịch toàn thị trường',
    sentiment_index_status                      Nullable(String)        COMMENT 'Ngưỡng trạng thái Sentiment Index',
    margin_tension                              Nullable(Decimal(5,2))  COMMENT 'Chỉ số độ căng margin',
    margin_tension_status                       Nullable(String)        COMMENT 'Ngưỡng trạng thái Margin Tension',
    vnindex_daily_return                        Nullable(Decimal(5,2))  COMMENT 'Lợi suất ngày VN-Index Rt',
    systemic_vol_current                        Nullable(Decimal(5,2))  COMMENT 'Độ lệch chuẩn biến động VN-Index 20 phiên (annualized)',
    systemic_vol_max                            Nullable(Decimal(5,2))  COMMENT 'Độ lệch chuẩn biến động VN-Index lịch sử tối đa',
    systemic_vol                                Nullable(Decimal(5,2))  COMMENT 'Chỉ số biến động hệ thống',
    systemic_vol_status                         Nullable(String)        COMMENT 'Ngưỡng trạng thái Systemic Vol',
    vnindex_val_previous_day                    Nullable(Decimal(23,2)) COMMENT 'Điểm chứng khoán VN-Index phiên trước',
    vnindex_daily_return_average                Nullable(Decimal(5,2))  COMMENT 'Lợi suất VN-Index trung bình N phiên',
    index_val_monthly_average                   Nullable(Decimal(23,2)) COMMENT 'Chỉ số Index bình quân tháng',
    total_trading_val_matched                   Nullable(Decimal(23,2)) COMMENT 'Tổng GTGD khớp lệnh toàn thị trường ngày t',
    total_trading_val_matched_previous_day      Nullable(Decimal(23,2)) COMMENT 'Tổng GTGD khớp lệnh ngày giao dịch trước',
    total_order_count_matched                   Nullable(Int64)         COMMENT 'Tổng số lệnh khớp toàn thị trường ngày t',
    average_order_size                          Nullable(Decimal(23,2)) COMMENT 'Quy mô lệnh khớp trung bình ngày t',
    total_trading_vol_matched                   Nullable(Decimal(23,2)) COMMENT 'Khối lượng giao dịch khớp lệnh toàn thị trường ngày t',
    total_trading_val_matched_average_50_days   Nullable(Decimal(23,2)) COMMENT 'GTGD MA50',
    total_trading_val_matched_average_n_days    Nullable(Decimal(23,2)) COMMENT 'GTGD bình quân N phiên',
    net_flow_foreign_average_30_days            Nullable(Decimal(23,2)) COMMENT 'Dòng tiền ròng NĐTNN trung bình 30 phiên',
    net_flow_proprietary_average_30_days        Nullable(Decimal(23,2)) COMMENT 'Dòng tiền ròng Tự doanh trung bình 30 phiên',
    net_flow_correlation_foreign_proprietary    Nullable(Decimal(5,2))  COMMENT 'Hệ số tương quan Pearson — NĐTNN & Tự doanh',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                                Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt))
COMMENT 'Flat table — Fact Market Risk Snapshot × Calendar Date Dimension'
;


-- ============================================================
-- 2. FACT: pttt_fct_investor_flow_snpst_flat
--    Dòng tiền mua/bán theo nhóm nhà đầu tư
--    Grain: 1 row / nhóm NĐT / ngày
--    Joins: Calendar Date (snpst_dt_dim_id JOIN) × Investor Group Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_investor_flow_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Investor Flow Snapshot
    snpst_dt_dim_id           String                  COMMENT 'FK → Calendar Date Dimension',
    investor_group_dim_id     String                  COMMENT 'FK → Investor Group Dimension',
    buy_val                   Nullable(Decimal(23,2)) COMMENT 'GTGD mua theo nhóm NĐT tại ngày t',
    sell_val                  Nullable(Decimal(23,2)) COMMENT 'GTGD bán theo nhóm NĐT tại ngày t',
    net_flow_val              Nullable(Decimal(23,2)) COMMENT 'Dòng tiền ròng theo nhóm NĐT tại ngày t',
    trading_val_ratio         Nullable(Decimal(5,2))  COMMENT 'Tỷ trọng GTGD nhóm NĐT trên tổng GTGD toàn thị trường',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt              Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension',

    -- From: INVESTOR GROUP DIMENSION
    investor_group_code       Nullable(String)        COMMENT 'Mã nhóm NĐT — từ Investor Group Dimension',
    investor_group_nm          Nullable(String)        COMMENT 'Tên nhóm NĐT — từ Investor Group Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), investor_group_dim_id)
COMMENT 'Flat table — Fact Investor Flow Snapshot × Calendar Date Dimension × Investor Group Dimension'
;


-- ============================================================
-- 3. FACT: pttt_fct_sector_risk_snpst_flat
--    Chỉ số áp lực, thanh khoản và sức khỏe tài chính theo ngành
--    Grain: 1 row / ngành / ngày
--    Joins: Calendar Date (snpst_dt_dim_id JOIN) × Industry Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_sector_risk_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Sector Risk Snapshot
    snpst_dt_dim_id     String                  COMMENT 'FK → Calendar Date Dimension',
    industry_dim_id       String                  COMMENT 'FK → Industry Dimension',
    total_val_sector    Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị giao dịch toàn bộ cổ phiếu trong ngành ngày t',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt        Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension',

    -- From: SECTOR DIMENSION
    industry_code          Nullable(String)        COMMENT 'Mã ngành nghề — từ Industry Dimension',
    industry_nm             Nullable(String)        COMMENT 'Tên ngành nghề — từ Industry Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), industry_dim_id)
COMMENT 'Flat table — Fact Sector Risk Snapshot × Calendar Date Dimension × Industry Dimension'
;


-- ============================================================
-- 4. FACT: pttt_fct_order_size_snpst_flat
--    GTGD và phân loại quy mô lệnh per mã CK theo ngày
--    Grain: 1 row / mã CK / ngày
--    Joins: Calendar Date (snpst_dt_dim_id JOIN)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_order_size_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Order Size Snapshot
    snpst_dt_dim_id             String                  COMMENT 'FK → Calendar Date Dimension',
    security_symbol_code        String                  COMMENT 'Mã chứng khoán',
    total_trading_val_matched   Nullable(Decimal(23,2)) COMMENT 'GTGD per mã CK tại ngày t',
    order_size_band             Nullable(String)        COMMENT 'Phân loại quy mô lệnh',
    total_trading_vol_matched   Nullable(Decimal(23,2)) COMMENT 'KL khớp lệnh tại ngày per mã CK',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), security_symbol_code)
COMMENT 'Flat table — Fact Order Size Snapshot × Calendar Date Dimension'
;


-- ============================================================
-- 5. FACT: pttt_fct_foreign_net_trade_snpst_flat
--    GTGD mua/bán/ròng NĐTNN per mã CK theo ngày
--    Grain: 1 row / mã CK / ngày
--    Joins: Calendar Date (snpst_dt_dim_id JOIN)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_foreign_net_trade_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Foreign Net Trade Snapshot
    snpst_dt_dim_id      String                  COMMENT 'FK → Calendar Date Dimension',
    security_symbol_code String                  COMMENT 'Mã chứng khoán',
    foreign_buy_val       Nullable(Decimal(23,2)) COMMENT 'GTGD mua NĐTNN per mã CK tại ngày t',
    foreign_sell_val      Nullable(Decimal(23,2)) COMMENT 'GTGD bán NĐTNN per mã CK tại ngày t',
    foreign_net_val        Nullable(Decimal(23,2)) COMMENT 'Dòng tiền ròng NĐTNN per mã CK tại ngày t',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt          Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), security_symbol_code)
COMMENT 'Flat table — Fact Foreign Net Trade Snapshot × Calendar Date Dimension'
;


-- ============================================================
-- 6. FACT: pttt_fct_proprietary_net_trade_snpst_flat
--    GTGD mua/bán/ròng tự doanh per mã CK theo ngày
--    Grain: 1 row / mã CK / ngày
--    Joins: Calendar Date (snpst_dt_dim_id JOIN)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_proprietary_net_trade_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Proprietary Net Trade Snapshot
    snpst_dt_dim_id       String                  COMMENT 'FK → Calendar Date Dimension',
    security_symbol_code  String                  COMMENT 'Mã chứng khoán',
    proprietary_buy_val    Nullable(Decimal(23,2)) COMMENT 'GTGD mua tự doanh per mã CK tại ngày t',
    proprietary_sell_val   Nullable(Decimal(23,2)) COMMENT 'GTGD bán tự doanh per mã CK tại ngày t',
    proprietary_net_val     Nullable(Decimal(23,2)) COMMENT 'Dòng tiền ròng tự doanh per mã CK tại ngày t',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt           Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), security_symbol_code)
COMMENT 'Flat table — Fact Proprietary Net Trade Snapshot × Calendar Date Dimension'
;


-- ============================================================
-- 7. FACT: pttt_fct_corporate_bond_market_snpst_flat
--    Quy mô thị trường TPDN tổng hợp toàn thị trường theo ngày
--    Grain: 1 row / ngày
--    Joins: Calendar Date (snpst_dt_dim_id JOIN)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_corporate_bond_market_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Corporate Bond Market Snapshot
    snpst_dt_dim_id                        String                  COMMENT 'FK → Calendar Date Dimension',
    par_val                                 Nullable(Decimal(23,2)) COMMENT 'Mệnh giá trái phiếu',
    outstanding_vol                         Nullable(Decimal(23,2)) COMMENT 'KL TP lưu hành toàn thị trường ngày t',
    bond_outstanding_val                    Nullable(Decimal(23,2)) COMMENT 'Tổng dư nợ trái phiếu toàn thị trường ngày t',
    maturity_pressure_12_months             Nullable(Decimal(23,2)) COMMENT 'Áp lực đáo hạn 12 tháng',
    maturity_pressure_12_months_previous    Nullable(Decimal(23,2)) COMMENT 'Áp lực đáo hạn 12 tháng tại kỳ liền trước',
    maturity_pressure_growth_percentage     Nullable(Decimal(5,2))  COMMENT 'Tăng trưởng áp lực đáo hạn',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                            Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt))
COMMENT 'Flat table — Fact Corporate Bond Market Snapshot × Calendar Date Dimension'
;


-- ============================================================
-- 8. FACT: pttt_fct_corporate_bond_maturity_wall_flat
--    Xếp hạng tín nhiệm + lịch biểu đáo hạn trái phiếu per mã TP
--    Grain: 1 row / mã TP / kỳ (quý)
--    Joins: Calendar Date (snpst_dt_dim_id JOIN) × Securities Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_corporate_bond_maturity_wall_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Corporate Bond Maturity Wall
    snpst_dt_dim_id      String            COMMENT 'FK → Calendar Date Dimension',
    securities_dim_id    String            COMMENT 'FK → Securities Dimension',
    ranking_code          Nullable(String)  COMMENT 'Xếp hạng tín nhiệm DN',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt          Nullable(Date)    COMMENT 'Ngày snapshot — từ Calendar Date Dimension',

    -- From: SECURITIES DIMENSION
    symbol                 Nullable(String)  COMMENT 'Mã chứng khoán — từ Securities Dimension',
    security_full_nm       Nullable(String)  COMMENT 'Tên đầy đủ chứng khoán — từ Securities Dimension',
    stock_tp_code          Nullable(String)  COMMENT 'Loại chứng khoán — từ Securities Dimension',
    floor_code             Nullable(String)  COMMENT 'Sàn giao dịch — từ Securities Dimension',
    listed_share_count     Nullable(Int64)   COMMENT 'Số lượng cổ phiếu niêm yết — từ Securities Dimension',
    total_listing_vol      Nullable(Int64)   COMMENT 'Tổng KL niêm yết — từ Securities Dimension',
    underlying_symbol      Nullable(String)  COMMENT 'Mã chỉ số cơ sở — từ Securities Dimension',
    issuer_nm              Nullable(String)  COMMENT 'Tên tổ chức phát hành — từ Securities Dimension',
    listing_dt             Nullable(Date)    COMMENT 'Ngày niêm yết — từ Securities Dimension',
    symbol_status_code     Nullable(String)  COMMENT 'Trạng thái mã — từ Securities Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), securities_dim_id)
COMMENT 'Flat table — Fact Corporate Bond Maturity Wall × Calendar Date Dimension × Securities Dimension'
;


-- ============================================================
-- 9. FACT: pttt_fct_corporate_bond_sector_snpst_flat
--    GTGD trái phiếu và tỷ trọng dư nợ theo ngành TCPH
--    Grain: 1 row / ngành TCPH / ngày
--    Joins: Calendar Date (snpst_dt_dim_id JOIN) × Corp Bond Industry Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_corporate_bond_sector_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Corporate Bond Sector Snapshot
    snpst_dt_dim_id             String                  COMMENT 'FK → Calendar Date Dimension',
    corp_bond_industry_dim_id     String                  COMMENT 'FK → Corp Bond Industry Dimension',
    bond_outstanding_val         Nullable(Decimal(23,2)) COMMENT 'Tổng dư nợ trái phiếu theo ngành TCPH tại ngày t',
    bond_outstanding_val_total   Nullable(Decimal(23,2)) COMMENT 'Dư nợ trái phiếu toàn thị trường tại ngày t',
    bond_outstanding_ratio       Nullable(Decimal(5,2))  COMMENT 'Tỷ trọng dư nợ trái phiếu theo ngành TCPH',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                 Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension',

    -- From: CORP BOND SECTOR DIMENSION
    industry_code                   Nullable(String)        COMMENT 'Mã ngành nghề TCPH — từ Corp Bond Industry Dimension',
    industry_nm                     Nullable(String)        COMMENT 'Tên ngành nghề TCPH — từ Corp Bond Industry Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), corp_bond_industry_dim_id)
COMMENT 'Flat table — Fact Corporate Bond Sector Snapshot × Calendar Date Dimension × Corp Bond Industry Dimension'
;


-- ============================================================
-- 10. FACT: pttt_fct_futures_intraday_snpst_flat
--    Biến động giá/KLGD trong phiên của HĐTL chỉ số (VN30/VN100)
--    Grain: 1 row / mã HĐTL / ngày
--    Joins: Calendar Date (snpst_dt_dim_id JOIN)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_futures_intraday_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Futures Intraday Snapshot
    snpst_dt_dim_id                              String                  COMMENT 'FK → Calendar Date Dimension',
    security_symbol_code                         String                  COMMENT 'Mã hợp đồng tương lai',
    underlying_symbol                            String                  COMMENT 'Mã chỉ số cơ sở (VN30/VN100)',
    maturity_month_year                          Nullable(String)        COMMENT 'Tháng đáo hạn hợp đồng',
    close_price                                  Nullable(Decimal(23,2)) COMMENT 'Giá đóng cửa HĐTL ngày t',
    reference_price                              Nullable(Decimal(23,2)) COMMENT 'Giá tham chiếu ngày t',
    price_change_percentage                      Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ thay đổi giá HĐTL',
    total_trading_vol_matched                    Nullable(Decimal(23,2)) COMMENT 'KLGD HĐTL ngày t',
    total_trading_vol_matched_average_50_days    Nullable(Decimal(23,2)) COMMENT 'KLGD HĐTL trung bình 50 phiên',
    liquidity_spike_ratio                        Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ đột biến thanh khoản HĐTL',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                                 Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), security_symbol_code)
COMMENT 'Flat table — Fact Futures Intraday Snapshot × Calendar Date Dimension'
;


-- ============================================================
-- 11. FACT: pttt_fct_futures_investor_flow_snpst_flat
--    GTGD mua/bán/dòng tiền ròng NĐTNN + Tự doanh trên HĐTL chỉ số
--    Grain: 1 row / mã HĐTL / ngày
--    Joins: Calendar Date (snpst_dt_dim_id JOIN)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_futures_investor_flow_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Futures Investor Flow Snapshot
    snpst_dt_dim_id         String                  COMMENT 'FK → Calendar Date Dimension',
    security_symbol_code    String                  COMMENT 'Mã hợp đồng tương lai',
    underlying_symbol       String                  COMMENT 'Mã chỉ số cơ sở (VN30/VN100)',
    foreign_buy_vol           Nullable(Decimal(23,2)) COMMENT 'KLGD NĐTNN mua HĐTL',
    foreign_sell_vol          Nullable(Decimal(23,2)) COMMENT 'KLGD NĐTNN bán HĐTL',
    foreign_net_vol            Nullable(Decimal(23,2)) COMMENT 'Dòng tiền ròng NĐTNN HĐTL',
    proprietary_buy_vol       Nullable(Decimal(23,2)) COMMENT 'KLGD Tự doanh mua HĐTL',
    proprietary_sell_vol      Nullable(Decimal(23,2)) COMMENT 'KLGD Tự doanh bán HĐTL',
    proprietary_net_vol        Nullable(Decimal(23,2)) COMMENT 'Dòng tiền ròng Tự doanh HĐTL',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt              Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), security_symbol_code)
COMMENT 'Flat table — Fact Futures Investor Flow Snapshot × Calendar Date Dimension'
;


-- ============================================================
-- 12. FACT: pttt_fct_market_statistics_snpst_flat
--    Bộ chỉ tiêu thống kê theo chỉ số (Data Explorer)
--    Grain: 1 row / chỉ số / ngày
--    Joins: Calendar Date (snpst_dt_dim_id JOIN)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_market_statistics_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Market Statistics Snapshot
    snpst_dt_dim_id                             String                  COMMENT 'FK → Calendar Date Dimension',
    market_code                                 String                  COMMENT 'Chiều Chỉ số (mã chỉ số/mã sàn)',
    total_trading_vol_matched                   Nullable(Decimal(23,2)) COMMENT 'KLGD theo chỉ số tại ngày t',
    close_price                                 Nullable(Decimal(23,2)) COMMENT 'Giá đóng cửa ngày t',
    close_price_previous_day                    Nullable(Decimal(23,2)) COMMENT 'Giá đóng cửa ngày t-1',
    price_change_percentage                     Nullable(Decimal(5,2))  COMMENT '% thay đổi giá',
    total_trading_val_matched                   Nullable(Decimal(23,2)) COMMENT 'GTGD phiên tại ngày t',
    total_trading_val_matched_average_50_days   Nullable(Decimal(23,2)) COMMENT 'GTGD trung bình 50 phiên (MA50)',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                                Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), market_code)
COMMENT 'Flat table — Fact Market Statistics Snapshot × Calendar Date Dimension'
;


-- ============================================================
-- 13. OPERATIONAL: pttt_opr_corporate_bond_issuer_credit_monitor_flat
--    Danh sách TCPH TPDN kèm chỉ tiêu tín dụng để giám sát rủi ro
--    Grain: 1 row / TCPH / ngày
--    Không JOIN Calendar Date, không JOIN dim nào
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_opr_corporate_bond_issuer_credit_monitor_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Corporate Bond Issuer Credit Monitor
    issuer_symbol_code    String                  COMMENT 'PK — mã TCPH (định danh qua mã TP)',
    snpst_dt               Date                    COMMENT 'PK — ngày thống kê',
    bond_outstanding_val   Nullable(Decimal(23,2)) COMMENT 'Dư nợ trái phiếu per TCPH tại ngày t',
    par_val                 Nullable(Decimal(23,2)) COMMENT 'Mệnh giá trái phiếu',
    outstanding_vol         Nullable(Decimal(23,2)) COMMENT 'KL TP lưu hành per TCPH tại ngày t',
    audit_opinion_text      Nullable(String)        COMMENT 'Ý kiến kiểm toán per TCPH',
    ranking_code             Nullable(String)        COMMENT 'Xếp hạng tín nhiệm per TCPH',
    risk_rating_text         Nullable(String)        COMMENT 'Xếp loại rủi ro per TCPH'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(snpst_dt)
ORDER BY (snpst_dt, issuer_symbol_code)
COMMENT 'Flat table — Operational Corporate Bond Issuer Credit Monitor'
;
