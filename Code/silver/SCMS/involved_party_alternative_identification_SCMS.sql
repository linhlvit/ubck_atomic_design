/*
*--------------------------------------------------------------------*
* Program code: involved_party_alternative_identification_SCMS
* Program name: Involved Party Alternative Identification SCMS
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH leg_ct_ki_to AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CT_KIEM_TOAN
    LATERAL VIEW stack(2,
        'GIAY PHEP KINH DOANH', giay_phep_kinh_doanh,
        'NOI CAP GPKD', noi_cap_gpkd
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_ng_ha_ng_ck AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_NGUOI_HANH_NGHE_CK
    LATERAL VIEW stack(1,
        'SO GIAY TO', so_giay_to
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_nh_su_ca_ca AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_NHAN_SU_CAO_CAP
    LATERAL VIEW stack(2,
        'SO CMND', so_cmnd,
        'NOI CAP', noi_cap
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_co_do AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_CO_DONG
    LATERAL VIEW stack(2,
        'SO CMND', so_cmnd,
        'NOI CAP', noi_cap
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_ki_to_vi AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CT_KIEM_TOAN_VIEN
    LATERAL VIEW stack(2,
        'SO CHUNG CHI', so_chung_chi,
        'SO CHUNG CHI', so_chung_chi
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_cd_da_di AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_CD_DAI_DIEN
    LATERAL VIEW stack(2,
        'SO CMND', so_cmnd,
        'NOI CAP', noi_cap
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_cd_mo_qu_he AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_CD_MOI_QUAN_HE
    LATERAL VIEW stack(2,
        'SO CMND', so_cmnd,
        'NOI CAP', noi_cap
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_th_ti AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_THONG_TIN
    LATERAL VIEW stack(2,
        'GIAY PHEP KINH DOANH', giay_phep_kinh_doanh,
        'NOI CAP GPKD', noi_cap_gpkd
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
)

SELECT
    hash_id('SCMS_CT_KIEM_TOAN', leg_ct_ki_to.ip_code) AS involved_party_id,
    leg_ct_ki_to.ip_code :: string                     AS involved_party_code,
    'SCMS_CT_KIEM_TOAN' :: string                      AS source_system_code,
    leg_ct_ki_to.type_code :: string                   AS identification_type_code,
    leg_ct_ki_to.address_value :: string               AS identification_number
FROM leg_ct_ki_to
UNION ALL
SELECT
    hash_id('SCMS_CTCK_NGUOI_HANH_NGHE_CK', leg_ct_ng_ha_ng_ck.ip_code) AS involved_party_id,
    leg_ct_ng_ha_ng_ck.ip_code :: string                                AS involved_party_code,
    'SCMS_CTCK_NGUOI_HANH_NGHE_CK' :: string                            AS source_system_code,
    leg_ct_ng_ha_ng_ck.type_code :: string                              AS identification_type_code,
    leg_ct_ng_ha_ng_ck.address_value :: string                          AS identification_number
FROM leg_ct_ng_ha_ng_ck
UNION ALL
SELECT
    hash_id('SCMS_CTCK_NHAN_SU_CAO_CAP', leg_ct_nh_su_ca_ca.ip_code) AS involved_party_id,
    leg_ct_nh_su_ca_ca.ip_code :: string                             AS involved_party_code,
    'SCMS_CTCK_NHAN_SU_CAO_CAP' :: string                            AS source_system_code,
    leg_ct_nh_su_ca_ca.type_code :: string                           AS identification_type_code,
    leg_ct_nh_su_ca_ca.address_value :: string                       AS identification_number
FROM leg_ct_nh_su_ca_ca
UNION ALL
SELECT
    hash_id('SCMS_CTCK_CO_DONG', leg_ct_co_do.ip_code) AS involved_party_id,
    leg_ct_co_do.ip_code :: string                     AS involved_party_code,
    'SCMS_CTCK_CO_DONG' :: string                      AS source_system_code,
    leg_ct_co_do.type_code :: string                   AS identification_type_code,
    leg_ct_co_do.address_value :: string               AS identification_number
FROM leg_ct_co_do
UNION ALL
SELECT
    hash_id('SCMS_CT_KIEM_TOAN_VIEN', leg_ct_ki_to_vi.ip_code) AS involved_party_id,
    leg_ct_ki_to_vi.ip_code :: string                          AS involved_party_code,
    'SCMS_CT_KIEM_TOAN_VIEN' :: string                         AS source_system_code,
    leg_ct_ki_to_vi.type_code :: string                        AS identification_type_code,
    leg_ct_ki_to_vi.address_value :: string                    AS identification_number
FROM leg_ct_ki_to_vi
UNION ALL
SELECT
    hash_id('SCMS_CTCK_CD_DAI_DIEN', leg_ct_cd_da_di.ip_code) AS involved_party_id,
    leg_ct_cd_da_di.ip_code :: string                         AS involved_party_code,
    'SCMS_CTCK_CD_DAI_DIEN' :: string                         AS source_system_code,
    leg_ct_cd_da_di.type_code :: string                       AS identification_type_code,
    leg_ct_cd_da_di.address_value :: string                   AS identification_number
FROM leg_ct_cd_da_di
UNION ALL
SELECT
    hash_id('SCMS_CTCK_CD_MOI_QUAN_HE', leg_ct_cd_mo_qu_he.ip_code) AS involved_party_id,
    leg_ct_cd_mo_qu_he.ip_code :: string                            AS involved_party_code,
    'SCMS_CTCK_CD_MOI_QUAN_HE' :: string                            AS source_system_code,
    leg_ct_cd_mo_qu_he.type_code :: string                          AS identification_type_code,
    leg_ct_cd_mo_qu_he.address_value :: string                      AS identification_number
FROM leg_ct_cd_mo_qu_he
UNION ALL
SELECT
    hash_id('SCMS_CTCK_THONG_TIN', leg_ct_th_ti.ip_code) AS involved_party_id,
    leg_ct_th_ti.ip_code :: string                       AS involved_party_code,
    'SCMS_CTCK_THONG_TIN' :: string                      AS source_system_code,
    leg_ct_th_ti.type_code :: string                     AS identification_type_code,
    leg_ct_th_ti.address_value :: string                 AS identification_number
FROM leg_ct_th_ti
;
