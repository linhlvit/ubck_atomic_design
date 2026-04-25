/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_license_decision_document
* Program name: Securities Practitioner License Decision Document
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH de AS (
    SELECT id, decisionnumber, title, reference, decisioncontent, signeddate, signatory, position, decisionunit, filename, filepath, typeid, status, createdby, createdat, updatedat
    FROM bronze.DECISIONS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_Decisions', de.id) AS license_decision_document_id,
    de.id :: string                   AS license_decision_document_code,
    'NHNCK_Decisions' :: string       AS source_system_code,
    de.decisionnumber :: string       AS decision_number,
    de.title :: string                AS decision_title,
    de.reference :: string            AS decision_reference,
    de.decisioncontent :: string      AS decision_content,
    de.signeddate :: date             AS signing_date,
    de.signatory :: string            AS signatory_name,
    de.position :: string             AS signatory_position_name,
    de.decisionunit :: string         AS decision_unit_name,
    de.filename :: string             AS attachment_file_name,
    de.filepath :: string             AS attachment_file_path,
    de.typeid :: string               AS decision_type_code,
    de.status :: string               AS decision_status_code,
    NULL :: string                    AS created_by_officer_id,
    de.createdby :: string            AS created_by_officer_code,
    de.createdat :: timestamp         AS created_timestamp,
    de.updatedat :: timestamp         AS updated_timestamp
;
