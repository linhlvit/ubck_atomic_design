/*
*--------------------------------------------------------------------*
* Program code: securities_practitioner_license_application_fee
* Program name: Securities Practitioner License Application Fee
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH ap_fe AS (
    SELECT id, applicationid, professionalid, feetype, fee, content, note, status, requestdate, paymentdate, expirydate, createdby, createdat, updatedat
    FROM bronze.APPLICATIONFEES
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    hash_id('NHNCK_ApplicationFees', ap_fe.id)           AS license_application_fee_id,
    ap_fe.id :: string                                   AS license_application_fee_code,
    'NHNCK_ApplicationFees' :: string                    AS source_system_code,
    hash_id('NHNCK_Applications', ap_fe.applicationid)   AS license_application_id,
    ap_fe.applicationid :: string                        AS license_application_code,
    hash_id('NHNCK_Professionals', ap_fe.professionalid) AS practitioner_id,
    ap_fe.professionalid :: string                       AS practitioner_code,
    ap_fe.feetype :: string                              AS fee_type_code,
    ap_fe.fee :: decimal(23,2)                           AS fee_amount,
    ap_fe.content :: string                              AS fee_content,
    ap_fe.note :: string                                 AS fee_note,
    ap_fe.status :: string                               AS payment_status_code,
    ap_fe.requestdate :: date                            AS request_date,
    ap_fe.paymentdate :: date                            AS payment_date,
    ap_fe.expirydate :: date                             AS expiry_date,
    NULL :: string                                       AS created_by_officer_id,
    ap_fe.createdby :: string                            AS created_by_officer_code,
    ap_fe.createdat :: timestamp                         AS created_timestamp,
    ap_fe.updatedat :: timestamp                         AS updated_timestamp
;
