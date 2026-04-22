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

WITH leg_se AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.SECURITIES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.SECURITIES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        telephone AS address_value,
        source_system_code
    FROM bronze.SECURITIES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND telephone IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'WEBSITE' AS type_code,
        website AS address_value,
        source_system_code
    FROM bronze.SECURITIES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND website IS NOT NULL
),

leg_fo_ch AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.FORBRCH
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.FORBRCH
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
),

leg_ba_mo AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.BANKMONI
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        telephone AS address_value,
        source_system_code
    FROM bronze.BANKMONI
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND telephone IS NOT NULL
),

leg_br AS (
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.BRANCHES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        telephone AS address_value,
        source_system_code
    FROM bronze.BRANCHES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND telephone IS NOT NULL
)

SELECT
    hash_id(leg_se.source_system_code, leg_se.ip_code) AS involved_party_id,
    leg_se.ip_code :: string                           AS involved_party_code,
    leg_se.source_system_code :: string                AS source_system_code,
    leg_se.type_code :: string                         AS electronic_address_type_code,
    leg_se.address_value :: string                     AS electronic_address_value
FROM leg_se
UNION ALL
SELECT
    hash_id(leg_fo_ch.source_system_code, leg_fo_ch.ip_code) AS involved_party_id,
    leg_fo_ch.ip_code :: string                              AS involved_party_code,
    leg_fo_ch.source_system_code :: string                   AS source_system_code,
    leg_fo_ch.type_code :: string                            AS electronic_address_type_code,
    leg_fo_ch.address_value :: string                        AS electronic_address_value
FROM leg_fo_ch
UNION ALL
SELECT
    hash_id(leg_ba_mo.source_system_code, leg_ba_mo.ip_code) AS involved_party_id,
    leg_ba_mo.ip_code :: string                              AS involved_party_code,
    leg_ba_mo.source_system_code :: string                   AS source_system_code,
    leg_ba_mo.type_code :: string                            AS electronic_address_type_code,
    leg_ba_mo.address_value :: string                        AS electronic_address_value
FROM leg_ba_mo
UNION ALL
SELECT
    hash_id(leg_br.source_system_code, leg_br.ip_code) AS involved_party_id,
    leg_br.ip_code :: string                           AS involved_party_code,
    leg_br.source_system_code :: string                AS source_system_code,
    leg_br.type_code :: string                         AS electronic_address_type_code,
    leg_br.address_value :: string                     AS electronic_address_value
FROM leg_br
;
