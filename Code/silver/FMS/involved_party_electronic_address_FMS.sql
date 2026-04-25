/*
*--------------------------------------------------------------------*
* Program code: involved_party_electronic_address_FMS
* Program name: Involved Party Electronic Address FMS
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH leg_se AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.SECURITIES
    LATERAL VIEW stack(4,
        'EMAIL', email,
        'FAX', fax,
        'PHONE', telephone,
        'WEBSITE', website
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_fo_ch AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.FORBRCH
    LATERAL VIEW stack(2,
        'EMAIL', email,
        'FAX', fax
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ba_mo AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.BANKMONI
    LATERAL VIEW stack(2,
        'EMAIL', email,
        'PHONE', telephone
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_br AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.BRANCHES
    LATERAL VIEW stack(2,
        'FAX', fax,
        'PHONE', telephone
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
)

SELECT
    hash_id('FMS_SECURITIES', leg_se.ip_code) AS involved_party_id,
    leg_se.ip_code :: string                  AS involved_party_code,
    'FMS_SECURITIES' :: string                AS source_system_code,
    leg_se.type_code :: string                AS electronic_address_type_code,
    leg_se.address_value :: string            AS electronic_address_value
FROM leg_se
UNION ALL
SELECT
    hash_id('FMS_FORBRCH', leg_fo_ch.ip_code) AS involved_party_id,
    leg_fo_ch.ip_code :: string               AS involved_party_code,
    'FMS_FORBRCH' :: string                   AS source_system_code,
    leg_fo_ch.type_code :: string             AS electronic_address_type_code,
    leg_fo_ch.address_value :: string         AS electronic_address_value
FROM leg_fo_ch
UNION ALL
SELECT
    hash_id('FMS_BANKMONI', leg_ba_mo.ip_code) AS involved_party_id,
    leg_ba_mo.ip_code :: string                AS involved_party_code,
    'FMS_BANKMONI' :: string                   AS source_system_code,
    leg_ba_mo.type_code :: string              AS electronic_address_type_code,
    leg_ba_mo.address_value :: string          AS electronic_address_value
FROM leg_ba_mo
UNION ALL
SELECT
    hash_id('FMS_BRANCHES', leg_br.ip_code) AS involved_party_id,
    leg_br.ip_code :: string                AS involved_party_code,
    'FMS_BRANCHES' :: string                AS source_system_code,
    leg_br.type_code :: string              AS electronic_address_type_code,
    leg_br.address_value :: string          AS electronic_address_value
FROM leg_br
;
