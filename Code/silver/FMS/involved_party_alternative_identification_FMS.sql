/*
*--------------------------------------------------------------------*
* Program code: involved_party_alternative_identification_FMS
* Program name: Involved Party Alternative Identification FMS
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
    LATERAL VIEW stack(1,
        'DECISION', decision
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_fo_ch AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.FORBRCH
    LATERAL VIEW stack(1,
        'CHANGELICENSE', changelicense
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_in AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.INVES
    LATERAL VIEW stack(1,
        'IDNO', idno
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_tl AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.TLPROFILES
    LATERAL VIEW stack(1,
        'IDNO', idno
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_br AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.BRANCHES
    LATERAL VIEW stack(1,
        'DECISION', decision
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
)

SELECT
    hash_id('FMS_SECURITIES', leg_se.ip_code) AS involved_party_id,
    leg_se.ip_code :: string                  AS involved_party_code,
    'FMS_SECURITIES' :: string                AS source_system_code,
    leg_se.type_code :: string                AS identification_type_code,
    leg_se.address_value :: string            AS identification_number
FROM leg_se
UNION ALL
SELECT
    hash_id('FMS_FORBRCH', leg_fo_ch.ip_code) AS involved_party_id,
    leg_fo_ch.ip_code :: string               AS involved_party_code,
    'FMS_FORBRCH' :: string                   AS source_system_code,
    leg_fo_ch.type_code :: string             AS identification_type_code,
    leg_fo_ch.address_value :: string         AS identification_number
FROM leg_fo_ch
UNION ALL
SELECT
    hash_id('FMS_INVES', leg_in.ip_code) AS involved_party_id,
    leg_in.ip_code :: string             AS involved_party_code,
    'FMS_INVES' :: string                AS source_system_code,
    leg_in.type_code :: string           AS identification_type_code,
    leg_in.address_value :: string       AS identification_number
FROM leg_in
UNION ALL
SELECT
    hash_id('FMS_TLProfiles', leg_tl.ip_code) AS involved_party_id,
    leg_tl.ip_code :: string                  AS involved_party_code,
    'FMS_TLProfiles' :: string                AS source_system_code,
    leg_tl.type_code :: string                AS identification_type_code,
    leg_tl.address_value :: string            AS identification_number
FROM leg_tl
UNION ALL
SELECT
    hash_id('FMS_BRANCHES', leg_br.ip_code) AS involved_party_id,
    leg_br.ip_code :: string                AS involved_party_code,
    'FMS_BRANCHES' :: string                AS source_system_code,
    leg_br.type_code :: string              AS identification_type_code,
    leg_br.address_value :: string          AS identification_number
FROM leg_br
;
