/*
*--------------------------------------------------------------------*
* Program code: involved_party_postal_address_DCST
* Program name: Involved Party Postal Address DCST
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
    LATERAL VIEW stack(8,
        'BUSINESS', mota_diachi_kd,
        'MA TINH KD', ma_tinh_kd,
        'TEN TINH KD', ten_tinh_kd,
        'MA HUYEN KD', ma_huyen_kd,
        'TEN HUYEN KD', ten_huyen_kd,
        'MA XA KD', ma_xa_kd,
        'TEN XA', ten_xa,
        'HEAD_OFFICE', dia_chi_tsc
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
)

SELECT
    hash_id('DCST_THONG_TIN_DK_THUE', leg_th_ti_dk_th.ip_code) AS involved_party_id,
    leg_th_ti_dk_th.ip_code :: string                          AS involved_party_code,
    'DCST_THONG_TIN_DK_THUE' :: string                         AS source_system_code,
    leg_th_ti_dk_th.type_code :: string                        AS address_type_code,
    leg_th_ti_dk_th.address_value :: string                    AS address_value
FROM leg_th_ti_dk_th
;
