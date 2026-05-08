# 2. CƠ SỞ DỮ LIỆU (OLTP)


## 2.1 DCST — Dữ liệu Cơ quan Thuế từ Tổng cục Thuế

### 2.1.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`DCST.dbml`](DCST.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID01 — Quản lý thông tin đăng ký thuế**: [`DCST_UID01.dbml`](DCST_UID01.dbml)
  - **UID02 — Báo cáo tài chính từ Tổng cục Thuế**: [`DCST_UID02.dbml`](DCST_UID02.dbml)
  - **UID03 — Cưỡng chế nợ thuế**: [`DCST_UID03.dbml`](DCST_UID03.dbml)
  - **UID04 — Xử lý vi phạm pháp luật về thuế**: [`DCST_UID04.dbml`](DCST_UID04.dbml)
  - **UID05 — Giám sát doanh nghiệp rủi ro cao**: [`DCST_UID05.dbml`](DCST_UID05.dbml)


**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | rgst_taxpayer | Doanh nghiệp/hộ kinh doanh đã đăng ký thuế với cơ quan thuế. Lưu thông tin pháp lý và trạng thái hoạt động. |
| 2 | taxpayer_rprs | Người đại diện hoặc chủ hộ kinh doanh của người nộp thuế. Ghi nhận tên và chức vụ. |
| 3 | hrsk_taxpayer_ases_snpst | Đánh giá xếp loại doanh nghiệp rủi ro cao về thuế theo năm. Ghi nhận thông tin tổ chức bị đánh giá rủi ro. |
| 4 | ip_pst_adr | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |
| 5 | ip_elc_adr | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 6 | ip_alt_identn | Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn. |
| 7 | tax_fnc_stmt | Tờ khai tài chính điện tử nộp lên cơ quan thuế. Ghi nhận kỳ kê khai và thông tin kiểm toán. |
| 8 | tax_fnc_stmt_itm | Chỉ tiêu chi tiết trong tờ khai tài chính. Ghi nhận giá trị số liệu theo từng ô chỉ tiêu trong biểu mẫu. |
| 9 | tax_dbt_nfrc_ordr | Quyết định cưỡng chế nợ thuế. Ghi nhận hình thức cưỡng chế và thông tin tài sản/tài khoản liên quan. |
| 10 | tax_vln_pny_dcsn | Quyết định xử lý vi phạm hành chính về thuế. Ghi nhận hành vi vi phạm và mức phạt/truy thu. |
| 11 | tax_inv_nfrc_ordr | Quyết định cưỡng chế nợ thuế theo hình thức ngừng sử dụng hóa đơn. Ghi nhận thông tin quyết định và thông báo. |
| 12 | tax_inv_nfrc_ordr_itm | Chi tiết hóa đơn thuộc quyết định cưỡng chế ngừng sử dụng hóa đơn. Ghi nhận số hiệu và loại hóa đơn. |




### 2.1.2 Bảng rgst_taxpayer



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | rgst_taxpayer_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | rgst_taxpayer_code | STRING |  |  |  |  | ID bản ghi đăng ký thuế. BK |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. Giá trị: DCST.THONG_TIN_DK_THUE |
| 4 | full_nm | STRING | X |  |  |  | Tên người nộp thuế |
| 5 | org_tax_identn_nbr | STRING | X |  |  |  | Mã số thuế |
| 6 | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ |
| 7 | charter_cptl_ccy_code | STRING | X |  | F |  | Loại tiền vốn điều lệ |
| 8 | frgn_charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ nước ngoài |
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






### 2.1.3 Bảng taxpayer_rprs



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | taxpayer_rprs_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | taxpayer_rprs_code | STRING |  |  |  |  | ID bản ghi người đại diện. BK |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.TTKDT_NGUOI_DAI_DIEN' | Mã nguồn dữ liệu. Giá trị: DCST.TTKDT_NGUOI_DAI_DIEN |
| 4 | rgst_taxpayer_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer |
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






### 2.1.4 Bảng hrsk_taxpayer_ases_snpst



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | hrsk_taxpayer_ases_snpst_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | hrsk_taxpayer_ases_snpst_code | STRING |  |  |  |  | ID bản ghi đánh giá rủi ro. BK |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.DN_RUI_RO_CAO' | Mã nguồn dữ liệu. Giá trị: DCST.DN_RUI_RO_CAO |
| 4 | rgst_taxpayer_id | BIGINT | X |  | F |  | FK đến Registered Taxpayer — resolve qua MST |
| 5 | rgst_taxpayer_code | STRING | X |  |  |  | Mã NNT — resolve qua MST |
| 6 | org_tax_identn_nbr | STRING | X |  |  |  | Mã số doanh nghiệp |
| 7 | org_full_nm | STRING | X |  |  |  | Tên doanh nghiệp |
| 8 | org_hd_offc_adr | STRING | X |  |  |  | Địa chỉ trụ sở chính |
| 9 | spvsr_tax_ahr_nm | STRING | X |  |  |  | Cơ quan quản lý thuế |
| 10 | rsk_ases_yr | STRING | X |  |  |  | Năm đánh giá rủi ro |


#### 2.1.4.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| hrsk_taxpayer_ases_snpst_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rgst_taxpayer_id | rgst_taxpayer | rgst_taxpayer_id |






### 2.1.5 Bảng ip_pst_adr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer |
| 2 | ip_code | STRING |  |  |  |  | Mã NNT |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — kinh doanh. |
| 5 | adr_val | STRING | X |  |  |  | Mô tả địa chỉ kinh doanh |
| 6 | prov_code | STRING | X |  |  |  | Mã tỉnh kinh doanh |
| 7 | prov_nm | STRING | X |  |  |  | Tên tỉnh kinh doanh |
| 8 | dstc_code | STRING | X |  |  |  | Mã huyện kinh doanh |
| 9 | dstc_nm | STRING | X |  |  |  | Tên huyện kinh doanh |
| 10 | ward_code | STRING | X |  |  |  | Mã xã kinh doanh |
| 11 | ward_nm | STRING | X |  |  |  | Tên xã kinh doanh |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |
| 13 | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer |
| 14 | ip_code | STRING |  |  |  |  | Mã NNT |
| 15 | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. |
| 16 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — trụ sở chính. |
| 17 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính |
| 18 | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 19 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). |
| 20 | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. |
| 21 | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. |
| 22 | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 23 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 24 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


#### 2.1.5.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | rgst_taxpayer | rgst_taxpayer_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |






### 2.1.6 Bảng ip_elc_adr



#### Từ DCST.THONG_TIN_DK_THUE

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer |
| 2 | ip_code | STRING |  |  |  |  | Mã NNT |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email kinh doanh. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email kinh doanh |
| 6 | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer |
| 7 | ip_code | STRING |  |  |  |  | Mã NNT |
| 8 | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — fax kinh doanh. |
| 10 | elc_adr_val | STRING | X |  |  |  | Fax kinh doanh |
| 11 | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer |
| 12 | ip_code | STRING |  |  |  |  | Mã NNT |
| 13 | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — fax trụ sở. |
| 15 | elc_adr_val | STRING | X |  |  |  | Fax trụ sở chính |
| 16 | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer |
| 17 | ip_code | STRING |  |  |  |  | Mã NNT |
| 18 | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. |
| 19 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại kinh doanh. |
| 20 | elc_adr_val | STRING | X |  |  |  | Số điện thoại kinh doanh |
| 21 | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer |
| 22 | ip_code | STRING |  |  |  |  | Mã NNT |
| 23 | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. |
| 24 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại trụ sở. |
| 25 | elc_adr_val | STRING | X |  |  |  | Số điện thoại trụ sở chính |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | rgst_taxpayer | rgst_taxpayer_id |




#### Từ DCST.TTKDT_NGUOI_DAI_DIEN

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Taxpayer Representative |
| 2 | ip_code | STRING |  |  |  |  | Mã người đại diện |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.TTKDT_NGUOI_DAI_DIEN' | Mã nguồn dữ liệu. |
| 4 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email |
| 6 | ip_id | BIGINT |  |  | F |  | FK đến Taxpayer Representative |
| 7 | ip_code | STRING |  |  |  |  | Mã người đại diện |
| 8 | src_stm_code | STRING |  |  |  | 'DCST.TTKDT_NGUOI_DAI_DIEN' | Mã nguồn dữ liệu. |
| 9 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — fax. |
| 10 | elc_adr_val | STRING | X |  |  |  | Fax |
| 11 | ip_id | BIGINT |  |  | F |  | FK đến Taxpayer Representative |
| 12 | ip_code | STRING |  |  |  |  | Mã người đại diện |
| 13 | src_stm_code | STRING |  |  |  | 'DCST.TTKDT_NGUOI_DAI_DIEN' | Mã nguồn dữ liệu. |
| 14 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại. |
| 15 | elc_adr_val | STRING | X |  |  |  | Số điện thoại |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | taxpayer_rprs | taxpayer_rprs_id |







### 2.1.7 Bảng ip_alt_identn



#### Từ DCST.THONG_TIN_DK_THUE

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer |
| 2 | ip_code | STRING |  |  |  |  | Mã NNT |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — giấy phép thành lập. |
| 5 | identn_nbr | STRING | X |  |  |  | Số giấy phép thành lập |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Cơ quan cấp giấy phép thành lập |
| 8 | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer |
| 9 | ip_code | STRING |  |  |  |  | Mã NNT |
| 10 | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. |
| 11 | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — quyết định thành lập. |
| 12 | identn_nbr | STRING | X |  |  |  | Số quyết định thành lập |
| 13 | issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định |
| 14 | issu_ahr_nm | STRING | X |  |  |  | Cơ quan ban hành quyết định thành lập |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | rgst_taxpayer | rgst_taxpayer_id |




#### Từ DCST.TTKDT_NGUOI_DAI_DIEN

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | BIGINT |  |  | F |  | FK đến Taxpayer Representative |
| 2 | ip_code | STRING |  |  |  |  | Mã người đại diện |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.TTKDT_NGUOI_DAI_DIEN' | Mã nguồn dữ liệu. |
| 4 | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — CCCD. |
| 5 | identn_nbr | STRING | X |  |  |  | Số CCCD |
| 6 | issu_dt | DATE | X |  |  |  | Ngày cấp CCCD |
| 7 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp CCCD/Hộ chiếu. |
| 8 | ip_id | BIGINT |  |  | F |  | FK đến Taxpayer Representative |
| 9 | ip_code | STRING |  |  |  |  | Mã người đại diện |
| 10 | src_stm_code | STRING |  |  |  | 'DCST.TTKDT_NGUOI_DAI_DIEN' | Mã nguồn dữ liệu. |
| 11 | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — CMND. |
| 12 | identn_nbr | STRING | X |  |  |  | Số CMND |
| 13 | issu_dt | DATE | X |  |  |  | Ngày cấp CMND |
| 14 | issu_ahr_nm | STRING | X |  |  |  | Nơi cấp CMND/CCCD. |
| 15 | ip_id | BIGINT |  |  | F |  | FK đến Taxpayer Representative |
| 16 | ip_code | STRING |  |  |  |  | Mã người đại diện |
| 17 | src_stm_code | STRING |  |  |  | 'DCST.TTKDT_NGUOI_DAI_DIEN' | Mã nguồn dữ liệu. |
| 18 | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — hộ chiếu. |
| 19 | identn_nbr | STRING | X |  |  |  | Số hộ chiếu |
| 20 | issu_dt | DATE | X |  |  |  | Ngày cấp hộ chiếu |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | taxpayer_rprs | taxpayer_rprs_id |







### 2.1.8 Bảng tax_fnc_stmt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | tax_fnc_stmt_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | tax_fnc_stmt_code | STRING |  |  |  |  | Mã định danh bản ghi trong DCST. BK |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.TCT_BAO_CAO' | Mã nguồn dữ liệu. Giá trị: DCST.TCT_BAO_CAO |
| 4 | rgst_taxpayer_id | BIGINT | X |  | F |  | Mã số thuế. FK đến Registered Taxpayer |
| 5 | rgst_taxpayer_code | STRING | X |  |  |  | Mã số thuế |
| 6 | taxpayer_nm | STRING | X |  |  |  | Tên người nộp thuế |
| 7 | taxpayer_adr | STRING | X |  |  |  | Địa chỉ người nộp thuế |
| 8 | taxpayer_ward | STRING | X |  |  |  | Phường xã |
| 9 | taxpayer_dstc_code | STRING | X |  |  |  | Mã huyện người nộp thuế |
| 10 | taxpayer_dstc_nm | STRING | X |  |  |  | Tên huyện người nộp thuế |
| 11 | taxpayer_prov_code | STRING | X |  |  |  | Mã tỉnh người nộp thuế |
| 12 | taxpayer_prov_nm | STRING | X |  |  |  | Tên tỉnh người nộp thuế |
| 13 | taxpayer_ph_nbr | STRING | X |  |  |  | Điện thoại người nộp thuế |
| 14 | taxpayer_fax_nbr | STRING | X |  |  |  | Fax người nộp thuế |
| 15 | taxpayer_email | STRING | X |  |  |  | Email người nộp thuế |
| 16 | bsn_idy | STRING | X |  |  |  | Ngày nghề kinh doanh |
| 17 | svc_code | STRING | X |  |  |  | Mã dịch vụ |
| 18 | svc_nm | STRING | X |  |  |  | Tên dịch vụ |
| 19 | svc_vrsn | STRING | X |  |  |  | Phiên bản dịch vụ |
| 20 | svc_pvdr_inf | STRING | X |  |  |  | Thông tin nhà cung cấp dịch vụ |
| 21 | tax_ret_code | STRING | X |  |  |  | Mã tờ khai |
| 22 | tax_ret_nm | STRING | X |  |  |  | Tên tờ khai |
| 23 | tax_ret_form_dsc | STRING | X |  |  |  | Mô tả biểu mẫu |
| 24 | tax_ret_xml_vrsn | STRING | X |  |  |  | Phiên bản tờ khai XML |
| 25 | tax_ret_tp_code | STRING | X |  |  |  | Loại tờ khai |
| 26 | amdt_cnt | INT | X |  |  |  | Số lần |
| 27 | rpt_prd_tp_code | STRING | X |  |  |  | Kiểu kỳ |
| 28 | rpt_prd | STRING | X |  |  |  | Kỳ kê khai |
| 29 | rpt_prd_strt_dt | STRING | X |  |  |  | Kỳ kê khai từ ngày |
| 30 | rpt_prd_end_dt | STRING | X |  |  |  | Kỳ kê khai đến ngày |
| 31 | rpt_prd_strt_mo | STRING | X |  |  |  | Kỳ kê khai từ tháng |
| 32 | rpt_prd_end_mo | STRING | X |  |  |  | Kỳ kê khai đến tháng |
| 33 | tax_ahr_code | STRING | X |  |  |  | Mã cơ quan thuế nơi nộp |
| 34 | tax_ahr_nm | STRING | X |  |  |  | Tên cơ quan thuế nơi nộp |
| 35 | filg_dt | STRING | X |  |  |  | Ngày lập tờ khai |
| 36 | exn_rsn_code | STRING | X |  |  |  | Mã lý do gia hạn |
| 37 | exn_rsn | STRING | X |  |  |  | Lý do gia hạn |
| 38 | signatory_nm | STRING | X |  | F |  | Người ký |
| 39 | signing_dt | DATE | X |  |  |  | Ngày ký |
| 40 | audt_st_code | STRING | X |  |  |  | Trạng thái kiểm toán |
| 41 | audt_firm_tax_identn_nbr | STRING | X |  | F |  | Mã số thuế tổ chức kiểm toán |
| 42 | audt_firm_nm | STRING | X |  |  |  | Tổ chức kiểm toán |
| 43 | auditor_code | STRING | X |  |  |  | Mã kiểm toán viên |
| 44 | auditor_nm | STRING | X |  |  |  | Kiểm toán vien |
| 45 | audited_fnc_stmt_ind | STRING | X |  |  |  | Báo cáo tài chính đã kiểm toán |
| 46 | audt_opinion_code | STRING | X |  |  |  | Mã ý kiến kiểm toán |
| 47 | audt_opinion | STRING | X |  |  |  | Ý kiến kiểm toán |
| 48 | audt_dt | DATE | X |  |  |  | Ngày kiểm toán |
| 49 | crt_dt | STRING | X |  |  |  | Ngày tạo |
| 50 | subm_dt | DATE | X |  |  |  | Ngày nộp tờ khai |
| 51 | recpt_dt | DATE | X |  |  |  | Ngày tiếp nhận |
| 52 | rpt_set_prd | STRING | X |  |  |  | Kỳ lập bộ báo cáo |
| 53 | filg_orig | STRING | X |  |  |  | Nguồn gốc tờ khai |
| 54 | filg_entr_psn | STRING | X |  |  |  | Người nhập tờ khại |
| 55 | filg_ack_dt | DATE | X |  |  |  | Ngày nhận tờ khai |
| 56 | filg_refr_id | STRING | X |  |  |  | ID tờ khai |
| 57 | sending_lo | STRING | X |  |  |  | Nơi gửi |
| 58 | receiving_lo | STRING | X |  |  |  | Nơi nhận |


#### 2.1.8.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| tax_fnc_stmt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rgst_taxpayer_id | rgst_taxpayer | rgst_taxpayer_id |






### 2.1.9 Bảng tax_fnc_stmt_itm



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | tax_fnc_stmt_itm_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | tax_fnc_stmt_itm_code | STRING |  |  |  |  | Mã định danh bản ghi trong DCST. BK |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.TCT_BAO_CAO_CHI_TIET' | Mã nguồn dữ liệu. Giá trị: DCST.TCT_BAO_CAO_CHI_TIET |
| 4 | tax_fnc_stmt_id | BIGINT |  |  | F |  | ID bảng TCT_BAO_CAO. FK đến Tax Financial Statement |
| 5 | tax_fnc_stmt_code | STRING |  |  |  |  | ID bảng TCT_BAO_CAO |
| 6 | line_itm_code | STRING | X |  |  |  | Mã chỉ tiêu |
| 7 | line_itm_nm | STRING | X |  |  |  | Tên chỉ tiêu |
| 8 | line_itm_note | STRING | X |  |  |  | Thuyết minh |
| 9 | shet_nm | STRING | X |  |  |  | Tên sheet |
| 10 | yr_end_amt | STRING | X |  |  |  | Số cuối năm |
| 11 | yr_strt_amt | STRING | X |  |  |  | Số đầu năm |
| 12 | crn_yr_amt | STRING | X |  |  |  | Năm nay |
| 13 | prev_yr_amt | STRING | X |  |  |  | Năm trước |
| 14 | prev_yr_incr_amt | STRING | X |  |  |  | Số tăng năm nay |
| 15 | crn_yr_net_amt | STRING | X |  |  |  | Số năm nay |
| 16 | prev_yr_net_amt | STRING | X |  |  |  | Số năm ngoái |
| 17 | crn_yr_opn_bal | STRING | X |  |  |  | Số dư đầu năm nay |
| 18 | crn_yr_cls_bal | STRING | X |  |  |  | Số dư cuối năm nay |
| 19 | prev_yr_opn_bal | STRING | X |  |  |  | Số dư đầu năm trước |
| 20 | prev_yr_cls_bal | STRING | X |  |  |  | Số dư cuối năm trước |
| 21 | crn_yr_incr_amt | STRING | X |  |  |  | Số tăng năm nay |
| 22 | crn_yr_dec_amt | STRING | X |  |  |  | Số giảm năm nay |
| 23 | prev_yr_dec_amt | STRING | X |  |  |  | Số giảm năm trước |
| 24 | preparer_nm | STRING | X |  |  |  | Người lập biểu |
| 25 | chief_accountant_nm | STRING | X |  |  |  | Kế toán trưởng |
| 26 | rpt_prep_dt | STRING | X |  |  |  | Ngày lập |
| 27 | director_nm | STRING | X |  |  |  | Giám đốc |
| 28 | auditor_license_nbr | STRING | X |  |  |  | Số chứng chỉ hành nghề |
| 29 | audt_firm_nm | STRING | X |  |  |  | Đơn vị cung cấp dịch vụ kiểm toán |
| 30 | going_concern_ind | STRING | X |  |  |  | Hoạt động liên tục |
| 31 | non_going_concern_ind | STRING | X |  |  |  | Hoạt động không liên tục |


#### 2.1.9.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| tax_fnc_stmt_itm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| tax_fnc_stmt_id | tax_fnc_stmt | tax_fnc_stmt_id |






### 2.1.10 Bảng tax_dbt_nfrc_ordr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | tax_dbt_nfrc_ordr_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | tax_dbt_nfrc_ordr_code | STRING |  |  |  |  | Mã định danh bản ghi trong DCST. BK |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.TCT_TT_CUONG_CHE_NO' | Mã nguồn dữ liệu. Giá trị: DCST.TCT_TT_CUONG_CHE_NO |
| 4 | rgst_taxpayer_id | BIGINT | X |  | F |  | Mã người nhận. FK đến Registered Taxpayer |
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


#### 2.1.10.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| tax_dbt_nfrc_ordr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rgst_taxpayer_id | rgst_taxpayer | rgst_taxpayer_id |






### 2.1.11 Bảng tax_vln_pny_dcsn



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | tax_vln_pny_dcsn_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | tax_vln_pny_dcsn_code | STRING |  |  |  |  | Mã định danh bản ghi trong DCST. BK |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.TT_XLY_VI_PHAM' | Mã nguồn dữ liệu. Giá trị: DCST.TT_XLY_VI_PHAM |
| 4 | rgst_taxpayer_id | BIGINT | X |  | F |  | Mã số thuế. FK đến Registered Taxpayer |
| 5 | rgst_taxpayer_code | STRING | X |  |  |  | Mã số thuế |
| 6 | taxpayer_nm | STRING | X |  |  |  | Tên đối tượng |
| 7 | ordr_nbr | STRING | X |  |  |  | Số quyết định xử lý |
| 8 | issu_ahr_nm | STRING | X |  |  |  | Cơ quan ban hành |
| 9 | insp_prd | STRING | X |  |  |  | Kỳ thanh tra kiểm tra |
| 10 | vln_pny_dsc | STRING | X |  |  |  | Phạt hành vi vi phạm |
| 11 | admn_vln_pny_dsc | STRING | X |  |  |  | Phạt hành vi vi phạm hành chính |
| 12 | tax_ars_rec_amt | STRING | X |  |  |  | Truy thu tiền thuế, tiền nộp chậm |


#### 2.1.11.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| tax_vln_pny_dcsn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rgst_taxpayer_id | rgst_taxpayer | rgst_taxpayer_id |






### 2.1.12 Bảng tax_inv_nfrc_ordr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | tax_inv_nfrc_ordr_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | tax_inv_nfrc_ordr_code | STRING |  |  |  |  | Mã định danh bản ghi trong DCST. BK |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.TCT_TTCCN_HOA_DON' | Mã nguồn dữ liệu. Giá trị: DCST.TCT_TTCCN_HOA_DON |
| 4 | rgst_taxpayer_id | BIGINT | X |  | F |  | Mã số thuế của người nộp thuế. FK đến Registered Taxpayer |
| 5 | rgst_taxpayer_code | STRING | X |  |  |  | Mã số thuế của người nộp thuế |
| 6 | taxpayer_nm | STRING | X |  |  |  | Tên người nộp thuế |
| 7 | spvsr_tax_ahr_code | STRING | X |  |  |  | Mã cơ quan quản lý trực tiếp |
| 8 | spvsr_tax_ahr_nm | STRING | X |  |  |  | Tên cơ quan quản lý trực tiếp |
| 9 | taxpayer_bsn_idy | STRING | X |  |  |  | Tên ngành kinh doanh của đối tượng bị cưỡng chế |
| 10 | nfrc_tp_code | STRING | X |  |  |  | Mã hình thức cưỡng chế |
| 11 | nfrc_tp_nm | STRING | X |  |  |  | Tên hình thức cưỡng chế |
| 12 | elc_txn_code | STRING | X |  |  |  | Mã giao dịch điện tử |
| 13 | inv_nfrc_ordr_nbr | STRING | X |  |  |  | Số quyết định |
| 14 | inv_nfrc_ordr_dt | DATE | X |  |  |  | Ngày quyết định |
| 15 | nfrc_eff_strt_dt | DATE | X |  |  |  | Ngày hiệu lực từ |
| 16 | nfrc_eff_end_dt | DATE | X |  |  |  | Ngày hiệu lực đến |
| 17 | nfrc_st | STRING | X |  |  |  | Hiệu lực |
| 18 | prev_nfrc_ordr_nbr | STRING | X |  | F |  | Căn cứ số quyết định |
| 19 | prev_nfrc_ordr_dt | DATE | X |  |  |  | Căn cứ ngày quyết định |
| 20 | ntc_taxpayer_code | STRING | X |  |  |  | Thông báo: Mã số thuế người nộp thuế |
| 21 | ntc_taxpayer_nm | STRING | X |  |  |  | Thông báo: Tên người nộp thuế |
| 22 | ntc_code | STRING | X |  |  |  | Mã thông báo |
| 23 | ntc_nm | STRING | X |  |  |  | Tên thông báo |
| 24 | notified_tax_dbt_amt | STRING | X |  |  |  | Thông báo số tiền nợ và số tiền phạt nộp chậm |
| 25 | dbt_ntc_dt | DATE | X |  |  |  | Thông báo tiền nợ và tiền phạt nộp chậm |


#### 2.1.12.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| tax_inv_nfrc_ordr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rgst_taxpayer_id | rgst_taxpayer | rgst_taxpayer_id |






### 2.1.13 Bảng tax_inv_nfrc_ordr_itm



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | tax_inv_nfrc_ordr_itm_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) |
| 2 | tax_inv_nfrc_ordr_itm_code | STRING |  |  |  |  | Mã định danh bản ghi trong DCST. BK |
| 3 | src_stm_code | STRING |  |  |  | 'DCST.HOA_DON_CHI_TIET' | Mã nguồn dữ liệu. Giá trị: DCST.HOA_DON_CHI_TIET |
| 4 | tax_inv_nfrc_ordr_id | BIGINT |  |  | F |  | ID Thông tin cưỡng chế nợ theo hóa đơn. FK đến Tax Invoice Enforcement Order |
| 5 | tax_inv_nfrc_ordr_code | STRING |  |  |  |  | ID Thông tin cưỡng chế nợ theo hóa đơn |
| 6 | inv_tpl_symb | STRING | X |  |  |  | Ký hiệu mẫu |
| 7 | inv_series_symb | STRING | X |  |  |  | Ký hiệu hóa đơn |
| 8 | inv_nbr | STRING | X |  |  |  | Số hóa đơn |
| 9 | inv_tp_code | STRING | X |  |  |  | Loại hóa đơn |


#### 2.1.13.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| tax_inv_nfrc_ordr_itm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| tax_inv_nfrc_ordr_id | tax_inv_nfrc_ordr | tax_inv_nfrc_ordr_id |







