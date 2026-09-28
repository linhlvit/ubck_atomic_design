-- ============================================================
-- QLQ Flat Tables — CREATE
-- Module: Quản lý Quỹ (Fund Management) — QLQ
-- Generated: Phase 3 LLD Datamart
-- 15 bảng: 6 fact + 9 operational
-- ============================================================

-- ============================================================
-- 1. FACT: qlq_fct_fund_management_company_snpst_flat
--    Fact Fund Management Company Snapshot
--    Grain: 1 snapshot toàn thị trường × 1 tháng (No Driving Table — measure độc lập)
--    Joins: Calendar Date (snpst_dt_dim_id) — không có dim khác (market-level)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_fct_fund_management_company_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Fund Management Company Snapshot
    snpst_dt_dim_id                              String                  COMMENT 'FK ngày snapshot thị trường — Calendar Date Dimension',
    investment_fund_count                        Nullable(Int64)         COMMENT 'Số lượng quỹ đầu tư chứng khoán tại kỳ',
    active_fund_management_company_count         Nullable(Int64)         COMMENT 'Số CTQLQ đang hoạt động tại kỳ',
    foreign_fund_management_organization_unit_count Nullable(Int64)      COMMENT 'Số VPĐD CTQLQ nước ngoài tại VN tại kỳ',
    active_foreign_fund_management_organization_unit_count Nullable(Int64) COMMENT 'Số VPĐD CTQLQ NN đang hoạt động tại kỳ',
    pending_closure_foreign_fund_management_organization_unit_count Nullable(Int64) COMMENT 'Số VPĐD CTQLQ NN đang chờ đóng cửa tại kỳ',
    closed_foreign_fund_management_organization_unit_count Nullable(Int64) COMMENT 'Số VPĐD CTQLQ NN đã đóng cửa tại kỳ',
    custodian_bank_count                         Nullable(Int64)         COMMENT 'Tổng số ngân hàng giám sát tại kỳ',
    investment_fund_nav_amt                      Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị NAV toàn thị trường tại kỳ',
    investment_fund_nav_per_ccq_amt              Nullable(Decimal(23,2)) COMMENT 'NAV/CCQ bình quân toàn thị trường tại kỳ',
    investment_fund_nav_per_ccq_growth_pct       Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ tăng trưởng NAV/CCQ toàn thị trường so với tháng liền trước',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                        Nullable(Date)          COMMENT 'Ngày snapshot tháng — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt))
COMMENT 'Flat table — Fact Fund Management Company Snapshot × Calendar Date'
;


-- ============================================================
-- 2. FACT: qlq_fct_investment_fund_count_snpst_flat
--    Fact Investment Fund Count Snapshot
--    Grain: 1 loại hình quỹ × 1 tháng
--    Joins: Calendar Date (snpst_dt_dim_id) × Classification Dimension (fund_tp_cl_dim_id, scheme FMS_FUND_TYPE)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_fct_investment_fund_count_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Investment Fund Count Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày snapshot tháng — Calendar Date Dimension',
    fund_tp_cl_dim_id                String                  COMMENT 'FK loại hình quỹ — Classification Dimension (scheme FMS_FUND_TYPE)',
    fund_count                      Nullable(Int64)         COMMENT 'Số lượng quỹ theo loại hình quỹ, hiệu lực tại kỳ',
    investment_fund_nav_amt          Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị NAV theo loại hình quỹ, hiệu lực tại kỳ',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                          Nullable(Date)          COMMENT 'Ngày snapshot tháng — từ Calendar Date Dimension',

    -- From: CLASSIFICATION DIMENSION (Fund Type)
    schema_code                     Nullable(String)        COMMENT 'Mã scheme phân loại (FMS_FUND_TYPE) — từ Classification Dimension',
    schema_nm                       Nullable(String)        COMMENT 'Tên scheme phân loại — từ Classification Dimension',
    cl_code                         Nullable(String)        COMMENT 'Mã loại hình quỹ — từ Classification Dimension',
    cl_nm                           Nullable(String)        COMMENT 'Tên loại hình quỹ — từ Classification Dimension',
    cl_nm_english                   Nullable(String)        COMMENT 'Tên loại hình quỹ (tiếng Anh) — từ Classification Dimension',
    cl_description                  Nullable(String)        COMMENT 'Diễn giải chi tiết loại hình quỹ — từ Classification Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), fund_tp_cl_dim_id)
COMMENT 'Flat table — Fact Investment Fund Count Snapshot × Calendar Date × Classification Dimension'
;


-- ============================================================
-- 3. FACT: qlq_fct_investment_fund_ccq_snpst_flat
--    Fact Investment Fund CCQ Snapshot
--    Grain: 1 loại hình quỹ × 1 tháng
--    Joins: Calendar Date (snpst_dt_dim_id) × Classification Dimension (fund_tp_cl_dim_id, scheme FMS_FUND_TYPE)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_fct_investment_fund_ccq_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Investment Fund CCQ Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày snapshot tháng — Calendar Date Dimension',
    fund_tp_cl_dim_id                String                  COMMENT 'FK loại hình quỹ — Classification Dimension (scheme FMS_FUND_TYPE)',
    outstanding_unit_quantity        Nullable(Int64)         COMMENT 'Tổng số lượng CCQ đang lưu hành theo loại hình quỹ, hiệu lực tại kỳ',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                          Nullable(Date)          COMMENT 'Ngày snapshot tháng — từ Calendar Date Dimension',

    -- From: CLASSIFICATION DIMENSION (Fund Type)
    schema_code                     Nullable(String)        COMMENT 'Mã scheme phân loại (FMS_FUND_TYPE) — từ Classification Dimension',
    schema_nm                       Nullable(String)        COMMENT 'Tên scheme phân loại — từ Classification Dimension',
    cl_code                         Nullable(String)        COMMENT 'Mã loại hình quỹ — từ Classification Dimension',
    cl_nm                           Nullable(String)        COMMENT 'Tên loại hình quỹ — từ Classification Dimension',
    cl_nm_english                   Nullable(String)        COMMENT 'Tên loại hình quỹ (tiếng Anh) — từ Classification Dimension',
    cl_description                  Nullable(String)        COMMENT 'Diễn giải chi tiết loại hình quỹ — từ Classification Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), fund_tp_cl_dim_id)
COMMENT 'Flat table — Fact Investment Fund CCQ Snapshot × Calendar Date × Classification Dimension'
;


-- ============================================================
-- 4. FACT: qlq_fct_investment_fund_nav_per_ccq_snpst_flat
--    Fact Investment Fund NAV per CCQ Snapshot
--    Grain: 1 loại hình quỹ chi tiết (9 giá trị) × 1 tháng
--    Joins: Calendar Date (snpst_dt_dim_id) × Classification Dimension (fund_tp_cl_dim_id, scheme FMS_FUND_TYPE)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_fct_investment_fund_nav_per_ccq_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Investment Fund NAV per CCQ Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày snapshot tháng — Calendar Date Dimension',
    fund_tp_cl_dim_id                String                  COMMENT 'FK loại hình quỹ chi tiết (9 giá trị) — Classification Dimension (scheme FMS_FUND_TYPE)',
    nav_per_ccq_amt                  Nullable(Decimal(23,2)) COMMENT 'NAV/CCQ bình quân theo loại hình quỹ chi tiết, hiệu lực tại kỳ',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                          Nullable(Date)          COMMENT 'Ngày snapshot tháng — từ Calendar Date Dimension',

    -- From: CLASSIFICATION DIMENSION (Fund Type Detail)
    schema_code                     Nullable(String)        COMMENT 'Mã scheme phân loại (FMS_FUND_TYPE) — từ Classification Dimension',
    schema_nm                       Nullable(String)        COMMENT 'Tên scheme phân loại — từ Classification Dimension',
    cl_code                         Nullable(String)        COMMENT 'Mã loại hình quỹ chi tiết — từ Classification Dimension',
    cl_nm                           Nullable(String)        COMMENT 'Tên loại hình quỹ chi tiết — từ Classification Dimension',
    cl_nm_english                   Nullable(String)        COMMENT 'Tên loại hình quỹ chi tiết (tiếng Anh) — từ Classification Dimension',
    cl_description                  Nullable(String)        COMMENT 'Diễn giải chi tiết loại hình quỹ chi tiết — từ Classification Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), fund_tp_cl_dim_id)
COMMENT 'Flat table — Fact Investment Fund NAV per CCQ Snapshot × Calendar Date × Classification Dimension'
;


-- ============================================================
-- 5. FACT: qlq_fct_fund_distribution_agent_snpst_flat
--    Fact Fund Distribution Agent Snapshot
--    Grain: 1 snapshot toàn thị trường × 1 quý/năm (No Driving Table)
--    Joins: Calendar Date (snpst_dt_dim_id) — không có dim khác (market-level)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_fct_fund_distribution_agent_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Fund Distribution Agent Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày snapshot quý/năm — Calendar Date Dimension',
    distribution_agent_count        Nullable(Int64)         COMMENT 'Số lượng ĐLPP đang hoạt động, đã có GCN đăng ký hoạt động phân phối CCQ tính đến kỳ',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                          Nullable(Date)          COMMENT 'Ngày snapshot quý/năm — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt))
COMMENT 'Flat table — Fact Fund Distribution Agent Snapshot × Calendar Date'
;


-- ============================================================
-- 6. FACT: qlq_fct_foreign_fund_management_organization_unit_snpst_flat
--    Fact Foreign Fund Management Organization Unit Snapshot
--    Grain: 1 snapshot toàn thị trường × 1 tháng (No Driving Table)
--    Joins: Calendar Date (snpst_dt_dim_id) — không có dim khác (market-level)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_fct_foreign_fund_management_organization_unit_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Foreign Fund Management Organization Unit Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày snapshot tháng — Calendar Date Dimension',
    branch_count                    Nullable(Int64)         COMMENT 'Số Chi nhánh CTQLQ nước ngoài tại VN (branch_tp_code = BRANCH), hiệu lực tại kỳ',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                          Nullable(Date)          COMMENT 'Ngày snapshot tháng — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt))
COMMENT 'Flat table — Fact Foreign Fund Management Organization Unit Snapshot × Calendar Date'
;


-- ============================================================
-- 7. OPERATIONAL: qlq_opr_fund_management_company_profile_flat
--    Operational Fund Management Company Profile
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_fund_management_company_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Fund Management Company Profile
    fmc_code                         String                  COMMENT 'PK — mã CTQLQ (Bảng Tác nghiệp)',
    fmc_full_nm                      Nullable(String)        COMMENT 'Tên hiển thị chính của công ty QLQ',
    fmc_short_nm                     Nullable(String)        COMMENT 'Tên viết tắt của công ty QLQ',
    fund_count                      Nullable(Int64)         COMMENT 'Số lượng quỹ đầu tư do công ty này quản lý, hiệu lực tại kỳ',
    rank_index                      Nullable(Int64)         COMMENT 'Thứ hạng xếp loại (1=Tốt nhất) tại kỳ xếp hạng gần nhất tính đến kỳ chạy ETL',
    total_score_amt                  Nullable(Int64)         COMMENT 'Tổng điểm CAMEL tại kỳ xếp hạng gần nhất tính đến kỳ chạy ETL',
    charter_capital_amt              Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ/vốn góp (VNĐ)',
    discretionary_investment_account_count Nullable(Int64)  COMMENT 'Số lượng hợp đồng UTQLDM của công ty này, hiệu lực tại kỳ',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (fmc_code)
COMMENT 'Flat table — Operational Fund Management Company Profile'
;


-- ============================================================
-- 8. OPERATIONAL: qlq_opr_fund_management_company_fund_list_flat
--    Operational Fund Management Company Fund List (bảng con drill-down)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_fund_management_company_fund_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Fund Management Company Fund List
    investment_fund_code             String                  COMMENT 'PK — mã quỹ (Bảng Tác nghiệp con, 1 dòng / quỹ trong 1 CTQLQ)',
    fmc_id                           Nullable(String)        COMMENT 'FK -> Fund Management Company Dimension (CTQLQ sở hữu quỹ)',
    fmc_code                         Nullable(String)        COMMENT 'Mã CTQLQ sở hữu quỹ (lookup pair với Fund Management Company Id)',
    investment_fund_full_nm          Nullable(String)        COMMENT 'Tên hiển thị chính của quỹ',
    fund_tp_code                     Nullable(String)        COMMENT 'Loại hình quỹ — Classification Value (scheme FMS_FUND_TYPE)',
    net_asset_val_amt                Nullable(Decimal(23,2)) COMMENT 'Giá trị NAV hiện tại của quỹ',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (investment_fund_code)
COMMENT 'Flat table — Operational Fund Management Company Fund List'
;


-- ============================================================
-- 9. OPERATIONAL: qlq_opr_fund_management_company_contract_list_flat
--    Operational Fund Management Company Contract List (bảng con drill-down UTQLDM)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_fund_management_company_contract_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Fund Management Company Contract List
    discretionary_investment_account_code String             COMMENT 'PK — mã hợp đồng UTQLDM (Bảng Tác nghiệp con, 1 dòng / hợp đồng)',
    fmc_id                           Nullable(String)        COMMENT 'FK -> Fund Management Company Dimension (CTQLQ sở hữu hợp đồng)',
    fmc_code                         Nullable(String)        COMMENT 'Mã CTQLQ sở hữu hợp đồng (lookup pair với Fund Management Company Id)',
    contract_nbr                     Nullable(String)        COMMENT 'Số hợp đồng UTQLDM',
    account_nbr                      Nullable(String)        COMMENT 'Số tài khoản lưu ký của hợp đồng',
    portfolio_val_amt                Nullable(Decimal(23,2)) COMMENT 'Giá trị danh mục của hợp đồng',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (discretionary_investment_account_code)
COMMENT 'Flat table — Operational Fund Management Company Contract List'
;


-- ============================================================
-- 10. OPERATIONAL: qlq_opr_investment_fund_profile_flat
--    Operational Investment Fund Profile
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_investment_fund_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Investment Fund Profile
    investment_fund_code             String                  COMMENT 'PK — mã quỹ (Bảng Tác nghiệp)',
    investment_fund_full_nm          Nullable(String)        COMMENT 'Tên hiển thị chính của quỹ',
    fund_tp_code                     Nullable(String)        COMMENT 'Phân loại quỹ — Classification Value (scheme FMS_FUND_TYPE)',
    fmc_short_nm                     Nullable(String)        COMMENT 'Tên viết tắt công ty quản lý quỹ',
    custodian_bank_full_nm           Nullable(String)        COMMENT 'Tên ngân hàng giám sát',
    representative_board_member_count Nullable(Int64)        COMMENT 'Số lượng thành viên ban đại diện đang hoạt động',
    manager_count                    Nullable(Int64)         COMMENT 'Số lượng người điều hành quỹ',
    outstanding_unit_quantity        Nullable(Int64)         COMMENT 'Số lượng CCQ đang lưu hành',
    net_asset_val_amt                Nullable(Decimal(23,2)) COMMENT 'Giá trị NAV hiện tại của quỹ',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (investment_fund_code)
COMMENT 'Flat table — Operational Investment Fund Profile'
;


-- ============================================================
-- 11. OPERATIONAL: qlq_opr_investment_fund_representative_board_member_list_flat
--    Operational Investment Fund Representative Board Member List
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_investment_fund_representative_board_member_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Investment Fund Representative Board Member List
    investment_fund_representative_board_member_code String  COMMENT 'PK — mã thành viên ban đại diện (Bảng Tác nghiệp)',
    investment_fund_id               Nullable(String)        COMMENT 'FK -> Investment Fund Dimension (quỹ mà thành viên đại diện)',
    investment_fund_code             Nullable(String)        COMMENT 'Mã quỹ mà thành viên đại diện (lookup pair với Investment Fund Id)',
    board_member_full_nm             Nullable(String)        COMMENT 'Tên hiển thị chính của thành viên',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (investment_fund_representative_board_member_code)
COMMENT 'Flat table — Operational Investment Fund Representative Board Member List'
;


-- ============================================================
-- 12. OPERATIONAL: qlq_opr_investment_fund_manager_list_flat
--    Operational Investment Fund Manager List
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_investment_fund_manager_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Investment Fund Manager List
    investment_fund_code             String                  COMMENT 'PK (composite) — mã quỹ',
    fmc_employee_code                String                  COMMENT 'PK (composite) — mã người điều hành quỹ',
    fmc_employee_full_nm             Nullable(String)        COMMENT 'Tên hiển thị chính của người điều hành',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (investment_fund_code, fmc_employee_code)
COMMENT 'Flat table — Operational Investment Fund Manager List'
;


-- ============================================================
-- 13. OPERATIONAL: qlq_opr_fund_distribution_agent_profile_flat
--    Operational Fund Distribution Agent Profile
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_fund_distribution_agent_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Fund Distribution Agent Profile
    securities_distribution_agent_code String                COMMENT 'PK — mã ĐLPP (Bảng Tác nghiệp)',
    securities_distribution_agent_full_nm Nullable(String)    COMMENT 'Tên hiển thị chính của ĐLPP',
    license_nbr                      Nullable(String)        COMMENT 'Số giấy phép thành lập',
    license_dt                       Nullable(Date)           COMMENT 'Ngày cấp giấy phép thành lập',
    address                          Nullable(String)        COMMENT 'Địa chỉ trụ sở chính',
    active_status_flag               Nullable(Int64)         COMMENT 'Trạng thái hoạt động (1=Đang hoạt động, 0=Ngừng hoạt động)',
    termination_dt                   Nullable(Date)           COMMENT 'Ngày chấm dứt hoạt động',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (securities_distribution_agent_code)
COMMENT 'Flat table — Operational Fund Distribution Agent Profile'
;


-- ============================================================
-- 14. OPERATIONAL: qlq_opr_fund_distribution_agent_fund_list_flat
--    Operational Fund Distribution Agent Fund List
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_fund_distribution_agent_fund_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Fund Distribution Agent Fund List
    fund_distribution_agent_code     String                  COMMENT 'PK (composite) — mã ĐLPP',
    investment_fund_code             String                  COMMENT 'PK (composite) — mã quỹ đang phân phối',
    investment_fund_full_nm          Nullable(String)        COMMENT 'Tên hiển thị chính của quỹ đang phân phối',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (fund_distribution_agent_code, investment_fund_code)
COMMENT 'Flat table — Operational Fund Distribution Agent Fund List'
;


-- ============================================================
-- 15. OPERATIONAL: qlq_opr_foreign_fund_management_organization_unit_profile_flat
--    Operational Foreign Fund Management Organization Unit Profile
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_foreign_fund_management_organization_unit_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Foreign Fund Management Organization Unit Profile
    foreign_fund_management_organization_unit_code String        COMMENT 'PK — mã Chi nhánh CTQLQ nước ngoài tại VN (Bảng Tác nghiệp)',
    foreign_fund_management_organization_unit_full_nm Nullable(String) COMMENT 'Tên hiển thị chính của CN',
    foreign_fund_management_organization_unit_short_nm Nullable(String) COMMENT 'Tên viết tắt của CN',
    director_full_nm                 Nullable(String)        COMMENT 'Tên Giám đốc chi nhánh',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (foreign_fund_management_organization_unit_code)
COMMENT 'Flat table — Operational Foreign Fund Management Organization Unit Profile'
;
