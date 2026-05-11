## DCST — Dữ liệu Cơ quan Thuế từ Tổng cục Thuế

### Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`DCST.dbml`](DCST.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID03 — Cưỡng chế nợ thuế**: [`DCST_UID03.dbml`](DCST_UID03.dbml)
  - **UID04 — Xử lý vi phạm pháp luật về thuế**: [`DCST_UID04.dbml`](DCST_UID04.dbml)


**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | tax_vln_pny_dcsn | Quyết định xử lý vi phạm hành chính về thuế. Ghi nhận hành vi vi phạm và mức phạt/truy thu. |
| 2 | tax_dbt_nfrc_ordr | Quyết định cưỡng chế nợ thuế. Ghi nhận hình thức cưỡng chế và thông tin tài sản/tài khoản liên quan. |




### Bảng tax_vln_pny_dcsn



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | tax_vln_pny_dcsn_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | tax_vln_pny_dcsn_code | STRING |  |  |  |  | Mã định danh bản ghi trong DCST. BK |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.TT_XLY_VI_PHAM' | Mã nguồn dữ liệu. Giá trị: DCST.TT_XLY_VI_PHAM |
| 4 | rgst_taxpayer_id | STRING | X |  | F |  | Mã số thuế. FK đến Registered Taxpayer |
| 5 | rgst_taxpayer_code | STRING | X |  |  |  | Mã số thuế |
| 6 | taxpayer_nm | STRING | X |  |  |  | Tên đối tượng |
| 7 | ordr_nbr | STRING | X |  |  |  | Số quyết định xử lý |
| 8 | issu_ahr_nm | STRING | X |  |  |  | Cơ quan ban hành |
| 9 | insp_prd | STRING | X |  |  |  | Kỳ thanh tra kiểm tra |
| 10 | vln_pny_dsc | STRING | X |  |  |  | Phạt hành vi vi phạm |
| 11 | admn_vln_pny_dsc | STRING | X |  |  |  | Phạt hành vi vi phạm hành chính |
| 12 | tax_ars_rec_amt | STRING | X |  |  |  | Truy thu tiền thuế, tiền nộp chậm |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| tax_vln_pny_dcsn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rgst_taxpayer_id | rgst_taxpayer | rgst_taxpayer_id |



#### Index

N/A

#### Trigger

N/A




### Bảng tax_dbt_nfrc_ordr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | tax_dbt_nfrc_ordr_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | tax_dbt_nfrc_ordr_code | STRING |  |  |  |  | Mã định danh bản ghi trong DCST. BK |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.TCT_TT_CUONG_CHE_NO' | Mã nguồn dữ liệu. Giá trị: DCST.TCT_TT_CUONG_CHE_NO |
| 4 | rgst_taxpayer_id | STRING | X |  | F |  | Mã người nhận. FK đến Registered Taxpayer |
| 5 | rgst_taxpayer_code | STRING | X |  |  |  | Mã người nhận |
| 6 | taxpayer_nm | STRING | X |  |  |  | Tên người nhận |
| 7 | taxpayer_bsn_idy | STRING | X |  |  |  | Ngành kinh doanh đối tượng bị cưỡng chế |
| 8 | tax_ahr_code | STRING | X |  |  |  | Mã cơ quan thuế |
| 9 | tax_ahr_nm | STRING | X |  |  |  | Tên cơ quan thuế |
| 10 | spvsr_tax_ahr_code | STRING | X |  |  |  | Mã cơ quan thuế quản lý |
| 11 | spvsr_tax_ahr_nm | STRING | X |  |  |  | Tên cơ quan thuế quản lý |
| 12 | nfrc_tp_code | STRING | X |  |  |  | Mã hình thức cưỡng chế |
| 13 | nfrc_tp_nm | STRING | X |  |  |  | Tên hình thức cưỡng chế |
| 14 | elc_txn_code | STRING | X |  |  |  | Mã giao dịch điện tử |
| 15 | nfrc_ordr_nbr | STRING | X |  | F |  | Số quyết định |
| 16 | nfrc_ordr_dt | DATE | X |  |  |  | Ngày quyết định |
| 17 | enforced_amt | STRING | X |  |  |  | Số tiền bị cưỡng chế |
| 18 | nfrc_eff_strt_dt | DATE | X |  |  |  | Ngày hiệu lực từ quyết định từ |
| 19 | nfrc_eff_end_dt | DATE | X |  |  |  | Ngày hiệu lực quyết định đến |
| 20 | nfrc_tm | DATE | X |  |  |  | Thời gian cưỡng chế |
| 21 | nfrc_lo | STRING | X |  |  |  | Địa điểm cưỡng chế |
| 22 | taxpayer_ac_nbr | STRING | X |  |  |  | Số tài khoản đối tượng bị cưỡng chế |
| 23 | taxpayer_ac_bnk | STRING | X |  |  |  | Nơi mở tài khoản bị cưỡng chế |
| 24 | incm_mgr_nm | STRING | X |  |  |  | Tên đối tượng quản lý thu nhập |
| 25 | incm_mgr_adr | STRING | X |  |  |  | Địa chỉ đối tượng quản lý thu nhập |
| 26 | seized_ast_dsc | STRING | X |  |  |  | Tài sản kê biên |
| 27 | seized_ast_val | STRING | X |  |  |  | Giá trị tài sản |
| 28 | ast_cstd_code | STRING | X |  | F |  | Mã đối tượng giữ tài sản cưỡng chế |
| 29 | ast_cstd_nm | STRING | X |  |  |  | Tên đối tượng giữ tài sản cưỡng chế |
| 30 | ast_cstd_adr | STRING | X |  |  |  | Địa chỉ đối tượng giữ tài sản cưỡng chế |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| tax_dbt_nfrc_ordr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rgst_taxpayer_id | rgst_taxpayer | rgst_taxpayer_id |



#### Index

N/A

#### Trigger

N/A




### Stored Procedure/Function

N/A

### Package

N/A
