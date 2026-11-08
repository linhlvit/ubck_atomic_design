-- ============================================================
-- QLQ Flat Tables — CREATE
-- Module: Quản lý Quỹ (Fund Management) — QLQ
-- Generated: Phase 3 LLD Datamart
-- 20 bảng thực tế (thêm #20 qlq_opr_fund_management_company_employee_investor_account_list_flat, Nhóm 28, 2026-10-28; #21/#22 Data Explorer báo cáo động FMS, 2026-11-08; số thứ tự #n giữ theo lịch sử, #n bãi bỏ không đánh lại)
-- Sửa 2026-10-14: thêm #18 qlq_opr_foreign_fund_management_organization_unit_contract_list_flat (Nhóm 27) và #19 qlq_fund_management_company_staff_trade_rpt_flat (Nhóm 28) — trước đó PENDING
-- Sửa 2026-10-14: thêm #17 qlq_fct_fund_management_rpt_cell_val_flat (Dashboard RPT, 51 KPI READY) — bị bỏ sót ở commit 2f62880d
-- Sửa 2026-11-08: bãi bỏ #21 cũ qlq_fct_dynamic_report_val_flat (gộp Fact + 2 Dim thành 1 bảng); thay bằng 2 bảng đích như job Data Explorer ODS cũ — #21 qlq_opr_dynamic_report_explorer_val_flat (dữ liệu, thay bc_bao_cao_quy) và #22 qlq_opr_dynamic_report_explorer_indicator_flat (chỉ tiêu, thay metadata_etl); cấu trúc giữ nguyên, chỉ chuẩn hóa tên bảng/cột (O_QLQ_80)
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
    charter_capital_amt                          Nullable(Decimal(23,2)) COMMENT 'Tổng vốn điều lệ/vốn góp (VNĐ) của các quỹ theo loại hình quỹ, hiệu lực tại kỳ — cùng tập quỹ với fund_count (quỹ có ngày cấp giấy phép không muộn hơn cuối tháng)',
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
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu',
    fmc_id                                       String                  COMMENT 'Khóa đại diện CTQLQ (SECURITIES.ID) — khóa nối với fct_fund_management_rpt_cell_val.fmc_id và là tham số drill-down (:fmc_id) của popup Nhóm 4/5. fmc_code của bảng này là SECURITIES.CODE nên không nối được với fmc_code của Fact báo cáo định kỳ và bảng hợp đồng (O_QLQ_64, O_QLQ_68)'
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
    fmc_id                           Nullable(String)        COMMENT 'FK -> Fund Management Company Dimension (CTQLQ sở hữu quỹ) — khóa lọc danh sách quỹ theo CTQLQ ở Nhóm 4, cùng giá trị fmc_id của Profile (O_QLQ_68)',
    fmc_code                         Nullable(String)        COMMENT 'Mã CTQLQ sở hữu quỹ (FUNDS.SEC_ID theo Atomic, có thể ≠ SECURITIES.CODE của Profile) — không dùng làm khóa lọc, dùng fmc_id (O_QLQ_68)',
    investment_fund_full_nm          Nullable(String)        COMMENT 'Tên hiển thị chính của quỹ',
    fund_tp_code                     Nullable(String)        COMMENT 'Loại hình quỹ — mã (join Fund Type Dimension.fund_type_code lấy tên)',
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
    distribution_cert_dt             Nullable(Date)           COMMENT 'Ngày cấp giấy chứng nhận đăng ký hoạt động phân phối CCQ (ip_alternative_identification) — dùng để lọc danh sách ĐLPP theo kỳ, O_QLQ_72',
    address                          Nullable(String)        COMMENT 'Địa chỉ trụ sở chính',
    active_status_flag               Nullable(Int64)         COMMENT 'Trạng thái hoạt động (1=Đang hoạt động, 0=Ngừng hoạt động)',
    termination_dt                   Nullable(Date)           COMMENT 'Ngày chấm dứt hoạt động',
    distributing_fund_count          Nullable(Int64)         COMMENT 'Số quỹ đang phân phối của ĐLPP — đếm quỹ chưa xóa trong FUD_AG_AGT có AGEN_ID = DISTRIBUTOR_AGENT.ID như SQL BA (BA 2026-10-26: DISTRIBUTOR_AGENT → FUD_AG_AGT → FUNDS, thay nối theo tên qua AGENCIES/AGEN_FUNDS); nối theo mã nguồn vì khóa đại lý của FUD_AG_AGT trên Atomic băm theo AGENCIES (O_QLQ_21)',
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
--    Grain: 1 hợp đồng UTDM (bảng table_idx) × 1 bản nộp báo cáo của 1 CTQLQ × 1 kỳ báo cáo (O_QLQ_75: khóa đổi từ dynamic_row_nbr sang table_idx — DROP + CREATE bảng vì ORDER BY đổi)
--    Khai thác ClickHouse (K_QLQ_36–38, O_QLQ_33/O_QLQ_68): bảng giữ mọi kỳ nên trên môi trường có cột partition loader ds_snpst_dt luôn đọc max(ds_snpst_dt) (không chặn theo tháng chọn vì báo cáo tháng M nộp đầu tháng M+1); lọc kỳ bằng period_tp_code = '3', rpt_year, period_val; khử trùng part chưa merge bằng LIMIT 1 BY fmr_submission_code, dynamic_row_nbr
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_fund_management_company_contract_list_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Fund Management Company Contract List
    fmr_submission_code      String                  COMMENT 'PK (composite) — mã bản nộp báo cáo',
    table_idx                Int64                   COMMENT 'PK (composite) — chỉ số bảng hợp đồng trong sheet @QLDMDT (mỗi bảng = 1 hợp đồng UTDM; = dynamic_row_nbr nếu giá trị tĩnh, = dynamic_row_nbr / 1000 nếu giá trị động)',
    investment_fund_code     Nullable(String)        COMMENT 'Mã quỹ của dòng báo cáo (nếu có; bản nộp của CTQLQ có thể để trống)',
    fmc_code                 Nullable(String)        COMMENT 'Mã CTQLQ nộp báo cáo (RPT_VALUES.SEC_ID, không phải SECURITIES.CODE của Profile) — không dùng làm khóa lọc theo CTQLQ, dùng fmc_id (O_QLQ_68)',
    record_tp                Nullable(String)        COMMENT 'Loại đối tượng nộp báo cáo (sheet @QLDMDT: 2 = CTQLQ, BA xác nhận 2026-10-30)',
    period_tp_code           Nullable(String)        COMMENT 'Loại kỳ báo cáo: 1=Ngày, 2=Tuần, 3=Tháng, 4=Quý, 5=Bán niên, 6=Năm, 7=Nửa tháng',
    period_val               Nullable(String)        COMMENT 'Giá trị kỳ báo cáo dạng chuỗi (số tháng theo SQL BA)',
    rpt_year                 Nullable(Int64)         COMMENT 'Năm của kỳ báo cáo',
    version_nbr              Nullable(Int64)         COMMENT 'Số phiên bản biểu mẫu báo cáo — chọn phiên bản mới nhất của kỳ theo BA',
    customer_nm              Nullable(String)        COMMENT 'Tên khách hàng của hợp đồng UTDM (PII — lưu nguyên văn theo ngoại lệ đã duyệt, O_QLQ_33)',
    custody_account_nbr      Nullable(String)        COMMENT 'Số tài khoản lưu ký của hợp đồng UTDM (PII — lưu nguyên văn theo ngoại lệ đã duyệt, O_QLQ_33)',
    contract_market_val_amt  Nullable(Decimal(38,8)) COMMENT 'Giá trị thị trường của hợp đồng UTDM tại thời điểm báo cáo (đơn vị gốc của ô, VND)',
    src_stm_code             String                  COMMENT 'Mã hệ thống nguồn dữ liệu',
    fmc_id                   Nullable(String)        COMMENT 'Khóa đại diện CTQLQ nộp báo cáo (RPT_VALUES.SEC_ID = SECURITIES.ID; nếu dòng báo cáo không mang CTQLQ thì suy từ quỹ nộp) — khóa lọc danh sách hợp đồng theo CTQLQ ở Nhóm 5, cùng giá trị fmc_id của Fund Management Company Profile ở Nhóm 3 (O_QLQ_64, O_QLQ_68)'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (fmr_submission_code, table_idx)
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
    fmc_id                                       Nullable(String)        COMMENT 'Khóa đại diện CTQLQ nộp báo cáo (RPT_VALUES.SEC_ID = SECURITIES.ID) — khóa nối với fund_management_company.fmc_id và opr_fund_management_company_profile.fmc_id. KHÔNG nối bằng fmc_code vì fmr_value.fmc_code mang SEC_ID (GUID) trong khi fund_management_company.fmc_code mang SECURITIES.CODE (O_QLQ_64)',

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
    row_stt_code                                     Nullable(String)           COMMENT 'Số thứ tự dòng chỉ tiêu trong sheet (nhãn ở cột STT cùng dòng; cột STT là cột nhỏ nhất có ô tiêu đề STT ở bất kỳ hàng nào của sheet) — từ Fund Management Report Cell Dimension',
    row_indicator_code                               Nullable(String)           COMMENT 'Mã chỉ tiêu của dòng (nhãn ở cột có tiêu đề Mã chỉ tiêu hoặc Mã số cùng dòng; sheet báo cáo tài chính dùng Mã số, O_QLQ_70) — GIẢ ĐỊNH hàng tiêu đề là hàng đầu — từ Fund Management Report Cell Dimension',
    row_indicator_nm                                 Nullable(String)           COMMENT 'Tên chỉ tiêu của dòng (nhãn ở cột Chỉ tiêu cùng dòng) — GIẢ ĐỊNH hàng tiêu đề là hàng… — từ Fund Management Report Cell Dimension',
    row_label_nm                                     Nullable(String)           COMMENT 'Nhãn dòng của ô (bỏ nhãn placeholder ...): nối các nhãn ô bên trái có phạm vi gộp hàng phủ dòng của ô, cách nhau… — từ Fund Management Report Cell Dimension',
    column_label_nm                                  Nullable(String)           COMMENT 'Nhãn cột của ô (bỏ nhãn placeholder ...): nối các nhãn ô phía trên có phạm vi gộp cột phủ cột của ô, cách nhau bằng >>; nhãn tiêu đề cột nằm ở phần tử cuối, phần tử đầu có thể là tên mục — từ Fund Management Report Cell Dimension',

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


-- ============================================================
-- 21. OPERATIONAL: qlq_opr_dynamic_report_explorer_val_flat
--    Bảng dữ liệu khai thác Data Explorer QLQ (engine báo cáo động FMS) — cấu trúc giữ nguyên default.bc_bao_cao_quy của job ODS cũ,
--    chỉ chuẩn hóa tên bảng/cột. Không gộp Fact + Dim: 2 bảng đích (dữ liệu này + bảng chỉ tiêu qlq_opr_dynamic_report_explorer_indicator_flat).
--    Nguồn: fct_dynamic_report_val + dynamic_report_structure_dim + dynamic_report_submission_history_dim (+ cdr_dt_dim ngày nộp) — O_QLQ_80
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_dynamic_report_explorer_val_flat ON CLUSTER 'my_cluster'
(
    period_end_dt                                Date                    COMMENT 'Ngày cuối KỲ BÁO CÁO suy từ period_tp + period_val (không parse được thì dùng ngày nộp); cột Data Explorer lọc khoảng kỳ',
    object_id                                    String                  COMMENT 'Mã định danh đối tượng nộp báo cáo',
    object_nm                                    String                  COMMENT 'Tên đối tượng nộp báo cáo',
    object_tp                                    String                  COMMENT 'Loại đối tượng nộp báo cáo (Công ty QLQ, Quỹ đầu tư, ...)',
    object_sub_tp                                String                  COMMENT 'Loại quỹ — chỉ đối tượng Quỹ đầu tư',
    rpt_tp_nm                                    String                  COMMENT 'Nhãn loại báo cáo: 1 Báo cáo định kỳ, 2 bất thường, 3 theo yêu cầu, 4 khác',
    period_tp                                    String                  COMMENT 'Loại kỳ báo cáo (THANG, QUY, NAM, 6_THANG, TUAN, NGAY, NUA_THANG)',
    period_val                                   String                  COMMENT 'Giá trị kỳ báo cáo (T03/2026, Q1/2026, NAM_2025 ...)',
    table_index                                  Int32                   COMMENT 'Thứ tự bảng lặp trong sheet (BA: TABLE_IDX)',
    dynamic_index                                Int32                   COMMENT 'Thứ tự dòng động trong bảng (BA: DYNAMIC_IDX), ô tĩnh = -1',
    entity_code                                  String                  COMMENT 'Mã đối tượng của dòng động; dòng trùng mã đánh số ACB#2',
    custodian_bank_code                          String                  COMMENT 'Mã ngân hàng lưu ký / tài khoản đi kèm ô (nguồn acc_value)',
    indicator_id                                 String                  COMMENT 'md5 của mã báo cáo, sheet, đường dẫn dòng, đường dẫn cột — khóa nối với bảng chỉ tiêu',
    indicator_val                                String                  COMMENT 'Giá trị ô dạng chuỗi (chữ giữ nguyên văn, số chuẩn hóa)',
    rpt_code                                     String                  COMMENT 'Mã mẫu báo cáo',
    rpt_nm                                       String                  COMMENT 'Tên mẫu báo cáo',
    dr_submission_history_code                   String                  COMMENT 'Mã lần nộp báo cáo (REPORT_LOG_ID) — mỗi lần nộp là một bản ghi riêng',
    ds_etl_pcs_tms                               DateTime                COMMENT 'Thời điểm ETL ghi dòng'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYear(period_end_dt)
ORDER BY (period_end_dt, object_id, period_tp, period_val, dr_submission_history_code, table_index, entity_code, custodian_bank_code, indicator_id)
COMMENT 'Flat Data Explorer QLQ — giá trị ô báo cáo động FMS (thay bc_bao_cao_quy)'
;


-- ============================================================
-- 22. OPERATIONAL: qlq_opr_dynamic_report_explorer_indicator_flat
--    Bảng chỉ tiêu (metadata) của Data Explorer QLQ — cấu trúc giữ nguyên default.metadata_etl của job ODS cũ (phần targettable QLQ),
--    chỉ chuẩn hóa tên bảng/cột. Nối bảng dữ liệu qua indicator_id.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlq_opr_dynamic_report_explorer_indicator_flat ON CLUSTER 'my_cluster'
(
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (md5) — khớp indicator_id của bảng dữ liệu',
    indicator_group_nm                           String                  COMMENT 'Đường dẫn nhóm chỉ tiêu: tên báo cáo > sheet > nhóm hàng',
    indicator_nm                                 String                  COMMENT 'Tên chỉ tiêu: tên cột, hoặc phần tử cuối đường dẫn dòng khi không có cột',
    indicator_tp                                 Int32                   COMMENT 'Loại chỉ tiêu (luôn 1)',
    source_table_nm                              String                  COMMENT 'Bảng nguồn của chỉ tiêu',
    target_table_nm                              String                  COMMENT 'Bảng dữ liệu chứa giá trị chỉ tiêu',
    group_key_list                               String                  COMMENT 'Danh sách cột chiều của bảng dữ liệu, cách nhau dấu phẩy, Data Explorer dựng GROUP BY theo chuỗi này',
    logic_function                               String                  COMMENT 'Hàm logic tổng hợp (để trống)',
    indicator_level                              Int32                   COMMENT 'Cấp chỉ tiêu (luôn 1)',
    active_ind                                   Int32                   COMMENT '1 = chỉ tiêu đang hiệu lực',
    effective_from_dt                            Date                    COMMENT 'Ngày bắt đầu hiệu lực',
    effective_to_dt                              Date                    COMMENT 'Ngày hết hiệu lực',
    ds_etl_pcs_tms                               DateTime                COMMENT 'Thời điểm ETL ghi dòng',
    unit_nm                                      String                  COMMENT 'Đơn vị: rỗng = chỉ tiêu số, __text__ = chỉ tiêu chữ',
    sort_order_nbr                               Int64                   COMMENT 'Số thứ tự sắp xếp theo mẫu báo cáo',
    rpt_nm                                       String                  COMMENT 'Tên mẫu báo cáo',
    sheet_nm                                     String                  COMMENT 'Tên sheet',
    row_path                                     String                  COMMENT 'Đường dẫn hàng đầy đủ của chỉ tiêu (dòng động thêm Chi tiết)',
    column_path                                  String                  COMMENT 'Đường dẫn header của cột',
    object_tp_list                               String                  COMMENT 'Các loại đối tượng đã nộp báo cáo của chỉ tiêu, dạng gạch đứng bao quanh',
    object_sub_tp_list                           String                  COMMENT 'Các loại quỹ đã nộp báo cáo của chỉ tiêu, dạng gạch đứng bao quanh'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (indicator_id)
COMMENT 'Flat Data Explorer QLQ — chỉ tiêu báo cáo động FMS (thay metadata_etl của QLQ)'
;
