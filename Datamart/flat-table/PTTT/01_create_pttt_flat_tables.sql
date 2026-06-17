-- =============================================================================
-- PTTT (Phân tích thị trường) — Flat Tables DDL
-- Generated for ClickHouse ON CLUSTER 'my_cluster'
-- Engine: ReplicatedReplacingMergeTree()
-- 10 fact flat tables + 2 operational flat tables = 12 tables total
-- =============================================================================


-- =============================================================================
-- 1. pttt_fct_mkt_rsk_snpst_flat
--    Fact Market Risk Snapshot × Calendar Date Dimension
-- =============================================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_mkt_rsk_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT MARKET RISK SNAPSHOT
    snpst_dt_dim_id             String          COMMENT 'FK → Calendar Date Dimension',
    snpst_dt                    Date            COMMENT 'Ngày snapshot',
    vol_30d                     Nullable(Decimal(5,2))   COMMENT 'Độ lệch chuẩn lợi suất VN-Index 30 phiên (σ)',
    z_scr_vol                   Nullable(Decimal(5,2))   COMMENT 'Z-score biến động giá VN-Index',
    z_scr_lqdt                  Nullable(Decimal(5,2))   COMMENT 'Z-score thanh khoản ILLIQ',
    z_scr_mrgn                  Nullable(Decimal(5,2))   COMMENT 'Z-score dư nợ margin / MCAP',
    z_scr_ir                    Nullable(Decimal(5,2))   COMMENT 'Z-score lãi suất liên ngân hàng',
    z_scr_frgn_flw              Nullable(Decimal(5,2))   COMMENT 'Z-score dòng tiền ròng NĐTNN',
    mcap_total_bil_vnd          Nullable(Decimal(23,2))  COMMENT 'Tổng vốn hóa thị trường (tỷ VND)',
    mrgn_mcap_rto_pct           Nullable(Decimal(5,2))   COMMENT 'Tỷ lệ dư nợ margin / Tổng vốn hóa (%)',
    wgt_vol                     Nullable(Decimal(5,2))   COMMENT 'Tỷ trọng yếu tố biến động',
    wgt_lqdt                    Nullable(Decimal(5,2))   COMMENT 'Tỷ trọng yếu tố thanh khoản',
    wgt_mrgn                    Nullable(Decimal(5,2))   COMMENT 'Tỷ trọng yếu tố dư nợ margin',
    wgt_ir                      Nullable(Decimal(5,2))   COMMENT 'Tỷ trọng yếu tố lãi suất',
    wgt_frgn_flw                Nullable(Decimal(5,2))   COMMENT 'Tỷ trọng yếu tố dòng tiền NĐTNN',
    wgt_eqty_rse                Nullable(Decimal(5,2))   COMMENT 'Tỷ trọng yếu tố huy động vốn cổ phần',
    sentmnt_indx                Nullable(Decimal(5,2))   COMMENT 'Chỉ số tâm lý giao dịch toàn thị trường (0–100)',
    sentmnt_st                  Nullable(String)         COMMENT 'Trạng thái Sentiment Index',
    mrgn_tntn_pct               Nullable(Decimal(5,2))   COMMENT 'Chỉ số độ căng margin = Tổng dư nợ / Tổng hạn mức × 100',
    mrgn_tntn_st                Nullable(String)         COMMENT 'Trạng thái Margin Tension',
    systmc_vol_pct              Nullable(Decimal(5,2))   COMMENT 'Chỉ số biến động hệ thống',
    systmc_vol_st               Nullable(String)         COMMENT 'Trạng thái Systemic Vol',
    tdg_val_bil_vnd             Nullable(Decimal(23,2))  COMMENT 'Tổng GTGD khớp lệnh toàn thị trường ngày t (tỷ VND)',
    tdg_val_prev_dy_bil_vnd     Nullable(Decimal(23,2))  COMMENT 'Tổng GTGD khớp lệnh ngày giao dịch trước (tỷ VND)',
    tdg_val_pct_chg             Nullable(Decimal(5,2))   COMMENT '% thay đổi GTGD phiên so ngày trước',
    tdg_val_prd_tot_bil_vnd     Nullable(Decimal(23,2))  COMMENT 'Tổng GTGD tích lũy kỳ (tỷ VND)',
    mrgn_dbt_total_bil_vnd      Nullable(Decimal(23,2))  COMMENT 'Tổng dư nợ margin tất cả CTCK (tỷ VND)',
    avg_ordr_sz_mil_vnd         Nullable(Decimal(23,2))  COMMENT 'Quy mô lệnh trung bình (triệu VND)',
    tot_mtch_vol                Nullable(Int64)          COMMENT 'Tổng khối lượng khớp lệnh toàn thị trường',
    tdg_val_ma50_bil_vnd        Nullable(Decimal(23,2))  COMMENT 'Trung bình GTGD khớp lệnh 50 phiên giao dịch (tỷ VND)',
    mrgn_dbt_cur_bil_vnd        Nullable(Decimal(23,2))  COMMENT 'Dư nợ margin kỳ hiện tại (tỷ VND)',
    mrgn_dbt_prev_bil_vnd       Nullable(Decimal(23,2))  COMMENT 'Dư nợ margin kỳ liền trước (tỷ VND)',
    mrgn_dlt_bil_vnd            Nullable(Decimal(23,2))  COMMENT 'Δ Margin Balance (tỷ VND)',
    avg_tdg_val_n_dy_bil_vnd    Nullable(Decimal(23,2))  COMMENT 'GTGD bình quân N phiên gần nhất (tỷ VND)',
    mrgn_strs_pct               Nullable(Decimal(5,2))   COMMENT 'Tỷ lệ bão hòa đòn bẩy (%)',
    mrgn_strs_st                Nullable(String)         COMMENT 'Trạng thái Margin Stress',
    z_scr_eqty_rse              Nullable(Decimal(5,2))   COMMENT 'Z-score huy động vốn cổ phần — PENDING',
    rsk_indx                    Nullable(Decimal(5,2))   COMMENT 'Chỉ số rủi ro hệ thống tổng hợp RI — PENDING',
    indx_code                   String                   COMMENT 'Mã chỉ số (luôn = VNINDEX)',
    corr_vni_ir                 Nullable(Decimal(7,6))   COMMENT 'Hệ số tương quan Pearson VN-Index & Lãi suất LNH',
    corr_vni_dxy                Nullable(Decimal(7,6))   COMMENT 'Hệ số tương quan Pearson VN-Index & DXY',
    corr_vni_ir_st              Nullable(String)         COMMENT 'Trạng thái tương quan VN-Index & Lãi suất LNH',
    corr_vni_dxy_st             Nullable(String)         COMMENT 'Trạng thái tương quan VN-Index & DXY',
    vnidx_cls                   Nullable(Decimal(10,2))  COMMENT 'Giá đóng cửa VN-Index tại ngày snapshot',
    ir_val                      Nullable(Decimal(7,4))   COMMENT 'Lãi suất liên ngân hàng tại ngày snapshot',
    vnidx_mo_avg                Nullable(Decimal(10,2))  COMMENT 'Chỉ số VN-Index bình quân tháng',
    ir_mo_avg                   Nullable(Decimal(7,4))   COMMENT 'Lãi suất LNH bình quân tháng',
    -- Raw values tại ngày t (Nhóm 2 — Giá trị hiện tại)
    indx_log_rtn_t              Nullable(Decimal(10,8))  COMMENT 'Log return VN-Index tại ngày t — Rₜ = ln(Pₜ/Pₜ₋₁)',
    illiq_t                     Nullable(Decimal(20,10)) COMMENT 'ILLIQ tại ngày t — ILLIQₜ = |Rₜ| / VOLDₜ',
    ir_t_pct                    Nullable(Decimal(7,4))   COMMENT 'Lãi suất liên ngân hàng tại ngày t (%)',
    frgn_net_flw_t_bil          Nullable(Decimal(23,2))  COMMENT 'Dòng tiền ròng NĐTNN tại ngày t (tỷ VND)',
    eqty_rse_t_bil              Nullable(Decimal(23,2))  COMMENT 'Huy động vốn cổ phần tại ngày t (tỷ VND) — PENDING',
    -- From: CALENDAR DATE DIMENSION
    full_date                   Nullable(Date)           COMMENT 'Ngày đầy đủ — từ Calendar Date Dimension',
    day_of_week                 Nullable(String)         COMMENT 'Thứ trong tuần',
    day_of_week_num             Nullable(Int32)          COMMENT 'Số thứ tự ngày trong tuần (1=Mon)',
    week_of_year                Nullable(Int32)          COMMENT 'Tuần trong năm',
    month_num                   Nullable(Int32)          COMMENT 'Tháng',
    month_name                  Nullable(String)         COMMENT 'Tên tháng',
    quarter_num                 Nullable(Int32)          COMMENT 'Quý',
    year_num                    Nullable(Int32)          COMMENT 'Năm',
    is_trading_day              Nullable(UInt8)          COMMENT 'Cờ ngày giao dịch',
    -- Technical metadata
    ds_batch_date               Date                     COMMENT 'ETL batch date',
    ds_population_timestamp     DateTime                 COMMENT 'Population timestamp'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(snpst_dt)
ORDER BY (snpst_dt, indx_code)
COMMENT 'Flat table — Fact Market Risk Snapshot × Calendar Date Dimension'
;


-- =============================================================================
-- 2. pttt_fct_mcr_ind_snpst_flat
--    Fact Macro Indicator Snapshot × Calendar Date Dimension
-- =============================================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_mcr_ind_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT MACRO INDICATOR SNAPSHOT
    snpst_dt_dim_id             String          COMMENT 'FK → Calendar Date Dimension',
    ind_code                    String          COMMENT 'Mã chỉ tiêu vĩ mô (NK)',
    ind_nm                      Nullable(String)         COMMENT 'Tên chỉ tiêu vĩ mô',
    val                         Nullable(String)         COMMENT 'Giá trị chỉ tiêu',
    prd_dt                      Date            COMMENT 'Ngày kỳ báo cáo (Driving Date)',
    prd_tp_code                 Nullable(String)         COMMENT 'Loại kỳ: 1=ngày 2=tuần 3=tháng 4=quý',
    -- From: CALENDAR DATE DIMENSION
    full_date                   Nullable(Date)           COMMENT 'Ngày đầy đủ — từ Calendar Date Dimension',
    day_of_week                 Nullable(String)         COMMENT 'Thứ trong tuần',
    day_of_week_num             Nullable(Int32)          COMMENT 'Số thứ tự ngày trong tuần (1=Mon)',
    week_of_year                Nullable(Int32)          COMMENT 'Tuần trong năm',
    month_num                   Nullable(Int32)          COMMENT 'Tháng',
    month_name                  Nullable(String)         COMMENT 'Tên tháng',
    quarter_num                 Nullable(Int32)          COMMENT 'Quý',
    year_num                    Nullable(Int32)          COMMENT 'Năm',
    is_trading_day              Nullable(UInt8)          COMMENT 'Cờ ngày giao dịch',
    -- Technical metadata
    ds_batch_date               Date                     COMMENT 'ETL batch date',
    ds_population_timestamp     DateTime                 COMMENT 'Population timestamp'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(prd_dt)
ORDER BY (prd_dt, ind_code)
COMMENT 'Flat table — Fact Macro Indicator Snapshot × Calendar Date Dimension'
;


-- =============================================================================
-- 3. pttt_fct_sctr_rsk_snpst_flat
--    Fact Sector Risk Snapshot × Calendar Date Dimension × Sector Dimension
-- =============================================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_sctr_rsk_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT SECTOR RISK SNAPSHOT
    snpst_dt_dim_id             String          COMMENT 'FK → Calendar Date Dimension',
    sctr_dim_id                 String          COMMENT 'FK → Sector Dimension',
    snpst_dt                    Date            COMMENT 'Ngày snapshot',
    sctr_avg_pdrwdwn            Nullable(Decimal(5,2))   COMMENT 'Price Drawdown trung bình ngành (%)',
    sctr_avg_pvol               Nullable(Decimal(5,2))   COMMENT 'Pvolatility trung bình ngành (%)',
    sctr_avg_pslng              Nullable(Decimal(5,2))   COMMENT 'Pselling trung bình ngành (%)',
    sctr_avg_strs_scr           Nullable(Decimal(5,2))   COMMENT 'StressScore ngành bình quân',
    sctr_tot_val                Nullable(Decimal(23,2))  COMMENT 'Tổng GTGD ngành tại ngày snapshot (tỷ VND)',
    sctr_dbt_scr                Nullable(Decimal(5,2))   COMMENT 'D/E ratio ngành từ BCTC năm gần nhất (%)',
    sctr_strs_scr_wgtd          Nullable(Decimal(5,2))   COMMENT 'Stress Score ngành có trọng số vốn hóa — PENDING',
    sctr_strs_dlt               Nullable(Decimal(5,2))   COMMENT 'Biến động Stress Score kỳ này − kỳ trước — PENDING',
    sctr_rtg                    Nullable(String)         COMMENT 'Xếp hạng ngành — PENDING',
    -- From: CALENDAR DATE DIMENSION
    full_date                   Nullable(Date)           COMMENT 'Ngày đầy đủ — từ Calendar Date Dimension',
    day_of_week                 Nullable(String)         COMMENT 'Thứ trong tuần',
    day_of_week_num             Nullable(Int32)          COMMENT 'Số thứ tự ngày trong tuần (1=Mon)',
    week_of_year                Nullable(Int32)          COMMENT 'Tuần trong năm',
    month_num                   Nullable(Int32)          COMMENT 'Tháng',
    month_name                  Nullable(String)         COMMENT 'Tên tháng',
    quarter_num                 Nullable(Int32)          COMMENT 'Quý',
    year_num                    Nullable(Int32)          COMMENT 'Năm',
    is_trading_day              Nullable(UInt8)          COMMENT 'Cờ ngày giao dịch',
    -- From: SECTOR DIMENSION
    sctr_code                   Nullable(String)         COMMENT 'Mã ngành — từ Sector Dimension',
    sctr_nm                     Nullable(String)         COMMENT 'Tên ngành nghề — từ Sector Dimension',
    -- Technical metadata
    ds_batch_date               Date                     COMMENT 'ETL batch date',
    ds_population_timestamp     DateTime                 COMMENT 'Population timestamp'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(snpst_dt)
ORDER BY (snpst_dt, sctr_dim_id)
COMMENT 'Flat table — Fact Sector Risk Snapshot × Calendar Date Dimension × Sector Dimension'
;


-- =============================================================================
-- 4. pttt_fct_ordr_sz_snpst_flat
--    Fact Order Size Snapshot × Calendar Date Dimension
-- =============================================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_ordr_sz_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT ORDER SIZE SNAPSHOT
    snpst_dt_dim_id             String          COMMENT 'FK → Calendar Date Dimension',
    snpst_dt                    Date            COMMENT 'Ngày giao dịch (snapshot)',
    scr_code                    String          COMMENT 'Mã chứng khoán',
    tdg_val_bil_vnd             Nullable(Decimal(23,2))  COMMENT 'GTGD per mã CK tại ngày t (tỷ VND)',
    ordr_sz_bnd                 Nullable(String)         COMMENT 'Phân loại quy mô lệnh',
    mtch_vol                    Nullable(Int64)          COMMENT 'KL khớp lệnh per mã CK tại ngày t',
    -- From: CALENDAR DATE DIMENSION
    full_date                   Nullable(Date)           COMMENT 'Ngày đầy đủ — từ Calendar Date Dimension',
    day_of_week                 Nullable(String)         COMMENT 'Thứ trong tuần',
    day_of_week_num             Nullable(Int32)          COMMENT 'Số thứ tự ngày trong tuần (1=Mon)',
    week_of_year                Nullable(Int32)          COMMENT 'Tuần trong năm',
    month_num                   Nullable(Int32)          COMMENT 'Tháng',
    month_name                  Nullable(String)         COMMENT 'Tên tháng',
    quarter_num                 Nullable(Int32)          COMMENT 'Quý',
    year_num                    Nullable(Int32)          COMMENT 'Năm',
    is_trading_day              Nullable(UInt8)          COMMENT 'Cờ ngày giao dịch',
    -- Technical metadata
    ds_batch_date               Date                     COMMENT 'ETL batch date',
    ds_population_timestamp     DateTime                 COMMENT 'Population timestamp'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(snpst_dt)
ORDER BY (snpst_dt, scr_code)
COMMENT 'Flat table — Fact Order Size Snapshot × Calendar Date Dimension'
;


-- =============================================================================
-- 5. pttt_fct_ivsr_flw_snpst_flat
--    Fact Investor Flow Snapshot × Calendar Date Dimension × Investor Group Dimension
-- =============================================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_ivsr_flw_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT INVESTOR FLOW SNAPSHOT
    snpst_dt_dim_id             String          COMMENT 'FK → Calendar Date Dimension',
    ivsr_grp_dim_id             String          COMMENT 'FK → Investor Group Dimension',
    snpst_dt                    Date            COMMENT 'Ngày snapshot',
    ivsr_grp_code               String          COMMENT 'Mã nhóm NĐT (FOREIGN/PROPRIETARY/DOMESTIC_INSTITUTION/DOMESTIC_INDIVIDUAL)',
    buy_val_bil_vnd             Nullable(Decimal(23,2))  COMMENT 'GTGD mua nhóm NĐT (tỷ VND)',
    sell_val_bil_vnd            Nullable(Decimal(23,2))  COMMENT 'GTGD bán nhóm NĐT (tỷ VND)',
    net_flw_bil_vnd             Nullable(Decimal(23,2))  COMMENT 'Dòng tiền ròng nhóm NĐT (tỷ VND)',
    net_flw_ma30_bil_vnd        Nullable(Decimal(23,2))  COMMENT 'Dòng tiền ròng nhóm NĐT trung bình 30 phiên (tỷ VND)',
    net_flw_corr_30d            Nullable(Decimal(5,2))   COMMENT 'Hệ số tương quan NĐTNN vs Tự doanh 30 phiên',
    tdg_val_bil_vnd             Nullable(Decimal(23,2))  COMMENT 'GTGD nhóm NĐT = Buy + Sell (tỷ VND)',
    tdg_val_rto_pct             Nullable(Decimal(5,2))   COMMENT 'Tỷ trọng GTGD nhóm NĐT / Tổng GTGD thị trường (%)',
    -- From: CALENDAR DATE DIMENSION
    full_date                   Nullable(Date)           COMMENT 'Ngày đầy đủ — từ Calendar Date Dimension',
    day_of_week                 Nullable(String)         COMMENT 'Thứ trong tuần',
    day_of_week_num             Nullable(Int32)          COMMENT 'Số thứ tự ngày trong tuần (1=Mon)',
    week_of_year                Nullable(Int32)          COMMENT 'Tuần trong năm',
    month_num                   Nullable(Int32)          COMMENT 'Tháng',
    month_name                  Nullable(String)         COMMENT 'Tên tháng',
    quarter_num                 Nullable(Int32)          COMMENT 'Quý',
    year_num                    Nullable(Int32)          COMMENT 'Năm',
    is_trading_day              Nullable(UInt8)          COMMENT 'Cờ ngày giao dịch',
    -- From: INVESTOR GROUP DIMENSION
    ivsr_grp_nm                 Nullable(String)         COMMENT 'Tên nhóm nhà đầu tư — từ Investor Group Dimension',
    -- Technical metadata
    ds_batch_date               Date                     COMMENT 'ETL batch date',
    ds_population_timestamp     DateTime                 COMMENT 'Population timestamp'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(snpst_dt)
ORDER BY (snpst_dt, ivsr_grp_dim_id)
COMMENT 'Flat table — Fact Investor Flow Snapshot × Calendar Date Dimension × Investor Group Dimension'
;


-- =============================================================================
-- 6. pttt_fct_frgn_net_trd_snpst_flat
--    Fact Foreign Net Trade Snapshot × Calendar Date Dimension
-- =============================================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_frgn_net_trd_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT FOREIGN NET TRADE SNAPSHOT
    snpst_dt_dim_id             String          COMMENT 'FK → Calendar Date Dimension',
    snpst_dt                    Date            COMMENT 'Ngày snapshot',
    scr_code                    String          COMMENT 'Mã chứng khoán',
    frgn_buy_val_bil_vnd        Nullable(Decimal(23,2))  COMMENT 'GTGD mua NĐTNN per mã CK (tỷ VND)',
    frgn_sell_val_bil_vnd       Nullable(Decimal(23,2))  COMMENT 'GTGD bán NĐTNN per mã CK (tỷ VND)',
    frgn_net_val_bil_vnd        Nullable(Decimal(23,2))  COMMENT 'Dòng tiền ròng NĐTNN per mã CK (tỷ VND)',
    -- From: CALENDAR DATE DIMENSION
    full_date                   Nullable(Date)           COMMENT 'Ngày đầy đủ — từ Calendar Date Dimension',
    day_of_week                 Nullable(String)         COMMENT 'Thứ trong tuần',
    day_of_week_num             Nullable(Int32)          COMMENT 'Số thứ tự ngày trong tuần (1=Mon)',
    week_of_year                Nullable(Int32)          COMMENT 'Tuần trong năm',
    month_num                   Nullable(Int32)          COMMENT 'Tháng',
    month_name                  Nullable(String)         COMMENT 'Tên tháng',
    quarter_num                 Nullable(Int32)          COMMENT 'Quý',
    year_num                    Nullable(Int32)          COMMENT 'Năm',
    is_trading_day              Nullable(UInt8)          COMMENT 'Cờ ngày giao dịch',
    -- Technical metadata
    ds_batch_date               Date                     COMMENT 'ETL batch date',
    ds_population_timestamp     DateTime                 COMMENT 'Population timestamp'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(snpst_dt)
ORDER BY (snpst_dt, scr_code)
COMMENT 'Flat table — Fact Foreign Net Trade Snapshot × Calendar Date Dimension'
;


-- =============================================================================
-- 7. pttt_fct_prpty_net_trd_snpst_flat
--    Fact Proprietary Net Trade Snapshot × Calendar Date Dimension
-- =============================================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_prpty_net_trd_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT PROPRIETARY NET TRADE SNAPSHOT
    snpst_dt_dim_id             String          COMMENT 'FK → Calendar Date Dimension',
    snpst_dt                    Date            COMMENT 'Ngày snapshot',
    scr_code                    String          COMMENT 'Mã chứng khoán',
    prpty_buy_val_bil_vnd       Nullable(Decimal(23,2))  COMMENT 'GTGD mua tự doanh per mã CK (tỷ VND)',
    prpty_sell_val_bil_vnd      Nullable(Decimal(23,2))  COMMENT 'GTGD bán tự doanh per mã CK (tỷ VND)',
    prpty_net_val_bil_vnd       Nullable(Decimal(23,2))  COMMENT 'Dòng tiền ròng tự doanh per mã CK (tỷ VND)',
    -- From: CALENDAR DATE DIMENSION
    full_date                   Nullable(Date)           COMMENT 'Ngày đầy đủ — từ Calendar Date Dimension',
    day_of_week                 Nullable(String)         COMMENT 'Thứ trong tuần',
    day_of_week_num             Nullable(Int32)          COMMENT 'Số thứ tự ngày trong tuần (1=Mon)',
    week_of_year                Nullable(Int32)          COMMENT 'Tuần trong năm',
    month_num                   Nullable(Int32)          COMMENT 'Tháng',
    month_name                  Nullable(String)         COMMENT 'Tên tháng',
    quarter_num                 Nullable(Int32)          COMMENT 'Quý',
    year_num                    Nullable(Int32)          COMMENT 'Năm',
    is_trading_day              Nullable(UInt8)          COMMENT 'Cờ ngày giao dịch',
    -- Technical metadata
    ds_batch_date               Date                     COMMENT 'ETL batch date',
    ds_population_timestamp     DateTime                 COMMENT 'Population timestamp'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(snpst_dt)
ORDER BY (snpst_dt, scr_code)
COMMENT 'Flat table — Fact Proprietary Net Trade Snapshot × Calendar Date Dimension'
;


-- =============================================================================
-- 8. pttt_fct_corp_bond_sctr_snpst_flat
--    Fact Corporate Bond Sector Snapshot × Calendar Date Dimension × Corp Bond Sector Dimension
-- =============================================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_corp_bond_sctr_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT CORPORATE BOND SECTOR SNAPSHOT
    snpst_dt_dim_id             String          COMMENT 'FK → Calendar Date Dimension',
    sctr_dim_id                 String          COMMENT 'FK → Corp Bond Sector Dimension',
    snpst_dt                    Date            COMMENT 'Ngày snapshot',
    bond_tdg_val_bil_vnd        Nullable(Decimal(23,2))  COMMENT 'GTGD trái phiếu per ngành TCPH (tỷ VND)',
    bond_tdg_val_tot_bil_vnd    Nullable(Decimal(23,2))  COMMENT 'Tổng GTGD trái phiếu toàn thị trường (tỷ VND)',
    bond_tdg_val_rto_pct        Nullable(Decimal(5,2))   COMMENT 'Tỷ trọng GTGD TP per ngành / Tổng GTGD TP (%)',
    bond_oustndg_sctr_bil_vnd   Nullable(Decimal(23,2))  COMMENT 'Dư nợ TP per ngành — PENDING',
    -- From: CALENDAR DATE DIMENSION
    full_date                   Nullable(Date)           COMMENT 'Ngày đầy đủ — từ Calendar Date Dimension',
    day_of_week                 Nullable(String)         COMMENT 'Thứ trong tuần',
    day_of_week_num             Nullable(Int32)          COMMENT 'Số thứ tự ngày trong tuần (1=Mon)',
    week_of_year                Nullable(Int32)          COMMENT 'Tuần trong năm',
    month_num                   Nullable(Int32)          COMMENT 'Tháng',
    month_name                  Nullable(String)         COMMENT 'Tên tháng',
    quarter_num                 Nullable(Int32)          COMMENT 'Quý',
    year_num                    Nullable(Int32)          COMMENT 'Năm',
    is_trading_day              Nullable(UInt8)          COMMENT 'Cờ ngày giao dịch',
    -- From: CORP BOND SECTOR DIMENSION
    sctr_code                   Nullable(String)         COMMENT 'Mã ngành TCPH — từ Corp Bond Sector Dimension',
    sctr_nm                     Nullable(String)         COMMENT 'Tên ngành TCPH — từ Corp Bond Sector Dimension',
    -- Technical metadata
    ds_batch_date               Date                     COMMENT 'ETL batch date',
    ds_population_timestamp     DateTime                 COMMENT 'Population timestamp'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(snpst_dt)
ORDER BY (snpst_dt, sctr_dim_id)
COMMENT 'Flat table — Fact Corporate Bond Sector Snapshot × Calendar Date Dimension × Corp Bond Sector Dimension'
;


-- =============================================================================
-- 9. pttt_fct_mbr_sfty_snpst_flat
--    Fact Member Safety Snapshot × Calendar Date Dimension
-- =============================================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_mbr_sfty_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT MEMBER SAFETY SNAPSHOT
    snpst_dt_dim_id             String          COMMENT 'FK → Calendar Date Dimension',
    snpst_dt                    Date            COMMENT 'Ngày snapshot',
    mrgn_dbt_total_bil_vnd      Nullable(Decimal(23,2))  COMMENT 'Tổng dư nợ margin tất cả CTCK (tỷ VND)',
    tot_eqty_bil_vnd            Nullable(Decimal(23,2))  COMMENT 'Tổng VCSH tất cả CTCK (tỷ VND)',
    tot_dbt_bil_vnd             Nullable(Decimal(23,2))  COMMENT 'Tổng nợ phải trả tất cả CTCK (tỷ VND)',
    avg_mrgn_eqty_rto_pct       Nullable(Decimal(5,2))   COMMENT 'Tỷ lệ dư nợ margin/VCSH bình quân (%)',
    de_rto_avg                  Nullable(Decimal(5,2))   COMMENT 'D/E trung bình hệ thống CTCK (%)',
    mbr_ctrl_cnt                Nullable(Int32)          COMMENT 'Số CTCK cần kiểm soát (vốn khả dụng < 120%)',
    mbr_cnt_high                Nullable(Int32)          COMMENT 'Số CTCK xếp hạng Cao (vốn khả dụng > 150%)',
    mbr_cnt_med                 Nullable(Int32)          COMMENT 'Số CTCK xếp hạng Trung bình (120%–150%)',
    mbr_cnt_low                 Nullable(Int32)          COMMENT 'Số CTCK xếp hạng Thấp (< 120%)',
    -- From: CALENDAR DATE DIMENSION
    full_date                   Nullable(Date)           COMMENT 'Ngày đầy đủ — từ Calendar Date Dimension',
    day_of_week                 Nullable(String)         COMMENT 'Thứ trong tuần',
    day_of_week_num             Nullable(Int32)          COMMENT 'Số thứ tự ngày trong tuần (1=Mon)',
    week_of_year                Nullable(Int32)          COMMENT 'Tuần trong năm',
    month_num                   Nullable(Int32)          COMMENT 'Tháng',
    month_name                  Nullable(String)         COMMENT 'Tên tháng',
    quarter_num                 Nullable(Int32)          COMMENT 'Quý',
    year_num                    Nullable(Int32)          COMMENT 'Năm',
    is_trading_day              Nullable(UInt8)          COMMENT 'Cờ ngày giao dịch',
    -- Technical metadata
    ds_batch_date               Date                     COMMENT 'ETL batch date',
    ds_population_timestamp     DateTime                 COMMENT 'Population timestamp'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(snpst_dt)
ORDER BY (snpst_dt)
COMMENT 'Flat table — Fact Member Safety Snapshot × Calendar Date Dimension'
;


-- =============================================================================
-- 10. pttt_fct_mbr_sfty_per_mbr_snpst_flat
--     Fact Member Safety Per Member Snapshot × Calendar Date Dimension × Securities Company Dimension
-- =============================================================================
CREATE TABLE IF NOT EXISTS datamart.pttt_fct_mbr_sfty_per_mbr_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT MEMBER SAFETY PER MEMBER SNAPSHOT
    snpst_dt_dim_id             String          COMMENT 'FK → Calendar Date Dimension',
    scr_co_dim_id               String          COMMENT 'FK → Securities Company Dimension',
    snpst_dt                    Date            COMMENT 'Ngày snapshot',
    eqty_bil_vnd                Nullable(Decimal(23,2))  COMMENT 'VCSH per CTCK — kỳ báo cáo quý gần nhất (tỷ VND)',
    mrgn_dbt_bil_vnd            Nullable(Decimal(23,2))  COMMENT 'Dư nợ margin per CTCK (tỷ VND)',
    mrgn_eqty_rto_pct           Nullable(Decimal(5,2))   COMMENT 'Tỷ lệ dư nợ margin/VCSH per CTCK (%)',
    attc_rtg                    Nullable(String)         COMMENT 'Xếp hạng an toàn tài chính per CTCK (Cao/Trung bình/Thấp)',
    -- From: CALENDAR DATE DIMENSION
    full_date                   Nullable(Date)           COMMENT 'Ngày đầy đủ — từ Calendar Date Dimension',
    day_of_week                 Nullable(String)         COMMENT 'Thứ trong tuần',
    day_of_week_num             Nullable(Int32)          COMMENT 'Số thứ tự ngày trong tuần (1=Mon)',
    week_of_year                Nullable(Int32)          COMMENT 'Tuần trong năm',
    month_num                   Nullable(Int32)          COMMENT 'Tháng',
    month_name                  Nullable(String)         COMMENT 'Tháng trong năm',
    quarter_num                 Nullable(Int32)          COMMENT 'Quý',
    year_num                    Nullable(Int32)          COMMENT 'Năm',
    is_trading_day              Nullable(UInt8)          COMMENT 'Cờ ngày giao dịch',
    -- From: SECURITIES COMPANY DIMENSION
    mbr_code                    Nullable(String)         COMMENT 'Mã thành viên CTCK — từ Securities Company Dimension',
    mbr_nm                      Nullable(String)         COMMENT 'Tên CTCK — từ Securities Company Dimension',
    -- Technical metadata
    ds_batch_date               Date                     COMMENT 'ETL batch date',
    ds_population_timestamp     DateTime                 COMMENT 'Population timestamp'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(snpst_dt)
ORDER BY (snpst_dt, scr_co_dim_id)
COMMENT 'Flat table — Fact Member Safety Per Member Snapshot × Calendar Date Dimension × Securities Company Dimension'
;


-- =============================================================================
-- 11. opr_corp_bond_issuer_credit_flat
--     Operational Corporate Bond Issuer Credit Monitor (no dim joins)
-- =============================================================================
CREATE TABLE IF NOT EXISTS datamart.opr_corp_bond_issuer_credit_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL CORPORATE BOND ISSUER CREDIT MONITOR
    issuer_credit_monitor_id    String          COMMENT 'Surrogate PK',
    bond_ticker_code            String          COMMENT 'Mã trái phiếu (business key)',
    issuer_nm                   String          COMMENT 'Tên tổ chức phát hành',
    snpst_dt                    Date            COMMENT 'Ngày snapshot',
    mat_dt                      Nullable(Date)           COMMENT 'Ngày đáo hạn trái phiếu',
    sctr_code                   Nullable(String)         COMMENT 'Mã ngành TCPH',
    tot_dbt_bil_vnd             Nullable(Decimal(23,2))  COMMENT 'Tổng nợ phải trả per TCPH (tỷ VND)',
    eqty_bil_vnd                Nullable(Decimal(23,2))  COMMENT 'VCSH cuối kỳ per TCPH (tỷ VND)',
    de_rto                      Nullable(Decimal(5,2))   COMMENT 'Hệ số D/E per TCPH',
    net_prft_bil_vnd            Nullable(Decimal(23,2))  COMMENT 'Lợi nhuận sau thuế per TCPH (tỷ VND)',
    roe_pct                     Nullable(Decimal(5,2))   COMMENT 'ROE per TCPH (%)',
    bond_oustndg_bil_vnd        Nullable(Decimal(23,2))  COMMENT 'Dư nợ TP per TCPH — PENDING',
    audit_opnn                  Nullable(String)         COMMENT 'Ý kiến kiểm toán BCTC — PENDING',
    credit_rtg                  Nullable(String)         COMMENT 'Xếp hạng tín nhiệm DN — PENDING',
    rsk_lvl                     Nullable(String)         COMMENT 'Xếp loại rủi ro (LOW/MEDIUM/HIGH) — PENDING',
    src_stm_code                String          COMMENT 'Mã hệ thống nguồn',
    -- Technical metadata
    ds_batch_date               Date                     COMMENT 'ETL batch date',
    ds_population_timestamp     DateTime                 COMMENT 'Population timestamp'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(snpst_dt)
ORDER BY (snpst_dt, bond_ticker_code)
COMMENT 'Flat table — Operational Corporate Bond Issuer Credit Monitor'
;


-- =============================================================================
-- 12. opr_mbr_sfty_monitor_flat
--     Operational Member Safety Monitor (no dim joins)
-- =============================================================================
CREATE TABLE IF NOT EXISTS datamart.opr_mbr_sfty_monitor_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL MEMBER SAFETY MONITOR
    mbr_sfty_monitor_id         String          COMMENT 'Surrogate PK',
    mbr_code                    String          COMMENT 'Mã CTCK (business key)',
    rpt_dt                      Date            COMMENT 'Ngày báo cáo',
    mbr_nm                      Nullable(String)         COMMENT 'Tên CTCK',
    eqty_bil_vnd                Nullable(Decimal(23,2))  COMMENT 'VCSH per CTCK — kỳ báo cáo quý gần nhất (tỷ VND)',
    mrgn_dbt_bil_vnd            Nullable(Decimal(23,2))  COMMENT 'Dư nợ margin per CTCK (tỷ VND)',
    mrgn_eqty_rto_pct           Nullable(Decimal(5,2))   COMMENT 'Tỷ lệ dư nợ margin/VCSH per CTCK (%)',
    attc_rtg                    Nullable(String)         COMMENT 'Xếp hạng ATTC per CTCK (Cao/Trung bình/Thấp)',
    src_stm_code                String          COMMENT 'Mã hệ thống nguồn',
    -- Technical metadata
    ds_batch_date               Date                     COMMENT 'ETL batch date',
    ds_population_timestamp     DateTime                 COMMENT 'Population timestamp'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(rpt_dt)
ORDER BY (rpt_dt, mbr_code)
COMMENT 'Flat table — Operational Member Safety Monitor'
;
