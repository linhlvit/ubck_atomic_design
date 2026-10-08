-- ============================================================
-- VP Flat Tables — CREATE
-- Module: Báo cáo Văn phòng (VP)
-- Generated: Phase 3 LLD Datamart
-- 2 bảng:
--   1. vp_fact_otc_bond_snapshot_flat (Nhóm 11, 12, 13: TPDN riêng lẻ)
--   2. vp_fact_share_auction_snapshot_flat (Nhóm 43: Đấu giá cổ phần)
-- ============================================================


-- ============================================================
-- 1. FACT: vp_fact_otc_bond_snapshot_flat
--    Snapshot giao dịch TPDN riêng lẻ — 1 row / ngày giao dịch
--    Grain: 1 ngày giao dịch
--    Joins: Calendar Date Dimension (snpst_dt_dim_id JOIN)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.vp_fact_otc_bond_snapshot_flat ON CLUSTER 'my_cluster'
(
    otc_bnd_snpst_id             String                  COMMENT 'PK đại diện của bản ghi snapshot',
    snpst_dt_dim_id              String                  COMMENT 'FK tới Calendar Date Dimension',
    trading_dt                   Date                    COMMENT 'Ngày giao dịch báo cáo',
    cdr_dt                       Date                    COMMENT 'Ngày giao dịch chuẩn hoá (Calendar Date)',
    year                         Int32                   COMMENT 'Năm giao dịch',
    month                        Int32                   COMMENT 'Tháng giao dịch',
    trading_val                  Nullable(Float64)       COMMENT 'Tổng giá trị giao dịch TPDN riêng lẻ trong ngày (K_VP_48)',
    foreign_buy_val              Nullable(Float64)       COMMENT 'Giá trị NĐTNN mua TPDN riêng lẻ trong ngày (K_VP_52)',
    foreign_sell_val             Nullable(Float64)       COMMENT 'Giá trị NĐTNN bán TPDN riêng lẻ trong ngày (K_VP_54)',
    foreign_net_val              Nullable(Float64)       COMMENT 'Giá trị NĐTNN mua/bán ròng TPDN riêng lẻ trong ngày (K_VP_56)',
    prop_buy_val                 Nullable(Float64)       COMMENT 'Giá trị Khối tự doanh mua TPDN riêng lẻ trong ngày',
    prop_sell_val                Nullable(Float64)       COMMENT 'Giá trị Khối tự doanh bán TPDN riêng lẻ trong ngày',
    reg_security_count           Nullable(Int32)         COMMENT 'Số mã TPDN riêng lẻ đăng ký giao dịch (K_VP_58)',
    src_stm_code                 String                  COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), otc_bnd_snpst_id)
COMMENT 'Flat table — Fact OTC Bond Snapshot × Calendar Date Dimension'
;


-- ============================================================
-- 2. FACT: vp_fact_share_auction_snapshot_flat
--    Snapshot kết quả đấu giá cổ phần — 1 row / năm / loại hình / sở GD
--    Grain: 1 năm × 1 loại hình đấu giá × 1 sở tổ chức
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.vp_fact_share_auction_snapshot_flat ON CLUSTER 'my_cluster'
(
    share_auction_snpst_id       String                  COMMENT 'PK đại diện của bản ghi snapshot',
    rpt_year                     Int32                   COMMENT 'Năm báo cáo kết quả đấu giá',
    auction_type_code            String                  COMMENT 'Mã loại hình đấu giá',
    auction_type_name            String                  COMMENT 'Tên loại hình đấu giá (K_VP_144)',
    exchange_code                Nullable(String)        COMMENT 'Sở tổ chức đấu giá (HOSE, HNX)',
    auction_session_cnt          Nullable(Int32)         COMMENT 'Số lượng phiên đấu giá tổ chức thành công (K_VP_146)',
    winning_auction_val          Nullable(Float64)       COMMENT 'Tổng giá trị cổ phần trúng giá (K_VP_145)',
    src_stm_code                 String                  COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (rpt_year, auction_type_code, share_auction_snpst_id)
COMMENT 'Flat table — Fact Share Auction Snapshot'
;
