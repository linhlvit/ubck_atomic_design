/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_identity_verification_record
* Program name: Securities Practitioner Identity Verification Record
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH id_in_06 AS (
    SELECT id, identitynumber, fullname, firstname, birthdate, birthyear, gender, national, religion, countrycode, placeofbirth, hometown, permanentcountrycode, permanentprovincecode, permanentdistrictcode, permanentdetail, currentcountrycode, currentprovincecode, currentdistrictcode, currentdetail, fatherfullname, fathercountrycode, fatheridentitynumber, fatheridentitynumberold, motherfullname, mothercountrycode, motheridentitynumber, motheridentitynumberold, couplefullname, couplecountrycode, coupleidentitynumber, coupleidentitynumberold, userupdateid
    FROM bronze.IDENTITYINFOC06S
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_IdentityInfoC06s', id_in_06.id) AS identity_verification_record_id,
    id_in_06.id :: string                          AS identity_verification_record_code,
    'NHNCK_IdentityInfoC06s' :: string             AS source_system_code,
    id_in_06.identitynumber :: string              AS identity_number,
    id_in_06.fullname :: string                    AS full_name,
    id_in_06.firstname :: string                   AS first_name,
    id_in_06.birthdate :: date                     AS date_of_birth,
    id_in_06.birthyear :: string                   AS birth_year,
    id_in_06.gender :: string                      AS individual_gender_code,
    id_in_06.national :: string                    AS nationality_code,
    id_in_06.religion :: string                    AS religion_name,
    id_in_06.countrycode :: string                 AS country_code,
    id_in_06.placeofbirth :: string                AS place_of_birth,
    id_in_06.hometown :: string                    AS hometown,
    id_in_06.permanentcountrycode :: string        AS permanent_country_code,
    id_in_06.permanentprovincecode :: string       AS permanent_province_code,
    id_in_06.permanentdistrictcode :: string       AS permanent_district_code,
    id_in_06.permanentdetail :: string             AS permanent_address_detail,
    id_in_06.currentcountrycode :: string          AS current_country_code,
    id_in_06.currentprovincecode :: string         AS current_province_code,
    id_in_06.currentdistrictcode :: string         AS current_district_code,
    id_in_06.currentdetail :: string               AS current_address_detail,
    id_in_06.fatherfullname :: string              AS father_full_name,
    id_in_06.fathercountrycode :: string           AS father_country_code,
    id_in_06.fatheridentitynumber :: string        AS father_identity_number,
    id_in_06.fatheridentitynumberold :: string     AS father_identity_number_old,
    id_in_06.motherfullname :: string              AS mother_full_name,
    id_in_06.mothercountrycode :: string           AS mother_country_code,
    id_in_06.motheridentitynumber :: string        AS mother_identity_number,
    id_in_06.motheridentitynumberold :: string     AS mother_identity_number_old,
    id_in_06.couplefullname :: string              AS couple_full_name,
    id_in_06.couplecountrycode :: string           AS couple_country_code,
    id_in_06.coupleidentitynumber :: string        AS couple_identity_number,
    id_in_06.coupleidentitynumberold :: string     AS couple_identity_number_old,
    NULL :: string                                 AS updated_by_officer_id,
    id_in_06.userupdateid :: string                AS updated_by_officer_code
;
