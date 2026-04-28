/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_related_party
* Program name: Securities Practitioner Related Party
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH pr_re AS (
    SELECT id, professionalid, fullname, relationshiptype, birthyear, countryid, identityid, address, occupation, workplace, note, createdat
    FROM bronze.PROFESSIONALRELATIONSHIPS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_ProfessionalRelationships', pr_re.id) AS securities_practitioner_related_party_id,
    pr_re.id :: string                                   AS securities_practitioner_related_party_code,
    'NHNCK_ProfessionalRelationships' :: string          AS source_system_code,
    hash_id('NHNCK_Professionals', pr_re.professionalid) AS practitioner_id,
    pr_re.professionalid :: string                       AS practitioner_code,
    pr_re.fullname :: string                             AS related_party_full_name,
    pr_re.relationshiptype :: string                     AS relationship_type_code,
    pr_re.birthyear :: string                            AS birth_year,
    pr_re.countryid :: string                            AS country_code,
    pr_re.identityid :: string                           AS identity_reference_code,
    pr_re.address :: string                              AS address,
    pr_re.occupation :: string                           AS occupation_name,
    pr_re.workplace :: string                            AS workplace_name,
    pr_re.note :: string                                 AS related_party_note,
    pr_re.createdat :: timestamp                         AS created_timestamp
;
