/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_license_certificate_group_member
* Program name: Securities Practitioner License Certificate Group Member
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ce_re_gr_me AS (
    SELECT id, certificaterecordgroupid, certificaterecordid, orderindex, isreissue, revocationreason, status
    FROM bronze.CERTIFICATERECORDGROUPMEMBERS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_CertificateRecordGroupMembers', ce_re_gr_me.id)           AS license_certificate_group_member_id,
    ce_re_gr_me.id :: string                                                 AS license_certificate_group_member_code,
    'NHNCK_CertificateRecordGroupMembers' :: string                          AS source_system_code,
    hash_id('NHNCK_CertificateRecordGroups', ce_re_gr_me.certificaterecordgroupid) AS license_certificate_group_document_id,
    ce_re_gr_me.certificaterecordgroupid :: string                           AS license_certificate_group_document_code,
    hash_id('NHNCK_CertificateRecords', ce_re_gr_me.certificaterecordid)     AS license_certificate_document_id,
    ce_re_gr_me.certificaterecordid :: string                                AS license_certificate_document_code,
    ce_re_gr_me.orderindex :: string                                         AS order_index,
    ce_re_gr_me.isreissue :: string                                          AS is_reissue_indicator,
    ce_re_gr_me.revocationreason :: string                                   AS revocation_reason,
    ce_re_gr_me.status :: string                                             AS member_status_code
;
