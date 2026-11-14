-- ============================================================
-- NDTNN Explorer Flat Tables — CREATE
-- Module: Nhà Đầu Tư Nước Ngoài — NDTNN (Data Explorer báo cáo FIMS)
-- Tạo 2026-11-13. 2 bảng Operational, thay 2 bảng ClickHouse đang chạy với tên chưa theo chuẩn:
--   default.bc_fims                            -> datamart.ndtnn_opr_foreign_investor_report_explorer_val_flat
--   default.metadata_etl (phần FIMS)           -> datamart.ndtnn_opr_foreign_investor_report_explorer_indicator_flat
-- Khuôn: QLQ (qlq_opr_dynamic_report_explorer_{val,indicator}_flat — Datamart/flat-table/flat_table_mapping.md, O_QLQ_79–81).
-- Chỉ ĐỔI TÊN bảng/cột; giữ nguyên số cột, thứ tự cột, kiểu, DEFAULT, ORDER BY và ngữ nghĩa engine của DDL gốc.
--
-- TRẠNG THÁI: CHỈ CÓ DDL. Chưa có LLD, Entities, khối INSERT (02_populate), chưa vào Gate 4 — file nằm ở thư mục con explorer/
-- (cùng cách GSTT/buffer/) nên Gate 4 (chỉ quét 01_create*.sql ở thư mục module) không đọc. Chờ job ODS FIMS của dev (Open Item sẽ mở là O_NDTNN_61)
-- để viết LLD + INSERT…SELECT; khi đó chuyển 2 khối này vào 01_create_ndtnn_flat_tables.sql (khối #11, #12).
--
-- Quyết định Data Modeler 2026-11-13: (1) giữ rpt_log_id UInt64 làm version column của ReplacingMergeTree (lần nộp có id lớn nhất thắng,
-- KHÔNG nằm trong ORDER BY — khác QLQ); (2) chỉ chỉ tiêu base, level 1 (indicator_tp luôn 1, logic_function để trống, nạp TRUNCATE + INSERT).
--
-- Cột còn GIẢ ĐỊNH / chưa có nguồn xác nhận (chờ job ODS): period_end_dt (ngày cuối kỳ như QLQ), object_nm, object_tp, entity_code,
-- công thức md5 của indicator_id (phải trùng byte với id_chitieu cũ nếu BI đang tham chiếu), unit_nm.
-- object_nm có thể là PII (cá nhân nước ngoài): chưa có trong system/rules/pii_columns.yaml, chưa bọc fn_pii_encrypt — xác nhận trước khi nạp.
--
-- Tên cột — bảng ánh xạ cũ -> mới (cùng tên với QLQ ở mọi cột chung để BI Data Explorer dùng chung):
--   bc_fims:      date->period_end_dt, object_name->object_nm, object_type_name->object_tp, period_type->period_tp, period_value->period_val,
--                 row_order->dynamic_row_order, id_chitieu->indicator_id, gia_tri->indicator_val, report_log_id->rpt_log_id,
--                 ngay_nop->submission_dt, updated_at->ds_etl_pcs_tms (object_id, entity_code giữ nguyên)
--   metadata_etl: id_chitieu->indicator_id, nhom_chitieu->indicator_group_nm, ten_chitieu->indicator_nm, loai_chi_tieu->indicator_tp,
--                 sourcetable->source_table_nm, targettable->target_table_nm, group_keys->group_key_list, level->indicator_level,
--                 active->active_ind, effective_from/to->effective_from_dt/effective_to_dt, updated_at->ds_etl_pcs_tms, don_vi->unit_nm,
--                 sort_order->sort_order_nbr, changed_by->changed_by_nm, report_name->rpt_nm, sheet_name->sheet_nm,
--                 object_types->object_tp_list, fund_types->object_sub_tp_list (logic_function, row_path, column_path, legal_basis giữ nguyên)
--
-- Triển khai: bảng cũ đang có dữ liệu nên tạo bảng mới song song rồi chuyển BI sang tên mới; KHÔNG DROP bảng cũ trước khi BI chuyển xong.
-- ============================================================


-- ============================================================
-- 11. OPERATIONAL: ndtnn_opr_foreign_investor_report_explorer_val_flat
--    Bảng dữ liệu khai thác Data Explorer NDTNN (báo cáo FIMS) — thay default.bc_fims.
--    Nguồn dự kiến: fct_foreign_investor_report_value + foreign_investor_report_structure_dim (+ cdr_dt_dim ngày nộp) — chưa viết INSERT.
--    Ngữ nghĩa nạp: ReplacingMergeTree theo ORDER BY, giữ dòng có rpt_log_id lớn nhất (lần nộp mới nhất thắng).
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_opr_foreign_investor_report_explorer_val_flat ON CLUSTER 'my_cluster'
(
    period_end_dt                                Date                    COMMENT 'Ngày cuối KỲ BÁO CÁO suy từ period_tp + period_val (GIẢ ĐỊNH theo QLQ, chờ job ODS xác nhận); cột Data Explorer lọc theo thời gian',
    object_id                                    String                  COMMENT 'Mã định danh đối tượng nộp báo cáo (Atomic fir_value.reporting_entity_code)',
    object_nm                                    String                  COMMENT 'Tên đối tượng nộp báo cáo (nguồn chờ job ODS; có thể là PII)',
    object_tp                                    String                  COMMENT 'Loại đối tượng nộp báo cáo, dạng nhãn (nhãn của Atomic fir_value.reporting_entity_tp_code)',
    period_tp                                    String                  COMMENT 'Loại kỳ báo cáo (THANG, QUY, NAM, ...)',
    period_val                                   String                  COMMENT 'Giá trị kỳ báo cáo (VD T09/2026)',
    entity_code                                  String                  COMMENT 'Mã đối tượng của dòng động trong báo cáo (chờ job ODS xác nhận quy tắc đánh số dòng trùng mã)',
    dynamic_row_order                            Int64 DEFAULT 0         COMMENT 'Thứ tự dòng trong band động (Atomic fir_value.dynamic_row_order); 0 = ô tĩnh',
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (md5) — khóa nối với bảng chỉ tiêu ndtnn_opr_foreign_investor_report_explorer_indicator_flat',
    indicator_val                                String                  COMMENT 'Giá trị ô dạng chuỗi (Atomic fir_value.val_raw, quy tắc chuẩn hóa chờ job ODS)',
    rpt_log_id                                   UInt64                  COMMENT 'Mã LẦN NỘP (REPORT_LOG_ID) — version column của ReplacingMergeTree: lần nộp có id lớn nhất thắng',
    submission_dt                                Date                    COMMENT 'Ngày THỰC TẾ nộp báo cáo (Atomic fir_value.submission_dt)',
    ds_etl_pcs_tms                               DateTime                COMMENT 'Thời điểm ETL ghi dòng'
)
ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{shard}/datamart/ndtnn_opr_foreign_investor_report_explorer_val_flat', '{replica}', rpt_log_id)
ORDER BY (period_end_dt, object_id, object_nm, object_tp, entity_code, dynamic_row_order, period_tp, period_val, indicator_id)
SETTINGS allow_nullable_key = 1, index_granularity = 8192
COMMENT 'Flat Data Explorer NDTNN — giá trị ô báo cáo FIMS (thay default.bc_fims)'
;


-- ============================================================
-- 12. OPERATIONAL: ndtnn_opr_foreign_investor_report_explorer_indicator_flat
--    Bảng chỉ tiêu (metadata) của Data Explorer NDTNN — thay phần FIMS của default.metadata_etl (23 cột).
--    Nối bảng dữ liệu qua indicator_id; chỉ tiêu base, level 1 (như QLQ). Cột loai_chi_tieu Enum8('base'=1,'user'=2) đổi thành
--    indicator_tp Int32 (1 = base, 2 = user); phần FIMS chỉ có giá trị 1.
--    Nguồn dự kiến: foreign_investor_report_structure_dim (+ đọc bảng dữ liệu val_flat để suy unit_nm) — chưa viết INSERT.
-- ============================================================
CREATE TABLE IF NOT EXISTS datamart.ndtnn_opr_foreign_investor_report_explorer_indicator_flat ON CLUSTER 'my_cluster'
(
    indicator_id                                 String                  COMMENT 'Mã chỉ tiêu (md5) — khớp indicator_id của bảng dữ liệu',
    indicator_group_nm                           String                  COMMENT 'Đường dẫn nhóm chỉ tiêu (tên báo cáo > sheet > nhóm hàng)',
    indicator_nm                                 String                  COMMENT 'Tên chỉ tiêu',
    indicator_tp                                 Int32                   COMMENT 'Loại chỉ tiêu: 1 = base (ETL sinh từ mẫu báo cáo), 2 = user (người dùng tự tạo; phần FIMS luôn 1)',
    source_table_nm                              String                  COMMENT 'Bảng nguồn của chỉ tiêu',
    target_table_nm                              String                  COMMENT 'Bảng dữ liệu chứa giá trị chỉ tiêu (ndtnn_opr_foreign_investor_report_explorer_val_flat)',
    group_key_list                               String                  COMMENT 'Danh sách cột chiều của bảng dữ liệu, cách nhau dấu phẩy; Data Explorer dựng GROUP BY theo chuỗi này (dùng tên cột MỚI của val_flat)',
    logic_function                               String                  COMMENT 'Hàm logic tổng hợp (để trống với chỉ tiêu base)',
    indicator_level                              Int32                   COMMENT 'Cấp chỉ tiêu (luôn 1 với chỉ tiêu base)',
    active_ind                                   Int32 DEFAULT 1         COMMENT '1 = chỉ tiêu đang hiệu lực',
    effective_from_dt                            Date                    COMMENT 'Ngày bắt đầu hiệu lực',
    effective_to_dt                              Date                    COMMENT 'Ngày hết hiệu lực',
    ds_etl_pcs_tms                               DateTime DEFAULT now()  COMMENT 'Thời điểm ETL ghi dòng',
    unit_nm                                      String DEFAULT ''       COMMENT 'Đơn vị của chỉ tiêu (quy tắc rỗng = số, __text__ = chữ chờ job ODS xác nhận cho FIMS)',
    sort_order_nbr                               Int64 DEFAULT 0         COMMENT 'Số thứ tự sắp xếp theo mẫu báo cáo',
    changed_by_nm                                String DEFAULT ''       COMMENT 'Người/tiến trình thay đổi chỉ tiêu gần nhất',
    rpt_nm                                       String DEFAULT ''       COMMENT 'Tên mẫu báo cáo',
    sheet_nm                                     String DEFAULT ''       COMMENT 'Tên sheet',
    row_path                                     String DEFAULT ''       COMMENT 'Đường dẫn hàng đầy đủ của chỉ tiêu',
    column_path                                  String DEFAULT ''       COMMENT 'Đường dẫn header của cột',
    object_tp_list                               String DEFAULT ''       COMMENT 'Các loại đối tượng đã nộp báo cáo của chỉ tiêu, dạng gạch đứng bao quanh',
    object_sub_tp_list                           String DEFAULT ''       COMMENT 'Các loại quỹ đã nộp báo cáo của chỉ tiêu, dạng gạch đứng bao quanh',
    legal_basis                                  String DEFAULT ''       COMMENT 'Căn cứ pháp lý của mẫu báo cáo (VD phụ lục TT51/2021/TT-BTC)'
)
ENGINE = ReplicatedMergeTree()
ORDER BY (indicator_level, indicator_id)
COMMENT 'Flat Data Explorer NDTNN — chỉ tiêu báo cáo FIMS (thay phần FIMS của default.metadata_etl)'
;
