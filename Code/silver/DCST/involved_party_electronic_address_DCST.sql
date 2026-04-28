/*
*--------------------------------------------------------------------*
* Program code: involved_party_electronic_address_DCST
* Program name: Involved Party Electronic Address DCST
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH leg_th_ti_dk_th AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.THONG_TIN_DK_THUE
    LATERAL VIEW stack(5,
        'EMAIL', email_kd,
        'FAX', fax_kd,
        'FAX', fax,
        'PHONE', dien_thoai_kd,
        'PHONE', dien_thoai
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_tt_ng_da_di AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.TTKDT_NGUOI_DAI_DIEN
    LATERAL VIEW stack(3,
        'EMAIL', email,
        'FAX', fax,
        'PHONE', dien_thoai
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
)

SELECT
    hash_id('DCST_THONG_TIN_DK_THUE', leg_th_ti_dk_th.ip_code) AS involved_party_id,
    leg_th_ti_dk_th.ip_code :: string                          AS involved_party_code,
    'DCST_THONG_TIN_DK_THUE' :: string                         AS source_system_code,
    leg_th_ti_dk_th.type_code :: string                        AS electronic_address_type_code,
    leg_th_ti_dk_th.address_value :: string                    AS electronic_address_value
FROM leg_th_ti_dk_th
UNION ALL
SELECT
    hash_id('DCST_TTKDT_NGUOI_DAI_DIEN', leg_tt_ng_da_di.ip_code) AS involved_party_id,
    leg_tt_ng_da_di.ip_code :: string                             AS involved_party_code,
    'DCST_TTKDT_NGUOI_DAI_DIEN' :: string                         AS source_system_code,
    leg_tt_ng_da_di.type_code :: string                           AS electronic_address_type_code,
    leg_tt_ng_da_di.address_value :: string                       AS electronic_address_value
FROM leg_tt_ng_da_di
;
