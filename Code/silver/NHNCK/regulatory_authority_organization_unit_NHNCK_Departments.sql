/*
*--------------------------------------------------------------------*
* Program code: regulatory_authority_organization_unit_NHNCK_Departments
* Program name: Regulatory Authority Organization Unit NHNCK Departments
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH de AS (
    SELECT departmentcode, departmentname, description, status, unitid, sortorder
    FROM bronze.DEPARTMENTS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_Departments', de.departmentcode) AS organization_unit_id,
    de.departmentcode :: string                     AS organization_unit_code,
    'NHNCK_Departments' :: string                   AS source_system_code,
    NULL :: string                                  AS organization_unit_type_code,
    de.departmentname :: string                     AS organization_unit_name,
    de.description :: string                        AS organization_unit_description,
    de.status :: string                             AS organization_unit_status_code,
    hash_id('NHNCK_Units', de.unitid)               AS parent_organization_unit_id,
    de.unitid :: string                             AS parent_organization_unit_code,
    de.sortorder :: string                          AS sort_order
;
