/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_license_application_verification_status
* Program name: Securities Practitioner License Application Verification Status
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ve_ap_st AS (
    SELECT id, applicationid, statusid, prevstatusid, verifiedby, reason, specreason, orgreason, overviewreason, createdby, updatedby, createdat, updatedat
    FROM bronze.VERIFYAPPLICATIONSTATUSES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_VerifyApplicationStatuses', ve_ap_st.id) AS license_application_verification_status_id,
    ve_ap_st.id :: string                                   AS license_application_verification_status_code,
    'NHNCK_VerifyApplicationStatuses' :: string             AS source_system_code,
    hash_id('NHNCK_Applications', ve_ap_st.applicationid)   AS license_application_id,
    ve_ap_st.applicationid :: string                        AS license_application_code,
    ve_ap_st.statusid :: string                             AS verification_status_code,
    ve_ap_st.prevstatusid :: string                         AS previous_verification_status_code,
    NULL :: string                                          AS verified_by_officer_id,
    ve_ap_st.verifiedby :: string                           AS verified_by_officer_code,
    ve_ap_st.reason :: string                               AS rejection_reason_description,
    ve_ap_st.specreason :: string                           AS specialization_officer_reason,
    ve_ap_st.orgreason :: string                            AS organization_officer_reason,
    ve_ap_st.overviewreason :: string                       AS overview_officer_reason,
    NULL :: string                                          AS created_by_officer_id,
    ve_ap_st.createdby :: string                            AS created_by_officer_code,
    NULL :: string                                          AS updated_by_officer_id,
    ve_ap_st.updatedby :: string                            AS updated_by_officer_code,
    ve_ap_st.createdat :: timestamp                         AS created_timestamp,
    ve_ap_st.updatedat :: timestamp                         AS updated_timestamp
;
