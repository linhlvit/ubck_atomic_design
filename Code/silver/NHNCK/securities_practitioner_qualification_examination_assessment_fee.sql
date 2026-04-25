/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_qualification_examination_assessment_fee
* Program name: Securities Practitioner Qualification Examination Assessment Fee
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ex_se_fe AS (
    SELECT id, examsessionid, certificateid, feeexam, feeappeal, status, createdby, updatedby, createdat, updatedat
    FROM bronze.EXAMSESSIONFEES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_ExamSessionFees', ex_se_fe.id)         AS examination_assessment_fee_id,
    ex_se_fe.id :: string                                 AS examination_assessment_fee_code,
    'NHNCK_ExamSessionFees' :: string                     AS source_system_code,
    hash_id('NHNCK_ExamSessions', ex_se_fe.examsessionid) AS examination_assessment_id,
    ex_se_fe.examsessionid :: string                      AS examination_assessment_code,
    ex_se_fe.certificateid :: string                      AS certificate_type_code,
    ex_se_fe.feeexam :: decimal(23,2)                     AS examination_fee_amount,
    ex_se_fe.feeappeal :: decimal(23,2)                   AS appeal_fee_amount,
    ex_se_fe.status :: string                             AS fee_status_code,
    NULL :: string                                        AS created_by_officer_id,
    ex_se_fe.createdby :: string                          AS created_by_officer_code,
    NULL :: string                                        AS updated_by_officer_id,
    ex_se_fe.updatedby :: string                          AS updated_by_officer_code,
    ex_se_fe.createdat :: timestamp                       AS created_timestamp,
    ex_se_fe.updatedat :: timestamp                       AS updated_timestamp
;
