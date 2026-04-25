/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_qualification_examination_assessment_result
* Program name: Securities Practitioner Qualification Examination Assessment Result
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ex_de AS (
    SELECT id, examsessionid, professionalid, certificateid, applicationid, sequencenumber, examnumber, lawscore, lawresult, specializationscore, specializationresult, result, note, createdby, createdat
    FROM bronze.EXAMDETAILS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_ExamDetails', ex_de.id)               AS examination_assessment_result_id,
    ex_de.id :: string                                   AS examination_assessment_result_code,
    'NHNCK_ExamDetails' :: string                        AS source_system_code,
    hash_id('NHNCK_ExamSessions', ex_de.examsessionid)   AS examination_assessment_id,
    ex_de.examsessionid :: string                        AS examination_assessment_code,
    hash_id('NHNCK_Professionals', ex_de.professionalid) AS practitioner_id,
    ex_de.professionalid :: string                       AS practitioner_code,
    ex_de.certificateid :: string                        AS certificate_type_code,
    hash_id('NHNCK_Applications', ex_de.applicationid)   AS license_application_id,
    ex_de.applicationid :: string                        AS license_application_code,
    ex_de.sequencenumber :: string                       AS sequence_number,
    ex_de.examnumber :: string                           AS exam_number,
    ex_de.lawscore :: string                             AS law_score,
    ex_de.lawresult :: string                            AS law_result_indicator,
    ex_de.specializationscore :: string                  AS specialization_score,
    ex_de.specializationresult :: string                 AS specialization_result_indicator,
    ex_de.result :: string                               AS examination_result_code,
    ex_de.note :: string                                 AS examination_note,
    NULL :: string                                       AS created_by_officer_id,
    ex_de.createdby :: string                            AS created_by_officer_code,
    ex_de.createdat :: timestamp                         AS created_timestamp
;
