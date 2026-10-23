# Danh sách trường Classification Value có comment `SCHEMA_CODE=...`

Quét `DataModel/working/Atomic/lld/**/lld_*.yaml` ngày 2026-10-23. Tổng: **241** trường, **111** bảng nguồn.

| # | Bảng nguồn | Entity (bảng Atomic) | Tên trường (physical) | Attribute name | SCHEMA_CODE | Note | design_status |
|---|---|---|---|---|---|---|---|
| 1 | AUDIT.AF_APPROVAL | af_approval | approval_target_tp_code | Approval Target Type Code | `AUDIT.AF_TARGET_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_TARGET_TYPE'). | approved |
| 2 | AUDIT.AF_APPROVAL | af_approval | approval_src_tp_code | Approval Source Type Code | `AUDIT.AF_AUTHORITY` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_AUTHORITY'). | approved |
| 3 | AUDIT.AF_AUDITOR_PROFILES | af_auditor | position_title_code | Position Title Code | `AUDIT.POSITION` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='POSITION'). | approved |
| 4 | AUDIT.AF_AUDITOR_PROFILES | af_auditor | auditor_status_code | Auditor Status Code | `AUDIT.AF_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_STATUS'). | approved |
| 5 | AUDIT.AF_AUDITOR_PROFILES | af_auditor | approval_status_code | Approval Status Code | `AUDIT.PROFILE_APPROVAL_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='PROFILE_APPROVAL_STATUS'). | approved |
| 6 | AUDIT.AF_AUDITOR_STATUS_HISTORY | af_auditor_status_history | event_tp_code | Event Type Code | `AUDIT.AF_AUDITOR_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_AUDITOR_STATUS'). | approved |
| 7 | AUDIT.AF_INSPECTION | af_inspection | inspection_authority_code | Inspection Authority Code | `AUDIT.AF_AUTHORITY` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_AUTHORITY'). | approved |
| 8 | AUDIT.AF_INSPECTION | af_inspection | inspection_result_code | Inspection Result Code | `AUDIT.AF_INSPECTION_RESULT` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_INSPECTION_RESULT'). | approved |
| 9 | AUDIT.AF_INSPECTION | af_inspection | audit_technical_result_code | Audit Technical Result Code | `AUDIT.AF_INSPECTION_RESULT` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_INSPECTION_RESULT'). | approved |
| 10 | AUDIT.AF_INSPECTION | af_inspection | overall_result_code | Overall Result Code | `AUDIT.AF_INSPECTION_RESULT` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_INSPECTION_RESULT'). | approved |
| 11 | AUDIT.AF_INSPECTION | af_inspection | overall_action_code | Overall Action Code | `AUDIT.AF_AUDIT_CODE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_AUDIT_CODE'). | approved |
| 12 | AUDIT.AF_INSPECTION | af_inspection | overall_action_tp_code | Overall Action Type Code | `AUDIT.AF_ACTION_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_ACTION_TYPE'). | approved |
| 13 | AUDIT.AF_LEGAL_REPRESENTATIVE | af_legal_representative | position_title_code | Position Title Code | `AUDIT.POSITION` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='POSITION'). | approved |
| 14 | AUDIT.AF_PROFILES | audit_firm | af_status_code | Audit Firm Status Code | `AUDIT.AF_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_STATUS'). | approved |
| 15 | AUDIT.AF_PROFILES | audit_firm | approval_status_code | Approval Status Code | `AUDIT.PROFILE_APPROVAL_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='PROFILE_APPROVAL_STATUS'). | approved |
| 16 | AUDIT.AF_SANCTIONS | af_sanction | sanction_authority_code | Sanction Authority Code | `AUDIT.AF_AUTHORITY` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_AUTHORITY'). | approved |
| 17 | AUDIT.AF_STATUS_HISTORY | af_status_history | status_tp_code | Status Type Code | `AUDIT.AF_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_STATUS'). | approved |
| 18 | AUDIT.AF_SUSPENSION | af_suspension | suspension_src_tp_code | Suspension Source Type Code | `AUDIT.AF_AUTHORITY` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_AUTHORITY'). | approved |
| 19 | AUDIT.AF_SUSPENSION | af_suspension | suspension_tp_code | Suspension Type Code | `AUDIT.AF_ACTION_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_ACTION_TYPE'). | approved |
| 20 | AUDIT.AF_TECHNICAL_AUDIT | af_technical_audit | action_tp_code | Action Type Code | `AUDIT.AF_INSPECTION_RESULT` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_INSPECTION_RESULT'). | approved |
| 21 | AUDIT.AF_TECHNICAL_AUDIT | af_technical_audit | leadership_inspection_result_code | Leadership Inspection Result Code | `AUDIT.AF_INSPECTION_RESULT` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_INSPECTION_RESULT'). | approved |
| 22 | AUDIT.AF_TECHNICAL_AUDIT | af_technical_audit | leadership_audit_action_code | Leadership Audit Action Code | `AUDIT.AF_AUDIT_ACTION` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_AUDIT_ACTION'). | approved |
| 23 | AUDIT.AF_TECHNICAL_AUDIT | af_technical_audit | inspection_unit_code | Inspection Unit Code | `AUDIT.AF_INSPECTION_UNIT` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_INSPECTION_UNIT'). | approved |
| 24 | AUDIT.AF_TECHNICAL_AUDIT | af_technical_audit | consider_next_year_processing_code | Consider Next Year Processing Code | `AUDIT.AF_NEXT_YEAR_PROCESSING` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_NEXT_YEAR_PROCESSING'). | approved |
| 25 | AUDIT.AF_TECHNICAL_AUDIT | af_technical_audit | leadership_consider_next_year_processing_code | Leadership Consider Next Year Processing Code | `AUDIT.AF_NEXT_YEAR_PROCESSING` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_NEXT_YEAR_PROCESSING'). | approved |
| 26 | AUDIT.AF_WARNING | af_warning | warning_target_tp_code | Warning Target Type Code | `AUDIT.AF_TARGET_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_TARGET_TYPE'). | approved |
| 27 | AUDIT.AF_WARNING | af_warning | warning_src_tp_code | Warning Source Type Code | `AUDIT.AF_AUTHORITY` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_AUTHORITY'). | approved |
| 28 | AUDIT.AF_WARNING | af_warning | warning_tp_code | Warning Type Code | `AUDIT.AF_ACTION_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='AF_ACTION_TYPE'). | approved |
| 29 | FIMS.INVESTOR | foreign_investor | investor_object_tp_code | Investor Object Type Code | `FIMS.OBJECT_TYPE` |  | approved |
| 30 | FIMS.INVESTOR | foreign_investor | gender_code | Gender Code | `GENDER` |  | approved |
| 31 | FMS.FOR_BRCH | foreign_fm_ou | ou_tp_code | Organization Unit Type Code | `FMS.ORGANIZATION_UNIT_TYPE` |  | approved |
| 32 | FMS.INSIDER | fmc_insider | insider_tp_code | Insider Type Code | `FMS.INSIDER_TYPE` |  | approved |
| 33 | FMS.INSIDER | fmc_insider | employment_status_code | Employment Status Code | `FMS.EMPLOYMENT_STATUS` | ETL map: 1=ACTIVE;2=EXPIRED;3=INDEFINITE. | approved |
| 34 | FMS.INVES | discretionary_investment_investor | organization_territory_tp_code | Organization Territory Type Code | `FMS.ORGANIZATION_TERRITORY_TYPE` | ETL derived: 1=DOMESTIC;2=FOREIGN. | approved |
| 35 | FMS.OFFERING | fmc_securities_offering | offering_tp_code | Offering Type Code | `FMS.OFFERING_TYPE` |  | approved |
| 36 | FMS.OFFERING | fmc_securities_offering | securities_tp_code | Securities Type Code | `FMS.SECURITIES_OFFERING_TYPE` |  | approved |
| 37 | FMS.OFFERING | fmc_securities_offering | data_src_code | Data Source Code | `FMS_OFFERING_DATA_SOURCE` |  | approved |
| 38 | FMS.OFFERING | fmc_securities_offering | stock_class_code | Stock Class Code | `FMS.STOCK_CLASS` |  | approved |
| 39 | FMS.OFFERING | fmc_securities_offering | bond_tp_code | Bond Type Code | `FMS_BOND_TYPE` |  | approved |
| 40 | FMS.OFFERING_PLAN | fmc_securities_offering_plan | offering_method_code | Offering Method Code | `FMS_STOCK_OFFERING_PLAN_METHOD` |  | approved |
| 41 | FMS.RANK | member_rating | rating_period_tp_code | Rating Period Type Code | `FMS.RANK_TYPE` |  | approved |
| 42 | FMS.RATING_PD | member_rating_period | rating_period_tp_code | Rating Period Type Code | `FMS.RATING_PD.PERIOD_TYPE` |  | approved |
| 43 | FMS.REPRESENT | investment_fund_representative_board_member | board_member_tp_code | Board Member Type Code | `FMS.BOARD_MEMBER_TYPE` | ETL map: 1=INDIVIDUAL_REPRESENTATIVE;2=ORGANIZATION_REPRESENTATIVE. | approved |
| 44 | FMS.RPT_MEMBER | fmr_submission | rpt_tp_code | Report Type Code | `FMS.REPORT_TYPE` |  | approved |
| 45 | FMS.RPT_MEMBER | fmr_submission | period_tp_code | Period Type Code | `FMS.PERIOD_TYPE` |  | approved |
| 46 | FMS.RPT_PERIOD | fmr_period | period_tp_code | Period Type Code | `FMS.PERIOD_TYPE` |  | approved |
| 47 | FMS.RPT_TEMP | fund_management_report | fmr_tp_code | Fund Management Report Type Code | `FMS.REPORT_TYPE` |  | approved |
| 48 | FMS.RPT_TEMP | fund_management_report | rpt_group_code | Report Group Code | `FMS.REPORT_GROUP` |  | approved |
| 49 | FMS.RPT_TEMP | fund_management_report | stm_object_tp_code | System Object Type Code | `FMS.SYSTEM_OBJECTS` |  | approved |
| 50 | FMS.RPT_VALUES | fmr_value | period_tp_code | Period Type Code | `FMS.PERIOD_TYPE` |  | approved |
| 51 | FMS.SECURITIES | fund_management_company | exchange_code | Exchange Code | `FMS.STOCK_EXCHANGE` |  | approved |
| 52 | FMS.STATUS | cl_fms_status | object_tp_code | Object Type Code | `FMS.SYSTEM_OBJECT` |  | approved |
| 53 | FMS.STF_FG_BRCH | foreign_fm_ou_staff | staff_branch_tp_code | Staff Branch Type Code | `FMS.ORGANIZATION_UNIT_TYPE` |  | approved |
| 54 | FMS.STF_FG_BRCH | foreign_fm_ou_staff | gender_code | Gender Code | `GENDER` |  | approved |
| 55 | FMS.TL_PROFILES | fmc_employee | gender_code | Gender Code | `GENDER` |  | approved |
| 56 | IAM.USERS | identity_and_access_management_user | individual_gender_code | Individual Gender Code | `GENDER` |  | approved |
| 57 | IAM.USERS | identity_and_access_management_user | ip_tp_code | Involved Party Type Code | `IAM.USER_TYPE` |  | approved |
| 58 | IDS.COMPANY_DATA | pc_report_submission | approval_status_code | Approval Status Code | `IDS.NEWS_APPROVAL_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='NEWS_APPROVAL_STATUS'). | approved |
| 59 | IDS.COMPANY_DATA | pc_report_submission | news_tp_code | News Type Code | `IDS.NEWS_TYPE_CD` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='NEWS_TYPE'). | approved |
| 60 | IDS.COMPANY_ENTITY_ROLE | pc_entity_role | role_tp_code | Role Type Code | `IDS.ENTITY_ROLE_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='ENTITY_ROLE_TYPE'). | approved |
| 61 | IDS.COMPANY_INSPECTION | pc_inspection | inspection_tp_code | Inspection Type Code | `IDS.INSPECTION_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='INSPECTION_TYPE'). | approved |
| 62 | IDS.COMPANY_INSPECTION | pc_inspection | inspection_mode_code | Inspection Mode Code | `IDS.INSPECTION_MODE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='INSPECTION_MODE'). | approved |
| 63 | IDS.COMPANY_PENALTIES | pc_penalty | penalized_subject_tp_code | Penalized Subject Type Code | `IDS.PENALIZED_SUBJECT_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='PENALIZED_SUBJECT_TYPE'). | approved |
| 64 | IDS.COMPANY_PENALTIES | pc_penalty | investor_position_code | Investor Position Code | `IDS.POSITION` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='POSITION'). | approved |
| 65 | IDS.COMPANY_PROFILES | public_company | enterprise_tp_code | Enterprise Type Code | `IDS.ENTERPRISE_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='ENTERPRISE_TYPE'). | approved |
| 66 | IDS.COMPANY_PROFILES | public_company | financial_statement_tp_code | Financial Statement Type Code | `IDS.FINANCIAL_STATEMENT_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='FINANCIAL_STATEMENT_TYPE'). Dữ liệu dạng list (HN, ME) | approved |
| 67 | IDS.COMPANY_PROFILES | public_company | securities_tp_code | Securities Type Code | `IDS.SECURITIES_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SECURITIES_TYPE'). | approved |
| 68 | IDS.COMPANY_PROFILES | public_company | exchange_code | Exchange Code | `IDS.EXCHANGE_CODE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='EQUITY_LISTING_EXCH'). | approved |
| 69 | IDS.COMPANY_PROFILES | public_company | bond_exchange_code | Bond Exchange Code | `IDS.EXCHANGE_CODE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='EQUITY_LISTING_EXCH'). | approved |
| 70 | IDS.COMPANY_PROFILES | public_company | pc_status_code | Public Company Status Code | `IDS.PUBLIC_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='STATUS_IDS'). | approved |
| 71 | IDS.COMPANY_PROFILES | public_company | pc_form_tp_code | Public Company Form Type Code | `IDS.PUBLIC_COMPANY_FORM_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='PUBLIC_COMPANY_FORM'). | approved |
| 72 | IDS.COMPANY_PROFILES | public_company | pc_tp_code | Public Company Type Code | `IDS.PUBLIC_COMPANY_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='PUBLIC_COM_TYPE'). | approved |
| 73 | IDS.COMPANY_PROFILES | public_company | approval_status_code | Approval Status Code | `IDS.SO_APPROVAL_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_APPROVAL_STATUS'). | approved |
| 74 | IDS.COMPANY_RELATIONSHIP | pc_related_entity | rltnp_tp_code | Relationship Type Code | `IDS.COMPANY_RELATIONSHIP_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='COMPANY_RELATIONSHIP_TYPE'). | approved |
| 75 | IDS.COMPANY_SHAREHOLDING | pc_shareholding | shareholder_tp_code | Shareholder Type Code | `IDS.SHAREHOLDER_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SHAREHOLDER_TYPE'). | approved |
| 76 | IDS.COMPANY_TENDER_OFFER | pc_tender_offer | exchange_code | Exchange Code | `IDS.EXCHANGE_CODE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='EQUITY_LISTING_EXCH'). | approved |
| 77 | IDS.COMPANY_TENDER_OFFER | pc_tender_offer | ap_code | Administrative Procedure Code | `IDS.SO_ADMINISTRATIVE_PROCEDURE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_ADMINISTRATIVE_PROCEDURE'). | approved |
| 78 | IDS.COMPANY_TENDER_OFFER | pc_tender_offer | approval_status_code | Approval Status Code | `IDS.SO_APPROVAL_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_APPROVAL_STATUS'). | approved |
| 79 | IDS.COMPANY_TENDER_OFFER | pc_tender_offer | administrative_status_code | Administrative Status Code | `IDS.SO_ADMINISTRATIVE_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_ADMINISTRATIVE_STATUS'). | approved |
| 80 | IDS.COMPANY_TENDER_OFFER_RESULT | pc_tender_offer_result | approval_status_code | Approval Status Code | `IDS.SO_APPROVAL_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_APPROVAL_STATUS'). | approved |
| 81 | IDS.COMPANY_TREASURY_SHARES | pc_treasury_share_transaction | transaction_tp_code | Transaction Type Code | `IDS.SO_TRANSACTION_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_TRANSACTION_TYPE'). | approved |
| 82 | IDS.COMPANY_TREASURY_SHARES | pc_treasury_share_transaction | approval_status_code | Approval Status Code | `IDS.SO_APPROVAL_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_APPROVAL_STATUS'). | approved |
| 83 | IDS.COMPANY_TREASURY_SHARES | pc_treasury_share_transaction | administrative_status_code | Administrative Status Code | `IDS.SO_ADMINISTRATIVE_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_ADMINISTRATIVE_STATUS'). | approved |
| 84 | IDS.COMPANY_TREASURY_SHARES | pc_treasury_share_transaction | ap_code | Administrative Procedure Code | `IDS.SO_ADMINISTRATIVE_PROCEDURE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_ADMINISTRATIVE_PROCEDURE'). | approved |
| 85 | IDS.DATA | fr_value | rpt_catalog_tp_code | Report Catalog Type Code | `IDS.REPORT_CATALOG_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='RC_TYPE'). | approved |
| 86 | IDS.EVALUATIONS | pc_evaluation | evaluation_tp_code | Evaluation Type Code | `IDS.EVALUATION_RANK` |  | approved |
| 87 | IDS.EVALUATIONS | pc_evaluation | approval_status_code | Approval Status Code | `IDS.NEWS_APPROVAL_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='NEWS_APPROVAL_STATUS'). | approved |
| 88 | IDS.EVALUATION_DETAILS | pc_evaluation_detail | evaluation_level_code | Evaluation Level Code | `IDS.EVALUATION_LEVEL` | Values: 1-Bình thường, 2- Cảnh báo, 3- Rủi ro. | approved |
| 89 | IDS.EVALUATION_PERIODS | pc_evaluation_period | approval_status_code | Approval Status Code | `IDS.NEWS_APPROVAL_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='NEWS_APPROVAL_STATUS'). | approved |
| 90 | IDS.FORMS | financial_report | news_tp_code | News Type Code | `IDS.NEWS_TYPE_CD` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='NEWS_TYPE'). | approved |
| 91 | IDS.FORMS | financial_report | news_sub_tp_code | News Sub Type Code | `IDS.SUB_NEWS_TYPE_CD` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SUB_NEWS_TYPE'). | approved |
| 92 | IDS.FORMS | financial_report | form_group_tp_code | Form Group Type Code | `IDS.FORM_GROUP_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='FORM_GROUP'). | approved |
| 93 | IDS.FORMS | financial_report | rpt_tp_code | Report Type Code | `IDS.REPORT_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='REPORT_TYPE'). | approved |
| 94 | IDS.FORMS | financial_report | control_unit_code | Control Unit Code | `ECAT.DEPARTMENT` |  | approved |
| 95 | IDS.FORMS | financial_report | operating_unit_code | Operating Unit Code | `ECAT.DEPARTMENT` |  | approved |
| 96 | IDS.HOLDER_RELATIONSHIP | stock_holder_relationship | rltnp_tp_code | Relationship Type Code | `IDS.RELATIONSHIP_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='RELATIONSHIP_TYPE'). | approved |
| 97 | IDS.IDENTITY | ip_alternative_identification | identification_tp_code | Identification Type Code | `IDS.IDENTITY_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='IDENTITY_TYPE'). | approved |
| 98 | IDS.LEGAL_ENTITIES | legal_entity | legal_entity_tp_code | Legal Entity Type Code | `IDS.LEGAL_ENTITY_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='ENTITY_TYPE'). | approved |
| 99 | IDS.LEGAL_ENTITIES | legal_entity | identification_tp_code | Identification Type Code | `IDS.IDENTITY_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='IDENTITY_TYPE'). | approved |
| 100 | IDS.LEGAL_ENTITIES | legal_entity | gender_code | Gender Code | `GENDER` |  | approved |
| 101 | IDS.LEGAL_ENTITIES | legal_entity | individual_education_level_code | Individual Education Level Code | `IDS.EDUCATION_LEVEL` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='EDUCATION_LEVEL'). | approved |
| 102 | IDS.LEGAL_REPRESENTATIVE | pc_legal_representative | position_code | Position Code | `IDS.POSITION` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='POSITION'). | approved |
| 103 | IDS.POSITIONS | legal_entity_position | position_code | Position Code | `IDS.POSITION` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='POSITION'). | approved |
| 104 | IDS.PUB_COMPANY_CANCELLATION | pc_cancellation | approval_status_code | Approval Status Code | `IDS.NEWS_APPROVAL_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='NEWS_APPROVAL_STATUS'). | approved |
| 105 | IDS.PUB_COMPANY_REGISTRATION | pc_registration | approval_status_code | Approval Status Code | `IDS.NEWS_APPROVAL_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='NEWS_APPROVAL_STATUS'). | approved |
| 106 | IDS.RCOL | fr_column | column_tp_code | Column Type Code | `IDS.REPORT_ROW` | /COL_TYPE. Values load từ LOOKUP_VALUES (LOOKUP_GROUP='REPORT_ROW_TYPE'). | approved |
| 107 | IDS.RCOL | fr_column | rpt_catalog_tp_code | Report Catalog Type Code | `IDS.REPORT_CATALOG_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='RC_TYPE'). | approved |
| 108 | IDS.REPORT_CATALOG | fr_catalog | rpt_catalog_tp_code | Report Catalog Type Code | `IDS.REPORT_CATALOG_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='RC_TYPE'). | approved |
| 109 | IDS.REPORT_CATALOG | fr_catalog | fr_scope_tp_code | Financial Report Scope Type Code | `IDS.REPORT_SCOPE_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='REPORT_SCOPE'). | approved |
| 110 | IDS.REPORT_CATALOG | fr_catalog | enterprise_tp_code | Enterprise Type Code | `IDS.ENTERPRISE_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='ENTERPRISE_TYPE'). | approved |
| 111 | IDS.REPORT_CATALOG | fr_catalog | financial_statement_tp_code | Financial Statement Type Code | `IDS.FINANCIAL_STATEMENT_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='FINANCIAL_STATEMENT_TYPE'). | approved |
| 112 | IDS.REPORT_CATALOG | fr_catalog | reporting_period_tp_code | Reporting Period Type Code | `IDS.REPORT_PERIOD_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='REPORT_PERIOD_TYPE'). | approved |
| 113 | IDS.REPORT_CATALOG | fr_catalog | financial_statement_component_tp_code | Financial Statement Component Type Code | `IDS.FINANCIAL_STATEMENT_COMPONENT_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='FINANCIAL_STATEMENT_COMPONENT'). | approved |
| 114 | IDS.REP_COLUMN | ufr_column | column_data_tp_code | Column Data Type Code | `IDS.RF_C_DATA_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='RF_C_DATA_TYPE'). | approved |
| 115 | IDS.REP_DATA | ufr_value | column_data_tp_code | Column Data Type Code | `IDS.RF_C_DATA_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='RF_C_DATA_TYPE'). | approved |
| 116 | IDS.REP_DATA | ufr_value | row_data_tp_code | Row Data Type Code | `IDS.RF_R_DATA_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='RF_R_DATA_TYPE'). | approved |
| 117 | IDS.REP_FORMS | unstructured_financial_report | ufr_tp_code | Unstructured Financial Report Type Code | `IDS.REPORT_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='REPORT_TYPE'). | approved |
| 118 | IDS.REP_ROW | ufr_row | row_data_tp_code | Row Data Type Code | `IDS.RF_R_DATA_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='RF_R_DATA_TYPE'). | approved |
| 119 | IDS.RROW | fr_row | row_tp_code | Row Type Code | `IDS.REPORT_ROW` | /COL_TYPE. Values load từ LOOKUP_VALUES (LOOKUP_GROUP='REPORT_ROW_TYPE'). | approved |
| 120 | IDS.RROW | fr_row | rpt_catalog_tp_code | Report Catalog Type Code | `IDS.REPORT_CATALOG_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='RC_TYPE'). | approved |
| 121 | IDS.SECURITIES_OFFERING | pc_securities_offering | legal_entity_tp_code | Legal Entity Type Code | `IDS.LEGAL_ENTITY_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='ENTITY_TYPE'). Xử lý CASE WHEN APPLICANT_TYPE_FLG = 1 THEN 'TC' WHEN APPLICANT_TYPE_FLG = 2 THEN 'CN' END. | approved |
| 122 | IDS.SECURITIES_OFFERING | pc_securities_offering | ap_code | Administrative Procedure Code | `IDS.SO_ADMINISTRATIVE_PROCEDURE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_ADMINISTRATIVE_PROCEDURE'). | approved |
| 123 | IDS.SECURITIES_OFFERING | pc_securities_offering | administrative_status_code | Administrative Status Code | `IDS.SO_ADMINISTRATIVE_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_ADMINISTRATIVE_STATUS'). | approved |
| 124 | IDS.SECURITIES_OFFERING | pc_securities_offering | approval_status_code | Approval Status Code | `IDS.SO_APPROVAL_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_APPROVAL_STATUS'). | approved |
| 125 | IDS.SECURITIES_OFFERING_PLAN | pc_securities_offering_plan | offering_method_code | Offering Method Code | `IDS.SO_OFFERING_METHOD` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_OFFERING_METHOD'). | approved |
| 126 | IDS.SECURITIES_OFFERING_PLAN | pc_securities_offering_plan | distribution_method_code | Distribution Method Code | `IDS.SO_DISTRIBUTION_METHOD` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_DISTRIBUTION_METHOD'). | approved |
| 127 | IDS.SECURITIES_OFFERING_PLAN | pc_securities_offering_plan | security_tp_code | Security Type Code | `IDS.SO_SECURITY_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_SECURITY_TYPE'). | approved |
| 128 | IDS.SECURITIES_OFFERING_RESULT | pc_securities_offering_result | offering_method_code | Offering Method Code | `IDS.SO_OFFERING_METHOD` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_OFFERING_METHOD'). | approved |
| 129 | IDS.SECURITIES_OFFERING_RESULT | pc_securities_offering_result | security_tp_code | Security Type Code | `IDS.SO_SECURITY_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_SECURITY_TYPE'). | approved |
| 130 | IDS.STOCK_CONTROLS | stock_control | restriction_tp_code | Restriction Type Code | `IDS.RESTRICTION_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='RESTRICTION_TYPE'). | approved |
| 131 | IDS.STOCK_LISTING_HISTORY | pc_stock_listing_history | stock_listing_action_tp_code | Stock Listing Action Type Code | `IDS.STOCK_LISTING_ACTION_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='PUB_COM_LISTING_ACTION_TYPE'). | approved |
| 132 | IDS.STOCK_LISTING_HISTORY | pc_stock_listing_history | exchange_code | Exchange Code | `IDS.EXCHANGE_CODE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='EXCHANGE'). | approved |
| 133 | IDS.TREASURY_SHARE_TRANS_RESULT | pc_treasury_share_transaction_result | approval_status_code | Approval Status Code | `IDS.SO_APPROVAL_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='SO_APPROVAL_STATUS'). | approved |
| 134 | IDS.VIOLATION_REPORT | violation_report | period_quarter_tp_code | Period Quarter Type Code | `IDS.PERIOD_QUARTER_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='QUARTER_CODE'). | approved |
| 135 | IDS.VIOLATION_REPORT | violation_report | submission_status_code | Submission Status Code | `IDS.VIOLATION_SUBMISSION_STATUS` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='VIOLATION_STATUS'). | approved |
| 136 | IDS.VIOLATION_TEMPLATES | vr_template | vr_tp_code | Violation Report Type Code | `IDS.VIOLATION_REPORT_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='VIOLATION_TYPE'). | approved |
| 137 | IDS.VIOLATION_TEMPLATES | vr_template | vr_sub_tp_code | Violation Report Sub Type Code | `IDS.VIOLATION_REPORT_SUBTYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='VIOLATION_SUBTYPE'). | approved |
| 138 | IDS.VIOLATION_TEMPLATES | vr_template | news_tp_code | News Type Code | `IDS.NEWS_TYPE_CD` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='NEWS_TYPE'). | approved |
| 139 | IDS.VIOLATION_TEMPLATES | vr_template | fr_scope_tp_code | Financial Report Scope Type Code | `IDS.REPORT_SCOPE_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='REPORT_SCOPE'). | approved |
| 140 | IDS.VIOLATION_TEMPLATES | vr_template | period_tp_code | Period Type Code | `IDS.REPORT_PERIOD_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='REPORT_PERIOD_TYPE'). | approved |
| 141 | IDS.VIOLATION_TEMPLATES | vr_template | violation_trigger_point_code | Violation Trigger Point Code | `IDS.VIOLATION_TRIGGER_POINT` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='VIOLATION_TRIGGER_POINT'). | approved |
| 142 | IDS.VIOLATION_TEMPLATES | vr_template | violation_trigger_point_extended_code | Violation Trigger Point Extended Code | `IDS.VIOLATION_TRIGGER_POINT` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='VIOLATION_TRIGGER_POINT'). | approved |
| 143 | IDS.VIOLATION_TEMPLATES | vr_template | day_tp_code | Day Type Code | `IDS.DAY_TYPE` | Values load từ LOOKUP_VALUES (LOOKUP_GROUP='DAY_TYPE'). | approved |
| 144 | MDDS.JAD_CSIDXINFOR | index_constituent_snapshot | floor_code | Floor Code | `MDDS.FLOOR_CODE` |  | approved |
| 145 | MDDS.JAD_MARKETINFOR | market_index_snapshot | exchange_code | Exchange Code | `MDDS.EXCHANGE_CODE` |  | approved |
| 146 | MDDS.JAD_STOCKINFOR | security_trading_snapshot | floor_code | Floor Code | `MDDS.FLOOR_CODE` |  | approved |
| 147 | MRMS.RISK_INDICATOR | cl_risk_indicator | risk_ind_category_code | Risk Indicator Category Code | `MRMS.RISK_INDICATOR_CATEGORY` |  | approved |
| 148 | MRMS.RISK_INDICATOR | cl_risk_indicator | set_tp_code | Set Type Code | `MRMS.SET_TYPE` |  | approved |
| 149 | MRMS.RISK_INDICATOR | cl_risk_indicator | period_tp_code | Period Type Code | `MRMS.PERIOD_TYPE` |  | approved |
| 150 | MRMS.RISK_INDICATOR | cl_risk_indicator | unit_tp_code | Unit Type Code | `MRMS.UNIT_TYPE` |  | approved |
| 151 | MRMS.RISK_INDICATOR | cl_risk_indicator | data_src_tp_code | Data Source Type Code | `MRMS.SOURCE_SYSTEM_TYPE` |  | approved |
| 152 | MRMS.RISK_INDICATOR_VALUE | cl_risk_indicator_value | period_tp_code | Period Type Code | `MRMS.PERIOD_TYPE` |  | approved |
| 153 | MRMS.RISK_INDICATOR_VALUE | cl_risk_indicator_value | unit_tp_code | Unit Type Code | `MRMS.UNIT_TYPE` |  | approved |
| 154 | MRMS.RISK_INDICATOR_VALUE | cl_risk_indicator_value | data_src_tp_code | Data Source Type Code | `MRMS.SOURCE_SYSTEM_TYPE` |  | approved |
| 155 | MRMS.RISK_INDICATOR_VALUE | cl_risk_indicator_value | data_origin_tp_code | Data Origin Type Code | `MRMS.DATA_ORIGIN_TYPE` |  | approved |
| 156 | NHNCK.APPLICATIONS | sp_license_application | application_tp_code | Application Type Code | `NHNCK.APPLICATIONS.APPLICATION_TYPE` |  | approved |
| 157 | NHNCK.APPLICATIONS | sp_license_application | application_status_code | Application Status Code | `NHNCK.APPLICATION_STATUSES` |  | approved |
| 158 | NHNCK.APPLICATIONS | sp_license_application | registration_tp_code | Registration Type Code | `NHNCK.APPLICATIONS.REGISTRATION_TYPE` |  | approved |
| 159 | NHNCK.APPLICATIONS | sp_license_application | certificate_receipt_method_code | Certificate Receipt Method Code | `NHNCK.APPLICATIONS.CERTIFICATE_RECEIPT_METHOD` |  | approved |
| 160 | NHNCK.APPLICATION_FEES | sp_license_application_fee | fee_tp_code | Fee Type Code | `NHNCK.APPLICATION_FEES.FEE_TYPE` |  | approved |
| 161 | NHNCK.APPLICATION_FEES | sp_license_application_fee | status_code | Status Code | `NHNCK.APPLICATION_FEES.STATUS` |  | approved |
| 162 | NHNCK.APPLICATION_GROUPS | sp_license_application_group | application_tp_code | Application Type Code | `NHNCK.APPLICATIONS.APPLICATION_TYPE` |  | approved |
| 163 | NHNCK.APPLICATION_GROUPS | sp_license_application_group | status_code | Status Code | `NHNCK.APPLICATION_GROUPS.STATUS` |  | approved |
| 164 | NHNCK.APPLICATION_RE_EXAMS | sp_license_application_re_exam_request | status_code | Status Code | `NHNCK.APPLICATION_RE_EXAMS.STATUS` |  | approved |
| 165 | NHNCK.APPLICATION_SPECIALIZATIONS | sp_license_application_education_certificate_document | specialization_code | Specialization Code | `NHNCK.SPECIALIZATIONS` |  | approved |
| 166 | NHNCK.APPLICATION_SPECIALIZATIONS | sp_license_application_education_certificate_document | status_code | Status Code | `NHNCK.APPLICATION_SPECIALIZATIONS.STATUS` |  | approved |
| 167 | NHNCK.CERTIFICATE_DEPARTMENTS | ra_organization_unit_x_sp_license_certificate_type_relationship | department_code | Department Code | `NHNCK.DEPARTMENTS` | Cần ETL crosswalk sang NHNCK.DEPARTMENTS: CERTIFICATE_DEPARTMENTS.DEPARTMENT_ID = DEPARTMENTS.ID để xác nhận DEPARTMENT_CODE. | approved |
| 168 | NHNCK.CERTIFICATE_RECORDS | sp_license_certificate_document | process_status_code | Process Status Code | `NHNCK.CERTIFICATE_RECORDS.PROCESS_STATUS` |  | approved |
| 169 | NHNCK.CERTIFICATE_RECORDS | sp_license_certificate_document | conversion_status_code | Conversion Status Code | `NHNCK.CERTIFICATE_RECORDS.CONVERSION_STATUS` |  | approved |
| 170 | NHNCK.CERTIFICATE_RECORDS | sp_license_certificate_document | status_code | Status Code | `NHNCK.CERTIFICATE_RECORDS.STATUS` |  | approved |
| 171 | NHNCK.CERTIFICATE_RECORD_GROUPS | sp_license_certificate_group | group_tp_code | Group Type Code | `NHNCK.CERTIFICATE_RECORD_GROUPS.TYPE` |  | approved |
| 172 | NHNCK.CERTIFICATE_RECORD_GROUPS | sp_license_certificate_group | status_code | Status Code | `NHNCK.CERTIFICATE_RECORD_GROUPS.STATUS` |  | approved |
| 173 | NHNCK.CERTIFICATE_RECORD_STATUS_HISTORIES | sp_license_certificate_status_change_history | old_certificate_status_code | Old Certificate Status Code | `NHNCK.CERTIFICATE_RECORDS.STATUS` |  | approved |
| 174 | NHNCK.CERTIFICATE_RECORD_STATUS_HISTORIES | sp_license_certificate_status_change_history | new_certificate_status_code | New Certificate Status Code | `NHNCK.CERTIFICATE_RECORDS.STATUS` |  | approved |
| 175 | NHNCK.CERTIFICATE_SPECIALIZATIONS | sp_license_certificate_type_x_cl_specialization_relationship | specialization_code | Specialization Code | `NHNCK.SPECIALIZATIONS` |  | approved |
| 176 | NHNCK.CERTIFICATE_SPECIALIZATIONS | sp_license_certificate_type_x_cl_specialization_relationship | document_tp_code | Document Type Code | `NHNCK.CERTIFICATE_SPECIALIZATIONS.DOCUMENT_TYPE` |  | approved |
| 177 | NHNCK.DECISIONS | sp_license_decision_document | decision_tp_code | Decision Type Code | `NHNCK.DECISIONS.DECISION_TYPE_ID` |  | approved |
| 178 | NHNCK.DECISION_DOCUMENTS | sp_license_decision_document_attachment | attachment_tp_code | Attachment Type Code | `NHNCK.DECISION_DOCUMENTS.TYPE` |  | approved |
| 179 | NHNCK.DECISION_DOCUMENTS | sp_license_decision_document_attachment | status_code | Status Code | `NHNCK.DECISION_DOCUMENTS.STATUS` |  | approved |
| 180 | NHNCK.EXAM_DETAILS | sp_qualification_examination_assessment_result | law_result_code | Law Result Code | `EXAM_RESULT` |  | approved |
| 181 | NHNCK.EXAM_DETAILS | sp_qualification_examination_assessment_result | specialization_result_code | Specialization Result Code | `NHNCK.EXAM_DETAILS.RESULT` |  | approved |
| 182 | NHNCK.EXAM_DETAILS | sp_qualification_examination_assessment_result | overall_result_code | Overall Result Code | `NHNCK.EXAM_DETAILS.RESULT` |  | approved |
| 183 | NHNCK.EXAM_SESSIONS | sp_qualification_examination_assessment | bank_code | Bank Code | `NHNCK.BANKS` | Cần ETL crosswalk sang NHNCK.BANKS: EXAM_SESSIONS.BANK_ID = BANKS.ID để xác nhận NHNCK.BANKS.BANK_CODE, sau đó lưu BANK_CODE (không lưu ID kỹ thuật) vào cột này. | approved |
| 184 | NHNCK.EXAM_SESSIONS | sp_qualification_examination_assessment | status_code | Status Code | `NHNCK.EXAM_SESSIONS.STATUS` |  | approved |
| 185 | NHNCK.ORGANIZATIONS | securities_organization_reference | organization_tp_code | Organization Type Code | `NHNCK.ORGANIZATIONS.ORGANIZATIONS_TYPE` |  | approved |
| 186 | NHNCK.ORGANIZATIONS | securities_organization_reference | sync_status_code | Sync Status Code | `NHNCK.ORGANIZATIONS.SYNC_STATUS` |  | approved |
| 187 | NHNCK.ORGANIZATIONS | securities_organization_reference | status_code | Status Code | `NHNCK.ORGANIZATIONS.STATUS` |  | approved |
| 188 | NHNCK.ORGANIZATION_REPORTS | sp_organization_employment_report | organization_status_code_at_rpt | Organization Status Code At Report | `NHNCK.ORGANIZATION_REPORTS.STATUS` |  | approved |
| 189 | NHNCK.ORGANIZATION_REPORTS | sp_organization_employment_report | status_code | Status Code | `NHNCK.ORGANIZATION_REPORTS.STATUS` |  | approved |
| 190 | NHNCK.ORGANIZATION_REPORTS | sp_organization_employment_report | rpt_tp_code | Report Type Code | `NHNCK.ORGANIZATION_REPORTS.TYPE` |  | approved |
| 191 | NHNCK.ORGANIZATION_REPORT_YEARLYS | sp_organization_annual_report | rpt_tp_code | Report Type Code | `NHNCK.ORGANIZATION_REPORT_YEARLYS.TYPE` |  | approved |
| 192 | NHNCK.ORGANIZATION_REPORT_YEARLYS | sp_organization_annual_report | status_code | Status Code | `NHNCK.ORGANIZATION_REPORT_YEARLYS.STATUS` |  | approved |
| 193 | NHNCK.POST_CERT_TRAINING_RESULTS | sp_post_certification_training_result | training_result_status_code | Training Result Status Code | `NHNCK.POST_CERT_TRAINING_RESULTS.RESULT_STATUS` |  | approved |
| 194 | NHNCK.PROFESSIONALS | securities_practitioner | gender_code | Gender Code | `GENDER` |  | approved |
| 195 | NHNCK.PROFESSIONALS | securities_practitioner | education_level_code | Education Level Code | `NHNCK.EDUCATION_LEVELS` |  | approved |
| 196 | NHNCK.PROFESSIONALS | securities_practitioner | practitioner_registration_tp_code | Practitioner Registration Type Code | `NHNCK.APPLICATIONS.REGISTRATION_TYPE` |  | approved |
| 197 | NHNCK.PROFESSIONALS | securities_practitioner | practice_status_code | Practice Status Code | `NHNCK.PROFESSIONALS.STATUS_WORK` |  | approved |
| 198 | NHNCK.PROFESSIONALS | securities_practitioner | account_status_code | Account Status Code | `NHNCK.PROFESSIONALS.STATUS_ACCOUNT` |  | approved |
| 199 | NHNCK.PROFESSIONALS | securities_practitioner | sso_sync_status_code | SSO Sync Status Code | `NHNCK.PROFESSIONALS.SSO_SYNCED` |  | approved |
| 200 | NHNCK.PROFESSIONALS | securities_practitioner | status_code | Status Code | `NHNCK.PROFESSIONALS.STATUS` |  | approved |
| 201 | NHNCK.PROFESSIONAL_RELATIONSHIPS | sp_related_party | rltnp_tp_code | Relationship Type Code | `NHNCK.PROFESSIONAL_RELATIONSHIPS.RELATIONSHIP_TYPE` |  | approved |
| 202 | NHNCK.PROFESSIONAL_WORK_HISTORIES | sp_employment_status | position_code | Position Code | `NHNCK.POSITIONS` | Cần ETL crosswalk sang NHNCK.POSITIONS: PROFESSIONAL_WORK_HISTORIES.POSITION_ID = POSITIONS.ID để xác nhận NHNCK.POSITIONS.POSITION_CODE, sau đó lưu POSITION_CODE (không lưu ID kỹ thuật) vào cột này. | approved |
| 203 | NHNCK.SPECIALIZATION_COURSES | sp_professional_training_class | specialization_code | Specialization Code | `NHNCK.SPECIALIZATIONS` |  | approved |
| 204 | NHNCK.SPECIALIZATION_COURSE_DETAILS | sp_professional_training_class_enrollment | specialization_code | Specialization Code | `NHNCK.SPECIALIZATIONS` |  | approved |
| 205 | NHNCK.SPECIALIZATION_COURSE_DETAILS | sp_professional_training_class_enrollment | identification_tp_code | Identification Type Code | `IDENTIFICATION_DOCUMENT_TYPE` |  | approved |
| 206 | NHNCK.SPECIALIZATION_COURSE_DETAILS | sp_professional_training_class_enrollment | training_result_code | Training Result Code | `NHNCK.EXAM_DETAILS.RESULT` |  | approved |
| 207 | NHNCK.VERIFY_APPLICATION_STATUSES | sp_license_application_status_review | application_status_code | Application Status Code | `NHNCK.APPLICATION_STATUSES` |  | approved |
| 208 | NHNCK.VERIFY_APPLICATION_STATUSES | sp_license_application_status_review | previous_application_status_code | Previous Application Status Code | `NHNCK.APPLICATION_STATUSES` |  | approved |
| 209 | NHNCK.VERIFY_APPLICATION_STATUSES | sp_license_application_status_review | status_code | Status Code | `NHNCK.VERIFY_APPLICATION_STATUSES.STATUS` |  | approved |
| 210 | NHNCK.VIOLATIONS | sp_violation | violation_status_code | Violation Status Code | `NHNCK.VIOLATIONS.STATUS` |  | approved |
| 211 | NHNCK.VIOLATIONS | sp_violation | violation_tp_code | Violation Type Code | `NHNCK.VIOLATIONS.TYPE` |  | approved |
| 212 | SCMS.CAT_EVENT_TYPE | cl_securities_company_event_type | obligation_tp_code | Obligation Type Code | `SCMS.CAT_EVENT_TYPE.OBLIGATION_TYPE` |  | approved |
| 213 | SCMS.CAT_EVENT_TYPE | cl_securities_company_event_type | event_category_code | Event Category Code | `SCMS.GROUP_EVENT_TYPE` |  | approved |
| 214 | SCMS.CAT_EVENT_TYPE | cl_securities_company_event_type | deadline_calculation_method_code | Deadline Calculation Method Code | `SCMS.CAT_EVENT_TYPE.DEADLINE_CALCULATION_METHOD` |  | approved |
| 215 | SCMS.CAT_SERVICE_LEGAL_CAPITAL | cl_securities_company_firm_service | application_tp_code | Application Type Code | `SCMS.CAT_SERVICE_LEGAL_CAPITAL.APPLICATION_TYPE` |  | approved |
| 216 | SCMS.FORM_INDICATOR_INPUT | sc_report_indicator | data_tp_code | Data Type Code | `SCMS.FORM_SHEET.DATA_TYPE` |  | approved |
| 217 | SCMS.FORM_REPORT | sc_report | rpt_group | Report Group | `SCMS.REPORT_GROUP` |  | approved |
| 218 | SCMS.FORM_REPORT | sc_report | rpt_style_code | Report Style Code | `SCMS.FORM_REPORT.REPORT_STYLE` |  | approved |
| 219 | SCMS.FORM_REPORT | sc_report | disclosure_news_tp_code | Disclosure News Type Code | `SCMS.GROUP_EVENT_TYPE` |  | approved |
| 220 | SCMS.FORM_REPORT | sc_report | signature_tp_code | Signature Type Code | `SCMS.FORM_REPORT.SIGNATURE_TYPE` |  | approved |
| 221 | SCMS.FORM_SHEET | sc_report_sheet | rpt_style_code | Report Style Code | `SCMS.FORM_SHEET.REPORT_STYLE` |  | approved |
| 222 | SCMS.FORM_SHEET | sc_report_sheet | record_tp_code | Record Type Code | `SCMS.FORM_SHEET.RECORD_TYPE` |  | approved |
| 223 | SCMS.FORM_SHEET_CELL | sc_report_sheet_cell | style_format_code | Style Format Code | `SCMS.FORM_SHEET.TEXT_FORMATTING` |  | approved |
| 224 | SCMS.FORM_SHEET_CELL | sc_report_sheet_cell | filter_code | Filter Code | `SCMS.CAT_FILTER` | Cần ETL crosswalk sang SCMS.CAT_FILTER: FORM_SHEET_CELL.FILTER_ID = CAT_FILTER.ID để xác nhận CODE, sau đó lưu CODE vào cột này. | approved |
| 225 | SCMS.FORM_SHEET_CELL | sc_report_sheet_cell | data_tp_code | Data Type Code | `SCMS.FORM_SHEET.DATA_TYPE` |  | approved |
| 226 | SCMS.FORM_SHEET_COLUMN | sc_report_sheet_column | nm_format_code | Name Format Code | `SCMS.FORM_SHEET.TEXT_FORMATTING` |  | approved |
| 227 | SCMS.FORM_SHEET_COLUMN | sc_report_sheet_column | data_tp_code | Data Type Code | `SCMS.FORM_SHEET.DATA_TYPE` |  | approved |
| 228 | SCMS.FORM_SHEET_ROW | sc_report_sheet_row | nm_format_code | Name Format Code | `SCMS.FORM_SHEET.TEXT_FORMATTING` |  | approved |
| 229 | SCMS.FORM_SHEET_ROW | sc_report_sheet_row | row_tp_code | Row Type Code | `SCMS.FORM_SHEET_ROW.ROW_TYPE` |  | approved |
| 230 | SCMS.SC_FIRM_ADHOC_REPORT | sc_adhoc_report | rpt_submission_status_code | Report Submission Status Code | `SCMS.SC_FIRM_REPORT.RECORD_STATUS` |  | approved |
| 231 | SCMS.SC_FIRM_INFO | securities_company | company_tp_code | Company Type Code | `SCMS.CAT_COMPANY_TYPE` | Cần ETL crosswalk sang SCMS.CAT_COMPANY_TYPE: SC_FIRM_INFO.COMPANY_TYPE_ID = CAT_COMPANY_TYPE.ID để xác nhận COMPANY_TYPE_CODE. | approved |
| 232 | SCMS.SC_FIRM_INSIDER_RELATION | sc_insider_related_person | gender_code | Gender Code | `GENDER` |  | approved |
| 233 | SCMS.SC_FIRM_PERIODIC_REPORT | sc_periodic_report | rpt_submission_status_code | Report Submission Status Code | `SCMS.SC_FIRM_REPORT.RECORD_STATUS` |  | approved |
| 234 | SCMS.SC_FIRM_RELATED_PERSON | sc_related_person | gender_code | Gender Code | `GENDER` |  | approved |
| 235 | SCMS.SC_FIRM_SENIOR_PERSONNEL | sc_senior_personnel | gender_code | Gender Code | `GENDER` |  | approved |
| 236 | TTHC.AP_DOCUMENT | ap_document | processing_status_code | Processing Status Code | `TTHC.PROCESSING_STATUS` | Nguồn thực: Document.Content->'HoSoTTHC'->'TrangThaiHoSo'->ContentItemIds[0]. | approved |
| 237 | TTHC.AP_DOCUMENT | ap_document | processing_authority_code | Processing Authority Code | `TTHC.PROCESSING_AUTHORITY` | Nguồn thực: Document.Content->'HoSoTTHC'->'CoQuanXuLy'->ContentItemIds[0]. | approved |
| 238 | TTHC.AP_DOCUMENT | ap_document | document_tp_code | Document Type Code | `TTHC.DOCUMENT_TYPE` | Nguồn thực: Document.Content->'HoSoTTHC'->'LoaiHoSo'->ContentItemIds[0]. | approved |
| 239 | TTHC.AP_DOCUMENT | ap_document | domain_code | Domain Code | `TTHC.DOMAIN` | Nguồn thực: Document.Content->'HoSoTTHC'->'LinhVucTTHC'->ContentItemIds[0]. | approved |
| 240 | TTHC.AP_DOCUMENT | ap_document | priority_level_code | Priority Level Code | `TTHC.PRIORITY_LEVEL` | Nguồn thực: Document.Content->'HoSoTTHC'->'MucDoTTHC'->ContentItemIds[0]. | approved |
| 241 | TTHC.AP_DOCUMENT | ap_document | reception_channel_code | Reception Channel Code | `TTHC.RECEPTION_CHANNEL` | Nguồn thực: Document.Content->'HoSoTTHC'->'KenhTiepNhan'->ContentItemIds[0]. | approved |
