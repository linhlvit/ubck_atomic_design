-- ============================================================
-- QLKD Flat Tables — POPULATE
-- Module: Quản lý kinh doanh (Hoạt động CTCK) — QLKD
-- Generated: Phase 3 LLD Datamart
-- 22 bảng flat: 7 fact + 14 operational + 1 dimension bộ lọc (khối 21)
-- ETL daily: fact lọc theo WHERE cal.cdr_dt = :etl_date
-- ============================================================


-- ============================================================
-- 1. FACT: qlkd_fct_securities_company_status_snpst_flat
--    Grain APPEND (Periodic Snapshot theo ngày) — DELETE đúng ngày :etl_date
--    (không TRUNCATE) rồi INSERT, giữ nguyên lịch sử các ngày snapshot khác.
-- ============================================================
DELETE FROM datamart.qlkd_fct_securities_company_status_snpst_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.qlkd_fct_securities_company_status_snpst_flat
SELECT
    -- From: FACT Fact Securities Company Status Snapshot
    f.snpst_dt_dim_id,
    f.securities_company_dim_id,
    f.license_issue_dt_dim_id,

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    cal.cdr_dt                      AS cdr_dt,

    -- From: CALENDAR DATE DIMENSION (License Issue Date)
    license_cal.cdr_dt              AS license_issue_cdr_dt,

    -- From: SECURITIES COMPANY DIMENSION
    sc_dim.sc_id                       AS sc_id,
    sc_dim.sc_code                     AS sc_code,
    sc_dim.sc_nm                       AS sc_nm,
    sc_dim.sc_short_nm                 AS sc_short_nm,
    sc_dim.company_tp_code             AS company_tp_code,
    sc_dim.company_tp_nm               AS company_tp_nm,
    sc_dim.company_status_code         AS company_status_code,
    sc_dim.company_status_nm           AS company_status_nm,
    sc_dim.is_listed_indicator         AS is_listed_indicator,
    sc_dim.stock_exchange_nm           AS stock_exchange_nm,
    sc_dim.src_stm_code                AS securities_company_src_stm_code

FROM datamart.fct_securities_company_status_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.cdr_dt_dim license_cal
    ON license_cal.cdr_dt_dim_id = f.license_issue_dt_dim_id
LEFT JOIN datamart.securities_company_dim sc_dim
    ON sc_dim.securities_company_dim_id = f.securities_company_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 2. FACT: qlkd_fct_securities_company_compliance_report_snpst_flat
--    Grain APPEND (Periodic Snapshot theo ngày sự vụ, UNION 2 nguồn ADHOC/
--    PERIODIC đã merge tại tầng Datamart Fact) — DELETE đúng ngày :etl_date
--    (không TRUNCATE) rồi INSERT, giữ nguyên lịch sử các ngày sự vụ khác.
-- ============================================================
DELETE FROM datamart.qlkd_fct_securities_company_compliance_report_snpst_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.qlkd_fct_securities_company_compliance_report_snpst_flat
SELECT
    -- From: FACT Fact Securities Company Compliance Report Snapshot
    f.snpst_dt_dim_id,
    f.securities_company_dim_id,
    f.report_tp_code,
    f.report_id,
    f.rpt_nm,
    f.rpt_submission_status_code,
    f.sent_dt,
    f.submission_deadline_dt,
    f.rpt_year,
    f.rpt_period_tp_code,
    f.period_nbr,
    f.period_val,
    f.src_stm_code                  AS src_stm_code,
    f.created_dt,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                      AS cdr_dt,

    -- From: SECURITIES COMPANY DIMENSION
    sc_dim.sc_id                       AS sc_id,
    sc_dim.sc_code                     AS sc_code,
    sc_dim.sc_nm                       AS sc_nm,
    sc_dim.sc_short_nm                 AS sc_short_nm,
    sc_dim.company_tp_code             AS company_tp_code,
    sc_dim.company_tp_nm               AS company_tp_nm,
    sc_dim.company_status_code         AS company_status_code,
    sc_dim.company_status_nm           AS company_status_nm,
    sc_dim.is_listed_indicator         AS is_listed_indicator,
    sc_dim.stock_exchange_nm           AS stock_exchange_nm,
    sc_dim.src_stm_code                AS securities_company_src_stm_code

FROM datamart.fct_securities_company_compliance_report_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.securities_company_dim sc_dim
    ON sc_dim.securities_company_dim_id = f.securities_company_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 3. FACT: qlkd_fct_securities_company_license_condition_snpst_flat
--    Grain APPEND (Periodic Snapshot — mỗi ngày lấy bản ghi cảnh báo mới nhất
--    per CTCK) — DELETE đúng ngày :etl_date (không TRUNCATE) rồi INSERT.
-- ============================================================
DELETE FROM datamart.qlkd_fct_securities_company_license_condition_snpst_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.qlkd_fct_securities_company_license_condition_snpst_flat
SELECT
    -- From: FACT Fact Securities Company License Condition Snapshot
    f.snpst_dt_dim_id,
    f.securities_company_dim_id,
    f.indicator_code,
    f.severity_level,
    f.alert_dt,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                      AS cdr_dt,

    -- From: SECURITIES COMPANY DIMENSION
    sc_dim.sc_id                       AS sc_id,
    sc_dim.sc_code                     AS sc_code,
    sc_dim.sc_nm                       AS sc_nm,
    sc_dim.sc_short_nm                 AS sc_short_nm,
    sc_dim.company_tp_code             AS company_tp_code,
    sc_dim.company_tp_nm               AS company_tp_nm,
    sc_dim.company_status_code         AS company_status_code,
    sc_dim.company_status_nm           AS company_status_nm,
    sc_dim.is_listed_indicator         AS is_listed_indicator,
    sc_dim.stock_exchange_nm           AS stock_exchange_nm,
    sc_dim.src_stm_code                AS securities_company_src_stm_code

FROM datamart.fct_securities_company_license_condition_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.securities_company_dim sc_dim
    ON sc_dim.securities_company_dim_id = f.securities_company_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 4. FACT: qlkd_fct_securities_company_capital_raising_event_flat
--    Grain Event theo THÁNG: cdr_dt = ngày đầu tháng của tháng chào bán/phát hành (FK event_dt_dim_id = TRUNC(document_dt, 'MM')).
--    [SỬA 2026-10-16 — rà cột ngày] Fact chỉ tính lại THÁNG HIỆN TẠI mỗi lần ETL (LLD: TRUNC(document_dt, 'MM') = TRUNC(ngày ETL, 'MM')),
--    nên flat DELETE + INSERT đúng ngày đầu tháng của ngày ETL (toStartOfMonth). Trước đây so cdr_dt với ngày ETL nguyên ngày → chỉ khớp khi
--    ETL chạy vào mùng 1: flat gần như rỗng, và DELETE không xóa gì nên chạy lại bị nhân đôi dòng.
-- ============================================================
DELETE FROM datamart.qlkd_fct_securities_company_capital_raising_event_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt IN (toStartOfMonth(:etl_date));
INSERT INTO datamart.qlkd_fct_securities_company_capital_raising_event_flat
SELECT
    -- From: FACT Fact Securities Company Capital Raising Event
    f.event_dt_dim_id,
    f.offering_form_dim_id,
    f.proceeds_collected_amt,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                      AS cdr_dt,

    -- From: OFFERING FORM DIMENSION
    offer_dim.capital_raising_form_code   AS capital_raising_form_code,
    offer_dim.capital_raising_form_nm     AS capital_raising_form_nm,
    offer_dim.src_stm_code                AS offering_form_src_stm_code

FROM datamart.fct_securities_company_capital_raising_event f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.event_dt_dim_id
LEFT JOIN datamart.offering_form_dim offer_dim
    ON offer_dim.offering_form_dim_id = f.offering_form_dim_id
WHERE cal.cdr_dt IN (toStartOfMonth(:etl_date))
;


-- ============================================================
-- 5. FACT: qlkd_fct_market_index_snpst_flat
--    Sửa 2026-07-24 (datamart-review): Fact nguồn `fct_market_index_snpst` nay populate
--    grain 1 chỉ số × 1 ngày (dùng chung QLKD/NDTNN, trước đây 1 chỉ số × 1 tháng).
--    QLKD (cần số liệu cuối tháng, K_QLKD_88-91) tự filter đúng ngày cuối tháng của
--    :etl_date trên Fact grain-ngày này — không còn nhận nguyên mọi ngày trong tháng.
--    cal: JOIN + WHERE cdr_dt = :etl_date
--    [Sửa 2026-10-17 — BA Update 12/10] ETL chạy mỗi ngày giao dịch (bảng flat tích lũy mọi ngày);
--    K_QLKD_88-91 chọn NGÀY GIAO DỊCH CUỐI CÙNG có dữ liệu của tháng khi truy vấn (không còn
--    giả định ETL chỉ chạy đúng ngày cuối tháng — ngày cuối tháng có thể là ngày nghỉ).
--    Sửa 2026-08-03: Grain APPEND tích lũy nhiều tháng — DELETE đúng tháng cuối của
--    :etl_date (không TRUNCATE) rồi INSERT, giữ nguyên lịch sử các ngày khác.
-- ============================================================
DELETE FROM datamart.qlkd_fct_market_index_snpst_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.qlkd_fct_market_index_snpst_flat
SELECT
    -- From: FACT Market Index Snapshot
    f.snpst_dt_dim_id,
    f.market_index_dim_id,
    f.market_index_val,
    f.open_index,
    f.high_index,
    f.low_index,
    f.prior_index,
    f.index_change,
    f.index_percent_change,
    f.advances_count,
    f.declines_count,
    f.no_change_count,
    f.ceiling_count,
    f.floor_count,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt                      AS cdr_dt,

    -- From: MARKET INDEX DIMENSION
    idx_dim.market_id               AS market_id,
    idx_dim.market_code             AS market_code,
    idx_dim.index_nm                AS index_nm,
    idx_dim.index_tp_code           AS index_tp_code,
    idx_dim.tsc_product_group_id     AS tsc_product_group_id,
    idx_dim.market_status_code      AS market_status_code,
    idx_dim.src_stm_code             AS market_index_src_stm_code

FROM datamart.fct_market_index_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.market_index_dim idx_dim
    ON idx_dim.market_index_dim_id = f.market_index_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 6. FACT: qlkd_fct_securities_company_service_assignment_snpst_flat
--    Grain APPEND (Periodic Snapshot theo ngày) — DELETE đúng ngày :etl_date
--    (không TRUNCATE) rồi INSERT, giữ nguyên lịch sử các ngày snapshot khác.
--    Fact nguồn (fct_securities_company_service_assignment_snpst) chỉ chứa
--    assignment còn hiệu lực tại ngày :etl_date (Start Date <= D AND (End Date
--    IS NULL OR End Date > D)) — filter này áp dụng khi populate bảng nguồn
--    datamart.fct_securities_company_service_assignment_snpst, không lặp lại ở đây.
-- ============================================================
DELETE FROM datamart.qlkd_fct_securities_company_service_assignment_snpst_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.qlkd_fct_securities_company_service_assignment_snpst_flat
SELECT
    -- From: FACT Fact Securities Company Service Assignment Snapshot
    f.snpst_dt_dim_id,
    f.securities_company_dim_id,
    f.securities_service_cl_dim_id,
    f.license_nbr,
    f.license_dt,
    f.start_dt,
    f.end_dt,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    cal.cdr_dt                         AS cdr_dt,

    -- From: SECURITIES COMPANY DIMENSION
    sc_dim.sc_id                       AS sc_id,
    sc_dim.sc_code                     AS sc_code,
    sc_dim.sc_nm                       AS sc_nm,
    sc_dim.sc_short_nm                 AS sc_short_nm,
    sc_dim.company_tp_code             AS company_tp_code,
    sc_dim.company_tp_nm               AS company_tp_nm,
    sc_dim.company_status_code         AS company_status_code,
    sc_dim.company_status_nm           AS company_status_nm,
    sc_dim.is_listed_indicator         AS is_listed_indicator,
    sc_dim.stock_exchange_nm           AS stock_exchange_nm,
    sc_dim.src_stm_code                AS securities_company_src_stm_code,

    -- From: SECURITIES SERVICE CLASSIFICATION DIMENSION
    svc_dim.cl_sc_firm_service_code    AS cl_sc_firm_service_code,
    svc_dim.cl_sc_firm_service_nm      AS cl_sc_firm_service_nm,
    svc_dim.description                AS description,
    svc_dim.catalog_tp                 AS catalog_tp,
    svc_dim.catalog_code               AS catalog_code,
    svc_dim.application_tp_code        AS application_tp_code,
    svc_dim.legal_capital_amt          AS legal_capital_amt,
    svc_dim.src_stm_code                AS securities_service_cl_src_stm_code

FROM datamart.fct_securities_company_service_assignment_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.securities_company_dim sc_dim
    ON sc_dim.securities_company_dim_id = f.securities_company_dim_id
LEFT JOIN datamart.securities_service_cl_dim svc_dim
    ON svc_dim.securities_service_cl_dim_id = f.securities_service_cl_dim_id
WHERE cal.cdr_dt = :etl_date
;


-- ============================================================
-- 7. OPERATIONAL: qlkd_opr_securities_company_personnel_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_securities_company_personnel_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_securities_company_personnel_profile_flat
SELECT
    -- From: OPERATIONAL Securities Company Personnel Profile
    o.sc_senior_personnel_code,
    o.sc_code,
    o.full_nm,
    o.department,
    o.position_nm,
    o.email,
    o.phone,
    o.work_start_dt,
    o.dismissal_dt,
    o.personnel_status_code,
    o.src_stm_code

FROM datamart.opr_securities_company_personnel_profile o
;


-- ============================================================
-- 8. OPERATIONAL: qlkd_opr_securities_company_organization_unit_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_securities_company_organization_unit_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_securities_company_organization_unit_profile_flat
SELECT
    -- From: OPERATIONAL Securities Company Organization Unit Profile
    o.sc_ou_code,
    o.sc_code,
    o.ou_tp_code,
    o.ou_nm,
    o.adr_val,
    o.decision_dt,
    o.director_nm,
    o.cl_firm_status_code,
    o.business_line_nm_list,
    o.src_stm_code

FROM datamart.opr_securities_company_organization_unit_profile o
;


-- ============================================================
-- 9. OPERATIONAL: qlkd_opr_securities_company_compliance_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_securities_company_compliance_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_securities_company_compliance_hist_flat
SELECT
    -- From: OPERATIONAL Securities Company Compliance History
    o.compliance_event_code,
    o.event_tp_code,
    o.form_tp_code,
    o.insp_decision_dt,
    o.decision_nbr,
    o.issued_dt,
    o.violation_behavior_nm,
    o.supplementary_penalty_nm,
    o.remedial_measure_nm,
    o.sc_code,
    o.src_stm_code,
    o.event_dt

FROM datamart.opr_securities_company_compliance_hist o
;


-- ============================================================
-- 10. OPERATIONAL: qlkd_opr_individual_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_individual_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_individual_profile_flat
SELECT
    -- From: OPERATIONAL Individual Profile
    o.sc_senior_personnel_code,
    o.sc_code,
    o.full_nm,
    o.position_nm,
    o.identification_nbr,
    o.license_certificate_nbr,
    o.src_stm_code,
    o.appointment_dt

FROM datamart.opr_individual_profile o
;


-- ============================================================
-- 11. OPERATIONAL: qlkd_opr_individual_related_party_network_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_individual_related_party_network_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_individual_related_party_network_flat
SELECT
    -- From: OPERATIONAL Individual Related Party Network
    o.sc_insider_related_person_code,
    o.sc_senior_personnel_code,
    o.related_person_full_nm,
    o.rltnp,
    o.representative_position,
    o.identification_nbr,
    o.shares_count,
    o.ownership_ratio,
    o.src_stm_code,
    o.relation_start_dt

FROM datamart.opr_individual_related_party_network o
;


-- ============================================================
-- 12. OPERATIONAL: qlkd_opr_individual_listed_company_role_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_individual_listed_company_role_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_individual_listed_company_role_flat
SELECT
    -- From: OPERATIONAL Individual Listed Company Role
    o.sc_insider_related_person_code,
    o.sc_senior_personnel_code,
    o.sc_code,
    o.representative_position,
    o.shares_count,
    o.src_stm_code

FROM datamart.opr_individual_listed_company_role o
;


-- ============================================================
-- 13. OPERATIONAL: qlkd_opr_individual_trading_account_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_individual_trading_account_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_individual_trading_account_flat
SELECT
    -- From: OPERATIONAL Individual Trading Account
    o.sc_shareholder_code,
    o.sc_code,
    o.trading_account,
    o.shareholder_nm,
    o.src_stm_code,
    o.created_dt

FROM datamart.opr_individual_trading_account o
;


-- ============================================================
-- 14. OPERATIONAL: qlkd_opr_individual_work_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_individual_work_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_individual_work_hist_flat
SELECT
    -- From: OPERATIONAL Individual Work History
    o.sc_senior_personnel_code,
    o.sc_code,
    o.position_nm,
    o.work_start_dt,
    o.resignation_dt,
    o.employment_status_code,
    o.src_stm_code

FROM datamart.opr_individual_work_hist o
;


-- ============================================================
-- 15. OPERATIONAL: qlkd_opr_individual_violation_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_individual_violation_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_individual_violation_hist_flat
SELECT
    -- From: OPERATIONAL Individual Violation History
    o.pd_subject_behavior_code,
    o.pd_code,
    o.identification_nbr,
    o.decision_nbr,
    o.issued_dt,
    o.violation_description,
    o.violation_behavior_nm,
    o.penalty_tp_nm,
    o.decision_status_code,
    o.src_stm_code

FROM datamart.opr_individual_violation_hist o
;


-- ============================================================
-- 16. FACT: qlkd_fct_securities_company_financial_structure_snpst_flat
-- ============================================================
--    Grain: 1 CTCK x 1 ô báo cáo x 1 kỳ x 1 biểu mẫu; cdr_dt = NGÀY KẾT THÚC KỲ báo cáo (end_dt), KHÔNG phải ngày ETL.
--    [SỬA 2026-10-16 — rà cột ngày] Fact ETL không giới hạn theo ngày chạy (nạp mọi kỳ, khử trùng bản nộp mới nhất; kỳ cũ có thể được nộp/nộp lại về sau)
--    nên flat TRUNCATE + INSERT toàn bộ, cùng cách các Fact báo cáo ở QLQ/PTTT. Trước đây DELETE/WHERE cdr_dt bằng ngày ETL chỉ khớp khi ngày ETL
--    trùng đúng ngày kết thúc kỳ → flat gần như rỗng.
TRUNCATE TABLE IF EXISTS datamart.qlkd_fct_securities_company_financial_structure_snpst_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_fct_securities_company_financial_structure_snpst_flat
SELECT
    -- From: FCT_SECURITIES_COMPANY_FINANCIAL_STRUCTURE_SNPST
    f.rpt_input_val_id,
    f.snpst_dt_dim_id,
    f.securities_company_dim_id,
    f.report_indicator_dim_id,
    f.rpt_year,
    f.rpt_period_tp_code,
    f.period_nbr,
    f.indicator_val_amt,
    f.rpt_code,
    f.rpt_input_submission_id,
    f.submission_dt,
    f.submission_status_code,
    f.src_stm_code,
    f.preferred_report_ind,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt AS cdr_dt,
    cal.year AS year,
    cal.quarter AS quarter,
    cal.month AS month,
    cal.day_of_week AS day_of_week,
    cal.is_weekend AS is_weekend,
    cal.holiday_flag AS holiday_flag,
    cal.is_trading_date AS is_trading_date,

    -- From: SECURITIES COMPANY DIMENSION
    sc_dim.sc_id AS sc_id,
    sc_dim.sc_code AS sc_code,
    sc_dim.sc_nm AS sc_nm,
    sc_dim.sc_short_nm AS sc_short_nm,
    sc_dim.company_tp_code AS company_tp_code,
    sc_dim.company_tp_nm   AS company_tp_nm,
    sc_dim.company_status_code AS company_status_code,
    sc_dim.company_status_nm AS company_status_nm,
    sc_dim.is_listed_indicator AS is_listed_indicator,
    sc_dim.stock_exchange_nm AS stock_exchange_nm,
    sc_dim.src_stm_code AS sc_dim_src_stm_code,

    -- From: REPORT INDICATOR DIMENSION
    ri_dim.sheet_id AS sheet_id,
    ri_dim.cell_id AS cell_id,
    ri_dim.src_stm_code AS ri_dim_src_stm_code

FROM datamart.fct_securities_company_financial_structure_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.securities_company_dim sc_dim
    ON sc_dim.securities_company_dim_id = f.securities_company_dim_id
LEFT JOIN datamart.report_indicator_dim ri_dim
    ON ri_dim.report_indicator_dim_id = f.report_indicator_dim_id
;


-- ============================================================
-- 17. OPERATIONAL: qlkd_opr_securities_company_report_data_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_securities_company_report_data_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_securities_company_report_data_flat
SELECT
    -- From: OPR_SECURITIES_COMPANY_REPORT_DATA
    f.rpt_cell_val_id,
    f.rpt_input_submission_id,
    f.sc_code,
    f.sc_nm,
    f.rpt_code,
    f.rpt_year,
    f.rpt_period,
    f.period_nbr,
    f.sheet_id,
    f.section_id,
    f.cell_id,
    f.row_nbr,
    f.item_val,
    f.submission_dt,
    f.submission_deadline_dt,
    f.submission_status_code,
    f.src_stm_code

FROM datamart.opr_securities_company_report_data f
;


-- ============================================================
-- 18. OPERATIONAL: qlkd_opr_securities_company_financial_report_hist_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_securities_company_financial_report_hist_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_securities_company_financial_report_hist_flat
SELECT
    -- From: OPR_SECURITIES_COMPANY_FINANCIAL_REPORT_HIST
    f.fin_rpt_hist_id,
    f.sc_code,
    f.sc_nm,
    f.rpt_year,
    f.rpt_period,
    f.rpt_code,
    f.period_nbr,
    f.revenue_amt,
    f.profit_after_tax_amt,
    f.roa_rate,
    f.roe_rate,
    f.submission_dt,
    f.submission_status_code,
    f.src_stm_code,
    f.preferred_report_ind

FROM datamart.opr_securities_company_financial_report_hist f
;


-- ============================================================
-- 19. OPERATIONAL: qlkd_opr_securities_company_practitioner_profile_flat
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_securities_company_practitioner_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_securities_company_practitioner_profile_flat
SELECT
    -- From: OPR_SECURITIES_COMPANY_PRACTITIONER_PROFILE
    f.prac_profile_id,
    f.sc_code,
    f.sc_nm,
    f.rpt_code,
    f.rpt_year,
    f.rpt_period_tp_code,
    f.period_nbr,
    f.total_employee_cnt,
    f.licensed_practitioner_cnt,
    f.unlicensed_practitioner_cnt,
    f.brokerage_practitioner_cnt,
    f.underwriting_practitioner_cnt,
    f.advisory_practitioner_cnt,
    f.proprietary_practitioner_cnt,
    f.deriv_brokerage_practitioner_cnt,
    f.deriv_advisory_practitioner_cnt,
    f.deriv_proprietary_practitioner_cnt,
    f.submission_dt,
    f.submission_status_code,
    f.src_stm_code

FROM datamart.opr_securities_company_practitioner_profile f
;


-- ==========================================================
-- 20. OPERATIONAL: qlkd_opr_securities_company_organization_unit_service_flat
-- ==========================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_opr_securities_company_organization_unit_service_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_opr_securities_company_organization_unit_service_flat
SELECT
    -- From: OPR_SECURITIES_COMPANY_ORGANIZATION_UNIT_SERVICE
    f.organization_unit_service_id,
    f.sc_ou_code,
    f.cl_sc_firm_service_code,
    f.sc_code,
    f.ou_tp_code,
    f.catalog_code,
    f.decision_dt,
    f.src_stm_code

FROM datamart.opr_securities_company_organization_unit_service f
;


-- ============================================================
-- 21. DIMENSION (bộ lọc): qlkd_securities_service_cl_dim_flat
--     Bảng danh mục (không có ngày snapshot) — TRUNCATE + INSERT toàn bộ từ datamart.securities_service_cl_dim, không lọc ngày.
--     Không lọc ds_rcrd_st: cùng quy ước JOIN svc_dim ở khối 6 (dimension LLD không khai báo cột audit SCD4A).
--     Thứ tự cột SELECT khớp 1-1 với CREATE TABLE ở file 01 (9 cột).
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlkd_securities_service_cl_dim_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlkd_securities_service_cl_dim_flat
SELECT
    -- From: DIMENSION Securities Service Classification Dimension
    d.securities_service_cl_dim_id,
    d.cl_sc_firm_service_code,
    d.cl_sc_firm_service_nm,
    d.description,
    d.catalog_tp,
    d.catalog_code,
    d.application_tp_code,
    d.legal_capital_amt,
    d.src_stm_code

FROM datamart.securities_service_cl_dim d
;


-- ==========================================================
-- 23. FACT: qlkd_fct_securities_company_brokerage_market_share_snpst_flat
-- ==========================================================
DELETE FROM datamart.qlkd_fct_securities_company_brokerage_market_share_snpst_flat ON CLUSTER 'my_cluster'
WHERE cdr_dt = :etl_date;
INSERT INTO datamart.qlkd_fct_securities_company_brokerage_market_share_snpst_flat
SELECT
    -- From: FCT_SECURITIES_COMPANY_BROKERAGE_MARKET_SHARE_SNPST
    f.snpst_dt_dim_id,
    f.securities_company_dim_id,
    f.report_quarter,
    f.trading_venue_nm,
    f.market_share_pct,
    f.src_stm_code,

    -- From: CALENDAR DATE DIMENSION
    cal.cdr_dt AS cdr_dt,
    cal.year AS year,
    cal.quarter AS quarter,
    cal.month AS month,
    cal.day_of_week AS day_of_week,
    cal.is_weekend AS is_weekend,
    cal.holiday_flag AS holiday_flag,
    cal.is_trading_date AS is_trading_date,

    -- From: SECURITIES COMPANY DIMENSION
    securities_c_dim.sc_id AS sc_id,
    securities_c_dim.sc_code AS sc_code,
    securities_c_dim.sc_nm AS sc_nm,
    securities_c_dim.sc_short_nm AS sc_short_nm,
    securities_c_dim.company_tp_code AS company_tp_code,
    securities_c_dim.company_tp_nm AS company_tp_nm,
    securities_c_dim.company_status_code AS company_status_code,
    securities_c_dim.company_status_nm AS company_status_nm,
    securities_c_dim.is_listed_indicator AS is_listed_indicator,
    securities_c_dim.stock_exchange_nm AS stock_exchange_nm,
    securities_c_dim.src_stm_code AS securities_c_dim_src_stm_code

FROM datamart.fct_securities_company_brokerage_market_share_snpst f
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN datamart.securities_company_dim securities_c_dim
    ON securities_c_dim.securities_company_dim_id = f.securities_company_dim_id
WHERE cal.cdr_dt = :etl_date
;
