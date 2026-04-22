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

WITH leg_org AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.ORGANIZATIONS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.ORGANIZATIONS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'MOBILE' AS type_code,
        mobilenumber AS address_value,
        source_system_code
    FROM bronze.ORGANIZATIONS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND mobilenumber IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        phonenumber AS address_value,
        source_system_code
    FROM bronze.ORGANIZATIONS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND phonenumber IS NOT NULL
)

SELECT
    hash_id(leg_org.source_system_code, leg_org.ip_code) AS involved_party_id,
    leg_org.ip_code :: string                            AS involved_party_code,
    leg_org.source_system_code :: string                 AS source_system_code,
    leg_org.type_code :: string                          AS electronic_address_type_code,
    leg_org.address_value :: string                      AS electronic_address_value
FROM leg_org
;
