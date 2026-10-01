-- ============================================================
-- TT Flat Tables — RECREATE (DROP + CREATE) — 2026-10-01
-- Lý do: đổi ORDER BY / kiểu Nullable / thứ tự cột không ALTER được trên ReplicatedReplacingMergeTree.
-- Bảng bị ảnh hưởng (4):
--   tt_fct_inspection_team_target_activity_flat   (FK đối tượng nullable, ORDER BY thêm inspection_team_code)
--   tt_fct_penalty_decision_subject_behavior_flat (cột violation_behavior_group_nm cuối, FK nullable, ORDER BY mới)
--   tt_fct_penalty_decision_subject_flat          (FK đối tượng nullable, ORDER BY mới)
--   tt_opr_petition_list_flat                     (PK petition_id, petition_code nullable, cột target_nm)
-- CÁCH DÙNG: chạy file này TRƯỚC, rồi chạy lại phần CREATE tương ứng trong 01_create_tt_flat_tables.sql
--            và phần INSERT tương ứng trong 02_populate_tt_flat_tables.sql để nạp lại dữ liệu.
-- CẢNH BÁO: DROP xoá dữ liệu flat (nạp lại được từ bảng datamart.*). Kiểm tra trước khi chạy trên production.
-- ============================================================
DROP TABLE IF EXISTS datamart.tt_fct_inspection_team_target_activity_flat ON CLUSTER 'my_cluster' SYNC;
DROP TABLE IF EXISTS datamart.tt_fct_penalty_decision_subject_behavior_flat ON CLUSTER 'my_cluster' SYNC;
DROP TABLE IF EXISTS datamart.tt_fct_penalty_decision_subject_flat ON CLUSTER 'my_cluster' SYNC;
DROP TABLE IF EXISTS datamart.tt_opr_petition_list_flat ON CLUSTER 'my_cluster' SYNC;
