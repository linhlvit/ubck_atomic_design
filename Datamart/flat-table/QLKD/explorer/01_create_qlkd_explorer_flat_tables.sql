-- ============================================================
-- QLKD Explorer Flat Tables — CREATE
-- Module: Quản lý kinh doanh chứng khoán (QLKD) — Data Explorer báo cáo định kỳ của CTCK / chi nhánh / VPĐD / ngân hàng lưu ký, thanh toán
-- Tạo 2026-11-17. 5 bảng Operational dạng DỌC (id_chitieu/gia_tri), thiết kế lại từ DDL ClickHouse đang chạy (tên chưa theo chuẩn Datamart):
--   dwh_prod.bc_cnctcknn  ->  datamart.qlkd_opr_foreign_securities_company_branch_explorer_val_flat
--       đổi tên cột: branch_name->branch_nm, report_year->rpt_year, report_period->rpt_period, period->period_val, form_report_id->form_rpt_id, row_order->dynamic_row_order, id_chitieu->indicator_id, gia_tri->indicator_val, updated_at->ds_etl_pcs_tms
--       giữ nguyên : submission_dt, object_id, object_code, entity_code
--   dwh_prod.bc_ctcktn  ->  datamart.qlkd_opr_domestic_securities_company_explorer_val_flat
--       đổi tên cột: firm_name->sc_nm, listing_exchange->equity_listing_exchange_code, business_lines->business_line_nm_list, report_year->rpt_year, report_period->rpt_period, period->period_val, form_report_id->form_rpt_id, row_order->dynamic_row_order, id_chitieu->indicator_id, gia_tri->indicator_val, updated_at->ds_etl_pcs_tms
--       giữ nguyên : submission_dt, object_id, object_code, entity_code
--   dwh_prod.bc_nhlk  ->  datamart.qlkd_opr_custodian_bank_explorer_val_flat
--       đổi tên cột: bank_name->bank_nm, report_year->rpt_year, report_period->rpt_period, period->period_val, form_report_id->form_rpt_id, row_order->dynamic_row_order, id_chitieu->indicator_id, gia_tri->indicator_val, updated_at->ds_etl_pcs_tms
--       giữ nguyên : submission_dt, object_id, object_code, entity_code
--   dwh_prod.bc_nhtt  ->  datamart.qlkd_opr_settlement_bank_explorer_val_flat
--       đổi tên cột: bank_name->bank_nm, report_year->rpt_year, report_period->rpt_period, period->period_val, form_report_id->form_rpt_id, row_order->dynamic_row_order, id_chitieu->indicator_id, gia_tri->indicator_val, updated_at->ds_etl_pcs_tms
--       giữ nguyên : submission_dt, object_id, object_code, entity_code
--   dwh_prod.bc_vpddctcknn  ->  datamart.qlkd_opr_foreign_securities_company_representative_office_explorer_val_flat
--       đổi tên cột: rep_office_name->representative_office_nm, report_year->rpt_year, report_period->rpt_period, period->period_val, form_report_id->form_rpt_id, row_order->dynamic_row_order, id_chitieu->indicator_id, gia_tri->indicator_val, updated_at->ds_etl_pcs_tms
--       giữ nguyên : submission_dt, object_id, object_code, entity_code
-- Khuôn: NDTNN/QLQ/GSTT Data Explorer (indicator_id, indicator_val, ds_etl_pcs_tms dùng chung tên với QLQ/NDTNN để BI Data Explorer đọc chung).
-- Chỉ ĐỔI TÊN bảng/cột; giữ nguyên số cột, thứ tự cột, kiểu và DEFAULT của DDL gốc (đã kiểm máy). Đích: database datamart (bảng gốc ở dwh_prod/default).
--
-- ENGINE / PARTITION BY / ORDER BY là ĐỀ XUẤT (DDL gốc không kèm; cần SHOW CREATE TABLE bảng gốc để đối chiếu). Chưa kiểm trên ClickHouse thật.
-- ReplacingMergeTree dedup theo ORDER BY: key gồm mọi cột chiều + indicator_id (cột tên/nhãn phụ thuộc hàm không đưa vào key); đọc bằng FINAL.
-- Version column = submission_dt (lần nộp ngày lớn nhất của cùng kỳ/biểu mẫu/đối tượng/dòng/chỉ tiêu thắng); ORDER BY KHÔNG chứa submission_dt. Bảng gốc không có log id lần nộp (QLQ/FIMS có rpt_log_id) — nộp lại cùng ngày thì dòng ghi sau thắng.
-- GIẢ ĐỊNH chờ xác nhận: period_val (cột period cũ) = giá trị kỳ trong loại kỳ rpt_period; object_id = id nguồn, object_code = mã nghiệp vụ; entity_code = mã dòng động như QLQ.
-- Liên quan O_QLKD_37 (HLD): STT 148–173 CN CTCK nước ngoài nộp qua sc_foreign_branch_periodic_report, STT 176–178 ngân hàng lưu ký/thanh toán nguồn BANK_PERIODIC_REPORT (atomic_out_of_scope) — DDL này chỉ là bảng đích ClickHouse, chưa có LLD/nguồn Atomic.
--
-- TRẠNG THÁI: CHỈ CÓ DDL, nằm ở thư mục con explorer/ (cùng cách GSTT/buffer/, NDTNN/explorer/ trước đây) nên Gate 4 (chỉ quét 01_create*.sql ở thư mục module)
-- không đọc. Khi có job ODS + LLD + INSERT: chuyển các khối vào 01_create_*_flat_tables.sql, xóa thư mục explorer/. Chưa có bảng chỉ tiêu (metadata) cho phân hệ này.
-- Triển khai: bảng cũ đang có dữ liệu nên tạo bảng mới song song rồi chuyển BI sang tên mới; KHÔNG DROP bảng cũ trước khi BI chuyển xong.
-- Số khối #n là tạm (nối tiếp khối cuối của 01_create_*_flat_tables.sql hiện hành), đánh lại khi chuyển vào.
-- ============================================================


-- ============================================================
-- 24. OPERATIONAL: qlkd_opr_foreign_securities_company_branch_explorer_val_flat
--    Chi nhánh CTCK nước ngoài — dạng dọc (1 dòng = 1 ô chỉ tiêu của biểu mẫu báo cáo định kỳ).
--    Thay dwh_prod.bc_cnctcknn (13 cột). Chưa có LLD/Entities/INSERT — chờ job ODS của dev.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_foreign_securities_company_branch_explorer_val_flat ON CLUSTER 'my_cluster'
(
    submission_dt                                Date                    COMMENT 'Ngày nộp báo cáo của lần nộp được chọn cho kỳ báo cáo — đồng thời là version column của ReplacingMergeTree (lần nộp ngày lớn nhất thắng)',
    object_id                                    String                  COMMENT 'Mã định danh (id nguồn) của đối tượng nộp báo cáo',
    object_code                                  String                  COMMENT 'Mã nghiệp vụ của đối tượng nộp báo cáo',
    branch_nm                                    String                  COMMENT 'Tên chi nhánh CTCK nước ngoài tại Việt Nam (branch_name cũ)',
    rpt_year                                     Int32                   COMMENT 'Năm báo cáo (report_year cũ)',
    rpt_period                                   String                  COMMENT 'Loại kỳ báo cáo QUY/THANG/NAM/NGAY (report_period cũ) — cùng ý nghĩa rpt_period của qlkd_opr_securities_company_report_data_flat',
    period_val                                   String                  COMMENT 'Giá trị kỳ báo cáo, chuỗi nguyên văn từ bảng gốc (period cũ) — GIẢ ĐỊNH là số thứ tự kỳ trong loại kỳ ở rpt_period',
    form_rpt_id                                  String                  COMMENT 'Mã (id) biểu mẫu báo cáo (form_report_id cũ)',
    entity_code                                  String                  COMMENT 'Mã đối tượng của dòng động trong biểu mẫu (giữ tên entity_code như QLQ/NDTNN)',
    dynamic_row_order                            Int32                   COMMENT 'Thứ tự dòng trong band động của biểu mẫu (row_order cũ)',
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (id_chitieu cũ) — khóa nối với bảng chỉ tiêu của Data Explorer (chưa có DDL bảng chỉ tiêu cho phân hệ này)',
    indicator_val                                String                  COMMENT 'Giá trị ô/chỉ tiêu dạng chuỗi nguyên văn từ nguồn (gia_tri cũ)',
    ds_etl_pcs_tms                               DateTime                COMMENT 'Thời điểm ETL ghi dòng (updated_at cũ)'
)
ENGINE = ReplicatedReplacingMergeTree(submission_dt)
PARTITION BY rpt_year
ORDER BY (rpt_year, rpt_period, period_val, form_rpt_id, object_id, entity_code, dynamic_row_order, indicator_id)
COMMENT 'Flat Data Explorer QLKD — Chi nhánh CTCK nước ngoài (thay dwh_prod.bc_cnctcknn)'
;


-- ============================================================
-- 25. OPERATIONAL: qlkd_opr_domestic_securities_company_explorer_val_flat
--    Công ty chứng khoán trong nước — dạng dọc (1 dòng = 1 ô chỉ tiêu của biểu mẫu báo cáo định kỳ).
--    Thay dwh_prod.bc_ctcktn (15 cột). Chưa có LLD/Entities/INSERT — chờ job ODS của dev.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_domestic_securities_company_explorer_val_flat ON CLUSTER 'my_cluster'
(
    submission_dt                                Date                    COMMENT 'Ngày nộp báo cáo của lần nộp được chọn cho kỳ báo cáo — đồng thời là version column của ReplacingMergeTree (lần nộp ngày lớn nhất thắng)',
    object_id                                    String                  COMMENT 'Mã định danh (id nguồn) của đối tượng nộp báo cáo',
    object_code                                  String                  COMMENT 'Mã nghiệp vụ của đối tượng nộp báo cáo',
    sc_nm                                        String                  COMMENT 'Tên công ty chứng khoán (firm_name cũ) — cùng tên cột sc_nm của các flat QLKD',
    equity_listing_exchange_code                 String                  COMMENT 'Sàn niêm yết của CTCK, chuỗi nguyên văn từ bảng gốc (listing_exchange cũ)',
    business_line_nm_list                        String                  COMMENT 'Danh sách nghiệp vụ kinh doanh chứng khoán của CTCK dạng chuỗi (business_lines cũ) — GIẢ ĐỊNH cùng nghĩa business_line_nm_list ở qlkd_opr_securities_company_organization_unit_profile_flat',
    rpt_year                                     Int32                   COMMENT 'Năm báo cáo (report_year cũ)',
    rpt_period                                   String                  COMMENT 'Loại kỳ báo cáo QUY/THANG/NAM/NGAY (report_period cũ) — cùng ý nghĩa rpt_period của qlkd_opr_securities_company_report_data_flat',
    period_val                                   String                  COMMENT 'Giá trị kỳ báo cáo, chuỗi nguyên văn từ bảng gốc (period cũ) — GIẢ ĐỊNH là số thứ tự kỳ trong loại kỳ ở rpt_period',
    form_rpt_id                                  String                  COMMENT 'Mã (id) biểu mẫu báo cáo (form_report_id cũ)',
    entity_code                                  String                  COMMENT 'Mã đối tượng của dòng động trong biểu mẫu (giữ tên entity_code như QLQ/NDTNN)',
    dynamic_row_order                            Int32                   COMMENT 'Thứ tự dòng trong band động của biểu mẫu (row_order cũ)',
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (id_chitieu cũ) — khóa nối với bảng chỉ tiêu của Data Explorer (chưa có DDL bảng chỉ tiêu cho phân hệ này)',
    indicator_val                                String                  COMMENT 'Giá trị ô/chỉ tiêu dạng chuỗi nguyên văn từ nguồn (gia_tri cũ)',
    ds_etl_pcs_tms                               DateTime                COMMENT 'Thời điểm ETL ghi dòng (updated_at cũ)'
)
ENGINE = ReplicatedReplacingMergeTree(submission_dt)
PARTITION BY rpt_year
ORDER BY (rpt_year, rpt_period, period_val, form_rpt_id, object_id, entity_code, dynamic_row_order, indicator_id)
COMMENT 'Flat Data Explorer QLKD — Công ty chứng khoán trong nước (thay dwh_prod.bc_ctcktn)'
;


-- ============================================================
-- 26. OPERATIONAL: qlkd_opr_custodian_bank_explorer_val_flat
--    Ngân hàng lưu ký — dạng dọc (1 dòng = 1 ô chỉ tiêu của biểu mẫu báo cáo định kỳ).
--    Thay dwh_prod.bc_nhlk (13 cột). Chưa có LLD/Entities/INSERT — chờ job ODS của dev.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_custodian_bank_explorer_val_flat ON CLUSTER 'my_cluster'
(
    submission_dt                                Date                    COMMENT 'Ngày nộp báo cáo của lần nộp được chọn cho kỳ báo cáo — đồng thời là version column của ReplacingMergeTree (lần nộp ngày lớn nhất thắng)',
    object_id                                    String                  COMMENT 'Mã định danh (id nguồn) của đối tượng nộp báo cáo',
    object_code                                  String                  COMMENT 'Mã nghiệp vụ của đối tượng nộp báo cáo',
    bank_nm                                      String                  COMMENT 'Tên ngân hàng lưu ký (bank_name cũ)',
    rpt_year                                     Int32                   COMMENT 'Năm báo cáo (report_year cũ)',
    rpt_period                                   String                  COMMENT 'Loại kỳ báo cáo QUY/THANG/NAM/NGAY (report_period cũ) — cùng ý nghĩa rpt_period của qlkd_opr_securities_company_report_data_flat',
    period_val                                   String                  COMMENT 'Giá trị kỳ báo cáo, chuỗi nguyên văn từ bảng gốc (period cũ) — GIẢ ĐỊNH là số thứ tự kỳ trong loại kỳ ở rpt_period',
    form_rpt_id                                  String                  COMMENT 'Mã (id) biểu mẫu báo cáo (form_report_id cũ)',
    entity_code                                  String                  COMMENT 'Mã đối tượng của dòng động trong biểu mẫu (giữ tên entity_code như QLQ/NDTNN)',
    dynamic_row_order                            Int32                   COMMENT 'Thứ tự dòng trong band động của biểu mẫu (row_order cũ)',
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (id_chitieu cũ) — khóa nối với bảng chỉ tiêu của Data Explorer (chưa có DDL bảng chỉ tiêu cho phân hệ này)',
    indicator_val                                String                  COMMENT 'Giá trị ô/chỉ tiêu dạng chuỗi nguyên văn từ nguồn (gia_tri cũ)',
    ds_etl_pcs_tms                               DateTime                COMMENT 'Thời điểm ETL ghi dòng (updated_at cũ)'
)
ENGINE = ReplicatedReplacingMergeTree(submission_dt)
PARTITION BY rpt_year
ORDER BY (rpt_year, rpt_period, period_val, form_rpt_id, object_id, entity_code, dynamic_row_order, indicator_id)
COMMENT 'Flat Data Explorer QLKD — Ngân hàng lưu ký (thay dwh_prod.bc_nhlk)'
;


-- ============================================================
-- 27. OPERATIONAL: qlkd_opr_settlement_bank_explorer_val_flat
--    Ngân hàng thanh toán — dạng dọc (1 dòng = 1 ô chỉ tiêu của biểu mẫu báo cáo định kỳ).
--    Thay dwh_prod.bc_nhtt (13 cột). Chưa có LLD/Entities/INSERT — chờ job ODS của dev.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_settlement_bank_explorer_val_flat ON CLUSTER 'my_cluster'
(
    submission_dt                                Date                    COMMENT 'Ngày nộp báo cáo của lần nộp được chọn cho kỳ báo cáo — đồng thời là version column của ReplacingMergeTree (lần nộp ngày lớn nhất thắng)',
    object_id                                    String                  COMMENT 'Mã định danh (id nguồn) của đối tượng nộp báo cáo',
    object_code                                  String                  COMMENT 'Mã nghiệp vụ của đối tượng nộp báo cáo',
    bank_nm                                      String                  COMMENT 'Tên ngân hàng thanh toán (bank_name cũ)',
    rpt_year                                     Int32                   COMMENT 'Năm báo cáo (report_year cũ)',
    rpt_period                                   String                  COMMENT 'Loại kỳ báo cáo QUY/THANG/NAM/NGAY (report_period cũ) — cùng ý nghĩa rpt_period của qlkd_opr_securities_company_report_data_flat',
    period_val                                   String                  COMMENT 'Giá trị kỳ báo cáo, chuỗi nguyên văn từ bảng gốc (period cũ) — GIẢ ĐỊNH là số thứ tự kỳ trong loại kỳ ở rpt_period',
    form_rpt_id                                  String                  COMMENT 'Mã (id) biểu mẫu báo cáo (form_report_id cũ)',
    entity_code                                  String                  COMMENT 'Mã đối tượng của dòng động trong biểu mẫu (giữ tên entity_code như QLQ/NDTNN)',
    dynamic_row_order                            Int32                   COMMENT 'Thứ tự dòng trong band động của biểu mẫu (row_order cũ)',
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (id_chitieu cũ) — khóa nối với bảng chỉ tiêu của Data Explorer (chưa có DDL bảng chỉ tiêu cho phân hệ này)',
    indicator_val                                String                  COMMENT 'Giá trị ô/chỉ tiêu dạng chuỗi nguyên văn từ nguồn (gia_tri cũ)',
    ds_etl_pcs_tms                               DateTime                COMMENT 'Thời điểm ETL ghi dòng (updated_at cũ)'
)
ENGINE = ReplicatedReplacingMergeTree(submission_dt)
PARTITION BY rpt_year
ORDER BY (rpt_year, rpt_period, period_val, form_rpt_id, object_id, entity_code, dynamic_row_order, indicator_id)
COMMENT 'Flat Data Explorer QLKD — Ngân hàng thanh toán (thay dwh_prod.bc_nhtt)'
;


-- ============================================================
-- 28. OPERATIONAL: qlkd_opr_foreign_securities_company_representative_office_explorer_val_flat
--    Văn phòng đại diện CTCK nước ngoài — dạng dọc (1 dòng = 1 ô chỉ tiêu của biểu mẫu báo cáo định kỳ).
--    Thay dwh_prod.bc_vpddctcknn (13 cột). Chưa có LLD/Entities/INSERT — chờ job ODS của dev.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.qlkd_opr_foreign_securities_company_representative_office_explorer_val_flat ON CLUSTER 'my_cluster'
(
    submission_dt                                Date                    COMMENT 'Ngày nộp báo cáo của lần nộp được chọn cho kỳ báo cáo — đồng thời là version column của ReplacingMergeTree (lần nộp ngày lớn nhất thắng)',
    object_id                                    String                  COMMENT 'Mã định danh (id nguồn) của đối tượng nộp báo cáo',
    object_code                                  String                  COMMENT 'Mã nghiệp vụ của đối tượng nộp báo cáo',
    representative_office_nm                     String                  COMMENT 'Tên văn phòng đại diện CTCK nước ngoài (rep_office_name cũ)',
    rpt_year                                     Int32                   COMMENT 'Năm báo cáo (report_year cũ)',
    rpt_period                                   String                  COMMENT 'Loại kỳ báo cáo QUY/THANG/NAM/NGAY (report_period cũ) — cùng ý nghĩa rpt_period của qlkd_opr_securities_company_report_data_flat',
    period_val                                   String                  COMMENT 'Giá trị kỳ báo cáo, chuỗi nguyên văn từ bảng gốc (period cũ) — GIẢ ĐỊNH là số thứ tự kỳ trong loại kỳ ở rpt_period',
    form_rpt_id                                  String                  COMMENT 'Mã (id) biểu mẫu báo cáo (form_report_id cũ)',
    entity_code                                  String                  COMMENT 'Mã đối tượng của dòng động trong biểu mẫu (giữ tên entity_code như QLQ/NDTNN)',
    dynamic_row_order                            Int32                   COMMENT 'Thứ tự dòng trong band động của biểu mẫu (row_order cũ)',
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (id_chitieu cũ) — khóa nối với bảng chỉ tiêu của Data Explorer (chưa có DDL bảng chỉ tiêu cho phân hệ này)',
    indicator_val                                String                  COMMENT 'Giá trị ô/chỉ tiêu dạng chuỗi nguyên văn từ nguồn (gia_tri cũ)',
    ds_etl_pcs_tms                               DateTime                COMMENT 'Thời điểm ETL ghi dòng (updated_at cũ)'
)
ENGINE = ReplicatedReplacingMergeTree(submission_dt)
PARTITION BY rpt_year
ORDER BY (rpt_year, rpt_period, period_val, form_rpt_id, object_id, entity_code, dynamic_row_order, indicator_id)
COMMENT 'Flat Data Explorer QLKD — Văn phòng đại diện CTCK nước ngoài (thay dwh_prod.bc_vpddctcknn)'
;
