/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_license_certificate_document_activity_log
* Program name: Securities Practitioner License Certificate Document Activity Log
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ce_re_lo AS (
    SELECT id, certificaterecordid, actiontype, certificatenumber, decisionid, issuedate, note, createdby
    FROM bronze.CERTIFICATERECORDLOGS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_CertificateRecordLogs', ce_re_lo.id)               AS license_certificate_document_activity_log_id,
    ce_re_lo.id :: string                                             AS license_certificate_document_activity_log_code,
    'NHNCK_CertificateRecordLogs' :: string                           AS source_system_code,
    hash_id('NHNCK_CertificateRecords', ce_re_lo.certificaterecordid) AS license_certificate_document_id,
    ce_re_lo.certificaterecordid :: string                            AS license_certificate_document_code,
    ce_re_lo.actiontype :: string                                     AS activity_type_code,
    ce_re_lo.certificatenumber :: string                              AS certificate_number,
    hash_id('NHNCK_Decisions', ce_re_lo.decisionid)                   AS license_decision_document_id,
    ce_re_lo.decisionid :: string                                     AS license_decision_document_code,
    ce_re_lo.issuedate :: date                                        AS issue_date,
    ce_re_lo.note :: string                                           AS activity_note,
    NULL :: string                                                    AS processed_by_officer_id,
    ce_re_lo.createdby :: string                                      AS processed_by_officer_code
;
