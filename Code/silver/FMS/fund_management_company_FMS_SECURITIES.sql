/*
*--------------------------------------------------------------------*
* Program code: fund_management_company_FMS_SECURITIES
* Program name: Fund Management Company FMS SECURITIES
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH se AS (
    SELECT id, name, shortname, enname, status, seccapital, dorf, decision, decisiondate, activedate, stopdate, createdby, datecreated, datemodified
    FROM bronze.SECURITIES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

se_bu AS (
    SELECT secid, array_agg(buid) AS business_type_codes
    FROM bronze.SECBUSINES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    GROUP BY secid
)

SELECT
    hash_id('FMS_SECURITIES', se.id)    AS fund_management_company_id,
    se.id :: string                     AS fund_management_company_code,
    'FMS_SECURITIES' :: string          AS source_system_code,
    se.name :: string                   AS fund_management_company_name,
    se.shortname :: string              AS fund_management_company_short_name,
    se.enname :: string                 AS fund_management_company_english_name,
    se.status :: string                 AS practice_status_code,
    se.seccapital :: decimal(23,2)      AS charter_capital_amount,
    se.dorf :: string                   AS dorf_indicator,
    se.decision :: string               AS license_decision_number,
    se.decisiondate :: date             AS license_decision_date,
    se.activedate :: date               AS active_date,
    se.stopdate :: date                 AS stop_date,
    se_bu.business_type_codes :: string AS business_type_codes,
    se.createdby :: string              AS created_by,
    se.datecreated :: timestamp         AS created_timestamp,
    se.datemodified :: timestamp        AS updated_timestamp,
    NULL :: string                      AS country_of_registration_id,
    NULL :: string                      AS country_of_registration_code,
    NULL :: string                      AS life_cycle_status_code,
    NULL :: string                      AS director_name,
    NULL :: string                      AS depository_certificate_number,
    NULL :: string                      AS company_type_codes,
    NULL :: string                      AS description,
    NULL :: string                      AS company_type_code,
    NULL :: string                      AS fund_type_code,
    NULL :: string                      AS business_license_number,
    NULL :: string                      AS website
FROM se
    LEFT JOIN se_bu ON se.id = se_bu.secid
;
