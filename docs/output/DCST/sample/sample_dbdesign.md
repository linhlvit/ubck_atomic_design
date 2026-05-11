## 2.1 DCST — Dữ liệu Cơ quan Thuế từ Tổng cục Thuế

### 2.1.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`DCST.dbml`](DCST.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID01 — Quản lý thông tin đăng ký thuế**: [`DCST_UID01.dbml`](DCST_UID01.dbml)


**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | rgst_taxpayer | Doanh nghiệp/hộ kinh doanh đã đăng ký thuế với cơ quan thuế. Lưu thông tin pháp lý và trạng thái hoạt động. |
| 2 | taxpayer_rprs | Người đại diện hoặc chủ hộ kinh doanh của người nộp thuế. Ghi nhận tên và chức vụ. |




### 2.1.2 Bảng rgst_taxpayer



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rgst_taxpayer_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | rgst_taxpayer_code | STRING |  |  |  |  | ID bản ghi đăng ký thuế. BK |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. Giá trị: DCST.THONG_TIN_DK_THUE |
| 4 | full_nm | STRING | X |  |  |  | Tên người nộp thuế |
| 5 | org_tax_identn_nbr | STRING | X |  |  |  | Mã số thuế |
| 6 | charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ |
| 7 | charter_cptl_ccy_code | STRING | X |  | F |  | Loại tiền vốn điều lệ |
| 8 | frgn_charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ nước ngoài |
| 9 | frgn_charter_cptl_ccy_code | STRING | X |  | F |  | Loại tiền vốn điều lệ nước ngoài |
| 10 | bsn_line_code | STRING | X |  |  |  | Mã ngành nghề kinh doanh |
| 11 | bsn_line_dsc | STRING | X |  |  |  | Ngành nghề kinh doanh |
| 12 | bsn_commencement_dt | DATE | X |  |  |  | Ngày bắt đầu hoạt động kinh doanh |
| 13 | prn_org_nm | STRING | X |  |  |  | Đơn vị chủ quan/ đơn vị quản lý trực thuộc |
| 14 | prn_org_adr | STRING | X |  |  |  | Địa chỉ đơn vị chủ quản |
| 15 | spvsr_ahr_nm | STRING | X |  |  |  | Cơ quan quản lý trực tiếp |
| 16 | spvsr_tax_ahr_code | STRING | X |  |  |  | Mã cơ quan quản lý thuế |
| 17 | lgl_rprs_nm | STRING | X |  |  |  | Tên người đại diện kinh doanh |
| 18 | lgl_rprs_identn_nbr | STRING | X |  |  |  | Số CMT/ hộ chiếu người đại diện theo pháp luật/ chủ doanh nghiệp tư nhân |
| 19 | lgl_rprs_ph_nbr | STRING | X |  |  |  | Số ĐT người đại diện theo pháp luật/ chủ doanh nghiệp tư nhân |
| 20 | director_nm | STRING | X |  |  |  | Tên giám đốc/ tổng giám đốc |
| 21 | director_ph_nbr | STRING | X |  |  |  | Số điện thoại giám đốc/ tổng giám đốc |
| 22 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động: 00, 04: Đang hoạt động; 01: Ngừng HĐ đã hoàn thành thủ tục; 03: Ngừng HĐ chưa hoàn thành; 05: Ngừng KD có thời hạn; 06: Không HĐ tại địa chỉ đăng ký |
| 23 | lcs_nm | STRING | X |  |  |  | Tên trạng thái người nộp thuế. Giá trị denormalized từ nguồn |
| 24 | cessation_rsn_dsc | STRING | X |  |  |  | Lý do ngừng hoạt động |
| 25 | cessation_tp_code | STRING | X |  |  |  | Loại ngừng hoạt động: 1. Giải thể; 2. Phá sản; 3. Chuyển đổi loại hình DN; 4. Cho làm thủ tục giải thể; 5. Phá sản; 6. Tổ chức lại; 7. Thu hồi GP; 8. Đóng theo ĐVCQ; 9. Khác |
| 26 | cessation_dt | DATE | X |  |  |  | Ngày ngừng hoạt động |
| 27 | cessation_rsn | STRING | X |  |  |  | Lý do ngừng hoạt động (chi tiết) |
| 28 | cessation_note | STRING | X |  |  |  | Ghi chú ngừng hoạt động |
| 29 | cessation_ntc_nbr | STRING | X |  |  |  | Số thông báo ngừng hoạt động |
| 30 | temp_susp_strt_dt | DATE | X |  |  |  | Tạm nghỉ/Từ ngày |
| 31 | temp_susp_end_dt | DATE | X |  |  |  | Tạm nghỉ/Đến ngày |
| 32 | temp_susp_rsn | STRING | X |  |  |  | Lý do tạm nghỉ |
| 33 | temp_susp_ntc_nbr | STRING | X |  |  |  | Số thông báo - tạm nghỉ |
| 34 | temp_susp_ntc_dt | DATE | X |  |  |  | Ngày thông báo - tạm nghỉ |


#### 2.1.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| rgst_taxpayer_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| charter_cptl_ccy_code | ccy | ccy_code |
| frgn_charter_cptl_ccy_code | ccy | ccy_code |



#### 2.1.2.2 Index

N/A

#### 2.1.2.3 Trigger

N/A




### 2.1.3 Bảng taxpayer_rprs



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | taxpayer_rprs_id | STRING |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | taxpayer_rprs_code | STRING |  |  |  |  | ID bản ghi người đại diện. BK |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.TTKDT_NGUOI_DAI_DIEN' | Mã nguồn dữ liệu. Giá trị: DCST.TTKDT_NGUOI_DAI_DIEN |
| 4 | rgst_taxpayer_id | STRING |  |  | F |  | FK đến Registered Taxpayer |
| 5 | rgst_taxpayer_code | STRING |  |  |  |  | Mã NNT |
| 6 | rprs_nm | STRING | X |  |  |  | Tên người đại diện/chủ hộ KD |
| 7 | pos_ttl | STRING | X |  |  |  | Chức vụ người đại diện/chủ hộ KD |


#### 2.1.3.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| taxpayer_rprs_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rgst_taxpayer_id | rgst_taxpayer | rgst_taxpayer_id |



#### 2.1.3.2 Index

N/A

#### 2.1.3.3 Trigger

N/A




### 2.1.4 Stored Procedure/Function

N/A

### 2.1.5 Package

N/A
