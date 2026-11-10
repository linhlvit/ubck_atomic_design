-- ============================================================
-- QLQ Flat Tables — POPULATE
-- Module: Quản lý Quỹ (Fund Management) — QLQ
-- Generated: Phase 3 LLD Datamart
-- 20 bảng: 5 fact + 15 operational
-- Sửa 2026-10-14: thêm #18 qlq_opr_foreign_fund_management_organization_unit_contract_list_flat (Nhóm 27) và #19 qlq_fund_management_company_staff_trade_rpt_flat (Nhóm 28) — trước đó PENDING
-- Sửa 2026-10-14: thêm #17 qlq_fct_fund_management_rpt_cell_val_flat (Dashboard RPT, 51 KPI READY) — bị bỏ sót ở commit 2f62880d
-- Sửa 2026-10-27: 4 Fact snapshot (#1, #2, #4, #5) nạp ĐỦ mọi tháng — bỏ điều kiện khóa 1 ngày chạy ETL (O_QLQ_53)
-- Tham số ETL hàng ngày: :etl_date (không dùng {etl_date}/$etl_date/hardcode)
-- Sửa 2026-11-08: #21 + #22 thay #21 cũ — logic biến đổi của job Data Explorer ODS cũ chuyển thành INSERT...SELECT từ 3 bảng Datamart (fct_dynamic_report_val, dynamic_report_structure_dim, dynamic_report_submission_history_dim); nạp ĐỦ (TRUNCATE + INSERT), #22 phải chạy SAU #21 (O_QLQ_80)
-- ============================================================

-- ============================================================
-- 1. FACT: qlq_fct_fund_management_company_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_fct_fund_management_company_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_fct_fund_management_company_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.investment_fund_count,
    f.active_fund_management_company_count,
    f.foreign_fund_management_organization_unit_count,
    f.active_foreign_fund_management_organization_unit_count,
    f.pending_closure_foreign_fund_management_organization_unit_count,
    f.closed_foreign_fund_management_organization_unit_count,
    f.custodian_bank_count,
    snpst_cal.cdr_dt              AS snpst_cdr_dt
FROM datamart.fct_fund_management_company_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- [SỬA 2026-10-27, O_QLQ_53] nạp mọi tháng (TRUNCATE + INSERT), không khóa theo ngày chạy ETL
;


-- ============================================================
-- 2. FACT: qlq_fct_investment_fund_count_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_fct_investment_fund_count_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_fct_investment_fund_count_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.fund_type_id,
    f.fund_count,
    f.charter_capital_amt,
    f.src_stm_code,
    f.active_fund_count,
    f.inactive_fund_count,
    snpst_cal.cdr_dt              AS snpst_cdr_dt,
    fund_type_dim.fund_type_code  AS fund_type_code,
    fund_type_dim.fund_type_nm    AS fund_type_nm,
    fund_type_dim.open_fund_indicator AS open_fund_indicator
FROM datamart.fct_investment_fund_count_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.fund_type_dim fund_type_dim
    ON fund_type_dim.fund_type_id = f.fund_type_id
-- [SỬA 2026-10-27, O_QLQ_53] nạp mọi tháng (TRUNCATE + INSERT), không khóa theo ngày chạy ETL
;


-- ============================================================
-- 4. FACT: qlq_fct_fund_distribution_agent_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_fct_fund_distribution_agent_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_fct_fund_distribution_agent_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.distribution_agent_count,
    snpst_cal.cdr_dt              AS snpst_cdr_dt
FROM datamart.fct_fund_distribution_agent_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- [SỬA 2026-10-27, O_QLQ_53] nạp mọi tháng (TRUNCATE + INSERT), không khóa theo ngày chạy ETL
;


-- ============================================================
-- 5. FACT: qlq_fct_foreign_fund_management_organization_unit_snpst_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_fct_foreign_fund_management_organization_unit_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_fct_foreign_fund_management_organization_unit_snpst_flat
SELECT
    f.snpst_dt_dim_id,
    f.branch_count,
    f.representative_office_count,
    f.active_representative_office_count,
    f.pending_closure_representative_office_count,
    f.closed_representative_office_count,
    snpst_cal.cdr_dt              AS snpst_cdr_dt
FROM datamart.fct_foreign_fund_management_organization_unit_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- [SỬA 2026-10-27, O_QLQ_53] nạp mọi tháng (TRUNCATE + INSERT), không khóa theo ngày chạy ETL
;


-- ============================================================
-- 6. OPERATIONAL: qlq_opr_fund_management_company_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_fund_management_company_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_fund_management_company_profile_flat
SELECT
    o.fmc_code,
    o.fmc_full_nm,
    o.fmc_short_nm,
    o.operation_status_nm,
    o.legal_representative_nm,
    o.fund_count,
    o.rating_class_code,
    o.total_score_amt,
    o.src_stm_code,
    o.fmc_id
FROM datamart.opr_fund_management_company_profile o
;


-- ============================================================
-- 7. OPERATIONAL: qlq_opr_fund_management_company_fund_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_fund_management_company_fund_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_fund_management_company_fund_list_flat
SELECT
    o.investment_fund_code,
    o.fmc_id,
    o.fmc_code,
    o.investment_fund_full_nm,
    o.fund_tp_code,
    o.src_stm_code
FROM datamart.opr_fund_management_company_fund_list o
;


-- ============================================================
-- 8. OPERATIONAL: qlq_opr_investment_fund_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_investment_fund_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_investment_fund_profile_flat
SELECT
    o.investment_fund_code,
    o.investment_fund_full_nm,
    o.investment_fund_short_nm,
    o.fund_tp_code,
    o.fmc_full_nm,
    o.custodian_bank_full_nm,
    o.representative_board_member_count,
    o.manager_count,
    o.outstanding_unit_quantity,
    o.distribution_agent_count,
    o.src_stm_code
FROM datamart.opr_investment_fund_profile o
;


-- ============================================================
-- 9. OPERATIONAL: qlq_opr_investment_fund_representative_board_member_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_investment_fund_representative_board_member_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_investment_fund_representative_board_member_list_flat
SELECT
    o.investment_fund_representative_board_member_code,
    o.investment_fund_id,
    o.investment_fund_code,
    o.board_member_full_nm,
    o.src_stm_code
FROM datamart.opr_investment_fund_representative_board_member_list o
;


-- ============================================================
-- 10. OPERATIONAL: qlq_opr_investment_fund_manager_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_investment_fund_manager_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_investment_fund_manager_list_flat
SELECT
    o.investment_fund_code,
    o.fmc_employee_code,
    o.fmc_employee_full_nm,
    o.src_stm_code
FROM datamart.opr_investment_fund_manager_list o
;


-- ============================================================
-- 11. OPERATIONAL: qlq_opr_fund_distribution_agent_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_fund_distribution_agent_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_fund_distribution_agent_profile_flat
SELECT
    o.securities_distribution_agent_code,
    o.securities_distribution_agent_full_nm,
    o.license_nbr,
    o.license_dt,
    o.distribution_cert_dt,
    o.address,
    o.active_status_flag,
    o.termination_dt,
    o.distributing_fund_count,
    o.src_stm_code
FROM datamart.opr_fund_distribution_agent_profile o
;


-- ============================================================
-- 12. OPERATIONAL: qlq_opr_fund_distribution_agent_fund_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_fund_distribution_agent_fund_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_fund_distribution_agent_fund_list_flat
SELECT
    o.fund_distribution_agent_code,
    o.investment_fund_code,
    o.investment_fund_full_nm,
    o.securities_distribution_agent_code,
    o.src_stm_code
FROM datamart.opr_fund_distribution_agent_fund_list o
;


-- ============================================================
-- 13. OPERATIONAL: qlq_opr_foreign_fund_management_organization_unit_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_foreign_fund_management_organization_unit_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_foreign_fund_management_organization_unit_profile_flat
SELECT
    o.foreign_fund_management_organization_unit_code,
    o.foreign_fund_management_organization_unit_full_nm,
    o.foreign_fund_management_organization_unit_short_nm,
    o.director_full_nm,
    o.src_stm_code
FROM datamart.opr_foreign_fund_management_organization_unit_profile o
;


-- ============================================================
-- 14. OPERATIONAL: qlq_opr_fund_management_report_sheet_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_fund_management_report_sheet_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_fund_management_report_sheet_list_flat
SELECT
    o.fmr_sheet_code,
    o.fmr_code,
    o.fmr_nm,
    o.fmr_tp_code,
    o.rpt_short_code,
    o.fmr_sheet_nm,
    o.sheet_short_code,
    o.src_stm_code
FROM datamart.opr_fund_management_report_sheet_list o
;

-- ============================================================
-- 15. OPERATIONAL: qlq_opr_investment_fund_distribution_agent_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_investment_fund_distribution_agent_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_investment_fund_distribution_agent_list_flat
SELECT
    o.investment_fund_code,
    o.fund_distribution_agent_code,
    o.fund_distribution_agent_full_nm,
    o.src_stm_code
FROM datamart.opr_investment_fund_distribution_agent_list o
;

-- ============================================================
-- 16. OPERATIONAL: qlq_opr_fund_management_company_contract_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_fund_management_company_contract_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_fund_management_company_contract_list_flat
SELECT
    o.fmr_submission_code,
    o.table_idx,
    o.investment_fund_code,
    o.fmc_code,
    o.record_tp,
    o.period_tp_code,
    o.period_val,
    o.rpt_year,
    o.version_nbr,
    o.customer_nm,
    o.custody_account_nbr,
    o.contract_market_val_amt,
    o.src_stm_code,
    o.fmc_id,
    o.custody_bank_nm,
    o.contract_val_amt,
    o.disbursed_val_amt,
    o.listed_securities_val_amt,
    o.unlisted_securities_val_amt,
    o.other_assets_val_amt,
    o.cash_val_amt
FROM datamart.opr_fund_management_company_contract_list o
;


-- ============================================================
-- 17. FACT: qlq_fct_fund_management_rpt_cell_val_flat
--    Nạp toàn bộ bản nộp hợp lệ: không lọc theo ngày chạy ETL (O_QLQ_72).
--    Không lọc theo ngày cuối kỳ báo cáo: KPI cần nhiều kỳ và nhiều bản nộp trong cùng bảng (O_QLQ_32).
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_fct_fund_management_rpt_cell_val_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_fct_fund_management_rpt_cell_val_flat
SELECT
    f.rpt_period_end_dt_dim_id,
    f.fund_management_rpt_cell_id,
    f.fund_type_id,
    f.open_fund_tp_code,
    f.fund_establishment_license_dt,
    f.fmr_val_code,
    f.fmc_code,
    f.investment_fund_code,
    f.securities_distribution_agent_code,
    f.foreign_fund_management_organization_unit_code,
    f.record_tp,
    f.period_tp_code,
    f.period_val,
    f.rpt_year,
    f.dynamic_row_nbr,
    f.submitted_dt,
    f.cell_val,
    f.cell_numeric_val,
    f.src_stm_code,
    f.fmc_id,
    rpt_period_end_cal.cdr_dt     AS rpt_period_end_cdr_dt,
    cell_dim.fmr_sheet_code,
    cell_dim.cell_id,
    cell_dim.fmr_code,
    cell_dim.fmr_nm,
    cell_dim.fmr_tp_code,
    cell_dim.rpt_short_code,
    cell_dim.rpt_group_code,
    cell_dim.stm_object_tp_code,
    cell_dim.cl_fms_fund_tp_code,
    cell_dim.version_nbr,
    cell_dim.legal_basis,
    cell_dim.fmr_sheet_nm,
    cell_dim.sheet_short_code,
    cell_dim.sheet_index,
    cell_dim.investment_portfolio_indicator,
    cell_dim.row_index,
    cell_dim.column_index,
    cell_dim.row_span,
    cell_dim.column_span,
    cell_dim.label_nm,
    cell_dim.row_stt_code,
    cell_dim.row_indicator_code,
    cell_dim.row_indicator_nm,
    cell_dim.row_label_nm,
    cell_dim.column_label_nm,
    fund_type_dim.fund_type_code,
    fund_type_dim.fund_type_nm,
    fund_type_dim.open_fund_indicator
FROM datamart.fct_fund_management_rpt_cell_val f
LEFT JOIN datamart.cdr_dt_dim rpt_period_end_cal
    ON rpt_period_end_cal.cdr_dt_dim_id = f.rpt_period_end_dt_dim_id
LEFT JOIN datamart.fund_management_rpt_cell_dim cell_dim
    ON cell_dim.fund_management_rpt_cell_id = f.fund_management_rpt_cell_id AND cell_dim.ds_rcrd_st = 'ACTIVE'
LEFT JOIN datamart.fund_type_dim fund_type_dim
    ON fund_type_dim.fund_type_id = f.fund_type_id AND fund_type_dim.ds_rcrd_st = 'ACTIVE'
;


-- ============================================================
-- 18. OPERATIONAL: qlq_opr_foreign_fund_management_organization_unit_contract_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_foreign_fund_management_organization_unit_contract_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_foreign_fund_management_organization_unit_contract_list_flat
SELECT
    o.fmr_submission_code,
    o.table_idx,
    o.foreign_fund_management_organization_unit_code,
    o.record_tp,
    o.period_tp_code,
    o.period_val,
    o.rpt_year,
    o.version_nbr,
    o.customer_nm,
    o.custody_account_nbr,
    o.contract_market_val_amt,
    o.src_stm_code
FROM datamart.opr_foreign_fund_management_organization_unit_contract_list o
;


-- ============================================================
-- 19. FACT (report): qlq_fund_management_company_staff_trade_rpt_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_fund_management_company_staff_trade_rpt_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_fund_management_company_staff_trade_rpt_flat
SELECT
    o.fmc_employee_code,
    o.trade_dt,
    o.securities_account_nbr,
    o.trade_direction_code,
    o.security_symbol_code,
    o.trade_method_nm,
    o.fmc_code,
    o.identification_nbr,
    o.securities_company_code,
    o.trade_direction_nm,
    o.order_vol,
    o.order_price,
    o.order_amt,
    o.src_stm_code
FROM datamart.fund_management_company_staff_trade_rpt o
;


-- ============================================================
-- 20. OPERATIONAL: qlq_opr_fund_management_company_employee_investor_account_list_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_fund_management_company_employee_investor_account_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_fund_management_company_employee_investor_account_list_flat
SELECT
    o.fmc_employee_code,
    o.investor_account_nbr,
    o.identification_nbr,
    o.fmc_code,
    o.fmc_employee_full_nm,
    o.account_open_dt,
    o.account_update_dt,
    o.src_stm_code
FROM datamart.opr_fund_management_company_employee_investor_account_list o
;


-- ============================================================
-- 21. OPERATIONAL: qlq_opr_dynamic_report_explorer_val_flat
--    Bảng dữ liệu khai thác Data Explorer QLQ (engine báo cáo động FMS) — thay default.bc_bao_cao_quy của job ODS cũ.
--    Nguồn: fct_dynamic_report_val + dynamic_report_structure_dim + dynamic_report_submission_history_dim (+ cdr_dt_dim ngày nộp).
--    Logic biến đổi GIỮ NGUYÊN job cũ (chỉ đổi tên bảng/cột): lần nộp thắng theo rpt_version, loại chỉ tiêu mồ côi, table_index/dynamic_index,
--    đánh số dòng trùng mã (ACB#2), indicator_id = md5, indicator_val, ngày cuối kỳ, alias dòng Tổng-N -> Chi tiết, khử trùng khóa ORDER BY.
--    Nạp toàn bộ (TRUNCATE + INSERT) — O_QLQ_80.
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_dynamic_report_explorer_val_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_dynamic_report_explorer_val_flat
SELECT
    ifNull(pend, nop)                                                       AS period_end_dt,
    ifNull(object_id, '')                                                   AS object_id,
    ifNull(object_nm, '')                                                   AS object_nm,
    ifNull(object_tp, '')                                                   AS object_tp,
    ifNull(object_sub_tp, '')                                               AS object_sub_tp,
    rpt_tp_nm                                                               AS rpt_tp_nm,
    ifNull(period_tp, '')                                                   AS period_tp,
    ifNull(period_val, '')                                                  AS period_val,
    toInt32(table_index)                                                    AS table_index,
    toInt32(dynamic_index)                                                  AS dynamic_index,
    entity_code_final                                                       AS entity_code,
    acc_clean                                                               AS custodian_bank_code,
    indicator_id                                                            AS indicator_id,
    multiIf(
        is_label, entity_base,
        kd IN ('string', 'datasource'), txt_val,
        match(vt, '^[+-]?(\\d+\\.?\\d*|\\.\\d+)([eE][+-]?\\d+)?$'),
            multiIf(
                match(vt, '^[+-]?\\d+$') AND isNotNull(toInt64OrNull(vt)), toString(toInt64OrNull(vt)),
                match(vt, '^\\+?\\d+$') AND isNotNull(toUInt64OrNull(replaceOne(vt, '+', ''))),
                    toString(toUInt64OrNull(replaceOne(vt, '+', ''))),
                concat(toString(toFloat64(vt)),
                       if(toFloat64(vt) = floor(toFloat64(vt)) AND abs(toFloat64(vt)) < 1e16
                              AND NOT match(toString(toFloat64(vt)), '[.eE]'), '.0', ''))),
        txt_val)                                                            AS indicator_val,
    ifNull(rpt_code, '')                                                    AS rpt_code,
    ifNull(rpt_nm, '')                                                      AS rpt_nm,
    log_id                                                                  AS dr_submission_history_code,
    now()                                                                   AS ds_etl_pcs_tms
FROM
(
    -- Lớp 3: khóa nghiệp vụ, ngày cuối kỳ, nhãn loại báo cáo, giá trị chuỗi; đánh số dòng trùng mã
    SELECT
        dr_val_id, log_id, nop, is_dyn, is_label, entity_base, kd, vt,
        object_id, object_nm, object_tp, object_sub_tp, period_tp, period_val, rpt_code, rpt_nm,
        table_index, dynamic_index,
        if(dup_mask AND rk >= 2, concat(entity_base, '#', toString(rk)), entity_base)       AS entity_code_final,
        if(accs IN ('', '0', 'nan', 'none'), '', accs)                                      AS acc_clean,
        if(vt != '' AND lowerUTF8(vt) NOT IN ('none', 'nan', '...'), vt, '0')               AS txt_val,
        multiIf(
            isNull(rtp_f), '',
            toInt64(rtp_f) = 1, 'Báo cáo định kỳ',
            toInt64(rtp_f) = 2, 'Báo cáo bất thường',
            toInt64(rtp_f) = 3, 'Báo cáo theo yêu cầu',
            toInt64(rtp_f) = 4, 'Báo cáo khác',
            '')                                                                             AS rpt_tp_nm,
        arrayJoin(
            if(is_dyn AND match(if(dup_mask AND rk >= 2, concat(entity_base, '#', toString(rk)), entity_base), '^Tổng-\\d+$'),
               [lower(hex(MD5(concat(rkey, '|', skey, '|', if(is_dyn, concat(erp, ' > ...'), erp), '|', ckey)))),
                lower(hex(MD5(concat(rkey, '|', skey, '|', concat(erp, ' > Chi tiết > ...'), '|', ckey))))],
               [lower(hex(MD5(concat(rkey, '|', skey, '|', if(is_dyn, concat(erp, ' > ...'), erp), '|', ckey))))]))
                                                                                            AS indicator_id,
        -- ngày cuối kỳ: kiểm tra vòng tròn vì toDateOrNull của ClickHouse tự cuộn ngày sai (2026-02-31 thành 2026-03-03,
        -- tháng 13 thành 1970-01-01) trong khi job cũ coi là không parse được và lấy ngày nộp
        if(pstr != '' AND toString(toDateOrNull(pstr)) = pstr,
           if(pkind = 1, toLastDayOfMonth(toDateOrNull(pstr)), toDateOrNull(pstr)), NULL)         AS pend
    FROM
    (
        -- Lớp 2: đánh số dòng trùng mã (dense_rank theo row_order) trong cùng lần nộp / bảng / TK / mục / mã
        SELECT
            *,
            dense_rank() OVER (PARTITION BY log_id, table_index, accs_raw, erp, entity_base, dup_mask ORDER BY ro_raw) AS rk
        FROM
        (
            -- Lớp 2a: table_index (BA: TABLE_IDX) và dynamic_index (BA: DYNAMIC_IDX)
            SELECT
                *,
                if(uniqExactIf(ro, NOT is_dyn) OVER (PARTITION BY log_id, skey) > 1,
                   if(is_dyn, toInt64(floor(ro / 1000)), ro), 0)                            AS table_index,
                if(is_dyn, ro - table_index * 1000, -1)                                     AS dynamic_index,
                is_dyn AND NOT match(entity_base, '^Tổng-\\d+$')                            AS dup_mask
            FROM
            (
                -- Lớp 1: ghép Fact với Dim cấu trúc (loại chỉ tiêu mồ côi), lịch sử nộp thắng, ngày nộp; suy các cột cơ sở
                SELECT
                    f.dr_val_id                                                             AS dr_val_id,
                    f.dr_submission_history_code                                            AS log_id,
                    d.cdr_dt                                                                AS nop,
                    toInt64(ifNull(f.row_dynamic_index, 0))                                 AS ro,
                    toInt64(ifNull(f.row_dynamic_index, -1))                                AS ro_raw,
                    ifNull(f.dynamic_ind, 0) = 1                                            AS is_dyn,
                    ifNull(f.label_column_ind, 0) = 1                                       AS is_label,
                    replaceRegexpAll(ifNull(f.custodian_bank_code, ''), '^\\s+|\\s+$', '')  AS accs,
                    ifNull(f.custodian_bank_code, '')                                       AS accs_raw,
                    lowerUTF8(replaceRegexpAll(ifNull(f.data_tp, ''), '^\\s+|\\s+$', ''))   AS kd,
                    replaceRegexpAll(ifNull(f.val, ''), '^\\s+|\\s+$', '')                  AS vt,
                    if(is_dyn
                           AND replaceRegexpAll(ifNull(f.entity_code, ''), '^\\s+|\\s+$', '') != ''
                           AND lowerUTF8(replaceRegexpAll(ifNull(f.entity_code, ''), '^\\s+|\\s+$', '')) NOT IN ('...', '0')
                           AND NOT match(replaceRegexpAll(ifNull(f.entity_code, ''), '^\\s+|\\s+$', ''), '^[. ]+$'),
                       replaceRegexpAll(ifNull(f.entity_code, ''), '^\\s+|\\s+$', ''), '') AS entity_base,
                    -- effective_row_path: dòng động = đường dẫn mẫu cắt trước ' > ...'; dòng tĩnh = đường dẫn mẫu nguyên văn
                    if(is_dyn,
                       if(replaceRegexpAll(ifNull(s.structure_row_path, ''), '^\\s+|\\s+$', '') = '...', '',
                          replaceRegexpAll(replaceRegexpOne(arrayElement(splitByString(' > ...',
                              replaceRegexpAll(ifNull(s.structure_row_path, ''), '^\\s+|\\s+$', '')), 1), '[ >]+$', ''),
                              '^\\s+|\\s+$', '')),
                       ifNull(s.structure_row_path, ''))                                    AS erp,
                    -- khóa md5: legal_basis (nếu có) gắn vào mã báo cáo; sheet/column NULL viết 'None' như job cũ (giữ nguyên id đã lưu)
                    if(replaceRegexpAll(ifNull(s.legal_basis, ''), '^\\s+|\\s+$', '') != '',
                       concat(ifNull(s.rpt_code, ''), '|', replaceRegexpAll(ifNull(s.legal_basis, ''), '^\\s+|\\s+$', '')),
                       ifNull(s.rpt_code, ''))                                              AS rkey,
                    ifNull(s.sheet_nm, 'None')                                              AS skey,
                    ifNull(s.column_path, 'None')                                           AS ckey,
                    s.rpt_code                                                              AS rpt_code,
                    s.rpt_nm                                                                AS rpt_nm,
                    w.object_id                                                             AS object_id,
                    w.object_nm                                                             AS object_nm,
                    w.object_tp                                                             AS object_tp,
                    w.object_sub_tp                                                         AS object_sub_tp,
                    w.rpt_tp                                                                AS rpt_tp,
                    toFloat64OrNull(replaceRegexpAll(ifNull(w.rpt_tp, ''), '^\\s+|\\s+$', '')) AS rtp_f,
                    w.period_tp                                                             AS period_tp,
                    w.period_val                                                            AS period_val,
                    upper(replaceRegexpAll(ifNull(w.period_tp, ''), '^\\s+|\\s+$', ''))     AS period_tp_u,
                    upper(replaceRegexpAll(ifNull(w.period_val, ''), '^\\s+|\\s+$', ''))    AS period_val_u,
                    -- pstr: chuỗi ngày ứng viên của ngày cuối kỳ (rỗng nếu kỳ không parse được)
                    multiIf(
                        period_tp_u = 'THANG' AND match(period_val_u, '^T\\d{1,2}/\\d{4}$'),
                            concat(extractGroups(period_val_u, '^T(\\d{1,2})/(\\d{4})$')[2], '-',
                                   leftPad(extractGroups(period_val_u, '^T(\\d{1,2})/(\\d{4})$')[1], 2, '0'), '-01'),
                        period_tp_u = 'QUY' AND match(period_val_u, '^Q[1-4]/\\d{4}$'),
                            concat(extractGroups(period_val_u, '^Q([1-4])/(\\d{4})$')[2], '-',
                                   leftPad(toString(toUInt8OrZero(extractGroups(period_val_u, '^Q([1-4])/(\\d{4})$')[1]) * 3), 2, '0'), '-01'),
                        period_tp_u = '6_THANG' AND match(period_val_u, '^6T[12]/\\d{4}$'),
                            concat(extractGroups(period_val_u, '^6T([12])/(\\d{4})$')[2], '-',
                                   if(extractGroups(period_val_u, '^6T([12])/(\\d{4})$')[1] = '1', '06', '12'), '-01'),
                        period_tp_u = 'NAM' AND match(period_val_u, '^NAM_\\d{4}$'),
                            concat(extractGroups(period_val_u, '^NAM_(\\d{4})$')[1], '-12-31'),
                        period_tp_u = 'NGAY' AND match(period_val_u, '^\\d{1,2}/\\d{1,2}/\\d{4}'),
                            concat(extractGroups(period_val_u, '^(\\d{1,2})/(\\d{1,2})/(\\d{4})')[3], '-',
                                   leftPad(extractGroups(period_val_u, '^(\\d{1,2})/(\\d{1,2})/(\\d{4})')[2], 2, '0'), '-',
                                   leftPad(extractGroups(period_val_u, '^(\\d{1,2})/(\\d{1,2})/(\\d{4})')[1], 2, '0')),
                        period_tp_u = 'NUA_THANG' AND match(period_val_u, '^NT[12]/\\d{1,2}/\\d{4}$'),
                            concat(extractGroups(period_val_u, '^NT([12])/(\\d{1,2})/(\\d{4})$')[3], '-',
                                   leftPad(extractGroups(period_val_u, '^NT([12])/(\\d{1,2})/(\\d{4})$')[2], 2, '0'),
                                   if(extractGroups(period_val_u, '^NT([12])/(\\d{1,2})/(\\d{4})$')[1] = '1', '-15', '-01')),
                        period_tp_u = 'TUAN' AND match(period_val_u, '^TU\\d{1,2}/\\d{4}$')
                            AND toISOYear(toMonday(toDateOrNull(concat(extractGroups(period_val_u, '^TU(\\d{1,2})/(\\d{4})$')[2], '-01-04')))
                                    + (toUInt8OrZero(extractGroups(period_val_u, '^TU(\\d{1,2})/(\\d{4})$')[1]) - 1) * 7 + 6)
                                = toUInt16OrZero(extractGroups(period_val_u, '^TU(\\d{1,2})/(\\d{4})$')[2])
                            AND toISOWeek(toMonday(toDateOrNull(concat(extractGroups(period_val_u, '^TU(\\d{1,2})/(\\d{4})$')[2], '-01-04')))
                                    + (toUInt8OrZero(extractGroups(period_val_u, '^TU(\\d{1,2})/(\\d{4})$')[1]) - 1) * 7 + 6)
                                = toUInt8OrZero(extractGroups(period_val_u, '^TU(\\d{1,2})/(\\d{4})$')[1]),
                            toString(toMonday(toDateOrNull(concat(extractGroups(period_val_u, '^TU(\\d{1,2})/(\\d{4})$')[2], '-01-04')))
                                    + (toUInt8OrZero(extractGroups(period_val_u, '^TU(\\d{1,2})/(\\d{4})$')[1]) - 1) * 7 + 6),
                        '')                                                                 AS pstr,
                    -- pkind = 1: lấy ngày cuối THÁNG của pstr (THANG, QUY, 6_THANG, nửa tháng thứ hai); 0: dùng đúng ngày pstr
                    multiIf(period_tp_u IN ('THANG', 'QUY', '6_THANG'), 1,
                            period_tp_u = 'NUA_THANG' AND startsWith(period_val_u, 'NT2'), 1, 0) AS pkind
                FROM datamart.fct_dynamic_report_val f
                INNER JOIN datamart.cdr_dt_dim d
                    ON d.cdr_dt_dim_id = f.submission_dt_dim_id
                INNER JOIN datamart.dynamic_report_structure_dim s
                    ON s.dr_structure_code = f.dr_structure_code AND s.ds_rcrd_st = 'ACTIVE'
                INNER JOIN
                (
                    -- Lần nộp thắng: mỗi nhóm (đối tượng, báo cáo, loại kỳ, kỳ) chỉ giữ lần nộp có rpt_version cao nhất
                    -- (NULL = thấp nhất; cùng version cao nhất thì giữ tất cả). Xét TOÀN BỘ lịch sử nộp, không chỉ lần nộp có dòng giá trị.
                    SELECT
                        dr_submission_history_code AS log_id, object_id, object_nm, object_tp, object_sub_tp, rpt_tp, period_tp, period_val
                    FROM
                    (
                        SELECT
                            h.dr_submission_history_code AS dr_submission_history_code,
                            h.object_id AS object_id, h.object_nm AS object_nm, h.object_tp AS object_tp,
                            h.object_sub_tp AS object_sub_tp, h.rpt_tp AS rpt_tp, h.period_tp AS period_tp, h.period_val AS period_val,
                            ifNull(toInt64(h.rpt_version), -9223372036854775807) AS ver,
                            max(ifNull(toInt64(h.rpt_version), -9223372036854775807)) OVER (
                                PARTITION BY ifNull(h.object_id, ''), ifNull(h.submission_rpt_code, ''),
                                             ifNull(h.period_tp, ''), ifNull(h.period_val, '')) AS best_ver
                        FROM datamart.dynamic_report_submission_history_dim h
                        WHERE h.ds_rcrd_st = 'ACTIVE'
                    )
                    WHERE ver = best_ver
                ) w
                    ON w.log_id = f.dr_submission_history_code
            )
        )
    )
)
-- Khử trùng theo khóa ORDER BY: giữ bản có ngày nộp mới nhất (hòa thì dr_val_id lớn nhất)
ORDER BY nop DESC, dr_val_id DESC
LIMIT 1 BY period_end_dt, object_id, period_tp, period_val, dr_submission_history_code, table_index, entity_code, custodian_bank_code, indicator_id
;


-- ============================================================
-- 22. OPERATIONAL: qlq_opr_dynamic_report_explorer_indicator_flat
--    Bảng chỉ tiêu (metadata) Data Explorer QLQ — thay phần targettable QLQ của default.metadata_etl của job ODS cũ.
--    Chỉ tiêu = mọi ô của mẫu báo cáo (dynamic_report_structure_dim), gồm cả chỉ tiêu chưa có dữ liệu. Phải chạy SAU khối 21
--    (đọc qlq_opr_dynamic_report_explorer_val_flat để suy unit_nm số/chữ). Nạp toàn bộ (TRUNCATE + INSERT) — O_QLQ_80.
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_dynamic_report_explorer_indicator_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_dynamic_report_explorer_indicator_flat
SELECT
    x.id                                                                    AS indicator_id,
    x.grp_nm                                                                AS indicator_group_nm,
    x.ind_nm                                                                AS indicator_nm,
    toInt32(1)                                                              AS indicator_tp,
    'datamart.fct_dynamic_report_val'                                       AS source_table_nm,
    'qlq_opr_dynamic_report_explorer_val_flat'                              AS target_table_nm,
    'period_end_dt,object_id,object_nm,object_tp,object_sub_tp,rpt_tp_nm,dr_submission_history_code,table_index,dynamic_index,entity_code,custodian_bank_code,period_tp,period_val'
                                                                            AS group_key_list,
    ''                                                                      AS logic_function,
    toInt32(1)                                                              AS indicator_level,
    toInt32(1)                                                              AS active_ind,
    toDate('2000-01-01')                                                    AS effective_from_dt,
    toDate('2099-12-31')                                                    AS effective_to_dt,
    now()                                                                   AS ds_etl_pcs_tms,
    -- số khi: mọi ô khai báo kiểu số (không phải cột nhãn) và không có giá trị chữ nào; còn lại là chữ
    if(x.declared = 1 AND ne.ne_id = '', '', '__text__')                    AS unit_nm,
    x.sort_ord                                                              AS sort_order_nbr,
    x.rn                                                                    AS rpt_nm,
    x.sn                                                                    AS sheet_nm,
    x.rowpath                                                               AS row_path,
    x.cp                                                                    AS column_path,
    ot.ot_lst                                                               AS object_tp_list,
    ft.ft_lst                                                               AS object_sub_tp_list
FROM
(
    -- Lớp 2: tên nhóm, tên chỉ tiêu, đường dẫn hàng, thứ tự sắp xếp; bỏ chỉ tiêu tĩnh "ma" của sheet thuần dòng động
    SELECT
        *,
        if(cp != '', erp, arrayStringConcat(arrayMap(p -> replaceRegexpAll(p, '^\\s+|\\s+$', ''), arrayPopBack(splitByChar('>', erp))), ' > ')) AS nhom_base,
        arrayStringConcat(arrayMap(p -> if(replaceRegexpAll(p, '^\\s+|\\s+$', '') = '...', 'Chi tiết', p),
            arrayFilter(p -> replaceRegexpAll(p, '^\\s+|\\s+$', '') != '', splitByString(' > ', nhom_base))), ' > ')   AS nhom_norm,
        if(isd = 1, if(nhom_norm != '', concat(nhom_norm, ' > Chi tiết'), 'Chi tiết'), nhom_norm)                  AS nhom,
        arrayStringConcat(arrayFilter(g -> g != '', [rn, sn, nhom]), ' > ')                                        AS grp_nm,
        if(cp != '', cp, arrayElement(arrayMap(p -> replaceRegexpAll(p, '^\\s+|\\s+$', ''), splitByChar('>', erp)), -1)) AS ind_nm,
        arrayStringConcat(
            arrayConcat(
                arrayMap(p -> if(replaceRegexpAll(p, '^\\s+|\\s+$', '') = '...', 'Chi tiết', p),
                    arrayFilter(p -> replaceRegexpAll(p, '^\\s+|\\s+$', '') != '', splitByString(' > ', erp))),
                if(isd = 1, ['Chi tiết'], [])), ' > ')                                                             AS rowpath,
        -- sort_order: có row_index thì row_index * 1000 + cột; không thì khóa phân cấp theo tối đa 4 đoạn của đường dẫn hàng
        if(rowidx IS NOT NULL,
           toInt64(rowidx) * 1000 + least(colidx, 999),
           arraySum(arrayMap((stt, i) ->
               multiIf(
                   stt = '' OR stt IN ('...', '-', '—'), 990,
                   match(stt, '^\\d+$'), 100 + toInt64OrZero(stt),
                   i = 1 AND match(stt, '^[ABEFGHJKNOPQRSTUWYZabefghjknopqrstuwyz]$'), toInt64(ascii(upper(stt))) - 65,
                   match(upper(stt), '^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$'),
                       26 + arrayMap(rv -> arraySum(arrayMap((v, nx) -> if(v < nx, -v, v), rv, arrayPushBack(arrayPopFront(rv), 0))),
                                [arrayMap(c -> multiIf(c = 'M', 1000, c = 'D', 500, c = 'C', 100, c = 'L', 50, c = 'X', 10, c = 'V', 5, c = 'I', 1, 0),
                                          splitByString('', upper(stt)))])[1],
                   match(stt, '^[A-Za-z]$'), toInt64(ascii(upper(stt))) - 65,
                   999) * [1000000000, 1000000, 1000, 1][i],
               arrayMap(sg -> replaceRegexpAll(arrayElement(splitByChar('-', sg), 1), '^\\s+|\\s+$', ''),
                        arraySlice(if(erp = '', [], arrayMap(s -> replaceRegexpAll(s, '^\\s+|\\s+$', ''), splitByString(' > ', erp))), 1, 4)),
               arrayEnumerate(arraySlice(if(erp = '', [], arrayMap(s -> replaceRegexpAll(s, '^\\s+|\\s+$', ''), splitByString(' > ', erp))), 1, 4))
           )) * 1000 + least(colidx, 999))                                                                         AS sort_ord
    FROM
    (
        -- Lớp 1b: nhận diện cột của sheet thuần dòng động (có chỉ tiêu động với đường dẫn hàng rỗng)
        SELECT
            *,
            maxIf(1, isd = 1 AND erp = '') OVER (PARTITION BY rn, sn, cp) AS dyn_col
        FROM
        (
            -- Lớp 1a: hợp nhất 3 nguồn chỉ tiêu, mỗi indicator_id giữ nguồn ưu tiên cao nhất
            SELECT id, erp, isd, rcode, rn, sn, cp, colidx, rowidx, declared, prio, ikm
            FROM
            (
                -- Ưu tiên 1: chỉ tiêu CÓ dữ liệu (thuộc tính lấy từ ô giá trị của lần nộp thắng)
                SELECT
                    id,
                    argMin(erp, ik)                                                 AS erp,
                    argMin(isd, ik)                                                 AS isd,
                    argMin(rcode, ik)                                               AS rcode,
                    argMin(rn, ik)                                                  AS rn,
                    argMin(sn, ik)                                                  AS sn,
                    argMin(cp, ik)                                                  AS cp,
                    argMin(colidx, ik)                                              AS colidx,
                    argMin(rowidx, ik)                                              AS rowidx,
                    toUInt8(max(nonnum) = 0)                                        AS declared,
                    toUInt8(1)                                                      AS prio,
                    min(ik)                                                         AS ikm
                FROM
                (
                    SELECT
                        s.dr_structure_code                                         AS ik,
                        ifNull(f.dynamic_ind, 0) = 1                                AS is_dyn,
                        if(is_dyn,
                           if(replaceRegexpAll(ifNull(s.structure_row_path, ''), '^\\s+|\\s+$', '') = '...', '',
                              replaceRegexpAll(replaceRegexpOne(arrayElement(splitByString(' > ...',
                                  replaceRegexpAll(ifNull(s.structure_row_path, ''), '^\\s+|\\s+$', '')), 1), '[ >]+$', ''),
                                  '^\\s+|\\s+$', '')),
                           ifNull(s.structure_row_path, ''))                        AS erp,
                        lower(hex(MD5(concat(
                            if(replaceRegexpAll(ifNull(s.legal_basis, ''), '^\\s+|\\s+$', '') != '',
                               concat(ifNull(s.rpt_code, ''), '|', replaceRegexpAll(ifNull(s.legal_basis, ''), '^\\s+|\\s+$', '')),
                               ifNull(s.rpt_code, '')),
                            '|', ifNull(s.sheet_nm, 'None'), '|', if(is_dyn, concat(erp, ' > ...'), erp), '|', ifNull(s.column_path, 'None'))))) AS id,
                        is_dyn                                                      AS isd,
                        ifNull(s.rpt_code, '')                                      AS rcode,
                        ifNull(s.rpt_nm, '')                                        AS rn,
                        ifNull(s.sheet_nm, '')                                      AS sn,
                        ifNull(s.column_path, '')                                   AS cp,
                        ifNull(s.column_index, 0)                                   AS colidx,
                        toNullable(toInt64(s.row_index))                            AS rowidx,
                        (lowerUTF8(replaceRegexpAll(ifNull(f.data_tp, ''), '^\\s+|\\s+$', '')) NOT IN ('numberic', 'number', 'numeric', 'percentage')
                            OR ifNull(f.label_column_ind, 0) = 1)                   AS nonnum
                    FROM datamart.fct_dynamic_report_val f
                    INNER JOIN datamart.cdr_dt_dim d
                        ON d.cdr_dt_dim_id = f.submission_dt_dim_id
                    INNER JOIN datamart.dynamic_report_structure_dim s
                        ON s.dr_structure_code = f.dr_structure_code AND s.ds_rcrd_st = 'ACTIVE'
                    INNER JOIN
                    (
                        SELECT dr_submission_history_code AS log_id
                        FROM
                        (
                            SELECT
                                h.dr_submission_history_code AS dr_submission_history_code,
                                ifNull(toInt64(h.rpt_version), -9223372036854775807) AS ver,
                                max(ifNull(toInt64(h.rpt_version), -9223372036854775807)) OVER (
                                    PARTITION BY ifNull(h.object_id, ''), ifNull(h.submission_rpt_code, ''),
                                                 ifNull(h.period_tp, ''), ifNull(h.period_val, '')) AS best_ver
                            FROM datamart.dynamic_report_submission_history_dim h
                            WHERE h.ds_rcrd_st = 'ACTIVE'
                        )
                        WHERE ver = best_ver
                    ) w
                        ON w.log_id = f.dr_submission_history_code
                )
                GROUP BY id
                HAVING rn != '' OR sn != ''

                UNION ALL

                -- Ưu tiên 2: chỉ tiêu TĨNH của mẫu chưa có dữ liệu (đường dẫn hàng không chứa ' > ...')
                SELECT
                    lower(hex(MD5(concat(
                        if(replaceRegexpAll(ifNull(s2.legal_basis, ''), '^\\s+|\\s+$', '') != '',
                           concat(ifNull(s2.rpt_code, ''), '|', replaceRegexpAll(ifNull(s2.legal_basis, ''), '^\\s+|\\s+$', '')),
                           ifNull(s2.rpt_code, '')),
                        '|', ifNull(s2.sheet_nm, 'None'), '|',
                        replaceRegexpAll(replaceRegexpOne(ifNull(s2.structure_row_path, ''), '[ >]+$', ''), '^\\s+|\\s+$', ''),
                        '|', ifNull(s2.column_path, 'None')))))                     AS id,
                    replaceRegexpAll(replaceRegexpOne(ifNull(s2.structure_row_path, ''), '[ >]+$', ''), '^\\s+|\\s+$', '') AS erp,
                    toUInt8(0)                                                      AS isd,
                    ifNull(s2.rpt_code, '')                                         AS rcode,
                    ifNull(s2.rpt_nm, '')                                           AS rn,
                    ifNull(s2.sheet_nm, '')                                         AS sn,
                    ifNull(s2.column_path, '')                                      AS cp,
                    ifNull(s2.column_index, 0)                                      AS colidx,
                    toNullable(toInt64(s2.row_index))                               AS rowidx,
                    toUInt8(0)                                                      AS declared,
                    toUInt8(2)                                                      AS prio,
                    s2.dr_structure_code                                            AS ikm
                FROM datamart.dynamic_report_structure_dim s2
                WHERE s2.ds_rcrd_st = 'ACTIVE'
                    AND position(ifNull(s2.structure_row_path, ''), ' > ...') = 0
                    AND replaceRegexpAll(ifNull(s2.structure_row_path, ''), '^\\s+|\\s+$', '') != '...'

                UNION ALL

                -- Ưu tiên 3: chỉ tiêu ĐỘNG của mẫu chưa có dữ liệu (đường dẫn hàng chứa ' > ...' hoặc đúng '...')
                SELECT
                    lower(hex(MD5(concat(
                        if(replaceRegexpAll(ifNull(s3.legal_basis, ''), '^\\s+|\\s+$', '') != '',
                           concat(ifNull(s3.rpt_code, ''), '|', replaceRegexpAll(ifNull(s3.legal_basis, ''), '^\\s+|\\s+$', '')),
                           ifNull(s3.rpt_code, '')),
                        '|', ifNull(s3.sheet_nm, 'None'), '|',
                        if(replaceRegexpAll(ifNull(s3.structure_row_path, ''), '^\\s+|\\s+$', '') = '...', '',
                           replaceRegexpAll(replaceRegexpOne(arrayElement(splitByString(' > ...',
                               replaceRegexpAll(ifNull(s3.structure_row_path, ''), '^\\s+|\\s+$', '')), 1), '[ >]+$', ''), '^\\s+|\\s+$', '')),
                        ' > ...', '|', ifNull(s3.column_path, 'None')))))           AS id,
                    if(replaceRegexpAll(ifNull(s3.structure_row_path, ''), '^\\s+|\\s+$', '') = '...', '',
                       replaceRegexpAll(replaceRegexpOne(arrayElement(splitByString(' > ...',
                           replaceRegexpAll(ifNull(s3.structure_row_path, ''), '^\\s+|\\s+$', '')), 1), '[ >]+$', ''), '^\\s+|\\s+$', '')) AS erp,
                    toUInt8(1)                                                      AS isd,
                    ifNull(s3.rpt_code, '')                                         AS rcode,
                    ifNull(s3.rpt_nm, '')                                           AS rn,
                    ifNull(s3.sheet_nm, '')                                         AS sn,
                    ifNull(s3.column_path, '')                                      AS cp,
                    ifNull(s3.column_index, 0)                                      AS colidx,
                    toNullable(toInt64(s3.row_index))                               AS rowidx,
                    toUInt8(0)                                                      AS declared,
                    toUInt8(3)                                                      AS prio,
                    s3.dr_structure_code                                            AS ikm
                FROM datamart.dynamic_report_structure_dim s3
                WHERE s3.ds_rcrd_st = 'ACTIVE'
                    AND (position(ifNull(s3.structure_row_path, ''), ' > ...') > 0
                         OR replaceRegexpAll(ifNull(s3.structure_row_path, ''), '^\\s+|\\s+$', '') = '...')
            )
            ORDER BY prio, ikm
            LIMIT 1 BY id
        )
    )
    WHERE NOT (isd = 0 AND erp = '' AND dyn_col = 1)
) x
LEFT JOIN
(
    -- chỉ tiêu có ít nhất một giá trị CHỮ có nội dung (không ép được sang số) thì là chỉ tiêu chữ
    SELECT DISTINCT vf.indicator_id AS ne_id
    FROM datamart.qlq_opr_dynamic_report_explorer_val_flat vf
    WHERE lowerUTF8(replaceRegexpAll(vf.indicator_val, '^\\s+|\\s+$', '')) NOT IN ('', '0', '-', '—', '...', 'x', 'n/a', 'none', 'nan')
        AND NOT match(replaceRegexpAll(vf.indicator_val, '^\\s+|\\s+$', ''),
                      '(?i)^[+-]?((\\d+\\.?\\d*|\\.\\d+)(e[+-]?\\d+)?|inf|infinity)$')
) ne
    ON ne.ne_id = x.id
LEFT JOIN
(
    -- loại đối tượng đã từng nộp từng báo cáo, dạng |Loại 1|Loại 2| (toàn bộ lịch sử nộp)
    SELECT
        h2.submission_rpt_code AS ot_rc,
        concat('|', arrayStringConcat(arraySort(groupUniqArray(replaceRegexpAll(h2.object_tp, '^\\s+|\\s+$', ''))), '|'), '|') AS ot_lst
    FROM datamart.dynamic_report_submission_history_dim h2
    WHERE h2.ds_rcrd_st = 'ACTIVE'
        AND ifNull(h2.submission_rpt_code, '') != ''
        AND replaceRegexpAll(ifNull(h2.object_tp, ''), '^\\s+|\\s+$', '') != ''
    GROUP BY h2.submission_rpt_code
) ot
    ON ot.ot_rc = x.rcode
LEFT JOIN
(
    -- loại quỹ đã từng nộp từng báo cáo (chỉ đối tượng Quỹ đầu tư)
    SELECT
        h3.submission_rpt_code AS ft_rc,
        concat('|', arrayStringConcat(arraySort(groupUniqArray(replaceRegexpAll(h3.object_sub_tp, '^\\s+|\\s+$', ''))), '|'), '|') AS ft_lst
    FROM datamart.dynamic_report_submission_history_dim h3
    WHERE h3.ds_rcrd_st = 'ACTIVE'
        AND h3.object_tp = 'Quỹ đầu tư'
        AND ifNull(h3.submission_rpt_code, '') != ''
        AND replaceRegexpAll(ifNull(h3.object_sub_tp, ''), '^\\s+|\\s+$', '') != ''
    GROUP BY h3.submission_rpt_code
) ft
    ON ft.ft_rc = x.rcode
;


-- ==========================================================
-- 22. OPERATIONAL: qlq_opr_foreign_fund_management_representative_office_profile_flat
-- ==========================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_foreign_fund_management_representative_office_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_foreign_fund_management_representative_office_profile_flat
SELECT
    -- From: OPR_FOREIGN_FUND_MANAGEMENT_REPRESENTATIVE_OFFICE_PROFILE
    f.foreign_fund_management_organization_unit_code,
    f.foreign_fund_management_organization_unit_full_nm,
    f.operation_status_nm,
    f.license_nbr,
    f.license_dt,
    f.address,
    f.tax_id_nbr,
    f.src_stm_code,
    f.ds_rcrd_st,
    f.ds_rcrd_isrt_dt,
    f.ds_rcrd_udt_dt,
    f.ds_etl_pcs_tms

FROM datamart.opr_foreign_fund_management_representative_office_profile f
;


-- ==========================================================
-- 23. OPERATIONAL: qlq_opr_fund_management_company_contract_asset_list_flat
-- ==========================================================
TRUNCATE TABLE IF EXISTS datamart.qlq_opr_fund_management_company_contract_asset_list_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlq_opr_fund_management_company_contract_asset_list_flat
SELECT
    -- From: OPR_FUND_MANAGEMENT_COMPANY_CONTRACT_ASSET_LIST
    f.fmr_submission_code,
    f.table_idx,
    f.asset_indicator_code,
    f.investment_fund_code,
    f.fmc_code,
    f.record_tp,
    f.period_tp_code,
    f.period_val,
    f.rpt_year,
    f.version_nbr,
    f.asset_market_val_amt,
    f.src_stm_code,
    f.ds_rcrd_st,
    f.ds_rcrd_isrt_dt,
    f.ds_rcrd_udt_dt,
    f.ds_etl_pcs_tms,
    f.fmc_id

FROM datamart.opr_fund_management_company_contract_asset_list f
;
