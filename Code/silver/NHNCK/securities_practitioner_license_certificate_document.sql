/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_license_certificate_document
* Program name: Securities Practitioner License Certificate Document
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ce_re AS (
    SELECT id, professionalid, professionalfullname, certificateid, issuedecisionid, revocationdecisionid, cannellationdecisionid, certificatenumber, issuedate, revocationdate, revocationreason, status, processstatus, description, allowreissue, createdby, createdat
    FROM bronze.CERTIFICATERECORDS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_CertificateRecords', ce_re.id)            AS license_certificate_document_id,
    ce_re.id :: string                                       AS license_certificate_document_code,
    'NHNCK_CertificateRecords' :: string                     AS source_system_code,
    hash_id('NHNCK_Professionals', ce_re.professionalid)     AS practitioner_id,
    ce_re.professionalid :: string                           AS practitioner_code,
    ce_re.professionalfullname :: string                     AS professional_full_name,
    ce_re.certificateid :: string                            AS certificate_type_code,
    hash_id('NHNCK_Decisions', ce_re.issuedecisionid)        AS issuance_decision_document_id,
    ce_re.issuedecisionid :: string                          AS issuance_decision_document_code,
    hash_id('NHNCK_Decisions', ce_re.revocationdecisionid)   AS revocation_decision_document_id,
    ce_re.revocationdecisionid :: string                     AS revocation_decision_document_code,
    hash_id('NHNCK_Decisions', ce_re.cannellationdecisionid) AS cancellation_decision_document_id,
    ce_re.cannellationdecisionid :: string                   AS cancellation_decision_document_code,
    ce_re.certificatenumber :: string                        AS certificate_number,
    ce_re.issuedate :: date                                  AS certificate_issue_date,
    ce_re.revocationdate :: date                             AS revocation_date,
    ce_re.revocationreason :: string                         AS revocation_reason,
    ce_re.status :: string                                   AS certificate_status_code,
    ce_re.processstatus :: string                            AS process_status_code,
    ce_re.description :: string                              AS certificate_description,
    ce_re.allowreissue :: string                             AS allow_reissue_indicator,
    NULL :: string                                           AS created_by_officer_id,
    ce_re.createdby :: string                                AS created_by_officer_code,
    ce_re.createdat :: timestamp                             AS created_timestamp
;
