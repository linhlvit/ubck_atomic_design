/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_professional_training_class_enrollment
* Program name: Securities Practitioner Professional Training Class Enrollment
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH sp_co_de AS (
    SELECT id, specializationcourseid, professionalid, fullname, birthdate, placeofdate, identitynumber, examnumber, description, examscore, result, note, status, assigneeid, createdby, updatedby, createdat, updatedat
    FROM bronze.SPECIALIZATIONCOURSEDETAILS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_SpecializationCourseDetails', sp_co_de.id)               AS professional_training_class_enrollment_id,
    sp_co_de.id :: string                                                   AS professional_training_class_enrollment_code,
    'NHNCK_SpecializationCourseDetails' :: string                           AS source_system_code,
    hash_id('NHNCK_SpecializationCourses', sp_co_de.specializationcourseid) AS professional_training_class_id,
    sp_co_de.specializationcourseid :: string                               AS professional_training_class_code,
    hash_id('NHNCK_Professionals', sp_co_de.professionalid)                 AS practitioner_id,
    sp_co_de.professionalid :: string                                       AS practitioner_code,
    sp_co_de.fullname :: string                                             AS full_name,
    sp_co_de.birthdate :: date                                              AS date_of_birth,
    sp_co_de.placeofdate :: string                                          AS place_of_birth,
    sp_co_de.identitynumber :: string                                       AS identification_number,
    sp_co_de.examnumber :: string                                           AS exam_number,
    sp_co_de.description :: string                                          AS enrollment_description,
    sp_co_de.examscore :: string                                            AS assessment_score,
    sp_co_de.result :: string                                               AS assessment_result_code,
    sp_co_de.note :: string                                                 AS enrollment_note,
    sp_co_de.status :: string                                               AS enrollment_status_code,
    NULL :: string                                                          AS assignee_officer_id,
    sp_co_de.assigneeid :: string                                           AS assignee_officer_code,
    NULL :: string                                                          AS created_by_officer_id,
    sp_co_de.createdby :: string                                            AS created_by_officer_code,
    NULL :: string                                                          AS updated_by_officer_id,
    sp_co_de.updatedby :: string                                            AS updated_by_officer_code,
    sp_co_de.createdat :: timestamp                                         AS created_timestamp,
    sp_co_de.updatedat :: timestamp                                         AS updated_timestamp
;
