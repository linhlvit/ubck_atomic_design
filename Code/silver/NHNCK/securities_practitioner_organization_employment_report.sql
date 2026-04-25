/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_organization_employment_report
* Program name: Securities Practitioner Organization Employment Report
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH or_re AS (
    SELECT id, professionalid, organizationid, certificateid, certificaterecordid, parentreportid, type, reportdate, fullname, birthdate, identitynumber, position, department, businessdepartment, workplace, hiredate, terminationdate, certificatenumber, issuedate, disciplines, description, syncid, synccreatedat, syncupdatedat, createdby, createdat, updatedat
    FROM bronze.ORGANIZATIONREPORTS
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_OrganizationReports', or_re.id)                 AS organization_employment_report_id,
    or_re.id :: string                                             AS organization_employment_report_code,
    'NHNCK_OrganizationReports' :: string                          AS source_system_code,
    hash_id('NHNCK_Professionals', or_re.professionalid)           AS practitioner_id,
    or_re.professionalid :: string                                 AS practitioner_code,
    hash_id('NHNCK_Organizations', or_re.organizationid)           AS securities_organization_id,
    or_re.organizationid :: string                                 AS securities_organization_code,
    or_re.certificateid :: string                                  AS certificate_type_code,
    hash_id('NHNCK_CertificateRecords', or_re.certificaterecordid) AS license_certificate_document_id,
    or_re.certificaterecordid :: string                            AS license_certificate_document_code,
    hash_id('NHNCK_OrganizationReports', or_re.parentreportid)     AS parent_organization_employment_report_id,
    or_re.parentreportid :: string                                 AS parent_organization_employment_report_code,
    or_re.type :: string                                           AS report_type_code,
    or_re.reportdate :: date                                       AS report_date,
    or_re.fullname :: string                                       AS full_name,
    or_re.birthdate :: date                                        AS date_of_birth,
    or_re.identitynumber :: string                                 AS identification_number,
    or_re.position :: string                                       AS position_name,
    or_re.department :: string                                     AS department_name,
    or_re.businessdepartment :: string                             AS business_department_name,
    or_re.workplace :: string                                      AS workplace_name,
    or_re.hiredate :: date                                         AS hire_date,
    or_re.terminationdate :: date                                  AS termination_date,
    or_re.certificatenumber :: string                              AS certificate_number,
    or_re.issuedate :: date                                        AS certificate_issue_date,
    or_re.disciplines :: string                                    AS discipline_description,
    or_re.description :: string                                    AS report_description,
    or_re.syncid :: string                                         AS sync_id,
    or_re.synccreatedat :: timestamp                               AS sync_created_timestamp,
    or_re.syncupdatedat :: timestamp                               AS sync_updated_timestamp,
    NULL :: string                                                 AS created_by_officer_id,
    or_re.createdby :: string                                      AS created_by_officer_code,
    or_re.createdat :: timestamp                                   AS created_timestamp,
    or_re.updatedat :: timestamp                                   AS updated_timestamp
;
