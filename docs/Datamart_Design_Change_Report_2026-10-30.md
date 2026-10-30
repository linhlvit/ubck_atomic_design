# Báo cáo Thay đổi Thiết kế Datamart 11 Phân hệ (2026-10-30)

> **Ngày lập báo cáo:** 2026-10-30  
> **Phạm vi cập nhật:** 3 Phân hệ chính: **VP** (Văn phòng / Tổng hợp điều hành), **QLKD** (Quản lý Kinh doanh), **QLQ** (Quản lý Quỹ) + Tiến độ đối soát dữ liệu Staging **NHNCK** (Người hành nghề chứng khoán).  
> **Người thực hiện / Data Modeler:** Vương Ngô (`vuongjune2@gmail.com`)  
> **Các commit liên quan trên `main`:**
> - `60731d36`: `feat(VP): cap nhat thiet ke nhom 36, 50, 51 theo SQL BA moi va dong O_VP_44, O_VP_45`
> - `921119a6`: `feat(qlkd): cap nhat thiet ke nhom 26-27 (O_QLKD_68) va co che nap partition staging flat table (O_QLKD_69)`
> - `51f9ccfc`: `feat(qlq): nang ready 8 kpi nhom 28 theo sql ba moi tu so lenh va don dep ddl flat table (O_QLQ_63)`

---

## 1. Mục đích và Bối cảnh phiên làm việc 2026-10-30

Phiên làm việc ngày 30/10/2026 tập trung giải quyết các phản hồi thực tế từ UAT, đồng bộ câu lệnh khai thác mới từ BA và hoàn thiện kiến trúc nạp dữ liệu Flat Table cho ClickHouse:
1. **Phân hệ VP:** BA cập nhật câu lệnh chính thức cho Nhóm 36 (Mua/Bán ròng NĐTNN Cổ phiếu) và Nhóm 50–51 (Báo cáo thường niên). Đóng 2 mục còn mở `O_VP_44` và `O_VP_45`.
2. **Phân hệ QLKD:** Xử lý triệt để phản ánh từ Tester UAT về 4 kỳ hiển thị giá trị NULL của CTCK SSI ở Nhóm 26 và 27 (`O_QLKD_68`); đồng thời cải tiến cơ chế nạp Flat Table Cơ cấu tài chính định kỳ (`fct_securities_company_financial_structure_snpst_flat`) sang mô hình Staging `REPLACE PARTITION` (`O_QLKD_69`).
3. **Phân hệ QLQ:** Tiếp nhận SQL tham khảo mới của BA nối từ sổ lệnh `trade_book` (HOSE/HNX) và nâng toàn bộ 8 chỉ tiêu Nhóm 28 từ PENDING lên READY (`O_QLQ_63`).
4. **Phân hệ NHNCK:** Soạn thảo bộ câu lệnh kiểm tra dữ liệu Staging UAT (`NHNCK_UAT`), xác nhận 4 điểm cốt lõi trước khi chốt với BA.

---

## 2. Chi tiết thay đổi thiết kế theo Phân hệ

### 2.1. Phân hệ VP (Văn phòng / Tổng hợp điều hành)
* **Nhóm 36 — Mua/Bán ròng NĐTNN (Cổ phiếu):**
  - **Vấn đề:** Trước đây bảng thiết kế bao gồm cả Cổ phiếu, CCQ, ETF và Chứng quyền.
  - **Cập nhật:** Thu hẹp phạm vi lọc sang chỉ lấy Cổ phiếu (`stock_tp_code = '2'`), loại bỏ CCQ/ETF/CW theo đúng SQL tra cứu của BA.
  - **Tài liệu cập nhật:** [`DTM_VP_Detail_Mapping.csv`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/DTM_VP_Detail_Mapping.csv), [`DTM_VP_Entities.md`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/hld/DTM_VP_Entities.md), [`02_populate_vp_flat_tables.sql`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/flat-table/VP/02_populate_vp_flat_tables.sql).
* **Nhóm 50 & 51 — Báo cáo thường niên:**
  - **Chốt `O_VP_45` (Khối lượng vs. Giá trị):** BA đã chốt công thức tính theo **Khối lượng** (`SUM(ls.new_listed_shares)`, `SUM(ls.additional_listed_shares)`, `SUM(ls.delisted_shares)`). Đồng bộ 100% với Fact và Detail Mapping.
  - **Chốt `O_VP_44` (Kỳ báo cáo & SCD mapping sàn):** Kỳ tính theo **Ngày hiệu lực** (`effective_date`). Niêm yết mới nối bản tin MDDS `s_new` tại `first_trading_date`; Niêm yết bổ sung/hủy nối `s_add` tại ngày giao dịch gần nhất $\le$ `effective_date`. Bỏ điều kiện `exchange_transfer NOT LIKE 'Có%'`.
  - Đóng chính thức `O_VP_44` và `O_VP_45` trong [`DTM_VP_HLD.md`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/hld/DTM_VP_HLD.md) (chuyển sang `Resolved`).
* **Dọn dẹp flat table:** Xóa 2 file thừa ở thư mục root cũ `Datamart/flat-table/01_create_vp_flat_tables.sql` và `02_populate_vp_flat_tables.sql`.

---

### 2.2. Phân hệ QLKD (Quản lý Kinh doanh)
* **`O_QLKD_68`: Khắc phục lỗi 4 kỳ BCTC SSI hiển thị NULL (Nhóm 26 & 27):**
  - **Hiện tượng:** Đối soát UAT (CTCK SSI, `sc_code = '966'`) phát hiện 4 kỳ bị trả về giá trị NULL ở Nhóm 27 và làm sai lệch Nhóm 26.
  - **Nguyên nhân:** Bảng `opr_securities_company_financial_report_hist` nạp lọt cả báo cáo tình hình hoạt động `BCTHHD_CTCK` (không có doanh thu, LNST, ROA, ROE) với `preferred_report_ind = '1'`.
  - **Giải pháp:** Sửa bộ lọc ETL: Chỉ lấy biểu mẫu `BCTCHN` và `BCTCRL` theo đúng SQL BA. Cập nhật LLD table spec và Detail Mapping ([`K_QLKD_131`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/DTM_QLKD_Detail_Mapping.csv#L236), [`K_QLKD_135..141`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/DTM_QLKD_Detail_Mapping.csv#L244-L250)).
* **`O_QLKD_69`: Cơ chế nạp Staging Partition Flat Table (`fct_securities_company_financial_structure_snpst_flat`):**
  - **Vấn đề:** TRUNCATE toàn bộ bảng gây trống dữ liệu khi người dùng tra cứu; DELETE theo ngày ETL làm rỗng flat table do ngày kết thúc kỳ không trùng ngày chạy ETL.
  - **Giải pháp:** Fact nạp upsert theo phạm vi `(sc_code, rpt_year, rpt_period, period)`. Flat table nạp theo từng partition tháng `toYYYYMM(cdr_dt)` vào bảng đệm `_stg` rồi thực thi `ALTER TABLE ... REPLACE PARTITION :ym FROM ..._flat_stg` (nguyên tử, không gián đoạn truy vấn).
  - **Nâng cấp Tooling Gate 4:** Nâng cấp `datamart_flat_table_checker.py` và `build_flat_tables.py`, thêm 8 test cases tự động (`test_flat_table_checker.py`, `test_build_flat_sync_columns.py`). Kiểm định Gate 4 đạt **PASS 100% (22/22 bảng)**.

---

### 2.3. Phân hệ QLQ (Quản lý Quỹ)
* **`O_QLQ_63`: Nâng READY 8 chỉ tiêu Nhóm 28 (Giao dịch nhân viên công ty QLQ):**
  - **Cập nhật:** BA đã cung cấp SQL tham khảo hoàn chỉnh nối từ staging sổ lệnh HOSE/HNX `trade_book` với tài khoản nhân viên CTQLQ (`tl_profiles` $\times$ `open_investors` $\cup$ `updated_investors`).
  - **Nâng trạng thái:** 8 chỉ tiêu [`K_QLQ_108` $\rightarrow$ `K_QLQ_115`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/DTM_QLQ_Detail_Mapping.csv#L108-L115) chuyển từ PENDING sang **READY** thông qua Fact append report `fund_management_company_staff_trade_rpt`:
    - `K_QLQ_108`: Mã CTCK nơi mở tài khoản
    - `K_QLQ_109`: Ngày giao dịch
    - `K_QLQ_110`: Phương thức giao dịch (ánh xạ board type)
    - `K_QLQ_111`: Lệnh mua/bán (hướng giao dịch)
    - `K_QLQ_112`: Mã CK
    - `K_QLQ_113`: Số lượng CK đặt lệnh
    - `K_QLQ_114`: Giá đặt lệnh
    - `K_QLQ_115`: Tổng giá trị lệnh (Volume $\times$ Price)
* **Dọn dẹp flat table:** Xóa 21 dòng khai báo DDL thừa/lặp ở cuối bảng `qlq_fund_management_company_staff_trade_rpt_flat` trong [`01_create_qlq_flat_tables.sql`](file:///C:/Workspace/Design_DW/ubck_atomic_design/Datamart/flat-table/QLQ/01_create_qlq_flat_tables.sql). Gate 4 Audit đạt **PASS 100% (19/19 bảng)**.

---

### 2.4. Phân hệ NHNCK (Người hành nghề chứng khoán)
* **Hiện trạng:** Đạt 115/132 KPI READY (~87.1%), 17 KPI PENDING (~12.9%).
* **Phân tích kết quả chạy Staging UAT (`NHNCK_UAT`):**
  1. *Check 1 (Trạng thái CCHN):* Có nhiều dòng lịch sử thay đổi trạng thái $\rightarrow$ giữ nguyên thiết kế chọn bản ghi trạng thái mới nhất `NEW_STATUS`.
  2. *Check 2 (Khóa dòng CCHN):* Phát hiện thực tế có tình trạng cấp lại giữ nguyên số CCHN $\rightarrow$ chốt giải pháp dùng ID bản ghi (`cert_record_id`) làm khóa dòng duy nhất.
  3. *Check 3 (Ngưỡng 8h bồi dưỡng):* Query 3c trả về 0 dòng $\rightarrow$ xác nhận thực tế các khóa bồi dưỡng chuẩn đều $\ge$ 8h, không có độ vênh giữa kiểm tra từng lần vs cộng dồn.
  4. *Check 4 (15.000 người hành nghề chưa tham gia bồi dưỡng):* Đã chuẩn bị 2 phương án hiển thị để chốt với BA.

---

## 3. Tổng kết Trạng thái Quality Gates & Flat Tables

| Phân hệ | Số bảng DDL Flat | Số bảng DML Flat | Gate 4 Audit | Tiến độ & Trạng thái |
|:---:|:---:|:---:|:---:|---|
| **VP** | 6 | 6 | **PASS** | Đã push `60731d36` (Đóng O_VP_44, O_VP_45) |
| **QLKD** | 22 | 22 | **PASS** | Đã push `921119a6` (O_QLKD_68, O_QLKD_69) |
| **QLQ** | 19 | 19 | **PASS** | Đã push `51f9ccfc` (Nâng READY 8 KPI Nhóm 28) |
| **NHNCK** | 9 | 9 | Đang rà soát | Đã có bộ câu lệnh kiểm tra staging UAT 4 điểm |
