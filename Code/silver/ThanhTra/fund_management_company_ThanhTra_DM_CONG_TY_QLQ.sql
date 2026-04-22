/*
*--------------------------------------------------------------------*
* Program code: fund_management_company_ThanhTra_DM_CONG_TY_QLQ
* Program name: Fund Management Company ThanhTra DM CONG TY QLQ
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH dm_co_ty_ql AS (
    SELECT id, ten_tieng_viet, ten_viet_tat, ten_tieng_anh, von_dieu_le, trang_thai_hoat_dong, loai_hinh_cong_ty, loai_quy, giay_phep_kinh_doanh, website
    FROM bronze.DM_CONG_TY_QLQ
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('ThanhTra_DM_CONG_TY_QLQ', dm_co_ty_ql.id) AS fund_management_company_id,
    dm_co_ty_ql.id :: string                           AS fund_management_company_code,
    'ThanhTra_DM_CONG_TY_QLQ' :: string                AS source_system_code,
    dm_co_ty_ql.ten_tieng_viet :: string               AS fund_management_company_name,
    dm_co_ty_ql.ten_viet_tat :: string                 AS fund_management_company_short_name,
    dm_co_ty_ql.ten_tieng_anh :: string                AS fund_management_company_english_name,
    NULL :: string                                     AS practice_status_code,
    dm_co_ty_ql.von_dieu_le :: decimal(23,2)           AS charter_capital_amount,
    NULL :: string                                     AS dorf_indicator,
    NULL :: string                                     AS license_decision_number,
    NULL :: date                                       AS license_decision_date,
    NULL :: date                                       AS active_date,
    NULL :: date                                       AS stop_date,
    NULL :: string                                     AS business_type_codes,
    NULL :: string                                     AS created_by,
    NULL :: timestamp                                  AS created_timestamp,
    NULL :: timestamp                                  AS updated_timestamp,
    NULL :: string                                     AS country_of_registration_id,
    NULL :: string                                     AS country_of_registration_code,
    dm_co_ty_ql.trang_thai_hoat_dong :: string         AS life_cycle_status_code,
    NULL :: string                                     AS director_name,
    NULL :: string                                     AS depository_certificate_number,
    NULL :: string                                     AS company_type_codes,
    NULL :: string                                     AS description,
    dm_co_ty_ql.loai_hinh_cong_ty :: string            AS company_type_code,
    dm_co_ty_ql.loai_quy :: string                     AS fund_type_code,
    dm_co_ty_ql.giay_phep_kinh_doanh :: string         AS business_license_number,
    dm_co_ty_ql.website :: string                      AS website
;
