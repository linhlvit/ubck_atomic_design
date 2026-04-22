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

WITH leg_dm_ca_bo AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.DM_CAN_BO
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        dien_thoai AS address_value,
        source_system_code
    FROM bronze.DM_CAN_BO
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND dien_thoai IS NOT NULL
),

leg_dm_co_ty_dc AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.DM_CONG_TY_DC
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        dien_thoai AS address_value,
        source_system_code
    FROM bronze.DM_CONG_TY_DC
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND dien_thoai IS NOT NULL
),

leg_dm_co_ty_ck AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.DM_CONG_TY_CK
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        dien_thoai AS address_value,
        source_system_code
    FROM bronze.DM_CONG_TY_CK
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND dien_thoai IS NOT NULL
),

leg_dm_co_ty_ql AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.DM_CONG_TY_QLQ
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        dien_thoai AS address_value,
        source_system_code
    FROM bronze.DM_CONG_TY_QLQ
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND dien_thoai IS NOT NULL
),

leg_dm_do_tu_kh AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.DM_DOI_TUONG_KHAC
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.DM_DOI_TUONG_KHAC
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'SO DIEN THOAI' AS type_code,
        so_dien_thoai AS address_value,
        source_system_code
    FROM bronze.DM_DOI_TUONG_KHAC
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND so_dien_thoai IS NOT NULL
)

SELECT
    hash_id(leg_dm_ca_bo.source_system_code, leg_dm_ca_bo.ip_code) AS involved_party_id,
    leg_dm_ca_bo.ip_code :: string                                 AS involved_party_code,
    leg_dm_ca_bo.source_system_code :: string                      AS source_system_code,
    leg_dm_ca_bo.type_code :: string                               AS electronic_address_type_code,
    leg_dm_ca_bo.address_value :: string                           AS electronic_address_value
FROM leg_dm_ca_bo
UNION ALL
SELECT
    hash_id(leg_dm_co_ty_dc.source_system_code, leg_dm_co_ty_dc.ip_code) AS involved_party_id,
    leg_dm_co_ty_dc.ip_code :: string                                    AS involved_party_code,
    leg_dm_co_ty_dc.source_system_code :: string                         AS source_system_code,
    leg_dm_co_ty_dc.type_code :: string                                  AS electronic_address_type_code,
    leg_dm_co_ty_dc.address_value :: string                              AS electronic_address_value
FROM leg_dm_co_ty_dc
UNION ALL
SELECT
    hash_id(leg_dm_co_ty_ck.source_system_code, leg_dm_co_ty_ck.ip_code) AS involved_party_id,
    leg_dm_co_ty_ck.ip_code :: string                                    AS involved_party_code,
    leg_dm_co_ty_ck.source_system_code :: string                         AS source_system_code,
    leg_dm_co_ty_ck.type_code :: string                                  AS electronic_address_type_code,
    leg_dm_co_ty_ck.address_value :: string                              AS electronic_address_value
FROM leg_dm_co_ty_ck
UNION ALL
SELECT
    hash_id(leg_dm_co_ty_ql.source_system_code, leg_dm_co_ty_ql.ip_code) AS involved_party_id,
    leg_dm_co_ty_ql.ip_code :: string                                    AS involved_party_code,
    leg_dm_co_ty_ql.source_system_code :: string                         AS source_system_code,
    leg_dm_co_ty_ql.type_code :: string                                  AS electronic_address_type_code,
    leg_dm_co_ty_ql.address_value :: string                              AS electronic_address_value
FROM leg_dm_co_ty_ql
UNION ALL
SELECT
    hash_id(leg_dm_do_tu_kh.source_system_code, leg_dm_do_tu_kh.ip_code) AS involved_party_id,
    leg_dm_do_tu_kh.ip_code :: string                                    AS involved_party_code,
    leg_dm_do_tu_kh.source_system_code :: string                         AS source_system_code,
    leg_dm_do_tu_kh.type_code :: string                                  AS electronic_address_type_code,
    leg_dm_do_tu_kh.address_value :: string                              AS electronic_address_value
FROM leg_dm_do_tu_kh
;
