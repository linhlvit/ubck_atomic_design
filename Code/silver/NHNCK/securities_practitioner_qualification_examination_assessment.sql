/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_qualification_examination_assessment
* Program name: Securities Practitioner Qualification Examination Assessment
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ex_se AS (
    SELECT id, code, name, year, session, organizingunit, applicationstartdate, applicationenddate, examstartdate, examenddate, examlocations, notidate, submissionmethods, filepath, decisionid, status, createdby
    FROM bronze.EXAMSESSIONS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_ExamSessions', ex_se.id)      AS examination_assessment_id,
    ex_se.id :: string                           AS examination_assessment_code,
    'NHNCK_ExamSessions' :: string               AS source_system_code,
    ex_se.code :: string                         AS session_code,
    ex_se.name :: string                         AS session_name,
    ex_se.year :: string                         AS examination_year,
    ex_se.session :: string                      AS session_number,
    ex_se.organizingunit :: string               AS organizer_name,
    ex_se.applicationstartdate :: date           AS registration_start_date,
    ex_se.applicationenddate :: date             AS registration_end_date,
    ex_se.examstartdate :: date                  AS examination_start_date,
    ex_se.examenddate :: date                    AS examination_end_date,
    ex_se.examlocations :: string                AS examination_location,
    ex_se.notidate :: date                       AS notification_date,
    ex_se.submissionmethods :: string            AS submission_method_description,
    ex_se.filepath :: string                     AS attachment_file_path,
    hash_id('NHNCK_Decisions', ex_se.decisionid) AS license_decision_document_id,
    ex_se.decisionid :: string                   AS license_decision_document_code,
    ex_se.status :: string                       AS examination_status_code,
    NULL :: string                               AS created_by_officer_id,
    ex_se.createdby :: string                    AS created_by_officer_code
;
