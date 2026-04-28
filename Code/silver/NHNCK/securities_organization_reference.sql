/*
*--------------------------------------------------------------------*
* Program code: securities_organization_reference
* Program name: Securities Organization Reference
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH org AS (
    SELECT id, organizationcode, organizationname, englishname, abbreviation, organizationtypeid, level, parentid, representative, chartercapital, licensenumber, licenseissuer, licensedate, website, description, status, sortorder, linkedid, syncid, lastsyncdate, syncstatus, createdby, createdat, updatedat
    FROM bronze.ORGANIZATIONS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_Organizations', org.id)       AS securities_organization_reference_id,
    org.id :: string                             AS securities_organization_reference_code,
    'NHNCK_Organizations' :: string              AS source_system_code,
    org.organizationcode :: string               AS organization_code,
    org.organizationname :: string               AS organization_name,
    org.englishname :: string                    AS english_name,
    org.abbreviation :: string                   AS abbreviation,
    org.organizationtypeid :: string             AS organization_type_code,
    org.level :: string                          AS organization_level_code,
    hash_id('NHNCK_Organizations', org.parentid) AS parent_organization_id,
    org.parentid :: string                       AS parent_organization_code,
    org.representative :: string                 AS representative_name,
    org.chartercapital :: decimal(23,2)          AS charter_capital_amount,
    org.licensenumber :: string                  AS license_number,
    org.licenseissuer :: string                  AS license_issuer,
    org.licensedate :: date                      AS license_date,
    org.website :: string                        AS website,
    org.description :: string                    AS organization_description,
    org.status :: string                         AS organization_status_code,
    org.sortorder :: string                      AS sort_order,
    org.linkedid :: string                       AS linked_id,
    org.syncid :: string                         AS sync_id,
    org.lastsyncdate :: date                     AS last_sync_date,
    org.syncstatus :: string                     AS sync_status_code,
    NULL :: string                               AS created_by_officer_id,
    org.createdby :: string                      AS created_by_officer_code,
    org.createdat :: timestamp                   AS created_timestamp,
    org.updatedat :: timestamp                   AS updated_timestamp
;
