/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_license_application_document_attachment
* Program name: Securities Practitioner License Application Document Attachment
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ap_do AS (
    SELECT id, applicationid, documentid, documentname, filename, filepath, format, filesize, description, note, status, isinvalid, isincomplete, assigneeid, appraisaledat, createdat
    FROM bronze.APPLICATIONDOCUMENTS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_ApplicationDocuments', ap_do.id)    AS license_application_document_attachment_id,
    ap_do.id :: string                                 AS license_application_document_attachment_code,
    'NHNCK_ApplicationDocuments' :: string             AS source_system_code,
    hash_id('NHNCK_Applications', ap_do.applicationid) AS license_application_id,
    ap_do.applicationid :: string                      AS license_application_code,
    ap_do.documentid :: string                         AS document_type_code,
    ap_do.documentname :: string                       AS document_name,
    ap_do.filename :: string                           AS file_name,
    ap_do.filepath :: string                           AS file_path,
    ap_do.format :: string                             AS file_format,
    ap_do.filesize :: string                           AS file_size,
    ap_do.description :: string                        AS attachment_description,
    ap_do.note :: string                               AS attachment_note,
    ap_do.status :: string                             AS appraisal_status_code,
    ap_do.isinvalid :: string                          AS is_invalid_indicator,
    ap_do.isincomplete :: string                       AS is_incomplete_indicator,
    NULL :: string                                     AS assignee_officer_id,
    ap_do.assigneeid :: string                         AS assignee_officer_code,
    ap_do.appraisaledat :: timestamp                   AS appraisaled_timestamp,
    ap_do.createdat :: timestamp                       AS created_timestamp
;
