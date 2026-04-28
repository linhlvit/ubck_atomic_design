/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_conduct_violation
* Program name: Securities Practitioner Conduct Violation
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH vi AS (
    SELECT id, professionalid, fullname, birthdate, identitynumber, decisionid, type, note, status, createdby, updatedby, createdat, updatedat
    FROM bronze.VIOLATIONS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_Violations', vi.id)                AS conduct_violation_id,
    vi.id :: string                                   AS conduct_violation_code,
    'NHNCK_Violations' :: string                      AS source_system_code,
    hash_id('NHNCK_Professionals', vi.professionalid) AS practitioner_id,
    vi.professionalid :: string                       AS practitioner_code,
    vi.fullname :: string                             AS full_name,
    vi.birthdate :: date                              AS date_of_birth,
    vi.identitynumber :: string                       AS identification_number,
    hash_id('NHNCK_Decisions', vi.decisionid)         AS license_decision_document_id,
    vi.decisionid :: string                           AS license_decision_document_code,
    vi.type :: string                                 AS conduct_violation_type_code,
    vi.note :: string                                 AS violation_note,
    vi.status :: string                               AS violation_status_code,
    NULL :: string                                    AS created_by_officer_id,
    vi.createdby :: string                            AS created_by_officer_code,
    NULL :: string                                    AS updated_by_officer_id,
    vi.updatedby :: string                            AS updated_by_officer_code,
    vi.createdat :: timestamp                         AS created_timestamp,
    vi.updatedat :: timestamp                         AS updated_timestamp
;
