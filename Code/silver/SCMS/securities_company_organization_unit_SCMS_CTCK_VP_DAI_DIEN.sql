/*
*--------------------------------------------------------------------*
* Program code: securities_company_organization_unit_SCMS_CTCK_VP_DAI_DIEN
* Program name: Securities Company Organization Unit SCMS CTCK VP DAI DIEN
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ct_vp_da_di AS (
    SELECT id, ctck_thong_tin_id, ten_day_du, so_quyet_dinh, ngay_quyet_dinh, ngay_hs_hop_le, trang_thai_vpdd, ghi_chu, is_bang_tam, ngay_tao, ngay_cap_nhat, trang_thai, ctck_chi_nhanh_id, nguoi_dai_dien
    FROM bronze.CTCK_VP_DAI_DIEN
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('SCMS_CTCK_VP_DAI_DIEN', ct_vp_da_di.id)                 AS securities_company_organization_unit_id,
    ct_vp_da_di.id :: string                                         AS securities_company_organization_unit_code,
    'SCMS_CTCK_VP_DAI_DIEN' :: string                                AS source_system_code,
    NULL :: string                                                   AS organization_unit_type_code,
    hash_id('FIMS_SECURITIESCOMPANY', ct_vp_da_di.ctck_thong_tin_id) AS securities_company_id,
    ct_vp_da_di.ctck_thong_tin_id :: string                          AS securities_company_code,
    ct_vp_da_di.ten_day_du :: string                                 AS organization_unit_name,
    ct_vp_da_di.so_quyet_dinh :: string                              AS decision_number,
    ct_vp_da_di.ngay_quyet_dinh :: date                              AS decision_date,
    ct_vp_da_di.ngay_hs_hop_le :: date                               AS valid_document_date,
    NULL :: string                                                   AS director_name,
    NULL :: string                                                   AS business_sector_name,
    ct_vp_da_di.trang_thai_vpdd :: string                            AS organization_unit_status_code,
    ct_vp_da_di.ghi_chu :: string                                    AS note,
    ct_vp_da_di.is_bang_tam :: string                                AS is_draft_indicator,
    ct_vp_da_di.ngay_tao :: timestamp                                AS created_timestamp,
    ct_vp_da_di.ngay_cap_nhat :: timestamp                           AS updated_timestamp,
    ct_vp_da_di.trang_thai :: string                                 AS life_cycle_status_code,
    hash_id('SCMS_CTCK_CHI_NHANH', ct_vp_da_di.ctck_chi_nhanh_id)    AS parent_organization_unit_id,
    ct_vp_da_di.ctck_chi_nhanh_id :: string                          AS parent_organization_unit_code,
    ct_vp_da_di.nguoi_dai_dien :: string                             AS representative_name
;
