/*
*--------------------------------------------------------------------*
* Program code: involved_party_electronic_address_FIMS
* Program name: Involved Party Electronic Address FIMS
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH leg_ba_mo AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.BANKMONI
    LATERAL VIEW stack(4,
        'EMAIL', email,
        'FAX', fax,
        'PHONE', telephone,
        'WEBSITE', website
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_br AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.BRANCHS
    LATERAL VIEW stack(4,
        'EMAIL', email,
        'FAX', fax,
        'PHONE', telephone,
        'WEBSITE', website
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_de_ce AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.DEPOSITORYCENTER
    LATERAL VIEW stack(5,
        'EMAIL', email,
        'FAX', fax,
        'HOTLINE', hotline,
        'PHONE', telephone,
        'WEBSITE', website
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_fu_co AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.FUNDCOMPANY
    LATERAL VIEW stack(4,
        'EMAIL', email,
        'FAX', fax,
        'PHONE', telephone,
        'WEBSITE', website
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_in_di_re AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.INFODISCREPRES
    LATERAL VIEW stack(4,
        'EMAIL', email,
        'FAX', fax,
        'PHONE', telephone,
        'WEBSITE', website
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_in AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.INVESTOR
    LATERAL VIEW stack(4,
        'EMAIL', email,
        'FAX', fax,
        'PHONE', telephone,
        'WEBSITE', website
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_se_co AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.SECURITIESCOMPANY
    LATERAL VIEW stack(4,
        'EMAIL', email,
        'FAX', fax,
        'PHONE', telephone,
        'WEBSITE', website
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_st_ex AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.STOCKEXCHANGE
    LATERAL VIEW stack(5,
        'EMAIL', email,
        'FAX', fax,
        'HOTLINE', hotline,
        'PHONE', telephone,
        'WEBSITE', website
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_tl AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.TLPROFILES
    LATERAL VIEW stack(2,
        'EMAIL', email,
        'PHONE', telephone
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
)

SELECT
    hash_id('FIMS_BANKMONI', leg_ba_mo.ip_code) AS involved_party_id,
    leg_ba_mo.ip_code :: string                 AS involved_party_code,
    'FIMS_BANKMONI' :: string                   AS source_system_code,
    leg_ba_mo.type_code :: string               AS electronic_address_type_code,
    leg_ba_mo.address_value :: string           AS electronic_address_value
FROM leg_ba_mo
UNION ALL
SELECT
    hash_id('FIMS_BRANCHS', leg_br.ip_code) AS involved_party_id,
    leg_br.ip_code :: string                AS involved_party_code,
    'FIMS_BRANCHS' :: string                AS source_system_code,
    leg_br.type_code :: string              AS electronic_address_type_code,
    leg_br.address_value :: string          AS electronic_address_value
FROM leg_br
UNION ALL
SELECT
    hash_id('FIMS_DEPOSITORYCENTER', leg_de_ce.ip_code) AS involved_party_id,
    leg_de_ce.ip_code :: string                         AS involved_party_code,
    'FIMS_DEPOSITORYCENTER' :: string                   AS source_system_code,
    leg_de_ce.type_code :: string                       AS electronic_address_type_code,
    leg_de_ce.address_value :: string                   AS electronic_address_value
FROM leg_de_ce
UNION ALL
SELECT
    hash_id('FIMS_FUNDCOMPANY', leg_fu_co.ip_code) AS involved_party_id,
    leg_fu_co.ip_code :: string                    AS involved_party_code,
    'FIMS_FUNDCOMPANY' :: string                   AS source_system_code,
    leg_fu_co.type_code :: string                  AS electronic_address_type_code,
    leg_fu_co.address_value :: string              AS electronic_address_value
FROM leg_fu_co
UNION ALL
SELECT
    hash_id('FIMS_INFODISCREPRES', leg_in_di_re.ip_code) AS involved_party_id,
    leg_in_di_re.ip_code :: string                       AS involved_party_code,
    'FIMS_INFODISCREPRES' :: string                      AS source_system_code,
    leg_in_di_re.type_code :: string                     AS electronic_address_type_code,
    leg_in_di_re.address_value :: string                 AS electronic_address_value
FROM leg_in_di_re
UNION ALL
SELECT
    hash_id('FIMS_INVESTOR', leg_in.ip_code) AS involved_party_id,
    leg_in.ip_code :: string                 AS involved_party_code,
    'FIMS_INVESTOR' :: string                AS source_system_code,
    leg_in.type_code :: string               AS electronic_address_type_code,
    leg_in.address_value :: string           AS electronic_address_value
FROM leg_in
UNION ALL
SELECT
    hash_id('FIMS_SECURITIESCOMPANY', leg_se_co.ip_code) AS involved_party_id,
    leg_se_co.ip_code :: string                          AS involved_party_code,
    'FIMS_SECURITIESCOMPANY' :: string                   AS source_system_code,
    leg_se_co.type_code :: string                        AS electronic_address_type_code,
    leg_se_co.address_value :: string                    AS electronic_address_value
FROM leg_se_co
UNION ALL
SELECT
    hash_id('FIMS_STOCKEXCHANGE', leg_st_ex.ip_code) AS involved_party_id,
    leg_st_ex.ip_code :: string                      AS involved_party_code,
    'FIMS_STOCKEXCHANGE' :: string                   AS source_system_code,
    leg_st_ex.type_code :: string                    AS electronic_address_type_code,
    leg_st_ex.address_value :: string                AS electronic_address_value
FROM leg_st_ex
UNION ALL
SELECT
    hash_id('FIMS_TLPROFILES', leg_tl.ip_code) AS involved_party_id,
    leg_tl.ip_code :: string                   AS involved_party_code,
    'FIMS_TLPROFILES' :: string                AS source_system_code,
    leg_tl.type_code :: string                 AS electronic_address_type_code,
    leg_tl.address_value :: string             AS electronic_address_value
FROM leg_tl
;
