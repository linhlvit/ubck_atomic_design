# Rà soát thiếu hụt Atomic — Dashboard phân hệ QLQ (STT 1–27)

> Ngày rà soát: 2026-10-12. Draft cần Data Modeler review trước khi gửi Atomic team/BA. Rà soát chỉ đọc — **chưa sửa HLD/LLD**.

## 1. Kết luận

- Dashboard QLQ có **173 dòng KPI** (Detail Mapping Nhóm 1–27): **68 READY, 105 PENDING**. 11 Nhóm PENDING 100% (2, 5, 8, 9, 14, 18, 19, 20, 21, 25, 27 — 47 KPI), 5 Nhóm READY 100% (10, 11, 15, 16, 23), 11 Nhóm một phần.
- **101/105 dòng PENDING là do engine báo cáo định kỳ `RPT_*` chưa dùng được trên Atomic** (`fmr_*` đã có header nhưng thiếu cột ô và trạng thái). 4 dòng còn lại: K_QLQ_97, K_QLQ_103 (thiếu junction `FUD_AG_AGT`, lỗi Atomic); K_QLQ_21, K_QLQ_143 (**không phải lỗi Atomic** — BA/nguồn, xem mục 6).
- Có **1 sai lệch mapping Atomic ↔ DDL** đang âm thầm làm hỏng KPI READY (`REPRESENT.JOBS_ID` không còn trong DDL UAT 7/10, mục 3.3).
- Có 6 KPI READY nhưng phải dùng giả định hoặc ghi chú thiết kế đã lỗi thời (mục 5).

## 2. Phương pháp và giới hạn

- Đối chiếu từng dòng BA Dashboard (`BA_analyst_QLQ.csv`, STT 1–27, cột *Bảng nguồn/Trường nguồn/Điều kiện/Câu lệnh tham khảo*) với: (a) Atomic LLD FMS `DataModel/working/Atomic/lld/FMS/` (63 bảng, 883 cột nguồn đã map); (b) DDL FMS UAT `Source/DDL UAT 1/FMS_UAT_schema.txt` (commit `da257fd8`, 7/10); (c) `pending_design.yaml`, `atomic_out_of_scope.yaml`; (d) Detail Mapping và HLD QLQ hiện hành.
- **Giới hạn:** chỉ 8/99 dòng BA dùng engine có SQL tường minh; 91 dòng còn lại BA chỉ ghi *Báo cáo/Sheet/Dòng/Cột/Trường nguồn* (SQL trống, cùng khuôn). `DataModel/Atomic/` (dm_atm yaml, `dm_manifest`) lệch `working/Atomic` (xem O_QLQ_29(4)) nên coi `working/Atomic/lld` là nguồn đúng. Không có code dev. Cột nằm trong `pending_design.yaml` (CREATED_BY, MODIFY_BY, …) không tính là thiếu.

## 3. Cột/bảng Atomic còn thiếu (cần Atomic team)

### 3.1 Engine báo cáo định kỳ `RPT_*` — chặn 99 dòng BA Dashboard (101 dòng PENDING)

| # | Nguồn (DDL UAT) | Atomic hiện có | Thiếu | BA dùng để | Mức |
|---|---|---|---|---|---|
| 1 | `RPT_VALUES.TGT_ID` RAW(16) NOT NULL | `fmr_value` (28 cột, có `cell_val`, `dynamic_row_nbr`, `fmr_sheet_id`) | **`tgt_id`** (và `code` — Dashboard không dùng, Data Explorer cần) | Nối giá trị với ô: `RPT_VALUES.TGT_ID = CELLS_META.uid` | **Bắt buộc** |
| 2 | `SHEET.DATA_LABEL`, `SHEET.CELLS_META` (NCLOB JSON) | `fmr_sheet` (có `fmr_sheet_nm`, `sheet_index`, `sheet_short_code`) | **Nhãn dòng/cột và vị trí ô** (`row`, `col`, `uid`) | Xác định ô nào là "Dòng"/"Cột" BA ghi (88/99 dòng BA có đủ Báo cáo/Sheet/Dòng/Cột, thêm 4 dòng thiếu Cột) | **Bắt buộc** — 93 dòng |
| 3 | `RPT_MEMBER.RECORD_STATUS`, `RPT_PERIOD.RECORD_STATUS`, `RPT_TEMP.RECORD_STATUS`, `SHEET.RECORD_STATUS` + 3 cột `DELETED` | `fmr_submission` chỉ có `record_tp` (= `RECORD_TYPE`); các bảng còn lại không có | **`record_status`** (hoặc ETL chỉ nạp bản ghi hiệu lực) | `RPT_MEMBER.RECORD_STATUS IN (2,3,5,10)` (báo cáo đã nộp/duyệt) là **điều kiện nghiệp vụ**, không bỏ được; `= 1` và `DELETED = 0` ở 3 bảng còn lại | **Bắt buộc** — riêng mục này mở khóa 6 KPI "Thời gian" (K_QLQ_12, 122, 126, 130, 134, 164) |
| 4 | `RPT_MEMBER.AUDIT_FIRM_ID`, `OTHER_AGENT_ID`, `PENSION_AGENT_ID`, `PENSION_FUND_ID`, `PENSION_PROVIDER_ID`, `TRANSFER_AGENT_ID` | `fmr_submission` chỉ có CTCK/quỹ/CN/ngân hàng giám sát/ĐLPP (`securities_distribution_agent_id`) | 6 FK trên | Chỉ thấy trong danh sách SELECT của CTE (kiểm `AUDIT_FIRM_ID`: 20/21 SQL xuất hiện đúng 1 lần, không thấy dùng ở kết quả) | Thấp — dev xác nhận có cần |

**Đề xuất cho #2:** Atomic không nên nạp nguyên JSON (đã phân loại JSON blob là "không phải fact số liệu structured" ở `atomic_out_of_scope.yaml`). Nên thêm entity ô đã parse từ `DATA_LABEL` × `CELLS_META`: `(fmr_sheet_id, row_nbr, col_nbr, cell_uid, label_text)` với `cell_uid` = `fmr_value.tgt_id`.

### 3.2 Junction `FUD_AG_AGT` (Quỹ ↔ Đại lý ↔ Loại đại lý) — chặn K_QLQ_97 (Nhóm 13), K_QLQ_103 (Nhóm 14)

- DDL: `FUD_AG_AGT(FUD_ID, AG_TY_ID, AGEN_ID, AGEN_ID_PARENT, SYSTEM_OBJECT_TYPE)`. BA (dòng 102, 108) lọc `LOWER(AGENCY_TYPE.ITEM_NAME) LIKE '%đại lý phân phối%'` qua `FUD_AG_AGT`.
- Atomic: bảng này ở `atomic_out_of_scope.yaml` với trạng thái **"CẦN RÀ SOÁT 2026-07-19"**; entity `cl_fms_agency_type` (FMS.AGENCY_TYPE) có nhưng **không entity nào tham chiếu** (`fund_distribution_agent` không có FK loại đại lý — O_QLQ_9). Đề xuất: bổ sung `cl_fms_agency_type_id/code` (và đại lý cấp trên `AGEN_ID_PARENT`) vào `fund_distribution_agent_x_investment_fund_relationship`, hoặc entity junction riêng.

### 3.3 Sai lệch mapping Atomic ↔ DDL — **làm hỏng KPI READY**

| Atomic | Nguồn Atomic ghi | DDL UAT 7/10 | Hệ quả |
|---|---|---|---|
| `investment_fund_representative_board_member.cl_fms_job_id/code` (`lld_FMS_REPRESENT.yaml`) | `FMS.REPRESENT.JOBS_ID` | cột là **`JOB_ID`** (FK → JOBS.ID); `JOBS_ID` không tồn tại | Chức danh thành viên BĐD không nạp được → K_QLQ_98 (đếm thành viên BĐD theo chức danh) có thể ra 0; K_QLQ_104 (danh sách) không lọc được theo chức danh như BA (dòng 109 lọc `REPRESENT.JOB_ID`). Đây là sai lệch **duy nhất** giữa 883 cột nguồn Atomic FMS và DDL (63/63 bảng nguồn Atomic đều có trong DDL) |

### 3.4 Cột nhỏ chưa map

- `STATUS.ACTIVE` (NOT NULL): BA dòng 4 ("Thời gian", Nhóm 1) và dòng 8 (K_QLQ_5) lọc `STATUS.DELETED = 0 AND STATUS.ACTIVE = 1`; `cl_fms_status` không có cột này.
- `RATING_PD.UPDATE_DATA_RATING`: `member_rating_period` không có; BA dùng cho "Thời gian" của Nhóm 3 (dòng 22).
- Giá trị phân loại vật lý (`classification_schemes.yaml` rỗng): chưa xác minh được literal `'hoạt động'` (FMS.STATUS), `'ban đại diện'`/`'ban điều hành'` (FMS.JOB_TYPE) — thiết kế đang dùng nhãn HLD tạm.
- **`DELETED`/`RECORD_STATUS` của các bảng FMS khác** không có trên Atomic (giả định ETL lọc hiệu lực, ghi ở `pending_design.yaml`). Số dòng BA Dashboard dùng: `FUNDS.DELETED` 36, `FUND_TYPE` 14, `FOR_BRCH` 11, `DISTRIBUTOR_AGENT` 9, `SECURITIES` 8, `JOBS` 6, `JOB_TYPE` 5, `AGENCIES` 5, `TL_PROFILES` 4, `STATUS`/`BANK_MONI`/`AGENCY_TYPE`/`REPRESENT`/`STF_FG_BRCH` mỗi bảng 3. Cần Atomic team xác nhận ETL đã lọc.

## 4. Tác động theo Nhóm Dashboard

| Nhóm | Tên | KPI | PENDING | Chặn bởi |
|---:|---|---:|---:|---|
| 1 | Thống kê chung | 11 | 3 | 3.1 (engine RPT) |
| 2 | Số liệu hợp đồng uỷ thác danh mục | 7 | 7 | 3.1 (engine RPT) |
| 3 | Danh sách các Công ty quản lý quỹ | 14 | 8 | BA/nguồn (mục 6), 3.1 (engine RPT) |
| 4 | Chi tiết Quỹ của một CTQLQ | 3 | 1 | 3.1 (engine RPT) |
| 5 | Chi tiết các hợp đồng UTDM của CTQLQ | 3 | 3 | 3.1 (engine RPT) |
| 6 | Thống kê chung của QĐT | 5 | 2 | 3.1 (engine RPT) |
| 7 | Biểu đồ Tổng NAV Quỹ và Tỷ lệ NAV/GDP | 6 | 3 | 3.1 (engine RPT) |
| 8 | Biểu đồ Phân bổ tài sản của Quỹ đầu tư | 7 | 7 | 3.1 (engine RPT) |
| 9 | Sự biến động về NAV của các Quỹ ĐTCK | 4 | 4 | 3.1 (engine RPT) |
| 12 | Tỉ lệ tăng trưởng NAV/CCQ một năm theo loại hình quỹ so với  | 15 | 11 | 3.1 (engine RPT) |
| 13 | Danh sách các quỹ đầu tư | 11 | 3 | 3.2 (FUD_AG_AGT), 3.1 (engine RPT) |
| 14 | Danh sách đại lý phân phối | 1 | 1 | 3.2 (FUD_AG_AGT) |
| 17 | Thống kê chung | 6 | 4 | 3.1 (engine RPT) |
| 18 | Tổng số tài khoản giao dịch chứng chỉ quỹ | 4 | 4 | 3.1 (engine RPT) |
| 19 | Số tài khoản nắm giữ chứng chỉ quỹ | 4 | 4 | 3.1 (engine RPT) |
| 20 | Giá trị chứng chỉ quỹ | 4 | 4 | 3.1 (engine RPT) |
| 21 | Giao dịch thông qua Đại lý phân phối | 3 | 3 | 3.1 (engine RPT) |
| 22 | Danh sách Đại lý phân phối | 22 | 16 | BA/nguồn (mục 6), 3.1 (engine RPT) |
| 24 | Thống kê chung | 4 | 2 | 3.1 (engine RPT) |
| 25 | Số liệu hợp đồng uỷ thác danh mục | 7 | 7 | 3.1 (engine RPT) |
| 26 | Danh sách các Chi nhánh CTQLQ nước ngoài tại Việt Nam | 8 | 5 | 3.1 (engine RPT) |
| 27 | Chi tiết hợp đồng UTQLDM | 3 | 3 | 3.1 (engine RPT) |

Nhóm READY 100%: 10, 11, 15, 16, 23 (không phụ thuộc engine).

## 5. KPI READY nhưng đang dựa giả định / ghi chú lỗi thời

| KPI | Vấn đề | Hướng xử lý |
|---|---|---|
| K_QLQ_5 (CTQLQ đang hoạt động) | Literal `'hoạt động'` chưa xác minh; `STATUS.ACTIVE` chưa map (3.4) | Atomic bổ sung giá trị scheme + `active_ind` |
| K_QLQ_98, K_QLQ_99 (số TV BĐD / người điều hành) | Literal `'ban đại diện'`/`'ban điều hành'` chưa xác minh; K_QLQ_98 còn dính 3.3 | Sửa 3.3 trước, rồi xác minh scheme `FMS_JOB_TYPE` |
| K_QLQ_2, K_QLQ_20 | Ghi chú Detail Mapping nói `FUNDS.ID_DATE`/`SECURITIES.ID_DATE` "chưa có trong Atomic — gap thật". **Ghi chú lỗi thời:** hai cột này đã map vào entity dùng chung `Involved Party Alternative Identification` (`lld_FMS_FUNDS_IP_Alt_Identification.yaml`, `lld_FMS_SECURITIES_IP_Alt_Identification.yaml`) | Cập nhật ghi chú; cân nhắc dùng `issue_dt` của IP Alt Identification cho "hiệu lực tại kỳ" |
| K_QLQ_24 (Xếp loại) | Ghi chú nói `member_rating` chưa có Rating Period. **Có vẻ lỗi thời:** `lld_FMS_RANK.yaml` đã có FK tới `member_rating_period` (có `rating_period_tp_code` = `RATING_PD.PERIOD`) | Rà lại để lọc đúng bán niên/năm như BA; `UPDATE_DATA_RATING` vẫn thiếu (3.4) |

## 6. Không phải thiếu Atomic (cần BA/nghiệp vụ)

- **K_QLQ_21 (Người đại diện theo pháp luật, Nhóm 3):** BA tự ghi *"Chưa có cách lấy đúng, đang chờ cf từ Tinh Vân"*, trạng thái Pending.
- **K_QLQ_143 (Quỹ đang phân phối, Nhóm 22):** BA chỉ ghi `FUNDS.ID` + `FUNDS.DELETED = 0`, **không có khóa nối tới ĐLPP**. DDL không có FK nào từ `FUNDS`/`AGEN_FUNDS` tới `DISTRIBUTOR_AGENT` (`AGEN_FUNDS` chỉ nối `AGENCIES`). BA cần xác nhận ĐLPP của Nhóm 22 là `AGENCIES` (khi đó `fund_distribution_agent_x_investment_fund_relationship` đã đủ) hay `DISTRIBUTOR_AGENT` (O_QLQ_10, O_QLQ_21).
- **K_QLQ_135/136 (Nhóm 21):** ngoài engine còn nghi double-count với K_QLQ_120/121 (O_QLQ_13).
- **91/99 dòng engine thiếu SQL:** kể cả khi Atomic đủ, Detail Mapping (Quy tắc L17) cần BA bổ sung SQL hoặc xác nhận cách đọc *Báo cáo/Sheet/Dòng/Cột*.
- **Nhóm 27:** thêm 2 lớp chặn phía BA (sheet lọc `s.ITEM_NAME = ''`, thiếu khóa `ROW_DYNAMIC`) — xem rà soát Nhóm 27 cùng ngày.

## 7. Phạm vi ngoài Dashboard (chỉ ghi nhận)

- Nhóm 28 (Báo cáo thống kê giao dịch nhân viên): thiếu cầu nối VSDC investor registry (O_QLQ_11). Data Explorer Nhóm 29–91: cùng engine 3.1 + BA Pending (O_QLQ_26).

## Phụ lục — KPI PENDING theo Nhóm

- Nhóm 1: K_QLQ_3, K_QLQ_4, K_QLQ_7
- Nhóm 2: K_QLQ_12, K_QLQ_13, K_QLQ_14, K_QLQ_15, K_QLQ_16, K_QLQ_17, K_QLQ_18
- Nhóm 3: K_QLQ_21, K_QLQ_22, K_QLQ_27, K_QLQ_28, K_QLQ_29, K_QLQ_30, K_QLQ_31, K_QLQ_32
- Nhóm 4: K_QLQ_35
- Nhóm 5: K_QLQ_36, K_QLQ_37, K_QLQ_38
- Nhóm 6: K_QLQ_42, K_QLQ_43
- Nhóm 7: K_QLQ_46, K_QLQ_48, K_QLQ_49
- Nhóm 8: K_QLQ_44, K_QLQ_50, K_QLQ_51, K_QLQ_52, K_QLQ_53, K_QLQ_54, K_QLQ_55
- Nhóm 9: K_QLQ_44, K_QLQ_56, K_QLQ_57, K_QLQ_58
- Nhóm 12: K_QLQ_81, K_QLQ_82, K_QLQ_83, K_QLQ_84, K_QLQ_85, K_QLQ_86, K_QLQ_87, K_QLQ_88, K_QLQ_89, K_QLQ_90, K_QLQ_91
- Nhóm 13: K_QLQ_97, K_QLQ_100, K_QLQ_102
- Nhóm 14: K_QLQ_103
- Nhóm 17: K_QLQ_118, K_QLQ_119, K_QLQ_120, K_QLQ_121
- Nhóm 18: K_QLQ_122, K_QLQ_123, K_QLQ_124, K_QLQ_125
- Nhóm 19: K_QLQ_126, K_QLQ_127, K_QLQ_128, K_QLQ_129
- Nhóm 20: K_QLQ_130, K_QLQ_131, K_QLQ_132, K_QLQ_133
- Nhóm 21: K_QLQ_134, K_QLQ_135, K_QLQ_136
- Nhóm 22: K_QLQ_143, K_QLQ_144, K_QLQ_145, K_QLQ_146, K_QLQ_147, K_QLQ_148, K_QLQ_149, K_QLQ_150, K_QLQ_151, K_QLQ_152, K_QLQ_153, K_QLQ_154, K_QLQ_155, K_QLQ_156, K_QLQ_157, K_QLQ_158
- Nhóm 24: K_QLQ_162, K_QLQ_163
- Nhóm 25: K_QLQ_164, K_QLQ_165, K_QLQ_166, K_QLQ_167, K_QLQ_168, K_QLQ_169, K_QLQ_170
- Nhóm 26: K_QLQ_174, K_QLQ_175, K_QLQ_176, K_QLQ_177, K_QLQ_178
- Nhóm 27: K_QLQ_179, K_QLQ_180, K_QLQ_181
