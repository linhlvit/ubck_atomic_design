/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_license_certificate_group_document
* Program name: Securities Practitioner License Certificate Group Document
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ce_re_gr AS (
    SELECT id, groupname, type, decisionid, description, notes, status, createdat, updatedat
    FROM bronze.CERTIFICATERECORDGROUPS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_CertificateRecordGroups', ce_re_gr.id) AS license_certificate_group_document_id,
    ce_re_gr.id :: string                                 AS license_certificate_group_document_code,
    'NHNCK_CertificateRecordGroups' :: string             AS source_system_code,
    ce_re_gr.groupname :: string                          AS group_name,
    ce_re_gr.type :: string                               AS group_type_code,
    hash_id('NHNCK_Decisions', ce_re_gr.decisionid)       AS license_decision_document_id,
    ce_re_gr.decisionid :: string                         AS license_decision_document_code,
    ce_re_gr.description :: string                        AS group_description,
    ce_re_gr.notes :: string                              AS group_notes,
    ce_re_gr.status :: string                             AS group_status_code,
    ce_re_gr.createdat :: timestamp                       AS created_timestamp,
    ce_re_gr.updatedat :: timestamp                       AS updated_timestamp
;
