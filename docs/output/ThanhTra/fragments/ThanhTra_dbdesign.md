## ThanhTra — Phần hệ phục vụ công tác thanh tra chứng khoán

### Các mô hình quan hệ dữ liệu

![Mô hình quan hệ dữ liệu ThanhTra](ThanhTra/fragments/ThanhTra_diagram.png)

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
| 1 | aml_nfrc_case | Hồ sơ xử lý vi phạm phòng chống rửa tiền. Ghi nhận đối tượng vi phạm và trạng thái xử lý. |
| 2 | aml_nfrc_dcsn | Văn bản xử lý vi phạm rửa tiền. FK → AML Enforcement Case. |
| 3 | aml_prd_rpt | Báo cáo định kỳ về hoạt động phòng chống rửa tiền. Mỗi dòng = 1 lần lập báo cáo. |
| 4 | anti-corruption_rpt | Báo cáo tổng hợp định kỳ về hoạt động phòng chống tham nhũng. Mỗi dòng = 1 lần lập báo cáo. |
| 5 | cpln_nfrc_dcsn | Văn bản xử lý / quyết định xử phạt từ hồ sơ đơn thư. FK → Complaint Processing Case. |
| 6 | cpln_pny_ancm | Công bố quyết định xử phạt từ hồ sơ đơn thư. FK → Complaint Enforcement Decision. |
| 7 | cpln_petition | Đơn thư khiếu nại/tố cáo/phản ánh/kiến nghị nhận từ công dân hoặc tổ chức. Khởi đầu quy trình giải quyết đơn thư. |
| 8 | cpln_pcs_case | Hồ sơ giải quyết đơn thư khiếu nại/tố cáo. FK → Complaint Petition. |
| 9 | cpln_pcs_conclusion | Kết luận giải quyết đơn thư. FK → Complaint Processing Case. |
| 10 | insp_anul_pln | Kế hoạch thanh tra kiểm tra cấp năm được phê duyệt. Khởi đầu quy trình thanh tra trong năm. |
| 11 | insp_anul_pln_sbj | Đối tượng thanh tra được đưa vào kế hoạch năm. Grain: 1 đối tượng × 1 kế hoạch. |
| 12 | insp_case | Hồ sơ thanh tra cụ thể — tập hợp tài liệu và kết quả 1 cuộc thanh tra. FK → Inspection Decision. Thông tin đối tượng denormalized (snapshot tại thời điểm thanh tra). |
| 13 | insp_case_conclusion | Kết luận thanh tra kèm thông tin xử lý vi phạm. FK → Inspection Case. |
| 14 | insp_case_ofcr_asgnm | Phân công cán bộ phụ trách hồ sơ thanh tra. FK → Inspection Case + FK → Inspection Officer. |
| 15 | insp_dcsn | Quyết định thanh tra/kiểm tra cụ thể. FK → Inspection Annual Plan (nullable — thanh tra đột xuất không có kế hoạch). |
| 16 | insp_dcsn_sbj | Đối tượng cụ thể được thanh tra theo một quyết định. FK → Inspection Decision. |
| 17 | insp_dcsn_team_mbr | Thành viên đoàn thanh tra chỉ định theo quyết định. FK → Inspection Decision + FK → Inspection Officer. |
| 18 | insp_pny_ancm | Công bố quyết định xử phạt từ kết luận thanh tra. FK → Inspection Case Conclusion. |
| 19 | surveil_nfrc_case | Hồ sơ xử lý vi phạm từ kết quả giám sát thị trường. Ghi nhận đối tượng và trạng thái xử lý. |
| 20 | surveil_nfrc_dcsn | Văn bản xử lý vi phạm từ giám sát. FK → Surveillance Enforcement Case. |
| 21 | surveil_pny_ancm | Công bố quyết định xử phạt từ giám sát. FK → Surveillance Enforcement Decision. |
| 22 | aml_case_doc_attch | Văn bản đính kèm hồ sơ PCRT. FK → AML Enforcement Case. |
| 23 | cpln_pcs_case_doc_attch | Văn bản đính kèm hồ sơ giải quyết đơn thư. FK → Complaint Processing Case. |
| 24 | insp_anul_pln_doc_attch | Văn bản đính kèm kế hoạch thanh tra năm. FK → Inspection Annual Plan. |
| 25 | insp_case_doc_attch | Văn bản đính kèm hồ sơ thanh tra (biên bản làm việc v.v.). FK → Inspection Case. |
| 26 | insp_dcsn_doc_attch | Văn bản đính kèm quyết định thanh tra. FK → Inspection Decision. |
| 27 | surveil_case_doc_attch | Văn bản đính kèm hồ sơ giám sát. FK → Surveillance Enforcement Case. |
| 28 | surveil_nfrc_dcsn_file_attch | File đính kèm văn bản xử lý giám sát. FK → Surveillance Enforcement Decision. |
| 29 | fnd_mgt_co | Công ty quản lý quỹ đầu tư chứng khoán trong nước được UBCKNN cấp phép hoạt động. Lưu thông tin pháp lý và hoạt động của công ty. |
| 30 | insp_ofcr | Cán bộ thanh tra viên thuộc UBCKNN. Ghi nhận thông tin cá nhân và trạng thái công tác. |
| 31 | insp_sbj_othr_p | Đối tượng thanh tra khác (cá nhân hoặc tổ chức) không thuộc danh mục CK/QLQ/ĐC. Phân biệt qua party_type_code. |
| 32 | pblc_co | Công ty đại chúng được UBCKNN quản lý. Lưu thông tin pháp lý và trạng thái hoạt động. |
| 33 | scr_co | Công ty chứng khoán - thành viên thị trường trong hệ thống FIMS. Quản lý tài khoản và danh mục NĐT nước ngoài. |
| 34 | ip_elc_adr | Lưu trữ các địa chỉ liên lạc điện tử của Involved Party (điện thoại/fax/email). Mỗi dòng = 1 kênh liên lạc từ 1 nguồn. |
| 35 | ip_pst_adr | Lưu trữ các địa chỉ bưu chính của Involved Party (trụ sở/kinh doanh/thường trú/nơi ở hiện tại). Mỗi dòng = 1 loại địa chỉ từ 1 nguồn. |




### Bảng aml_nfrc_case



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | aml_nfrc_case_id | STRING |  | X | P |  | Khóa đại diện cho hồ sơ phòng chống rửa tiền. |
| 2 | aml_nfrc_case_code | STRING |  |  |  |  | Mã hồ sơ. Map từ PK ThanhTra.PCRT_HO_SO.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.PCRT_HO_SO' | Mã hệ thống nguồn. |
| 4 | case_nbr | STRING |  |  |  |  | Mã hồ sơ nghiệp vụ (duy nhất). |
| 5 | case_nm | STRING | X |  |  |  | Tên hồ sơ. |
| 6 | sbj_tp_code | STRING |  |  |  |  | Loại đối tượng: CA_NHAN / TO_CHUC. |
| 7 | sbj_nm | STRING | X |  |  |  | Tên tổ chức/cá nhân liên quan (denormalized). |
| 8 | rcvd_dt | DATE | X |  |  |  | Ngày nhận hồ sơ. |
| 9 | bsn_sctr_code | STRING | X |  |  |  | Mảng nghiệp vụ liên quan. |
| 10 | archv_nbr | STRING | X |  |  |  | Mã số lưu trữ. |
| 11 | case_cntnt | STRING | X |  |  |  | Nội dung hồ sơ. |
| 12 | case_st_code | STRING |  |  |  |  | Trạng thái hồ sơ. |
| 13 | rspl_ofcr_id | STRING | X |  | F |  | FK đến Inspection Officer — lãnh đạo phụ trách. |
| 14 | rspl_ofcr_code | STRING | X |  |  |  | Mã cán bộ lãnh đạo phụ trách. |
| 15 | pcs_ofcr_id | STRING | X |  | F |  | FK đến Inspection Officer — chuyên viên xử lý. |
| 16 | pcs_ofcr_code | STRING | X |  |  |  | Mã cán bộ chuyên viên xử lý. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| aml_nfrc_case_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rspl_ofcr_id | insp_ofcr | insp_ofcr_id |
| pcs_ofcr_id | insp_ofcr | insp_ofcr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng aml_nfrc_dcsn



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | aml_nfrc_dcsn_id | STRING |  | X | P |  | Khóa đại diện cho quyết định xử phạt PCRT. |
| 2 | aml_nfrc_dcsn_code | STRING |  |  |  |  | Mã quyết định. Map từ PK ThanhTra.PCRT_VAN_BAN_XU_LY.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.PCRT_VAN_BAN_XU_LY' | Mã hệ thống nguồn. |
| 4 | aml_nfrc_case_id | STRING |  |  | F |  | FK đến AML Enforcement Case. |
| 5 | aml_nfrc_case_code | STRING |  |  |  |  | Mã hồ sơ PCRT. |
| 6 | pny_dcsn_nbr | STRING | X |  |  |  | Số quyết định xử phạt / công văn nhắc nhở. |
| 7 | vln_rpt_nbr | STRING | X |  |  |  | Số biên bản vi phạm hành chính. |
| 8 | vln_rpt_dt | DATE | X |  |  |  | Ngày ký biên bản vi phạm hành chính. |
| 9 | pny_cntnt | STRING | X |  |  |  | Nội dung xử phạt. |
| 10 | tot_pny_amt | DECIMAL(23,2) | X |  |  |  | Tổng số tiền phạt. |
| 11 | dcsn_st_code | STRING | X |  |  |  | Trạng thái. |
| 12 | remark | STRING | X |  |  |  | Ghi chú. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| aml_nfrc_dcsn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| aml_nfrc_case_id | aml_nfrc_case | aml_nfrc_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng aml_prd_rpt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | aml_prd_rpt_id | STRING |  | X | P |  | Khóa đại diện cho báo cáo phòng chống rửa tiền định kỳ. |
| 2 | aml_prd_rpt_code | STRING |  |  |  |  | Mã báo cáo. Map từ ThanhTra.PCRT_BAO_CAO.MA_BAO_CAO (unique). |
| 3 | src_rcrd_id | STRING |  |  |  |  | Khóa chính nội bộ từ bảng nguồn ThanhTra.PCRT_BAO_CAO.ID. |
| 4 | src_stm_code | STRING |  |  |  | 'ThanhTra.PCRT_BAO_CAO' | Mã hệ thống nguồn. |
| 5 | rpt_nm | STRING |  |  |  |  | Tên báo cáo phòng chống rửa tiền. |
| 6 | rpt_dt | DATE | X |  |  |  | Ngày lập báo cáo. |
| 7 | rpt_snd_dt | DATE | X |  |  |  | Ngày gửi báo cáo. |
| 8 | prd_fm_dt | DATE | X |  |  |  | Từ ngày tổng hợp. |
| 9 | prd_to_dt | DATE | X |  |  |  | Đến ngày tổng hợp. |
| 10 | rpt_cntnt | STRING | X |  |  |  | Nội dung báo cáo. |
| 11 | rpt_file_url | STRING | X |  |  |  | Đường dẫn file báo cáo. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| aml_prd_rpt_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng anti-corruption_rpt



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | anti-corruption_rpt_id | STRING |  | X | P |  | Khóa đại diện cho báo cáo phòng chống tham nhũng. |
| 2 | anti-corruption_rpt_code | STRING |  |  |  |  | Mã báo cáo PCTN. Map từ PK ThanhTra.PCTN_BAO_CAO.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.PCTN_BAO_CAO' | Mã hệ thống nguồn. |
| 4 | rpt_nm | STRING |  |  |  |  | Tên báo cáo phòng chống tham nhũng. |
| 5 | rpt_dt | DATE | X |  |  |  | Ngày lập báo cáo. |
| 6 | rpt_snd_dt | DATE | X |  |  |  | Ngày gửi báo cáo. |
| 7 | prd_fm_dt | DATE | X |  |  |  | Từ ngày tổng hợp. |
| 8 | prd_to_dt | DATE | X |  |  |  | Đến ngày tổng hợp. |
| 9 | citizen_rcptn_rslt | STRING | X |  |  |  | Kết quả tiếp công dân. |
| 10 | cpln_pcs_rslt | STRING | X |  |  |  | Kết quả xử lý khiếu nại tố cáo. |
| 11 | rpt_file_url | STRING | X |  |  |  | Đường dẫn file báo cáo. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| anti-corruption_rpt_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng cpln_nfrc_dcsn



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | cpln_nfrc_dcsn_id | STRING |  | X | P |  | Khóa đại diện cho quyết định xử phạt từ hồ sơ đơn thư. |
| 2 | cpln_nfrc_dcsn_code | STRING |  |  |  |  | Mã quyết định xử phạt. Map từ PK ThanhTra.DT_VAN_BAN_XU_LY.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DT_VAN_BAN_XU_LY' | Mã hệ thống nguồn. |
| 4 | cpln_pcs_case_id | STRING |  |  | F |  | FK đến Complaint Processing Case (OQ-5: DT_VAN_BAN_XU_LY FK → DT_HO_SO). |
| 5 | cpln_pcs_case_code | STRING |  |  |  |  | Mã hồ sơ đơn thư. |
| 6 | pny_dcsn_nbr | STRING | X |  |  |  | Số quyết định xử phạt. |
| 7 | vln_rpt_nbr | STRING | X |  |  |  | Số biên bản vi phạm hành chính. |
| 8 | vln_rpt_dt | DATE | X |  |  |  | Ngày biên bản vi phạm hành chính. |
| 9 | pny_cntnt | STRING | X |  |  |  | Nội dung xử phạt. |
| 10 | dcsn_st_code | STRING |  |  |  |  | Trạng thái: CHUA_NOP_PHAT / DA_NOP_PHAT / NOP_PHAT_NHIEU_LAN. |
| 11 | remark | STRING | X |  |  |  | Ghi chú. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| cpln_nfrc_dcsn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cpln_pcs_case_id | cpln_pcs_case | cpln_pcs_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng cpln_pny_ancm



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | cpln_pny_ancm_id | STRING |  | X | P |  | Khóa đại diện cho công bố xử phạt từ đơn thư. |
| 2 | cpln_pny_ancm_code | STRING |  |  |  |  | Mã công bố. Map từ PK ThanhTra.DT_CONG_BO_XU_PHAT.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DT_CONG_BO_XU_PHAT' | Mã hệ thống nguồn. |
| 4 | cpln_pcs_case_id | STRING | X |  | F |  | FK đến Complaint Processing Case (via HO_SO_ID — redundant navigation FK). |
| 5 | cpln_pcs_case_code | STRING | X |  |  |  | Mã hồ sơ đơn thư. |
| 6 | cpln_nfrc_dcsn_id | STRING |  |  | F |  | FK đến Complaint Enforcement Decision. |
| 7 | cpln_nfrc_dcsn_code | STRING |  |  |  |  | Mã quyết định xử phạt đơn thư. |
| 8 | ancm_cnl | STRING | X |  |  |  | Chuyên mục / kênh công bố. |
| 9 | ancm_cntnt | STRING | X |  |  |  | Nội dung công bố. |
| 10 | ancm_dt | DATE | X |  |  |  | Ngày công bố. |
| 11 | ancm_st_code | STRING |  |  |  |  | Trạng thái: CHO_DUYET / DA_DUYET. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| cpln_pny_ancm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cpln_pcs_case_id | cpln_pcs_case | cpln_pcs_case_id |
| cpln_nfrc_dcsn_id | cpln_nfrc_dcsn | cpln_nfrc_dcsn_id |



#### Index

N/A

#### Trigger

N/A




### Bảng cpln_petition



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | cpln_petition_id | STRING |  | X | P |  | Khóa đại diện cho đơn thư khiếu nại tố cáo. |
| 2 | cpln_petition_code | STRING |  |  |  |  | Mã đơn thư. Map từ PK ThanhTra.DT_DON_THU.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DT_DON_THU' | Mã hệ thống nguồn. |
| 4 | petition_nm | STRING | X |  |  |  | Tên đơn thư. |
| 5 | complainant_tp_code | STRING |  |  |  |  | Loại đối tượng gửi đơn: CA_NHAN / TO_CHUC. |
| 6 | complainant_nm | STRING | X |  |  |  | Tên tổ chức / cá nhân gửi đơn (snapshot tại thời điểm tiếp nhận). |
| 7 | is_anon | STRING |  |  |  |  | Nặc danh: 1-Có, 0-Không. |
| 8 | complainant_cnt | INT | X |  |  |  | Số người gửi đơn. |
| 9 | complainant_email | STRING | X |  |  |  | Email người gửi (snapshot — grain là đơn thư không phải IP). |
| 10 | complainant_adr | STRING | X |  |  |  | Địa chỉ người gửi (snapshot). |
| 11 | has_no_adr | STRING |  |  |  |  | Không có địa chỉ: 1-Có / 0-Không. |
| 12 | complainant_id_nbr | STRING | X |  |  |  | Số CMND/CCCD người gửi (cá nhân — snapshot). |
| 13 | complainant_id_issu_dt | DATE | X |  |  |  | Ngày cấp CMND/CCCD (snapshot). |
| 14 | complainant_gnd_code | STRING | X |  |  |  | Giới tính người gửi (cá nhân — snapshot). |
| 15 | petition_tp_code | STRING |  |  |  |  | Loại đơn: KHIEU_NAI / TO_CAO / PHAN_ANH / KIEN_NGHI. |
| 16 | written_dt | DATE | X |  |  |  | Ngày viết đơn. |
| 17 | petition_cntnt | STRING | X |  |  |  | Nội dung đơn thư. |
| 18 | subm_dt | DATE |  |  |  |  | Ngày tiếp nhận đơn. |
| 19 | recpt_src | STRING | X |  |  |  | Nơi/kênh tiếp nhận đơn. |
| 20 | petition_st_code | STRING |  |  |  |  | Trạng thái: MOI / DANG_XU_LY / HOAN_THANH / DONG. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| cpln_petition_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng cpln_pcs_case



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | cpln_pcs_case_id | STRING |  | X | P |  | Khóa đại diện cho hồ sơ giải quyết đơn thư. |
| 2 | cpln_pcs_case_code | STRING |  |  |  |  | Mã hồ sơ. Map từ PK ThanhTra.DT_HO_SO.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DT_HO_SO' | Mã hệ thống nguồn. |
| 4 | cpln_petition_id | STRING |  |  | F |  | FK đến Complaint Petition — đơn thư gốc. |
| 5 | cpln_petition_code | STRING |  |  |  |  | Mã đơn thư gốc. |
| 6 | case_nbr | STRING | X |  |  |  | Số hồ sơ. |
| 7 | case_nm | STRING | X |  |  |  | Tên hồ sơ. |
| 8 | archv_nbr | STRING | X |  |  |  | Mã số lưu trữ. |
| 9 | tfr_unit_nm | STRING | X |  |  |  | Đơn vị chuyển kết quả rà soát. |
| 10 | case_st_code | STRING |  |  |  |  | Trạng thái: MOI_TIEP_NHAN / DANG_GIAI_QUYET / HOAN_THANH. |
| 11 | rsl_dt | DATE | X |  |  |  | Ngày kết thúc giải quyết. |
| 12 | remark | STRING | X |  |  |  | Ghi chú. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| cpln_pcs_case_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cpln_petition_id | cpln_petition | cpln_petition_id |



#### Index

N/A

#### Trigger

N/A




### Bảng cpln_pcs_conclusion



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | cpln_pcs_conclusion_id | STRING |  | X | P |  | Khóa đại diện cho kết luận giải quyết đơn thư. |
| 2 | cpln_pcs_conclusion_code | STRING |  |  |  |  | Mã kết luận. Map từ PK ThanhTra.DT_KET_LUAN.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DT_KET_LUAN' | Mã hệ thống nguồn. |
| 4 | cpln_pcs_case_id | STRING |  |  | F |  | FK đến Complaint Processing Case. |
| 5 | cpln_pcs_case_code | STRING |  |  |  |  | Mã hồ sơ đơn thư. |
| 6 | conclusion_nbr | STRING | X |  |  |  | Số kết luận. |
| 7 | conclusion_dt | DATE | X |  |  |  | Ngày kết luận. |
| 8 | rsl_rslt_code | STRING | X |  |  |  | Kết quả giải quyết: DUNG / SAI / DUNG_MOT_PHAN. |
| 9 | conclusion_cntnt | STRING | X |  |  |  | Nội dung kết luận. |
| 10 | offc_conclusion_dt | DATE | X |  |  |  | Ngày ra kết luận chính thức. |
| 11 | referred_to_ministry_dt | DATE | X |  |  |  | Ngày chuyển cho thanh tra bộ. |
| 12 | conclusion_st_code | STRING |  |  |  |  | Trạng thái: DANG_GIAI_QUYET / DA_HOAN_THANH. |
| 13 | remark | STRING | X |  |  |  | Ghi chú. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| cpln_pcs_conclusion_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cpln_pcs_case_id | cpln_pcs_case | cpln_pcs_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng insp_anul_pln



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | insp_anul_pln_id | STRING |  | X | P |  | Khóa đại diện cho kế hoạch thanh tra hàng năm. |
| 2 | insp_anul_pln_code | STRING |  |  |  |  | Mã kế hoạch. Map từ PK ThanhTra.TT_KE_HOACH.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.TT_KE_HOACH' | Mã hệ thống nguồn. |
| 4 | pln_tp_code | STRING |  |  |  |  | Loại kế hoạch: THANH_TRA / KIEM_TRA. |
| 5 | pln_nm | STRING |  |  |  |  | Tên kế hoạch (ví dụ: Kế hoạch thanh tra năm 2025). |
| 6 | aprv_dcsn_nbr | STRING | X |  |  |  | Số quyết định phê duyệt kế hoạch. |
| 7 | aprv_dt | DATE | X |  |  |  | Ngày ký quyết định phê duyệt. |
| 8 | pln_yr | INT |  |  |  |  | Năm kế hoạch (ví dụ: 2025). |
| 9 | offc_dispatch_nbr | STRING | X |  |  |  | Số công văn kèm kế hoạch. |
| 10 | offc_dispatch_dt | DATE | X |  |  |  | Ngày công văn. |
| 11 | remark | STRING | X |  |  |  | Ghi chú (tối đa 4000 ký tự). |
| 12 | pln_st_code | STRING |  |  |  |  | Trạng thái: 1-Hoạt động, 0-Đã xóa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| insp_anul_pln_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng insp_anul_pln_sbj



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | insp_anul_pln_sbj_id | STRING |  | X | P |  | Khóa đại diện cho đối tượng trong kế hoạch thanh tra. |
| 2 | insp_anul_pln_sbj_code | STRING |  |  |  |  | Mã đối tượng kế hoạch. Map từ PK ThanhTra.TT_KE_HOACH_DOI_TUONG.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.TT_KE_HOACH_DOI_TUONG' | Mã hệ thống nguồn. |
| 4 | insp_anul_pln_id | STRING |  |  | F |  | FK đến Inspection Annual Plan. |
| 5 | insp_anul_pln_code | STRING |  |  |  |  | Mã kế hoạch. |
| 6 | seq_nbr | INT | X |  |  |  | Số thứ tự đối tượng trong kế hoạch. |
| 7 | sbj_nm | STRING |  |  |  |  | Tên đối tượng thanh tra (denormalized — không có DOI_TUONG_ID FK). |
| 8 | sbj_adr | STRING | X |  |  |  | Địa chỉ đối tượng (denormalized). |
| 9 | pln_drtn | STRING | X |  |  |  | Thời gian dự kiến thanh tra. |
| 10 | lead_unit_nm | STRING | X |  |  |  | Đơn vị chủ trì (denormalized theo tên). |
| 11 | notf_dispatch_nbr | STRING | X |  |  |  | Số công văn thông báo. |
| 12 | notf_dispatch_dt | DATE | X |  |  |  | Ngày ký công văn thông báo. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| insp_anul_pln_sbj_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| insp_anul_pln_id | insp_anul_pln | insp_anul_pln_id |



#### Index

N/A

#### Trigger

N/A




### Bảng insp_case



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | insp_case_id | STRING |  | X | P |  | Khóa đại diện cho hồ sơ thanh tra. |
| 2 | insp_case_code | STRING |  |  |  |  | Mã hồ sơ. Map từ PK ThanhTra.TT_HO_SO.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.TT_HO_SO' | Mã hệ thống nguồn. |
| 4 | insp_dcsn_id | STRING |  |  | F |  | FK đến Inspection Decision. |
| 5 | insp_dcsn_code | STRING |  |  |  |  | Mã quyết định. |
| 6 | insp_tp_code | STRING |  |  |  |  | Loại hình: THANH_TRA / KIEM_TRA. |
| 7 | bsn_sctr_code | STRING | X |  |  |  | Mảng nghiệp vụ. |
| 8 | case_nbr | STRING |  |  |  |  | Mã hồ sơ nghiệp vụ (duy nhất). |
| 9 | case_nm | STRING | X |  |  |  | Tên hồ sơ. |
| 10 | archv_nbr | STRING | X |  |  |  | Mã số lưu trữ. |
| 11 | rcvd_dt | DATE | X |  |  |  | Ngày nhận hồ sơ. |
| 12 | data_src_dsc | STRING | X |  |  |  | Nguồn cung cấp thông tin. |
| 13 | case_cntnt | STRING | X |  |  |  | Nội dung hồ sơ. |
| 14 | sbj_tp_code | STRING | X |  |  |  | Loại đối tượng: CA_NHAN / TO_CHUC (snapshot). |
| 15 | sbj_full_nm | STRING | X |  |  |  | Họ tên cá nhân đối tượng (snapshot — grain là hồ sơ không phải IP). |
| 16 | sbj_dob | DATE | X |  |  |  | Ngày sinh cá nhân đối tượng (snapshot). |
| 17 | sbj_gnd_code | STRING | X |  |  |  | Giới tính cá nhân đối tượng (snapshot). |
| 18 | sbj_nat | STRING | X |  |  |  | Quốc tịch đối tượng (snapshot — text tự do). |
| 19 | sbj_ac_nbr | STRING | X |  |  |  | Số tài khoản đối tượng (snapshot). |
| 20 | sbj_ac_bnk_nm | STRING | X |  |  |  | Nơi mở tài khoản (snapshot). |
| 21 | sbj_id_nbr | STRING | X |  |  |  | Số CMND/CCCD đối tượng cá nhân (snapshot). |
| 22 | sbj_ph_nbr | STRING | X |  |  |  | Số điện thoại đối tượng (snapshot). |
| 23 | sbj_email | STRING | X |  |  |  | Email đối tượng (snapshot). |
| 24 | sbj_adr | STRING | X |  |  |  | Địa chỉ đối tượng (snapshot). |
| 25 | sbj_org_nm | STRING | X |  |  |  | Tên tổ chức đối tượng (snapshot). |
| 26 | sbj_org_shrt_nm | STRING | X |  |  |  | Tên viết tắt tổ chức (snapshot). |
| 27 | sbj_rprs_nm | STRING | X |  |  |  | Người đại diện tổ chức (snapshot). |
| 28 | sbj_bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh tổ chức (snapshot). |
| 29 | sbj_cty | STRING | X |  |  |  | Quốc gia tổ chức (snapshot — text tự do). |
| 30 | sbj_webst | STRING | X |  |  |  | Website đối tượng (snapshot). |
| 31 | sbj_fax_nbr | STRING | X |  |  |  | Số fax đối tượng (snapshot). |
| 32 | case_st_code | STRING |  |  |  |  | Trạng thái hồ sơ. |
| 33 | rspl_ofcr_id | STRING | X |  | F |  | FK đến Inspection Officer — lãnh đạo phụ trách. |
| 34 | rspl_ofcr_code | STRING | X |  |  |  | Mã cán bộ lãnh đạo phụ trách. |
| 35 | pcs_ofcr_id | STRING | X |  | F |  | FK đến Inspection Officer — chuyên viên xử lý. |
| 36 | pcs_ofcr_code | STRING | X |  |  |  | Mã cán bộ chuyên viên xử lý. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| insp_case_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| insp_dcsn_id | insp_dcsn | insp_dcsn_id |
| rspl_ofcr_id | insp_ofcr | insp_ofcr_id |
| pcs_ofcr_id | insp_ofcr | insp_ofcr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng insp_case_conclusion



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | insp_case_conclusion_id | STRING |  | X | P |  | Khóa đại diện cho kết luận thanh tra. |
| 2 | insp_case_conclusion_code | STRING |  |  |  |  | Mã kết luận. Map từ PK ThanhTra.TT_KET_LUAN.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.TT_KET_LUAN' | Mã hệ thống nguồn. |
| 4 | insp_case_id | STRING |  |  | F |  | FK đến Inspection Case. |
| 5 | insp_case_code | STRING |  |  |  |  | Mã hồ sơ thanh tra. |
| 6 | conclusion_seq_nbr | INT |  |  |  |  | Số thứ tự kết luận trong 1 hồ sơ (1:N — có thể có nhiều kết luận: sơ bộ, chính thức, bổ sung). |
| 7 | doc_tp_code | STRING | X |  |  |  | Loại văn bản: KET_LUAN / VAN_BAN_XU_LY. |
| 8 | conclusion_doc_nbr | STRING | X |  |  |  | Số hiệu văn bản kết luận. |
| 9 | signing_dt | DATE | X |  |  |  | Ngày văn bản. |
| 10 | conclusion_smy | STRING | X |  |  |  | Nội dung văn bản kết luận. |
| 11 | pny_amt | DECIMAL(23,2) | X |  |  |  | Số tiền phạt. |
| 12 | vln_claus | STRING | X |  |  |  | Điều khoản hành vi vi phạm. |
| 13 | vln_reg_doc | STRING | X |  |  |  | Văn bản quy định hành vi vi phạm. |
| 14 | pny_claus | STRING | X |  |  |  | Điều khoản chế tài áp dụng. |
| 15 | pny_reg_doc | STRING | X |  |  |  | Văn bản quy định chế tài. |
| 16 | vln_tp_code | STRING | X |  |  |  | Danh mục hành vi vi phạm. |
| 17 | pny_tp_code | STRING | X |  |  |  | Danh mục hình thức phạt. |
| 18 | attch_file_nm | STRING | X |  |  |  | Tên file đính kèm kết luận. |
| 19 | attch_file_url | STRING | X |  |  |  | Đường dẫn file kết luận. |
| 20 | conclusion_st_code | STRING | X |  |  |  | Trạng thái văn bản kết luận. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| insp_case_conclusion_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| insp_case_id | insp_case | insp_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng insp_case_ofcr_asgnm



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | insp_case_ofcr_asgnm_id | STRING |  | X | P |  | Khóa đại diện cho phân công cán bộ xử lý hồ sơ thanh tra. |
| 2 | insp_case_ofcr_asgnm_code | STRING |  |  |  |  | Mã phân công. Map từ PK ThanhTra.TT_HO_SO_CAN_BO.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.TT_HO_SO_CAN_BO' | Mã hệ thống nguồn. |
| 4 | insp_case_id | STRING |  |  | F |  | FK đến Inspection Case. |
| 5 | insp_case_code | STRING |  |  |  |  | Mã hồ sơ thanh tra. |
| 6 | insp_ofcr_id | STRING |  |  | F |  | FK đến Inspection Officer — cán bộ được phân công. |
| 7 | insp_ofcr_code | STRING |  |  |  |  | Mã cán bộ. |
| 8 | ofcr_rl_code | STRING |  |  |  |  | Loại phân công: LANH_DAO / CHUYEN_VIEN. |
| 9 | asgnm_dt | DATE | X |  |  |  | Ngày phân công. |
| 10 | remark | STRING | X |  |  |  | Ghi chú phân công. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| insp_case_ofcr_asgnm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| insp_case_id | insp_case | insp_case_id |
| insp_ofcr_id | insp_ofcr | insp_ofcr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng insp_dcsn



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | insp_dcsn_id | STRING |  | X | P |  | Khóa đại diện cho quyết định thanh tra. |
| 2 | insp_dcsn_code | STRING |  |  |  |  | Mã quyết định. Map từ PK ThanhTra.TT_QUYET_DINH.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.TT_QUYET_DINH' | Mã hệ thống nguồn. |
| 4 | insp_anul_pln_id | STRING | X |  | F |  | FK đến Inspection Annual Plan (nullable — quyết định đột xuất không có kế hoạch). |
| 5 | insp_anul_pln_code | STRING | X |  |  |  | Mã kế hoạch. |
| 6 | insp_tp_code | STRING |  |  |  |  | Loại hình: THANH_TRA / KIEM_TRA. |
| 7 | doc_form_tp_code | STRING | X |  |  |  | Hình thức văn bản. |
| 8 | dcsn_nbr | STRING |  |  |  |  | Số quyết định (duy nhất). |
| 9 | dcsn_nm | STRING | X |  |  |  | Tên quyết định. |
| 10 | issu_dt | DATE | X |  |  |  | Ngày ra quyết định. |
| 11 | ancm_dt | DATE | X |  |  |  | Ngày công bố quyết định. |
| 12 | bsn_sctr_code | STRING | X |  |  |  | Mảng nghiệp vụ. |
| 13 | lgl_bss_tp_code | STRING | X |  |  |  | Căn cứ thanh tra (văn bản pháp lý). |
| 14 | dcsn_cntnt | STRING | X |  |  |  | Nội dung quyết định. |
| 15 | remark | STRING | X |  |  |  | Ghi chú. |
| 16 | dcsn_st_code | STRING |  |  |  |  | Trạng thái: 1-Hoạt động, 0-Đã xóa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| insp_dcsn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| insp_anul_pln_id | insp_anul_pln | insp_anul_pln_id |



#### Index

N/A

#### Trigger

N/A




### Bảng insp_dcsn_sbj



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | insp_dcsn_sbj_id | STRING |  | X | P |  | Khóa đại diện cho đối tượng trong quyết định thanh tra. |
| 2 | insp_dcsn_sbj_code | STRING |  |  |  |  | Mã đối tượng quyết định. Map từ PK ThanhTra.TT_QUYET_DINH_DOI_TUONG.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.TT_QUYET_DINH_DOI_TUONG' | Mã hệ thống nguồn. |
| 4 | insp_dcsn_id | STRING |  |  | F |  | FK đến Inspection Decision. |
| 5 | insp_dcsn_code | STRING |  |  |  |  | Mã quyết định. |
| 6 | seq_nbr | INT | X |  |  |  | Số thứ tự đối tượng trong quyết định. |
| 7 | sbj_tp_code | STRING |  |  |  |  | Loại đối tượng: CA_NHAN / TO_CHUC. |
| 8 | sbj_nm | STRING |  |  |  |  | Tên đối tượng (denormalized — DOI_TUONG_REF_ID là polymorphic FK, không resolve được thành entity duy nhất). |
| 9 | sbj_refr_id | STRING | X |  | F |  | Tham chiếu đến bảng DM_ tương ứng (polymorphic — giá trị có thể trỏ đến DM_CONG_TY_CK/QLQ/DC/DM_DOI_TUONG_KHAC). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| insp_dcsn_sbj_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| insp_dcsn_id | insp_dcsn | insp_dcsn_id |



#### Index

N/A

#### Trigger

N/A




### Bảng insp_dcsn_team_mbr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | insp_dcsn_team_mbr_id | STRING |  | X | P |  | Khóa đại diện cho thành viên đoàn thanh tra trong quyết định. |
| 2 | insp_dcsn_team_mbr_code | STRING |  |  |  |  | Mã thành viên. Map từ PK ThanhTra.TT_QUYET_DINH_THANH_PHAN.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.TT_QUYET_DINH_THANH_PHAN' | Mã hệ thống nguồn. |
| 4 | insp_dcsn_id | STRING |  |  | F |  | FK đến Inspection Decision. |
| 5 | insp_dcsn_code | STRING |  |  |  |  | Mã quyết định. |
| 6 | insp_ofcr_id | STRING |  |  | F |  | FK đến Inspection Officer — cán bộ trong đoàn. |
| 7 | insp_ofcr_code | STRING |  |  |  |  | Mã cán bộ. |
| 8 | team_rl_dsc | STRING | X |  |  |  | Vai trò trong đoàn (trưởng đoàn, thành viên...). |
| 9 | seq_nbr | INT | X |  |  |  | Số thứ tự trong đoàn. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| insp_dcsn_team_mbr_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| insp_dcsn_id | insp_dcsn | insp_dcsn_id |
| insp_ofcr_id | insp_ofcr | insp_ofcr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng insp_pny_ancm



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | insp_pny_ancm_id | STRING |  | X | P |  | Khóa đại diện cho công bố xử phạt từ kết luận thanh tra. |
| 2 | insp_pny_ancm_code | STRING |  |  |  |  | Mã công bố. Map từ PK ThanhTra.TT_CONG_BO_XU_PHAT.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.TT_CONG_BO_XU_PHAT' | Mã hệ thống nguồn. |
| 4 | insp_case_id | STRING | X |  | F |  | FK đến Inspection Case (via HO_SO_ID — redundant navigation FK). |
| 5 | insp_case_code | STRING | X |  |  |  | Mã hồ sơ thanh tra. |
| 6 | insp_case_conclusion_id | STRING |  |  | F |  | FK đến Inspection Case Conclusion. |
| 7 | insp_case_conclusion_code | STRING |  |  |  |  | Mã kết luận thanh tra. |
| 8 | ancm_cnl | STRING | X |  |  |  | Chuyên mục trên cổng TTĐT. |
| 9 | ancm_cntnt | STRING | X |  |  |  | Nội dung công bố. |
| 10 | ancm_dt | DATE | X |  |  |  | Ngày công bố. |
| 11 | ancm_st_code | STRING |  |  |  |  | Trạng thái: CHO_DUYET / DA_DUYET. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| insp_pny_ancm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| insp_case_id | insp_case | insp_case_id |
| insp_case_conclusion_id | insp_case_conclusion | insp_case_conclusion_id |



#### Index

N/A

#### Trigger

N/A




### Bảng surveil_nfrc_case



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | surveil_nfrc_case_id | STRING |  | X | P |  | Khóa đại diện cho hồ sơ xử lý vi phạm từ giám sát. |
| 2 | surveil_nfrc_case_code | STRING |  |  |  |  | Mã hồ sơ. Map từ PK ThanhTra.GS_HO_SO.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.GS_HO_SO' | Mã hệ thống nguồn. |
| 4 | case_nbr | STRING |  |  |  |  | Mã hồ sơ nghiệp vụ (duy nhất trong hệ thống). |
| 5 | case_nm | STRING | X |  |  |  | Tên hồ sơ. |
| 6 | archv_nbr | STRING | X |  |  |  | Mã số lưu trữ. |
| 7 | rcvd_dt | DATE | X |  |  |  | Ngày nhận hồ sơ. |
| 8 | bsn_sctr_code | STRING | X |  |  |  | Mảng nghiệp vụ liên quan. |
| 9 | data_src_dsc | STRING | X |  |  |  | Nguồn cung cấp hồ sơ (nhiều nguồn, lưu text). |
| 10 | case_cntnt | STRING | X |  |  |  | Nội dung hồ sơ. |
| 11 | scr_lvl_code | STRING | X |  |  |  | Mức độ bảo mật hồ sơ. |
| 12 | sbj_nm | STRING | X |  |  |  | Tên đối tượng vi phạm (denormalized). |
| 13 | case_st_code | STRING |  |  |  |  | Trạng thái hồ sơ. |
| 14 | remark | STRING | X |  |  |  | Ghi chú. |
| 15 | rspl_ofcr_id | STRING | X |  | F |  | FK đến Inspection Officer — lãnh đạo phụ trách. |
| 16 | rspl_ofcr_code | STRING | X |  |  |  | Mã cán bộ lãnh đạo phụ trách. |
| 17 | pcs_ofcr_id | STRING | X |  | F |  | FK đến Inspection Officer — chuyên viên xử lý. |
| 18 | pcs_ofcr_code | STRING | X |  |  |  | Mã cán bộ chuyên viên xử lý. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| surveil_nfrc_case_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| rspl_ofcr_id | insp_ofcr | insp_ofcr_id |
| pcs_ofcr_id | insp_ofcr | insp_ofcr_id |



#### Index

N/A

#### Trigger

N/A




### Bảng surveil_nfrc_dcsn



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | surveil_nfrc_dcsn_id | STRING |  | X | P |  | Khóa đại diện cho quyết định xử phạt từ giám sát. |
| 2 | surveil_nfrc_dcsn_code | STRING |  |  |  |  | Mã quyết định. Map từ PK ThanhTra.GS_VAN_BAN_XU_LY.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.GS_VAN_BAN_XU_LY' | Mã hệ thống nguồn. |
| 4 | surveil_nfrc_case_id | STRING |  |  | F |  | FK đến Surveillance Enforcement Case. |
| 5 | surveil_nfrc_case_code | STRING |  |  |  |  | Mã hồ sơ giám sát. |
| 6 | pny_dcsn_nbr | STRING | X |  |  |  | Số quyết định xử phạt / số công văn nhắc nhở. |
| 7 | vln_rpt_nbr | STRING | X |  |  |  | Số biên bản vi phạm hành chính. |
| 8 | vln_rpt_dt | DATE | X |  |  |  | Ngày ký biên bản vi phạm hành chính. |
| 9 | pny_cntnt | STRING | X |  |  |  | Nội dung xử phạt. |
| 10 | tot_pny_amt | DECIMAL(23,2) | X |  |  |  | Tổng số tiền phạt. |
| 11 | dcsn_st_code | STRING | X |  |  |  | Trạng thái hồ sơ sau xử lý. |
| 12 | remark | STRING | X |  |  |  | Ghi chú. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| surveil_nfrc_dcsn_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| surveil_nfrc_case_id | surveil_nfrc_case | surveil_nfrc_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng surveil_pny_ancm



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | surveil_pny_ancm_id | STRING |  | X | P |  | Khóa đại diện cho thông báo công bố xử phạt từ giám sát. |
| 2 | surveil_pny_ancm_code | STRING |  |  |  |  | Mã công bố. Map từ PK ThanhTra.GS_CONG_BO_XU_PHAT.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.GS_CONG_BO_XU_PHAT' | Mã hệ thống nguồn. |
| 4 | surveil_nfrc_case_id | STRING | X |  | F |  | FK đến Surveillance Enforcement Case (via HO_SO_ID — redundant navigation FK). |
| 5 | surveil_nfrc_case_code | STRING | X |  |  |  | Mã hồ sơ giám sát. |
| 6 | surveil_nfrc_dcsn_id | STRING |  |  | F |  | FK đến Surveillance Enforcement Decision (via QUYET_DINH_XU_PHAT_ID). |
| 7 | surveil_nfrc_dcsn_code | STRING |  |  |  |  | Mã quyết định xử phạt. |
| 8 | ancm_cnl | STRING | X |  |  |  | Chuyên mục / kênh công bố. |
| 9 | ancm_cntnt | STRING | X |  |  |  | Nội dung công bố. |
| 10 | ancm_dt | DATE | X |  |  |  | Ngày công bố. |
| 11 | ancm_st_code | STRING |  |  |  |  | Trạng thái: CHO_DUYET / DA_DUYET. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| surveil_pny_ancm_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| surveil_nfrc_case_id | surveil_nfrc_case | surveil_nfrc_case_id |
| surveil_nfrc_dcsn_id | surveil_nfrc_dcsn | surveil_nfrc_dcsn_id |



#### Index

N/A

#### Trigger

N/A




### Bảng aml_case_doc_attch



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | aml_case_doc_attch_id | STRING |  | X | P |  | Khóa đại diện cho văn bản đính kèm hồ sơ PCRT. |
| 2 | aml_case_doc_attch_code | STRING |  |  |  |  | Mã văn bản. Map từ PK ThanhTra.PCRT_HO_SO_VAN_BAN.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.PCRT_HO_SO_VAN_BAN' | Mã hệ thống nguồn. |
| 4 | aml_nfrc_case_id | STRING |  |  | F |  | FK đến AML Enforcement Case. |
| 5 | aml_nfrc_case_code | STRING |  |  |  |  | Mã hồ sơ PCRT. |
| 6 | doc_nbr | STRING | X |  |  |  | Số hiệu văn bản. |
| 7 | doc_nm | STRING |  |  |  |  | Tên tài liệu. |
| 8 | pg_cnt | INT | X |  |  |  | Số trang. |
| 9 | doc_src | STRING | X |  |  |  | Nguồn gốc tài liệu. |
| 10 | attch_file_nm | STRING | X |  |  |  | Tên file đính kèm. |
| 11 | attch_file_url | STRING | X |  |  |  | Đường dẫn file. |
| 12 | attch_file_sz | INT | X |  |  |  | Kích thước file (bytes). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| aml_case_doc_attch_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| aml_nfrc_case_id | aml_nfrc_case | aml_nfrc_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng cpln_pcs_case_doc_attch



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | cpln_pcs_case_doc_attch_id | STRING |  | X | P |  | Khóa đại diện cho văn bản đính kèm hồ sơ đơn thư. |
| 2 | cpln_pcs_case_doc_attch_code | STRING |  |  |  |  | Mã văn bản. Map từ PK ThanhTra.DT_HO_SO_VAN_BAN.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DT_HO_SO_VAN_BAN' | Mã hệ thống nguồn. |
| 4 | cpln_pcs_case_id | STRING |  |  | F |  | FK đến Complaint Processing Case. |
| 5 | cpln_pcs_case_code | STRING |  |  |  |  | Mã hồ sơ đơn thư. |
| 6 | doc_tp_code | STRING | X |  |  |  | Loại văn bản: QUYET_DINH_THU_LY / BIEN_BAN_VPHC / CONG_VAN_TB / DON_THU. |
| 7 | doc_nbr | STRING | X |  |  |  | Số hiệu văn bản. |
| 8 | doc_nm | STRING |  |  |  |  | Tên tài liệu. |
| 9 | pg_cnt | INT | X |  |  |  | Số trang. |
| 10 | doc_src | STRING | X |  |  |  | Nguồn gốc. |
| 11 | attch_file_nm | STRING | X |  |  |  | Tên file đính kèm. |
| 12 | attch_file_url | STRING | X |  |  |  | Đường dẫn file. |
| 13 | attch_file_sz | INT | X |  |  |  | Kích thước file (bytes). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| cpln_pcs_case_doc_attch_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cpln_pcs_case_id | cpln_pcs_case | cpln_pcs_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng insp_anul_pln_doc_attch



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | insp_anul_pln_doc_attch_id | STRING |  | X | P |  | Khóa đại diện cho văn bản kèm kế hoạch thanh tra. |
| 2 | insp_anul_pln_doc_attch_code | STRING |  |  |  |  | Mã văn bản. Map từ PK ThanhTra.TT_KE_HOACH_VAN_BAN.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.TT_KE_HOACH_VAN_BAN' | Mã hệ thống nguồn. |
| 4 | insp_anul_pln_id | STRING |  |  | F |  | FK đến Inspection Annual Plan. |
| 5 | insp_anul_pln_code | STRING |  |  |  |  | Mã kế hoạch. |
| 6 | doc_nbr | STRING | X |  |  |  | Số hiệu văn bản. |
| 7 | doc_nm | STRING |  |  |  |  | Tên tài liệu. |
| 8 | pg_seq_nbr | INT | X |  |  |  | Số thứ tự trang. |
| 9 | pg_cnt | INT | X |  |  |  | Số trang tài liệu. |
| 10 | doc_src | STRING | X |  |  |  | Nguồn gốc tài liệu. |
| 11 | attch_file_nm | STRING | X |  |  |  | Tên file đính kèm. |
| 12 | attch_file_url | STRING | X |  |  |  | Đường dẫn file lưu trữ. |
| 13 | attch_file_sz | INT | X |  |  |  | Kích thước file (bytes). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| insp_anul_pln_doc_attch_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| insp_anul_pln_id | insp_anul_pln | insp_anul_pln_id |



#### Index

N/A

#### Trigger

N/A




### Bảng insp_case_doc_attch



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | insp_case_doc_attch_id | STRING |  | X | P |  | Khóa đại diện cho văn bản đính kèm hồ sơ thanh tra. |
| 2 | insp_case_doc_attch_code | STRING |  |  |  |  | Mã văn bản. Map từ PK ThanhTra.TT_HO_SO_VAN_BAN.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.TT_HO_SO_VAN_BAN' | Mã hệ thống nguồn. |
| 4 | insp_case_id | STRING |  |  | F |  | FK đến Inspection Case. |
| 5 | insp_case_code | STRING |  |  |  |  | Mã hồ sơ thanh tra. |
| 6 | doc_tp_code | STRING | X |  |  |  | Loại văn bản: KE_HOACH / QUYET_DINH / BIEN_BAN / KET_LUAN / CONG_VAN / GIAI_TRINH. |
| 7 | doc_nbr | STRING | X |  |  |  | Số hiệu văn bản. |
| 8 | doc_nm | STRING |  |  |  |  | Tên tài liệu. |
| 9 | pg_seq_nbr | INT | X |  |  |  | Số thứ tự. |
| 10 | pg_cnt | INT | X |  |  |  | Số trang. |
| 11 | doc_src | STRING | X |  |  |  | Nguồn gốc tài liệu. |
| 12 | attch_file_nm | STRING | X |  |  |  | Tên file đính kèm. |
| 13 | attch_file_url | STRING | X |  |  |  | Đường dẫn file. |
| 14 | attch_file_sz | INT | X |  |  |  | Kích thước file (bytes). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| insp_case_doc_attch_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| insp_case_id | insp_case | insp_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng insp_dcsn_doc_attch



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | insp_dcsn_doc_attch_id | STRING |  | X | P |  | Khóa đại diện cho văn bản kèm quyết định thanh tra. |
| 2 | insp_dcsn_doc_attch_code | STRING |  |  |  |  | Mã văn bản. Map từ PK ThanhTra.TT_QUYET_DINH_VAN_BAN.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.TT_QUYET_DINH_VAN_BAN' | Mã hệ thống nguồn. |
| 4 | insp_dcsn_id | STRING |  |  | F |  | FK đến Inspection Decision. |
| 5 | insp_dcsn_code | STRING |  |  |  |  | Mã quyết định. |
| 6 | doc_nbr | STRING | X |  |  |  | Số hiệu văn bản. |
| 7 | doc_nm | STRING |  |  |  |  | Tên tài liệu. |
| 8 | pg_seq_nbr | INT | X |  |  |  | Số thứ tự. |
| 9 | pg_cnt | INT | X |  |  |  | Số trang. |
| 10 | doc_src | STRING | X |  |  |  | Nguồn gốc tài liệu. |
| 11 | attch_file_nm | STRING | X |  |  |  | Tên file đính kèm. |
| 12 | attch_file_url | STRING | X |  |  |  | Đường dẫn file. |
| 13 | attch_file_sz | INT | X |  |  |  | Kích thước file (bytes). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| insp_dcsn_doc_attch_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| insp_dcsn_id | insp_dcsn | insp_dcsn_id |



#### Index

N/A

#### Trigger

N/A




### Bảng surveil_case_doc_attch



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | surveil_case_doc_attch_id | STRING |  | X | P |  | Khóa đại diện cho văn bản đính kèm hồ sơ giám sát. |
| 2 | surveil_case_doc_attch_code | STRING |  |  |  |  | Mã văn bản. Map từ PK ThanhTra.GS_HO_SO_VAN_BAN.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.GS_HO_SO_VAN_BAN' | Mã hệ thống nguồn. |
| 4 | surveil_nfrc_case_id | STRING |  |  | F |  | FK đến Surveillance Enforcement Case. |
| 5 | surveil_nfrc_case_code | STRING |  |  |  |  | Mã hồ sơ giám sát. |
| 6 | doc_nbr | STRING | X |  |  |  | Số hiệu văn bản. |
| 7 | doc_nm | STRING |  |  |  |  | Tên tài liệu. |
| 8 | seq_nbr | INT | X |  |  |  | Số thứ tự. |
| 9 | pg_cnt | INT | X |  |  |  | Số trang. |
| 10 | doc_src | STRING | X |  |  |  | Nguồn gốc tài liệu. |
| 11 | attch_file_nm | STRING | X |  |  |  | Tên file đính kèm. |
| 12 | attch_file_url | STRING | X |  |  |  | Đường dẫn file. |
| 13 | attch_file_sz | INT | X |  |  |  | Kích thước file (bytes). |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| surveil_case_doc_attch_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| surveil_nfrc_case_id | surveil_nfrc_case | surveil_nfrc_case_id |



#### Index

N/A

#### Trigger

N/A




### Bảng surveil_nfrc_dcsn_file_attch



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | surveil_nfrc_dcsn_file_attch_id | STRING |  | X | P |  | Khóa đại diện cho file đính kèm quyết định xử phạt giám sát. |
| 2 | surveil_nfrc_dcsn_file_attch_code | STRING |  |  |  |  | Mã file. Map từ PK ThanhTra.GS_VAN_BAN_XU_LY_FILE.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.GS_VAN_BAN_XU_LY_FILE' | Mã hệ thống nguồn. |
| 4 | surveil_nfrc_dcsn_id | STRING |  |  | F |  | FK đến Surveillance Enforcement Decision. |
| 5 | surveil_nfrc_dcsn_code | STRING |  |  |  |  | Mã quyết định xử phạt. |
| 6 | doc_nbr | STRING | X |  |  |  | Số hiệu văn bản. |
| 7 | doc_nm | STRING |  |  |  |  | Tên tài liệu. |
| 8 | pg_cnt | INT | X |  |  |  | Số trang. |
| 9 | doc_src | STRING | X |  |  |  | Nguồn gốc tài liệu. |
| 10 | attch_file_nm | STRING | X |  |  |  | Tên file đính kèm. |
| 11 | attch_file_url | STRING | X |  |  |  | Đường dẫn file. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| surveil_nfrc_dcsn_file_attch_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| surveil_nfrc_dcsn_id | surveil_nfrc_dcsn | surveil_nfrc_dcsn_id |



#### Index

N/A

#### Trigger

N/A




### Bảng fnd_mgt_co



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | fnd_mgt_co_id | STRING |  | X | P |  | Khóa đại diện cho công ty quản lý quỹ. |
| 2 | fnd_mgt_co_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. Map từ PK ThanhTra.DM_CONG_TY_QLQ.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CONG_TY_QLQ' | Mã hệ thống nguồn. |
| 4 | fnd_mgt_co_nm | STRING |  |  |  |  | Tên tiếng Việt công ty quản lý quỹ. |
| 5 | fnd_mgt_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt công ty quản lý quỹ. |
| 6 | fnd_mgt_co_en_nm | STRING | X |  |  |  | Tên tiếng Anh công ty quản lý quỹ. |
| 7 | practice_st_code | STRING | X |  |  |  | Trạng thái hoạt động của công ty QLQ. |
| 8 | charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ. |
| 9 | dorf_ind | STRING | X |  |  |  | Loại hình trong/ngoài nước. 1=Trong nước; 0=Nước ngoài. |
| 10 | license_dcsn_nbr | STRING | X |  |  |  | Số quyết định/giấy phép thành lập. |
| 11 | license_dcsn_dt | DATE | X |  |  |  | Ngày cấp phép. |
| 12 | actv_dt | DATE | X |  |  |  | Ngày bắt đầu hoạt động. |
| 13 | stop_dt | DATE | X |  |  |  | Ngày ngừng hoạt động. |
| 14 | bsn_tp_codes | ARRAY<STRING> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction FUNDCOMBUSINES. |
| 15 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 16 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 17 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 18 | cty_of_rgst_id | STRING | X |  | F |  | FK đến quốc gia đăng ký của công ty QLQ. |
| 19 | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. |
| 20 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. |
| 21 | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). |
| 22 | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký — thông tin bổ sung của FIMS không có trong FMS.SECURITIES. |
| 23 | co_tp_codes | ARRAY<STRING> | X |  |  |  | Danh sách mã loại hình doanh nghiệp. Từ bảng junction FUNDCOMTYPE. |
| 24 | dsc | STRING | X |  |  |  | Ghi chú. |
| 25 | co_tp_code | STRING | X |  |  |  | Loại hình công ty. |
| 26 | fnd_tp_code | STRING | X |  |  |  | Loại quỹ (áp dụng cho quỹ đầu tư). |
| 27 | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. |
| 28 | webst | STRING | X |  |  |  | Website chính thức. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| fnd_mgt_co_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cty_of_rgst_id | geo | geo_id |



#### Index

N/A

#### Trigger

N/A




### Bảng insp_ofcr



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | insp_ofcr_id | STRING |  | X | P |  | Khóa đại diện cho cán bộ thanh tra. |
| 2 | insp_ofcr_code | STRING |  |  |  |  | Mã cán bộ thanh tra. Map từ PK bảng nguồn ThanhTra.DM_CAN_BO.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CAN_BO' | Mã hệ thống nguồn. |
| 4 | login_nm | STRING | X |  |  |  | Tên đăng nhập, liên kết tài khoản hệ thống nội bộ. |
| 5 | full_nm | STRING |  |  |  |  | Họ và tên cán bộ thanh tra. |
| 6 | dob | DATE | X |  |  |  | Ngày sinh cán bộ. |
| 7 | gnd_code | STRING | X |  |  |  | Giới tính: NAM / NU. |
| 8 | supervised_co_nm | STRING | X |  |  |  | Công ty phụ trách (tên công ty — denormalized, không có FK). |
| 9 | ofcr_st_code | STRING |  |  |  |  | Trạng thái cán bộ: SU_DUNG / KHONG_SU_DUNG. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| insp_ofcr_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng insp_sbj_othr_p



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | insp_sbj_othr_p_id | STRING |  | X | P |  | Khóa đại diện cho đối tượng thanh tra khác. |
| 2 | insp_sbj_othr_p_code | STRING |  |  |  |  | Mã đối tượng. Map từ PK ThanhTra.DM_DOI_TUONG_KHAC.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_DOI_TUONG_KHAC' | Mã hệ thống nguồn. |
| 4 | p_tp_code | STRING |  |  |  |  | Loại đối tượng: CA_NHAN / TO_CHUC. |
| 5 | nm | STRING |  |  |  |  | Tên đối tượng thanh tra. |
| 6 | shrt_nm | STRING | X |  |  |  | Tên viết tắt. |
| 7 | rprs_nm | STRING | X |  |  |  | Người đại diện (cho tổ chức). |
| 8 | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh (cho tổ chức). |
| 9 | cty_of_rgst_id | STRING | X |  | F |  | FK đến Geographic Area — quốc gia đăng ký. |
| 10 | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. |
| 11 | webst | STRING | X |  |  |  | Website. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| insp_sbj_othr_p_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cty_of_rgst_id | geo | geo_id |



#### Index

N/A

#### Trigger

N/A




### Bảng pblc_co



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | pblc_co_id | STRING |  | X | P |  | Khóa đại diện cho công ty đại chúng. |
| 2 | pblc_co_code | STRING |  |  |  |  | Mã công ty đại chúng. Map từ PK ThanhTra.DM_CONG_TY_DC.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CONG_TY_DC' | Mã hệ thống nguồn. |
| 4 | pblc_co_nm | STRING |  |  |  |  | Tên tiếng Việt công ty đại chúng. |
| 5 | pblc_co_en_nm | STRING | X |  |  |  | Tên tiếng Anh công ty đại chúng. |
| 6 | pblc_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt công ty đại chúng. |
| 7 | co_tp_code | STRING | X |  |  |  | Loại hình công ty. |
| 8 | charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ. |
| 9 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. |
| 10 | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. |
| 11 | webst | STRING | X |  |  |  | Website chính thức. |
| 12 | bsn_rgst_nbr | STRING | X |  |  |  | Mã số doanh nghiệp / số ĐKKD. |
| 13 | frst_rgst_dt | DATE | X |  |  |  | Ngày đăng ký lần đầu. |
| 14 | latest_rgst_dt | DATE | X |  |  |  | Ngày cấp gần nhất. |
| 15 | latest_rgst_prov_code | STRING | X |  |  |  | Tỉnh/thành nơi cấp gần nhất (mã tỉnh từ provinces). |
| 16 | idy_cgy_id | STRING | X |  | F |  | Id ngành nghề (categories). |
| 17 | idy_cgy_code | STRING | X |  |  |  | Mã ngành nghề (categories). |
| 18 | idy_cgy_level1_code | STRING | X |  |  |  | Ngành nghề cấp 1 (mã categories cấp 1). |
| 19 | idy_cgy_level2_code | STRING | X |  |  |  | Ngành nghề cấp 2 (mã categories cấp 2). |
| 20 | ids_st_code | STRING | X |  |  |  | Trạng thái niêm yết IDS. |
| 21 | auto_aprv_f | BOOLEAN | X |  |  |  | Tự động duyệt (1=tự động / 0=không). |
| 22 | co_login | STRING | X |  |  |  | User của công ty niêm yết (login_name). |
| 23 | approver_cmnt | STRING | X |  |  |  | Ý kiến người duyệt. |
| 24 | prn_co_f | BOOLEAN | X |  |  |  | Là công ty mẹ (1=có / 0=không). |
| 25 | eqty_listing_exg_code | STRING | X |  |  |  | Sàn niêm yết cổ phiếu (HNX/HOSE/UPCoM). |
| 26 | eqty_listing_exg_nm | STRING | X |  |  |  | Sàn niêm yết cổ phiếu (text từ company_detail). |
| 27 | bond_listing_exg_nm | STRING | X |  |  |  | Sàn niêm yết trái phiếu (text từ company_detail). |
| 28 | eqty_scr_f | BOOLEAN | X |  |  |  | Loại chứng khoán niêm yết là cổ phiếu (1=có / 0=không). |
| 29 | bond_scr_f | BOOLEAN | X |  |  |  | Loại chứng khoán niêm yết là trái phiếu (1=có / 0=không). |
| 30 | eqty_ticker | STRING | X |  |  |  | Mã chứng khoán cổ phiếu. |
| 31 | bond_ticker | STRING | X |  |  |  | Mã chứng khoán trái phiếu. |
| 32 | eqty_list_qty | INT | X |  |  |  | Số lượng cổ phiếu đang niêm yết. |
| 33 | bond_list_qty | INT | X |  |  |  | Số lượng trái phiếu đang niêm yết. |
| 34 | itnl_exg_nm | STRING | X |  |  |  | Sàn niêm yết quốc tế. |
| 35 | itnl_ticker | STRING | X |  |  |  | Mã chứng quốc tế. |
| 36 | isin_code | STRING | X |  |  |  | Mã ISIN. |
| 37 | scr_tp_code | STRING | X |  |  |  | Loại chứng khoán phát hành. |
| 38 | pblc_co_form_code | STRING | X |  |  |  | Hình thức trở thành công ty đại chúng (IPO / nộp hồ sơ trực tiếp). |
| 39 | cptl_paid_rpt_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ thực góp (cập nhật theo BCTC năm). |
| 40 | trsr_shr_qty | INT | X |  |  |  | Cổ phiếu quỹ hiện có. |
| 41 | fyr_strt_dt | DATE | X |  |  |  | Ngày bắt đầu năm tài chính. |
| 42 | fyr_end_dt | DATE | X |  |  |  | Ngày kết thúc năm tài chính. |
| 43 | fnc_stmt_tp_code | STRING | X |  |  |  | Loại báo cáo tài chính (IFRS/VAS...). |
| 44 | ids_rgst_f | BOOLEAN | X |  |  |  | Trạng thái đăng ký trên IDS (1=đã đăng ký / 0=chưa). |
| 45 | ids_rgst_dt | DATE | X |  |  |  | Ngày đăng ký trên IDS. |
| 46 | pblc_co_f | BOOLEAN | X |  |  |  | Là công ty đại chúng (1=có / 0=không). |
| 47 | pblc_bond_issur_f | BOOLEAN | X |  |  |  | Là tổ chức niêm yết trái phiếu (1=có / 0=không). |
| 48 | lrg_pblc_co_f | BOOLEAN | X |  |  |  | Là công ty đại chúng quy mô lớn (1=có / 0=không). |
| 49 | formr_ste_own_f | BOOLEAN | X |  |  |  | Tiền thân là doanh nghiệp nhà nước (1=có / 0=không). |
| 50 | equitisation_license_dt | DATE | X |  |  |  | Ngày được cấp GPKD sau cổ phần hóa. |
| 51 | cptl_at_equitisation_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ thực góp tại thời điểm cổ phần hóa. |
| 52 | has_ste_own_f | BOOLEAN | X |  |  |  | Có vốn nhà nước (1=có / 0=không). |
| 53 | fdi_co_f | BOOLEAN | X |  |  |  | Là doanh nghiệp FDI (1=có / 0=không). |
| 54 | has_prn_co_f | BOOLEAN | X |  |  |  | Có công ty mẹ (1=có / 0=không). |
| 55 | has_subs_f | BOOLEAN | X |  |  |  | Có công ty con (1=có / 0=không). |
| 56 | has_jnt_ventures_f | BOOLEAN | X |  |  |  | Có công ty liên doanh, liên kết (1=có / 0=không). |
| 57 | entp_tp_code | STRING | X |  |  |  | Loại hình doanh nghiệp (bh/td/ck/dn). |
| 58 | spcl_notes | STRING | X |  |  |  | Ghi chú của chuyên viên. |
| 59 | crt_by_login_nm | STRING | X |  |  |  | Người tạo (login_name của logins). |
| 60 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo. |
| 61 | last_udt_by_login_nm | STRING | X |  |  |  | Người sửa (login_name của logins). |
| 62 | last_udt_tms | TIMESTAMP | X |  |  |  | Ngày sửa. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| pblc_co_id |



**Khóa phụ (Foreign Key):**

*Không có Foreign Key.*


#### Index

N/A

#### Trigger

N/A




### Bảng scr_co



| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | scr_co_id | STRING |  | X | P |  | Khóa đại diện cho công ty chứng khoán. |
| 2 | scr_co_code | STRING |  |  |  |  | Mã công ty chứng khoán. Map từ PK ThanhTra.DM_CONG_TY_CK.ID. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CONG_TY_CK' | Mã hệ thống nguồn. |
| 4 | cty_of_rgst_id | STRING | X |  | F |  | FK đến quốc gia đăng ký của công ty chứng khoán. |
| 5 | cty_of_rgst_code | STRING | X |  |  |  | Mã quốc gia đăng ký. |
| 6 | full_nm | STRING |  |  |  |  | Tên công ty chứng khoán. |
| 7 | en_nm | STRING | X |  |  |  | Tên tiếng Anh. |
| 8 | abr | STRING | X |  |  |  | Tên viết tắt. |
| 9 | charter_cptl_amt | DECIMAL(23,2) | X |  |  |  | Vốn điều lệ. |
| 10 | lcs_code | STRING | X |  |  |  | Trạng thái hoạt động. |
| 11 | director_nm | STRING | X |  |  |  | Tên Tổng giám đốc (denormalized). |
| 12 | depst_ctf_nbr | STRING | X |  |  |  | Chứng nhận lưu ký. |
| 13 | bsn_tp_codes | ARRAY<STRING> | X |  |  |  | Danh sách mã nghiệp vụ kinh doanh. Từ bảng junction SECCOMBUSINES. |
| 14 | co_tp_codes | ARRAY<STRING> | X |  |  |  | Danh sách mã loại hình doanh nghiệp. Từ bảng junction SECCOMTYPE. |
| 15 | dsc | STRING | X |  |  |  | Ghi chú. |
| 16 | crt_by | STRING | X |  |  |  | Người tạo bản ghi. |
| 17 | crt_tms | TIMESTAMP | X |  |  |  | Ngày tạo bản ghi. |
| 18 | udt_tms | TIMESTAMP | X |  |  |  | Ngày cập nhật bản ghi. |
| 19 | scr_co_bsn_key | STRING | X |  |  |  | ID duy nhất của CTCK dùng liên thông hệ thống (BK nghiệp vụ). |
| 20 | scr_co_bsn_code | STRING | X |  |  |  | Mã số CTCK (mã nghiệp vụ ngắn). |
| 21 | scr_co_nm | STRING |  |  |  |  | Tên tiếng Việt công ty chứng khoán. |
| 22 | scr_co_en_nm | STRING | X |  |  |  | Tên tiếng Anh công ty chứng khoán. |
| 23 | scr_co_shrt_nm | STRING | X |  |  |  | Tên viết tắt công ty chứng khoán. |
| 24 | tax_code | STRING | X |  |  |  | Mã số thuế. |
| 25 | co_tp_code | STRING | X |  |  |  | Loại hình công ty. |
| 26 | shr_qty | INT | X |  |  |  | Số lượng cổ phần. |
| 27 | bsn_sctr_codes | ARRAY<STRING> | X |  |  |  | Danh sách mã ngành nghề kinh doanh. |
| 28 | is_list_ind | STRING | X |  |  |  | Cờ niêm yết: 1-Có niêm yết; 0-Không. |
| 29 | stk_exg_nm | STRING | X |  |  |  | Sàn niêm yết. |
| 30 | scr_code | STRING | X |  |  |  | Mã chứng khoán niêm yết. |
| 31 | rgst_dt | DATE | X |  |  |  | Ngày đăng ký CTDC. |
| 32 | rgst_dcsn_nbr | STRING | X |  |  |  | Số quyết định đăng ký. |
| 33 | tmt_dt | DATE | X |  |  |  | Ngày kết thúc CTDC. |
| 34 | tmt_dcsn_nbr | STRING | X |  |  |  | Số quyết định kết thúc. |
| 35 | co_st_code | STRING | X |  |  |  | Trạng thái hoạt động của CTCK. |
| 36 | is_drft_ind | STRING | X |  |  |  | Cờ bảng tạm: 1-Bảng tạm; 0-Chính thức. |
| 37 | bsn_avy_cgy_id | STRING | X |  | F |  | FK đến ngành nghề kinh doanh (DM_NGANH_NGHE_KD). Nullable. |
| 38 | bsn_avy_cgy_code | STRING | X |  |  |  | Mã ngành nghề kinh doanh. |
| 39 | bsn_license_nbr | STRING | X |  |  |  | Số giấy phép kinh doanh. |
| 40 | webst | STRING | X |  |  |  | Website chính thức. |


#### Constraint

**Khóa chính (Primary Key):**

| Tên trường |
|---|
| scr_co_id |



**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| cty_of_rgst_id | geo | geo_id |



#### Index

N/A

#### Trigger

N/A




### Bảng ip_elc_adr



#### Từ ThanhTra.DM_CAN_BO

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Inspection Officer. |
| 2 | ip_code | STRING |  |  |  |  | Mã cán bộ thanh tra. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CAN_BO' | Mã hệ thống nguồn. |
| 4 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email cán bộ. |
| 6 | ip_id | STRING |  |  | F |  | FK đến Inspection Officer. |
| 7 | ip_code | STRING |  |  |  |  | Mã cán bộ thanh tra. |
| 8 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CAN_BO' | Mã hệ thống nguồn. |
| 9 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số điện thoại cán bộ. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | insp_ofcr | insp_ofcr_id |



**Index:** N/A

**Trigger:** N/A


#### Từ ThanhTra.DM_CONG_TY_DC

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Public Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CONG_TY_DC' | Mã hệ thống nguồn. |
| 4 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | STRING |  |  | F |  | FK đến Public Company. |
| 7 | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 8 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CONG_TY_DC' | Mã hệ thống nguồn. |
| 9 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | pblc_co | pblc_co_id |



**Index:** N/A

**Trigger:** N/A


#### Từ ThanhTra.DM_CONG_TY_CK

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CONG_TY_CK' | Mã hệ thống nguồn. |
| 4 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | STRING |  |  | F |  | FK đến Securities Company. |
| 7 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 8 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CONG_TY_CK' | Mã hệ thống nguồn. |
| 9 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co | scr_co_id |



**Index:** N/A

**Trigger:** N/A


#### Từ ThanhTra.DM_CONG_TY_QLQ

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Fund Management Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CONG_TY_QLQ' | Mã hệ thống nguồn. |
| 4 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | STRING |  |  | F |  | FK đến Fund Management Company. |
| 7 | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. |
| 8 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CONG_TY_QLQ' | Mã hệ thống nguồn. |
| 9 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — điện thoại. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | fnd_mgt_co | fnd_mgt_co_id |



**Index:** N/A

**Trigger:** N/A


#### Từ ThanhTra.DM_DOI_TUONG_KHAC

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Inspection Subject Other Party. |
| 2 | ip_code | STRING |  |  |  |  | Mã đối tượng thanh tra. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_DOI_TUONG_KHAC' | Mã hệ thống nguồn. |
| 4 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — email. |
| 5 | elc_adr_val | STRING | X |  |  |  | Email. |
| 6 | ip_id | STRING |  |  | F |  | FK đến Inspection Subject Other Party. |
| 7 | ip_code | STRING |  |  |  |  | Mã đối tượng thanh tra. |
| 8 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_DOI_TUONG_KHAC' | Mã hệ thống nguồn. |
| 9 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — fax. |
| 10 | elc_adr_val | STRING | X |  |  |  | Số fax. |
| 11 | ip_id | STRING |  |  | F |  | FK đến Inspection Subject Other Party. |
| 12 | ip_code | STRING |  |  |  |  | Mã đối tượng thanh tra. |
| 13 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_DOI_TUONG_KHAC' | Mã hệ thống nguồn. |
| 14 | elc_adr_tp_code | STRING |  |  |  |  | Loại kênh liên lạc — số điện thoại. |
| 15 | elc_adr_val | STRING | X |  |  |  | Số điện thoại. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | insp_sbj_othr_p | insp_sbj_othr_p_id |



**Index:** N/A

**Trigger:** N/A





### Bảng ip_pst_adr



#### Từ ThanhTra.DM_CAN_BO

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Inspection Officer. |
| 2 | ip_code | STRING |  |  |  |  | Mã cán bộ thanh tra. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CAN_BO' | Mã hệ thống nguồn. |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — địa chỉ hiện tại. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ cán bộ. |
| 6 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | insp_ofcr | insp_ofcr_id |



**Index:** N/A

**Trigger:** N/A


#### Từ ThanhTra.DM_CONG_TY_DC

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Public Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty đại chúng. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CONG_TY_DC' | Mã hệ thống nguồn. |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính. |
| 6 | prov_id | STRING | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). |
| 8 | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. |
| 9 | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. |
| 10 | geo_id | STRING | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 11 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | pblc_co | pblc_co_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ ThanhTra.DM_CONG_TY_CK

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Securities Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty chứng khoán. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CONG_TY_CK' | Mã hệ thống nguồn. |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính. |
| 6 | prov_id | STRING | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). |
| 8 | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. |
| 9 | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. |
| 10 | geo_id | STRING | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 11 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | scr_co | scr_co_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ ThanhTra.DM_CONG_TY_QLQ

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Fund Management Company. |
| 2 | ip_code | STRING |  |  |  |  | Mã công ty quản lý quỹ. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_CONG_TY_QLQ' | Mã hệ thống nguồn. |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — trụ sở chính. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ trụ sở chính. |
| 6 | prov_id | STRING | X |  | F |  | FK đến tỉnh/thành phố trụ sở. |
| 7 | prov_code | STRING | X |  |  |  | Mã tỉnh/thành (provinces). |
| 8 | dstc_nm | STRING | X |  |  |  | Quận/huyện trụ sở. |
| 9 | ward_nm | STRING | X |  |  |  | Phường/xã trụ sở. |
| 10 | geo_id | STRING | X |  | F |  | FK đến tỉnh/thành phố đặt trụ sở chi nhánh. |
| 11 | geo_code | STRING | X |  |  |  | Mã tỉnh/thành phố đặt trụ sở chi nhánh. |
| 12 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | fnd_mgt_co | fnd_mgt_co_id |
| prov_id | geo | geo_id |
| geo_id | geo | geo_id |



**Index:** N/A

**Trigger:** N/A


#### Từ ThanhTra.DM_DOI_TUONG_KHAC

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
| 1 | ip_id | STRING |  |  | F |  | FK đến Inspection Subject Other Party. |
| 2 | ip_code | STRING |  |  |  |  | Mã đối tượng thanh tra. |
| 3 | src_stm_code | STRING |  |  |  | 'ThanhTra.DM_DOI_TUONG_KHAC' | Mã hệ thống nguồn. |
| 4 | adr_tp_code | STRING |  |  |  |  | Loại địa chỉ — địa chỉ liên hệ. |
| 5 | adr_val | STRING | X |  |  |  | Địa chỉ. |
| 6 | adr_dtl | STRING | X |  |  |  | Địa chỉ văn phòng đại diện. |


**Khóa chính (Primary Key):**

*Không có Primary Key.*


**Khóa phụ (Foreign Key):**

| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
| ip_id | insp_sbj_othr_p | insp_sbj_othr_p_id |



**Index:** N/A

**Trigger:** N/A





### Stored Procedure/Function

N/A

### Package

N/A
