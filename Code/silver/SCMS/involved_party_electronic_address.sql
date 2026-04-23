/*
*--------------------------------------------------------------------*
* Program code: involved_party_electronic_address
* Program name: Involved Party Electronic Address
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH leg_ct_th_ti AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.CTCK_THONG_TIN
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.CTCK_THONG_TIN
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        dien_thoai AS address_value,
        source_system_code
    FROM bronze.CTCK_THONG_TIN
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND dien_thoai IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'WEBSITE' AS type_code,
        website AS address_value,
        source_system_code
    FROM bronze.CTCK_THONG_TIN
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND website IS NOT NULL
),

leg_ct_ch_nh AS (
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.CTCK_CHI_NHANH
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        dien_thoai AS address_value,
        source_system_code
    FROM bronze.CTCK_CHI_NHANH
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND dien_thoai IS NOT NULL
),

leg_ct_nh_su_ca_ca AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.CTCK_NHAN_SU_CAO_CAP
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'EMAIL CONG BO TT' AS type_code,
        email_cong_bo_tt AS address_value,
        source_system_code
    FROM bronze.CTCK_NHAN_SU_CAO_CAP
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email_cong_bo_tt IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.CTCK_NHAN_SU_CAO_CAP
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        dien_thoai AS address_value,
        source_system_code
    FROM bronze.CTCK_NHAN_SU_CAO_CAP
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND dien_thoai IS NOT NULL
),

leg_ct_ki_to AS (
    SELECT
        id AS ip_code,
        'EMAIL' AS type_code,
        email AS address_value,
        source_system_code
    FROM bronze.CT_KIEM_TOAN
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND email IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.CT_KIEM_TOAN
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        dien_thoai AS address_value,
        source_system_code
    FROM bronze.CT_KIEM_TOAN
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND dien_thoai IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'WEBSITE' AS type_code,
        website AS address_value,
        source_system_code
    FROM bronze.CT_KIEM_TOAN
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND website IS NOT NULL
),

leg_ct_ph_gi_di AS (
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.CTCK_PHONG_GIAO_DICH
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        dien_thoai AS address_value,
        source_system_code
    FROM bronze.CTCK_PHONG_GIAO_DICH
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND dien_thoai IS NOT NULL
),

leg_ct_vp_da_di AS (
    SELECT
        id AS ip_code,
        'FAX' AS type_code,
        fax AS address_value,
        source_system_code
    FROM bronze.CTCK_VP_DAI_DIEN
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND fax IS NOT NULL
    UNION ALL
    SELECT
        id AS ip_code,
        'PHONE' AS type_code,
        dien_thoai AS address_value,
        source_system_code
    FROM bronze.CTCK_VP_DAI_DIEN
    WHERE data_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND dien_thoai IS NOT NULL
)

SELECT
    hash_id(leg_ct_th_ti.source_system_code, leg_ct_th_ti.ip_code) AS involved_party_id,
    leg_ct_th_ti.ip_code :: string                                 AS involved_party_code,
    leg_ct_th_ti.source_system_code :: string                      AS source_system_code,
    leg_ct_th_ti.type_code :: string                               AS electronic_address_type_code,
    leg_ct_th_ti.address_value :: string                           AS electronic_address_value
FROM leg_ct_th_ti
UNION ALL
SELECT
    hash_id(leg_ct_ch_nh.source_system_code, leg_ct_ch_nh.ip_code) AS involved_party_id,
    leg_ct_ch_nh.ip_code :: string                                 AS involved_party_code,
    leg_ct_ch_nh.source_system_code :: string                      AS source_system_code,
    leg_ct_ch_nh.type_code :: string                               AS electronic_address_type_code,
    leg_ct_ch_nh.address_value :: string                           AS electronic_address_value
FROM leg_ct_ch_nh
UNION ALL
SELECT
    hash_id(leg_ct_nh_su_ca_ca.source_system_code, leg_ct_nh_su_ca_ca.ip_code) AS involved_party_id,
    leg_ct_nh_su_ca_ca.ip_code :: string                                     AS involved_party_code,
    leg_ct_nh_su_ca_ca.source_system_code :: string                          AS source_system_code,
    leg_ct_nh_su_ca_ca.type_code :: string                                   AS electronic_address_type_code,
    leg_ct_nh_su_ca_ca.address_value :: string                               AS electronic_address_value
FROM leg_ct_nh_su_ca_ca
UNION ALL
SELECT
    hash_id(leg_ct_ki_to.source_system_code, leg_ct_ki_to.ip_code) AS involved_party_id,
    leg_ct_ki_to.ip_code :: string                                 AS involved_party_code,
    leg_ct_ki_to.source_system_code :: string                      AS source_system_code,
    leg_ct_ki_to.type_code :: string                               AS electronic_address_type_code,
    leg_ct_ki_to.address_value :: string                           AS electronic_address_value
FROM leg_ct_ki_to
UNION ALL
SELECT
    hash_id(leg_ct_ph_gi_di.source_system_code, leg_ct_ph_gi_di.ip_code) AS involved_party_id,
    leg_ct_ph_gi_di.ip_code :: string                                    AS involved_party_code,
    leg_ct_ph_gi_di.source_system_code :: string                         AS source_system_code,
    leg_ct_ph_gi_di.type_code :: string                                  AS electronic_address_type_code,
    leg_ct_ph_gi_di.address_value :: string                              AS electronic_address_value
FROM leg_ct_ph_gi_di
UNION ALL
SELECT
    hash_id(leg_ct_vp_da_di.source_system_code, leg_ct_vp_da_di.ip_code) AS involved_party_id,
    leg_ct_vp_da_di.ip_code :: string                                    AS involved_party_code,
    leg_ct_vp_da_di.source_system_code :: string                         AS source_system_code,
    leg_ct_vp_da_di.type_code :: string                                  AS electronic_address_type_code,
    leg_ct_vp_da_di.address_value :: string                              AS electronic_address_value
FROM leg_ct_vp_da_di
;
