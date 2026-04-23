/*
*--------------------------------------------------------------------*
* Program code: involved_party_electronic_address
* Program name: Involved Party Electronic Address
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH leg_th_ti_dk_th AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email_kd AS address_value,
        source_system_code
    FROM bronze.THONG_TIN_DK_THUE
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email_kd IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax_kd AS address_value,
        source_system_code
    FROM bronze.THONG_TIN_DK_THUE
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax_kd IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.THONG_TIN_DK_THUE
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        dien_thoai_kd AS address_value,
        source_system_code
    FROM bronze.THONG_TIN_DK_THUE
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND dien_thoai_kd IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        dien_thoai AS address_value,
        source_system_code
    FROM bronze.THONG_TIN_DK_THUE
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND dien_thoai IS NOT NULL
),

leg_tt_ng_da_di AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.TTKDT_NGUOI_DAI_DIEN
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.TTKDT_NGUOI_DAI_DIEN
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        dien_thoai AS address_value,
        source_system_code
    FROM bronze.TTKDT_NGUOI_DAI_DIEN
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND dien_thoai IS NOT NULL
)

SELECT
    hash_id(leg_th_ti_dk_th.source_system_code, leg_th_ti_dk_th.ip_code) AS involved_party_id,
    leg_th_ti_dk_th.ip_code :: string                                    AS involved_party_code,
    leg_th_ti_dk_th.source_system_code :: string                         AS source_system_code,
    leg_th_ti_dk_th.type_code :: string                                  AS electronic_address_type_code,
    leg_th_ti_dk_th.address_value :: string                              AS electronic_address_value
FROM leg_th_ti_dk_th
UNION ALL
SELECT
    hash_id(leg_tt_ng_da_di.source_system_code, leg_tt_ng_da_di.ip_code) AS involved_party_id,
    leg_tt_ng_da_di.ip_code :: string                                    AS involved_party_code,
    leg_tt_ng_da_di.source_system_code :: string                         AS source_system_code,
    leg_tt_ng_da_di.type_code :: string                                  AS electronic_address_type_code,
    leg_tt_ng_da_di.address_value :: string                              AS electronic_address_value
FROM leg_tt_ng_da_di
;
