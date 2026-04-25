/*
*--------------------------------------------------------------------*
* Program code: involved_party_alternative_identification_DCST
* Program name: Involved Party Alternative Identification DCST
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
    LATERAL VIEW stack(4,
        'SO GIAY PHEP', so_giay_phep,
        'CO QUAN CAP', co_quan_cap,
        'SO QUYET DINH', so_quyet_dinh,
        'CO QUAN BAN HANH', co_quan_ban_hanh
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_tt_ng_da_di AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.TTKDT_NGUOI_DAI_DIEN
    LATERAL VIEW stack(3,
        'SO GIAY TO', so_giay_to,
        'SO GIAY TO', so_giay_to,
        'SO GIAY TO', so_giay_to
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
)

SELECT
    hash_id('DCST_THONG_TIN_DK_THUE', leg_th_ti_dk_th.ip_code) AS involved_party_id,
    leg_th_ti_dk_th.ip_code :: string                          AS involved_party_code,
    'DCST_THONG_TIN_DK_THUE' :: string                         AS source_system_code,
    leg_th_ti_dk_th.type_code :: string                        AS identification_type_code,
    leg_th_ti_dk_th.address_value :: string                    AS identification_number
FROM leg_th_ti_dk_th
UNION ALL
SELECT
    hash_id('DCST_TTKDT_NGUOI_DAI_DIEN', leg_tt_ng_da_di.ip_code) AS involved_party_id,
    leg_tt_ng_da_di.ip_code :: string                             AS involved_party_code,
    'DCST_TTKDT_NGUOI_DAI_DIEN' :: string                         AS source_system_code,
    leg_tt_ng_da_di.type_code :: string                           AS identification_type_code,
    leg_tt_ng_da_di.address_value :: string                       AS identification_number
FROM leg_tt_ng_da_di
;
