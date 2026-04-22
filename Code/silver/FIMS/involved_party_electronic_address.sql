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

WITH leg_ba_mo AS (
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
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.BANKMONI
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        telephone AS address_value,
        source_system_code
    FROM bronze.BANKMONI
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND telephone IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'WEBSITE' AS type_code,
        website AS address_value,
        source_system_code
    FROM bronze.BANKMONI
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND website IS NOT NULL
),

leg_br AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.BRANCHS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.BRANCHS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        telephone AS address_value,
        source_system_code
    FROM bronze.BRANCHS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND telephone IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'WEBSITE' AS type_code,
        website AS address_value,
        source_system_code
    FROM bronze.BRANCHS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND website IS NOT NULL
),

leg_de_ce AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.DEPOSITORYCENTER
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.DEPOSITORYCENTER
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'HOTLINE' AS type_code,
        hotline AS address_value,
        source_system_code
    FROM bronze.DEPOSITORYCENTER
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND hotline IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        telephone AS address_value,
        source_system_code
    FROM bronze.DEPOSITORYCENTER
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND telephone IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'WEBSITE' AS type_code,
        website AS address_value,
        source_system_code
    FROM bronze.DEPOSITORYCENTER
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND website IS NOT NULL
),

leg_fu_co AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.FUNDCOMPANY
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.FUNDCOMPANY
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        telephone AS address_value,
        source_system_code
    FROM bronze.FUNDCOMPANY
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND telephone IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'WEBSITE' AS type_code,
        website AS address_value,
        source_system_code
    FROM bronze.FUNDCOMPANY
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND website IS NOT NULL
),

leg_in_di_re AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.INFODISCREPRES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.INFODISCREPRES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        telephone AS address_value,
        source_system_code
    FROM bronze.INFODISCREPRES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND telephone IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'WEBSITE' AS type_code,
        website AS address_value,
        source_system_code
    FROM bronze.INFODISCREPRES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND website IS NOT NULL
),

leg_in AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.INVESTOR
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.INVESTOR
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        telephone AS address_value,
        source_system_code
    FROM bronze.INVESTOR
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND telephone IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'WEBSITE' AS type_code,
        website AS address_value,
        source_system_code
    FROM bronze.INVESTOR
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND website IS NOT NULL
),

leg_se_co AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.SECURITIESCOMPANY
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.SECURITIESCOMPANY
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        telephone AS address_value,
        source_system_code
    FROM bronze.SECURITIESCOMPANY
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND telephone IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'WEBSITE' AS type_code,
        website AS address_value,
        source_system_code
    FROM bronze.SECURITIESCOMPANY
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND website IS NOT NULL
),

leg_st_ex AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.STOCKEXCHANGE
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.STOCKEXCHANGE
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'HOTLINE' AS type_code,
        hotline AS address_value,
        source_system_code
    FROM bronze.STOCKEXCHANGE
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND hotline IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        telephone AS address_value,
        source_system_code
    FROM bronze.STOCKEXCHANGE
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND telephone IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'WEBSITE' AS type_code,
        website AS address_value,
        source_system_code
    FROM bronze.STOCKEXCHANGE
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND website IS NOT NULL
),

leg_tl AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.TLPROFILES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        telephone AS address_value,
        source_system_code
    FROM bronze.TLPROFILES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND telephone IS NOT NULL
)

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
UNION ALL
SELECT
    hash_id(leg_de_ce.source_system_code, leg_de_ce.ip_code) AS involved_party_id,
    leg_de_ce.ip_code :: string                              AS involved_party_code,
    leg_de_ce.source_system_code :: string                   AS source_system_code,
    leg_de_ce.type_code :: string                            AS electronic_address_type_code,
    leg_de_ce.address_value :: string                        AS electronic_address_value
FROM leg_de_ce
UNION ALL
SELECT
    hash_id(leg_fu_co.source_system_code, leg_fu_co.ip_code) AS involved_party_id,
    leg_fu_co.ip_code :: string                              AS involved_party_code,
    leg_fu_co.source_system_code :: string                   AS source_system_code,
    leg_fu_co.type_code :: string                            AS electronic_address_type_code,
    leg_fu_co.address_value :: string                        AS electronic_address_value
FROM leg_fu_co
UNION ALL
SELECT
    hash_id(leg_in_di_re.source_system_code, leg_in_di_re.ip_code) AS involved_party_id,
    leg_in_di_re.ip_code :: string                                 AS involved_party_code,
    leg_in_di_re.source_system_code :: string                      AS source_system_code,
    leg_in_di_re.type_code :: string                               AS electronic_address_type_code,
    leg_in_di_re.address_value :: string                           AS electronic_address_value
FROM leg_in_di_re
UNION ALL
SELECT
    hash_id(leg_in.source_system_code, leg_in.ip_code) AS involved_party_id,
    leg_in.ip_code :: string                           AS involved_party_code,
    leg_in.source_system_code :: string                AS source_system_code,
    leg_in.type_code :: string                         AS electronic_address_type_code,
    leg_in.address_value :: string                     AS electronic_address_value
FROM leg_in
UNION ALL
SELECT
    hash_id(leg_se_co.source_system_code, leg_se_co.ip_code) AS involved_party_id,
    leg_se_co.ip_code :: string                              AS involved_party_code,
    leg_se_co.source_system_code :: string                   AS source_system_code,
    leg_se_co.type_code :: string                            AS electronic_address_type_code,
    leg_se_co.address_value :: string                        AS electronic_address_value
FROM leg_se_co
UNION ALL
SELECT
    hash_id(leg_st_ex.source_system_code, leg_st_ex.ip_code) AS involved_party_id,
    leg_st_ex.ip_code :: string                              AS involved_party_code,
    leg_st_ex.source_system_code :: string                   AS source_system_code,
    leg_st_ex.type_code :: string                            AS electronic_address_type_code,
    leg_st_ex.address_value :: string                        AS electronic_address_value
FROM leg_st_ex
UNION ALL
SELECT
    hash_id(leg_tl.source_system_code, leg_tl.ip_code) AS involved_party_id,
    leg_tl.ip_code :: string                           AS involved_party_code,
    leg_tl.source_system_code :: string                AS source_system_code,
    leg_tl.type_code :: string                         AS electronic_address_type_code,
    leg_tl.address_value :: string                     AS electronic_address_value
FROM leg_tl
;
