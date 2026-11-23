/*
*--------------------------------------------------------------------*
* Program code: atm_sc_disclosure_securities_offering_result
* Program name: Atomic Securities Company Disclosure Securities Offering Result
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH dsor AS (
    SELECT
        id
        , sc_firm_info_id
        , offering_target
        , offering_method
        , par_val
        , planned_quantity
        , planned_price_amt
        , planned_value_at_par
        , planned_participant_count
        , offering_target_description
        , swap_purpose_description
        , expected_start_dt
        , expected_end_dt
        , actual_quantity
        , actual_price_amt
        , actual_val_amt
        , actual_participant_count
        , foreign_investor_participant_count
        , foreign_investor_issuance_val
    FROM {{ ref('ods_scms_disclosure_securities_offering_result') }}
)

, sc_fi_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_DISCLOSURE_SECURITIES_OFFERING_RESULT', "concat_ws('-', dsor.id, dsor.offering_method, dsor.offering_target_code)") }} AS sc_disclosure_securities_offering_item_id
    , CAST(concat_ws('-', dsor.id, dsor.offering_method, dsor.offering_target_code) AS string) AS sc_disclosure_securities_offering_item_code
    , CAST('SCMS_DISCLOSURE_SECURITIES_OFFERING_RESULT' AS string)                             AS src_stm_code
    -- FK về bảng cha: cùng công thức với sc_disclosure_securities_offering_id của atm_sc_disclosure_securities_offering
    , {{ generate_surrogate_key_bigint('SCMS_DISCLOSURE_SECURITIES_OFFERING', "dsor.id") }}    AS sc_disclosure_securities_offering_id
    , CAST(dsor.id AS string)                                                                  AS sc_disclosure_securities_offering_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                AS sc_id
    , CAST(sc_fi_in.code AS string)                                                            AS sc_code
    , CAST(dsor.offering_target AS string)                                                     AS offering_target
    , CAST(dsor.offering_method AS string)                                                     AS offering_method
    , dsor.par_val                                                                             AS par_val
    , dsor.planned_quantity                                                                    AS planned_quantity
    , dsor.planned_price_amt                                                                   AS planned_price_amt
    , dsor.planned_value_at_par                                                                AS planned_value_at_par
    , dsor.planned_participant_count                                                           AS planned_participant_count
    , CAST(dsor.offering_target_description AS string)                                         AS offering_target_description
    , CAST(dsor.swap_purpose_description AS string)                                            AS swap_purpose_description
    , try_cast(dsor.expected_start_dt AS date)                                                 AS expected_start_dt
    , try_cast(dsor.expected_end_dt AS date)                                                   AS expected_end_dt
    , dsor.actual_quantity                                                                     AS actual_quantity
    , dsor.actual_price_amt                                                                    AS actual_price_amt
    , dsor.actual_val_amt                                                                      AS actual_val_amt
    , dsor.actual_participant_count                                                            AS actual_participant_count
    , dsor.foreign_investor_participant_count                                                  AS foreign_investor_participant_count
    , dsor.foreign_investor_issuance_val                                                       AS foreign_investor_issuance_val
FROM dsor
    LEFT JOIN sc_fi_in ON dsor.sc_firm_info_id = sc_fi_in.id
