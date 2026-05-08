# GSGD HLD — Overview

**Source system:** GSGD (Giám sát Giao dịch)  
**Mô tả:** Hệ thống giám sát giao dịch chứng khoán của UBCKNN. Quản lý tài khoản nhà đầu tư, nhóm tài khoản, vụ việc giám sát, phân tích dữ liệu bất thường, và báo cáo tuân thủ.

---

## 7a. Bảng tổng quan Atomic Entities

| Tier | BCV Core Object | BCV Concept | Category | Source Table | Mô tả bảng nguồn | Atomic Entity | table_type |
|---|---|---|---|---|---|---|---|
| T1 | Arrangement | [Arrangement] Trading Account Arrangement | Arrangement | investor_account | Thông tin tài khoản nhà đầu tư | Investor Trading Account | Fundamental |
| T1 | Group | [Involved Party] Group | Group | account_group | Nhóm tài khoản | Account Investor Group | Fundamental |
| T1 | Group | [Group] Portfolio | Group | securities_group | Nhóm chứng khoán | Securities Watchlist Group | Fundamental |
| T1 | Business Activity | [Business Activity] Audit Investigation | — | case_file | Vụ việc giám sát | Market Surveillance Case | Fundamental |
| T1 | Condition | [Condition] Criterion | — | analysis_attribute_define | Định nghĩa tiêu chí/công thức phân tích vụ việc | Market Surveillance Analysis Criterion | Fundamental |
| T1 | Documentation | [Documentation] Regulatory Report | — | abnormal_report | Báo cáo bất thường | Abnormal Trading Report | Fundamental |
| T1 | Condition | [Condition] | — | compliance_report_template | Danh sách các loại báo cáo tuân thủ | Market Surveillance Compliance Report Template | Fundamental |
| T2 | Arrangement | [Arrangement] Financial Market | — | account_financial_service | Dịch vụ tài chính của tài khoản | Investor Trading Account Financial Service | Relative |
| T2 | Arrangement | [Arrangement] Authorization | — | account_authorization | Thông tin ủy quyền tài khoản | Investor Trading Account Authorization | Relative |
| T2 | Group | [Involved Party] Involved Party Group Membership | Group | account_group_member | Thành viên nhóm tài khoản | Account Investor Group Member | Relative |
| T2 | Business Activity | [Business Activity] Audit Investigation | — | account_relationship | Mối quan hệ giữa các tài khoản | Investor Account Relationship | Relative |
| T2 | Documentation | [Documentation] Supporting Documentation | — | case_attach_file | File đính kèm vụ việc | Market Surveillance Case Document Attachment | Relative |
| T2 | Business Activity | ETL Pattern — Activity Log | — | case_file_workflow | Quy trình xử lý vụ việc | Market Surveillance Case Workflow Step | Fact Append |
| T2 | Business Activity | ETL Pattern — Activity Log | — | case_approval_step | Tiến trình gửi duyệt vụ việc | Market Surveillance Case Approval Step Log | Fact Append |
| T2 | Involved Party | [Involved Party] Involved Party Group Membership | — | suspicious_account | Tài khoản nghi vấn | Market Surveillance Suspicious Account | Relative |
| T2 | Involved Party | [Involved Party] Involved Party Group Membership | — | suspicious_account_group | Nhóm tài khoản nghi vấn | Market Surveillance Suspicious Account Group | Relative |
| T2 | Condition | [Condition] Criterion | — | analysis_attribute_value | Giá trị tiêu chí phân tích theo từng quy trình | Market Surveillance Analysis Criterion Value | Relative |
| T2 | Documentation | [Documentation] Regulatory Report | — | compliance_report_config | Định nghĩa cấu trúc bảng cho từng loại báo cáo tuân thủ | Market Surveillance Compliance Report Column Config | Relative |
| T2 | Documentation | [Documentation] Regulatory Report | — | compliance_report_master | Thông tin tổng hợp báo cáo tuân thủ theo kỳ | Market Surveillance Compliance Report Instance | Relative |
| T2 | Event | [Event] | — | company_event | Sự kiện tổ chức niêm yết | Listed Company Corporate Event | Fact Append |
| T3 | Documentation | [Documentation] Supporting Documentation | — | abnormal_report_file | File đính kèm báo cáo bất thường | Abnormal Trading Report File Attachment | Relative |
| T3 | Documentation | [Documentation] Reported Information | — | compliance_report_data | Dữ liệu chi tiết báo cáo tổng hợp | Market Surveillance Compliance Report Row Data | Fact Append |
| T3 | Business Activity | [Business Activity] Audit Investigation | — | analysis_execution_log | Thông tin trạng thái phân tích quy trình của từng biểu mẫu | Market Surveillance Analysis Execution Log | Fact Append |
| T3 | Business Activity | [Business Activity] Audit Investigation | — | analysis_suspicious_account_code | Thông tin tài khoản nghi vấn của từng biểu mẫu | Market Surveillance Analysis Suspicious Account Snapshot | Fact Append |
| T3 | Business Activity | [Business Activity] Audit Investigation | — | analysis_suspicious_account | Phân tích tài khoản nghi vấn | Market Surveillance Suspicious Account Analysis Result | Fact Append |
| T3 | Business Activity | [Business Activity] Audit Investigation | — | analysis_account_relationship | Phân tích mối quan hệ giữa các tài khoản nghi vấn | Market Surveillance Account Relationship Analysis Result | Fact Append |
| T3 | Business Activity | [Business Activity] Audit Investigation | — | analysis_account_group | Phân tích nhóm tài khoản | Market Surveillance Account Group Analysis Result | Fact Append |
| T3 | Business Activity | [Business Activity] Audit Investigation | — | analysis_account_group_member | Lịch sử thay đổi nhóm tài khoản trong phân tích | Market Surveillance Account Group Member Analysis Result | Fact Append |
| T3 | Documentation | [Documentation] Reported Information | — | analysis_report | Báo cáo kết quả phân tích vụ việc | Market Surveillance Analysis Report | Fact Append |

---

## 7b. Diagram Atomic tổng (Mermaid)

```mermaid
erDiagram
    %% === TIER 1 ===
    InvestorTradingAccount["Investor Trading Account"] {
        bigint id PK
        string account_code BK
        string investor_type_code
        string account_status_code
    }

    AccountInvestorGroup["Account Investor Group"] {
        bigint id PK
        string group_code BK
        string group_type_code
        string relation_type_code
    }

    SecuritiesWatchlistGroup["Securities Watchlist Group"] {
        bigint id PK
        string group_code BK
        array securities_codes
    }

    MarketSurveillanceCase["Market Surveillance Case"] {
        bigint id PK
        string case_code BK
        string case_type_code
        string case_status_code
    }

    MarketSurveillanceAnalysisCriterion["Market Surveillance Analysis Criterion"] {
        bigint id PK
        string criterion_code BK
        string workflow_type_code
        string data_type_code
    }

    AbnormalTradingReport["Abnormal Trading Report"] {
        bigint id PK
        string report_code BK
        string approval_status_code
    }

    MarketSurveillanceComplianceReportTemplate["Market Surveillance Compliance Report Template"] {
        bigint id PK
        string template_name
        string period_type_code
    }

    %% === TIER 2 ===
    InvestorTradingAccountFinancialService["Investor Trading Account Financial Service"] {
        bigint id PK
        bigint investor_trading_account_id FK
        string service_type_code
    }

    InvestorTradingAccountAuthorization["Investor Trading Account Authorization"] {
        bigint id PK
        bigint investor_trading_account_id FK
        string authorized_person_name
    }

    AccountInvestorGroupMember["Account Investor Group Member"] {
        bigint id PK
        bigint account_investor_group_id FK
        bigint investor_trading_account_id FK
        string relationship_type_code
    }

    InvestorAccountRelationship["Investor Account Relationship"] {
        bigint id PK
        bigint investor_trading_account_1_id FK
        bigint investor_trading_account_2_id FK
        bigint account_investor_group_id FK
        string relationship_type_code
        small_counter strength
    }

    MarketSurveillanceCaseDocumentAttachment["Market Surveillance Case Document Attachment"] {
        bigint id PK
        bigint market_surveillance_case_id FK
        string file_type_code
    }

    MarketSurveillanceCaseWorkflowStep["Market Surveillance Case Workflow Step"] {
        bigint id PK
        bigint market_surveillance_case_id FK
        string workflow_type_code
        small_counter step_order
    }

    MarketSurveillanceCaseApprovalStepLog["Market Surveillance Case Approval Step Log"] {
        bigint id PK
        bigint market_surveillance_case_id FK
        string step_code
        string step_status_code
        timestamp action_at
    }

    MarketSurveillanceSuspiciousAccount["Market Surveillance Suspicious Account"] {
        bigint id PK
        bigint market_surveillance_case_id FK
        bigint investor_trading_account_id FK
    }

    MarketSurveillanceSuspiciousAccountGroup["Market Surveillance Suspicious Account Group"] {
        bigint id PK
        bigint market_surveillance_case_id FK
        string relationship_criteria_code
    }

    MarketSurveillanceAnalysisCriterionValue["Market Surveillance Analysis Criterion Value"] {
        bigint id PK
        bigint market_surveillance_analysis_criterion_id FK
        string workflow_type_code
    }

    MarketSurveillanceComplianceReportColumnConfig["Market Surveillance Compliance Report Column Config"] {
        bigint id PK
        bigint market_surveillance_compliance_report_template_id FK
        string column_label
    }

    MarketSurveillanceComplianceReportInstance["Market Surveillance Compliance Report Instance"] {
        bigint id PK
        bigint market_surveillance_compliance_report_template_id FK
        string period_type_code
        string instance_status_code
    }

    ListedCompanyCorporateEvent["Listed Company Corporate Event"] {
        bigint id PK
        string company_name
        string securities_code
        date event_date
    }

    %% === TIER 3 ===
    AbnormalTradingReportFileAttachment["Abnormal Trading Report File Attachment"] {
        bigint id PK
        bigint abnormal_trading_report_id FK
        string file_name
    }

    MarketSurveillanceComplianceReportRowData["Market Surveillance Compliance Report Row Data"] {
        bigint id PK
        bigint market_surveillance_compliance_report_instance_id FK
        string row_data
    }

    MarketSurveillanceAnalysisExecutionLog["Market Surveillance Analysis Execution Log"] {
        bigint id PK
        bigint market_surveillance_case_id FK
        string workflow_type_code
        timestamp start_time
    }

    MarketSurveillanceAnalysisSuspiciousAccountSnapshot["Market Surveillance Analysis Suspicious Account Snapshot"] {
        bigint id PK
        bigint market_surveillance_case_id FK
        string account_code
        date analysis_date
    }

    MarketSurveillanceSuspiciousAccountAnalysisResult["Market Surveillance Suspicious Account Analysis Result"] {
        bigint id PK
        bigint market_surveillance_case_id FK
        string account_code
        date analysis_date
    }

    MarketSurveillanceAccountRelationshipAnalysisResult["Market Surveillance Account Relationship Analysis Result"] {
        bigint id PK
        bigint market_surveillance_case_id FK
        bigint investor_account_relationship_id FK
        date analysis_date
    }

    MarketSurveillanceAccountGroupAnalysisResult["Market Surveillance Account Group Analysis Result"] {
        bigint id PK
        bigint market_surveillance_case_id FK
        string group_code
        date analysis_date
    }

    MarketSurveillanceAccountGroupMemberAnalysisResult["Market Surveillance Account Group Member Analysis Result"] {
        bigint id PK
        bigint market_surveillance_case_id FK
        bigint account_investor_group_id FK
        bigint investor_account_relationship_id FK
        date analysis_date
    }

    MarketSurveillanceAnalysisReport["Market Surveillance Analysis Report"] {
        bigint id PK
        bigint market_surveillance_case_id FK
        string report_type_code
        date report_date
        string report_file_path
    }

    %% === RELATIONS ===
    InvestorTradingAccountFinancialService ||--o{ InvestorTradingAccount : "account"
    InvestorTradingAccountAuthorization ||--o{ InvestorTradingAccount : "account"
    AccountInvestorGroupMember ||--o{ AccountInvestorGroup : "group"
    AccountInvestorGroupMember ||--o{ InvestorTradingAccount : "account"
    InvestorAccountRelationship ||--o{ InvestorTradingAccount : "account_1"
    InvestorAccountRelationship ||--o{ InvestorTradingAccount : "account_2"
    InvestorAccountRelationship ||--o{ AccountInvestorGroup : "group"
    MarketSurveillanceCaseDocumentAttachment ||--o{ MarketSurveillanceCase : "case"
    MarketSurveillanceCaseWorkflowStep ||--o{ MarketSurveillanceCase : "case"
    MarketSurveillanceCaseApprovalStepLog ||--o{ MarketSurveillanceCase : "case"
    MarketSurveillanceSuspiciousAccount ||--o{ MarketSurveillanceCase : "case"
    MarketSurveillanceSuspiciousAccount ||--o{ InvestorTradingAccount : "account"
    MarketSurveillanceSuspiciousAccountGroup ||--o{ MarketSurveillanceCase : "case"
    MarketSurveillanceAnalysisCriterionValue ||--o{ MarketSurveillanceAnalysisCriterion : "criterion"
    MarketSurveillanceComplianceReportColumnConfig ||--o{ MarketSurveillanceComplianceReportTemplate : "template"
    MarketSurveillanceComplianceReportInstance ||--o{ MarketSurveillanceComplianceReportTemplate : "template"
    AbnormalTradingReportFileAttachment ||--o{ AbnormalTradingReport : "report"
    MarketSurveillanceComplianceReportRowData ||--o{ MarketSurveillanceComplianceReportInstance : "instance"
    MarketSurveillanceAnalysisExecutionLog ||--o{ MarketSurveillanceCase : "case"
    MarketSurveillanceAnalysisSuspiciousAccountSnapshot ||--o{ MarketSurveillanceCase : "case"
    MarketSurveillanceSuspiciousAccountAnalysisResult ||--o{ MarketSurveillanceCase : "case"
    MarketSurveillanceAccountRelationshipAnalysisResult ||--o{ MarketSurveillanceCase : "case"
    MarketSurveillanceAccountRelationshipAnalysisResult ||--o{ InvestorAccountRelationship : "relationship"
    MarketSurveillanceAccountGroupAnalysisResult ||--o{ MarketSurveillanceCase : "case"
    MarketSurveillanceAccountGroupMemberAnalysisResult ||--o{ MarketSurveillanceCase : "case"
    MarketSurveillanceAccountGroupMemberAnalysisResult ||--o{ AccountInvestorGroup : "group"
    MarketSurveillanceAccountGroupMemberAnalysisResult ||--o{ InvestorAccountRelationship : "relationship"
    MarketSurveillanceAnalysisReport ||--o{ MarketSurveillanceCase : "case"
```

---

## 7c. Bảng Classification Value

| Source Table | Mô tả | BCV Term | Xử lý Atomic |
|---|---|---|---|
| category_item (INVESTOR_TYPE) | Loại nhà đầu tư: Cá nhân / Tổ chức | Classification | `GSGD_INVESTOR_TYPE` |
| category_item (ACCOUNT_STATUS) | Trạng thái tài khoản | Classification | `GSGD_ACCOUNT_STATUS` |
| category_item (DOMESTIC_FOREIGN_FLAG) | Trong nước / Nước ngoài | Classification | `GSGD_DOMESTIC_FOREIGN_FLAG` |
| category_item (ACCOUNT_GROUP_TYPE) | Loại nhóm TK: Thường / Nghi vấn | Classification | `GSGD_ACCOUNT_GROUP_TYPE` |
| category_item (ACCOUNT_RELATION_TYPE) | Loại quan hệ: Danh tính / IP / MAC / Tiền | Classification | `GSGD_ACCOUNT_RELATION_TYPE` |
| category_item (SECURITIES_GROUP_TYPE) | Loại nhóm CK: Thường / Theo ngành | Classification | `GSGD_SECURITIES_GROUP_TYPE` |
| category_item (CASE_FILE_TYPE) | Loại vụ việc: Sơ bộ / Thao túng / Nội gián / Liên thị trường | Classification | `GSGD_CASE_TYPE` |
| category_item (CASE_FILE_STATUS) | Trạng thái vụ việc | Classification | `GSGD_CASE_STATUS` |
| category_item (INFORMATION_SOURCE) | Nguồn thông tin vụ việc | Classification | `GSGD_INFORMATION_SOURCE` |
| category_item (WORKFLOW_TYPE) | Loại quy trình phân tích | Classification | `GSGD_WORKFLOW_TYPE` |
| category_item (DATA_TYPE) | Kiểu dữ liệu tiêu chí | Classification | `GSGD_DATA_TYPE` |
| category_item (REPORT_TYPE) | Loại báo cáo bất thường | Classification | `GSGD_ABNORMAL_REPORT_TYPE` |
| category_item (PERIOD_TYPE) | Loại kỳ báo cáo | Classification | `GSGD_PERIOD_TYPE` |
| category_item (SUBMITTER_TYPE) | Loại người nộp | Classification | `GSGD_SUBMITTER_TYPE` |
| category_item (APPROVAL_STATUS) | Trạng thái phê duyệt | Classification | `GSGD_APPROVAL_STATUS` |
| category_item (SERVICE_TYPE) | Loại dịch vụ tài chính | Classification | `GSGD_FINANCIAL_SERVICE_TYPE` |
| category_item (FILE_TYPE) | Loại file đính kèm | Classification | `GSGD_FILE_TYPE` |
| category_item (FILE_GROUP) | Nhóm file đính kèm | Classification | `GSGD_FILE_GROUP` |
| category_item (STEP_CODE) | Mã bước phê duyệt | Classification | `GSGD_APPROVAL_STEP_CODE` |
| category_item (STEP_STATUS) | Trạng thái bước phê duyệt | Classification | `GSGD_APPROVAL_STEP_STATUS` |
| category_item (SUSPICIOUS_SOURCE) | Nguồn TK nghi vấn | Classification | `GSGD_SUSPICIOUS_SOURCE` |
| category_item (RELATIONSHIP_CRITERIA) | Tiêu chí phân nhóm nghi vấn | Classification | `GSGD_RELATIONSHIP_CRITERIA` |
| category_item (COMPANY_EVENT_TYPE) | Loại sự kiện tổ chức niêm yết | Classification | `GSGD_COMPANY_EVENT_TYPE` |
| category_item (EXECUTION_STATUS) | Trạng thái phân tích | Classification | `GSGD_EXECUTION_STATUS` |
| category_item (RESULT_TYPE) | Loại kết quả phân tích | Classification | `GSGD_RESULT_TYPE` |
| category_item (TEMPLATE_TYPE) | Loại biểu mẫu | Classification | `GSGD_TEMPLATE_TYPE` |
| category_item (ANALYSIS_REPORT_TYPE) | Loại báo cáo phân tích vụ việc | Classification | `GSGD_ANALYSIS_REPORT_TYPE` |

---

## 7d. Junction Tables

| Source Table | Mô tả | Entity chính | Xử lý trên Atomic |
|---|---|---|---|
| securities_group_member | Thành viên nhóm chứng khoán — 2 FK: group_id + securities_code_id | Securities Watchlist Group | Denormalize thành `Array<Text>` trên `Securities Watchlist Group`. Mỗi phần tử = 1 mã CK. securities_code ngoài scope không có surrogate key → chỉ Array<Text>. |
| analysis_define_report_template | Cấu hình biểu mẫu báo cáo phân tích — 2 FK: attribute_id + report_id (report_template ngoài scope) | — | **Ngoài scope Atomic** — thông tin cấu hình chạy báo cáo, không phải dữ liệu nghiệp vụ. |

---

## 7e. Điểm cần xác nhận

| # | Tier | Câu hỏi | Ảnh hưởng |
|---|---|---|---|
| 1 | T1 | `account_group.case_file_id` tạo circular dependency: account_group → case_file (và case_file liên quan account_group qua suspicious_account). Giữ Account Investor Group ở T1 (nullable FK) hay chuyển T2? | Đề xuất: giữ T1, case_file_id nullable. Account Investor Group tồn tại độc lập, chỉ liên kết case khi được gán. |
| 2 | T1 | ~~`investor_account` grain = 1 tài khoản hay 1 Involved Party?~~ **✅ RESOLVED:** Grain = 1 tài khoản → không tách shared entity IP. Các trường identity_number, contact_address, permanent_address, phone_number, email giữ **denormalized** trên `Investor Trading Account`. | — |
| 3 | T1 | `abnormal_report.submitter_id` — text không có FK đến entity Atomic. Cần link hay giữ denormalized? | Đề xuất: giữ denormalized cho đến khi có mapping tường minh. |
| 4 | T1 | ~~`case_file.securities_code_id` FK đến `securities_code` ngoài scope.~~ **✅ RESOLVED (pending dependency):** Giữ `securities_code` dạng **Text denormalized**. ⚠️ Cần xác nhận `securities_code` thuộc hệ thống nào (VSD/HoSE/HNX) để ghi nhận cross-system dependency khi LLD. | — |
| 5 | T1 | `compliance_report_template` có reuse entity `Report Template` Atomic hay tạo riêng? | Đề xuất: tạo riêng `Market Surveillance Compliance Report Template` — scope và cấu trúc khác. |
| 6 | T2 | `analysis_define_report_template` — pure junction giữa analysis_attribute_define và report_template (ngoài scope). Có cần Atomic entity? | Đề xuất: ngoài scope Atomic. |
| 7 | T2 | ~~`securities_group_member` — denormalize thành `Array<Text>` (securities_codes) trên `Securities Watchlist Group`.~~ **✅ RESOLVED:** Thêm `securities_codes ARRAY<Text>` vào `Securities Watchlist Group` (T1). Không tạo Atomic entity cho `securities_group_member`. | — |
| 8 | T2 | ~~`account_relationship.strength` — Small Counter hay Percentage?~~ **✅ RESOLVED:** Data domain = **Small Counter** (điểm tính 1-100, không phải %). | — |
| 9 | T3 | `analysis_execution_log` FK trực tiếp → case_file (T1). Có thể chuyển lên T2. | Chuyển T2 nếu muốn đơn giản hơn. |
| 10 | T3 | `compliance_report_data.row_data` là JSON blob không có schema ổn định. Có cần Atomic entity? | Đề xuất: giữ Atomic entity với row_data dạng Text (raw JSON). Cần xác nhận. |

---

## 7f. Bảng ngoài scope

| Nhóm | Source Table | Mô tả bảng nguồn | Lý do ngoài scope |
|---|---|---|---|
| Audit Log nguồn | investor_account_history | Lịch sử thay đổi tài khoản (OldValue/NewValue) | Audit Log nguồn — cơ chế ghi lịch sử đặc thù source system, không phải sự kiện nghiệp vụ |
| Audit Log nguồn | account_group_history | Lịch sử thay đổi nhóm tài khoản (OldValue/NewValue) | Audit Log nguồn — cơ chế ghi lịch sử đặc thù source system, không phải sự kiện nghiệp vụ |
| Audit Log nguồn | securities_group_history | Lịch sử thay đổi nhóm chứng khoán (OldValue/NewValue) | Audit Log nguồn — cơ chế ghi lịch sử đặc thù source system, không phải sự kiện nghiệp vụ |
| Audit Log nguồn | company_event_history | Lịch sử thay đổi sự kiện tổ chức niêm yết (OldValue/NewValue) | Audit Log nguồn — cơ chế ghi lịch sử đặc thù source system, không phải sự kiện nghiệp vụ |
| Operational / System | system_user | Người dùng hệ thống | Operational/system data — không có giá trị nghiệp vụ |
| Operational / System | user_group | Nhóm người dùng | Operational/system data — không có giá trị nghiệp vụ |
| Operational / System | user_group_member | Thành viên nhóm người dùng | Operational/system data — không có giá trị nghiệp vụ |
| Operational / System | system_permission | Quyền hệ thống | Operational/system data — không có giá trị nghiệp vụ |
| Operational / System | system_config | Cấu hình hệ thống | Operational/system data — không có giá trị nghiệp vụ |
| Operational / System | system_parameter | Tham số hệ thống | Operational/system data — không có giá trị nghiệp vụ |
| Operational / System | audit_log | Nhật ký hệ thống | Operational/system data — không có giá trị nghiệp vụ |
| Operational / System | user_table_config | Cấu hình hiển thị bảng theo user | Operational/system data — không có giá trị nghiệp vụ |
| Operational / System | report_template | Mẫu báo cáo (cấu hình UI) | Operational/system data — cấu hình biểu mẫu chạy báo cáo, không có giá trị nghiệp vụ |
| Operational / System | report_template_workflow | Cấu hình biểu mẫu cho quy trình phân tích | Operational/system data — không có FK inbound từ bảng nghiệp vụ nào có giá trị thiết kế Atomic |
| Reference Data | category_config | Cấu hình danh mục dùng chung | Không có FK inbound từ bảng nghiệp vụ — xử lý thành Classification Value |
| Reference Data | category_item | Item trong danh mục dùng chung | Không có FK inbound từ bảng nghiệp vụ — xử lý thành Classification Value |
| Out of scope | analysis_define_report_template | Tham số cấu hình biểu mẫu báo cáo | Pure junction giữa analysis_attribute_define và report_template (ngoài scope) — không có giá trị nghiệp vụ Atomic |
