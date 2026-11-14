-- ============================================================
-- NDTNN Flat Tables — POPULATE
-- Module: Nhà Đầu Tư Nước Ngoài — NDTNN
-- Generated: Phase 3 LLD Datamart
-- 7 bảng: 5 fact + 2 operational
-- ETL daily: fact có FK Calendar Date lọc theo WHERE cal.cdr_dt = :etl_date
--            fact report không có FK Calendar Date, lọc trực tiếp theo WHERE f.report_dt = :etl_date
-- 2 fact report (statistics_rpt, detail_rpt) là ETL append-only theo Report
-- Date (xem HLD O_NDTNN_31b) — KHÔNG TRUNCATE, chỉ DELETE đúng ngày :etl_date
-- (idempotent re-run) rồi INSERT lại, giữ nguyên lịch sử các ngày report khác.
-- ============================================================


-- ============================================================
-- 1. FACT: ndtnn_fct_securities_foreign_trading_snpst_flat
--    trade_cal: JOIN + WHERE cdr_dt = :etl_date
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.ndtnn_fct_securities_foreign_trading_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.ndtnn_fct_securities_foreign_trading_snpst_flat
SELECT
    -- From: FACT Fact Securities Foreign Trading Snapshot
    f.snpst_dt_dim_id,
    f.securities_dim_id,
    f.public_company_dim_id,
    f.foreign_buy_val,
    f.foreign_sell_val,
    f.total_market_val,

    -- From: CALENDAR DATE DIMENSION
    trade_cal.cdr_dt                   AS trade_cdr_dt,

    -- From: SECURITIES DIMENSION
    sec_dim.symbol                     AS symbol,
    sec_dim.security_full_nm           AS security_full_nm,
    sec_dim.stock_tp_code              AS stock_tp_code,
    sec_dim.floor_code                 AS floor_code,
    sec_dim.listed_share_count         AS listed_share_count,
    sec_dim.total_listing_vol          AS total_listing_vol,
    sec_dim.underlying_symbol          AS underlying_symbol,
    sec_dim.issuer_nm                  AS issuer_nm,
    sec_dim.listing_dt                 AS listing_dt,
    sec_dim.symbol_status_code         AS symbol_status_code,
    sec_dim.trading_time               AS trading_time,
    sec_dim.src_stm_code                AS securities_src_stm_code,

    -- From: PUBLIC COMPANY DIMENSION
    pc_dim.public_company_code             AS public_company_code,
    pc_dim.equity_ticker_symbol            AS equity_ticker_symbol,
    pc_dim.public_company_nm               AS public_company_nm,
    pc_dim.equity_listing_exchange_code    AS equity_listing_exchange_code,
    pc_dim.business_line_level_1_code      AS business_line_level_1_code,
    pc_dim.ids_registration_dt             AS ids_registration_dt,
    pc_dim.public_company_status_code      AS public_company_status_code,
    pc_dim.classification_business_line_nm AS classification_business_line_nm,
    pc_dim.public_company_english_nm       AS public_company_english_nm,
    pc_dim.enterprise_tp_code              AS enterprise_tp_code,
    pc_dim.public_company_tp_code          AS public_company_tp_code,
    pc_dim.head_office_province_nm         AS head_office_province_nm,
    pc_dim.operating_status_code           AS operating_status_code,
    pc_dim.has_state_ownership_indicator   AS has_state_ownership_indicator,
    pc_dim.charter_capital_amt             AS charter_capital_amt,
    pc_dim.first_registration_dt           AS first_registration_dt,
    pc_dim.latest_registration_dt          AS latest_registration_dt,
    pc_dim.latest_registration_province_nm AS latest_registration_province_nm,
    pc_dim.ids_registration_indicator      AS ids_registration_indicator,
    pc_dim.public_company_form_code        AS public_company_form_code,
    pc_dim.former_state_owned_indicator    AS former_state_owned_indicator,
    pc_dim.foreign_direct_investment_indicator AS foreign_direct_investment_indicator,
    pc_dim.has_parent_company_indicator    AS has_parent_company_indicator,
    pc_dim.has_subsidiary_indicator        AS has_subsidiary_indicator,
    pc_dim.has_joint_venture_indicator     AS has_joint_venture_indicator,
    pc_dim.ipo_company_indicator           AS ipo_company_indicator,
    pc_dim.src_stm_code                    AS public_company_src_stm_code

FROM datamart.fct_securities_foreign_trading_snpst f
JOIN datamart.cdr_dt_dim trade_cal
    ON trade_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.securities_dim sec_dim
    ON sec_dim.securities_dim_id = f.securities_dim_id
LEFT JOIN datamart.public_company_dim pc_dim
    ON pc_dim.public_company_dim_id = f.public_company_dim_id
WHERE trade_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 2. FACT (report): ndtnn_foreign_investor_trading_statistics_rpt_flat
--    Không FK Calendar Date — lọc trực tiếp trên report_dt
-- ============================================================
DELETE FROM datamart.ndtnn_foreign_investor_trading_statistics_rpt_flat ON CLUSTER 'my_cluster'
WHERE report_dt = :etl_date;
INSERT INTO datamart.ndtnn_foreign_investor_trading_statistics_rpt_flat
SELECT
    -- From: FACT Foreign Investor Trading Statistics Report
    f.report_dt,
    f.security_tp_group,
    f.buy_val,
    f.sell_val,
    f.total_market_val,
    f.src_stm_code

FROM datamart.foreign_investor_trading_statistics_rpt f
WHERE f.report_dt = :etl_date
;


-- ============================================================
-- 3. FACT (report): ndtnn_foreign_investor_trading_detail_rpt_flat
--    Không FK Calendar Date — lọc trực tiếp trên report_dt
-- ============================================================
DELETE FROM datamart.ndtnn_foreign_investor_trading_detail_rpt_flat ON CLUSTER 'my_cluster'
WHERE report_dt = :etl_date;
INSERT INTO datamart.ndtnn_foreign_investor_trading_detail_rpt_flat
SELECT
    -- From: FACT Foreign Investor Trading Detail Report
    f.report_dt,
    fn_pii_encrypt(f.account_nbr, :aes_key_hex) AS account_nbr,
    f.symbol,
    f.trade_direction_code,
    fn_pii_encrypt(f.account_holder_nm, :aes_key_hex) AS account_holder_nm,
    fn_pii_encrypt(f.investor_nm, :aes_key_hex) AS investor_nm,
    f.execution_vol,
    f.execution_val,
    f.src_stm_code

FROM datamart.foreign_investor_trading_detail_rpt f
WHERE f.report_dt = :etl_date
;


-- ============================================================
-- 4. OPERATIONAL: ndtnn_opr_foreign_investor_360_profile_flat
--    Không JOIN, không lọc ngày
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.ndtnn_opr_foreign_investor_360_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.ndtnn_opr_foreign_investor_360_profile_flat
SELECT
    -- From: OPERATIONAL Operational Foreign Investor 360 Profile
    o.investor_code,
    fn_pii_encrypt(o.investor_nm, :aes_key_hex) AS investor_nm,
    o.nationality_code,
    o.nationality_nm,
    o.investor_tp_code,
    o.investor_tp_nm,
    fn_pii_encrypt(o.director_nm, :aes_key_hex) AS director_nm,
    o.custodian_bank_nm,
    o.src_stm_code,
    o.investor_status_code,
    o.investor_status_nm,
    fn_pii_encrypt(o.identification_nbr, :aes_key_hex) AS identification_nbr

FROM datamart.opr_foreign_investor_360_profile o
;


-- ============================================================
-- 5. OPERATIONAL: ndtnn_opr_investor_compliance_hist_flat
--    Không JOIN, không lọc ngày
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.ndtnn_opr_investor_compliance_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.ndtnn_opr_investor_compliance_hist_flat
SELECT
    -- From: OPERATIONAL Operational Investor Compliance History
    o.investor_compliance_hist_code,
    fn_pii_encrypt(o.subject_nm, :aes_key_hex) AS subject_nm,
    fn_pii_encrypt(o.subject_id_nbr, :aes_key_hex) AS subject_id_nbr,
    o.issued_dt,
    o.penalty_tp_nm,
    o.description,
    o.life_cycle_status_code,
    o.src_stm_code

FROM datamart.opr_investor_compliance_hist o
;


-- ============================================================
-- 6. FACT: ndtnn_fct_public_company_foreign_ownership_snpst_flat
--    snpst_cal: JOIN + WHERE cdr_dt = :etl_date
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.ndtnn_fct_public_company_foreign_ownership_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.ndtnn_fct_public_company_foreign_ownership_snpst_flat
SELECT
    -- From: FACT Fact Public Company Foreign Ownership Snapshot
    f.snpst_dt_dim_id,
    f.public_company_dim_id,
    f.ticker_symbol,
    f.total_issued_share_quantity,
    f.max_foreign_ownership_ratio,
    f.max_foreign_holding_quantity,
    f.current_foreign_holding_quantity,
    f.remaining_foreign_holding_quantity,
    f.src_stm_code,
    f.foreign_holding_value,

    -- From: CALENDAR DATE DIMENSION
    snpst_cal.cdr_dt                       AS snpst_cdr_dt,

    -- From: PUBLIC COMPANY DIMENSION
    pc_dim.public_company_code             AS public_company_code,
    pc_dim.equity_ticker_symbol            AS equity_ticker_symbol,
    pc_dim.public_company_nm               AS public_company_nm,
    pc_dim.equity_listing_exchange_code    AS equity_listing_exchange_code,
    pc_dim.classification_business_line_nm AS classification_business_line_nm

FROM datamart.fct_public_company_foreign_ownership_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.public_company_dim pc_dim
    ON pc_dim.public_company_dim_id = f.public_company_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 7. FACT: ndtnn_fct_foreign_net_flow_market_index_snpst_flat
--    snpst_cal: JOIN + WHERE cdr_dt = :etl_date
--    Chuỗi thời gian cho line chart Nhóm 5 — KHÔNG TRUNCATE, chỉ DELETE đúng
--    ngày :etl_date (idempotent re-run) rồi INSERT lại, giữ lịch sử các ngày khác.
-- ============================================================
DELETE FROM datamart.ndtnn_fct_foreign_net_flow_market_index_snpst_flat ON CLUSTER 'my_cluster'
WHERE snpst_cdr_dt = :etl_date;
INSERT INTO datamart.ndtnn_fct_foreign_net_flow_market_index_snpst_flat
SELECT
    -- From: FACT Fact Foreign Net Flow Market Index Snapshot
    f.snpst_dt_dim_id,
    f.market_index_dim_id,
    f.foreign_buy_val,
    f.foreign_sell_val,
    f.foreign_net_trading_val,
    f.market_index_close_val,
    f.foreign_net_capital_flow_mtd_amt,

    -- From: CALENDAR DATE DIMENSION
    snpst_cal.cdr_dt                       AS snpst_cdr_dt,

    -- From: MARKET INDEX DIMENSION
    mi_dim.market_id                       AS market_id,
    mi_dim.market_code                     AS market_code,
    mi_dim.index_nm                        AS index_nm

FROM datamart.fct_foreign_net_flow_market_index_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.market_index_dim mi_dim
    ON mi_dim.market_index_dim_id = f.market_index_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 8. FACT: ndtnn_fct_foreign_investor_report_value_flat
-- ============================================================
DELETE FROM datamart.ndtnn_fct_foreign_investor_report_value_flat ON CLUSTER 'my_cluster'
WHERE submission_cdr_dt = :etl_date;
INSERT INTO datamart.ndtnn_fct_foreign_investor_report_value_flat
SELECT
    f.submission_dt_dim_id,
    f.foreign_investor_report_structure_dim_id,
    f.rpt_log_id,
    f.dynamic_row_order,
    f.period_tp_code,
    f.period_val,
    f.rpt_year,
    f.submission_status_code,
    f.late_duration,
    f.total_row_ind,
    f.section_echo_ind,
    f.band_overflow_ind,
    f.static_copy_ind,
    f.rpt_marker_ind,
    f.val_raw,
    f.src_stm_code,

    submission_cal.cdr_dt AS submission_cdr_dt,

    str_dim.structure_code,
    str_dim.rpt_code,
    str_dim.rpt_nm,
    str_dim.report_type_nm,
    str_dim.legal_basis,
    str_dim.sheet_code,
    str_dim.sheet_nm,
    str_dim.section_id,
    str_dim.row_path,
    str_dim.column_path,
    str_dim.data_tp,


    str_dim.fir_structure_code,   -- [MỚI 2026-10-05] khớp ALTER TABLE ADD COLUMN

    f.rpt_dt_dim_id,              -- [MỚI 2026-10-13] ngày báo cáo (role-playing, nullable) — 2 cột cuối khớp ALTER TABLE ADD COLUMN
    nullIf(rpt_cal.cdr_dt, toDate('1970-01-01')) AS rpt_cdr_dt   -- LEFT JOIN không khớp (DayReport NULL) trả 1970-01-01 khi join_use_nulls=0 → ép về NULL
FROM datamart.fct_foreign_investor_report_value f
JOIN datamart.cdr_dt_dim submission_cal
    ON submission_cal.cdr_dt_dim_id = f.submission_dt_dim_id
LEFT JOIN datamart.cdr_dt_dim rpt_cal
    ON rpt_cal.cdr_dt_dim_id = f.rpt_dt_dim_id
LEFT JOIN datamart.foreign_investor_report_structure_dim str_dim
    ON str_dim.foreign_investor_report_structure_dim_id = f.foreign_investor_report_structure_dim_id
WHERE submission_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 9. FACT: ndtnn_fct_foreign_investor_capital_flow_snpst_flat
-- ============================================================
DELETE FROM datamart.ndtnn_fct_foreign_investor_capital_flow_snpst_flat ON CLUSTER 'my_cluster'
WHERE snpst_cdr_dt = :etl_date;
INSERT INTO datamart.ndtnn_fct_foreign_investor_capital_flow_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.rpt_log_id,
    f.section_id,
    f.dynamic_row_order,
    f.period_val,
    f.nationality_nm,
    fn_pii_encrypt(f.investor_nm, :aes_key_hex) AS investor_nm,
    f.capital_flow_net_val,
    f.src_stm_code,

    submission_cal.cdr_dt AS snpst_cdr_dt,

    f.rpt_code,                   -- [MỚI 2026-10-13] 3 cột cuối khớp ALTER TABLE ADD COLUMN
    f.rpt_dt_dim_id,
    nullIf(rpt_cal.cdr_dt, toDate('1970-01-01')) AS rpt_cdr_dt   -- LEFT JOIN không khớp (DayReport NULL) trả 1970-01-01 khi join_use_nulls=0 → ép về NULL
FROM datamart.fct_foreign_investor_capital_flow_snpst f
JOIN datamart.cdr_dt_dim submission_cal
    ON submission_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.cdr_dt_dim rpt_cal
    ON rpt_cal.cdr_dt_dim_id = f.rpt_dt_dim_id
WHERE submission_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 10. FACT: ndtnn_fct_foreign_investor_portfolio_report_snpst_flat
-- ============================================================
DELETE FROM datamart.ndtnn_fct_foreign_investor_portfolio_report_snpst_flat ON CLUSTER 'my_cluster'
WHERE snpst_cdr_dt = :etl_date;
INSERT INTO datamart.ndtnn_fct_foreign_investor_portfolio_report_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.rpt_log_id,
    f.section_id,
    f.dynamic_row_order,
    f.period_val,
    f.rpt_code,
    f.investor_group_nm,
    f.nationality_nm,
    f.investor_type_nm,
    fn_pii_encrypt(f.investor_nm, :aes_key_hex) AS investor_nm,
    f.bill_val,
    f.bond_val,
    f.listed_equity_fund_val,
    f.upcom_equity_val,
    f.capital_contribution_val,
    f.cash_equivalent_val,
    f.total_portfolio_val,
    f.individual_ind,
    f.fund_ind,
    f.non_fund_org_ind,
    f.foreign_bank_branch_ind,
    f.transaction_cd,
    f.src_stm_code,

    submission_cal.cdr_dt AS snpst_cdr_dt,

    f.rpt_dt_dim_id,              -- [MỚI 2026-11-14, O_NDTNN_60] 3 cột cuối khớp ALTER TABLE ADD COLUMN
    f.asset_class_total_val,
    nullIf(rpt_cal.cdr_dt, toDate('1970-01-01')) AS rpt_cdr_dt   -- LEFT JOIN không khớp (DayReport NULL) trả 1970-01-01 khi join_use_nulls=0 → ép về NULL

FROM datamart.fct_foreign_investor_portfolio_report_snpst f
JOIN datamart.cdr_dt_dim submission_cal
    ON submission_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.cdr_dt_dim rpt_cal
    ON rpt_cal.cdr_dt_dim_id = f.rpt_dt_dim_id
WHERE submission_cal.cdr_dt = :etl_date
;


-- ==========================================================
-- 11. FACT: ndtnn_fct_foreign_bank_branch_portfolio_report_snpst_flat
-- ==========================================================
DELETE FROM datamart.ndtnn_fct_foreign_bank_branch_portfolio_report_snpst_flat ON CLUSTER 'my_cluster'
WHERE snpst_cdr_dt = :etl_date;
INSERT INTO datamart.ndtnn_fct_foreign_bank_branch_portfolio_report_snpst_flat
SELECT
    f.fir_val_id,
    f.snpst_dt_dim_id,
    f.rpt_dt_dim_id,
    f.rpt_log_id,
    f.period_val,
    f.rpt_code,
    f.asset_group_nm,
    f.closing_balance_val,
    f.src_stm_code,

    submission_cal.cdr_dt AS snpst_cdr_dt,
    nullIf(rpt_cal.cdr_dt, toDate('1970-01-01')) AS rpt_cdr_dt   -- LEFT JOIN không khớp (DayReport NULL) trả 1970-01-01 khi join_use_nulls=0 → ép về NULL
FROM datamart.fct_foreign_bank_branch_portfolio_report_snpst f
JOIN datamart.cdr_dt_dim submission_cal
    ON submission_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.cdr_dt_dim rpt_cal
    ON rpt_cal.cdr_dt_dim_id = f.rpt_dt_dim_id
WHERE submission_cal.cdr_dt = :etl_date
;


-- ==========================================================
-- 12. OPERATIONAL: ndtnn_opr_fir_structure_flat
-- ==========================================================
TRUNCATE TABLE IF EXISTS datamart.ndtnn_opr_fir_structure_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.ndtnn_opr_fir_structure_flat
SELECT
    -- From: OPR_FIR_STRUCTURE
    f.fir_structure_id,
    f.fir_structure_code,
    f.src_stm_code,
    f.structure_code,
    f.fir_id,
    f.fir_code,
    f.rpt_id,
    f.row_index,
    f.column_index,
    f.data_tp,
    f.row_path,
    f.column_path,
    f.section_id,
    f.section_tp_code,
    f.dynamic_ind,
    f.last_band_ind,
    f.total_row_ind,
    f.ordinal_column_ind,
    f.data_explorer_id,
    f.sort_order,
    f.excluded_by_config_ind,
    f.override_src,
    f.ds_rcrd_st,
    f.ds_rcrd_isrt_dt,
    f.ds_rcrd_udt_dt,
    f.ds_rcrd_end_dt,
    f.ds_etl_pcs_tms

FROM datamart.opr_fir_structure f
;


-- ==========================================================
-- 13. OPERATIONAL: ndtnn_opr_fir_value_flat
-- ==========================================================
TRUNCATE TABLE IF EXISTS datamart.ndtnn_opr_fir_value_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.ndtnn_opr_fir_value_flat
SELECT
    -- From: OPR_FIR_VALUE
    f.fir_val_id,
    f.fir_val_code,
    f.src_stm_code,
    f.fir_structure_id,
    f.fir_structure_code,
    f.structure_code,
    f.rpt_log_id,
    f.rpt_id,
    f.fir_id,
    f.fir_code,
    f.reporting_entity_tp_code,
    f.reporting_entity_code,
    f.period_tp_code,
    f.period_val,
    f.rpt_year,
    f.rpt_day,
    f.submission_deadline_tms,
    f.submission_status_code,
    f.submission_status_tp_code,
    f.late_duration,
    f.total_row_ind,
    f.ordinal_column_ind,
    f.section_echo_ind,
    f.band_overflow_ind,
    f.static_copy_ind,
    f.rpt_marker_ind,
    f.dynamic_ind,
    f.dynamic_row_order,
    f.val_raw,
    f.submission_dt,
    f.ds_rcrd_st,
    f.ds_rcrd_isrt_dt,
    f.ds_rcrd_udt_dt,
    f.ds_etl_pcs_tms

FROM datamart.opr_fir_value f
;


-- ==========================================================
-- 14. OPERATIONAL: ndtnn_opr_foreign_investor_report_flat
-- ==========================================================
TRUNCATE TABLE IF EXISTS datamart.ndtnn_opr_foreign_investor_report_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.ndtnn_opr_foreign_investor_report_flat
SELECT
    -- From: OPR_FOREIGN_INVESTOR_REPORT
    f.fir_id,
    f.fir_code,
    f.src_stm_code,
    f.rpt_id,
    f.rpt_code,
    f.rpt_nm,
    f.legal_basis,
    f.rpt_status,
    f.sheet_code,
    f.sheet_nm,
    f.sheet_index,
    f.ds_rcrd_st,
    f.ds_rcrd_isrt_dt,
    f.ds_rcrd_udt_dt,
    f.ds_rcrd_end_dt,
    f.ds_etl_pcs_tms

FROM datamart.opr_foreign_investor_report f
;


-- ==========================================================
-- 15. OPERATIONAL: ndtnn_opr_foreign_investor_reporting_entity_flat
-- ==========================================================
TRUNCATE TABLE IF EXISTS datamart.ndtnn_opr_foreign_investor_reporting_entity_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.ndtnn_opr_foreign_investor_reporting_entity_flat
SELECT
    -- From: OPR_FOREIGN_INVESTOR_REPORTING_ENTITY
    f.cl_foreign_investor_reporting_entity_id,
    f.cl_foreign_investor_reporting_entity_code,
    f.src_stm_code,
    f.reporting_entity_code,
    f.reporting_entity_tp_code,
    f.reporting_entity_tp_nm,
    f.entity_reference_nbr,
    f.reporting_entity_nm,
    f.reporting_entity_short_nm,
    f.ds_rcrd_st,
    f.ds_rcrd_isrt_dt,
    f.ds_rcrd_udt_dt,
    f.ds_rcrd_end_dt,
    f.ds_etl_pcs_tms

FROM datamart.opr_foreign_investor_reporting_entity f
;


-- ============================================================
-- 16. OPERATIONAL: ndtnn_opr_foreign_investor_report_explorer_val_flat
--    Bảng dữ liệu Data Explorer NDTNN (FIMS) — logic job fims_ods_to_clickhouse (FIMS_MART_TO_CLICKHOUSE_MAPPING.md §2–§3, §5) — O_NDTNN_61.
--    Không lọc lại dòng/chỉ tiêu (đã lọc ở Atomic); chỉ nối + đổi tên cột. Bản ghi hiện hành: ds_rcrd_st = 'ACTIVE' (+ ds_rcrd_end_dt = '2400-01-01' với SCD2).
--    Xóa–ghi lại theo ngày nộp. rpt_log_id ép số: không phải số → 0 (version thấp nhất).
-- ============================================================
DELETE FROM datamart.ndtnn_opr_foreign_investor_report_explorer_val_flat ON CLUSTER 'my_cluster'
WHERE submission_dt = :etl_date;
INSERT INTO datamart.ndtnn_opr_foreign_investor_report_explorer_val_flat
SELECT
    coalesce(v.rpt_day, v.submission_dt)                                    AS period_end_dt,
    coalesce(v.reporting_entity_code, '')                                   AS object_id,
    coalesce(e.reporting_entity_nm, '')                                     AS object_nm,
    coalesce(e.reporting_entity_tp_nm, '')                                  AS object_tp,
    coalesce(v.period_tp_code, '')                                          AS period_tp,
    coalesce(v.period_val, '')                                              AS period_val,
    coalesce(v.dynamic_row_order, 0)                                        AS dynamic_row_order,
    s.data_explorer_id                                                      AS indicator_id,
    coalesce(v.val_raw, '')                                                 AS indicator_val,
    toUInt64OrZero(v.rpt_log_id)                                            AS rpt_log_id,
    v.submission_dt                                                         AS submission_dt,
    now()                                                                   AS ds_etl_pcs_tms
FROM datamart.opr_fir_value v
INNER JOIN datamart.opr_fir_structure s
    ON s.fir_structure_id = v.fir_structure_id
   AND s.ds_rcrd_st = 'ACTIVE' AND toString(s.ds_rcrd_end_dt) = '2400-01-01'
INNER JOIN datamart.opr_foreign_investor_report r
    ON r.fir_id = s.fir_id
   AND r.ds_rcrd_st = 'ACTIVE' AND toString(r.ds_rcrd_end_dt) = '2400-01-01'
LEFT JOIN datamart.opr_foreign_investor_reporting_entity e
    ON e.reporting_entity_tp_code = v.reporting_entity_tp_code
   AND e.reporting_entity_code = v.reporting_entity_code
   AND e.ds_rcrd_st = 'ACTIVE' AND toString(e.ds_rcrd_end_dt) = '2400-01-01'
WHERE v.ds_rcrd_st = 'ACTIVE'
  AND v.submission_dt = :etl_date
;


-- ============================================================
-- 17. OPERATIONAL: ndtnn_opr_foreign_investor_report_explorer_indicator_flat
--    Cây chỉ tiêu Data Explorer NDTNN (FIMS) — logic job fims_ods_to_clickhouse (FIMS_MART_TO_CLICKHOUSE_MAPPING.md §4–§5) — O_NDTNN_61.
--    Phải chạy SAU khối 16 (đọc ndtnn_opr_foreign_investor_report_explorer_val_flat để suy unit_nm). Nạp toàn bộ (TRUNCATE + INSERT).
--    Mỗi data_explorer_id một dòng (LIMIT 1 BY, thứ tự sort_order, fir_structure_id) từ TOÀN BỘ opr_fir_structure hiện hành.
--    unit_nm phụ thuộc dữ liệu của ngày chạy (số ô chữ nhiều hơn số ô số → chữ), nên có thể khác nhau giữa hai lần chạy.
--    8 cột cuối (changed_by_nm … legal_basis) job FIMS không ghi — để rỗng.
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.ndtnn_opr_foreign_investor_report_explorer_indicator_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.ndtnn_opr_foreign_investor_report_explorer_indicator_flat
SELECT
    x.indicator_id                                                          AS indicator_id,
    x.nhom                                                                  AS indicator_group_nm,
    x.ten                                                                   AS indicator_nm,
    toInt32(1)                                                              AS indicator_tp,
    'datamart.opr_fir_value'                                                AS source_table_nm,
    'ndtnn_opr_foreign_investor_report_explorer_val_flat'                                                                  AS target_table_nm,
    'period_end_dt,object_id,object_nm,object_tp,dynamic_row_order,period_tp,period_val'
                                                                            AS group_key_list,
    ''                                                                      AS logic_function,
    toInt32(1)                                                              AS indicator_level,
    toInt32(1)                                                              AS active_ind,
    toDate('2000-01-01')                                                    AS effective_from_dt,
    toDate('2099-12-31')                                                    AS effective_to_dt,
    now()                                                                   AS ds_etl_pcs_tms,
    -- số: khai numberic/percentage và trong khoảng ngày chạy số ô chữ KHÔNG nhiều hơn số ô số; chỉ tiêu số có lá column_path chứa '%' hoặc bắt đầu 'tỷ lệ' → '%'
    multiIf(
        NOT x.declared_num OR st.n_text > st.n_num, '__text__',
        position(x.col_leaf, '%') > 0 OR startsWith(lowerUTF8(x.col_leaf), 'tỷ lệ'), '%',
        '')                                                                 AS unit_nm,
    x.sort_ord                                                              AS sort_order_nbr,
    ''                                                                      AS changed_by_nm,
    ''                                                                      AS rpt_nm,
    ''                                                                      AS sheet_nm,
    ''                                                                      AS row_path,
    ''                                                                      AS column_path,
    ''                                                                      AS object_tp_list,
    ''                                                                      AS object_sub_tp_list,
    ''                                                                      AS legal_basis
FROM
(
    -- Lớp 2: dựng nhóm / tên / cờ số-chữ cho mỗi data_explorer_id (chuỗi ' > ' bên trong rpt_nm, legal_basis, sheet_nm đổi thành ' / ')
    SELECT
        s.data_explorer_id                                                  AS indicator_id,
        arrayStringConcat(arrayFilter(p -> p != '', [
            concat(replaceAll(coalesce(r.rpt_nm, ''), ' > ', ' / '),
                   if(coalesce(r.legal_basis, '') != '', concat(' - ', replaceAll(r.legal_basis, ' > ', ' / ')), '')),
            replaceAll(coalesce(r.sheet_nm, ''), ' > ', ' / '),
            if(coalesce(s.column_path, '') != '', coalesce(s.row_path, ''),
               arrayStringConcat(arrayPopBack(splitByString(' > ', coalesce(s.row_path, ''))), ' > ')),
            if(s.dynamic_ind = 1, 'Chi tiết', '')
        ]), ' > ')                                                          AS nhom,
        if(coalesce(s.column_path, '') != '', s.column_path,
           arrayElement(splitByString(' > ', coalesce(s.row_path, '')), -1)) AS ten,
        arrayElement(splitByString(' > ', coalesce(s.column_path, '')), -1) AS col_leaf,
        coalesce(s.data_tp, '') IN ('numberic', 'percentage')               AS declared_num,
        toInt64(coalesce(s.sort_order, 0))                                  AS sort_ord
    FROM datamart.opr_fir_structure s
    INNER JOIN datamart.opr_foreign_investor_report r
        ON r.fir_id = s.fir_id
       AND r.ds_rcrd_st = 'ACTIVE' AND toString(r.ds_rcrd_end_dt) = '2400-01-01'
    WHERE s.ds_rcrd_st = 'ACTIVE' AND toString(s.ds_rcrd_end_dt) = '2400-01-01'
      AND coalesce(s.data_explorer_id, '') != ''
    ORDER BY s.data_explorer_id, s.sort_order, s.fir_structure_id
    LIMIT 1 BY s.data_explorer_id
) x
LEFT JOIN
(
    -- đếm ô chữ thật sự / ô ra số trong khoảng ngày chạy (chấp nhận dấu phẩy nghìn)
    SELECT
        indicator_id,
        countIf(indicator_val != '' AND isNull(toFloat64OrNull(replaceAll(indicator_val, ',', '')))) AS n_text,
        countIf(isNotNull(toFloat64OrNull(replaceAll(indicator_val, ',', ''))))                      AS n_num
    FROM datamart.ndtnn_opr_foreign_investor_report_explorer_val_flat
    WHERE submission_dt = :etl_date
    GROUP BY indicator_id
) st ON st.indicator_id = x.indicator_id
;
