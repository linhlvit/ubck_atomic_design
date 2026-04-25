/*
*--------------------------------------------------------------------*
* Program code: involved_party_alternative_identification_NHNCK
* Program name: Involved Party Alternative Identification NHNCK
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH leg_pro AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.PROFESSIONALS
    LATERAL VIEW stack(1,
        'IDENTITYID', identityid
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_org AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.ORGANIZATIONS
    LATERAL VIEW stack(2,
        'LICENSENUMBER', licensenumber,
        'LICENSEISSUER', licenseissuer
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
)

SELECT
    hash_id('NHNCK_Professionals', leg_pro.ip_code) AS involved_party_id,
    leg_pro.ip_code :: string                       AS involved_party_code,
    'NHNCK_Professionals' :: string                 AS source_system_code,
    leg_pro.type_code :: string                     AS identification_type_code,
    leg_pro.address_value :: string                 AS identification_number
FROM leg_pro
UNION ALL
SELECT
    hash_id('NHNCK_Organizations', leg_org.ip_code) AS involved_party_id,
    leg_org.ip_code :: string                       AS involved_party_code,
    'NHNCK_Organizations' :: string                 AS source_system_code,
    leg_org.type_code :: string                     AS identification_type_code,
    leg_org.address_value :: string                 AS identification_number
FROM leg_org
;
