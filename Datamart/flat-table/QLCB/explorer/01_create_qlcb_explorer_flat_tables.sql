-- ============================================================
-- QLCB Explorer Flat Tables — CREATE
-- Module: Quản lý chào bán chứng khoán (QLCB) — Data Explorer
-- Tạo 2026-11-17. 1 bảng Operational dạng DỌC (id_chitieu/gia_tri), thiết kế lại từ DDL ClickHouse đang chạy (tên chưa theo chuẩn Datamart):
--   dwh_prod.bc_qlcb  ->  datamart.qlcb_opr_securities_offering_explorer_val_flat
--       đổi tên cột: licensed_object->plan_single_object, outcome_object->result_single_object, id_chitieu->indicator_id, gia_tri->indicator_val, updated_at->ds_etl_pcs_tms
--       giữ nguyên : ds_snpst_dt, cdr_dt, submission_dt, certificate_dt, official_letter_dt, equity_listing_exchange_code, classification_business_line_nm, official_letter_nbr, certificate_nbr, offering_method_nm, offering_purpose, processor_user_nm_snpst, public_company_code, public_company_nm, equity_ticker_symbol, securities_tp_nm
-- Khuôn: NDTNN/QLQ/GSTT Data Explorer (indicator_id, indicator_val, ds_etl_pcs_tms dùng chung tên với QLQ/NDTNN để BI Data Explorer đọc chung).
-- Chỉ ĐỔI TÊN bảng/cột; giữ nguyên số cột, thứ tự cột, kiểu và DEFAULT của DDL gốc (đã kiểm máy). Đích: database datamart (bảng gốc ở dwh_prod/default).
--
-- ENGINE / PARTITION BY / ORDER BY là ĐỀ XUẤT (DDL gốc không kèm; cần SHOW CREATE TABLE bảng gốc để đối chiếu). Chưa kiểm trên ClickHouse thật.
-- ReplacingMergeTree dedup theo ORDER BY: key gồm mọi cột chiều + indicator_id (cột tên/nhãn phụ thuộc hàm không đưa vào key); đọc bằng FINAL.
-- licensed_object -> plan_single_object, outcome_object -> result_single_object: GIẢ ĐỊNH cùng nghĩa 2 cột đã có ở qlcb_opr_securities_offering_360_profile_flat (Đối tượng cấp phép / Đối tượng kết quả) — chờ xác nhận.
-- processor_user_nm_snpst (tên chuyên viên xử lý) có sẵn ở bảng gốc; chưa nằm trong system/rules/pii_columns.yaml (cột cùng tên ở flat QLCB hiện hữu cũng chưa đăng ký) — Data Modeler/Security quyết định có mã hóa không trước khi viết INSERT.
--
-- TRẠNG THÁI: CHỈ CÓ DDL, nằm ở thư mục con explorer/ (cùng cách GSTT/buffer/, NDTNN/explorer/ trước đây) nên Gate 4 (chỉ quét 01_create*.sql ở thư mục module)
-- không đọc. Khi có job ODS + LLD + INSERT: chuyển các khối vào 01_create_*_flat_tables.sql, xóa thư mục explorer/. Chưa có bảng chỉ tiêu (metadata) cho phân hệ này.
-- Triển khai: bảng cũ đang có dữ liệu nên tạo bảng mới song song rồi chuyển BI sang tên mới; KHÔNG DROP bảng cũ trước khi BI chuyển xong.
-- Số khối #n là tạm (nối tiếp khối cuối của 01_create_*_flat_tables.sql hiện hành), đánh lại khi chuyển vào.
-- ============================================================


-- ============================================================
-- 6. OPERATIONAL: qlcb_opr_securities_offering_explorer_val_flat
--    Chào bán chứng khoán — dạng dọc (1 dòng = 1 chỉ tiêu × 1 hồ sơ/đợt chào bán).
--    Thay dwh_prod.bc_qlcb (21 cột). Chưa có LLD/Entities/INSERT — chờ job ODS của dev.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlcb_opr_securities_offering_explorer_val_flat ON CLUSTER 'my_cluster'
(
    ds_snpst_dt                                  Nullable(Date)          COMMENT 'Ngày snapshot ETL',
    cdr_dt                                       Nullable(Date)          COMMENT 'Ngày lịch của chỉ tiêu (cột Data Explorer lọc thời gian)',
    submission_dt                                Nullable(Date)          COMMENT 'Ngày nộp hồ sơ chào bán',
    certificate_dt                               Nullable(Date)          COMMENT 'Ngày cấp giấy chứng nhận',
    official_letter_dt                           Nullable(Date)          COMMENT 'Ngày công văn',
    equity_listing_exchange_code                 String                  COMMENT 'Sàn niêm yết',
    classification_business_line_nm              String                  COMMENT 'Tên ngành kinh tế',
    official_letter_nbr                          String                  COMMENT 'Số công văn gửi công ty',
    certificate_nbr                              String                  COMMENT 'Số giấy chứng nhận',
    offering_method_nm                           String                  COMMENT 'Hình thức chào bán',
    plan_single_object                           String                  COMMENT 'Đối tượng cấp phép (licensed_object cũ) — GIẢ ĐỊNH cùng nghĩa plan_single_object của qlcb_opr_securities_offering_360_profile_flat',
    offering_purpose                             String                  COMMENT 'Mục đích sử dụng vốn',
    result_single_object                         String                  COMMENT 'Đối tượng kết quả (outcome_object cũ) — GIẢ ĐỊNH cùng nghĩa result_single_object của qlcb_opr_securities_offering_360_profile_flat',
    processor_user_nm_snpst                      String                  COMMENT 'Chuyên viên xử lý (snapshot)',
    public_company_code                          String                  COMMENT 'Mã công ty đại chúng',
    public_company_nm                            String                  COMMENT 'Tên công ty đại chúng',
    equity_ticker_symbol                         String                  COMMENT 'Mã chứng khoán',
    securities_tp_nm                             String                  COMMENT 'Tên loại chứng khoán chào bán',
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (id_chitieu cũ) — khóa nối với bảng chỉ tiêu của Data Explorer (chưa có DDL bảng chỉ tiêu cho phân hệ này)',
    indicator_val                                Float64                 COMMENT 'Giá trị chỉ tiêu (gia_tri cũ)',
    ds_etl_pcs_tms                               DateTime DEFAULT now()  COMMENT 'Thời điểm ETL ghi dòng (updated_at cũ)'
)
ENGINE = ReplicatedReplacingMergeTree(ds_etl_pcs_tms)
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(ds_snpst_dt), assumeNotNull(cdr_dt), public_company_code, certificate_nbr, official_letter_nbr, offering_method_nm, securities_tp_nm, indicator_id)
COMMENT 'Flat Data Explorer QLCB — chào bán chứng khoán (thay dwh_prod.bc_qlcb)'
;
