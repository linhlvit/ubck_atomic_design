/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_license_certificate_document_status_history
* Program name: Securities Practitioner License Certificate Document Status History
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ce_re_st_hi AS (
    SELECT id, certificaterecordid, decisionid, updatetype, oldstatus, newstatus, reason, createdat, updatedat
    FROM bronze.CERTIFICATERECORDSTATUSHISTORIES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_CertificateRecordStatusHistories', ce_re_st_hi.id)    AS license_certificate_document_status_history_id,
    ce_re_st_hi.id :: string                                             AS license_certificate_document_status_history_code,
    'NHNCK_CertificateRecordStatusHistories' :: string                   AS source_system_code,
    hash_id('NHNCK_CertificateRecords', ce_re_st_hi.certificaterecordid) AS license_certificate_document_id,
    ce_re_st_hi.certificaterecordid :: string                            AS license_certificate_document_code,
    hash_id('NHNCK_Decisions', ce_re_st_hi.decisionid)                   AS license_decision_document_id,
    ce_re_st_hi.decisionid :: string                                     AS license_decision_document_code,
    ce_re_st_hi.updatetype :: string                                     AS update_type_code,
    ce_re_st_hi.oldstatus :: string                                      AS old_status_code,
    ce_re_st_hi.newstatus :: string                                      AS new_status_code,
    ce_re_st_hi.reason :: string                                         AS status_change_reason_description,
    ce_re_st_hi.createdat :: timestamp                                   AS status_change_timestamp,
    ce_re_st_hi.updatedat :: timestamp                                   AS updated_timestamp
;
