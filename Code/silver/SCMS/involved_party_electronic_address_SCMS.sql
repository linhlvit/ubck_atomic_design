/*
*--------------------------------------------------------------------*
* Program code: involved_party_electronic_address_SCMS
* Program name: Involved Party Electronic Address SCMS
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH leg_ct_th_ti AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_THONG_TIN
    LATERAL VIEW stack(4,
        'EMAIL', email,
        'FAX', fax,
        'PHONE', dien_thoai,
        'WEBSITE', website
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_ch_nh AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_CHI_NHANH
    LATERAL VIEW stack(2,
        'FAX', fax,
        'PHONE', dien_thoai
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_nh_su_ca_ca AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_NHAN_SU_CAO_CAP
    LATERAL VIEW stack(4,
        'EMAIL', email,
        'EMAIL CONG BO TT', email_cong_bo_tt,
        'FAX', fax,
        'PHONE', dien_thoai
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_ki_to AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CT_KIEM_TOAN
    LATERAL VIEW stack(4,
        'EMAIL', email,
        'FAX', fax,
        'PHONE', dien_thoai,
        'WEBSITE', website
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_ph_gi_di AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_PHONG_GIAO_DICH
    LATERAL VIEW stack(2,
        'FAX', fax,
        'PHONE', dien_thoai
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_vp_da_di AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_VP_DAI_DIEN
    LATERAL VIEW stack(2,
        'FAX', fax,
        'PHONE', dien_thoai
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
)

SELECT
    hash_id('SCMS_CTCK_THONG_TIN', leg_ct_th_ti.ip_code) AS involved_party_id,
    leg_ct_th_ti.ip_code :: string                       AS involved_party_code,
    'SCMS_CTCK_THONG_TIN' :: string                      AS source_system_code,
    leg_ct_th_ti.type_code :: string                     AS electronic_address_type_code,
    leg_ct_th_ti.address_value :: string                 AS electronic_address_value
FROM leg_ct_th_ti
UNION ALL
SELECT
    hash_id('SCMS_CTCK_CHI_NHANH', leg_ct_ch_nh.ip_code) AS involved_party_id,
    leg_ct_ch_nh.ip_code :: string                       AS involved_party_code,
    'SCMS_CTCK_CHI_NHANH' :: string                      AS source_system_code,
    leg_ct_ch_nh.type_code :: string                     AS electronic_address_type_code,
    leg_ct_ch_nh.address_value :: string                 AS electronic_address_value
FROM leg_ct_ch_nh
UNION ALL
SELECT
    hash_id('SCMS_CTCK_NHAN_SU_CAO_CAP', leg_ct_nh_su_ca_ca.ip_code) AS involved_party_id,
    leg_ct_nh_su_ca_ca.ip_code :: string                             AS involved_party_code,
    'SCMS_CTCK_NHAN_SU_CAO_CAP' :: string                            AS source_system_code,
    leg_ct_nh_su_ca_ca.type_code :: string                           AS electronic_address_type_code,
    leg_ct_nh_su_ca_ca.address_value :: string                       AS electronic_address_value
FROM leg_ct_nh_su_ca_ca
UNION ALL
SELECT
    hash_id('SCMS_CT_KIEM_TOAN', leg_ct_ki_to.ip_code) AS involved_party_id,
    leg_ct_ki_to.ip_code :: string                     AS involved_party_code,
    'SCMS_CT_KIEM_TOAN' :: string                      AS source_system_code,
    leg_ct_ki_to.type_code :: string                   AS electronic_address_type_code,
    leg_ct_ki_to.address_value :: string               AS electronic_address_value
FROM leg_ct_ki_to
UNION ALL
SELECT
    hash_id('SCMS_CTCK_PHONG_GIAO_DICH', leg_ct_ph_gi_di.ip_code) AS involved_party_id,
    leg_ct_ph_gi_di.ip_code :: string                             AS involved_party_code,
    'SCMS_CTCK_PHONG_GIAO_DICH' :: string                         AS source_system_code,
    leg_ct_ph_gi_di.type_code :: string                           AS electronic_address_type_code,
    leg_ct_ph_gi_di.address_value :: string                       AS electronic_address_value
FROM leg_ct_ph_gi_di
UNION ALL
SELECT
    hash_id('SCMS_CTCK_VP_DAI_DIEN', leg_ct_vp_da_di.ip_code) AS involved_party_id,
    leg_ct_vp_da_di.ip_code :: string                         AS involved_party_code,
    'SCMS_CTCK_VP_DAI_DIEN' :: string                         AS source_system_code,
    leg_ct_vp_da_di.type_code :: string                       AS electronic_address_type_code,
    leg_ct_vp_da_di.address_value :: string                   AS electronic_address_value
FROM leg_ct_vp_da_di
;
