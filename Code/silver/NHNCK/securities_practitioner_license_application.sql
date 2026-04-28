/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_license_application
* Program name: Securities Practitioner License Application
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ap AS (
    SELECT id, professionalid, certificateid, statusid, certificaterecordid, previouscertificateid, previouscertificaterecordid, examsessionid, assigneeid, infoverifyid, applicationcode, title, registrationtype, applicationtype, submissiondate, supplementdate, supplementletterdate, reissuereason, rejectionreason, certificatenumber, issuedate, previouscertificatenumber, previousissuedate, reissuehsm, certificatereceiptmethod, certificatereceiptaddress, certificatereceiptphone, receiptstatus, isviolated, isdateexploitable, note, createdby, updatedby, createdat, updatedat
    FROM bronze.APPLICATIONS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_Applications', ap.id)                                AS license_application_id,
    ap.id :: string                                                     AS license_application_code,
    'NHNCK_Applications' :: string                                      AS source_system_code,
    hash_id('NHNCK_Professionals', ap.professionalid)                   AS practitioner_id,
    ap.professionalid :: string                                         AS practitioner_code,
    ap.certificateid :: string                                          AS certificate_type_code,
    ap.statusid :: string                                               AS application_status_code,
    hash_id('NHNCK_CertificateRecords', ap.certificaterecordid)         AS license_certificate_document_id,
    ap.certificaterecordid :: string                                    AS license_certificate_document_code,
    ap.previouscertificateid :: string                                  AS previous_certificate_type_code,
    hash_id('NHNCK_CertificateRecords', ap.previouscertificaterecordid) AS previous_license_certificate_document_id,
    ap.previouscertificaterecordid :: string                            AS previous_license_certificate_document_code,
    hash_id('NHNCK_ExamSessions', ap.examsessionid)                     AS examination_assessment_id,
    ap.examsessionid :: string                                          AS examination_assessment_code,
    NULL :: string                                                      AS assignee_officer_id,
    ap.assigneeid :: string                                             AS assignee_officer_code,
    hash_id('NHNCK_VerifyApplicationStatuses', ap.infoverifyid)         AS license_application_verification_status_id,
    ap.infoverifyid :: string                                           AS license_application_verification_status_code,
    ap.applicationcode :: string                                        AS application_code,
    ap.title :: string                                                  AS application_title,
    ap.registrationtype :: string                                       AS registration_type_code,
    ap.applicationtype :: string                                        AS application_type_code,
    ap.submissiondate :: date                                           AS submission_date,
    ap.supplementdate :: date                                           AS supplement_date,
    ap.supplementletterdate :: date                                     AS supplement_letter_date,
    ap.reissuereason :: string                                          AS reissue_reason,
    ap.rejectionreason :: string                                        AS rejection_reason,
    ap.certificatenumber :: string                                      AS certificate_number,
    ap.issuedate :: date                                                AS issue_date,
    ap.previouscertificatenumber :: string                              AS previous_certificate_number,
    ap.previousissuedate :: date                                        AS previous_issue_date,
    ap.reissuehsm :: string                                             AS reissue_hsm_code,
    ap.certificatereceiptmethod :: string                               AS certificate_receipt_method_code,
    ap.certificatereceiptaddress :: string                              AS certificate_receipt_address,
    ap.certificatereceiptphone :: string                                AS certificate_receipt_phone,
    ap.receiptstatus :: string                                          AS receipt_status_code,
    ap.isviolated :: string                                             AS is_violated_indicator,
    ap.isdateexploitable :: date                                        AS is_date_exploitable_indicator,
    ap.note :: string                                                   AS application_note,
    NULL :: string                                                      AS created_by_officer_id,
    ap.createdby :: string                                              AS created_by_officer_code,
    NULL :: string                                                      AS updated_by_officer_id,
    ap.updatedby :: string                                              AS updated_by_officer_code,
    ap.createdat :: timestamp                                           AS created_timestamp,
    ap.updatedat :: timestamp                                           AS updated_timestamp
;
