-- ============================================================
-- GSDC Explorer Flat Tables — CREATE
-- Module: Giám sát doanh nghiệp đại chúng (GSDC) — Data Explorer
-- Tạo 2026-11-17. 4 bảng Operational dạng DỌC (id_chitieu/gia_tri), thiết kế lại từ DDL ClickHouse đang chạy (tên chưa theo chuẩn Datamart):
--   dwh_prod.bc_gsdc_cd  ->  datamart.gsdc_opr_public_company_evaluation_explorer_val_flat
--       đổi tên cột: id_chitieu->indicator_id, gia_tri->indicator_val, updated_at->ds_etl_pcs_tms
--       giữ nguyên : ds_snpst_dt, evaluation_year, evaluation_month, equity_listing_exchange_code, business_line_level_1_code, classification_business_line_nm, equity_ticker_symbol, public_company_code, public_company_nm
--   dwh_prod.bc_gsdc_ny  ->  datamart.gsdc_opr_public_company_listing_explorer_val_flat
--       đổi tên cột: id_chitieu->indicator_id, gia_tri->indicator_val, updated_at->ds_etl_pcs_tms
--       giữ nguyên : ds_snpst_dt, snpst_cdr_dt, equity_listing_exchange_code, business_line_level_1_code, classification_business_line_nm, equity_ticker_symbol, public_company_code, public_company_nm
--   dwh_prod.bc_gsdc_tc  ->  datamart.gsdc_opr_public_company_financial_explorer_val_flat
--       đổi tên cột: id_chitieu->indicator_id, gia_tri->indicator_val, updated_at->ds_etl_pcs_tms
--       giữ nguyên : ds_snpst_dt, rpt_year, rpt_quarter, column_description_reference, fr_catalog_enterprise_tp_code, equity_listing_exchange_code, business_line_level_1_code, classification_business_line_nm, equity_ticker_symbol, public_company_code, public_company_nm
--   dwh_prod.bc_gsdc_th  ->  datamart.gsdc_opr_public_company_financial_summary_explorer_val_flat
--       đổi tên cột: id_chitieu->indicator_id, gia_tri->indicator_val, updated_at->ds_etl_pcs_tms
--       giữ nguyên : ds_snpst_dt, rpt_year, rpt_quarter, equity_listing_exchange_code, business_line_level_1_code, classification_business_line_nm, enterprise_tp_code, enterprise_tp_nm
-- Khuôn: NDTNN/QLQ/GSTT Data Explorer (indicator_id, indicator_val, ds_etl_pcs_tms dùng chung tên với QLQ/NDTNN để BI Data Explorer đọc chung).
-- Chỉ ĐỔI TÊN bảng/cột; giữ nguyên số cột, thứ tự cột, kiểu và DEFAULT của DDL gốc (đã kiểm máy). Đích: database datamart (bảng gốc ở dwh_prod/default).
--
-- ENGINE / PARTITION BY / ORDER BY là ĐỀ XUẤT (DDL gốc không kèm; cần SHOW CREATE TABLE bảng gốc để đối chiếu). Chưa kiểm trên ClickHouse thật.
-- ReplacingMergeTree dedup theo ORDER BY: key gồm mọi cột chiều + indicator_id (cột tên/nhãn phụ thuộc hàm không đưa vào key); đọc bằng FINAL.
-- Cả 4 bảng gốc đã dùng tên cột kiểu Datamart/Atomic (ds_snpst_dt, rpt_year, equity_*, public_company_*); chỉ đổi 3 cột kỹ thuật/chỉ tiêu (id_chitieu, gia_tri, updated_at) và tên bảng.
-- ds_snpst_dt đứng đầu ORDER BY (giữ nhiều snapshot theo ngày như các flat gsdc_fct_*_snpst_flat); bỏ ds_snpst_dt khỏi ORDER BY nếu chỉ cần bản mới nhất.
-- Khác biệt kiểu cần xác nhận: bc_gsdc_cd.gia_tri là String (3 bảng còn lại Float64); evaluation_month Int32 ở đây nhưng Nullable(String) ở gsdc_fct_public_company_*_evaluation_snpst_flat.
--
-- TRẠNG THÁI: CHỈ CÓ DDL, nằm ở thư mục con explorer/ (cùng cách GSTT/buffer/, NDTNN/explorer/ trước đây) nên Gate 4 (chỉ quét 01_create*.sql ở thư mục module)
-- không đọc. Khi có job ODS + LLD + INSERT: chuyển các khối vào 01_create_*_flat_tables.sql, xóa thư mục explorer/. Chưa có bảng chỉ tiêu (metadata) cho phân hệ này.
-- Triển khai: bảng cũ đang có dữ liệu nên tạo bảng mới song song rồi chuyển BI sang tên mới; KHÔNG DROP bảng cũ trước khi BI chuyển xong.
-- Số khối #n là tạm (nối tiếp khối cuối của 01_create_*_flat_tables.sql hiện hành), đánh lại khi chuyển vào.
-- ============================================================


-- ============================================================
-- 21. OPERATIONAL: gsdc_opr_public_company_evaluation_explorer_val_flat
--    Đánh giá công ty đại chúng theo kỳ (tháng) — dạng dọc (1 dòng = 1 chỉ tiêu × 1 công ty/nhóm công ty).
--    Thay dwh_prod.bc_gsdc_cd (12 cột). Chưa có LLD/Entities/INSERT — chờ job ODS của dev.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gsdc_opr_public_company_evaluation_explorer_val_flat ON CLUSTER 'my_cluster'
(
    ds_snpst_dt                                  Nullable(Date)          COMMENT 'Ngày snapshot ETL (giữ nguyên cột gốc; cùng tên ds_snpst_dt của các flat GSDC)',
    evaluation_year                              Int32                   COMMENT 'Năm của kỳ đánh giá',
    evaluation_month                             Int32                   COMMENT 'Tháng của kỳ đánh giá — kiểu Int32 theo bảng gốc (cột cùng tên ở gsdc_fct_public_company_*_evaluation_snpst_flat là Nullable(String))',
    equity_listing_exchange_code                 String                  COMMENT 'Sàn niêm yết',
    business_line_level_1_code                   String                  COMMENT 'Ngành kinh tế cấp 1',
    classification_business_line_nm              String                  COMMENT 'Tên ngành kinh tế',
    equity_ticker_symbol                         String                  COMMENT 'Mã chứng khoán',
    public_company_code                          String                  COMMENT 'Mã công ty đại chúng',
    public_company_nm                            String                  COMMENT 'Tên công ty đại chúng',
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (id_chitieu cũ) — khóa nối với bảng chỉ tiêu của Data Explorer (chưa có DDL bảng chỉ tiêu cho phân hệ này)',
    indicator_val                                String                  COMMENT 'Giá trị chỉ tiêu dạng CHUỖI theo bảng gốc (gia_tri cũ; 3 bảng bc_gsdc_* còn lại dùng Float64) — chờ xác nhận có chỉ tiêu dạng nhãn không',
    ds_etl_pcs_tms                               DateTime DEFAULT now()  COMMENT 'Thời điểm ETL ghi dòng (updated_at cũ)'
)
ENGINE = ReplicatedReplacingMergeTree(ds_etl_pcs_tms)
PARTITION BY evaluation_year
ORDER BY (assumeNotNull(ds_snpst_dt), evaluation_year, evaluation_month, public_company_code, indicator_id)
COMMENT 'Flat Data Explorer GSDC — Đánh giá công ty đại chúng theo kỳ (tháng) (thay dwh_prod.bc_gsdc_cd)'
;


-- ============================================================
-- 22. OPERATIONAL: gsdc_opr_public_company_listing_explorer_val_flat
--    Công ty đại chúng — nhóm niêm yết (số liệu snapshot theo ngày lịch) — dạng dọc (1 dòng = 1 chỉ tiêu × 1 công ty/nhóm công ty).
--    Thay dwh_prod.bc_gsdc_ny (11 cột). Chưa có LLD/Entities/INSERT — chờ job ODS của dev.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gsdc_opr_public_company_listing_explorer_val_flat ON CLUSTER 'my_cluster'
(
    ds_snpst_dt                                  Nullable(Date)          COMMENT 'Ngày snapshot ETL (giữ nguyên cột gốc; cùng tên ds_snpst_dt của các flat GSDC)',
    snpst_cdr_dt                                 Nullable(Date)          COMMENT 'Ngày lịch của số liệu snapshot (as-of) — cùng tên snpst_cdr_dt của các flat Fact snapshot GSDC',
    equity_listing_exchange_code                 String                  COMMENT 'Sàn niêm yết',
    business_line_level_1_code                   String                  COMMENT 'Ngành kinh tế cấp 1',
    classification_business_line_nm              String                  COMMENT 'Tên ngành kinh tế',
    equity_ticker_symbol                         String                  COMMENT 'Mã chứng khoán',
    public_company_code                          String                  COMMENT 'Mã công ty đại chúng',
    public_company_nm                            String                  COMMENT 'Tên công ty đại chúng',
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (id_chitieu cũ) — khóa nối với bảng chỉ tiêu của Data Explorer (chưa có DDL bảng chỉ tiêu cho phân hệ này)',
    indicator_val                                Float64                 COMMENT 'Giá trị chỉ tiêu (gia_tri cũ)',
    ds_etl_pcs_tms                               DateTime DEFAULT now()  COMMENT 'Thời điểm ETL ghi dòng (updated_at cũ)'
)
ENGINE = ReplicatedReplacingMergeTree(ds_etl_pcs_tms)
PARTITION BY toYYYYMM(assumeNotNull(snpst_cdr_dt))
ORDER BY (assumeNotNull(ds_snpst_dt), assumeNotNull(snpst_cdr_dt), public_company_code, indicator_id)
COMMENT 'Flat Data Explorer GSDC — Công ty đại chúng — nhóm niêm yết (số liệu snapshot theo ngày lịch) (thay dwh_prod.bc_gsdc_ny)'
;


-- ============================================================
-- 23. OPERATIONAL: gsdc_opr_public_company_financial_explorer_val_flat
--    Công ty đại chúng — báo cáo tài chính theo quý — dạng dọc (1 dòng = 1 chỉ tiêu × 1 công ty/nhóm công ty).
--    Thay dwh_prod.bc_gsdc_tc (14 cột). Chưa có LLD/Entities/INSERT — chờ job ODS của dev.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gsdc_opr_public_company_financial_explorer_val_flat ON CLUSTER 'my_cluster'
(
    ds_snpst_dt                                  Nullable(Date)          COMMENT 'Ngày snapshot ETL (giữ nguyên cột gốc; cùng tên ds_snpst_dt của các flat GSDC)',
    rpt_year                                     Int32                   COMMENT 'Năm báo cáo tài chính',
    rpt_quarter                                  Int32                   COMMENT 'Quý báo cáo tài chính (1–4)',
    column_description_reference                 String                  COMMENT 'Tham chiếu mô tả cột của báo cáo tài chính (giữ nguyên cột gốc)',
    fr_catalog_enterprise_tp_code                String                  COMMENT 'Mã loại hình doanh nghiệp của danh mục báo cáo tài chính (giữ nguyên cột gốc)',
    equity_listing_exchange_code                 String                  COMMENT 'Sàn niêm yết',
    business_line_level_1_code                   String                  COMMENT 'Ngành kinh tế cấp 1',
    classification_business_line_nm              String                  COMMENT 'Tên ngành kinh tế',
    equity_ticker_symbol                         String                  COMMENT 'Mã chứng khoán',
    public_company_code                          String                  COMMENT 'Mã công ty đại chúng',
    public_company_nm                            String                  COMMENT 'Tên công ty đại chúng',
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (id_chitieu cũ) — khóa nối với bảng chỉ tiêu của Data Explorer (chưa có DDL bảng chỉ tiêu cho phân hệ này)',
    indicator_val                                Float64                 COMMENT 'Giá trị chỉ tiêu (gia_tri cũ)',
    ds_etl_pcs_tms                               DateTime DEFAULT now()  COMMENT 'Thời điểm ETL ghi dòng (updated_at cũ)'
)
ENGINE = ReplicatedReplacingMergeTree(ds_etl_pcs_tms)
PARTITION BY rpt_year
ORDER BY (assumeNotNull(ds_snpst_dt), rpt_year, rpt_quarter, public_company_code, fr_catalog_enterprise_tp_code, column_description_reference, indicator_id)
COMMENT 'Flat Data Explorer GSDC — Công ty đại chúng — báo cáo tài chính theo quý (thay dwh_prod.bc_gsdc_tc)'
;


-- ============================================================
-- 24. OPERATIONAL: gsdc_opr_public_company_financial_summary_explorer_val_flat
--    Công ty đại chúng — tổng hợp tài chính theo sàn × ngành × loại hình doanh nghiệp — dạng dọc (1 dòng = 1 chỉ tiêu × 1 công ty/nhóm công ty).
--    Thay dwh_prod.bc_gsdc_th (11 cột). Chưa có LLD/Entities/INSERT — chờ job ODS của dev.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.gsdc_opr_public_company_financial_summary_explorer_val_flat ON CLUSTER 'my_cluster'
(
    ds_snpst_dt                                  Nullable(Date)          COMMENT 'Ngày snapshot ETL (giữ nguyên cột gốc; cùng tên ds_snpst_dt của các flat GSDC)',
    rpt_year                                     Int32                   COMMENT 'Năm báo cáo',
    rpt_quarter                                  Int32                   COMMENT 'Quý báo cáo (1–4)',
    equity_listing_exchange_code                 String                  COMMENT 'Sàn niêm yết',
    business_line_level_1_code                   String                  COMMENT 'Ngành kinh tế cấp 1',
    classification_business_line_nm              String                  COMMENT 'Tên ngành kinh tế',
    enterprise_tp_code                           String                  COMMENT 'Loại hình doanh nghiệp (cùng tên enterprise_tp_code của Public Company Dimension flat)',
    enterprise_tp_nm                             String                  COMMENT 'Tên loại hình doanh nghiệp',
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (id_chitieu cũ) — khóa nối với bảng chỉ tiêu của Data Explorer (chưa có DDL bảng chỉ tiêu cho phân hệ này)',
    indicator_val                                Float64                 COMMENT 'Giá trị chỉ tiêu (gia_tri cũ)',
    ds_etl_pcs_tms                               DateTime DEFAULT now()  COMMENT 'Thời điểm ETL ghi dòng (updated_at cũ)'
)
ENGINE = ReplicatedReplacingMergeTree(ds_etl_pcs_tms)
PARTITION BY rpt_year
ORDER BY (assumeNotNull(ds_snpst_dt), rpt_year, rpt_quarter, equity_listing_exchange_code, business_line_level_1_code, enterprise_tp_code, indicator_id)
COMMENT 'Flat Data Explorer GSDC — Công ty đại chúng — tổng hợp tài chính theo sàn × ngành × loại hình doanh nghiệp (thay dwh_prod.bc_gsdc_th)'
;
