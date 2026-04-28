/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_NHNCK_Professionals
* Program name: Securities Practitioner NHNCK Professionals
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH pro AS (
    SELECT id, fullname, birthyear, countryid, identityid, relationshiptype, occupation, workplace, note, createdat
    FROM bronze.PROFESSIONALS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

pr_hi AS (
    SELECT birthdate, gender, nationalityid, educationlevelid, placeofbirth, registrationtype, statuswork
    FROM bronze.PROFESSIONALHISTORIES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_Professionals', pro.id)  AS practitioner_id,
    pro.id :: string                        AS practitioner_code,
    'NHNCK_Professionals' :: string         AS source_system_code,
    pro.fullname :: string                  AS full_name,
    pro.birthyear :: string                 AS birth_year,
    pr_hi.birthdate :: date                 AS date_of_birth,
    pr_hi.gender :: string                  AS individual_gender_code,
    pr_hi.nationalityid :: string           AS nationality_code,
    pr_hi.educationlevelid :: string        AS education_level_code,
    pr_hi.placeofbirth :: string            AS birth_place,
    pr_hi.registrationtype :: string        AS practitioner_registration_type_code,
    pr_hi.statuswork :: string              AS practice_status_code,
    hash_id('FIMS_NATIONAL', pro.countryid) AS country_of_residence_geographic_area_id,
    pro.countryid :: string                 AS country_of_residence_geographic_area_code,
    pro.identityid :: string                AS identity_reference_code,
    pro.relationshiptype :: string          AS relationship_type_code,
    pro.occupation :: string                AS occupation_name,
    pro.workplace :: string                 AS workplace_name,
    pro.note :: string                      AS practitioner_note,
    pro.createdat :: timestamp              AS created_timestamp,
    NULL :: string                          AS securities_company_id,
    NULL :: string                          AS securities_company_code,
    NULL :: string                          AS employee_code,
    NULL :: string                          AS license_number,
    NULL :: date                            AS employment_start_date,
    NULL :: date                            AS employment_end_date,
    NULL :: string                          AS note,
    NULL :: string                          AS practitioner_status_code
FROM pro
    LEFT JOIN pr_hi ON pro.id = pr_hi.??
;
