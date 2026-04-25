/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_license_application_education_certificate_document
* Program name: Securities Practitioner License Application Education Certificate Document
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ap_sp AS (
    SELECT id, applicationid, specializationid, filename, filepath, format, filesize, note, status, assigneeid, appraisaledat
    FROM bronze.APPLICATIONSPECIALIZATIONS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_ApplicationSpecializations', ap_sp.id) AS license_application_education_certificate_document_id,
    ap_sp.id :: string                                    AS license_application_education_certificate_document_code,
    'NHNCK_ApplicationSpecializations' :: string          AS source_system_code,
    hash_id('NHNCK_Applications', ap_sp.applicationid)    AS license_application_id,
    ap_sp.applicationid :: string                         AS license_application_code,
    ap_sp.specializationid :: string                      AS specialization_type_code,
    ap_sp.filename :: string                              AS file_name,
    ap_sp.filepath :: string                              AS file_path,
    ap_sp.format :: string                                AS file_format,
    ap_sp.filesize :: string                              AS file_size,
    ap_sp.note :: string                                  AS specialization_note,
    ap_sp.status :: string                                AS appraisal_status_code,
    NULL :: string                                        AS assignee_officer_id,
    ap_sp.assigneeid :: string                            AS assignee_officer_code,
    ap_sp.appraisaledat :: timestamp                      AS appraisaled_timestamp
;
