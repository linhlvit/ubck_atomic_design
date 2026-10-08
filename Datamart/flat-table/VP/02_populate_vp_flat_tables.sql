-- ============================================================
-- VP Flat Tables — POPULATE
-- Module: Báo cáo Văn phòng (VP)
-- Generated: Phase 3 LLD Datamart
-- 2 bảng:
--   1. vp_fact_otc_bond_snapshot_flat
--   2. vp_fact_share_auction_snapshot_flat
-- ============================================================


-- ============================================================
-- 1. FACT: vp_fact_otc_bond_snapshot_flat
--    cal: JOIN + DELETE-scoped theo cdr_dt = :etl_date
-- ============================================================
DELETE FROM datamart.vp_fact_otc_bond_snapshot_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;

INSERT INTO datamart.vp_fact_otc_bond_snapshot_flat
SELECT
    f.otc_bnd_snpst_id,
    f.snpst_dt_dim_id,
    f.trading_dt,
    d.cdr_dt,
    d.year,
    d.month,
    f.trading_val,
    f.foreign_buy_val,
    f.foreign_sell_val,
    f.foreign_net_val,
    f.prop_buy_val,
    f.prop_sell_val,
    f.reg_security_count,
    f.src_stm_code
FROM datamart.fact_otc_bond_snapshot AS f
LEFT JOIN datamart.cdr_dt_dim AS d ON f.snpst_dt_dim_id = d.cdr_dt_dim_id
WHERE d.cdr_dt = :etl_date;


-- ============================================================
-- 2. FACT: vp_fact_share_auction_snapshot_flat
--    Annual snapshot: TRUNCATE + INSERT toàn bộ
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.vp_fact_share_auction_snapshot_flat ON CLUSTER 'my_cluster';

INSERT INTO datamart.vp_fact_share_auction_snapshot_flat
SELECT
    f.share_auction_snpst_id,
    f.rpt_year,
    f.auction_type_code,
    f.auction_type_name,
    f.exchange_code,
    f.auction_session_cnt,
    f.winning_auction_val,
    f.src_stm_code
FROM datamart.fact_share_auction_snapshot AS f;
