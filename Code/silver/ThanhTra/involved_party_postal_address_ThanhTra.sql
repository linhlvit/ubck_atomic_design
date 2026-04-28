/*
*--------------------------------------------------------------------*
* Program code: involved_party_postal_address_ThanhTra
* Program name: Involved Party Postal Address ThanhTra
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH leg_dm_ca_bo AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.DM_CAN_BO
    LATERAL VIEW stack(1,
        'ADDRESS', dia_chi
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_dm_co_ty_dc AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.DM_CONG_TY_DC
    LATERAL VIEW stack(1,
        'ADDRESS', dia_chi
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_dm_co_ty_ck AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.DM_CONG_TY_CK
    LATERAL VIEW stack(1,
        'ADDRESS', dia_chi
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_dm_co_ty_ql AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.DM_CONG_TY_QLQ
    LATERAL VIEW stack(1,
        'ADDRESS', dia_chi
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_dm_do_tu_kh AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.DM_DOI_TUONG_KHAC
    LATERAL VIEW stack(1,
        'ADDRESS', dia_chi
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
)

SELECT
    hash_id('ThanhTra_DM_CAN_BO', leg_dm_ca_bo.ip_code) AS involved_party_id,
    leg_dm_ca_bo.ip_code :: string                      AS involved_party_code,
    'ThanhTra_DM_CAN_BO' :: string                      AS source_system_code,
    leg_dm_ca_bo.type_code :: string                    AS address_type_code,
    leg_dm_ca_bo.address_value :: string                AS address_value
FROM leg_dm_ca_bo
UNION ALL
SELECT
    hash_id('ThanhTra_DM_CONG_TY_DC', leg_dm_co_ty_dc.ip_code) AS involved_party_id,
    leg_dm_co_ty_dc.ip_code :: string                          AS involved_party_code,
    'ThanhTra_DM_CONG_TY_DC' :: string                         AS source_system_code,
    leg_dm_co_ty_dc.type_code :: string                        AS address_type_code,
    leg_dm_co_ty_dc.address_value :: string                    AS address_value
FROM leg_dm_co_ty_dc
UNION ALL
SELECT
    hash_id('ThanhTra_DM_CONG_TY_CK', leg_dm_co_ty_ck.ip_code) AS involved_party_id,
    leg_dm_co_ty_ck.ip_code :: string                          AS involved_party_code,
    'ThanhTra_DM_CONG_TY_CK' :: string                         AS source_system_code,
    leg_dm_co_ty_ck.type_code :: string                        AS address_type_code,
    leg_dm_co_ty_ck.address_value :: string                    AS address_value
FROM leg_dm_co_ty_ck
UNION ALL
SELECT
    hash_id('ThanhTra_DM_CONG_TY_QLQ', leg_dm_co_ty_ql.ip_code) AS involved_party_id,
    leg_dm_co_ty_ql.ip_code :: string                           AS involved_party_code,
    'ThanhTra_DM_CONG_TY_QLQ' :: string                         AS source_system_code,
    leg_dm_co_ty_ql.type_code :: string                         AS address_type_code,
    leg_dm_co_ty_ql.address_value :: string                     AS address_value
FROM leg_dm_co_ty_ql
UNION ALL
SELECT
    hash_id('ThanhTra_DM_DOI_TUONG_KHAC', leg_dm_do_tu_kh.ip_code) AS involved_party_id,
    leg_dm_do_tu_kh.ip_code :: string                              AS involved_party_code,
    'ThanhTra_DM_DOI_TUONG_KHAC' :: string                         AS source_system_code,
    leg_dm_do_tu_kh.type_code :: string                            AS address_type_code,
    leg_dm_do_tu_kh.address_value :: string                        AS address_value
FROM leg_dm_do_tu_kh
;
