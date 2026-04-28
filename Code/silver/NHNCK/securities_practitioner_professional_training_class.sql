/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_professional_training_class
* Program name: Securities Practitioner Professional Training Class
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH sp_co AS (
    SELECT id, specializationid, coursecode, coursename, academicyear, examdate, description, filepath, isactive, status, createdby, updatedby, createdat, updatedat
    FROM bronze.SPECIALIZATIONCOURSES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_SpecializationCourses', sp_co.id) AS professional_training_class_id,
    sp_co.id :: string                               AS professional_training_class_code,
    'NHNCK_SpecializationCourses' :: string          AS source_system_code,
    sp_co.specializationid :: string                 AS specialization_type_code,
    sp_co.coursecode :: string                       AS course_code,
    sp_co.coursename :: string                       AS course_name,
    sp_co.academicyear :: string                     AS academic_year,
    sp_co.examdate :: date                           AS exam_date,
    sp_co.description :: string                      AS course_description,
    sp_co.filepath :: string                         AS attachment_file_path,
    sp_co.isactive :: string                         AS is_active_flag,
    sp_co.status :: string                           AS course_status_code,
    NULL :: string                                   AS created_by_officer_id,
    sp_co.createdby :: string                        AS created_by_officer_code,
    NULL :: string                                   AS updated_by_officer_id,
    sp_co.updatedby :: string                        AS updated_by_officer_code,
    sp_co.createdat :: timestamp                     AS created_timestamp,
    sp_co.updatedat :: timestamp                     AS updated_timestamp
;
