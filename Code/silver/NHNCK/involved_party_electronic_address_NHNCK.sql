/*
*--------------------------------------------------------------------*
* Program code: involved_party_electronic_address_NHNCK
* Program name: Involved Party Electronic Address NHNCK
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH leg_org AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.ORGANIZATIONS
    LATERAL VIEW stack(4,
        'EMAIL', email,
        'FAX', fax,
        'MOBILE', mobilenumber,
        'PHONE', phonenumber
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
)

SELECT
    hash_id('NHNCK_Organizations', leg_org.ip_code) AS involved_party_id,
    leg_org.ip_code :: string                       AS involved_party_code,
    'NHNCK_Organizations' :: string                 AS source_system_code,
    leg_org.type_code :: string                     AS electronic_address_type_code,
    leg_org.address_value :: string                 AS electronic_address_value
FROM leg_org
;
