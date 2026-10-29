-- ============================================================
-- QLQ Flat Tables — CREATE
-- Module: Quản lý Quỹ (Fund Management) — QLQ
-- Generated: Phase 3 LLD Datamart
-- 19 bảng thực tế (thêm #20 qlq_opr_fund_management_company_employee_investor_account_list_flat, Nhóm 28, 2026-10-28; số thứ tự #n giữ theo lịch sử, #n bãi bỏ không đánh lại)
-- Sửa 2026-10-14: thêm #18 qlq_opr_foreign_fund_management_organization_unit_contract_list_flat (Nhóm 27) và #19 qlq_fund_management_company_staff_trade_rpt_flat (Nhóm 28) — trước đó PENDING
-- Sửa 2026-10-14: thêm #17 qlq_fct_fund_management_rpt_cell_val_flat (Dashboard RPT, 51 KPI READY) — bị bỏ sót ở commit 2f62880d
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

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                                  Nullable(Date)          COMMENT 'Ngày snapshot tháng — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt))
COMMENT 'Flat table — Fact Fund Management Company Snapshot × Calendar Date'
;


-- ============================================================
-- 2. FACT: qlq_fct_investment_fund_count_snpst_flat
--    Fact Investment Fund Count Snapshot
--    Grain: 1 loại hình quỹ × 1 tháng
--    Joins: Calendar Date (snpst_dt_dim_id) × Fund Type Dimension (fund_type_id)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_fct_investment_fund_count_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Investment Fund Count Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày snapshot tháng — Calendar Date Dimension',
    fund_type_id                    String                  COMMENT 'FK loại hình quỹ — Fund Type Dimension',
    fund_count                      Nullable(Int64)         COMMENT 'Số lượng quỹ theo loại hình quỹ, hiệu lực tại kỳ',
    charter_capital_amt                          Nullable(Decimal(23,2)) COMMENT 'Tổng vốn điều lệ/vốn góp (VNĐ) của các quỹ theo loại hình quỹ, hiệu lực tại kỳ — cùng tập quỹ với fund_count (quỹ có ngày cấp giấy phép không muộn hơn cuối tháng); K_QLQ_73/74 (Quỹ BĐS, Quỹ thành viên) chia 10.000 (mệnh giá) thành số CCQ theo mô tả BA',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                    Nullable(Date)          COMMENT 'Ngày snapshot tháng — từ Calendar Date Dimension',

    -- From: FUND TYPE DIMENSION
    fund_type_code                  Nullable(String)        COMMENT 'Mã loại hình quỹ — từ Fund Type Dimension',
    fund_type_nm                    Nullable(String)        COMMENT 'Tên loại hình quỹ — từ Fund Type Dimension',
    open_fund_indicator             Nullable(Int64)         COMMENT 'Cờ quỹ mở (1 = quỹ mở, 0 = không) — từ Fund Type Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt), fund_type_id)
COMMENT 'Flat table — Fact Investment Fund Count Snapshot × Calendar Date × Fund Type Dimension'
;


-- ============================================================
-- 4. FACT: qlq_fct_fund_distribution_agent_snpst_flat
--    Fact Fund Distribution Agent Snapshot
--    Grain: 1 snapshot toàn thị trường × 1 quý/năm (No Driving Table)
--    Joins: Calendar Date (snpst_dt_dim_id) — không có dim khác (market-level)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_fct_fund_distribution_agent_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Fund Distribution Agent Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày snapshot quý/năm — Calendar Date Dimension',
    distribution_agent_count        Nullable(Int64)         COMMENT 'Số lượng ĐLPP có GCN đăng ký hoạt động phân phối CCQ tính đến kỳ (không lọc trạng thái chấm dứt, như BA)',

    -- From: CALENDAR DATE DIMENSION
    snpst_cdr_dt                    Nullable(Date)          COMMENT 'Ngày snapshot quý/năm — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt))
COMMENT 'Flat table — Fact Fund Distribution Agent Snapshot × Calendar Date'
;


-- ============================================================
-- 5. FACT: qlq_fct_foreign_fund_management_organization_unit_snpst_flat
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
    snpst_cdr_dt                    Nullable(Date)          COMMENT 'Ngày snapshot tháng — từ Calendar Date Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(snpst_cdr_dt))
COMMENT 'Flat table — Fact Foreign Fund Management Organization Unit Snapshot × Calendar Date'
;


-- ============================================================
-- 6. OPERATIONAL: qlq_opr_fund_management_company_profile_flat
--    Operational Fund Management Company Profile
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_fund_management_company_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Fund Management Company Profile
    fmc_code                         String                  COMMENT 'PK — mã CTQLQ (Bảng Tác nghiệp)',
    fmc_full_nm                      Nullable(String)        COMMENT 'Tên hiển thị chính của công ty QLQ',
    fmc_short_nm                     Nullable(String)        COMMENT 'Tên viết tắt của công ty QLQ',
    operation_status_nm                          Nullable(String)        COMMENT 'Trạng thái hoạt động của công ty QLQ (tên trạng thái)',
    legal_representative_nm                      Nullable(String)        COMMENT 'Họ tên người đại diện theo pháp luật của công ty QLQ',
    fund_count                      Nullable(Int64)         COMMENT 'Số lượng quỹ đầu tư do công ty này quản lý, hiệu lực tại kỳ',
    rating_class_code                            Nullable(String)        COMMENT 'Xếp loại của công ty QLQ tại kỳ đánh giá gần nhất (1=A, 2=B, 3=C, 4=D)',
    total_score_amt                  Nullable(Int64)         COMMENT 'Tổng điểm CAMEL tại kỳ xếp hạng gần nhất tính đến kỳ chạy ETL',
    charter_capital_amt              Nullable(Decimal(23,2)) COMMENT 'Vốn điều lệ/vốn góp (VNĐ)',
    certified_practitioner_staff_count Nullable(Int64)         COMMENT 'Số lượng nhân viên có chứng chỉ hành nghề của CTQLQ (báo cáo kỳ mới nhất)',
    assets_under_management_amt      Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị tài sản ròng đang quản lý (AUM) của CTQLQ (báo cáo kỳ mới nhất)',
    capital_adequacy_ratio           Nullable(Decimal(9,2))  COMMENT 'Tỷ lệ an toàn tài chính (tỷ lệ vốn khả dụng) của CTQLQ (báo cáo kỳ mới nhất)',
    net_profit_after_tax_amt         Nullable(Decimal(23,2)) COMMENT 'Lợi nhuận sau thuế TNDN lũy kế theo báo cáo tài chính gần nhất của CTQLQ',
    owner_equity_amt                 Nullable(Decimal(23,2)) COMMENT 'Vốn chủ sở hữu theo báo cáo tài chính gần nhất của CTQLQ',
    portfolio_management_contract_count Nullable(Int64)         COMMENT 'Số lượng hợp đồng ủy thác quản lý danh mục đang thực hiện của CTQLQ (báo cáo kỳ mới nhất)',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (fmc_code)
COMMENT 'Flat table — Operational Fund Management Company Profile'
;


-- ============================================================
-- 7. OPERATIONAL: qlq_opr_fund_management_company_fund_list_flat
--    Operational Fund Management Company Fund List (bảng con drill-down)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_fund_management_company_fund_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Fund Management Company Fund List
    investment_fund_code             String                  COMMENT 'PK — mã quỹ (Bảng Tác nghiệp con, 1 dòng / quỹ trong 1 CTQLQ)',
    fmc_id                           Nullable(String)        COMMENT 'FK -> Fund Management Company Dimension (CTQLQ sở hữu quỹ)',
    fmc_code                         Nullable(String)        COMMENT 'Mã CTQLQ sở hữu quỹ (lookup pair với Fund Management Company Id)',
    investment_fund_full_nm          Nullable(String)        COMMENT 'Tên hiển thị chính của quỹ',
    fund_tp_code                     Nullable(String)        COMMENT 'Loại hình quỹ — mã (join Fund Type Dimension.fund_type_code lấy tên)',
    net_asset_val_amt                Nullable(Decimal(23,2)) COMMENT 'Giá trị tài sản ròng (NAV) của quỹ theo báo cáo kỳ mới nhất',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (investment_fund_code)
COMMENT 'Flat table — Operational Fund Management Company Fund List'
;


-- ============================================================
-- 8. OPERATIONAL: qlq_opr_investment_fund_profile_flat
--    Operational Investment Fund Profile
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_investment_fund_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Investment Fund Profile
    investment_fund_code             String                  COMMENT 'PK — mã quỹ (Bảng Tác nghiệp)',
    investment_fund_full_nm          Nullable(String)        COMMENT 'Tên hiển thị chính của quỹ',
    investment_fund_short_nm                     Nullable(String)        COMMENT 'Tên viết tắt của quỹ (BA: Tên quỹ = FUNDS.ITEM_NAME || -- || FUNDS.SHORT_NAME)',
    fund_tp_code                     Nullable(String)        COMMENT 'Phân loại quỹ — mã loại hình (join Fund Type Dimension.fund_type_code lấy tên)',
    fmc_full_nm                      Nullable(String)        COMMENT 'Tên đầy đủ công ty quản lý quỹ',
    custodian_bank_full_nm           Nullable(String)        COMMENT 'Tên ngân hàng giám sát',
    representative_board_member_count Nullable(Int64)        COMMENT 'Số lượng thành viên ban đại diện đang hoạt động',
    manager_count                    Nullable(Int64)         COMMENT 'Số lượng người điều hành quỹ',
    outstanding_unit_quantity        Nullable(Int64)         COMMENT 'Số lượng CCQ đang lưu hành',
    distribution_agent_count         Nullable(Int64)         COMMENT 'Số lượng đại lý phân phối của quỹ (loại đại lý phân phối)',
    net_asset_val_amt                Nullable(Decimal(23,2)) COMMENT 'Giá trị tài sản ròng (NAV) hiện tại của quỹ theo báo cáo kỳ mới nhất',
    year_to_dt_profit_amt            Nullable(Decimal(23,2)) COMMENT 'Lợi nhuận lũy kế từ đầu năm của quỹ (BCKQHĐKD mã 50 hoặc BCThuNhap mã 41, cột lũy kế từ đầu năm đến cuối kỳ báo cáo)',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (investment_fund_code)
COMMENT 'Flat table — Operational Investment Fund Profile'
;


-- ============================================================
-- 9. OPERATIONAL: qlq_opr_investment_fund_representative_board_member_list_flat
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
-- 10. OPERATIONAL: qlq_opr_investment_fund_manager_list_flat
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
-- 11. OPERATIONAL: qlq_opr_fund_distribution_agent_profile_flat
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
    distributing_fund_count          Nullable(Int64)         COMMENT 'Số quỹ đang phân phối của ĐLPP — đếm quỹ chưa xóa trong FUD_AG_AGT có AGEN_ID = DISTRIBUTOR_AGENT.ID như SQL BA (BA 2026-10-26: DISTRIBUTOR_AGENT → FUD_AG_AGT → FUNDS, thay nối theo tên qua AGENCIES/AGEN_FUNDS); nối theo mã nguồn vì khóa đại lý của FUD_AG_AGT trên Atomic băm theo AGENCIES (O_QLQ_21)',
    trading_account_count            Nullable(Int64)         COMMENT 'Số lượng tài khoản giao dịch chứng chỉ quỹ đã mở trong kỳ',
    trading_account_year_to_dt_count Nullable(Int64)         COMMENT 'Số lượng tài khoản giao dịch chứng chỉ quỹ đã mở lũy kế từ đầu năm',
    institution_trading_account_count Nullable(Int64)         COMMENT 'Số tài khoản giao dịch CCQ của nhà đầu tư tổ chức trong nước',
    individual_trading_account_count Nullable(Int64)         COMMENT 'Số tài khoản giao dịch CCQ của nhà đầu tư cá nhân trong nước',
    foreign_trading_account_count    Nullable(Int64)         COMMENT 'Số tài khoản giao dịch CCQ của nhà đầu tư nước ngoài',
    institution_holding_account_count Nullable(Int64)         COMMENT 'Số tài khoản nắm giữ CCQ cuối kỳ của nhà đầu tư tổ chức trong nước',
    individual_holding_account_count Nullable(Int64)         COMMENT 'Số tài khoản nắm giữ CCQ cuối kỳ của nhà đầu tư cá nhân trong nước',
    foreign_holding_account_count    Nullable(Int64)         COMMENT 'Số tài khoản nắm giữ CCQ cuối kỳ của nhà đầu tư nước ngoài',
    institution_fund_certificate_amt Nullable(Decimal(23,2)) COMMENT 'Giá trị CCQ nắm giữ bởi nhà đầu tư tổ chức trong nước',
    individual_fund_certificate_amt  Nullable(Decimal(23,2)) COMMENT 'Giá trị CCQ nắm giữ bởi nhà đầu tư cá nhân trong nước',
    foreign_fund_certificate_amt     Nullable(Decimal(23,2)) COMMENT 'Giá trị CCQ nắm giữ bởi nhà đầu tư nước ngoài',
    issued_amt                       Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị CCQ phát hành trong kỳ (cộng các dòng con 5.1–5.3)',
    issued_year_to_dt_amt            Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị CCQ phát hành lũy kế từ đầu năm (cộng các dòng con 5.1–5.3)',
    redeemed_amt                     Nullable(Decimal(23,2)) COMMENT 'Tổng giá trị CCQ mua lại trong kỳ (cộng các dòng con 6.1–6.3)',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (securities_distribution_agent_code)
COMMENT 'Flat table — Operational Fund Distribution Agent Profile'
;


-- ============================================================
-- 12. OPERATIONAL: qlq_opr_fund_distribution_agent_fund_list_flat
--    Operational Fund Distribution Agent Fund List
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_fund_distribution_agent_fund_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Fund Distribution Agent Fund List
    fund_distribution_agent_code     String                  COMMENT 'PK (composite) — mã ĐLPP',
    investment_fund_code             String                  COMMENT 'PK (composite) — mã quỹ đang phân phối',
    investment_fund_full_nm          Nullable(String)        COMMENT 'Tên hiển thị chính của quỹ đang phân phối',
    securities_distribution_agent_code           Nullable(String)        COMMENT 'Mã đại lý phân phối (DISTRIBUTOR_AGENT) — nối theo mã nguồn (FUD_AG_AGT.AGEN_ID = DISTRIBUTOR_AGENT.ID như SQL BA 2026-10-26, K_QLQ_143/159) để popup lọc theo ĐLPP chọn ở Danh sách ĐLPP (Nhóm 22); không NULL vì dòng chỉ lấy đại lý có trong DISTRIBUTOR_AGENT',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (fund_distribution_agent_code, investment_fund_code)
COMMENT 'Flat table — Operational Fund Distribution Agent Fund List'
;


-- ============================================================
-- 13. OPERATIONAL: qlq_opr_foreign_fund_management_organization_unit_profile_flat
--    Operational Foreign Fund Management Organization Unit Profile
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_foreign_fund_management_organization_unit_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Foreign Fund Management Organization Unit Profile
    foreign_fund_management_organization_unit_code String        COMMENT 'PK — mã Chi nhánh CTQLQ nước ngoài tại VN (Bảng Tác nghiệp)',
    foreign_fund_management_organization_unit_full_nm Nullable(String) COMMENT 'Tên hiển thị chính của CN',
    foreign_fund_management_organization_unit_short_nm Nullable(String) COMMENT 'Tên viết tắt của CN',
    director_full_nm                 Nullable(String)        COMMENT 'Tên Giám đốc chi nhánh',
    certified_practitioner_staff_count Nullable(Int64)         COMMENT 'Số lượng nhân viên có chứng chỉ hành nghề/chứng chỉ quốc tế của chi nhánh (báo cáo kỳ mới nhất)',
    capital_adequacy_ratio           Nullable(Decimal(9,2))  COMMENT 'Tỷ lệ an toàn tài chính (tỷ lệ vốn khả dụng) của chi nhánh (báo cáo kỳ mới nhất)',
    net_profit_after_tax_amt         Nullable(Decimal(23,2)) COMMENT 'Lợi nhuận sau thuế TNDN theo báo cáo tài chính gần nhất của chi nhánh',
    owner_equity_amt                 Nullable(Decimal(23,2)) COMMENT 'Vốn chủ sở hữu theo báo cáo tài chính gần nhất của chi nhánh',
    portfolio_management_contract_count Nullable(Int64)         COMMENT 'Số lượng hợp đồng ủy thác quản lý danh mục của chi nhánh (báo cáo kỳ mới nhất)',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (foreign_fund_management_organization_unit_code)
COMMENT 'Flat table — Operational Foreign Fund Management Organization Unit Profile'
;


-- ============================================================
-- 14. OPERATIONAL: qlq_opr_fund_management_report_sheet_list_flat
--    Operational Fund Management Report Sheet List
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_fund_management_report_sheet_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Fund Management Report Sheet List
    fmr_sheet_code                  String                  COMMENT 'PK — mã sheet biểu mẫu báo cáo (SHEET.ID, hex)',
    fmr_code                        Nullable(String)        COMMENT 'Mã biểu mẫu báo cáo chứa sheet (khóa nối sang báo cáo đã nộp)',
    fmr_nm                          Nullable(String)        COMMENT 'Tên báo cáo (RPT_TEMP.ITEM_NAME)',
    fmr_tp_code                     String                  COMMENT 'Loại báo cáo (scheme FMS_REPORT_TYPE)',
    rpt_short_code                  Nullable(String)        COMMENT 'Mã báo cáo (RPT_TEMP.CODE)',
    fmr_sheet_nm                    Nullable(String)        COMMENT 'Tên sheet (SHEET.ITEM_NAME)',
    sheet_short_code                Nullable(String)        COMMENT 'Mã sheet (SHEET.CODE)',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (fmr_sheet_code)
COMMENT 'Flat table — Operational Fund Management Report Sheet List'
;

-- ============================================================
-- 15. OPERATIONAL: qlq_opr_investment_fund_distribution_agent_list_flat
--    Operational Investment Fund Distribution Agent List
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_investment_fund_distribution_agent_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Investment Fund Distribution Agent List
    investment_fund_code             String                  COMMENT 'PK (composite) — mã quỹ',
    fund_distribution_agent_code     String                  COMMENT 'PK (composite) — mã đại lý phân phối',
    fund_distribution_agent_full_nm  Nullable(String)        COMMENT 'Tên hiển thị chính của đại lý phân phối',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (investment_fund_code, fund_distribution_agent_code)
COMMENT 'Flat table — Operational Investment Fund Distribution Agent List'
;

-- ============================================================
-- 16. OPERATIONAL: qlq_opr_fund_management_company_contract_list_flat
--    Operational Fund Management Company Contract List
--    Grain: 1 hợp đồng UTDM (dòng động) × 1 bản nộp báo cáo của 1 quỹ × 1 kỳ báo cáo
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_fund_management_company_contract_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Fund Management Company Contract List
    fmr_submission_code      String                  COMMENT 'PK (composite) — mã bản nộp báo cáo',
    dynamic_row_nbr          Int64                   COMMENT 'PK (composite) — số thứ tự dòng động, mỗi dòng là 1 hợp đồng UTDM',
    investment_fund_code     Nullable(String)        COMMENT 'Mã quỹ nộp báo cáo (loại đối tượng = 7 theo Điều kiện BA)',
    fmc_code                 Nullable(String)        COMMENT 'Mã CTQLQ quản lý quỹ nộp báo cáo — khóa lọc danh sách hợp đồng theo CTQLQ',
    record_tp                Nullable(String)        COMMENT 'Loại đối tượng nộp báo cáo (BA: 7 = Quỹ)',
    period_tp_code           Nullable(String)        COMMENT 'Loại kỳ báo cáo: 1=Ngày, 2=Tuần, 3=Tháng, 4=Quý, 5=Bán niên, 6=Năm, 7=Nửa tháng',
    period_val               Nullable(String)        COMMENT 'Giá trị kỳ báo cáo dạng chuỗi (số tháng theo SQL BA)',
    rpt_year                 Nullable(Int64)         COMMENT 'Năm của kỳ báo cáo',
    version_nbr              Nullable(Int64)         COMMENT 'Số phiên bản biểu mẫu báo cáo — chọn phiên bản mới nhất của kỳ theo BA',
    customer_nm              Nullable(String)        COMMENT 'Tên khách hàng của hợp đồng UTDM (PII — lưu nguyên văn theo ngoại lệ đã duyệt, O_QLQ_33)',
    custody_account_nbr      Nullable(String)        COMMENT 'Số tài khoản lưu ký của hợp đồng UTDM (PII — lưu nguyên văn theo ngoại lệ đã duyệt, O_QLQ_33)',
    contract_market_val_amt  Nullable(Decimal(38,8)) COMMENT 'Giá trị thị trường của hợp đồng UTDM tại thời điểm báo cáo (đơn vị gốc của ô, VND)',
    src_stm_code             String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (fmr_submission_code, dynamic_row_nbr)
COMMENT 'Flat table — Operational Fund Management Company Contract List'
;


-- ============================================================
-- 17. FACT: qlq_fct_fund_management_rpt_cell_val_flat
--    Fact Fund Management Report Cell Value
--    Grain: 1 ô báo cáo × 1 bản nộp (fmr_value) — Fact EAV mức ô, Dashboard RPT, 51 KPI READY ở 14 Nhóm (1, 2, 6–9, 12, 17–21, 24, 25)
--    Joins: Calendar Date (rpt_period_end_dt_dim_id — ngày cuối kỳ báo cáo) + Fund Management Report Cell Dimension
--           (fund_management_rpt_cell_id) + Fund Type Dimension (fund_type_id)
--    Nạp tăng dần theo ngày nộp (O_QLQ_34): DELETE đúng ngày nộp rồi INSERT; flat giữ TOÀN BỘ kỳ/bản nộp đã nộp để KPI
--    chọn kỳ gần nhất ≤ tháng slicer và bản nộp mới nhất (O_QLQ_32). Nhãn dòng/cột của ô là giả định — O_QLQ_31
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_fct_fund_management_rpt_cell_val_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Fund Management Report Cell Value
    rpt_period_end_dt_dim_id                         Nullable(String)           COMMENT 'FK -> Calendar Date Dimension (vai trò: ngày cuối kỳ báo cáo — suy từ loại kỳ, giá trị kỳ, năm; GIẢ ĐỊNH…',
    fund_management_rpt_cell_id                      String                     COMMENT 'FK -> Fund Management Report Cell Dimension (ô báo cáo: sheet + cell id)',
    fund_type_id                                     Nullable(String)           COMMENT 'FK -> Fund Type Dimension (loại hình quỹ của bản nộp thuộc đối tượng quỹ; NULL với bản nộp của đối tượng…',
    open_fund_tp_code                                Nullable(String)           COMMENT 'Phân loại quỹ mở: EQUITY/BOND/BALANCED (NULL với quỹ không phải quỹ mở hoặc bản nộp của đối tượng khác)',
    fund_establishment_license_dt                Nullable(Date)          COMMENT 'Ngày cấp giấy chứng nhận đăng ký lập quỹ (FMS.FUNDS.ID_DATE) của quỹ nộp báo cáo — dùng lọc "quỹ đã được cấp phép đến cuối tháng" như BA (LAST_DAY(FUNDS.ID_DATE) <= tháng, BA 2026-10-26 Nhóm 7/9/11/12); NULL với bản nộp của đối tượng khác hoặc quỹ chưa có ngày cấp phép (BA loại quỹ NULL vì so sánh NULL không đúng)',
    fmr_val_code                                     String                     COMMENT 'Mã giá trị ô báo cáo (RPT_VALUES.ID) — khóa grain của Fact',
    fmc_code                                         Nullable(String)           COMMENT 'Mã CTQLQ nộp báo cáo (bản nộp thuộc đối tượng CTQLQ)',
    investment_fund_code                             Nullable(String)           COMMENT 'Mã quỹ nộp báo cáo (bản nộp thuộc đối tượng quỹ)',
    securities_distribution_agent_code               Nullable(String)           COMMENT 'Mã đại lý phân phối nộp báo cáo (bản nộp thuộc đối tượng ĐLPP)',
    foreign_fund_management_organization_unit_code   Nullable(String)           COMMENT 'Mã chi nhánh CTQLQ nước ngoài nộp báo cáo (bản nộp thuộc đối tượng chi nhánh NN)',
    record_tp                                        Nullable(String)           COMMENT 'Loại đối tượng nộp báo cáo — theo điều kiện BA: 2=CTQLQ, 4=Chi nhánh CTQLQ NN, 7=Quỹ, 8=ĐLPP',
    period_tp_code                                   Nullable(String)           COMMENT 'Loại kỳ báo cáo: 1=Ngày, 2=Tuần, 3=Tháng, 4=Quý, 5=Bán niên, 6=Năm, 7=Nửa tháng',
    period_val                                       Nullable(String)           COMMENT 'Giá trị kỳ báo cáo dạng chuỗi (VD: Q1/2024, T03/2024, 2024)',
    rpt_year                                         Nullable(Int64)            COMMENT 'Năm của kỳ báo cáo',
    dynamic_row_nbr                                  Nullable(Int64)            COMMENT 'Số thứ tự hàng động trong sheet báo cáo có số dòng thay đổi (danh sách khách hàng, tài khoản…)',
    submitted_dt                                     Nullable(Date)             COMMENT 'Ngày thành viên nộp báo cáo — dùng chọn bản nộp mới nhất của kỳ khi có nộp lại',
    cell_val                                         Nullable(String)           COMMENT 'Giá trị gốc của ô dạng chuỗi',
    cell_numeric_val                                 Nullable(Decimal(38,8))    COMMENT 'Giá trị số của ô (bỏ ký tự %; NULL nếu ô chứa chữ hoặc không đổi được sang số); đơn vị theo từng ô báo cáo',
    src_stm_code                                     String                     COMMENT 'Mã hệ thống nguồn dữ liệu',

    -- From: CALENDAR DATE DIMENSION
    rpt_period_end_cdr_dt                            Nullable(Date)             COMMENT 'Ngày cuối kỳ báo cáo — từ Calendar Date Dimension',

    -- From: FUND MANAGEMENT REPORT CELL DIMENSION
    fmr_sheet_code                                   Nullable(String)           COMMENT 'Mã sheet biểu mẫu báo cáo (SHEET.ID) — khóa nối với giá trị ô — từ Fund Management Report Cell Dimension',
    cell_id                                          Nullable(String)           COMMENT 'ID ô báo cáo — khóa nối với giá trị ô (RPT_VALUES.TGT_ID) — từ Fund Management Report Cell Dimension',
    fmr_code                                         Nullable(String)           COMMENT 'Mã biểu mẫu báo cáo chứa sheet — từ Fund Management Report Cell Dimension',
    fmr_nm                                           Nullable(String)           COMMENT 'Tên biểu mẫu báo cáo (RPT_TEMP.ITEM_NAME) — từ Fund Management Report Cell Dimension',
    fmr_tp_code                                      Nullable(String)           COMMENT 'Loại báo cáo (RPT_TEMP.REPORT_TYPE; scheme FMS_REPORT_TYPE) — từ Fund Management Report Cell Dimension',
    rpt_short_code                                   Nullable(String)           COMMENT 'Mã định danh ngắn của biểu mẫu báo cáo (RPT_TEMP.CODE) — từ Fund Management Report Cell Dimension',
    rpt_group_code                                   Nullable(String)           COMMENT 'Nhóm báo cáo (RPT_TEMP.REPORT_GROUP) — từ Fund Management Report Cell Dimension',
    stm_object_tp_code                               Nullable(String)           COMMENT 'Đối tượng hệ thống áp dụng biểu mẫu: 1=QLQ, 2=QĐT, 3=BKGS, 4=ĐLPP, 5=ĐLCN — từ Fund Management Report Cell Dimension',
    cl_fms_fund_tp_code                              Nullable(String)           COMMENT 'Loại quỹ đầu tư áp dụng biểu mẫu (RPT_TEMP.FTYPE_ID) — từ Fund Management Report Cell Dimension',
    version_nbr                                      Nullable(Int64)            COMMENT 'Số phiên bản biểu mẫu báo cáo — từ Fund Management Report Cell Dimension',
    legal_basis                                      Nullable(String)           COMMENT 'Cơ sở pháp lý của biểu mẫu báo cáo — từ Fund Management Report Cell Dimension',
    fmr_sheet_nm                                     Nullable(String)           COMMENT 'Tên sheet (SHEET.ITEM_NAME) — BA lọc theo tên sheet — từ Fund Management Report Cell Dimension',
    sheet_short_code                                 Nullable(String)           COMMENT 'Mã định danh ngắn của sheet (SHEET.CODE) — từ Fund Management Report Cell Dimension',
    sheet_index                                      Nullable(Int64)            COMMENT 'Thứ tự sheet trong biểu mẫu (bắt đầu từ 0) — từ Fund Management Report Cell Dimension',
    investment_portfolio_indicator                   Nullable(Int64)            COMMENT 'Cờ sheet là danh mục đầu tư (1=Có, 0=Không) — từ Fund Management Report Cell Dimension',
    row_index                                        Nullable(Int64)            COMMENT 'Số thứ tự hàng của ô trong sheet — từ Fund Management Report Cell Dimension',
    column_index                                     Nullable(Int64)            COMMENT 'Số thứ tự cột của ô trong sheet — từ Fund Management Report Cell Dimension',
    row_span                                         Nullable(Int64)            COMMENT 'Số hàng được gộp của ô — từ Fund Management Report Cell Dimension',
    column_span                                      Nullable(Int64)            COMMENT 'Số cột được gộp của ô — từ Fund Management Report Cell Dimension',
    label_nm                                         Nullable(String)           COMMENT 'Nhãn hiển thị của ô (parse từ DATA_LABEL) — từ Fund Management Report Cell Dimension',
    row_stt_code                                     Nullable(String)           COMMENT 'Số thứ tự dòng chỉ tiêu trong sheet (nhãn ở cột STT cùng dòng) — GIẢ ĐỊNH hàng tiêu đề… — từ Fund Management Report Cell Dimension',
    row_indicator_code                               Nullable(String)           COMMENT 'Mã chỉ tiêu của dòng (nhãn ở cột Mã chỉ tiêu cùng dòng) — GIẢ ĐỊNH hàng tiêu đề là hàng… — từ Fund Management Report Cell Dimension',
    row_indicator_nm                                 Nullable(String)           COMMENT 'Tên chỉ tiêu của dòng (nhãn ở cột Chỉ tiêu cùng dòng) — GIẢ ĐỊNH hàng tiêu đề là hàng… — từ Fund Management Report Cell Dimension',
    row_label_nm                                     Nullable(String)           COMMENT 'Nhãn dòng của ô: nối các nhãn ô bên trái có phạm vi gộp hàng phủ dòng của ô, cách nhau… — từ Fund Management Report Cell Dimension',
    column_label_nm                                  Nullable(String)           COMMENT 'Nhãn cột của ô: nối các nhãn ô phía trên có phạm vi gộp cột phủ cột của ô, cách nhau… — từ Fund Management Report Cell Dimension',

    -- From: FUND TYPE DIMENSION
    fund_type_code                                   Nullable(String)           COMMENT 'Mã loại hình quỹ (BK nguồn FMS.FUND_TYPE.ID — nguồn không có cột mã nghiệp vụ riêng);… — từ Fund Type Dimension',
    fund_type_nm                                     Nullable(String)           COMMENT 'Tên loại hình quỹ hiển thị (FMS.FUND_TYPE.ITEM_NAME) — từ Fund Type Dimension',
    open_fund_indicator                              Nullable(Int64)            COMMENT 'Cờ quỹ mở (FMS.FUND_TYPE.IS_OPEN_FUND): 1 = quỹ mở, 0 = không. Giữ int 0/1 như Atomic… — từ Fund Type Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(rpt_period_end_cdr_dt))
ORDER BY (assumeNotNull(rpt_period_end_cdr_dt), fund_management_rpt_cell_id, fmr_val_code)
COMMENT 'Flat table — Fact Fund Management Report Cell Value × Calendar Date × Fund Management Report Cell Dimension × Fund Type Dimension'
;


-- ============================================================
-- 18. OPERATIONAL: qlq_opr_foreign_fund_management_organization_unit_contract_list_flat
--    Operational Foreign Fund Management Organization Unit Contract List
--    Grain: 1 hợp đồng UTQLDM (dòng động) × 1 bản nộp báo cáo của 1 CN CTQLQ NN × 1 kỳ báo cáo (Nhóm 27)
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_foreign_fund_management_organization_unit_contract_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Foreign Fund Management Organization Unit Contract List
    fmr_submission_code                      String                     COMMENT 'PK — Driving: fmr_value (composite cùng Dynamic Row Number; lấy DISTINCT theo bản nộp × dòng động)',
    dynamic_row_nbr                          Int64                      COMMENT 'PK — Driving: fmr_value (composite cùng Fund Management Report Submission Code); số thứ tự dòng động; mỗi…',
    foreign_fund_management_organization_unit_code Nullable(String)           COMMENT 'Mã chi nhánh CTQLQ nước ngoài nộp báo cáo (RPT_MEMBER.FR_BR_ID; loại đối tượng = 4 theo Điều kiện BA) —…',
    record_tp                                Nullable(String)           COMMENT 'Loại đối tượng nộp báo cáo (BA: 4 = Chi nhánh CTQLQ nước ngoài)',
    period_tp_code                           Nullable(String)           COMMENT 'Loại kỳ báo cáo: 1=Ngày, 2=Tuần, 3=Tháng, 4=Quý, 5=Bán niên, 6=Năm, 7=Nửa tháng',
    period_val                               Nullable(String)           COMMENT 'Giá trị kỳ báo cáo dạng chuỗi (VD: T03/2024, Q1/2024, 2024)',
    rpt_year                                 Nullable(Int64)            COMMENT 'Năm của kỳ báo cáo',
    version_nbr                              Nullable(Int64)            COMMENT 'Số phiên bản biểu mẫu báo cáo — chọn phiên bản mới nhất của kỳ theo cách BA xếp hạng',
    customer_nm                              Nullable(String)           COMMENT 'Tên khách hàng của hợp đồng UTQLDM (K_QLQ_179) — nội dung báo cáo chi nhánh nộp; giá trị đã mã hóa từ nguồn',
    custody_account_nbr                      Nullable(String)           COMMENT 'Số tài khoản lưu ký của hợp đồng UTQLDM (K_QLQ_180) — giá trị đã mã hóa từ nguồn',
    contract_market_val_amt                  Nullable(Decimal(38,8))    COMMENT 'Giá trị thị trường của từng hợp đồng UTQLDM (K_QLQ_181) = ô cột Tổng giá trị thị trường tại thời điểm báo…',
    src_stm_code                             String                     COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (fmr_submission_code, dynamic_row_nbr)
COMMENT 'Flat table — Operational Foreign Fund Management Organization Unit Contract List'
;


-- ============================================================
-- 19. FACT (report): qlq_fund_management_company_staff_trade_rpt_flat
--    Fund Management Company Staff Trade Report
--    Grain: 1 dòng khử trùng (UNION của BA) của nhân viên CTQLQ × ngày × tài khoản × bên mua/bán × mã CK × phương thức × CTCK × số lượng lệnh × giá lệnh (Nhóm 28)
--    [SỬA 2026-10-14 — O_QLQ_38] Operational (SCD4A) -> Fact report append, partition theo trade_dt
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_fund_management_company_staff_trade_rpt_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT (report) Fund Management Company Staff Trade Report
    fmc_employee_code                        String                     COMMENT 'Grain (1/6) — mã nhân viên CTQLQ (FMS.TL_PROFILES.ID) có CCCD trùng CCCD chủ tài khoản (`open_investor_account.identification_nbr`) của số tài khoản mua/bán trên sổ lệnh — nối CCCD → tài khoản theo BA dòng 177 (thay đường tài khoản khai ở hồ sơ, O_QLQ_35)',
    trade_dt                                 Date                       COMMENT 'Grain (2/6) — Ngày giao dịch (K_QLQ_109; Độ chi tiết ''Ngày'' của báo cáo); cột partition; nạp append theo ngày chạy ETL (O_QLQ_34; O_QLQ_38)',
    securities_account_nbr                   String                     COMMENT 'Grain (3/6) — Số tài khoản giao dịch chứng khoán (K_QLQ_107) lấy từ sổ lệnh theo bên mua/bán; thuộc nhân viên qua CCCD → open_investor_account (O_QLQ_35)',
    trade_direction_code                     String                     COMMENT 'Grain (4/6) — bên của nhân viên trong giao dịch: BUY = bên mua; SELL = bên bán',
    security_symbol_code                     String                     COMMENT 'Grain (5/6) — Mã chứng khoán (K_QLQ_112); sàn HOSE là symbol; sàn HNX là ISSUE_CODE theo SQL BA',
    trade_method_nm                          String                     COMMENT 'Grain (6/6) — Phương thức giao dịch (K_QLQ_110) — ánh xạ Board Type Code sang tên theo SQL BA; HOSE chỉ G1–G4 còn lại là "Khác"; HNX thêm G7 G8 T1 T2 T3 T4 T6 R1 (O_QLQ_36)',
    fmc_code                                 Nullable(String)           COMMENT 'Mã CTQLQ nơi nhân viên làm việc (FMS.TL_PROFILES.SEC_ID) — khóa lọc báo cáo theo CTQLQ',
    identification_nbr                       Nullable(String)           COMMENT 'Số CCCD/Hộ chiếu của nhân viên (K_QLQ_106; FMS.TL_PROFILES.ID_NO; đã mã hóa từ nguồn) — Chiều ''Mã CCCD'' của báo cáo; cũng là khóa nối sang tài khoản chứng khoán (`open_investor_account.identification_nbr`)',
    securities_company_code                  Nullable(String)           COMMENT 'Mã CTCK nơi mở tài khoản (K_QLQ_108) — số hiệu môi giới/thành viên trên sổ lệnh theo bên mua/bán. Khử trùng theo UNION của SQL BA: các dòng trùng toàn bộ cột chỉ giữ 1 (O_QLQ_36).',
    trade_direction_nm                       Nullable(String)           COMMENT 'Lệnh mua/bán (K_QLQ_111): "Mua" hoặc "Bán" theo bên của nhân viên',
    order_vol                                Nullable(Int64)            COMMENT 'Số lượng chứng khoán của LỆNH (K_QLQ_113) theo bên mua/bán — không phải khối lượng khớp. Khử trùng theo UNION của SQL BA: các dòng trùng toàn bộ cột chỉ giữ 1 (O_QLQ_36).',
    order_price                              Nullable(Decimal(23,2))    COMMENT 'Giá của LỆNH (K_QLQ_114) theo bên mua/bán — không phải giá khớp (O_QLQ_36). Khử trùng theo UNION của SQL BA: các dòng trùng toàn bộ cột chỉ giữ 1 (O_QLQ_36).',
    order_amt                                Nullable(Decimal(23,2))    COMMENT 'Tổng giá trị (K_QLQ_115) = số lượng lệnh × giá lệnh theo cột "Trường nguồn" dòng 186 BA; SQL BA nhánh HNX bên bán dùng trade_quantity × trade_price lệch cột (O_QLQ_36). Khử trùng theo UNION của SQL BA: các dòng trùng toàn bộ cột chỉ giữ 1 (O_QLQ_36).',
    src_stm_code                             String                     COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(trade_dt)
ORDER BY (trade_dt, fmc_employee_code, securities_account_nbr, trade_direction_code, security_symbol_code, trade_method_nm, assumeNotNull(securities_company_code), assumeNotNull(order_vol), assumeNotNull(order_price))
COMMENT 'Flat table — Fund Management Company Staff Trade Report (Fact report, append, khử trùng như UNION của BA)'
; mã giao dịch khớp trong sổ lệnh (cùng Trade Date, Trade Direction Code…',
    trade_direction_code                     String                     COMMENT 'Grain (3/4) — bên của nhân viên trong giao dịch khớp: BUY = bên mua; SELL = bên bán',
    fmc_employee_code                        String                     COMMENT 'Grain (4/4) — mã nhân viên CTQLQ (FMS.TL_PROFILES.ID) sở hữu tài khoản chứng khoán của bên mua/bán; nối…',
    trade_dt                                 Date                       COMMENT 'Grain (1/4) — Ngày giao dịch khớp (K_QLQ_109; Độ chi tiết Ngày của báo cáo); cột partition; nạp append theo ngày chạy ETL',
    fmc_code                                 Nullable(String)           COMMENT 'Mã CTQLQ nơi nhân viên làm việc (FMS.TL_PROFILES.SEC_ID) — khóa lọc báo cáo theo CTQLQ',
    identification_nbr                       Nullable(String)           COMMENT 'Số CCCD/Hộ chiếu của nhân viên (K_QLQ_106; FMS.TL_PROFILES.ID_NO; đã mã hóa từ nguồn) — Chiều Mã CCCD của bá',
    securities_account_nbr                   Nullable(String)           COMMENT 'Số tài khoản giao dịch chứng khoán của nhân viên (K_QLQ_107) — lấy từ sổ lệnh theo bên mua/bán',
    securities_company_code                  Nullable(String)           COMMENT 'Mã CTCK nơi mở tài khoản (K_QLQ_108) — số hiệu môi giới/thành viên trên sổ lệnh theo bên mua/bán',
    board_tp_code                            String                     COMMENT 'Mã loại bảng giao dịch của sổ lệnh (G1–G8; T1–T6; R1) — nguồn suy Phương thức giao dịch',
    trade_method_nm                          Nullable(String)           COMMENT 'Phương thức giao dịch (K_QLQ_110) — ánh xạ Board Type Code sang tên theo SQL BA; HOSE chỉ G1–G4 còn lại là…',
    trade_direction_nm                       Nullable(String)           COMMENT 'Lệnh mua/bán (K_QLQ_111): Mua hoặc Bán theo bên của nhân viên',
    security_symbol_code                     String                     COMMENT 'Mã chứng khoán (K_QLQ_112); sàn HOSE là symbol; sàn HNX là ISSUE_CODE theo SQL BA',
    order_vol                                Nullable(Int64)            COMMENT 'Số lượng chứng khoán của LỆNH (K_QLQ_113) theo bên mua/bán — không phải khối lượng khớp; một lệnh khớp…',
    order_price                              Nullable(Decimal(23,2))    COMMENT 'Giá của LỆNH (K_QLQ_114) theo bên mua/bán — không phải giá khớp (O_QLQ_36)',
    order_amt                                Nullable(Decimal(23,2))    COMMENT 'Tổng giá trị (K_QLQ_115) = số lượng lệnh × giá lệnh theo cột Trường nguồn dòng 186 BA; SQL BA nhánh HNX bên',
    src_stm_code                             String                     COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(trade_dt)
ORDER BY (trade_dt, securities_trade_code, trade_direction_code, fmc_employee_code)
COMMENT 'Flat table — Fund Management Company Staff Trade Report (Fact report, append)'
;


-- ============================================================
-- 20. OPERATIONAL: qlq_opr_fund_management_company_employee_investor_account_list_flat
--    Operational Fund Management Company Employee Investor Account List
--    Grain: 1 nhân viên CTQLQ × 1 tài khoản giao dịch chứng khoán VSDC (nối CCCD; open_investors UNION updated_investors)
--    [MỚI 2026-10-28 — O_QLQ_55] Nhóm 28: K_QLQ_106 (CCCD), K_QLQ_107 (số tài khoản) READY
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_fund_management_company_employee_investor_account_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Fund Management Company Employee Investor Account List
    fmc_employee_code                String                  COMMENT 'PK (composite) — mã nhân viên CTQLQ (FMS.TL_PROFILES.ID)',
    investor_account_nbr             String                  COMMENT 'PK (composite) — số tài khoản giao dịch chứng khoán VSDC',
    identification_nbr               String                  COMMENT 'Số CCCD/Hộ chiếu của nhân viên (K_QLQ_106)',
    fmc_code                         Nullable(String)        COMMENT 'Mã CTQLQ nơi nhân viên làm việc',
    fmc_employee_full_nm             Nullable(String)        COMMENT 'Họ tên nhân viên CTQLQ',
    account_open_dt                  Nullable(Date)          COMMENT 'Ngày mở tài khoản đầu tiên trên VSDC — để BI lọc khoảng ngày',
    account_update_dt                Nullable(Date)          COMMENT 'Ngày cập nhật thông tin tài khoản gần nhất trên VSDC — để BI lọc khoảng ngày',
    src_stm_code                     String                  COMMENT 'Mã hệ thống nguồn dữ liệu'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (fmc_employee_code, investor_account_nbr)
COMMENT 'Flat table — Operational Fund Management Company Employee Investor Account List'
;
