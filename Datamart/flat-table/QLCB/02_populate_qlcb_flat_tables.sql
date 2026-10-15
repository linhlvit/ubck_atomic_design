-- ============================================================
-- QLCB Flat Tables — POPULATE
-- Module: Quản lý Chào bán (QLCB)
-- Generated: Phase 3 LLD Datamart
-- 5 bảng: 3 fact (snapshot) + 1 fact phẳng (fct_tthc_ap_document) + 1 operational
-- ETL daily — 3 Fact snapshot grain APPEND theo Snapshot Date (ETL full-scan toàn bộ
-- hồ sơ/đợt mỗi lần chạy để measure động — Total Collected Amount — luôn phản ánh
-- đúng trạng thái mới nhất).
-- 3 Fact snapshot KHÔNG TRUNCATE — chỉ DELETE đúng ngày :etl_date (idempotent re-run) rồi
-- INSERT lại, giữ nguyên lịch sử các ngày snapshot khác.
-- Fact phẳng fct_tthc_ap_document (2026-10-15) + bảng tác nghiệp: TRUNCATE + INSERT (không có ngày snapshot).
-- Certificate Date giữ nguyên vai trò Chiều/slicer (JOIN riêng, không đổi).
-- ============================================================


-- ============================================================
-- 1. FACT: qlcb_fct_securities_offering_snpst_flat
--    Grain APPEND — DELETE đúng ngày :etl_date (không TRUNCATE) rồi INSERT
-- ============================================================
DELETE FROM datamart.qlcb_fct_securities_offering_snpst_flat ON CLUSTER 'my_cluster'
WHERE snpst_cdr_dt = :etl_date;
INSERT INTO datamart.qlcb_fct_securities_offering_snpst_flat
SELECT
    f.securities_offering_code,
    f.snpst_dt_dim_id,
    f.certificate_dt_dim_id,
    f.public_company_dim_id,
    f.total_expected_amt,
    f.total_collected_amt,
    f.official_letter_dt,

    snpst_cal.cdr_dt                    AS snpst_cdr_dt,

    cal.cdr_dt                          AS cdr_dt,

    pc.public_company_code,
    pc.equity_ticker_symbol,
    pc.public_company_nm,
    pc.equity_listing_exchange_code,
    pc.business_line_level_1_code,
    pc.ids_registration_dt,
    pc.public_company_status_code,
    pc.classification_business_line_nm     AS classification_business_line_nm,
    pc.public_company_english_nm           AS public_company_english_nm,
    pc.enterprise_tp_code                  AS enterprise_tp_code,
    pc.public_company_tp_code              AS public_company_tp_code,
    pc.head_office_province_nm             AS head_office_province_nm,
    pc.operating_status_code               AS operating_status_code,
    pc.has_state_ownership_indicator       AS has_state_ownership_indicator,
    pc.charter_capital_amt                 AS charter_capital_amt,
    pc.first_registration_dt               AS first_registration_dt,
    pc.latest_registration_dt              AS latest_registration_dt,
    pc.latest_registration_province_nm     AS latest_registration_province_nm,
    pc.ids_registration_indicator          AS ids_registration_indicator,
    pc.public_company_form_code            AS public_company_form_code,
    pc.former_state_owned_indicator        AS former_state_owned_indicator,
    pc.foreign_direct_investment_indicator AS foreign_direct_investment_indicator,
    pc.has_parent_company_indicator        AS has_parent_company_indicator,
    pc.has_subsidiary_indicator            AS has_subsidiary_indicator,
    pc.has_joint_venture_indicator         AS has_joint_venture_indicator,
    pc.ipo_company_indicator               AS ipo_company_indicator,
    pc.src_stm_code                        AS public_company_src_stm_code
FROM datamart.fct_securities_offering_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.certificate_dt_dim_id
LEFT JOIN datamart.public_company_dim pc
    ON pc.public_company_dim_id = f.public_company_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 2. FACT: qlcb_fct_securities_offering_plan_snpst_flat
--    Grain APPEND — DELETE đúng ngày :etl_date (không TRUNCATE) rồi INSERT
-- ============================================================
DELETE FROM datamart.qlcb_fct_securities_offering_plan_snpst_flat ON CLUSTER 'my_cluster'
WHERE snpst_cdr_dt = :etl_date;
INSERT INTO datamart.qlcb_fct_securities_offering_plan_snpst_flat
SELECT
    f.securities_offering_code,
    f.snpst_dt_dim_id,
    f.certificate_dt_dim_id,
    f.public_company_dim_id,
    f.offering_method_dim_id,
    f.total_expected_amt_snpst,

    snpst_cal.cdr_dt                    AS snpst_cdr_dt,

    cal.cdr_dt                          AS cdr_dt,

    pc.public_company_code,
    pc.equity_ticker_symbol,
    pc.public_company_nm,
    pc.equity_listing_exchange_code,
    pc.business_line_level_1_code,
    pc.ids_registration_dt,
    pc.public_company_status_code,
    pc.classification_business_line_nm     AS classification_business_line_nm,
    pc.public_company_english_nm           AS public_company_english_nm,
    pc.enterprise_tp_code                  AS enterprise_tp_code,
    pc.public_company_tp_code              AS public_company_tp_code,
    pc.head_office_province_nm             AS head_office_province_nm,
    pc.operating_status_code               AS operating_status_code,
    pc.has_state_ownership_indicator       AS has_state_ownership_indicator,
    pc.charter_capital_amt                 AS charter_capital_amt,
    pc.first_registration_dt               AS first_registration_dt,
    pc.latest_registration_dt              AS latest_registration_dt,
    pc.latest_registration_province_nm     AS latest_registration_province_nm,
    pc.ids_registration_indicator          AS ids_registration_indicator,
    pc.public_company_form_code            AS public_company_form_code,
    pc.former_state_owned_indicator        AS former_state_owned_indicator,
    pc.foreign_direct_investment_indicator AS foreign_direct_investment_indicator,
    pc.has_parent_company_indicator        AS has_parent_company_indicator,
    pc.has_subsidiary_indicator            AS has_subsidiary_indicator,
    pc.has_joint_venture_indicator         AS has_joint_venture_indicator,
    pc.ipo_company_indicator               AS ipo_company_indicator,
    pc.src_stm_code                        AS public_company_src_stm_code,

    om.offering_method_code,
    om.offering_method_nm,
    om.offering_method_group_nm,
    om.src_stm_code                        AS offering_method_src_stm_code
FROM datamart.fct_securities_offering_plan_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.certificate_dt_dim_id
LEFT JOIN datamart.public_company_dim pc
    ON pc.public_company_dim_id = f.public_company_dim_id
LEFT JOIN datamart.offering_method_dim om
    ON om.offering_method_dim_id = f.offering_method_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 3. FACT: qlcb_fct_securities_offering_result_snpst_flat
--    Grain APPEND — DELETE đúng ngày :etl_date (không TRUNCATE) rồi INSERT
-- ============================================================
DELETE FROM datamart.qlcb_fct_securities_offering_result_snpst_flat ON CLUSTER 'my_cluster'
WHERE snpst_cdr_dt = :etl_date;
INSERT INTO datamart.qlcb_fct_securities_offering_result_snpst_flat
SELECT
    f.securities_offering_code,
    f.snpst_dt_dim_id,
    f.certificate_dt_dim_id,
    f.public_company_dim_id,
    f.offering_method_dim_id,
    f.total_collected_amt,

    snpst_cal.cdr_dt                    AS snpst_cdr_dt,

    cal.cdr_dt                          AS cdr_dt,

    pc.public_company_code,
    pc.equity_ticker_symbol,
    pc.public_company_nm,
    pc.equity_listing_exchange_code,
    pc.business_line_level_1_code,
    pc.ids_registration_dt,
    pc.public_company_status_code,
    pc.classification_business_line_nm     AS classification_business_line_nm,
    pc.public_company_english_nm           AS public_company_english_nm,
    pc.enterprise_tp_code                  AS enterprise_tp_code,
    pc.public_company_tp_code              AS public_company_tp_code,
    pc.head_office_province_nm             AS head_office_province_nm,
    pc.operating_status_code               AS operating_status_code,
    pc.has_state_ownership_indicator       AS has_state_ownership_indicator,
    pc.charter_capital_amt                 AS charter_capital_amt,
    pc.first_registration_dt               AS first_registration_dt,
    pc.latest_registration_dt              AS latest_registration_dt,
    pc.latest_registration_province_nm     AS latest_registration_province_nm,
    pc.ids_registration_indicator          AS ids_registration_indicator,
    pc.public_company_form_code            AS public_company_form_code,
    pc.former_state_owned_indicator        AS former_state_owned_indicator,
    pc.foreign_direct_investment_indicator AS foreign_direct_investment_indicator,
    pc.has_parent_company_indicator        AS has_parent_company_indicator,
    pc.has_subsidiary_indicator            AS has_subsidiary_indicator,
    pc.has_joint_venture_indicator         AS has_joint_venture_indicator,
    pc.ipo_company_indicator               AS ipo_company_indicator,
    pc.src_stm_code                        AS public_company_src_stm_code,

    om.offering_method_code,
    om.offering_method_nm,
    om.offering_method_group_nm,
    om.src_stm_code                        AS offering_method_src_stm_code
FROM datamart.fct_securities_offering_result_snpst f
JOIN datamart.cdr_dt_dim snpst_cal
    ON snpst_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
JOIN datamart.cdr_dt_dim cal
    ON cal.cdr_dt_dim_id = f.certificate_dt_dim_id
LEFT JOIN datamart.public_company_dim pc
    ON pc.public_company_dim_id = f.public_company_dim_id
LEFT JOIN datamart.offering_method_dim om
    ON om.offering_method_dim_id = f.offering_method_dim_id
WHERE snpst_cal.cdr_dt = :etl_date
;


-- ============================================================
-- 4. FACT (PHẲNG): qlcb_fct_tthc_ap_document_flat
--    [SỬA 2026-10-15] Fact phẳng theo SQL dbt dtm_fct_tthc_ap_document — Fact đã chứa sẵn tên nhóm trạng thái,
--    hình thức, người nộp, mã CK, ngày gửi nên KHÔNG JOIN Dimension / Calendar Date; không có cột ngày snapshot.
--    Bảng phản ánh trạng thái hiện hành (như bảng tác nghiệp) → TRUNCATE rồi INSERT lại mỗi lần chạy
--    (giả định — O_QLCB_26: nếu cần giữ lịch sử theo ngày chạy thì phải thêm cột ngày snapshot ở Fact)
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlcb_fct_tthc_ap_document_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlcb_fct_tthc_ap_document_flat
SELECT
    f.ap_document_code,
    f.ap_document_applicant_nm,
    f.securities_code,
    f.offering_method_nm,
    f.submission_dt,
    f.document_status_group_nm
FROM datamart.fct_tthc_ap_document f
;


-- ============================================================
-- 5. OPERATIONAL: qlcb_opr_securities_offering_360_profile_flat
--    Không JOIN dim, không lọc theo ngày (bảng tác nghiệp)
-- ============================================================
TRUNCATE TABLE IF EXISTS datamart.qlcb_opr_securities_offering_360_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.qlcb_opr_securities_offering_360_profile_flat
SELECT
    o.securities_offering_code,
    o.offering_method_code,
    cl.cl_nm                            AS offering_method_nm,
    o.public_company_code,
    o.public_company_nm,
    o.equity_ticker_symbol,
    o.securities_tp_code,
    o.securities_tp_nm,
    o.total_registered_quantity,
    o.total_expected_amt,
    o.total_successful_quantity,
    o.total_collected_amt,
    o.certificate_nbr,
    o.certificate_dt,
    o.official_letter_nbr,
    o.official_letter_dt,
    o.offering_purpose,
    o.business_line_level_1_code,
    o.classification_business_line_nm,
    o.equity_listing_exchange_code,
    o.consulting_organization_nm,
    o.audit_organization_nm,
    o.underwriting_organization_nm,
    o.credit_rating_organization_nm,
    o.processor_user_nm_snpst,
    o.successful_ratio_percentage,
    o.offering_price,
    o.employee_quantity,
    o.swap_target,
    o.actual_offering_price,
    o.employee_quantity_result,
    o.capital_src,
    o.result_rpt_dt,
    o.plan_single_object,
    o.offering_end_dt,
    o.result_single_object,
    o.foreign_collected_amt,
    o.src_stm_code
FROM datamart.opr_securities_offering_360_profile o
LEFT JOIN datamart.cl_value cl
    ON cl.cl_code = o.offering_method_code AND cl.schema_code = 'SO_OFFERING_METHOD'
;
