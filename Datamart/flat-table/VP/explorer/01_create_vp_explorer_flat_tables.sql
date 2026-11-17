-- ============================================================
-- VP Explorer Flat Tables — CREATE
-- Module: Thống kê thị trường chứng khoán (VP) — Data Explorer tổng hợp tài khoản nhà đầu tư
-- Tạo 2026-11-17. 2 bảng Operational dạng DỌC (id_chitieu/gia_tri), thiết kế lại từ DDL ClickHouse đang chạy (tên chưa theo chuẩn Datamart):
--   default.bc_tonghop_taikhoan_ps  ->  datamart.vp_opr_investor_account_movement_explorer_val_flat
--       đổi tên cột: id_chitieu->indicator_id, gia_tri->indicator_val, updated_at->ds_etl_pcs_tms
--       giữ nguyên : cdr_dt
--   default.bc_tonghop_taikhoan_cs  ->  datamart.vp_opr_investor_account_cumulative_explorer_val_flat
--       đổi tên cột: id_chitieu->indicator_id, gia_tri->indicator_val, updated_at->ds_etl_pcs_tms
--       giữ nguyên : cdr_dt, investor_tp_code
-- Khuôn: NDTNN/QLQ/GSTT Data Explorer (indicator_id, indicator_val, ds_etl_pcs_tms dùng chung tên với QLQ/NDTNN để BI Data Explorer đọc chung).
-- Chỉ ĐỔI TÊN bảng/cột; giữ nguyên số cột, thứ tự cột, kiểu và DEFAULT của DDL gốc (đã kiểm máy). Đích: database datamart (bảng gốc ở dwh_prod/default).
--
-- ENGINE / PARTITION BY / ORDER BY là ĐỀ XUẤT (DDL gốc không kèm; cần SHOW CREATE TABLE bảng gốc để đối chiếu). Chưa kiểm trên ClickHouse thật.
-- ReplacingMergeTree dedup theo ORDER BY: key gồm mọi cột chiều + indicator_id (cột tên/nhãn phụ thuộc hàm không đưa vào key); đọc bằng FINAL.
-- GIẢ ĐỊNH ps = phát sinh (mở/đóng trong ngày), cs = cuối kỳ (lũy kế) — theo Fact Investor Account Movement Snapshot (HLD VP: số TK mở, số TK đóng, lũy kế theo loại NĐT). Chờ xác nhận ý nghĩa 'ps'/'cs'.
-- Bảng ps không có investor_tp_code (loại NĐT có thể đã nằm trong indicator_id); bảng cs có investor_tp_code.
--
-- TRẠNG THÁI: CHỈ CÓ DDL, nằm ở thư mục con explorer/ (cùng cách GSTT/buffer/, NDTNN/explorer/ trước đây) nên Gate 4 (chỉ quét 01_create*.sql ở thư mục module)
-- không đọc. Khi có job ODS + LLD + INSERT: chuyển các khối vào 01_create_*_flat_tables.sql, xóa thư mục explorer/. Chưa có bảng chỉ tiêu (metadata) cho phân hệ này.
-- Triển khai: bảng cũ đang có dữ liệu nên tạo bảng mới song song rồi chuyển BI sang tên mới; KHÔNG DROP bảng cũ trước khi BI chuyển xong.
-- Số khối #n là tạm (nối tiếp khối cuối của 01_create_*_flat_tables.sql hiện hành), đánh lại khi chuyển vào.
-- ============================================================


-- ============================================================
-- 19. OPERATIONAL: vp_opr_investor_account_movement_explorer_val_flat
--    Tổng hợp tài khoản nhà đầu tư PHÁT SINH (ps) — dạng dọc (1 dòng = 1 chỉ tiêu × 1 ngày).
--    Thay default.bc_tonghop_taikhoan_ps (4 cột). Chưa có LLD/Entities/INSERT — chờ job ODS của dev.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.vp_opr_investor_account_movement_explorer_val_flat ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)          COMMENT 'Ngày lịch của số liệu (GIẢ ĐỊNH ngày phát sinh, cùng tên cdr_dt của Calendar Date Dimension)',
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (id_chitieu cũ) — khóa nối với bảng chỉ tiêu của Data Explorer (chưa có DDL bảng chỉ tiêu cho phân hệ này)',
    indicator_val                                Float64                 COMMENT 'Giá trị chỉ tiêu (gia_tri cũ)',
    ds_etl_pcs_tms                               DateTime DEFAULT now()  COMMENT 'Thời điểm ETL ghi dòng (updated_at cũ)'
)
ENGINE = ReplicatedReplacingMergeTree(ds_etl_pcs_tms)
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), indicator_id)
COMMENT 'Flat Data Explorer VP — tổng hợp tài khoản phát sinh (thay default.bc_tonghop_taikhoan_ps)'
;


-- ============================================================
-- 20. OPERATIONAL: vp_opr_investor_account_cumulative_explorer_val_flat
--    Tổng hợp tài khoản nhà đầu tư CUỐI KỲ (cs) theo loại nhà đầu tư — dạng dọc (1 dòng = 1 chỉ tiêu × 1 ngày × 1 loại NĐT).
--    Thay default.bc_tonghop_taikhoan_cs (5 cột). Chưa có LLD/Entities/INSERT — chờ job ODS của dev.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.vp_opr_investor_account_cumulative_explorer_val_flat ON CLUSTER 'my_cluster'
(
    cdr_dt                                       Nullable(Date)          COMMENT 'Ngày lịch của số liệu (GIẢ ĐỊNH ngày cuối kỳ, cùng tên cdr_dt của Calendar Date Dimension)',
    investor_tp_code                             String                  COMMENT 'Mã loại nhà đầu tư (VSDC: 3 Cá nhân trong nước, 4 Cá nhân nước ngoài, 5 Pháp nhân trong nước, 6 Pháp nhân nước ngoài) — cùng tên investor_tp_code ở vp_fct_investor_account_movement_snpst_flat',
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (id_chitieu cũ) — khóa nối với bảng chỉ tiêu của Data Explorer (chưa có DDL bảng chỉ tiêu cho phân hệ này)',
    indicator_val                                Float64                 COMMENT 'Giá trị chỉ tiêu (gia_tri cũ)',
    ds_etl_pcs_tms                               DateTime DEFAULT now()  COMMENT 'Thời điểm ETL ghi dòng (updated_at cũ)'
)
ENGINE = ReplicatedReplacingMergeTree(ds_etl_pcs_tms)
PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))
ORDER BY (assumeNotNull(cdr_dt), investor_tp_code, indicator_id)
COMMENT 'Flat Data Explorer VP — tổng hợp tài khoản cuối kỳ theo loại NĐT (thay default.bc_tonghop_taikhoan_cs)'
;
