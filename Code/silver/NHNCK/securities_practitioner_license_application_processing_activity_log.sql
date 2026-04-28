/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_license_application_processing_activity_log
* Program name: Securities Practitioner License Application Processing Activity Log
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ac_lo AS (
    SELECT id, userid, clientmachine, detail, createdat
    FROM bronze.ACTIONLOGS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_ActionLogs', ac_lo.id) AS license_application_processing_activity_log_id,
    ac_lo.id :: string                    AS license_application_processing_activity_log_code,
    'NHNCK_ActionLogs' :: string          AS source_system_code,
    NULL :: string                        AS officer_id,
    ac_lo.userid :: string                AS officer_code,
    ac_lo.clientmachine :: string         AS client_machine_address,
    ac_lo.detail :: string                AS activity_detail,
    ac_lo.createdat :: timestamp          AS created_timestamp
;
