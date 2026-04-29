## 2.{IDX} DCST — Dữ liệu Cơ quan Thuế từ Tổng cục Thuế

### 2.{IDX}.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`DCST.dbml`](DCST.dbml) — paste vào https://dbdiagram.io để render.
- Diagram theo mảng nghiệp vụ:
  - **UID01 — Quản lý thông tin đăng ký thuế**: [`DCST_UID01.dbml`](DCST_UID01.dbml)
  - **UID02 — Báo cáo tài chính từ Tổng cục Thuế**: [`DCST_UID02.dbml`](DCST_UID02.dbml)
  - **UID03 — Cưỡng chế nợ thuế**: [`DCST_UID03.dbml`](DCST_UID03.dbml)
  - **UID04 — Xử lý vi phạm pháp luật về thuế**: [`DCST_UID04.dbml`](DCST_UID04.dbml)
  - **UID05 — Giám sát doanh nghiệp rủi ro cao**: [`DCST_UID05.dbml`](DCST_UID05.dbml)


**Danh sách bảng:**

| STT | Thực thể | Tên bảng | Mô tả |
|---|---|---|---|
| 1 | Registered Taxpayer | rgst_taxpayer | Doanh nghiệp/hộ kinh doanh đã đăng ký thuế với cơ quan thuế. Lưu thông tin pháp lý và trạng thái hoạt động. |
| 2 | Taxpayer Representative | taxpayer_representative | Người đại diện hoặc chủ hộ kinh doanh của người nộp thuế. Ghi nhận tên và chức vụ. |
| 3 | High Risk Taxpayer Assessment Snapshot | hrsk_taxpayer_ases_snpst | Đánh giá xếp loại doanh nghiệp rủi ro cao về thuế theo năm. Ghi nhận thông tin tổ chức bị đánh giá rủi ro. |
| 4 | Involved Party Postal Address | ip_pst_adr | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |
| 5 | Involved Party Electronic Address | ip_elc_adr | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 6 | Involved Party Alternative Identification | ip_alt_identn | Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn. |
| 7 | Tax Financial Statement | tax_fnc_stmt | Tờ khai tài chính điện tử nộp lên cơ quan thuế. Ghi nhận kỳ kê khai và thông tin kiểm toán. |
| 8 | Tax Financial Statement Item | tax_fnc_stmt_itm | Chỉ tiêu chi tiết trong tờ khai tài chính. Ghi nhận giá trị số liệu theo từng ô chỉ tiêu trong biểu mẫu. |
| 9 | Tax Debt Enforcement Order | tax_dbt_enforcement_ordr | Quyết định cưỡng chế nợ thuế. Ghi nhận hình thức cưỡng chế và thông tin tài sản/tài khoản liên quan. |
| 10 | Tax Violation Penalty Decision | tax_vln_pny_dcsn | Quyết định xử lý vi phạm hành chính về thuế. Ghi nhận hành vi vi phạm và mức phạt/truy thu. |
| 11 | Tax Invoice Enforcement Order | tax_inv_enforcement_ordr | Quyết định cưỡng chế nợ thuế theo hình thức ngừng sử dụng hóa đơn. Ghi nhận thông tin quyết định và thông báo. |
| 12 | Tax Invoice Enforcement Order Item | tax_inv_enforcement_ordr_itm | Chi tiết hóa đơn thuộc quyết định cưỡng chế ngừng sử dụng hóa đơn. Ghi nhận số hiệu và loại hóa đơn. |
| 13 |  |  |  |



### 2.{IDX}.2 Bảng Registered Taxpayer

- **Mô tả:** Doanh nghiệp/hộ kinh doanh đã đăng ký thuế với cơ quan thuế. Lưu thông tin pháp lý và trạng thái hoạt động.
- **Tên vật lý:** rgst_taxpayer
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Registered Taxpayer Id | rgst_taxpayer_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | DCST.THONG_TIN_DK_THUE |  | PK surrogate. BCV: "Organization" (Involved Party). |
| 2 | Registered Taxpayer Code | rgst_taxpayer_code | STRING |  |  |  |  | ID bản ghi đăng ký thuế. BK | DCST.THONG_TIN_DK_THUE | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. Giá trị: DCST.THONG_TIN_DK_THUE | DCST.THONG_TIN_DK_THUE |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Full Name | full_nm | STRING | X |  |  |  | Tên người nộp thuế | DCST.THONG_TIN_DK_THUE | TEN_NGUOI_NOP |  |
| 5 | Organization Tax Identification Number | org_tax_identn_nbr | STRING | X |  |  |  | Mã số thuế | DCST.THONG_TIN_DK_THUE | MA_SO_THUE |  |
| 6 | Charter Capital Amount | charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ | DCST.THONG_TIN_DK_THUE | VON_DIEU_LE |  |
| 7 | Charter Capital Currency Code | charter_cptl_ccy_code | STRING | X |  | F |  | Loại tiền vốn điều lệ | DCST.THONG_TIN_DK_THUE | LOAITIEN_VON_DL_VN |  |
| 8 | Foreign Charter Capital Amount | frgn_charter_cptl_amt | DECIMAL(18,2) | X |  |  |  | Vốn điều lệ nước ngoài | DCST.THONG_TIN_DK_THUE | SOTIEN_VON_DL_NN |  |
| 9 | Foreign Charter Capital Currency Code | frgn_charter_cptl_ccy_code | STRING | X |  | F |  | Loại tiền vốn điều lệ nước ngoài | DCST.THONG_TIN_DK_THUE | LOAITIEN_VON_DL_NN |  |
| 10 | Business Line Code | bsn_line_code | STRING | X |  |  |  | Mã ngành nghề kinh doanh | DCST.THONG_TIN_DK_THUE | MA_NGANH |  |
| 11 | Business Line Description | bsn_line_dsc | STRING | X |  |  |  | Ngành nghề kinh doanh | DCST.THONG_TIN_DK_THUE | NGANH_NGHE_KD |  |
| 12 | Business Commencement Date | bsn_commencement_dt | DATE | X |  |  |  | Ngày bắt đầu hoạt động kinh doanh | DCST.THONG_TIN_DK_THUE | NGAY_BD_HDKD |  |
| 13 | Parent Organization Name | prn_org_nm | STRING | X |  |  |  | Đơn vị chủ quan/ đơn vị quản lý trực thuộc | DCST.THONG_TIN_DK_THUE | DON_VI_CHU_QUAN |  |
| 14 | Parent Organization Address | prn_org_adr | STRING | X |  |  |  | Địa chỉ đơn vị chủ quản | DCST.THONG_TIN_DK_THUE | DVCQ_VN_DIACHI |  |
| 15 | Supervisory Authority Name | spvsr_ahr_nm | STRING | X |  |  |  | Cơ quan quản lý trực tiếp | DCST.THONG_TIN_DK_THUE | CO_QUAN_QUAN_LY_TRUC_TIEP |  |
| 16 | Supervisory Tax Authority Code | spvsr_tax_ahr_code | STRING | X |  |  |  | Mã cơ quan quản lý thuế | DCST.THONG_TIN_DK_THUE | MA_CQQL_QLT |  |
| 17 | Legal Representative Name | lgl_representative_nm | STRING | X |  |  |  | Tên người đại diện kinh doanh | DCST.THONG_TIN_DK_THUE | TEN_NGUOI_DAI_DIEN_KD |  |
| 18 | Legal Representative Identification Number | lgl_representative_identn_nbr | STRING | X |  |  |  | Số CMT/ hộ chiếu người đại diện theo pháp luật/ chủ doanh nghiệp tư nhân | DCST.THONG_TIN_DK_THUE | SO_CMT |  |
| 19 | Legal Representative Phone Number | lgl_representative_ph_nbr | STRING | X |  |  |  | Số ĐT người đại diện theo pháp luật/ chủ doanh nghiệp tư nhân | DCST.THONG_TIN_DK_THUE | SO_DIEN_THOAI |  |
| 20 | Director Name | director_nm | STRING | X |  |  |  | Tên giám đốc/ tổng giám đốc | DCST.THONG_TIN_DK_THUE | TEN_GIAM_DOC |  |
| 21 | Director Phone Number | director_ph_nbr | STRING | X |  |  |  | Số điện thoại giám đốc/ tổng giám đốc | DCST.THONG_TIN_DK_THUE | SO_DIEN_THOAI_GD |  |
| 22 | Life Cycle Status Code | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động: 00, 04: Đang hoạt động; 01: Ngừng HĐ đã hoàn thành thủ tục; 03: Ngừng HĐ chưa hoàn thành; 05: Ngừng KD có thời hạn; 06: Không HĐ tại địa chỉ đăng ký | DCST.THONG_TIN_DK_THUE | TRANG_THAI_HOAT_DONG | Scheme: LIFE_CYCLE_STATUS. |
| 23 | Life Cycle Status Name | lcs_nm | STRING | X |  |  |  | Tên trạng thái người nộp thuế. Giá trị denormalized từ nguồn | DCST.THONG_TIN_DK_THUE | TEN_TRANG_THAI |  |
| 24 | Cessation Reason Description | cessation_rsn_dsc | STRING | X |  |  |  | Lý do ngừng hoạt động | DCST.THONG_TIN_DK_THUE | LY_DO_NGUNG_HOAT_DONG |  |
| 25 | Cessation Type Code | cessation_tp_code | STRING | X |  |  |  | Loại ngừng hoạt động: 1. Giải thể; 2. Phá sản; 3. Chuyển đổi loại hình DN; 4. Cho làm thủ tục giải thể; 5. Phá sản; 6. Tổ chức lại; 7. Thu hồi GP; 8. Đóng theo ĐVCQ; 9. Khác | DCST.THONG_TIN_DK_THUE | LOAI_NGUNG_HOAT_DONG | Scheme: TAXPAYER_CESSATION_TYPE. |
| 26 | Cessation Date | cessation_dt | DATE | X |  |  |  | Ngày ngừng hoạt động | DCST.THONG_TIN_DK_THUE | NGUNG_HD_NGAY |  |
| 27 | Cessation Reason | cessation_rsn | STRING | X |  |  |  | Lý do ngừng hoạt động (chi tiết) | DCST.THONG_TIN_DK_THUE | NGUNG_HD_LY_DO |  |
| 28 | Cessation Note | cessation_note | STRING | X |  |  |  | Ghi chú ngừng hoạt động | DCST.THONG_TIN_DK_THUE | NGUNG_HD_GHI_CHU |  |
| 29 | Cessation Notice Number | cessation_ntc_nbr | STRING | X |  |  |  | Số thông báo ngừng hoạt động | DCST.THONG_TIN_DK_THUE | NGUNG_HD_SO_TBAO |  |
| 30 | Temporary Suspension Start Date | temp_susp_strt_dt | DATE | X |  |  |  | Tạm nghỉ/Từ ngày | DCST.THONG_TIN_DK_THUE | TAM_NGHI_TU_NGAY |  |
| 31 | Temporary Suspension End Date | temp_susp_end_dt | DATE | X |  |  |  | Tạm nghỉ/Đến ngày | DCST.THONG_TIN_DK_THUE | TAM_NGHI_DEN_NGAY |  |
| 32 | Temporary Suspension Reason | temp_susp_rsn | STRING | X |  |  |  | Lý do tạm nghỉ | DCST.THONG_TIN_DK_THUE | TAM_NGHI_LY_DO |  |
| 33 | Temporary Suspension Notice Number | temp_susp_ntc_nbr | STRING | X |  |  |  | Số thông báo - tạm nghỉ | DCST.THONG_TIN_DK_THUE | TAM_NGHI_SO_TBAO |  |
| 34 | Temporary Suspension Notice Date | temp_susp_ntc_dt | DATE | X |  |  |  | Ngày thông báo - tạm nghỉ | DCST.THONG_TIN_DK_THUE | TAM_NGHI_NGAY_TB_NNT |  |


#### 2.{IDX}.2.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Registered Taxpayer Id | rgst_taxpayer_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Charter Capital Currency Code | charter_cptl_ccy_code | Currency | Currency Code |  |
| Foreign Charter Capital Currency Code | frgn_charter_cptl_ccy_code | Currency | Currency Code |  |




### 2.{IDX}.3 Bảng Taxpayer Representative

- **Mô tả:** Người đại diện hoặc chủ hộ kinh doanh của người nộp thuế. Ghi nhận tên và chức vụ.
- **Tên vật lý:** taxpayer_representative
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Taxpayer Representative Id | taxpayer_representative_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | DCST.TTKDT_NGUOI_DAI_DIEN |  | PK surrogate. BCV: "Involved Party" — người đại diện của NNT. |
| 2 | Taxpayer Representative Code | taxpayer_representative_code | STRING |  |  |  |  | ID bản ghi người đại diện. BK | DCST.TTKDT_NGUOI_DAI_DIEN | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.TTKDT_NGUOI_DAI_DIEN' | Mã nguồn dữ liệu. Giá trị: DCST.TTKDT_NGUOI_DAI_DIEN | DCST.TTKDT_NGUOI_DAI_DIEN |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Registered Taxpayer Id | rgst_taxpayer_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer | DCST.TTKDT_NGUOI_DAI_DIEN | THONG_TIN_DK_THUE_ID |  |
| 5 | Registered Taxpayer Code | rgst_taxpayer_code | STRING |  |  |  |  | Mã NNT | DCST.TTKDT_NGUOI_DAI_DIEN | THONG_TIN_DK_THUE_ID |  |
| 6 | Representative Name | representative_nm | STRING | X |  |  |  | Tên người đại diện/chủ hộ KD | DCST.TTKDT_NGUOI_DAI_DIEN | TEN_NNT |  |
| 7 | Position Title | pos_ttl | STRING | X |  |  |  | Chức vụ người đại diện/chủ hộ KD | DCST.TTKDT_NGUOI_DAI_DIEN | CHUC_VU |  |


#### 2.{IDX}.3.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Taxpayer Representative Id | taxpayer_representative_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Registered Taxpayer Id | rgst_taxpayer_id | Registered Taxpayer | Registered Taxpayer Id | rgst_taxpayer_id |




### 2.{IDX}.4 Bảng High Risk Taxpayer Assessment Snapshot

- **Mô tả:** Đánh giá xếp loại doanh nghiệp rủi ro cao về thuế theo năm. Ghi nhận thông tin tổ chức bị đánh giá rủi ro.
- **Tên vật lý:** hrsk_taxpayer_ases_snpst
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | High Risk Taxpayer Assessment Snapshot Id | hrsk_taxpayer_ases_snpst_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | DCST.DN_RUI_RO_CAO |  | PK surrogate. BCV: "Organization" (Involved Party). Đánh giá rủi ro DN. |
| 2 | High Risk Taxpayer Assessment Snapshot Code | hrsk_taxpayer_ases_snpst_code | STRING |  |  |  |  | ID bản ghi đánh giá rủi ro. BK | DCST.DN_RUI_RO_CAO | ID | BK chính. PK nguồn. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.DN_RUI_RO_CAO' | Mã nguồn dữ liệu. Giá trị: DCST.DN_RUI_RO_CAO | DCST.DN_RUI_RO_CAO |  | Scheme: SOURCE_SYSTEM. BK. Hardcode. |
| 4 | Registered Taxpayer Id | rgst_taxpayer_id | BIGINT | X |  | F |  | FK đến Registered Taxpayer — resolve qua MST | DCST.DN_RUI_RO_CAO | MA_SO_DOANH_NGHIEP |  |
| 5 | Registered Taxpayer Code | rgst_taxpayer_code | STRING | X |  |  |  | Mã NNT — resolve qua MST | DCST.DN_RUI_RO_CAO | MA_SO_DOANH_NGHIEP |  |
| 6 | Organization Tax Identification Number | org_tax_identn_nbr | STRING | X |  |  |  | Mã số doanh nghiệp | DCST.DN_RUI_RO_CAO | MA_SO_DOANH_NGHIEP |  |
| 7 | Organization Full Name | org_full_nm | STRING | X |  |  |  | Tên doanh nghiệp | DCST.DN_RUI_RO_CAO | TEN_DOANH_NGHIEP |  |
| 8 | Organization Head Office Address | org_hd_offc_adr | STRING | X |  |  |  | Địa chỉ trụ sở chính | DCST.DN_RUI_RO_CAO | DIA_CHI_TSC |  |
| 9 | Supervisory Tax Authority Name | spvsr_tax_ahr_nm | STRING | X |  |  |  | Cơ quan quản lý thuế | DCST.DN_RUI_RO_CAO | CQ_THUE_QUAN_LY |  |
| 10 | Risk Assessment Year | rsk_ases_yr | STRING | X |  |  |  | Năm đánh giá rủi ro | DCST.DN_RUI_RO_CAO | NAM_DANH_GIA_RUI_RO |  |


#### 2.{IDX}.4.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| High Risk Taxpayer Assessment Snapshot Id | hrsk_taxpayer_ases_snpst_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Registered Taxpayer Id | rgst_taxpayer_id | Registered Taxpayer | Registered Taxpayer Id | rgst_taxpayer_id |




### 2.{IDX}.5 Bảng Involved Party Postal Address

- **Mô tả:** Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn.
- **Tên vật lý:** ip_pst_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer | DCST.THONG_TIN_DK_THUE | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã NNT | DCST.THONG_TIN_DK_THUE | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. | DCST.THONG_TIN_DK_THUE |  |  |
| 4 | Address Type Code | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — kinh doanh. | DCST.THONG_TIN_DK_THUE |  |  |
| 5 | Address Value | adr_val | STRING | X |  |  |  | Mô tả địa chỉ kinh doanh | DCST.THONG_TIN_DK_THUE | MOTA_DIACHI_KD |  |
| 6 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh kinh doanh | DCST.THONG_TIN_DK_THUE | MA_TINH_KD |  |
| 7 | Province Name | prov_nm | STRING | X |  |  |  | Tên tỉnh kinh doanh | DCST.THONG_TIN_DK_THUE | TEN_TINH_KD |  |
| 8 | District Code | dstc_code | STRING | X |  |  |  | Mã huyện kinh doanh | DCST.THONG_TIN_DK_THUE | MA_HUYEN_KD |  |
| 9 | District Name | dstc_nm | STRING | X |  |  |  | Tên huyện kinh doanh | DCST.THONG_TIN_DK_THUE | TEN_HUYEN_KD |  |
| 10 | Ward Code | ward_code | STRING | X |  |  |  | Mã xã kinh doanh | DCST.THONG_TIN_DK_THUE | MA_XA_KD |  |
| 11 | Ward Name | ward_nm | STRING | X |  |  |  | Tên xã kinh doanh | DCST.THONG_TIN_DK_THUE | TEN_XA |  |
| 12 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | DCST.THONG_TIN_DK_THUE |  |  |
| 13 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer | DCST.THONG_TIN_DK_THUE | ID |  |
| 14 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã NNT | DCST.THONG_TIN_DK_THUE | ID |  |
| 15 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. | DCST.THONG_TIN_DK_THUE |  |  |
| 16 | Address Type Code | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — trụ sở chính. | DCST.THONG_TIN_DK_THUE |  |  |
| 17 | Address Value | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính | DCST.THONG_TIN_DK_THUE | DIA_CHI_TSC |  |
| 18 | Province Id | prov_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố trụ sở. | DCST.THONG_TIN_DK_THUE |  |  |
| 19 | Province Code | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). | DCST.THONG_TIN_DK_THUE |  |  |
| 20 | District Name | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. | DCST.THONG_TIN_DK_THUE |  |  |
| 21 | Ward Name | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. | DCST.THONG_TIN_DK_THUE |  |  |
| 22 | Geographic Area Id | geo_id | BIGINT | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. | DCST.THONG_TIN_DK_THUE |  |  |
| 23 | Geographic Area Code | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. | DCST.THONG_TIN_DK_THUE |  |  |
| 24 | Address Detail | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. | DCST.THONG_TIN_DK_THUE |  |  |


#### 2.{IDX}.5.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Registered Taxpayer | Registered Taxpayer Id | rgst_taxpayer_id |
| Province Id | prov_id | Geographic Area | Geographic Area Id | geo_id |
| Geographic Area Id | geo_id | Geographic Area | Geographic Area Id | geo_id |




### 2.{IDX}.6 Bảng Involved Party Electronic Address — DCST.THONG_TIN_DK_THUE

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer | DCST.THONG_TIN_DK_THUE | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã NNT | DCST.THONG_TIN_DK_THUE | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. | DCST.THONG_TIN_DK_THUE |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email kinh doanh. | DCST.THONG_TIN_DK_THUE |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email kinh doanh | DCST.THONG_TIN_DK_THUE | EMAIL_KD |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer | DCST.THONG_TIN_DK_THUE | ID |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã NNT | DCST.THONG_TIN_DK_THUE | ID |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. | DCST.THONG_TIN_DK_THUE |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — fax kinh doanh. | DCST.THONG_TIN_DK_THUE |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Fax kinh doanh | DCST.THONG_TIN_DK_THUE | FAX_KD |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer | DCST.THONG_TIN_DK_THUE | ID |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã NNT | DCST.THONG_TIN_DK_THUE | ID |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. | DCST.THONG_TIN_DK_THUE |  |  |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — fax trụ sở. | DCST.THONG_TIN_DK_THUE |  |  |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Fax trụ sở chính | DCST.THONG_TIN_DK_THUE | FAX |  |
| 16 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer | DCST.THONG_TIN_DK_THUE | ID |  |
| 17 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã NNT | DCST.THONG_TIN_DK_THUE | ID |  |
| 18 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. | DCST.THONG_TIN_DK_THUE |  |  |
| 19 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại kinh doanh. | DCST.THONG_TIN_DK_THUE |  |  |
| 20 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại kinh doanh | DCST.THONG_TIN_DK_THUE | DIEN_THOAI_KD |  |
| 21 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer | DCST.THONG_TIN_DK_THUE | ID |  |
| 22 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã NNT | DCST.THONG_TIN_DK_THUE | ID |  |
| 23 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. | DCST.THONG_TIN_DK_THUE |  |  |
| 24 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại trụ sở. | DCST.THONG_TIN_DK_THUE |  |  |
| 25 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại trụ sở chính | DCST.THONG_TIN_DK_THUE | DIEN_THOAI |  |


#### 2.{IDX}.6.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Registered Taxpayer | Registered Taxpayer Id | rgst_taxpayer_id |




### 2.{IDX}.7 Bảng Involved Party Alternative Identification — DCST.THONG_TIN_DK_THUE

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer | DCST.THONG_TIN_DK_THUE | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã NNT | DCST.THONG_TIN_DK_THUE | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. | DCST.THONG_TIN_DK_THUE |  |  |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — giấy phép thành lập. | DCST.THONG_TIN_DK_THUE |  |  |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số giấy phép thành lập | DCST.THONG_TIN_DK_THUE | SO_GIAY_PHEP |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp giấy phép | DCST.THONG_TIN_DK_THUE | NGAY_CAP |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Cơ quan cấp giấy phép thành lập | DCST.THONG_TIN_DK_THUE | CO_QUAN_CAP |  |
| 8 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Registered Taxpayer | DCST.THONG_TIN_DK_THUE | ID |  |
| 9 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã NNT | DCST.THONG_TIN_DK_THUE | ID |  |
| 10 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.THONG_TIN_DK_THUE' | Mã nguồn dữ liệu. | DCST.THONG_TIN_DK_THUE |  |  |
| 11 | Identification Type Code | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — quyết định thành lập. | DCST.THONG_TIN_DK_THUE |  |  |
| 12 | Identification Number | identn_nbr | STRING | X |  |  |  | Số quyết định thành lập | DCST.THONG_TIN_DK_THUE | SO_QUYET_DINH |  |
| 13 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày ban hành quyết định | DCST.THONG_TIN_DK_THUE | NGAY_BAN_HANH |  |
| 14 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Cơ quan ban hành quyết định thành lập | DCST.THONG_TIN_DK_THUE | CO_QUAN_BAN_HANH |  |


#### 2.{IDX}.7.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Registered Taxpayer | Registered Taxpayer Id | rgst_taxpayer_id |




### 2.{IDX}.8 Bảng Involved Party Electronic Address — DCST.TTKDT_NGUOI_DAI_DIEN

- **Mô tả:** Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn.
- **Tên vật lý:** ip_elc_adr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Taxpayer Representative | DCST.TTKDT_NGUOI_DAI_DIEN | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người đại diện | DCST.TTKDT_NGUOI_DAI_DIEN | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.TTKDT_NGUOI_DAI_DIEN' | Mã nguồn dữ liệu. | DCST.TTKDT_NGUOI_DAI_DIEN |  |  |
| 4 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email. | DCST.TTKDT_NGUOI_DAI_DIEN |  |  |
| 5 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Email | DCST.TTKDT_NGUOI_DAI_DIEN | EMAIL |  |
| 6 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Taxpayer Representative | DCST.TTKDT_NGUOI_DAI_DIEN | ID |  |
| 7 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người đại diện | DCST.TTKDT_NGUOI_DAI_DIEN | ID |  |
| 8 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.TTKDT_NGUOI_DAI_DIEN' | Mã nguồn dữ liệu. | DCST.TTKDT_NGUOI_DAI_DIEN |  |  |
| 9 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — fax. | DCST.TTKDT_NGUOI_DAI_DIEN |  |  |
| 10 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Fax | DCST.TTKDT_NGUOI_DAI_DIEN | FAX |  |
| 11 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Taxpayer Representative | DCST.TTKDT_NGUOI_DAI_DIEN | ID |  |
| 12 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người đại diện | DCST.TTKDT_NGUOI_DAI_DIEN | ID |  |
| 13 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.TTKDT_NGUOI_DAI_DIEN' | Mã nguồn dữ liệu. | DCST.TTKDT_NGUOI_DAI_DIEN |  |  |
| 14 | Electronic Address Type Code | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại. | DCST.TTKDT_NGUOI_DAI_DIEN |  |  |
| 15 | Electronic Address Value | elc_adr_val | STRING | X |  |  |  | Số điện thoại | DCST.TTKDT_NGUOI_DAI_DIEN | DIEN_THOAI |  |


#### 2.{IDX}.8.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Taxpayer Representative | Taxpayer Representative Id | taxpayer_representative_id |




### 2.{IDX}.9 Bảng Involved Party Alternative Identification — DCST.TTKDT_NGUOI_DAI_DIEN

- **Mô tả:** Lưu trữ các giấy tờ định danh thay thế của Involved Party (CMND/CCCD/Hộ chiếu/Giấy phép kinh doanh/Chứng chỉ hành nghề). Mỗi dòng = 1 loại giấy tờ từ 1 nguồn.
- **Tên vật lý:** ip_alt_identn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Taxpayer Representative | DCST.TTKDT_NGUOI_DAI_DIEN | ID |  |
| 2 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người đại diện | DCST.TTKDT_NGUOI_DAI_DIEN | ID |  |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.TTKDT_NGUOI_DAI_DIEN' | Mã nguồn dữ liệu. | DCST.TTKDT_NGUOI_DAI_DIEN |  |  |
| 4 | Identification Type Code | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — CCCD. | DCST.TTKDT_NGUOI_DAI_DIEN | LOAI_GIAY_TO | ETL map: 2080 → CITIZEN_ID. |
| 5 | Identification Number | identn_nbr | STRING | X |  |  |  | Số CCCD | DCST.TTKDT_NGUOI_DAI_DIEN | SO_GIAY_TO |  |
| 6 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp CCCD | DCST.TTKDT_NGUOI_DAI_DIEN | NGAY_CAP |  |
| 7 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp CCCD/Hộ chiếu. | DCST.TTKDT_NGUOI_DAI_DIEN |  |  |
| 8 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Taxpayer Representative | DCST.TTKDT_NGUOI_DAI_DIEN | ID |  |
| 9 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người đại diện | DCST.TTKDT_NGUOI_DAI_DIEN | ID |  |
| 10 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.TTKDT_NGUOI_DAI_DIEN' | Mã nguồn dữ liệu. | DCST.TTKDT_NGUOI_DAI_DIEN |  |  |
| 11 | Identification Type Code | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — CMND. | DCST.TTKDT_NGUOI_DAI_DIEN | LOAI_GIAY_TO | ETL map: 1010 → NATIONAL_ID. |
| 12 | Identification Number | identn_nbr | STRING | X |  |  |  | Số CMND | DCST.TTKDT_NGUOI_DAI_DIEN | SO_GIAY_TO |  |
| 13 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp CMND | DCST.TTKDT_NGUOI_DAI_DIEN | NGAY_CAP |  |
| 14 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Nơi cấp CMND/CCCD. | DCST.TTKDT_NGUOI_DAI_DIEN |  |  |
| 15 | Involved Party Id | ip_id | BIGINT |  |  | F |  | FK đến Taxpayer Representative | DCST.TTKDT_NGUOI_DAI_DIEN | ID |  |
| 16 | Involved Party Code | ip_code | STRING |  |  |  |  | Mã người đại diện | DCST.TTKDT_NGUOI_DAI_DIEN | ID |  |
| 17 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.TTKDT_NGUOI_DAI_DIEN' | Mã nguồn dữ liệu. | DCST.TTKDT_NGUOI_DAI_DIEN |  |  |
| 18 | Identification Type Code | identn_tp_code | STRING |  |  |  |  | Loại giấy tờ — hộ chiếu. | DCST.TTKDT_NGUOI_DAI_DIEN | LOAI_GIAY_TO | ETL map: 1020 → PASSPORT. |
| 19 | Identification Number | identn_nbr | STRING | X |  |  |  | Số hộ chiếu | DCST.TTKDT_NGUOI_DAI_DIEN | SO_GIAY_TO |  |
| 20 | Issue Date | issu_dt | DATE | X |  |  |  | Ngày cấp hộ chiếu | DCST.TTKDT_NGUOI_DAI_DIEN | NGAY_CAP |  |


#### 2.{IDX}.9.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Involved Party Id | ip_id | Taxpayer Representative | Taxpayer Representative Id | taxpayer_representative_id |




### 2.{IDX}.10 Bảng Tax Financial Statement

- **Mô tả:** Tờ khai tài chính điện tử nộp lên cơ quan thuế. Ghi nhận kỳ kê khai và thông tin kiểm toán.
- **Tên vật lý:** tax_fnc_stmt
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Tax Financial Statement Id | tax_fnc_stmt_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | DCST.TCT_BAO_CAO |  | PK surrogate. BCV: "Financial Statement" (Documentation) — entity-level concept. |
| 2 | Tax Financial Statement Code | tax_fnc_stmt_code | STRING |  |  |  |  | Mã định danh bản ghi trong DCST. BK | DCST.TCT_BAO_CAO | ID | BK chính. PK nguồn map vào Code — không đưa vào technical field. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.TCT_BAO_CAO' | Mã nguồn dữ liệu. Giá trị: DCST.TCT_BAO_CAO | DCST.TCT_BAO_CAO |  | Scheme: SOURCE_SYSTEM. Hardcode. |
| 4 | Registered Taxpayer Id | rgst_taxpayer_id | BIGINT | X |  | F |  | Mã số thuế. FK đến Registered Taxpayer | DCST.TCT_BAO_CAO | MST |  |
| 5 | Registered Taxpayer Code | rgst_taxpayer_code | STRING | X |  |  |  | Mã số thuế | DCST.TCT_BAO_CAO | MST |  |
| 6 | Taxpayer Name | taxpayer_nm | STRING | X |  |  |  | Tên người nộp thuế | DCST.TCT_BAO_CAO | TEN_NNT |  |
| 7 | Taxpayer Address | taxpayer_adr | STRING | X |  |  |  | Địa chỉ người nộp thuế | DCST.TCT_BAO_CAO | DIA_CHI_NNT |  |
| 8 | Taxpayer Ward | taxpayer_ward | STRING | X |  |  |  | Phường xã | DCST.TCT_BAO_CAO | PHUONG_XA |  |
| 9 | Taxpayer District Code | taxpayer_dstc_code | STRING | X |  |  |  | Mã huyện người nộp thuế | DCST.TCT_BAO_CAO | MA_HUYEN_NNT |  |
| 10 | Taxpayer District Name | taxpayer_dstc_nm | STRING | X |  |  |  | Tên huyện người nộp thuế | DCST.TCT_BAO_CAO | TEN_HUYEN_NNT |  |
| 11 | Taxpayer Province Code | taxpayer_prov_code | STRING | X |  |  |  | Mã tỉnh người nộp thuế | DCST.TCT_BAO_CAO | MA_TINH_NNT |  |
| 12 | Taxpayer Province Name | taxpayer_prov_nm | STRING | X |  |  |  | Tên tỉnh người nộp thuế | DCST.TCT_BAO_CAO | TEN_TINH_NNT |  |
| 13 | Taxpayer Phone Number | taxpayer_ph_nbr | STRING | X |  |  |  | Điện thoại người nộp thuế | DCST.TCT_BAO_CAO | DIEN_THOAI_NNT |  |
| 14 | Taxpayer Fax Number | taxpayer_fax_nbr | STRING | X |  |  |  | Fax người nộp thuế | DCST.TCT_BAO_CAO | FAX_NNT |  |
| 15 | Taxpayer Email | taxpayer_email | STRING | X |  |  |  | Email người nộp thuế | DCST.TCT_BAO_CAO | EMAIL_NNT |  |
| 16 | Business Industry | bsn_idy | STRING | X |  |  |  | Ngày nghề kinh doanh | DCST.TCT_BAO_CAO | NGANH_NGHE_KD |  |
| 17 | Service Code | svc_code | STRING | X |  |  |  | Mã dịch vụ | DCST.TCT_BAO_CAO | MA_DVU |  |
| 18 | Service Name | svc_nm | STRING | X |  |  |  | Tên dịch vụ | DCST.TCT_BAO_CAO | TEN_DVU |  |
| 19 | Service Version | svc_vrsn | STRING | X |  |  |  | Phiên bản dịch vụ | DCST.TCT_BAO_CAO | PHIEN_BAN_DVU |  |
| 20 | Service Provider Information | svc_pvdr_inf | STRING | X |  |  |  | Thông tin nhà cung cấp dịch vụ | DCST.TCT_BAO_CAO | TT_NHACC_DVU |  |
| 21 | Tax Return Code | tax_ret_code | STRING | X |  |  |  | Mã tờ khai | DCST.TCT_BAO_CAO | MA_TKHAI |  |
| 22 | Tax Return Name | tax_ret_nm | STRING | X |  |  |  | Tên tờ khai | DCST.TCT_BAO_CAO | TEN_TKHAI |  |
| 23 | Tax Return Form Description | tax_ret_form_dsc | STRING | X |  |  |  | Mô tả biểu mẫu | DCST.TCT_BAO_CAO | MO_TA_BMAU |  |
| 24 | Tax Return XML Version | tax_ret_xml_vrsn | STRING | X |  |  |  | Phiên bản tờ khai XML | DCST.TCT_BAO_CAO | PBAN_TKHAI_XML |  |
| 25 | Tax Return Type Code | tax_ret_tp_code | STRING | X |  |  |  | Loại tờ khai | DCST.TCT_BAO_CAO | LOAI_TKHAI | Scheme: TAX_RETURN_TYPE. BCV: gần nhất "Document Type" (Documentation). Giá trị mới — xem append ref_shared_entity_classifications. |
| 26 | Amendment Count | amdt_cnt | INT | X |  |  |  | Số lần | DCST.TCT_BAO_CAO | SO_LAN |  |
| 27 | Reporting Period Type Code | rpt_prd_tp_code | STRING | X |  |  |  | Kiểu kỳ | DCST.TCT_BAO_CAO | KIEU_KY | Scheme: REPORTING_PERIOD_TYPE. BCV: không có term riêng cho kiểu kỳ báo cáo thuế. Giá trị mới — xem append. |
| 28 | Reporting Period | rpt_prd | STRING | X |  |  |  | Kỳ kê khai | DCST.TCT_BAO_CAO | KY_KKHAI |  |
| 29 | Reporting Period Start Date | rpt_prd_strt_dt | STRING | X |  |  |  | Kỳ kê khai từ ngày | DCST.TCT_BAO_CAO | KY_KKHAI_TU_NGAY |  |
| 30 | Reporting Period End Date | rpt_prd_end_dt | STRING | X |  |  |  | Kỳ kê khai đến ngày | DCST.TCT_BAO_CAO | KY_KKHAI_DEN_NGAY |  |
| 31 | Reporting Period Start Month | rpt_prd_strt_mo | STRING | X |  |  |  | Kỳ kê khai từ tháng | DCST.TCT_BAO_CAO | KY_KKHAI_TU_THANG |  |
| 32 | Reporting Period End Month | rpt_prd_end_mo | STRING | X |  |  |  | Kỳ kê khai đến tháng | DCST.TCT_BAO_CAO | KY_KKHAI_DEN_THANG |  |
| 33 | Tax Authority Code | tax_ahr_code | STRING | X |  |  |  | Mã cơ quan thuế nơi nộp | DCST.TCT_BAO_CAO | MA_CQTHUE_NOI_NOP |  |
| 34 | Tax Authority Name | tax_ahr_nm | STRING | X |  |  |  | Tên cơ quan thuế nơi nộp | DCST.TCT_BAO_CAO | TEN_CQTHUE_NOI_NOP |  |
| 35 | Filing Date | filg_dt | STRING | X |  |  |  | Ngày lập tờ khai | DCST.TCT_BAO_CAO | NGAY_LAP_TKHAI |  |
| 36 | Extension Reason Code | exn_rsn_code | STRING | X |  |  |  | Mã lý do gia hạn | DCST.TCT_BAO_CAO | MA_LY_DO_GIA_HAN |  |
| 37 | Extension Reason | exn_rsn | STRING | X |  |  |  | Lý do gia hạn | DCST.TCT_BAO_CAO | LY_DO_GIA_HAN |  |
| 38 | Signatory Name | signatory_nm | STRING | X |  | F |  | Người ký | DCST.TCT_BAO_CAO | NGUOI_KY |  |
| 39 | Signing Date | signing_dt | DATE | X |  |  |  | Ngày ký | DCST.TCT_BAO_CAO | NGAY_KY |  |
| 40 | Audit Status Code | audt_st_code | STRING | X |  |  |  | Trạng thái kiểm toán | DCST.TCT_BAO_CAO | TRANG_THAI_KT | Scheme: AUDIT_STATUS. BCV: không có term riêng cho trạng thái kiểm toán BCTC. Giá trị mới — xem append. |
| 41 | Audit Firm Tax Identification Number | audt_firm_tax_identn_nbr | STRING | X |  | F |  | Mã số thuế tổ chức kiểm toán | DCST.TCT_BAO_CAO | MST_TC_KTOAN |  |
| 42 | Audit Firm Name | audt_firm_nm | STRING | X |  |  |  | Tổ chức kiểm toán | DCST.TCT_BAO_CAO | TC_KIEM_TOAN |  |
| 43 | Auditor Code | auditor_code | STRING | X |  |  |  | Mã kiểm toán viên | DCST.TCT_BAO_CAO | MA_KIEM_TOAN_VIEN |  |
| 44 | Auditor Name | auditor_nm | STRING | X |  |  |  | Kiểm toán vien | DCST.TCT_BAO_CAO | KIEM_TOAN_VIEN |  |
| 45 | Audited Financial Statement Indicator | audited_fnc_stmt_ind | STRING | X |  |  |  | Báo cáo tài chính đã kiểm toán | DCST.TCT_BAO_CAO | BCTC_DA_KIEM_TOAN |  |
| 46 | Audit Opinion Code | audt_opinion_code | STRING | X |  |  |  | Mã ý kiến kiểm toán | DCST.TCT_BAO_CAO | MA_YKKT |  |
| 47 | Audit Opinion | audt_opinion | STRING | X |  |  |  | Ý kiến kiểm toán | DCST.TCT_BAO_CAO | YKKT |  |
| 48 | Audit Date | audt_dt | DATE | X |  |  |  | Ngày kiểm toán | DCST.TCT_BAO_CAO | NGAY_KIEM_TOAN |  |
| 49 | Created Date | crt_dt | STRING | X |  |  |  | Ngày tạo | DCST.TCT_BAO_CAO | NGAY_TAO |  |
| 50 | Submission Date | submission_dt | DATE | X |  |  |  | Ngày nộp tờ khai | DCST.TCT_BAO_CAO | ADD_INFO_NGAY_NOP_TK |  |
| 51 | Receipt Date | recpt_dt | DATE | X |  |  |  | Ngày tiếp nhận | DCST.TCT_BAO_CAO | ADD_INFO_NGAY_TIEP_NHAN |  |
| 52 | Report Set Period | rpt_set_prd | STRING | X |  |  |  | Kỳ lập bộ báo cáo | DCST.TCT_BAO_CAO | ADD_INFO_KY_LAP_BO |  |
| 53 | Filing Origin | filg_orig | STRING | X |  |  |  | Nguồn gốc tờ khai | DCST.TCT_BAO_CAO | ADD_INFO_NGUON_GOC_TK |  |
| 54 | Filing Entry Person | filg_entr_psn | STRING | X |  |  |  | Người nhập tờ khại | DCST.TCT_BAO_CAO | ADD_INFO_NGUOI_NHAP_TK |  |
| 55 | Filing Acknowledged Date | filg_ack_dt | DATE | X |  |  |  | Ngày nhận tờ khai | DCST.TCT_BAO_CAO | ADD_INFO_NGAY_NHAN_TK |  |
| 56 | Filing Reference Id | filg_refr_id | STRING | X |  |  |  | ID tờ khai | DCST.TCT_BAO_CAO | ADD_INFO_ID_TK |  |
| 57 | Sending Location | sending_lo | STRING | X |  |  |  | Nơi gửi | DCST.TCT_BAO_CAO | ADD_INFO_NOI_GUI |  |
| 58 | Receiving Location | receiving_lo | STRING | X |  |  |  | Nơi nhận | DCST.TCT_BAO_CAO | ADD_INFO_NOI_NHAN |  |


#### 2.{IDX}.10.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Tax Financial Statement Id | tax_fnc_stmt_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Registered Taxpayer Id | rgst_taxpayer_id | Registered Taxpayer | Registered Taxpayer Id | rgst_taxpayer_id |




### 2.{IDX}.11 Bảng Tax Financial Statement Item

- **Mô tả:** Chỉ tiêu chi tiết trong tờ khai tài chính. Ghi nhận giá trị số liệu theo từng ô chỉ tiêu trong biểu mẫu.
- **Tên vật lý:** tax_fnc_stmt_itm
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Tax Financial Statement Item Id | tax_fnc_stmt_itm_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | DCST.TCT_BAO_CAO_CHI_TIET |  | PK surrogate. BCV: "Reported Information" (Documentation) — entity-level concept. |
| 2 | Tax Financial Statement Item Code | tax_fnc_stmt_itm_code | STRING |  |  |  |  | Mã định danh bản ghi trong DCST. BK | DCST.TCT_BAO_CAO_CHI_TIET | ID | BK chính. PK nguồn map vào Code. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.TCT_BAO_CAO_CHI_TIET' | Mã nguồn dữ liệu. Giá trị: DCST.TCT_BAO_CAO_CHI_TIET | DCST.TCT_BAO_CAO_CHI_TIET |  | Scheme: SOURCE_SYSTEM. Hardcode. |
| 4 | Tax Financial Statement Id | tax_fnc_stmt_id | BIGINT |  |  | F |  | ID bảng TCT_BAO_CAO. FK đến Tax Financial Statement | DCST.TCT_BAO_CAO_CHI_TIET | TCT_BAO_CAO_ID |  |
| 5 | Tax Financial Statement Code | tax_fnc_stmt_code | STRING |  |  |  |  | ID bảng TCT_BAO_CAO | DCST.TCT_BAO_CAO_CHI_TIET | TCT_BAO_CAO_ID |  |
| 6 | Line Item Code | line_itm_code | STRING | X |  |  |  | Mã chỉ tiêu | DCST.TCT_BAO_CAO_CHI_TIET | MA_CHI_TIEU |  |
| 7 | Line Item Name | line_itm_nm | STRING | X |  |  |  | Tên chỉ tiêu | DCST.TCT_BAO_CAO_CHI_TIET | TEN_CHI_TIEU |  |
| 8 | Line Item Note | line_itm_note | STRING | X |  |  |  | Thuyết minh | DCST.TCT_BAO_CAO_CHI_TIET | THUYET_MINH |  |
| 9 | Sheet Name | shet_nm | STRING | X |  |  |  | Tên sheet | DCST.TCT_BAO_CAO_CHI_TIET | TEN_SHEET |  |
| 10 | Year End Amount | yr_end_amt | STRING | X |  |  |  | Số cuối năm | DCST.TCT_BAO_CAO_CHI_TIET | SO_CUOI_NAM |  |
| 11 | Year Start Amount | yr_strt_amt | STRING | X |  |  |  | Số đầu năm | DCST.TCT_BAO_CAO_CHI_TIET | SO_DAU_NAM |  |
| 12 | Current Year Amount | crn_yr_amt | STRING | X |  |  |  | Năm nay | DCST.TCT_BAO_CAO_CHI_TIET | NAM_NAY |  |
| 13 | Prior Year Amount | prev_yr_amt | STRING | X |  |  |  | Năm trước | DCST.TCT_BAO_CAO_CHI_TIET | NAM_TRUOC |  |
| 14 | Prior Year Increase Amount | prev_yr_incr_amt | STRING | X |  |  |  | Số tăng năm nay | DCST.TCT_BAO_CAO_CHI_TIET | SO_TANG_NAM_TRUOC |  |
| 15 | Current Year Net Amount | crn_yr_net_amt | STRING | X |  |  |  | Số năm nay | DCST.TCT_BAO_CAO_CHI_TIET | SO_NAM_NAY |  |
| 16 | Prior Year Net Amount | prev_yr_net_amt | STRING | X |  |  |  | Số năm ngoái | DCST.TCT_BAO_CAO_CHI_TIET | SO_NAM_NGOAI |  |
| 17 | Current Year Opening Balance | crn_yr_opn_bal | STRING | X |  |  |  | Số dư đầu năm nay | DCST.TCT_BAO_CAO_CHI_TIET | SO_DU_DAU_NAM_NAY |  |
| 18 | Current Year Closing Balance | crn_yr_cls_bal | STRING | X |  |  |  | Số dư cuối năm nay | DCST.TCT_BAO_CAO_CHI_TIET | SO_DU_CUOI_NAM_NAY |  |
| 19 | Prior Year Opening Balance | prev_yr_opn_bal | STRING | X |  |  |  | Số dư đầu năm trước | DCST.TCT_BAO_CAO_CHI_TIET | SO_DU_DAU_NAM_TRUOC |  |
| 20 | Prior Year Closing Balance | prev_yr_cls_bal | STRING | X |  |  |  | Số dư cuối năm trước | DCST.TCT_BAO_CAO_CHI_TIET | SO_DU_CUOI_NAM_TRUOC |  |
| 21 | Current Year Increase Amount | crn_yr_incr_amt | STRING | X |  |  |  | Số tăng năm nay | DCST.TCT_BAO_CAO_CHI_TIET | SO_TANG_NAM_NAY |  |
| 22 | Current Year Decrease Amount | crn_yr_dec_amt | STRING | X |  |  |  | Số giảm năm nay | DCST.TCT_BAO_CAO_CHI_TIET | SO_GIAM_NAM_NAY |  |
| 23 | Prior Year Decrease Amount | prev_yr_dec_amt | STRING | X |  |  |  | Số giảm năm trước | DCST.TCT_BAO_CAO_CHI_TIET | SO_GIAM_NAM_TRUOC |  |
| 24 | Preparer Name | preparer_nm | STRING | X |  |  |  | Người lập biểu | DCST.TCT_BAO_CAO_CHI_TIET | NGUOILAPBIEU |  |
| 25 | Chief Accountant Name | chief_accountant_nm | STRING | X |  |  |  | Kế toán trưởng | DCST.TCT_BAO_CAO_CHI_TIET | KETOANTRUONG |  |
| 26 | Report Preparation Date | rpt_prep_dt | STRING | X |  |  |  | Ngày lập | DCST.TCT_BAO_CAO_CHI_TIET | NGAYLAP |  |
| 27 | Director Name | director_nm | STRING | X |  |  |  | Giám đốc | DCST.TCT_BAO_CAO_CHI_TIET | GIAMDOC |  |
| 28 | Auditor License Number | auditor_license_nbr | STRING | X |  |  |  | Số chứng chỉ hành nghề | DCST.TCT_BAO_CAO_CHI_TIET | SOCHUNGCHIHANHNGHE |  |
| 29 | Audit Firm Name | audt_firm_nm | STRING | X |  |  |  | Đơn vị cung cấp dịch vụ kiểm toán | DCST.TCT_BAO_CAO_CHI_TIET | DONVICCAPDVUKTOAN |  |
| 30 | Going Concern Indicator | going_concern_ind | STRING | X |  |  |  | Hoạt động liên tục | DCST.TCT_BAO_CAO_CHI_TIET | HOATDONGLIENTUC |  |
| 31 | Non Going Concern Indicator | non_going_concern_ind | STRING | X |  |  |  | Hoạt động không liên tục | DCST.TCT_BAO_CAO_CHI_TIET | HOATDONGKHONGLIENTUC |  |


#### 2.{IDX}.11.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Tax Financial Statement Item Id | tax_fnc_stmt_itm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Tax Financial Statement Id | tax_fnc_stmt_id | Tax Financial Statement | Tax Financial Statement Id | tax_fnc_stmt_id |




### 2.{IDX}.12 Bảng Tax Debt Enforcement Order

- **Mô tả:** Quyết định cưỡng chế nợ thuế. Ghi nhận hình thức cưỡng chế và thông tin tài sản/tài khoản liên quan.
- **Tên vật lý:** tax_dbt_enforcement_ordr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Tax Debt Enforcement Order Id | tax_dbt_enforcement_ordr_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | DCST.TCT_TT_CUONG_CHE_NO |  | PK surrogate. BCV: "Regulatory Report" (Documentation) — entity-level concept. |
| 2 | Tax Debt Enforcement Order Code | tax_dbt_enforcement_ordr_code | STRING |  |  |  |  | Mã định danh bản ghi trong DCST. BK | DCST.TCT_TT_CUONG_CHE_NO | ID | BK chính. PK nguồn map vào Code. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.TCT_TT_CUONG_CHE_NO' | Mã nguồn dữ liệu. Giá trị: DCST.TCT_TT_CUONG_CHE_NO | DCST.TCT_TT_CUONG_CHE_NO |  | Scheme: SOURCE_SYSTEM. Hardcode. |
| 4 | Registered Taxpayer Id | rgst_taxpayer_id | BIGINT | X |  | F |  | Mã người nhận. FK đến Registered Taxpayer | DCST.TCT_TT_CUONG_CHE_NO | MA_NNHAN |  |
| 5 | Registered Taxpayer Code | rgst_taxpayer_code | STRING | X |  |  |  | Mã người nhận | DCST.TCT_TT_CUONG_CHE_NO | MA_NNHAN |  |
| 6 | Taxpayer Name | taxpayer_nm | STRING | X |  |  |  | Tên người nhận | DCST.TCT_TT_CUONG_CHE_NO | TEN_NNHAN |  |
| 7 | Taxpayer Business Industry | taxpayer_bsn_idy | STRING | X |  |  |  | Ngành kinh doanh đối tượng bị cưỡng chế | DCST.TCT_TT_CUONG_CHE_NO | NGANH_KD_DTBCC |  |
| 8 | Tax Authority Code | tax_ahr_code | STRING | X |  |  |  | Mã cơ quan thuế | DCST.TCT_TT_CUONG_CHE_NO | MA_CQT |  |
| 9 | Tax Authority Name | tax_ahr_nm | STRING | X |  |  |  | Tên cơ quan thuế | DCST.TCT_TT_CUONG_CHE_NO | TEN_CQT |  |
| 10 | Supervisory Tax Authority Code | spvsr_tax_ahr_code | STRING | X |  |  |  | Mã cơ quan thuế quản lý | DCST.TCT_TT_CUONG_CHE_NO | MA_CQT_QL |  |
| 11 | Supervisory Tax Authority Name | spvsr_tax_ahr_nm | STRING | X |  |  |  | Tên cơ quan thuế quản lý | DCST.TCT_TT_CUONG_CHE_NO | TEN_CQT_QL |  |
| 12 | Enforcement Type Code | enforcement_tp_code | STRING | X |  |  |  | Mã hình thức cưỡng chế | DCST.TCT_TT_CUONG_CHE_NO | MA_HTCC | Scheme: TAX_ENFORCEMENT_TYPE. BCV: không có term riêng. Dùng chung với TCT_TTCCN_HOA_DON. |
| 13 | Enforcement Type Name | enforcement_tp_nm | STRING | X |  |  |  | Tên hình thức cưỡng chế | DCST.TCT_TT_CUONG_CHE_NO | TEN_HTCC |  |
| 14 | Electronic Transaction Code | elc_txn_code | STRING | X |  |  |  | Mã giao dịch điện tử | DCST.TCT_TT_CUONG_CHE_NO | MA_GDDT |  |
| 15 | Enforcement Order Number | enforcement_ordr_nbr | STRING | X |  | F |  | Số quyết định | DCST.TCT_TT_CUONG_CHE_NO | SO_QD |  |
| 16 | Enforcement Order Date | enforcement_ordr_dt | DATE | X |  |  |  | Ngày quyết định | DCST.TCT_TT_CUONG_CHE_NO | NGAY_QD |  |
| 17 | Enforced Amount | enforced_amt | STRING | X |  |  |  | Số tiền bị cưỡng chế | DCST.TCT_TT_CUONG_CHE_NO | SO_TIEN_BI_CC |  |
| 18 | Enforcement Effective Start Date | enforcement_eff_strt_dt | DATE | X |  |  |  | Ngày hiệu lực từ quyết định từ | DCST.TCT_TT_CUONG_CHE_NO | NGAY_HIEU_LUC_QD_TU |  |
| 19 | Enforcement Effective End Date | enforcement_eff_end_dt | DATE | X |  |  |  | Ngày hiệu lực quyết định đến | DCST.TCT_TT_CUONG_CHE_NO | NGAY_HIEU_LUC_QD_DEN |  |
| 20 | Enforcement Time | enforcement_tm | DATE | X |  |  |  | Thời gian cưỡng chế | DCST.TCT_TT_CUONG_CHE_NO | THOI_GIAN_CC |  |
| 21 | Enforcement Location | enforcement_lo | STRING | X |  |  |  | Địa điểm cưỡng chế | DCST.TCT_TT_CUONG_CHE_NO | DIA_DIEM_CC |  |
| 22 | Taxpayer Account Number | taxpayer_ac_nbr | STRING | X |  |  |  | Số tài khoản đối tượng bị cưỡng chế | DCST.TCT_TT_CUONG_CHE_NO | STK_DT_BCC |  |
| 23 | Taxpayer Account Bank | taxpayer_ac_bnk | STRING | X |  |  |  | Nơi mở tài khoản bị cưỡng chế | DCST.TCT_TT_CUONG_CHE_NO | NO_MO_TK_BCC |  |
| 24 | Income Manager Name | incm_mgr_nm | STRING | X |  |  |  | Tên đối tượng quản lý thu nhập | DCST.TCT_TT_CUONG_CHE_NO | TEN_DTQLTN |  |
| 25 | Income Manager Address | incm_mgr_adr | STRING | X |  |  |  | Địa chỉ đối tượng quản lý thu nhập | DCST.TCT_TT_CUONG_CHE_NO | DI_CHI_DTQLTN |  |
| 26 | Seized Asset Description | seized_ast_dsc | STRING | X |  |  |  | Tài sản kê biên | DCST.TCT_TT_CUONG_CHE_NO | TS_KE_BIEN |  |
| 27 | Seized Asset Value | seized_ast_val | STRING | X |  |  |  | Giá trị tài sản | DCST.TCT_TT_CUONG_CHE_NO | GIA_TRI_TS |  |
| 28 | Asset Custodian Code | ast_cstd_code | STRING | X |  | F |  | Mã đối tượng giữ tài sản cưỡng chế | DCST.TCT_TT_CUONG_CHE_NO | MA_DTGTSCC |  |
| 29 | Asset Custodian Name | ast_cstd_nm | STRING | X |  |  |  | Tên đối tượng giữ tài sản cưỡng chế | DCST.TCT_TT_CUONG_CHE_NO | TEN_DTGTSCC |  |
| 30 | Asset Custodian Address | ast_cstd_adr | STRING | X |  |  |  | Địa chỉ đối tượng giữ tài sản cưỡng chế | DCST.TCT_TT_CUONG_CHE_NO | DIA_CHI_DTGTSCC |  |


#### 2.{IDX}.12.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Tax Debt Enforcement Order Id | tax_dbt_enforcement_ordr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Registered Taxpayer Id | rgst_taxpayer_id | Registered Taxpayer | Registered Taxpayer Id | rgst_taxpayer_id |




### 2.{IDX}.13 Bảng Tax Violation Penalty Decision

- **Mô tả:** Quyết định xử lý vi phạm hành chính về thuế. Ghi nhận hành vi vi phạm và mức phạt/truy thu.
- **Tên vật lý:** tax_vln_pny_dcsn
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Tax Violation Penalty Decision Id | tax_vln_pny_dcsn_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | DCST.TT_XLY_VI_PHAM |  | PK surrogate. BCV: "Conduct Violation" (Business Activity) — Activity Fact Append. |
| 2 | Tax Violation Penalty Decision Code | tax_vln_pny_dcsn_code | STRING |  |  |  |  | Mã định danh bản ghi trong DCST. BK | DCST.TT_XLY_VI_PHAM | ID | BK chính. PK nguồn map vào Code. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.TT_XLY_VI_PHAM' | Mã nguồn dữ liệu. Giá trị: DCST.TT_XLY_VI_PHAM | DCST.TT_XLY_VI_PHAM |  | Scheme: SOURCE_SYSTEM. Hardcode. |
| 4 | Registered Taxpayer Id | rgst_taxpayer_id | BIGINT | X |  | F |  | Mã số thuế. FK đến Registered Taxpayer | DCST.TT_XLY_VI_PHAM | MST |  |
| 5 | Registered Taxpayer Code | rgst_taxpayer_code | STRING | X |  |  |  | Mã số thuế | DCST.TT_XLY_VI_PHAM | MST |  |
| 6 | Taxpayer Name | taxpayer_nm | STRING | X |  |  |  | Tên đối tượng | DCST.TT_XLY_VI_PHAM | TEN_DOI_TUONG |  |
| 7 | Order Number | ordr_nbr | STRING | X |  |  |  | Số quyết định xử lý | DCST.TT_XLY_VI_PHAM | SO_QDXL |  |
| 8 | Issuing Authority Name | issuing_ahr_nm | STRING | X |  |  |  | Cơ quan ban hành | DCST.TT_XLY_VI_PHAM | CO_QUAN_BAN_HANH |  |
| 9 | Inspection Period | inspection_prd | STRING | X |  |  |  | Kỳ thanh tra kiểm tra | DCST.TT_XLY_VI_PHAM | KY_TTKT |  |
| 10 | Violation Penalty Description | vln_pny_dsc | STRING | X |  |  |  | Phạt hành vi vi phạm | DCST.TT_XLY_VI_PHAM | PHAT_HANH_VI_VP |  |
| 11 | Administrative Violation Penalty Description | admn_vln_pny_dsc | STRING | X |  |  |  | Phạt hành vi vi phạm hành chính | DCST.TT_XLY_VI_PHAM | PHAT_HANH_VI_VPHC |  |
| 12 | Tax Arrears Recovery Amount | tax_ars_rec_amt | STRING | X |  |  |  | Truy thu tiền thuế, tiền nộp chậm | DCST.TT_XLY_VI_PHAM | TRUY_THU_TIEN_THUE |  |


#### 2.{IDX}.13.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Tax Violation Penalty Decision Id | tax_vln_pny_dcsn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Registered Taxpayer Id | rgst_taxpayer_id | Registered Taxpayer | Registered Taxpayer Id | rgst_taxpayer_id |




### 2.{IDX}.14 Bảng Tax Invoice Enforcement Order

- **Mô tả:** Quyết định cưỡng chế nợ thuế theo hình thức ngừng sử dụng hóa đơn. Ghi nhận thông tin quyết định và thông báo.
- **Tên vật lý:** tax_inv_enforcement_ordr
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Tax Invoice Enforcement Order Id | tax_inv_enforcement_ordr_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | DCST.TCT_TTCCN_HOA_DON |  | PK surrogate. BCV: "Invoice" (Documentation) — entity-level concept. |
| 2 | Tax Invoice Enforcement Order Code | tax_inv_enforcement_ordr_code | STRING |  |  |  |  | Mã định danh bản ghi trong DCST. BK | DCST.TCT_TTCCN_HOA_DON | ID | BK chính. PK nguồn map vào Code. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.TCT_TTCCN_HOA_DON' | Mã nguồn dữ liệu. Giá trị: DCST.TCT_TTCCN_HOA_DON | DCST.TCT_TTCCN_HOA_DON |  | Scheme: SOURCE_SYSTEM. Hardcode. |
| 4 | Registered Taxpayer Id | rgst_taxpayer_id | BIGINT | X |  | F |  | Mã số thuế của người nộp thuế. FK đến Registered Taxpayer | DCST.TCT_TTCCN_HOA_DON | MA_NNHAN |  |
| 5 | Registered Taxpayer Code | rgst_taxpayer_code | STRING | X |  |  |  | Mã số thuế của người nộp thuế | DCST.TCT_TTCCN_HOA_DON | MA_NNHAN |  |
| 6 | Taxpayer Name | taxpayer_nm | STRING | X |  |  |  | Tên người nộp thuế | DCST.TCT_TTCCN_HOA_DON | TEN_NNHAN |  |
| 7 | Supervisory Tax Authority Code | spvsr_tax_ahr_code | STRING | X |  |  |  | Mã cơ quan quản lý trực tiếp | DCST.TCT_TTCCN_HOA_DON | MA_CQT_QL |  |
| 8 | Supervisory Tax Authority Name | spvsr_tax_ahr_nm | STRING | X |  |  |  | Tên cơ quan quản lý trực tiếp | DCST.TCT_TTCCN_HOA_DON | TEN_CQT_QL |  |
| 9 | Taxpayer Business Industry | taxpayer_bsn_idy | STRING | X |  |  |  | Tên ngành kinh doanh của đối tượng bị cưỡng chế | DCST.TCT_TTCCN_HOA_DON | NGANH_KD_DTBCC |  |
| 10 | Enforcement Type Code | enforcement_tp_code | STRING | X |  |  |  | Mã hình thức cưỡng chế | DCST.TCT_TTCCN_HOA_DON | MA_HTCC | Scheme: TAX_ENFORCEMENT_TYPE. BCV: không có term riêng. Với bảng này luôn là hình thức ngừng sử dụng hóa đơn. Dùng chung với TCT_TT_CUONG_CHE_NO. |
| 11 | Enforcement Type Name | enforcement_tp_nm | STRING | X |  |  |  | Tên hình thức cưỡng chế | DCST.TCT_TTCCN_HOA_DON | TEN_HTCC |  |
| 12 | Electronic Transaction Code | elc_txn_code | STRING | X |  |  |  | Mã giao dịch điện tử | DCST.TCT_TTCCN_HOA_DON | MA_GDDT |  |
| 13 | Invoice Enforcement Order Number | inv_enforcement_ordr_nbr | STRING | X |  |  |  | Số quyết định | DCST.TCT_TTCCN_HOA_DON | SO_QD |  |
| 14 | Invoice Enforcement Order Date | inv_enforcement_ordr_dt | DATE | X |  |  |  | Ngày quyết định | DCST.TCT_TTCCN_HOA_DON | NGAY_QD |  |
| 15 | Enforcement Effective Start Date | enforcement_eff_strt_dt | DATE | X |  |  |  | Ngày hiệu lực từ | DCST.TCT_TTCCN_HOA_DON | NGAY_HIEU_LUC_QD_TU |  |
| 16 | Enforcement Effective End Date | enforcement_eff_end_dt | DATE | X |  |  |  | Ngày hiệu lực đến | DCST.TCT_TTCCN_HOA_DON | NGAY_HIEU_LUC_QD_DEN |  |
| 17 | Enforcement Status | enforcement_st | STRING | X |  |  |  | Hiệu lực | DCST.TCT_TTCCN_HOA_DON | HIEU_LUC |  |
| 18 | Prior Enforcement Order Number | prev_enforcement_ordr_nbr | STRING | X |  | F |  | Căn cứ số quyết định | DCST.TCT_TTCCN_HOA_DON | CAN_CU_QDSO |  |
| 19 | Prior Enforcement Order Date | prev_enforcement_ordr_dt | DATE | X |  |  |  | Căn cứ ngày quyết định | DCST.TCT_TTCCN_HOA_DON | CAN_CU_QDNGAY |  |
| 20 | Notice Taxpayer Code | ntc_taxpayer_code | STRING | X |  |  |  | Thông báo: Mã số thuế người nộp thuế | DCST.TCT_TTCCN_HOA_DON | TB_MA_NNHAN |  |
| 21 | Notice Taxpayer Name | ntc_taxpayer_nm | STRING | X |  |  |  | Thông báo: Tên người nộp thuế | DCST.TCT_TTCCN_HOA_DON | TB_TEN_NNHAN |  |
| 22 | Notice Code | ntc_code | STRING | X |  |  |  | Mã thông báo | DCST.TCT_TTCCN_HOA_DON | MA_THONG_BAO |  |
| 23 | Notice Name | ntc_nm | STRING | X |  |  |  | Tên thông báo | DCST.TCT_TTCCN_HOA_DON | TEN_THONG_BAO |  |
| 24 | Notified Tax Debt Amount | notified_tax_dbt_amt | STRING | X |  |  |  | Thông báo số tiền nợ và số tiền phạt nộp chậm | DCST.TCT_TTCCN_HOA_DON | TB_NO_SO |  |
| 25 | Debt Notice Date | dbt_ntc_dt | DATE | X |  |  |  | Thông báo tiền nợ và tiền phạt nộp chậm | DCST.TCT_TTCCN_HOA_DON | TB_NO_NGAY |  |


#### 2.{IDX}.14.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Tax Invoice Enforcement Order Id | tax_inv_enforcement_ordr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Registered Taxpayer Id | rgst_taxpayer_id | Registered Taxpayer | Registered Taxpayer Id | rgst_taxpayer_id |




### 2.{IDX}.15 Bảng Tax Invoice Enforcement Order Item

- **Mô tả:** Chi tiết hóa đơn thuộc quyết định cưỡng chế ngừng sử dụng hóa đơn. Ghi nhận số hiệu và loại hóa đơn.
- **Tên vật lý:** tax_inv_enforcement_ordr_itm
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Tax Invoice Enforcement Order Item Id | tax_inv_enforcement_ordr_itm_id | BIGINT |  | X | P |  | Id tự sinh (surrogate key) | DCST.HOA_DON_CHI_TIET |  | PK surrogate. BCV: "Invoice" (Documentation) — entity con của Tax Invoice Enforcement Order. |
| 2 | Tax Invoice Enforcement Order Item Code | tax_inv_enforcement_ordr_itm_code | STRING |  |  |  |  | Mã định danh bản ghi trong DCST. BK | DCST.HOA_DON_CHI_TIET | ID | BK chính. PK nguồn map vào Code. |
| 3 | Source System Code | src_stm_code | STRING |  |  |  | 'DCST.HOA_DON_CHI_TIET' | Mã nguồn dữ liệu. Giá trị: DCST.HOA_DON_CHI_TIET | DCST.HOA_DON_CHI_TIET |  | Scheme: SOURCE_SYSTEM. Hardcode. |
| 4 | Tax Invoice Enforcement Order Id | tax_inv_enforcement_ordr_id | BIGINT |  |  | F |  | ID Thông tin cưỡng chế nợ theo hóa đơn. FK đến Tax Invoice Enforcement Order | DCST.HOA_DON_CHI_TIET | TCT_TTCCN_HOA_DON_ID |  |
| 5 | Tax Invoice Enforcement Order Code | tax_inv_enforcement_ordr_code | STRING |  |  |  |  | ID Thông tin cưỡng chế nợ theo hóa đơn | DCST.HOA_DON_CHI_TIET | TCT_TTCCN_HOA_DON_ID |  |
| 6 | Invoice Template Symbol | inv_tpl_symb | STRING | X |  |  |  | Ký hiệu mẫu | DCST.HOA_DON_CHI_TIET | KH_MAU |  |
| 7 | Invoice Series Symbol | inv_series_symb | STRING | X |  |  |  | Ký hiệu hóa đơn | DCST.HOA_DON_CHI_TIET | KH_HOA_DON |  |
| 8 | Invoice Number | inv_nbr | STRING | X |  |  |  | Số hóa đơn | DCST.HOA_DON_CHI_TIET | SO_HOA_DON |  |
| 9 | Invoice Type Code | inv_tp_code | STRING | X |  |  |  | Loại hóa đơn | DCST.HOA_DON_CHI_TIET | LOAI_HOA_DON | Scheme: INVOICE_TYPE. BCV: gần nhất "Document Type" (Documentation). Giá trị mới — xem append ref_shared_entity_classifications. |


#### 2.{IDX}.15.1 Constraint

**Khóa chính (Primary Key):**

| Tên trường | Tên cột |
|---|---|
| Tax Invoice Enforcement Order Item Id | tax_inv_enforcement_ordr_itm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
| Tax Invoice Enforcement Order Id | tax_inv_enforcement_ordr_id | Tax Invoice Enforcement Order | Tax Invoice Enforcement Order Id | tax_inv_enforcement_ordr_id |




### 2.{IDX}.16 Bảng  — DCST.THONG_TIN_CONG_TY

- **Mô tả:** 
- **Tên vật lý:** 
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.16.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



### 2.{IDX}.17 Bảng  — DCST.NHOM_DANH_MUC

- **Mô tả:** 
- **Tên vật lý:** 
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|


#### 2.{IDX}.17.1 Constraint

**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*



