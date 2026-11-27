-- ============================================================
-- QLCB Flat Tables — POPULATE
-- Module: Quản lý Chào bán (QLCB)
-- Generated: Phase 3 LLD Datamart
-- 6 bảng: 4 fact (snapshot: Offering/Plan/Result/Detail) + 1 fact phẳng (fct_ap_document) + 1 operational
-- ETL daily — 4 Fact snapshot grain APPEND theo Snapshot Date (ETL full-scan toàn bộ
-- hồ sơ/đợt mỗi lần chạy để measure động — Total Collected Amount — luôn phản ánh
-- đúng trạng thái mới nhất).
-- 6 bảng KHÔNG TRUNCATE — chỉ DELETE đúng ngày :etl_date (idempotent re-run) rồi
-- INSERT lại, giữ nguyên lịch sử các ngày snapshot khác.
-- [ĐỒNG BỘ code dev 2026-11-27] Fact phẳng fct_ap_document + bảng tác nghiệp 360 Profile cũng nạp snapshot theo ngày (DELETE đúng :etl_date rồi INSERT, không TRUNCATE) — O_QLCB_28 (i), (j).
-- [ĐỒNG BỘ code dev 2026-11-27] 4 Fact snapshot nạp/xóa theo f.ds_snpst_dt = :etl_date (không JOIN Calendar ngày snapshot — snpst_dt_dim_id lấy thẳng từ Fact, cùng ngày ds_snpst_dt); ngày báo cáo cdr_dt = COALESCE(certificate_dt, official_letter_dt) từ 2 JOIN Calendar role-playing (O_QLCB_28).
-- ============================================================


-- ============================================================
-- 1. FACT: qlcb_fct_securities_offering_snpst_flat
--    Grain APPEND — DELETE đúng ngày :etl_date (không TRUNCATE) rồi INSERT
-- ============================================================
DELETE FROM datamart.qlcb_fct_securities_offering_snpst_flat ON CLUSTER 'my_cluster'
WHERE ds_snpst_dt = :etl_date;
INSERT INTO datamart.qlcb_fct_securities_offering_snpst_flat
SELECT
    f.securities_offering_code,
    f.snpst_dt_dim_id,
    f.security_tp_nm,
    f.official_letter_dt_dim_id,
    f.certificate_dt_dim_id,
    f.public_company_dim_id,
    f.total_expected_amt,
    f.total_collected_amt,
    f.ds_snpst_dt,

    cert_cal.cdr_dt                     AS certificate_dt,
    ol_cal.cdr_dt                       AS official_letter_dt,
    COALESCE(cert_cal.cdr_dt, ol_cal.cdr_dt) AS cdr_dt,

    pc.public_company_code,
    pc.equity_ticker_symbol,
    pc.public_company_nm,
    pc.equity_listing_exchange_code,
    pc.business_line_level_1_code,
    pc.ids_registration_dt,
    pc.public_company_status_code,
    COALESCE(pc.classification_business_line_nm, 'Chưa phân ngành') AS classification_business_line_nm,
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
LEFT JOIN datamart.cdr_dt_dim cert_cal
    ON cert_cal.cdr_dt_dim_id = f.certificate_dt_dim_id
LEFT JOIN datamart.cdr_dt_dim ol_cal
    ON ol_cal.cdr_dt_dim_id = f.official_letter_dt_dim_id
JOIN datamart.public_company_dim pc
    ON pc.public_company_dim_id = f.public_company_dim_id
WHERE f.ds_snpst_dt = :etl_date
;


-- ============================================================
-- 2. FACT: qlcb_fct_securities_offering_plan_snpst_flat
--    Grain APPEND — DELETE đúng ngày :etl_date (không TRUNCATE) rồi INSERT
-- ============================================================
DELETE FROM datamart.qlcb_fct_securities_offering_plan_snpst_flat ON CLUSTER 'my_cluster'
WHERE ds_snpst_dt = :etl_date;
INSERT INTO datamart.qlcb_fct_securities_offering_plan_snpst_flat
SELECT
    f.securities_offering_code,
    f.snpst_dt_dim_id,
    f.security_tp_nm,
    f.certificate_dt_dim_id,
    f.official_letter_dt_dim_id,
    f.public_company_dim_id,
    f.offering_method_dim_id,
    f.total_expected_amt_snpst,
    f.ds_snpst_dt,

    cert_cal.cdr_dt                     AS certificate_dt,
    ol_cal.cdr_dt                       AS official_letter_dt,
    COALESCE(cert_cal.cdr_dt, ol_cal.cdr_dt) AS cdr_dt,

    pc.public_company_code,
    pc.equity_ticker_symbol,
    pc.public_company_nm,
    pc.equity_listing_exchange_code,
    pc.business_line_level_1_code,
    pc.ids_registration_dt,
    pc.public_company_status_code,
    COALESCE(pc.classification_business_line_nm, 'Chưa phân ngành') AS classification_business_line_nm,
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
LEFT JOIN datamart.cdr_dt_dim cert_cal
    ON cert_cal.cdr_dt_dim_id = f.certificate_dt_dim_id
LEFT JOIN datamart.cdr_dt_dim ol_cal
    ON ol_cal.cdr_dt_dim_id = f.official_letter_dt_dim_id
JOIN datamart.public_company_dim pc
    ON pc.public_company_dim_id = f.public_company_dim_id
LEFT JOIN datamart.offering_method_dim om
    ON om.offering_method_dim_id = f.offering_method_dim_id
WHERE f.ds_snpst_dt = :etl_date
;


-- ============================================================
-- 3. FACT: qlcb_fct_securities_offering_result_snpst_flat
--    Grain APPEND — DELETE đúng ngày :etl_date (không TRUNCATE) rồi INSERT
-- ============================================================
DELETE FROM datamart.qlcb_fct_securities_offering_result_snpst_flat ON CLUSTER 'my_cluster'
WHERE ds_snpst_dt = :etl_date;
INSERT INTO datamart.qlcb_fct_securities_offering_result_snpst_flat
SELECT
    f.securities_offering_code,
    f.snpst_dt_dim_id,
    f.security_tp_nm,
    f.certificate_dt_dim_id,
    f.official_letter_dt_dim_id,
    f.public_company_dim_id,
    f.offering_method_dim_id,
    f.total_collected_amt,
    f.ds_snpst_dt,

    cert_cal.cdr_dt                     AS certificate_dt,
    ol_cal.cdr_dt                       AS official_letter_dt,
    COALESCE(cert_cal.cdr_dt, ol_cal.cdr_dt) AS cdr_dt,

    pc.public_company_code,
    pc.equity_ticker_symbol,
    pc.public_company_nm,
    pc.equity_listing_exchange_code,
    pc.business_line_level_1_code,
    pc.ids_registration_dt,
    pc.public_company_status_code,
    COALESCE(pc.classification_business_line_nm, 'Chưa phân ngành') AS classification_business_line_nm,
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
LEFT JOIN datamart.cdr_dt_dim cert_cal
    ON cert_cal.cdr_dt_dim_id = f.certificate_dt_dim_id
LEFT JOIN datamart.cdr_dt_dim ol_cal
    ON ol_cal.cdr_dt_dim_id = f.official_letter_dt_dim_id
JOIN datamart.public_company_dim pc
    ON pc.public_company_dim_id = f.public_company_dim_id
LEFT JOIN datamart.offering_method_dim om
    ON om.offering_method_dim_id = f.offering_method_dim_id
WHERE f.ds_snpst_dt = :etl_date
;


-- ============================================================
-- 4. FACT (PHẲNG): qlcb_fct_ap_document_flat
--    [SỬA 2026-10-15] Fact phẳng theo SQL dbt dtm_fct_tthc_ap_document — Fact đã chứa sẵn tên nhóm trạng thái,
--    hình thức, người nộp, mã CK, ngày gửi nên KHÔNG JOIN Dimension / Calendar Date.
--    [ĐỒNG BỘ code dev 2026-11-27] Đổi tên fct_tthc_ap_document → fct_ap_document; nạp snapshot theo ngày — DELETE đúng ngày :etl_date (không TRUNCATE)
--    rồi INSERT, giữ lịch sử các ngày khác (dev: partition ds_snpst_dt, WHERE ds_snpst_dt = etl_date) — O_QLCB_28 (j).
-- ============================================================
DELETE FROM datamart.qlcb_fct_ap_document_flat ON CLUSTER 'my_cluster'
WHERE ds_snpst_dt = :etl_date;
INSERT INTO datamart.qlcb_fct_ap_document_flat
SELECT
    f.ap_document_code,
    f.ap_document_applicant_nm,
    f.securities_code,
    f.offering_method_nm,
    f.submission_dt,
    f.document_status_group_nm,
    f.ds_snpst_dt
FROM datamart.fct_ap_document f
WHERE f.ds_snpst_dt = :etl_date
;


-- ============================================================
-- 5. OPERATIONAL: qlcb_opr_securities_offering_360_profile_flat
--    [ĐỒNG BỘ code dev 2026-11-27] Bản sao 1-1 bảng tác nghiệp (offering_method_nm đã có sẵn trên bảng nên bỏ LEFT JOIN cl_value cũ);
--    nạp snapshot theo ngày — DELETE đúng ngày :etl_date (không TRUNCATE) rồi INSERT — O_QLCB_28 (i)
-- ============================================================
DELETE FROM datamart.qlcb_opr_securities_offering_360_profile_flat ON CLUSTER 'my_cluster'
WHERE ds_snpst_dt = :etl_date;
INSERT INTO datamart.qlcb_opr_securities_offering_360_profile_flat
SELECT
    o.securities_offering_code,
    o.offering_method_code,
    o.offering_method_nm,
    o.public_company_code,
    o.public_company_nm,
    o.equity_ticker_symbol,
    o.securities_tp_code,
    o.securities_tp_nm,
    o.total_registered_quantity,
    o.total_expected_amt,
    o.certificate_nbr,
    o.certificate_dt,
    o.official_letter_nbr,
    o.official_letter_dt,
    o.offering_purpose,
    o.consulting_organization_nm,
    o.audit_organization_nm,
    o.underwriting_organization_nm,
    o.credit_rating_organization_nm,
    o.processor_user_nm_snpst,
    o.business_line_level_1_code,
    o.classification_business_line_nm,
    o.equity_listing_exchange_code,
    o.total_successful_quantity,
    o.total_collected_amt,
    o.offering_price,
    o.employee_quantity,
    o.actual_offering_price,
    o.employee_quantity_result,
    o.capital_src,
    o.result_report_dt,
    o.offering_end_date,
    o.foreign_collected_amt,
    o.licensed_object,
    o.outcome_object,
    o.submission_dt,
    o.cdr_dt,
    o.src_stm_code,
    o.ds_snpst_dt
FROM datamart.opr_securities_offering_360_profile o
WHERE o.ds_snpst_dt = :etl_date
;


-- ==========================================================
-- 6. FACT: qlcb_fct_securities_offering_detail_snpst_flat
--    [ĐỒNG BỘ code dev 2026-11-27] Grain APPEND — DELETE đúng ngày :etl_date (không TRUNCATE) rồi INSERT; bản sao 1-1 Fact, không JOIN
-- ==========================================================
DELETE FROM datamart.qlcb_fct_securities_offering_detail_snpst_flat ON CLUSTER 'my_cluster'
WHERE ds_snpst_dt = :etl_date;
INSERT INTO datamart.qlcb_fct_securities_offering_detail_snpst_flat
SELECT
    -- From: FCT_SECURITIES_OFFERING_DETAIL_SNPST
    f.securities_offering_detail_snpst_id,
    f.securities_offering_code,
    f.snpst_dt_dim_id,
    f.public_company_nm,
    f.classification_business_line_nm,
    f.equity_ticker_symbol,
    f.securities_tp_code,
    f.securities_tp_nm,
    f.certificate_dt,
    f.official_letter_dt,
    f.cdr_dt,
    f.offering_method_nm,
    f.consulting_organization_nm,
    f.audit_organization_nm,
    f.underwriting_organization_nm,
    f.credit_rating_organization_nm,
    f.total_registered_quantity,
    f.total_successful_quantity,
    f.total_collected_amt,
    f.total_expected_amt,
    f.successful_ratio_percentage,
    f.ds_snpst_dt
FROM datamart.fct_securities_offering_detail_snpst f
WHERE f.ds_snpst_dt = :etl_date
;
