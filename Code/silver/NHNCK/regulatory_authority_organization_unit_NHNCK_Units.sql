/*
*--------------------------------------------------------------------*
* Program code: regulatory_authority_organization_unit_NHNCK_Units
* Program name: Regulatory Authority Organization Unit NHNCK Units
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH un AS (
    SELECT unitcode, unitname, description, status
    FROM bronze.UNITS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_Units', un.unitcode) AS organization_unit_id,
    un.unitcode :: string               AS organization_unit_code,
    'NHNCK_Units' :: string             AS source_system_code,
    NULL :: string                      AS organization_unit_type_code,
    un.unitname :: string               AS organization_unit_name,
    un.description :: string            AS organization_unit_description,
    un.status :: string                 AS organization_unit_status_code,
    NULL :: string                      AS parent_organization_unit_id,
    NULL :: string                      AS parent_organization_unit_code,
    NULL :: string                      AS sort_order
;
