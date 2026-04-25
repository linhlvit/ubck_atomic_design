/*
*--------------------------------------------------------------------*
* Program code: involved_party_alternative_identification_FIMS
* Program name: Involved Party Alternative Identification FIMS
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
        'IDNO', idno,
        'IDADD', idadd,
        'REGNO', regno,
        'REGADD', regadd
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_br AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.BRANCHS
    LATERAL VIEW stack(4,
        'IDNO', idno,
        'IDADD', idadd,
        'REGNO', regno,
        'REGADD', regadd
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_fu_co AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.FUNDCOMPANY
    LATERAL VIEW stack(4,
        'IDNO', idno,
        'IDADD', idadd,
        'REGNO', regno,
        'REGADD', regadd
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_se_co AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.SECURITIESCOMPANY
    LATERAL VIEW stack(4,
        'IDNO', idno,
        'IDADD', idadd,
        'REGNO', regno,
        'REGADD', regadd
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_in AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.INVESTOR
    LATERAL VIEW stack(2,
        'IDNO', idno,
        'IDADD', idadd
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_tl AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.TLPROFILES
    LATERAL VIEW stack(4,
        'IDNO', idno,
        'IDADD', idadd,
        'CERTNO', certno,
        'CERTADD', certadd
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_in_di_re AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.INFODISCREPRES
    LATERAL VIEW stack(3,
        'CERTNO', certno,
        'IDADD', idadd,
        'IDNO', idno
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
)

SELECT
    hash_id('FIMS_BANKMONI', leg_ba_mo.ip_code) AS involved_party_id,
    leg_ba_mo.ip_code :: string                 AS involved_party_code,
    'FIMS_BANKMONI' :: string                   AS source_system_code,
    leg_ba_mo.type_code :: string               AS identification_type_code,
    leg_ba_mo.address_value :: string           AS identification_number
FROM leg_ba_mo
UNION ALL
SELECT
    hash_id('FIMS_BRANCHS', leg_br.ip_code) AS involved_party_id,
    leg_br.ip_code :: string                AS involved_party_code,
    'FIMS_BRANCHS' :: string                AS source_system_code,
    leg_br.type_code :: string              AS identification_type_code,
    leg_br.address_value :: string          AS identification_number
FROM leg_br
UNION ALL
SELECT
    hash_id('FIMS_FUNDCOMPANY', leg_fu_co.ip_code) AS involved_party_id,
    leg_fu_co.ip_code :: string                    AS involved_party_code,
    'FIMS_FUNDCOMPANY' :: string                   AS source_system_code,
    leg_fu_co.type_code :: string                  AS identification_type_code,
    leg_fu_co.address_value :: string              AS identification_number
FROM leg_fu_co
UNION ALL
SELECT
    hash_id('FIMS_SECURITIESCOMPANY', leg_se_co.ip_code) AS involved_party_id,
    leg_se_co.ip_code :: string                          AS involved_party_code,
    'FIMS_SECURITIESCOMPANY' :: string                   AS source_system_code,
    leg_se_co.type_code :: string                        AS identification_type_code,
    leg_se_co.address_value :: string                    AS identification_number
FROM leg_se_co
UNION ALL
SELECT
    hash_id('FIMS_INVESTOR', leg_in.ip_code) AS involved_party_id,
    leg_in.ip_code :: string                 AS involved_party_code,
    'FIMS_INVESTOR' :: string                AS source_system_code,
    leg_in.type_code :: string               AS identification_type_code,
    leg_in.address_value :: string           AS identification_number
FROM leg_in
UNION ALL
SELECT
    hash_id('FIMS_TLPROFILES', leg_tl.ip_code) AS involved_party_id,
    leg_tl.ip_code :: string                   AS involved_party_code,
    'FIMS_TLPROFILES' :: string                AS source_system_code,
    leg_tl.type_code :: string                 AS identification_type_code,
    leg_tl.address_value :: string             AS identification_number
FROM leg_tl
UNION ALL
SELECT
    hash_id('FIMS_INFODISCREPRES', leg_in_di_re.ip_code) AS involved_party_id,
    leg_in_di_re.ip_code :: string                       AS involved_party_code,
    'FIMS_INFODISCREPRES' :: string                      AS source_system_code,
    leg_in_di_re.type_code :: string                     AS identification_type_code,
    leg_in_di_re.address_value :: string                 AS identification_number
FROM leg_in_di_re
;
