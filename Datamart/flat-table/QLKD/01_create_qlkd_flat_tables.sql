-- ============================================================
-- QLKD Flat Tables — CREATE
-- Module: Quản lý kinh doanh (Hoạt động CTCK) — QLKD
-- Generated: Phase 3 LLD Datamart
-- 22 bảng flat: 7 fact + 14 operational + 1 dimension bộ lọc (khối 21)
-- ============================================================

-- ============================================================
-- 1. FACT: qlkd_fct_securities_company_status_snpst_flat
--    Fact Securities Company Status Snapshot
--    Grain: 1 CTCK × 1 ngày snapshot D (Periodic Snapshot APPEND, driving
--    table = Securities Company). License Issue Date là Chiều riêng, không
--    phải grain.
--    Joins: Calendar Date (snpst_dt_dim_id, license_issue_dt_dim_id) × Securities Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_fct_securities_company_status_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Securities Company Status Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày snapshot D — ETL runtime date, full-scan Securities Company Dimension mỗi lần chạy',
    securities_company_dim_id       String                  COMMENT 'FK CTCK — driving table',
    license_issue_dt_dim_id          Nullable(String)        COMMENT 'FK ngày cấp phép hoạt động — Chiều riêng, không phải grain',

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    cdr_dt                          Nullable(Date)          COMMENT 'Ngày snapshot D — từ Calendar Date Dimension',

    -- From: CALENDAR DATE DIMENSION (License Issue Date)
    license_issue_cdr_dt             Nullable(Date)          COMMENT 'Ngày cấp phép hoạt động — từ Calendar Date Dimension (Chiều/thuộc tính riêng)',

    -- From: SECURITIES COMPANY DIMENSION
    sc_id                           Nullable(String)        COMMENT 'Business Id CTCK (Atomic surrogate) — từ Securities Company Dimension',
    sc_code                         Nullable(String)        COMMENT 'Mã định danh CTCK — từ Securities Company Dimension',
    sc_nm                           Nullable(String)        COMMENT 'Tên đầy đủ CTCK bằng tiếng Việt — từ Securities Company Dimension',
    sc_short_nm                     Nullable(String)        COMMENT 'Tên viết tắt CTCK (VD: SSI, VPS, MBS) — từ Securities Company Dimension',
    company_tp_code                 Nullable(String)        COMMENT 'Loại hình doanh nghiệp CTCK — từ Securities Company Dimension',
    company_tp_nm                   Nullable(String)        COMMENT 'Tên loại hình doanh nghiệp CTCK — LEFT JOIN cl_value (scheme SCMS_COMPANY_TYPE) từ Securities Company Dimension; NULL nếu Atomic chưa nạp values.',
    company_status_code             Nullable(String)        COMMENT '7 nhóm trạng thái CTCK — derive CASE trên Item Code (CAT_SC_FIRM_STATUS.CODE) — LEFT JOIN cl_securities_company_firm_status — từ Securities Company Dimension',
    company_status_nm               Nullable(String)        COMMENT 'Nhãn tiếng Việt nhóm trạng thái CTCK (Đã bị thu hồi/Hoạt động bình thường/Kiểm soát đặc biệt/Kiểm soát/Cảnh báo/Đình chỉ hoạt động/Trạng thái khác); NULL khi CTCK không có trạng thái — từ Securities Company Dimension',
    is_listed_indicator             Nullable(UInt8)         COMMENT 'Cờ niêm yết trên sàn — từ Securities Company Dimension',
    stock_exchange_nm               Nullable(String)        COMMENT 'Sàn niêm yết (HOSE/HNX/UPCOM) — từ Securities Company Dimension',
    securities_company_src_stm_code Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Securities Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), securities_company_dim_id)
COMMENT 'Flat table — Fact Securities Company Status Snapshot × Calendar Date × Securities Company Dimension'
;


-- ============================================================
-- 2. FACT: qlkd_fct_securities_company_compliance_report_snpst_flat
--    Fact Securities Company Compliance Report Snapshot
--    Grain: 1 CTCK × 1 loại báo cáo (ADHOC/PERIODIC) × 1 kỳ/ngày sự vụ
--    UNION 2 nguồn Atomic độc lập: sc_adhoc_report + sc_periodic_report
--    Joins: Calendar Date (snpst_dt_dim_id) × Securities Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_fct_securities_company_compliance_report_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Securities Company Compliance Report Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày snapshot — chung cho cả 2 bộ ADHOC/PERIODIC',
    securities_company_dim_id       String                  COMMENT 'FK CTCK nộp báo cáo',
    report_tp_code                  String                  COMMENT 'Loại báo cáo — ADHOC (đột xuất) hoặc PERIODIC (định kỳ)',
    report_id                       String                  COMMENT 'Định danh báo cáo (degenerate) — dùng làm khóa COUNT DISTINCT',
    rpt_nm                                       Nullable(String)        COMMENT 'Tên báo cáo/biểu mẫu (nguồn REPORT_NAME) — cả 2 bộ ADHOC/PERIODIC',
    rpt_submission_status_code      Nullable(String)        COMMENT 'Mã trạng thái nộp báo cáo — giá trị riêng theo bộ ADHOC/PERIODIC',
    sent_dt                                      Nullable(Date)          COMMENT 'Ngày gửi báo cáo (nguồn SENT_AT) — bộ ADHOC',
    submission_deadline_dt                       Nullable(Date)          COMMENT 'Hạn nộp báo cáo (nguồn SUBMISSION_DEADLINE) — bộ ADHOC',
    rpt_year                                     Nullable(Int64)         COMMENT 'Năm báo cáo — bộ ADHOC',
    rpt_period_tp_code                           Nullable(String)        COMMENT 'Loại kỳ báo cáo (NGAY, TUAN, THANG, QUY, BAN_NIEN, NAM) — chỉ bộ PERIODIC, bộ ADHOC để NULL',
    period_nbr                                   Nullable(Int64)         COMMENT 'Số thứ tự kỳ báo cáo (quý 1-4, tháng 1-12) — chỉ bộ PERIODIC, bộ ADHOC để NULL',
    period_val                                   Nullable(String)        COMMENT 'Giá trị kỳ báo cáo đột xuất (VD 2024-Q1, nguồn PERIOD_VALUE) — chỉ bộ ADHOC, bộ PERIODIC để NULL',
    src_stm_code                        String                  COMMENT 'Mã hệ thống nguồn — SCMS_SC_FIRM_ADHOC_REPORT hoặc SCMS_SC_FIRM_PERIODIC_REPORT',
    created_dt                                   Nullable(Date)          COMMENT 'Ngày tạo bản ghi báo cáo đột xuất (nguồn SC_FIRM_ADHOC_REPORT.CREATED_AT → Atomic sc_adhoc_report.src_rcrd_isrt_tms) — ngày phát sinh yêu cầu báo cáo; BA dùng làm mốc phải nộp của báo cáo đột xuất chưa nộp (RECORD_STATUS = 0 AND TRUNC(CREATED_AT) <= ngày) và mốc đầu trục Nhóm 10/38/39. — bộ ADHOC',
    end_dt                                       Nullable(Date)          COMMENT 'Ngày kết thúc kỳ báo cáo (nguồn SC_FIRM_PERIODIC_REPORT.END_DATE) — chỉ bộ PERIODIC, bộ ADHOC để NULL; mốc đầu trục ngày Nhóm 28–30 (BA 24/10: MIN(END_DATE)).',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                          Nullable(Date)          COMMENT 'Ngày snapshot — từ Calendar Date Dimension',

    -- From: SECURITIES COMPANY DIMENSION
    sc_id                           Nullable(String)        COMMENT 'Business Id CTCK (Atomic surrogate) — từ Securities Company Dimension',
    sc_code                         Nullable(String)        COMMENT 'Mã định danh CTCK — từ Securities Company Dimension',
    sc_nm                           Nullable(String)        COMMENT 'Tên đầy đủ CTCK bằng tiếng Việt — từ Securities Company Dimension',
    sc_short_nm                     Nullable(String)        COMMENT 'Tên viết tắt CTCK (VD: SSI, VPS, MBS) — từ Securities Company Dimension',
    company_tp_code                 Nullable(String)        COMMENT 'Loại hình doanh nghiệp CTCK — từ Securities Company Dimension',
    company_tp_nm                   Nullable(String)        COMMENT 'Tên loại hình doanh nghiệp CTCK — LEFT JOIN cl_value (scheme SCMS_COMPANY_TYPE) từ Securities Company Dimension; NULL nếu Atomic chưa nạp values.',
    company_status_code             Nullable(String)        COMMENT '7 nhóm trạng thái CTCK — derive CASE trên Item Code (CAT_SC_FIRM_STATUS.CODE) — LEFT JOIN cl_securities_company_firm_status — từ Securities Company Dimension',
    company_status_nm               Nullable(String)        COMMENT 'Nhãn tiếng Việt nhóm trạng thái CTCK (Đã bị thu hồi/Hoạt động bình thường/Kiểm soát đặc biệt/Kiểm soát/Cảnh báo/Đình chỉ hoạt động/Trạng thái khác); NULL khi CTCK không có trạng thái — từ Securities Company Dimension',
    is_listed_indicator             Nullable(UInt8)         COMMENT 'Cờ niêm yết trên sàn — từ Securities Company Dimension',
    stock_exchange_nm               Nullable(String)        COMMENT 'Sàn niêm yết (HOSE/HNX/UPCOM) — từ Securities Company Dimension',
    securities_company_src_stm_code Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Securities Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), securities_company_dim_id, report_tp_code, report_id)
COMMENT 'Flat table — Fact Securities Company Compliance Report Snapshot × Calendar Date × Securities Company Dimension'
;


-- ============================================================
-- 3. FACT: qlkd_fct_securities_company_license_condition_snpst_flat
--    Fact Securities Company License Condition Snapshot
--    Joins: Calendar Date × Securities Company Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_fct_securities_company_license_condition_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Securities Company License Condition Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày snapshot D (Processing Date)',
    securities_company_dim_id       String                  COMMENT 'FK CTCK',
    indicator_code                  String        COMMENT 'Loại giấy phép — phân biệt Nhóm 5/6/7 trên cùng 1 Fact — JOIN sc_alert_indicator',
    severity_level                  Nullable(String)        COMMENT 'Mức duy trì điều kiện cấp phép (1/2/3)',
    alert_dt                                     Nullable(Date)          COMMENT 'Ngày phát sinh cảnh báo (nguồn SC_FIRM_ALERT_VIOLATION.ALERT_DATE) — ngày của dữ liệu, dùng làm cột ngày của trục Chiều thời gian theo ngày (date-spine Calendar Date Dimension, K_QLKD_30) của Nhóm 5/6/7/36: cận dưới trục = MIN(alert_dt), ngày trục cdr_dt_dim.cdr_dt nối alert_dt (BA STT 5/6/7/36, cập nhật 2026-10-22). Không phải khóa snapshot: snpst_dt_dim_id vẫn là ngày xử lý cảnh báo (processing_dt = :etl_date).',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                          Nullable(Date)          COMMENT 'FK ngày snapshot D (Processing Date) — từ Calendar Date Dimension',

    -- From: SECURITIES COMPANY DIMENSION
    sc_id                           Nullable(String)        COMMENT 'Business Id CTCK (Atomic surrogate) — từ Securities Company Dimension',
    sc_code                         Nullable(String)        COMMENT 'Mã định danh CTCK — từ Securities Company Dimension',
    sc_nm                           Nullable(String)        COMMENT 'Tên đầy đủ CTCK bằng tiếng Việt — từ Securities Company Dimension',
    sc_short_nm                     Nullable(String)        COMMENT 'Tên viết tắt CTCK (VD: SSI, VPS, MBS) — từ Securities Company Dimension',
    company_tp_code                 Nullable(String)        COMMENT 'Loại hình doanh nghiệp CTCK — từ Securities Company Dimension',
    company_tp_nm                   Nullable(String)        COMMENT 'Tên loại hình doanh nghiệp CTCK — LEFT JOIN cl_value (scheme SCMS_COMPANY_TYPE) từ Securities Company Dimension; NULL nếu Atomic chưa nạp values.',
    company_status_code             Nullable(String)        COMMENT '7 nhóm trạng thái CTCK — derive CASE trên Item Code (CAT_SC_FIRM_STATUS.CODE) — LEFT JOIN cl_securities_company_firm_status — từ Securities Company Dimension',
    company_status_nm               Nullable(String)        COMMENT 'Nhãn tiếng Việt nhóm trạng thái CTCK (Đã bị thu hồi/Hoạt động bình thường/Kiểm soát đặc biệt/Kiểm soát/Cảnh báo/Đình chỉ hoạt động/Trạng thái khác); NULL khi CTCK không có trạng thái — từ Securities Company Dimension',
    is_listed_indicator             Nullable(UInt8)         COMMENT 'Cờ niêm yết trên sàn — từ Securities Company Dimension',
    stock_exchange_nm               Nullable(String)        COMMENT 'Sàn niêm yết (HOSE/HNX/UPCOM) — từ Securities Company Dimension',
    securities_company_src_stm_code Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Securities Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), securities_company_dim_id, indicator_code)
COMMENT 'Flat table — Fact Securities Company License Condition Snapshot × Calendar Date × Securities Company Dimension'
;


-- ============================================================
-- 4. FACT: qlkd_fct_securities_company_capital_raising_event_flat
--    Fact Securities Company Capital Raising Event
--    Joins: Calendar Date × Offering Form Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_fct_securities_company_capital_raising_event_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Securities Company Capital Raising Event
    event_dt_dim_id                 String                  COMMENT 'FK tháng của đợt chào bán/phát hành — TRUNC(COALESCE(document_dt, src_rcrd_isrt_tms), \'MM\')',
    offering_form_dim_id            String                  COMMENT 'FK hình thức tăng vốn',
    proceeds_collected_amt          Nullable(Decimal(23,2)) COMMENT 'Tổng tiền thực tế thu được (SUM theo tháng x hình thức tăng vốn)',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                          Nullable(Date)          COMMENT 'FK tháng của đợt chào bán/phát hành — từ Calendar Date Dimension (TRUNC(COALESCE(document_dt, src_rcrd_isrt_tms), \'MM\'))',
    year                            Nullable(Int64)         COMMENT 'Năm (YYYY) — từ Calendar Date Dimension',
    month                           Nullable(Int64)         COMMENT 'Tháng (1–12) — từ Calendar Date Dimension',

    -- From: OFFERING FORM DIMENSION
    capital_raising_form_code       Nullable(String)        COMMENT 'Mã hình thức tăng vốn — ETL-derived CASE WHEN Item Category Code + Offering Type Code (dự phòng Offering Method) — từ Offering Form Dimension',
    capital_raising_form_nm         Nullable(String)        COMMENT 'Tên hình thức tăng vốn (5 nhóm) — từ Offering Form Dimension',
    offering_form_src_stm_code      Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Offering Form Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), offering_form_dim_id)
COMMENT 'Flat table — Fact Securities Company Capital Raising Event × Calendar Date × Offering Form Dimension'
;


-- ============================================================
-- 5. FACT: qlkd_fct_market_index_snpst_flat
--    Fact Market Index Snapshot (sở hữu QLKD, reuse NDTNN) — grain vật lý nguồn 1 ngày,
--    flat table QLKD lọc lấy đúng ngày cuối tháng (sửa 2026-07-24, datamart-review)
--    Joins: Calendar Date × Market Index Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_fct_market_index_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Market Index Snapshot
    snpst_dt_dim_id                 String                  COMMENT 'FK ngày (populate lấy đúng ngày cuối tháng)',
    market_index_dim_id             String                  COMMENT 'FK Market Index Dimension',
    market_index_val                Nullable(Decimal(23,2)) COMMENT 'Giá trị chỉ số (bản ghi cuối phiên, ngày cuối tháng)',
    open_index                      Nullable(Decimal(23,2)) COMMENT '[GSTT delta] Index mở cửa tại bản ghi cuối phiên',
    high_index                      Nullable(Decimal(23,2)) COMMENT '[GSTT delta] Index cao nhất tại bản ghi cuối phiên',
    low_index                       Nullable(Decimal(23,2)) COMMENT '[GSTT delta] Index thấp nhất tại bản ghi cuối phiên',
    prior_index                     Nullable(Decimal(23,2)) COMMENT '[GSTT delta] Index cuối cùng của phiên trước đó',
    index_change                    Nullable(Decimal(23,2)) COMMENT '[GSTT delta] Giá trị index thay đổi so với phiên trước',
    index_percent_change            Nullable(Decimal(5,2))  COMMENT '[GSTT delta] % index thay đổi so với phiên trước',
    advances_count                  Nullable(Int64)         COMMENT '[GSTT delta] Số lượng mã tăng',
    declines_count                  Nullable(Int64)         COMMENT '[GSTT delta] Số lượng mã giảm',
    no_change_count                 Nullable(Int64)         COMMENT '[GSTT delta] Số lượng mã không tăng/giảm',
    ceiling_count                   Nullable(Int64)         COMMENT '[GSTT delta] Số lượng mã đang trần',
    floor_count                     Nullable(Int64)         COMMENT '[GSTT delta] Số lượng mã đang sàn',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                          Nullable(Date)          COMMENT 'Ngày cuối tháng (LAST_DAY) — từ Calendar Date Dimension',
    year                            Nullable(Int64)         COMMENT 'Năm (YYYY) — từ Calendar Date Dimension',
    month                           Nullable(Int64)         COMMENT 'Tháng (1–12) — từ Calendar Date Dimension',

    -- From: MARKET INDEX DIMENSION
    market_id                       Nullable(String)        COMMENT 'Mã thị trường — từ Market Index Dimension',
    market_code                     Nullable(String)        COMMENT 'Mã sàn/chỉ số (HOSE/HNX/UPCOM/30) — từ Market Index Dimension',
    index_nm                        Nullable(String)        COMMENT '[MỚI 2026-09-15] Tên chuẩn của chỉ số (VN-Index/HNX-Index/UPCoM-Index/VN30...) — từ Market Index Dimension, theo MDDS.JAD_MARKETINFOR.INDEXNAME, dùng làm giá trị hiển thị thay Market Code (cùng cột đã bổ sung ở fct_market_index_intraday_flat/GSTT)',
    index_tp_code                   Nullable(String)        COMMENT 'Loại chỉ số — từ Market Index Dimension',
    tsc_product_group_id             Nullable(String)        COMMENT 'Mã sản phẩm giao dịch (HOSE/HNX/UPCOM) — từ Market Index Dimension',
    market_status_code              Nullable(String)        COMMENT 'Trạng thái phiên (current-state SCD4A) — từ Market Index Dimension',
    market_index_src_stm_code       Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Market Index Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), market_index_dim_id)
COMMENT 'Flat table — Fact Market Index Snapshot × Calendar Date × Market Index Dimension'
;


-- ============================================================
-- 6. FACT: qlkd_fct_securities_company_service_assignment_snpst_flat
--    Fact Securities Company Service Assignment Snapshot
--    Grain: 1 CTCK × 1 dịch vụ/nghiệp vụ × 1 ngày snapshot D (còn hiệu lực:
--    Start Date <= D AND (End Date IS NULL OR End Date > D))
--    Mới 17/09/2026 — Nhóm 2/3/4.
--    Joins: Calendar Date (snpst_dt_dim_id) × Securities Company Dimension ×
--    Securities Service Classification Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_fct_securities_company_service_assignment_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FACT Fact Securities Company Service Assignment Snapshot
    snpst_dt_dim_id                    String                  COMMENT 'FK ngày snapshot D — ETL runtime date, full-scan assignment còn hiệu lực',
    securities_company_dim_id          String                  COMMENT 'FK CTCK',
    securities_service_cl_dim_id       String                  COMMENT 'FK dịch vụ/nghiệp vụ kinh doanh chứng khoán',
    license_nbr                        Nullable(String)        COMMENT 'Số giấy phép dịch vụ chứng khoán hiện hành',
    license_dt                         Nullable(Date)          COMMENT 'Ngày cấp giấy phép dịch vụ',
    start_dt                           Nullable(Date)          COMMENT 'Ngày bắt đầu hiệu lực — dùng lọc còn hiệu lực tại ngày D',
    end_dt                             Nullable(Date)          COMMENT 'Ngày hết hiệu lực — dùng lọc còn hiệu lực tại ngày D',
    src_stm_code                       String                  COMMENT 'Mã hệ thống nguồn — từ Fact',

    -- From: CALENDAR DATE DIMENSION (Snapshot Date)
    cdr_dt                             Nullable(Date)          COMMENT 'Ngày snapshot D — từ Calendar Date Dimension',

    -- From: SECURITIES COMPANY DIMENSION
    sc_id                               Nullable(String)        COMMENT 'Business Id CTCK — từ Securities Company Dimension',
    sc_code                             Nullable(String)        COMMENT 'Mã định danh CTCK — từ Securities Company Dimension',
    sc_nm                               Nullable(String)        COMMENT 'Tên đầy đủ CTCK — từ Securities Company Dimension',
    sc_short_nm                         Nullable(String)        COMMENT 'Tên viết tắt CTCK — từ Securities Company Dimension',
    company_tp_code                     Nullable(String)        COMMENT 'Loại hình doanh nghiệp CTCK — từ Securities Company Dimension',
    company_tp_nm                       Nullable(String)        COMMENT 'Tên loại hình doanh nghiệp CTCK — LEFT JOIN cl_value (scheme SCMS_COMPANY_TYPE) từ Securities Company Dimension; NULL nếu Atomic chưa nạp values.',
    company_status_code                 Nullable(String)        COMMENT '7 nhóm trạng thái CTCK — từ Securities Company Dimension',
    company_status_nm                   Nullable(String)        COMMENT 'Nhãn tiếng Việt nhóm trạng thái CTCK (Đã bị thu hồi/Hoạt động bình thường/Kiểm soát đặc biệt/Kiểm soát/Cảnh báo/Đình chỉ hoạt động/Trạng thái khác); NULL khi CTCK không có trạng thái — từ Securities Company Dimension',
    is_listed_indicator                 Nullable(UInt8)         COMMENT 'Cờ niêm yết trên sàn — từ Securities Company Dimension',
    stock_exchange_nm                   Nullable(String)        COMMENT 'Sàn niêm yết — từ Securities Company Dimension',
    securities_company_src_stm_code     Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Securities Company Dimension',

    -- From: SECURITIES SERVICE CLASSIFICATION DIMENSION
    cl_sc_firm_service_code             Nullable(String)        COMMENT 'Mã dịch vụ/nghiệp vụ — từ Securities Service Classification Dimension',
    cl_sc_firm_service_nm               Nullable(String)        COMMENT 'Tên dịch vụ/nghiệp vụ — từ Securities Service Classification Dimension',
    description                         Nullable(String)        COMMENT 'Mô tả chi tiết dịch vụ/nghiệp vụ — từ Securities Service Classification Dimension',
    catalog_tp                          Nullable(String)        COMMENT 'Loại danh mục — từ Securities Service Classification Dimension',
    catalog_code                        Nullable(String)        COMMENT 'Mã danh mục chi tiết — dùng lọc nhóm dịch vụ/nghiệp vụ trên báo cáo — từ Securities Service Classification Dimension',
    application_tp_code                 Nullable(String)        COMMENT 'Loại nghiệp vụ: cơ sở/phái sinh — từ Securities Service Classification Dimension',
    legal_capital_amt                   Nullable(Decimal(23,2)) COMMENT 'Vốn pháp định tối thiểu — từ Securities Service Classification Dimension',
    securities_service_cl_src_stm_code  Nullable(String)        COMMENT 'Mã hệ thống nguồn — từ Securities Service Classification Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), securities_company_dim_id, securities_service_cl_dim_id)
COMMENT 'Flat table — Fact Securities Company Service Assignment Snapshot × Calendar Date × Securities Company Dimension × Securities Service Classification Dimension'
;


-- ============================================================
-- 7. OPERATIONAL: qlkd_opr_securities_company_personnel_profile_flat
--    Operational Securities Company Personnel Profile
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_securities_company_personnel_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Securities Company Personnel Profile
    sc_senior_personnel_code        String                  COMMENT 'PK — mã nhân sự cao cấp (Bảng Tác nghiệp)',
    sc_code                         String                  COMMENT 'Mã CTCK nơi nhân sự công tác',
    full_nm                         Nullable(String)        COMMENT 'Họ và tên đầy đủ nhân sự',
    department                      Nullable(String)        COMMENT 'Phòng/Ban — dùng CASE/LIKE phân nhóm tại tầng báo cáo',
    cl_sc_position_code                          Nullable(String)        COMMENT 'Mã chức vụ CHÍNH của nhân sự theo danh mục (`CAT_POSITION.POSITION_CODE` của `POSITION_ID` đơn trị): HĐQT = 6/7/8, HĐTV = 10/11, BKS/UB Kiểm toán = 23–28 (BA STT 31, SQL 1–3). XẤP XỈ so với BA: BA tách `POSITION_IDS` (CLOB, nhiều chức vụ → 1 dòng/chức vụ), Atomic chưa map. Số liệu K31-1 (28/10/2026, nhân sự đương nhiệm): 85k bản ghi, 41k không có `POSITION_IDS`, 3,6k nhiều chức vụ, 40k có `POSITION_ID` nằm trong `POSITION_IDS` (≈91% số bản ghi có `POSITION_IDS`) → thiếu các vai trò không phải chức vụ chính. Dùng cho FILTER nhóm nhân sự (`:nhom_nhan_su`) của K_QLKD_156–160.',
    position_nm                     Nullable(String)        COMMENT 'Chức vụ',
    email                           Nullable(String)        COMMENT 'Email nhân sự — JOIN ip_electronic_address filter EMAIL',
    phone                           Nullable(String)        COMMENT 'Số điện thoại nhân sự — JOIN ip_electronic_address filter PHONE',
    work_start_dt                   Nullable(Date)          COMMENT 'Ngày bắt đầu làm việc tại CTCK',
    dismissal_dt                    Nullable(Date)          COMMENT 'Ngày miễn nhiệm (NULL = đương nhiệm)',
    personnel_status_code           Nullable(String)        COMMENT 'Trạng thái nhân sự',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(work_start_dt))
ORDER BY (assumeNotNull(work_start_dt), sc_senior_personnel_code)
COMMENT 'Flat table — Operational Securities Company Personnel Profile'
;


-- ============================================================
-- 8. OPERATIONAL: qlkd_opr_securities_company_organization_unit_profile_flat
--    Operational Securities Company Organization Unit Profile
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_securities_company_organization_unit_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Securities Company Organization Unit Profile
    sc_ou_code                      String                  COMMENT 'PK — mã đơn vị (Bảng Tác nghiệp)',
    sc_code                         String                  COMMENT 'Mã CTCK',
    ou_tp_code                      String                  COMMENT 'Loại đơn vị (BRANCH/TRANSACTION_OFFICE/REP_OFFICE)',
    ou_nm                           Nullable(String)        COMMENT 'Tên đơn vị',
    adr_val                         Nullable(String)        COMMENT 'Địa chỉ đơn vị — JOIN ip_postal_address',
    decision_dt                     Nullable(Date)          COMMENT 'Ngày thành lập',
    director_nm                     Nullable(String)        COMMENT 'Giám đốc/Trưởng đơn vị — BRANCH dùng Director Name, TRANSACTION_OFFICE/REP_OFFICE dùng Representative Name',
    cl_firm_status_code             Nullable(String)        COMMENT 'Trạng thái pháp lý đơn vị',
    business_line_nm_list           Nullable(String)        COMMENT 'Danh sách tên nghiệp vụ kinh doanh chứng khoán được cấp phép cho đơn vị, nối bằng dấu phẩy (VPĐD = NULL)',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn — 3 giá trị khác nhau theo bộ (SC_FIRM_BRANCH/SC_FIRM_TRANSACTION_OFFICE/SC_FIRM_REP_OFFICE)'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(decision_dt))
ORDER BY (assumeNotNull(decision_dt), sc_ou_code)
COMMENT 'Flat table — Operational Securities Company Organization Unit Profile'
;


-- ============================================================
-- 9. OPERATIONAL: qlkd_opr_securities_company_compliance_hist_flat
--    Operational Securities Company Compliance History
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_securities_company_compliance_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Securities Company Compliance History
    compliance_event_code           String                  COMMENT 'PK — mã sự kiện tuân thủ (Bảng Tác nghiệp), thống nhất cho cả 3 nhánh UNION (Admin Penalty/Inspection/Examination)',
    event_tp_code                   String                  COMMENT 'Loại sự kiện tuân thủ (PENALTY_DECISION/INSPECTION/EXAMINATION) — ETL hardcode theo bộ',
    form_tp_code                    Nullable(String)        COMMENT 'Loại thanh tra/kiểm tra (PERIODIC/UNSCHEDULED). [SỬA 2026-09-19] Lấy trực tiếp từ Inspection/Examination Team (driving table) — không còn join ngược qua Penalty Decision Subject. NULL cho bộ Admin Penalty Decision.',
    insp_decision_dt                Nullable(Date)          COMMENT 'Ngày ban hành quyết định thanh tra/kiểm tra — luôn có giá trị cho bộ Inspection/Examination (thuộc tính trực tiếp driving table). NULL cho bộ Admin Penalty Decision.',
    decision_nbr                    Nullable(String)        COMMENT 'Số quyết định xử phạt',
    issued_dt                       Nullable(Date)          COMMENT 'Ngày ban hành quyết định xử phạt',
    violation_behavior_nm           Nullable(String)        COMMENT 'Hành vi vi phạm. NULL cho bộ Admin Penalty Decision.',
    supplementary_penalty_nm        Nullable(String)        COMMENT 'Hình thức xử phạt bổ sung (nếu có). NULL cho bộ Admin Penalty Decision.',
    remedial_measure_nm             Nullable(String)        COMMENT 'Biện pháp khắc phục (nếu có). NULL cho bộ Admin Penalty Decision.',
    sc_code                         Nullable(String)        COMMENT 'Mã CTCK. Bộ Admin Penalty Decision: direct. Bộ Inspection/Examination: GAP — text-match qua Team Target.target_reference_id, chưa có FK surrogate chính thức, có thể NULL. [SỬA 2026-09-19] JOIN securities_company nay là LEFT JOIN (xem O_QLKD_29) — không còn loại bỏ dòng khi không resolve được sc_code.',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn — 3 giá trị khác nhau theo bộ',
    event_dt                        Date                    COMMENT '[MỚI 2026-09-19, review Nhóm 40, xem O_QLKD_29] Ngày sự kiện chuẩn hóa = COALESCE(issued_dt, insp_decision_dt) — dùng làm PARTITION BY/ORDER BY thay issued_dt (nullable, gây lỗi assumeNotNull khi đợt thanh tra/kiểm tra sạch không có ngày xử phạt)'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(event_dt)
ORDER BY (event_dt, compliance_event_code)
COMMENT 'Flat table — Operational Securities Company Compliance History'
;


-- ============================================================
-- 10. OPERATIONAL: qlkd_opr_individual_profile_flat
--    Operational Individual Profile
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_individual_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Individual Profile
    sc_senior_personnel_code        String                  COMMENT 'PK — mã cá nhân (Bảng Tác nghiệp)',
    sc_code                         Nullable(String)        COMMENT 'Mã CTCK — chỉ áp dụng nguồn SCMS',
    full_nm                         Nullable(String)        COMMENT 'Họ và tên đầy đủ',
    position_nm                     Nullable(String)        COMMENT 'Vai trò/chức vụ',
    identification_nbr              Nullable(String)        COMMENT 'Số CCCD — merge key với nguồn còn lại (ETL, không phải FK Atomic)',
    license_certificate_nbr         Nullable(String)        COMMENT 'Số GCN hành nghề — chỉ áp dụng nguồn NHNCK',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn — 2 giá trị khác nhau theo bộ (SC_FIRM_SENIOR_PERSONNEL/NHNCK.PROFESSIONALS)',
    appointment_dt                               Nullable(Date)          COMMENT 'Ngày bổ nhiệm — không áp dụng cho nguồn NHNCK (người hành nghề không có ngày bổ nhiệm tại CTCK); chỉ có ở nguồn SCMS_SC_FIRM_SENIOR_PERSONNEL.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (sc_senior_personnel_code)
COMMENT 'Flat table — Operational Individual Profile'
;


-- ============================================================
-- 11. OPERATIONAL: qlkd_opr_individual_related_party_network_flat
--    Operational Individual Related Party Network
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_individual_related_party_network_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Individual Related Party Network
    related_party_network_id        String                  COMMENT 'PK — hash(src_stm_code + mã quan hệ người liên quan); Grain = 1 người liên quan của 1 cá nhân (nhân sự cấp cao hoặc cổ đông lớn), mỗi nguồn 1 loại quan hệ; khóa MERGE. Thay sc_insider_related_person_code (PK cũ chỉ đúng cho 1',
    individual_identification_nbr   Nullable(String)        COMMENT 'Số giấy tờ định danh (CCCD/CMND/hộ chiếu) của cá nhân CHÍNH (nhân sự cấp cao) — khóa chọn cá nhân trên dashboard (BA: AND sp.NATIONAL_ID = :cccd); đã mã hóa từ nguồn.',
    individual_full_nm              Nullable(String)        COMMENT 'Họ tên cá nhân chính (BA: ho_ten_ca_nhan).',
    sc_senior_personnel_code        Nullable(String)        COMMENT 'Mã nhân sự cao cấp chính (sp) — khóa nối tới cá nhân được chọn.',
    related_person_full_nm          Nullable(String)        COMMENT 'Tên người có liên quan.',
    rltnp                           Nullable(String)        COMMENT 'Mối quan hệ của người có liên quan (vợ/chồng/con cái...).',
    representative_position         Nullable(String)        COMMENT 'Vai trò/chức vụ của người có liên quan.',
    related_person_position_nm      Nullable(String)        COMMENT 'Chức vụ của người liên quan (BA: chuc_vu — nhánh người nội bộ: tên CAT_POSITION của POSITION_ID của người liên quan trong SC_FIRM_RELATED_PERSON, nối theo CTCK + số giấy tờ đã chuẩn hóa; nhánh cổ đông lớn: nhãn loại cổ đông).',
    identification_nbr              Nullable(String)        COMMENT 'CCCD người liên quan (BA: cccd_nguoi_lien_quan = r.NATIONAL_ID). [SỬA 2026-10-26] Lọc loại giấy tờ IDENTIFICATION — Atomic ETL hardcode giá trị này cho nguồn SC_FIRM_INSIDER_RELATION (bản cũ lọc NATIONAL_ID nên không bao giờ',
    shares_count                    Nullable(Int64)         COMMENT 'Số cổ phần người liên quan nắm giữ.',
    ownership_ratio                 Nullable(Decimal(5,2))  COMMENT 'Tỷ lệ sở hữu cổ phần người liên quan.',
    relation_start_dt               Nullable(Date)          COMMENT 'Ngày bắt đầu quan hệ (nguồn SC_FIRM_INSIDER_RELATION.RELATION_START_DATE) — mốc đầu cho trục Chiều thời gian theo Ngày của Nhóm 41/42 (K_QLKD_203; BA dòng 223, 226 Query 2).',
    effective_from_dt               Nullable(Date)          COMMENT 'Ngày bắt đầu hiệu lực để as-of (BA: TRUNC(r.CREATED_AT) <= ngày VÀ sp.APPOINTMENT_DATE <= ngày) = lớn hơn của ngày tạo quan hệ và ngày bổ nhiệm cá nhân; NULL nếu thiếu 1 trong 2 (bản ghi bị loại ở as-of như BA).',
    effective_to_dt                 Nullable(Date)          COMMENT 'Ngày kết thúc hiệu lực để as-of (BA: sp.DISMISSAL_DATE IS NULL OR sp.DISMISSAL_DATE > ngày) — ngày miễn nhiệm cá nhân chính.',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (related_party_network_id)
COMMENT 'Flat table — Operational Individual Related Party Network'
;


-- ============================================================
-- 12. OPERATIONAL: qlkd_opr_individual_listed_company_role_flat
--    Operational Individual Listed Company Role
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_individual_listed_company_role_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Individual Listed Company Role
    listed_company_role_id          String                  COMMENT 'PK — hash(src_stm_code + fmc_insider_code + số giấy tờ định danh); Grain = 1 vai trò của 1 cá nhân (theo số giấy tờ) tại 1 tổ chức, nguồn INSIDER của FMS (BA khối 1 nhánh 3); khóa MERGE.',
    individual_identification_nbr   String                  COMMENT 'Số giấy tờ định danh (CCCD/CMND/hộ chiếu) của cá nhân — khóa chọn cá nhân trên dashboard (BA: AND NATIONAL_ID = :cccd); đã mã hóa từ nguồn. Chỉ nạp bản ghi có số giấy tờ (BA: NATIONAL_ID/ID_NUMBER/ID_NO/IDENTITY_NO IS NOT NULL).',
    individual_full_nm              Nullable(String)        COMMENT 'Họ tên cá nhân (BA: ho_ten).',
    org_code                        Nullable(String)        COMMENT 'Mã tổ chức nơi cá nhân giữ vai trò (CTCK / CTQLQ / công ty đại chúng) — chỉ duy nhất trong cùng loại tổ chức (org_tp_nm); dùng đếm số tổ chức tham gia.',
    org_nm                          Nullable(String)        COMMENT 'Tên tổ chức hiển thị (BA: ten_to_chuc) — CTCK/CTQLQ: tên viết tắt; công ty đại chúng: mã chứng khoán (EQUITY_TICKER).',
    org_tp_nm                       String                  COMMENT 'Loại tổ chức (BA: loai_to_chuc; mô tả BA: CTCK, CTĐC, CT QLQ).',
    role_nm                         Nullable(String)        COMMENT 'Vai trò (BA: CASE INSIDER_TYPE — 1 Cổ đông lớn, 2 Ban điều hành, 3 HĐQT).',
    shares_held_qty                 Nullable(Int64)         COMMENT 'Số cổ phần nắm giữ (BA: so_cp_nam_giu).',
    status_nm                       String                  COMMENT 'Trạng thái (BA: trang_thai) — Đang hoạt động / Ngừng hoạt động suy từ trạng thái bản ghi Atomic (ds_rcrd_st); Atomic không map RECORD_STATUS/ACTIVE_FLG của nguồn (O_QLKD_60).',
    effective_from_dt               Nullable(Date)          COMMENT 'Ngày bắt đầu hiệu lực của vai trò — cận dưới as-of (<= ngày trên trục) và mốc đầu trục ngày Nhóm 41/42.',
    effective_to_dt                 Nullable(Date)          COMMENT 'Ngày kết thúc hiệu lực — cận trên as-of (IS NULL OR > ngày trên trục); NULL nếu nguồn không có ngày kết thúc.',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (listed_company_role_id)
COMMENT 'Flat table — Operational Individual Listed Company Role'
;


-- ============================================================
-- 13. OPERATIONAL: qlkd_opr_individual_trading_account_flat
--    Operational Individual Trading Account
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_individual_trading_account_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Individual Trading Account
    sc_shareholder_code             String                  COMMENT 'Mã cổ đông (chủ TK) — PK duy nhất (Bảng Tác nghiệp). Driving Table: Securities Company Shareholder (sc_shareholder) — nguồn track draft DataModel/working/Atomic/lld/SCMS/lld_SCMS_SC_FIRM_SHAREHOLDER.yaml, chưa approved.',
    sc_code                         String                  COMMENT 'Mã CTCK nơi mở tài khoản (SC_FIRM_INFO.CODE). BA hiển thị ma_ctck = SHORT_NAME → xem sc_short_nm.',
    sc_short_nm                     Nullable(String)        COMMENT 'Tên viết tắt CTCK nơi mở tài khoản (BA: ma_ctck = SC_FIRM_INFO.SHORT_NAME).',
    individual_identification_nbr   Nullable(String)        COMMENT 'Số giấy tờ định danh của chủ tài khoản (BA: sh.ID_NUMBER) — khóa chọn tài khoản của cá nhân và của người liên quan (khớp identification_nbr của Operational Individual Related Party Network); đã mã hóa từ nguồn.',
    trading_account                 Nullable(String)        COMMENT 'Số tài khoản giao dịch chứng khoán.',
    shareholder_nm                  Nullable(String)        COMMENT 'Tên chủ tài khoản.',
    shareholder_tp_code             Nullable(String)        COMMENT 'Loại cổ đông (BA: loai_co_dong = SHAREHOLDER_TYPE).',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn dữ liệu.',
    created_dt                      Nullable(Date)          COMMENT 'Ngày tạo bản ghi cổ đông (nguồn SC_FIRM_SHAREHOLDER.CREATED_AT → Atomic sc_shareholder.src_rcrd_isrt_tms) — một trong 7 mốc đầu của trục Chiều thời gian theo Ngày Nhóm 41/42 (BA dòng 223) và as-of cổ đông.'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY tuple()
ORDER BY (sc_shareholder_code)
COMMENT 'Flat table — Operational Individual Trading Account'
;


-- ============================================================
-- 14. OPERATIONAL: qlkd_opr_individual_work_hist_flat
--    Operational Individual Work History
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_individual_work_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Individual Work History
    sc_senior_personnel_code        String                  COMMENT 'PK — mã lần bổ nhiệm (Bảng Tác nghiệp)',
    individual_identification_nbr                Nullable(String)        COMMENT 'Số giấy tờ định danh (CCCD/CMND/hộ chiếu) của cá nhân — khóa chọn cá nhân trên dashboard Lịch sử công tác (BA STT 43: `AND p.NATIONAL_ID = <CCCD>`); đã mã hóa từ nguồn. KHÔNG loại bản ghi thiếu số giấy tờ (BA chỉ lọc CCCD ở mệnh đề chọn cá nhân, subquery BA không lọc). Ưu tiên dòng type `NATIONAL_ID` (`SC_FIRM_SENIOR_PERSONNEL.NATIONAL_ID` — BA dùng `p.NATIONAL_ID`; Data Modeler xác nhận Atomic đã map 2026-10-26, O_QLKD_60(i)); nếu không có thì lấy dòng `IDENTIFICATION` (`ID_NUMBER` = CMND cũ). Khuôn theo Operational Individual Listed Company Role.',
    sc_code                         String                  COMMENT 'Mã CTCK công tác',
    position_nm                     Nullable(String)        COMMENT 'Chức vụ tại công ty',
    work_start_dt                   Nullable(Date)          COMMENT 'Ngày bắt đầu làm việc',
    dismissal_dt                                 Nullable(Date)          COMMENT 'Ngày miễn nhiệm khỏi chức vụ (NULL = đương nhiệm) — BA STT 43: Đến ngày = `TRUNC(p.DISMISSAL_DATE)`. Khác `resignation_dt` (RESIGNATION_DATE — nghỉ việc tự nguyện, BA STT 43 không dùng).',
    resignation_dt                  Nullable(Date)          COMMENT 'Ngày nghỉ việc (NULL = hiện tại)',
    employment_status_code          Nullable(String)        COMMENT 'Trạng thái công tác (CURRENT/PAST) — derive từ Resignation Date',
    personnel_status_code                        Nullable(String)        COMMENT 'Trạng thái nhân sự (nguồn PERSONNEL_STATUS): 1 = Đương nhiệm → BA STT 43 hiển thị Hiện tại, giá trị khác → Quá khứ (`CASE WHEN p.PERSONNEL_STATUS = 1`). Khác `employment_status_code` (suy từ `resignation_dt`, BA STT 43 không dùng).',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(work_start_dt))
ORDER BY (assumeNotNull(work_start_dt), sc_senior_personnel_code)
COMMENT 'Flat table — Operational Individual Work History'
;


-- ============================================================
-- 15. OPERATIONAL: qlkd_opr_individual_violation_hist_flat
--    Operational Individual Violation History
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_individual_violation_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPERATIONAL Individual Violation History
    pd_subject_behavior_code                     String                  COMMENT '[SỬA 2026-10-19 — BA STT 44 cập nhật 19/10] PK — 1 dòng = 1 hành vi của 1 cá nhân trong 1 quyết định xử phạt (BA: mỗi dòng c = PENALTY_DECISION_SUBJECT_BEHAVIOR; nội dung vi phạm và hình thức phạt đi cặp theo hành vi). Thay PK cũ pd_code (lặp qua đối tượng/hành vi, flat ORDER BY có thể gộp mất dòng).',
    pd_code                         String                  COMMENT 'PK — mã quyết định xử phạt cá nhân (Bảng Tác nghiệp)',
    identification_nbr              Nullable(String)        COMMENT 'Số định danh cá nhân bị xử phạt — merge key với Operational Individual Profile',
    decision_nbr                    Nullable(String)        COMMENT 'Số quyết định xử phạt',
    issued_dt                       Nullable(Date)          COMMENT 'Ngày ban hành quyết định xử phạt',
    violation_description                        Nullable(String)        COMMENT '[SỬA 2026-10-19 — BA STT 44 cập nhật 19/10] Nội dung vi phạm — PENALTY_DECISION_SUBJECT_BEHAVIOR.DESCRIPTION (BA dòng 243); K_QLKD_221 đọc cột này (trước đây lấy tên hành vi danh mục, lệch BA).',
    violation_behavior_nm           Nullable(String)        COMMENT 'Nội dung vi phạm',
    penalty_tp_nm                   Nullable(String)        COMMENT 'Hình thức xử phạt chính',
    decision_status_code            Nullable(String)        COMMENT 'Trạng thái quyết định — LEFT JOIN Violation Case',
    src_stm_code                    String                  COMMENT 'Mã hệ thống nguồn'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(issued_dt))
ORDER BY (assumeNotNull(issued_dt), pd_subject_behavior_code)
COMMENT 'Flat table — Operational Individual Violation History'
;


-- ============================================================
-- 16. FACT: qlkd_fct_securities_company_financial_structure_snpst_flat
--    Fact Securities Company Financial Structure Snapshot — cơ cấu tài chính định kỳ CTCK (EAV)
--    Grain: 1 dong Atomic sc_report_input_value = 1 CTCK x 1 ky x 1 lan nop x 1 o bao cao; PK = rpt_input_val_id (khoa dong; ORDER BY phai chua PK vi ReplacingMergeTree dedup theo ORDER BY)
--    Nap theo pham vi (O_QLKD_69): thay nguyen partition thang bang REPLACE PARTITION tu bang dem qlkd_fct_securities_company_financial_structure_snpst_flat_stg (tao o 02_populate, cung cau truc voi bang nay)
--    Joins: Calendar Date Dimension, Securities Company Dimension, Report Indicator Dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_fct_securities_company_financial_structure_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FCT_SECURITIES_COMPANY_FINANCIAL_STRUCTURE_SNPST
    rpt_input_val_id                             String                  COMMENT 'PK — id dòng giá trị ô báo cáo đầu vào (Atomic `sc_report_input_value.sc_rpt_input_val_id` = hash_id của ID nguồn SCMS REPORT_INPUT_CELL_VALUE). Grain Fact = 1 dòng Atomic (không gộp): 1 CTCK × 1 kỳ × 1 lần nộp × 1 ô — PK là khóa dòng duy nhất của Fact nhưng KHÔNG phải đơn vị nạp: Fact nạp upsert THEO PHẠM VI (sc_code, rpt_year, rpt_period, period) — xóa toàn bộ dòng của phạm vi bị ảnh hưởng rồi nạp lại, không full refresh, không append (O_QLKD_69). Tọa độ ô (rpt_code, sheet_id, cell_id) tra qua `report_indicator_dim_id`; section_id/row_index không đưa vào Fact vì PK đã định danh từng dòng. [MỚI 2026-10-23] Trước đây Fact không khai báo khóa dòng.',
    snpst_dt_dim_id                              String                  COMMENT 'FK ngày snapshot — ngày kết thúc kỳ báo cáo (end_dt), lookup qua Calendar Date Dimension.',
    securities_company_dim_id                    String                  COMMENT 'FK CTCK nộp báo cáo — lookup qua Securities Company Dimension.',
    report_indicator_dim_id                      String                  COMMENT 'FK tọa độ ô báo cáo — lookup Report Indicator Dimension theo (rpt_code, sc_rpt_id, sheet_id, cell_id).',
    rpt_year                                     Int64                   COMMENT 'Năm báo cáo tài chính.',
    rpt_period_tp_code                           String                  COMMENT 'Loại kỳ báo cáo: QUY, THANG, NAM.',
    period_nbr                                   Int64                   COMMENT 'Số thứ tự kỳ báo cáo (1-4 cho Quý, 1-12 cho Tháng).',
    indicator_val_amt                            Nullable(Decimal(25,2)) COMMENT 'Giá trị chỉ tiêu tài chính (chuyển đổi từ text item_val sang số).',
    rpt_code                                     Nullable(String)        COMMENT 'Mã biểu mẫu báo cáo (BCTCHN, BCTCRL, BCTLAT, BCTHHD_CTCK).',
    legal_basis                                  Nullable(String)        COMMENT 'Căn cứ pháp lý của biểu mẫu báo cáo (trường LEGAL_BASIS của biểu mẫu, chứa số thông tư áp dụng, VD 121/2020/TT-BTC, 102/2025/TT-BTC). Cùng 1 mã biểu mẫu (VD BCTLAT) có thể có nhiều bản theo từng thông tư; KPI lọc cột này để chọn bản biểu mẫu cần đọc.',
    rpt_input_submission_id                      String                  COMMENT 'Khóa lần nộp dữ liệu báo cáo đầu vào (eForm) mà ô này thuộc về — cho biết giá trị lấy từ lần nộp nào của kỳ báo cáo.',
    submission_dt                                Nullable(Date)          COMMENT 'Ngày CTCK nộp báo cáo.',
    submission_status_code                       Nullable(String)        COMMENT 'Trạng thái nộp báo cáo định kỳ: 1 = Gửi đúng hạn, 2 = Gửi muộn.',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu.',
    preferred_report_ind                         Nullable(String)        COMMENT 'Cờ báo cáo được ưu tiên theo logic BA: 1 = dòng thuộc BCTCHN, hoặc BCTCRL của CTCK KHÔNG có BCTCHN (trạng thái 1/2) cùng kỳ, hoặc biểu mẫu khác (BCTLAT, BCTHHD_CTCK...); 0 = BCTCRL của CTCK đã có BCTCHN cùng kỳ (BA: chỉ lấy BCTCRL cho CTCK không nộp BCTCHN — CTE ctck_co_hn). KPI đo lọc = 1 để không cộng đôi HN và RL. ETL: cửa sổ trên các dòng Fact của cùng CTCK + năm + loại kỳ + kỳ. Đây cũng là phạm vi nạp của Fact (O_QLKD_69): cờ của dòng BCTCRL phụ thuộc có BCTCHN cùng phạm vi hay không, nên mọi dòng của phạm vi phải được dựng lại cùng lúc.',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                       Nullable(Date)          COMMENT 'NK — ngày lịch dùng để join từ Fact — từ Calendar Date Dimension',
    snpst_cdr_dt                                 Nullable(Date)          COMMENT 'Ngày snapshot (ngày kết thúc kỳ báo cáo), cùng giá trị cdr_dt; giữ tên snpst_cdr_dt theo quy ước chiều ngày snapshot — từ Calendar Date Dimension',
    year                                         Nullable(Int64)         COMMENT 'Năm (YYYY) — từ Calendar Date Dimension',
    quarter                                      Nullable(Int64)         COMMENT 'Quý (1–4) — từ Calendar Date Dimension',
    month                                        Nullable(Int64)         COMMENT 'Tháng (1–12) — từ Calendar Date Dimension',
    day_of_week                                  Nullable(Int64)         COMMENT 'Thứ trong tuần (1=Chủ nhật, 7=Thứ bảy) — từ Calendar Date Dimension',
    is_weekend                                   Nullable(String)        COMMENT '(Sửa 2026-07-17) Y nếu là ngày cuối tuần (thứ 7 hoặc CN), N nếu không — từ Calendar Date Dimension',
    holiday_flag                                 Nullable(String)        COMMENT '(Sửa 2026-07-20) Cờ đánh dấu ngày nghỉ — Y nếu là ngày nghỉ, N nếu không. Chỉ đánh dấu nghỉ/không nghỉ, không  — từ Calendar Date Dimension',
    is_trading_date                              Nullable(String)        COMMENT '(Sửa 2026-09-05, partial — thêm từ GSTT, yêu cầu thiết kế trực tiếp từ user) Y nếu ngày lịch là ngày giao dịch — từ Calendar Date Dimension',

    -- From: SECURITIES COMPANY DIMENSION
    sc_id                                        Nullable(String)        COMMENT 'Business Id CTCK (Atomic surrogate — dùng làm reference nghiệp vụ theo HLD). — từ Securities Company Dimension',
    sc_code                                      Nullable(String)        COMMENT 'Mã định danh CTCK — Natural Key. — từ Securities Company Dimension',
    sc_nm                                        Nullable(String)        COMMENT 'Tên đầy đủ CTCK bằng tiếng Việt. — từ Securities Company Dimension',
    sc_short_nm                                  Nullable(String)        COMMENT 'Tên viết tắt CTCK (VD: SSI, VPS, MBS). — từ Securities Company Dimension',
    company_tp_code                              Nullable(String)        COMMENT 'Loại hình doanh nghiệp CTCK. — từ Securities Company Dimension',
    company_tp_nm                                Nullable(String)        COMMENT 'Tên loại hình doanh nghiệp CTCK — LEFT JOIN cl_value (scheme SCMS_COMPANY_TYPE) từ Securities Company Dimension; NULL nếu Atomic chưa nạp values.',
    company_status_code                          Nullable(String)        COMMENT '7 nhóm trạng thái CTCK (Đã bị thu hồi/Hoạt động bình thường/Kiểm soát đặc biệt/Kiểm soát/Cảnh báo/Đình chỉ hoạ — từ Securities Company Dimension',
    company_status_nm                            Nullable(String)        COMMENT 'Nhãn tiếng Việt nhóm trạng thái CTCK (Đã bị thu hồi/Hoạt động bình thường/Kiểm soát đặc biệt/Kiểm soát/Cảnh báo/Đình chỉ hoạt động/Trạng thái khác); NULL khi CTCK không có trạng thái — từ Securities Company Dimension',
    is_listed_indicator                          Nullable(UInt8)         COMMENT 'Cờ niêm yết trên sàn. — từ Securities Company Dimension',
    stock_exchange_nm                            Nullable(String)        COMMENT 'Sàn niêm yết (HOSE/HNX/UPCOM). — từ Securities Company Dimension',
    sc_dim_src_stm_code                          Nullable(String)        COMMENT 'Mã hệ thống nguồn dữ liệu. — từ Securities Company Dimension',

    -- From: REPORT INDICATOR DIMENSION
    sheet_id                                     Nullable(String)        COMMENT 'Sheet trong biểu mẫu eForm động (sheet_id gốc eForm, chưa có mã sheet — O_QLKD_42) — từ Report Indicator Dimension',
    sheet_code                                   Nullable(String)        COMMENT 'Mã sheet nghiệp vụ của biểu mẫu eForm (sheetCode trong cấu hình biểu mẫu, VD 06620/06608/TTC_T/TTC_Q); cùng cell_id mang nghĩa khác nhau giữa các sheet nên lọc theo (rpt_code, sheet_code, cell_id) — từ Report Indicator Dimension',
    cell_id                                      Nullable(String)        COMMENT 'Mã ô dữ liệu (cell_id) trong sheet eForm động — chỉ có nghĩa cùng rpt_code + sheet_id — từ Report Indicator Dimension',
    sc_rpt_id                                    Nullable(String)        COMMENT 'Id kỹ thuật của BẢN biểu mẫu (FORM_REPORT.ID) — phân biệt các bản cùng rpt_code (nộp lại bằng bản mới/đổi thông tư); khóa nối Report Structure Dimension — từ Report Indicator Dimension',
    ri_dim_src_stm_code                          Nullable(String)        COMMENT 'Mã hệ thống nguồn dữ liệu. — từ Report Indicator Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), rpt_input_val_id)
COMMENT 'Flat table — Fact Securities Company Financial Structure Snapshot — cơ cấu tài chính định kỳ CTCK (EAV)'
;


-- ============================================================
-- 17. OPERATIONAL: qlkd_opr_securities_company_report_data_flat
--    Securities Company Report Data — raw data 102 bieu mau bao cao dinh ky
--    Grain: 1 o du lieu (cell) x 1 lan nop bao cao x 1 CTCK
--    Joins: không JOIN dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_securities_company_report_data_flat ON CLUSTER 'my_cluster'
(
    -- From: OPR_SECURITIES_COMPANY_REPORT_DATA
    rpt_cell_val_id                              String                  COMMENT 'Khóa chính giá trị ô báo cáo tác nghiệp.',
    rpt_input_submission_id                      String                  COMMENT 'Khóa lần nộp dữ liệu báo cáo đầu vào (eForm) chứa ô này, dùng để phân biệt các lần nộp của cùng một kỳ báo cáo.',
    rpt_input_submission_code                    String                  COMMENT 'Mã lần nộp dữ liệu báo cáo (ID nguồn REPORT_INPUT_SUBMISSION — số tăng dần theo lần nộp) dùng để chọn bản nộp MỚI NHẤT của cùng một kỳ báo cáo (BA: ROW_NUMBER/MAX(sub.ID) theo (REF_TYPE, REF_ID)); so sánh sau khi ép sang số nguyên lớn. `rpt_input_submission_id` là id đại diện, không dùng để xếp thứ tự lần nộp.',
    sc_code                                      String                  COMMENT 'Mã CTCK.',
    sc_nm                                        Nullable(String)        COMMENT 'Tên viết tắt hoặc tên đầy đủ của CTCK.',
    rpt_code                                     String                  COMMENT 'Mã biểu mẫu báo cáo (ví dụ: BCTCHN, BCTCRL, THSLCBPHCP...).',
    rpt_year                                     Int64                   COMMENT 'Năm báo cáo.',
    rpt_period                                   String                  COMMENT 'Kỳ báo cáo (QUY, THANG, NAM, NGAY).',
    period_nbr                                   Nullable(Int64)         COMMENT 'Số thứ tự kỳ (1-4 hoặc 1-12).',
    sheet_id                                     Nullable(String)        COMMENT 'Định danh sheet trong biểu mẫu eForm.',
    sheet_code                                   Nullable(String)        COMMENT 'Mã sheet nghiệp vụ của biểu mẫu eForm động (SHEETS_JSON.sheetCode), lấy từ cấu hình biểu mẫu (FORM_REPORT_DEEP_CONFIG) theo ĐÚNG bản biểu mẫu (`sc_rpt_id`) và `sheet_id` — ví dụ II.2 (cổ đông/thành viên góp vốn ≥ 5% vốn điều lệ, BCTHHD_CTCK), II.4, II.5, 06620, 06608, TTC_T. Cùng `cell_id` mang nghĩa khác nhau giữa các sheet của cùng biểu mẫu nên KPI lọc theo (rpt_code, sheet_code, cell_id). NULL khi sheet_id chưa có cấu hình sheet. [MỚI 2026-10-28, O_QLKD_63] Thêm cho khối Cổ đông lớn Nhóm 31 (BA dòng 172 lọc sheetCode = II.2); cột này phụ thuộc hàm vào (sc_rpt_id, sheet_id) nên KHÔNG vào khóa, không đổi grain.',
    section_id                                   Nullable(String)        COMMENT 'Định danh section trong biểu mẫu eForm.',
    cell_id                                      String                  COMMENT 'Mã ô dữ liệu trong biểu mẫu (tọa độ cell).',
    row_nbr                                      Nullable(Int64)         COMMENT 'Số thứ tự dòng dữ liệu (đối với bảng động/lưới).',
    item_val                                     Nullable(String)        COMMENT 'Giá trị ô dữ liệu nhập vào (dạng văn bản gốc).',
    submission_dt                                Nullable(Date)          COMMENT 'Ngày nộp báo cáo.',
    submission_deadline_dt                       Nullable(Date)          COMMENT 'Hạn nộp báo cáo định kỳ theo quy định.',
    submission_status_code                       Nullable(String)        COMMENT 'Trạng thái nộp báo cáo định kỳ.',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu.'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (rpt_cell_val_id)
COMMENT 'Flat table — Securities Company Report Data — raw data 102 bieu mau bao cao dinh ky'
;


-- ============================================================
-- 18. OPERATIONAL: qlkd_opr_securities_company_financial_report_hist_flat
--    Securities Company Financial Report History — lich su BCTC cua CTCK
--    Grain: 1 CTCK x 1 ky bao cao tai chinh x 1 ma bieu mau (rpt_code)
--    Joins: không JOIN dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_securities_company_financial_report_hist_flat ON CLUSTER 'my_cluster'
(
    -- From: OPR_SECURITIES_COMPANY_FINANCIAL_REPORT_HIST
    fin_rpt_hist_id                              String                  COMMENT 'Khóa chính lịch sử báo cáo tài chính.',
    sc_code                                      String                  COMMENT 'Mã CTCK.',
    sc_nm                                        Nullable(String)        COMMENT 'Tên CTCK.',
    rpt_year                                     Int64                   COMMENT 'Năm báo cáo.',
    rpt_period                                   String                  COMMENT 'Kỳ báo cáo (QUY, NAM, BAN_NIEN).',
    rpt_code                                     String                  COMMENT '[MỚI 2026-09-18] Mã biểu mẫu báo cáo: BCTCHN=hợp nhất, BCTCRL=riêng lẻ, BCTCRLCTCK, BCTHHDKD_TH. Thuộc NK — cùng (CTCK, kỳ) có thể có cả hai bản.',
    period_nbr                                   Nullable(Int64)         COMMENT 'Số thứ tự kỳ (1-4).',
    revenue_amt                                  Nullable(Decimal(23,2)) COMMENT 'Doanh thu (tỷ VNĐ).',
    profit_after_tax_amt                         Nullable(Decimal(23,2)) COMMENT 'Lợi nhuận sau thuế (tỷ VNĐ).',
    roa_rate                                     Nullable(Decimal(23,2)) COMMENT 'Tỷ suất sinh lời trên tổng tài sản ROA (%).',
    roe_rate                                     Nullable(Decimal(23,2)) COMMENT 'Tỷ suất sinh lời trên vốn chủ sở hữu ROE (%).',
    submission_dt                                Nullable(Date)          COMMENT 'Ngày nộp báo cáo.',
    submission_status_code                       Nullable(String)        COMMENT 'Trạng thái báo cáo: 1=Đã gửi/Đúng hạn, 2=Đã duyệt/Gửi muộn.',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu.',
    preferred_report_ind                         Nullable(String)        COMMENT 'Cờ báo cáo được ưu tiên theo logic BA: 1 = dòng thuộc BCTCHN, hoặc BCTCRL của CTCK KHÔNG có BCTCHN (trạng thái 1/2) cùng kỳ; 0 = BCTCRL của CTCK đã có BCTCHN cùng kỳ (BA: chỉ lấy BCTCRL cho CTCK không nộp BCTCHN — CTE ctck_co_hn). KPI đo/lịch sử lọc = 1 để không cộng đôi HN và RL. ETL: cửa sổ trên các dòng cùng CTCK + năm + loại kỳ + kỳ.'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (fin_rpt_hist_id)
COMMENT 'Flat table — Securities Company Financial Report History — lich su BCTC cua CTCK (grain them rpt_code tu 2026-09-18)'
;


-- ============================================================
-- 19. OPERATIONAL: qlkd_opr_securities_company_practitioner_profile_flat
--    Securities Company Practitioner Profile — ho so nguoi hanh nghe theo CTCK
--    Grain: 1 CTCK x 1 ma bieu mau x 1 ky bao cao (ban nop moi nhat)
--    Joins: không JOIN dimension
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_securities_company_practitioner_profile_flat ON CLUSTER 'my_cluster'
(
    -- From: OPR_SECURITIES_COMPANY_PRACTITIONER_PROFILE
    prac_profile_id                              String                  COMMENT 'Khóa chính hồ sơ người hành nghề chứng khoán — 1 CTCK × 1 mã biểu mẫu × 1 kỳ báo cáo (bản nộp mới nhất).',
    sc_code                                      String                  COMMENT 'Mã CTCK.',
    sc_nm                                        Nullable(String)        COMMENT 'Tên CTCK.',
    rpt_code                                     String                  COMMENT 'Mã biểu mẫu báo cáo định kỳ chứa số liệu nhân sự: BCTHHD_CTCK (Nhóm 28/29) hoặc BCHDPS (Nhóm 30). Cùng mã ô (VD TS017) mang nghĩa khác nhau giữa các biểu mẫu nên phải là một phần của khóa.',
    legal_basis                                  Nullable(String)        COMMENT 'Căn cứ pháp lý của biểu mẫu báo cáo (trường LEGAL_BASIS của biểu mẫu, VD 121/2020/TT-BTC, 102/2025/TT-BTC). Cùng mã biểu mẫu (BCTHHD_CTCK) có nhiều bản theo từng thông tư; SQL BA Nhóm 28/29 chỉ đọc bản `121/2020/TT-BTC` nên KPI lọc `legal_basis LIKE %121/2020/TT-BTC%` ([MỚI 2026-10-27, O_QLKD_64]). Là một phần khóa dòng để không gộp chéo thông tư.',
    rpt_year                                     Int64                   COMMENT 'Năm báo cáo.',
    rpt_period_tp_code                           String                  COMMENT 'Loại kỳ báo cáo (NAM, QUY, THANG…) — sc_periodic_report.rpt_period. BA STT 28 lọc THANG (sheet TTC_T, BA 24/10); BA STT 29/30 lọc NAM.',
    period_nbr                                   Int64                   COMMENT 'Kỳ báo cáo.',
    total_employee_cnt                           Nullable(Int64)         COMMENT 'Tổng số người lao động tại CTCK — BCTHHD_CTCK ô TS001 của kỳ THANG (BA STT 28 dòng 155, BA 24/10: sheet TTC_T; trước đây TS017 sheet TTC_N kỳ Năm). Chỉ có giá trị ở dòng kỳ THANG (TS001 kỳ QUY là vốn điều lệ).',
    licensed_practitioner_cnt                    Nullable(Int64)         COMMENT 'Số lao động có chứng chỉ hành nghề — BCTHHD_CTCK ô TS002 của kỳ THANG (BA STT 28 dòng 156, BA 24/10: sheet TTC_T; trước đây TS018).',
    unlicensed_practitioner_cnt                  Nullable(Int64)         COMMENT 'Số lao động chưa có chứng chỉ hành nghề = TS001 − TS002 của BCTHHD_CTCK kỳ THANG (BA STT 28 dòng 157, BA 24/10); NULL nếu thiếu 1 trong 2 ô.',
    brokerage_practitioner_cnt                   Nullable(Int64)         COMMENT 'Số người hành nghề bộ phận môi giới — BCTHHD_CTCK ô TS107 (BA STT 29 dòng 160; sheet II.1, kỳ Năm).',
    underwriting_practitioner_cnt                Nullable(Int64)         COMMENT 'Số người hành nghề bộ phận bảo lãnh phát hành — BCTHHD_CTCK ô TS115 (BA STT 29 dòng 161).',
    advisory_practitioner_cnt                    Nullable(Int64)         COMMENT 'Số người hành nghề bộ phận tư vấn đầu tư — BCTHHD_CTCK ô TS119 (BA STT 29 dòng 162).',
    proprietary_practitioner_cnt                 Nullable(Int64)         COMMENT 'Số người hành nghề bộ phận tự doanh — BCTHHD_CTCK ô TS111 (BA STT 29 dòng 163).',
    deriv_brokerage_practitioner_cnt             Nullable(Int64)         COMMENT 'Số người hành nghề liên quan CK phái sinh — dịch vụ môi giới — BCHDPS ô TS009 (BA STT 30 dòng 166; sheet 01, k',
    deriv_advisory_practitioner_cnt              Nullable(Int64)         COMMENT 'Số người hành nghề liên quan CK phái sinh — dịch vụ tư vấn — BCHDPS ô TS017 (BA STT 30 dòng 167).',
    deriv_proprietary_practitioner_cnt           Nullable(Int64)         COMMENT 'Số người hành nghề liên quan CK phái sinh — dịch vụ tự doanh — BCHDPS ô TS013 (BA STT 30 dòng 168).',
    submission_dt                                Nullable(Date)          COMMENT 'Ngày nộp báo cáo (TRUNC(SENT_AT)) — chỉ dùng khử trùng khi nhiều báo cáo định kỳ cùng khóa. Không còn là trục as-of của KPI Nhóm 28–30 (BA 24/10 đổi sang END_DATE, xem end_dt).',
    end_dt                                       Nullable(Date)          COMMENT 'Ngày kết thúc kỳ báo cáo (BA 24/10: TRUNC(END_DATE)) — trục as-of của KPI Nhóm 28–30: lấy báo cáo có ngày kết thúc kỳ gần nhất <= ngày chọn của từng CTCK (CTE latest_per_ctck: ORDER BY END_DATE DESC, FORM_REPORT_ID DESC).',
    submission_status_code                       Nullable(String)        COMMENT 'Trạng thái nộp báo cáo: 1 = Đã gửi/Đúng hạn, 2 = Đã duyệt/Gửi muộn (BA: RECORD_STATUS IN (1,2)) — cùng từ điển với Fact Securities Company Financial Structure Snapshot.',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu. ETL: chỉ BCTHHD_CTCK/BCHDPS, khử trùng bản nộp mới nhất (xem LLD).'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (prac_profile_id)
COMMENT 'Flat table — Securities Company Practitioner Profile — ho so nguoi hanh nghe theo CTCK'
;


-- ==========================================================
-- 20. OPERATIONAL: qlkd_opr_securities_company_organization_unit_service_flat
--    opr_securities_company_organization_unit_service — sinh tự động từ master registry + Entities.csv
--    Joins: không JOIN dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_securities_company_organization_unit_service_flat ON CLUSTER 'my_cluster'
(
    -- From: OPR_SECURITIES_COMPANY_ORGANIZATION_UNIT_SERVICE
    organization_unit_service_id                 String                  COMMENT 'PK — Driving: sc_ou_x_cl_sc_firm_service_relationship (bộ Phòng giao dịch, mỗi dòng = 1 PGD × 1 dịch vụ được cấp phép). Surrogate sinh từ toàn bộ BK và src_stm_code.',
    sc_ou_code                                   String                  COMMENT 'Mã đơn vị (ID nguồn) — BK 1/3. ID chỉ duy nhất trong từng loại đơn vị, không duy nhất giữa Chi nhánh và Phòng giao dịch nên BK phải kèm loại đơn vị.',
    cl_sc_firm_service_code                      String                  COMMENT 'Mã dịch vụ/nghiệp vụ được cấp phép cho PGD — BK 3/3.',
    sc_code                                      String                  COMMENT 'Mã CTCK sở hữu đơn vị.',
    ou_tp_code                                   String                  COMMENT 'Loại đơn vị: BRANCH=Chi nhánh; TRANSACTION_OFFICE=Phòng giao dịch — BK 2/3, phân biệt các đơn vị trùng ID giữa hai loại.',
    catalog_code                                 Nullable(String)        COMMENT 'Mã danh mục của dịch vụ (phân loại nghiệp vụ cơ sở, dịch vụ tài chính, phái sinh).',
    decision_dt                                  Nullable(Date)          COMMENT 'Ngày thành lập của đơn vị (ngày ban hành quyết định) — mốc xác định đơn vị đã tồn tại tại một ngày báo cáo.',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn dữ liệu.'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (organization_unit_service_id)
COMMENT 'Flat table — opr_securities_company_organization_unit_service — sinh tự động từ master registry + Entities.csv'
;


-- ============================================================
-- 21. DIMENSION (bộ lọc): qlkd_securities_service_cl_dim_flat
--     Securities Service Classification Dimension — danh mục dịch vụ/nghiệp vụ kinh doanh chứng khoán của CTCK
--     Nguồn: datamart.securities_service_cl_dim (Atomic cl_securities_company_firm_service ← SCMS.CAT_SERVICE_LEGAL_CAPITAL)
--     Grain: 1 row / dịch vụ - nghiệp vụ kinh doanh chứng khoán (BK: cl_sc_firm_service_code)
--     Mục đích: bảng danh mục phục vụ BỘ LỌC cho dev — chọn Loại danh mục (catalog_tp: NGHIEP_VU/DICH_VU) → Nhóm (catalog_code) →
--               Loại nghiệp vụ cơ sở/phái sinh (application_tp_code) → mã/tên dịch vụ. JOIN với flat #6
--               (qlkd_fct_securities_company_service_assignment_snpst_flat) qua securities_service_cl_dim_id, hoặc với flat #20
--               (qlkd_opr_securities_company_organization_unit_service_flat) qua cl_sc_firm_service_code / catalog_code.
--     Ngoại lệ Phase 3: flat cho Dimension (mặc định chỉ fact/operational) — theo yêu cầu Data Modeler 2026-10-16, cùng tiền lệ Common/cl_flat.
--     Không phân vùng theo ngày (bảng danh mục, nạp lại toàn bộ mỗi lần ETL).
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_securities_service_cl_dim_flat ON CLUSTER 'my_cluster'
(
    -- From: DIMENSION Securities Service Classification Dimension
    securities_service_cl_dim_id       String                  COMMENT 'PK — Surrogate Key từ datamart.securities_service_cl_dim; khóa JOIN với FK securities_service_cl_dim_id của flat #6',
    cl_sc_firm_service_code            String                  COMMENT 'BK — Mã dịch vụ/nghiệp vụ kinh doanh chứng khoán — giá trị lọc',
    cl_sc_firm_service_nm              String                  COMMENT 'Tên dịch vụ/nghiệp vụ kinh doanh chứng khoán — nhãn hiển thị của bộ lọc',
    description                        Nullable(String)        COMMENT 'Mô tả chi tiết dịch vụ/nghiệp vụ.',
    catalog_tp                         Nullable(String)        COMMENT 'Loại danh mục: nghiệp vụ (NGHIEP_VU) hay dịch vụ (DICH_VU) — bộ lọc cấp 1.',
    catalog_code                       Nullable(String)        COMMENT 'Mã danh mục chi tiết — dùng lọc nhóm dịch vụ/nghiệp vụ trên báo cáo (VD: MG/BLPH/TVDT/TD/02/01/04/MGPS/TVDTPS/TDPS).',
    application_tp_code                Nullable(String)        COMMENT 'Loại nghiệp vụ kinh doanh: cơ sở hoặc phái sinh — chỉ có ý nghĩa với danh mục nghiệp vụ (catalog_tp = NGHIEP_VU).',
    legal_capital_amt                  Nullable(Decimal(23,2)) COMMENT 'Vốn pháp định tối thiểu theo quy định cho tổ hợp dịch vụ/nghiệp vụ này.',
    src_stm_code                       String                  COMMENT 'Mã hệ thống nguồn dữ liệu.'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (cl_sc_firm_service_code, securities_service_cl_dim_id)
COMMENT 'Flat table — Securities Service Classification Dimension (bộ lọc dịch vụ/nghiệp vụ kinh doanh chứng khoán CTCK; 1 dòng / dịch vụ-nghiệp vụ)'
;


-- ==========================================================
-- 23. FACT: qlkd_fct_securities_company_brokerage_market_share_snpst_flat
--    fct_securities_company_brokerage_market_share_snpst — sinh tự động từ master registry + Entities.csv
--    Joins: Calendar Date Dimension, Securities Company Dimension
-- ==========================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_fct_securities_company_brokerage_market_share_snpst_flat ON CLUSTER 'my_cluster'
(
    -- From: FCT_SECURITIES_COMPANY_BROKERAGE_MARKET_SHARE_SNPST
    snpst_dt_dim_id                              String                  COMMENT 'FK ngày snapshot D (ETL runtime date). Atomic brokerage_market_share là entity VSDC theo mapping md (Bảng 20/2',
    securities_company_dim_id                    String                  COMMENT 'FK CTCK (thành viên môi giới) — BA: JOIN SC_FIRM_INFO f ON f.CODE = bms.member_code.',
    report_quarter                               String                  COMMENT 'Kỳ quý của báo cáo thị phần, nhãn Qn/yyyy (BA: report_quarter) — trục K_QLKD_92.',
    trading_venue_nm                             Nullable(String)        COMMENT 'Sàn/nhóm giao dịch hiển thị: HOSE - CP niêm yết, HNX - CP niêm yết, UPCOM - CP đăng ký giao dịch, HNX - Chứng ',
    market_share_pct                             Nullable(Decimal(5,2))  COMMENT 'Thị phần môi giới theo giá trị giao dịch (%) — BA: market_share_by_value / thi_phan_pct.',
    src_stm_code                                 String                  COMMENT 'Mã hệ thống nguồn: HOSE_BROKERAGE_MARKET_SHARE (HOSE) / HNX_BROKERAGE_MARKET_SHARE (HNX) — O_QLKD_46.',

    -- From: CALENDAR DATE DIMENSION
    cdr_dt                                       Nullable(Date)          COMMENT 'NK — ngày lịch dùng để join từ Fact — từ Calendar Date Dimension',
    year                                         Nullable(Int64)         COMMENT 'Năm (YYYY) — từ Calendar Date Dimension',
    quarter                                      Nullable(Int64)         COMMENT 'Quý (1–4) — từ Calendar Date Dimension',
    month                                        Nullable(Int64)         COMMENT 'Tháng (1–12) — từ Calendar Date Dimension',
    day_of_week                                  Nullable(Int64)         COMMENT 'Thứ trong tuần (1=Chủ nhật, 7=Thứ bảy) — từ Calendar Date Dimension',
    is_weekend                                   Nullable(String)        COMMENT '(Sửa 2026-07-17) Y nếu là ngày cuối tuần (thứ 7 hoặc CN), N nếu không — từ Calendar Date Dimension',
    holiday_flag                                 Nullable(String)        COMMENT '(Sửa 2026-07-20) Cờ đánh dấu ngày nghỉ — Y nếu là ngày nghỉ, N nếu không. Chỉ đánh dấu nghỉ/không nghỉ, không  — từ Calendar Date Dimension',
    is_trading_date                              Nullable(String)        COMMENT '(Sửa 2026-10-12, BA đổi rule lần 2 — thay rule 2026-10-09 "cả hai nguồn") Y nếu ngày lịch có bản ghi ở ÍT NHẤT — từ Calendar Date Dimension',

    -- From: SECURITIES COMPANY DIMENSION
    sc_id                                        Nullable(String)        COMMENT 'Business Id CTCK (Atomic surrogate — dùng làm reference nghiệp vụ theo HLD). — từ Securities Company Dimension',
    sc_code                                      Nullable(String)        COMMENT 'Mã định danh CTCK — Natural Key. — từ Securities Company Dimension',
    sc_nm                                        Nullable(String)        COMMENT 'Tên đầy đủ CTCK bằng tiếng Việt. — từ Securities Company Dimension',
    sc_short_nm                                  Nullable(String)        COMMENT 'Tên viết tắt CTCK (VD: SSI, VPS, MBS). — từ Securities Company Dimension',
    company_tp_code                              Nullable(String)        COMMENT 'Loại hình doanh nghiệp CTCK. — từ Securities Company Dimension',
    company_tp_nm                                Nullable(String)        COMMENT 'Tên loại hình doanh nghiệp CTCK — LEFT JOIN cl_value theo scheme SCMS_COMPANY_TYPE (SCMS.CAT_COMPANY_TYPE). Có — từ Securities Company Dimension',
    company_status_code                          Nullable(String)        COMMENT '7 nhóm trạng thái CTCK (Đã bị thu hồi/Hoạt động bình thường/Kiểm soát đặc biệt/Kiểm soát/Cảnh báo/Đình chỉ hoạ — từ Securities Company Dimension',
    company_status_nm                            Nullable(String)        COMMENT 'Nhãn tiếng Việt nhóm trạng thái CTCK (Đã bị thu hồi/Hoạt động bình thường/Kiểm soát đặc biệt/Kiểm soát/Cảnh báo/Đình chỉ hoạt động/Trạng thái khác); NULL khi CTCK không có trạng thái — từ Securities Company Dimension',
    is_listed_indicator                          Nullable(UInt8)         COMMENT 'Cờ niêm yết trên sàn. — từ Securities Company Dimension',
    stock_exchange_nm                            Nullable(String)        COMMENT 'Sàn niêm yết (HOSE/HNX/UPCOM). — từ Securities Company Dimension',
    securities_c_dim_src_stm_code                Nullable(String)        COMMENT 'Mã hệ thống nguồn dữ liệu. — từ Securities Company Dimension'
)
ENGINE = ReplicatedReplacingMergeTree()
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), snpst_dt_dim_id)
COMMENT 'Flat table — fct_securities_company_brokerage_market_share_snpst — sinh tự động từ master registry + Entities.csv'
;
