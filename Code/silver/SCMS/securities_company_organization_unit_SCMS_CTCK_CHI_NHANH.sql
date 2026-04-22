/*
*--------------------------------------------------------------------*
* Program code: securities_company_organization_unit_SCMS_CTCK_CHI_NHANH
* Program name: Securities Company Organization Unit SCMS CTCK CHI NHANH
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ct_ch_nh AS (
    SELECT id, ctck_thong_tin_id, ten_day_du, so_quyet_dinh, ngay_quyet_dinh, ngay_hs_hop_le, giam_doc, nganh_nghe_kinh_doanh, trang_thai_chi_nhanh, ghi_chu, is_bang_tam, ngay_tao, ngay_cap_nhat, trang_thai
    FROM bronze.CTCK_CHI_NHANH
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('SCMS_CTCK_CHI_NHANH', ct_ch_nh.id)                   AS securities_company_organization_unit_id,
    ct_ch_nh.id :: string                                         AS securities_company_organization_unit_code,
    'SCMS_CTCK_CHI_NHANH' :: string                               AS source_system_code,
    NULL :: string                                                AS organization_unit_type_code,
    hash_id('FIMS_SECURITIESCOMPANY', ct_ch_nh.ctck_thong_tin_id) AS securities_company_id,
    ct_ch_nh.ctck_thong_tin_id :: string                          AS securities_company_code,
    ct_ch_nh.ten_day_du :: string                                 AS organization_unit_name,
    ct_ch_nh.so_quyet_dinh :: string                              AS decision_number,
    ct_ch_nh.ngay_quyet_dinh :: date                              AS decision_date,
    ct_ch_nh.ngay_hs_hop_le :: date                               AS valid_document_date,
    ct_ch_nh.giam_doc :: string                                   AS director_name,
    ct_ch_nh.nganh_nghe_kinh_doanh :: string                      AS business_sector_name,
    ct_ch_nh.trang_thai_chi_nhanh :: string                       AS organization_unit_status_code,
    ct_ch_nh.ghi_chu :: string                                    AS note,
    ct_ch_nh.is_bang_tam :: string                                AS is_draft_indicator,
    ct_ch_nh.ngay_tao :: timestamp                                AS created_timestamp,
    ct_ch_nh.ngay_cap_nhat :: timestamp                           AS updated_timestamp,
    ct_ch_nh.trang_thai :: string                                 AS life_cycle_status_code,
    NULL :: string                                                AS parent_organization_unit_id,
    NULL :: string                                                AS parent_organization_unit_code,
    NULL :: string                                                AS representative_name
;
