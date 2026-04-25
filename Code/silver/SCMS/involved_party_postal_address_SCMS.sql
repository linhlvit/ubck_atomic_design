/*
*--------------------------------------------------------------------*
* Program code: involved_party_postal_address_SCMS
* Program name: Involved Party Postal Address SCMS
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
        'ADDRESS', dia_chi,
        'TINH THANH ID', tinh_thanh_id,
        'QUAN HUYEN', quan_huyen,
        'PHUONG XA', phuong_xa
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_ch_nh AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_CHI_NHANH
    LATERAL VIEW stack(4,
        'ADDRESS', dia_chi,
        'QUAN HUYEN', quan_huyen,
        'PHUONG XA', phuong_xa,
        'TINH THANH ID', tinh_thanh_id
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_nh_su_ca_ca AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_NHAN_SU_CAO_CAP
    LATERAL VIEW stack(1,
        'ADDRESS', dia_chi
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_co_do AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_CO_DONG
    LATERAL VIEW stack(2,
        'DIA CHI HIEN TAI', dia_chi_hien_tai,
        'HO KHAU THUONG TRU', ho_khau_thuong_tru
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_ki_to AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CT_KIEM_TOAN
    LATERAL VIEW stack(1,
        'ADDRESS', dia_chi
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_ph_gi_di AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_PHONG_GIAO_DICH
    LATERAL VIEW stack(4,
        'TINH THANH ID', tinh_thanh_id,
        'QUAN HUYEN', quan_huyen,
        'PHUONG XA', phuong_xa,
        'ADDRESS', dia_chi
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
),

leg_ct_vp_da_di AS (
    SELECT id AS ip_code, type_code, address_value
    FROM bronze.CTCK_VP_DAI_DIEN
    LATERAL VIEW stack(4,
        'TINH THANH ID', tinh_thanh_id,
        'QUAN HUYEN', quan_huyen,
        'PHUONG XA', phuong_xa,
        'ADDRESS', dia_chi
    ) AS (type_code, address_value)
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND address_value IS NOT NULL
)

SELECT
    hash_id('SCMS_CTCK_THONG_TIN', leg_ct_th_ti.ip_code) AS involved_party_id,
    leg_ct_th_ti.ip_code :: string                       AS involved_party_code,
    'SCMS_CTCK_THONG_TIN' :: string                      AS source_system_code,
    leg_ct_th_ti.type_code :: string                     AS address_type_code,
    leg_ct_th_ti.address_value :: string                 AS address_value
FROM leg_ct_th_ti
UNION ALL
SELECT
    hash_id('SCMS_CTCK_CHI_NHANH', leg_ct_ch_nh.ip_code) AS involved_party_id,
    leg_ct_ch_nh.ip_code :: string                       AS involved_party_code,
    'SCMS_CTCK_CHI_NHANH' :: string                      AS source_system_code,
    leg_ct_ch_nh.type_code :: string                     AS address_type_code,
    leg_ct_ch_nh.address_value :: string                 AS address_value
FROM leg_ct_ch_nh
UNION ALL
SELECT
    hash_id('SCMS_CTCK_NHAN_SU_CAO_CAP', leg_ct_nh_su_ca_ca.ip_code) AS involved_party_id,
    leg_ct_nh_su_ca_ca.ip_code :: string                             AS involved_party_code,
    'SCMS_CTCK_NHAN_SU_CAO_CAP' :: string                            AS source_system_code,
    leg_ct_nh_su_ca_ca.type_code :: string                           AS address_type_code,
    leg_ct_nh_su_ca_ca.address_value :: string                       AS address_value
FROM leg_ct_nh_su_ca_ca
UNION ALL
SELECT
    hash_id('SCMS_CTCK_CO_DONG', leg_ct_co_do.ip_code) AS involved_party_id,
    leg_ct_co_do.ip_code :: string                     AS involved_party_code,
    'SCMS_CTCK_CO_DONG' :: string                      AS source_system_code,
    leg_ct_co_do.type_code :: string                   AS address_type_code,
    leg_ct_co_do.address_value :: string               AS address_value
FROM leg_ct_co_do
UNION ALL
SELECT
    hash_id('SCMS_CT_KIEM_TOAN', leg_ct_ki_to.ip_code) AS involved_party_id,
    leg_ct_ki_to.ip_code :: string                     AS involved_party_code,
    'SCMS_CT_KIEM_TOAN' :: string                      AS source_system_code,
    leg_ct_ki_to.type_code :: string                   AS address_type_code,
    leg_ct_ki_to.address_value :: string               AS address_value
FROM leg_ct_ki_to
UNION ALL
SELECT
    hash_id('SCMS_CTCK_PHONG_GIAO_DICH', leg_ct_ph_gi_di.ip_code) AS involved_party_id,
    leg_ct_ph_gi_di.ip_code :: string                             AS involved_party_code,
    'SCMS_CTCK_PHONG_GIAO_DICH' :: string                         AS source_system_code,
    leg_ct_ph_gi_di.type_code :: string                           AS address_type_code,
    leg_ct_ph_gi_di.address_value :: string                       AS address_value
FROM leg_ct_ph_gi_di
UNION ALL
SELECT
    hash_id('SCMS_CTCK_VP_DAI_DIEN', leg_ct_vp_da_di.ip_code) AS involved_party_id,
    leg_ct_vp_da_di.ip_code :: string                         AS involved_party_code,
    'SCMS_CTCK_VP_DAI_DIEN' :: string                         AS source_system_code,
    leg_ct_vp_da_di.type_code :: string                       AS address_type_code,
    leg_ct_vp_da_di.address_value :: string                   AS address_value
FROM leg_ct_vp_da_di
;
