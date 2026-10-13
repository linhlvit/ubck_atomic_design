# QLKD — Trường lấy từ JSON trong BA hiện hành mà Atomic chưa thiết kế

Ngày khảo sát: 13/10/2026. **Draft cần human review.** Chưa sửa HLD/LLD/DM/yaml/Atomic nào.

## 1. Phạm vi và phương pháp

- BA: `BRD/BA/BA_analyst_QLKD.csv` hiện hành (md5 `22fceeef25e24f239c288f21d397572a`, 4.622.243 byte, delimiter `,`, 27 cột, 8.160 dòng BA, 178 STT). Không đọc `Old versions/`.
- Trích JSON bằng cách quét cột `Trường nguồn` + `Câu lệnh tham khảo (SIT)`: mọi `JSON_TABLE(...)` (15 khối khác nhau) và `JSON_VALUE(...)` (23 path). 316/543 ô SQL tham khảo có JSON.
- Atomic: tra đủ 4 lớp theo bảng nguồn (`DataModel/Atomic/*/dm_atm_*.yaml`, `working/Atomic/lld/**`, `lld/manifest.yaml`, `hld/atomic_entities.yaml` + `aggregate/atomic_attributes.yaml`). Commit Atomic gần nhất: `ff7d9ac4` (12/10/2026). Không dùng `atomic_out_of_scope.yaml` làm bằng chứng.

## 2. Kết quả tổng

BA đọc JSON từ **6 cột nguồn** với **60 đường dẫn JSON**. **0/60** có thuộc tính Atomic đã parse tương ứng (chi tiết mục 3).

| # | Cột JSON nguồn | Số path | STT dùng | Dòng BA (STT có dùng) | Atomic entity | Tình trạng Atomic |
|---|---|---|---|---|---|---|
| A | `FORM_REPORT_DEEP_CONFIG.SHEETS_JSON` | 5 | 150 STT: 1, 8–9, 11–12, 14–16, 18–31, 48–145, 148–173, 175–178 | 7.735 | `sc_report_deep_config` (draft) | Cột `sheet_id`/`sheet_code` có tên nhưng **mapping sai nguồn** (mục 4-R1); còn lại thiếu |
| B | `FORM_SHEET_CELL.FORMULA` | 11 | 48, 49, 50, 51, 126 | 190 | `sc_report_sheet_cell` (draft) | **Không có** `FORMULA`/`FORMULA_TEXT`/`SUM_FORMULA` |
| C | `SC_FIRM_PROFILE_CHANGE.AFTER_DATA_JSON` | 23 | 48, 49, 50, 51 | 152 | `sc_profile_change` (draft) | **Loại trừ có chủ đích** ("JSON → EXCLUDED") |
| D1 | `DISCLOSURE_SECURITIES_OFFERING.PLAN_JSON` | 10 | 13 (1 path), 45, 46 | 89 | `sc_disclosure_securities_offering` (dm yaml) | **Loại trừ** |
| D2 | `…RESULT_JSON` | 2 | 45, 46 | 82 | cùng entity | **Loại trừ** |
| D3 | `…CAPITAL_USE_RESULT_JSON` | 9 | 45, 46 | 82 | cùng entity | **Loại trừ** |

Hợp các STT có dùng JSON: 153/178 STT, 7.824/8.160 dòng BA (con số dòng là cả STT có ít nhất 1 dòng dùng JSON, không phải riêng dòng chứa JSON). Trạng thái BA của các dòng này: Done 7.462, Pending 318, trống 44.

## 3. Danh sách trường JSON và tình trạng Atomic

### A. `FORM_REPORT_DEEP_CONFIG.SHEETS_JSON` (`$[*]`)

| Path | BA đặt tên | BA dùng để | Atomic | Ghi chú |
|---|---|---|---|---|
| `$.sheetId` | `sheetId` | nối `REPORT_INPUT_CELL_VALUE.SHEET_ID IN (...)` ở dashboard STT 1, 8–9, 11–12, 14–16, 18–31 | ✗ | `sc_report_input_value.sheet_id` có, nhưng không có bên kia của phép nối |
| `$.sheetCode` | `sheetCode` | chọn sheet theo mã (vd `06620`, `II.8`, `TTC_Q`); chiều Mã sheet Data Explorer | ✗ trong deep_config; ứng viên `sc_report_sheet.sheet_code` | chưa chứng minh JSON `sheetCode` = `FORM_SHEET.SHEET_CODE` |
| `$.sheetName` | `sheetName` | chiều Tên sheet (STT 48–178, 129 ô SQL) | ✗ trong deep_config; ứng viên `sc_report_sheet.sheet_nm` | như trên |
| `$.kyApDung` (mảng JSON) | `ky_ap_dung` | chiều **Kỳ báo cáo** theo sheet (Data Explorer) | ✗ | không có ở entity nào |
| `$.cellCriteria[*].cellId` (NESTED) | `cellId` | STT 29, 30: danh sách ô tiêu chí nghiệp vụ (`TS107/111/115/119`…) | ✗ | |

### B. `FORM_SHEET_CELL.FORMULA` (`$.forMulaObjectInfos[0].…`)

`key`, `memberProfileType`, `fieldOfMember`, `suVuId`, `rptId`, `sheetId`, `cellsMeta.catalogCellId`, `cellsMeta.sectionId`, `loaiDuLieuBc`, `bangDuLieuBc`, `cotDuLieuBc` — **11 path, đều ✗**. STT 48 chỉ dùng 6 path (`key`, `memberProfileType`, `fieldOfMember`, `loaiDuLieuBc`, `bangDuLieuBc`, `cotDuLieuBc`); STT 49/50/51/126 dùng đủ 11 (cùng `FSS.SCMS_MAP_CT` để ra `ROW_NAME`/`COLUMN_NAME`). Đây là A1 của báo cáo 12/10, nay đã định lượng theo path.

### C. `SC_FIRM_PROFILE_CHANGE.AFTER_DATA_JSON` — 23 path, đều ✗

| Đối tượng (BA lọc `ENTITY_TYPE`) | STT | Path (số lượng) |
|---|---|---|
| `CN` (chi nhánh) | 48 | `id`, `tenCtck`, `tenDayDu`, `diaChi`, `dienThoai`, `giamDoc`, `nganhNgheKinhDoanh`, `tenTrangThaiChiNhanh`, `nghiepVuUyQuyenSelected[*].label` (9) |
| `PGD` (phòng giao dịch) | 48 | `id`, `tenCtck`, `tenDayDu`, `diaChi`, `tenTinhThanh`, `ctckChiNhanhTen`, `tenTrangThaiPgd`, `nghiepVuHoTro` (8) |
| `TRU_SO_CHINH` (CTCK) | 49, 50 (`EVENT_TYPE_NAME = 'Đăng ký kinh doanh chứng khoán phái sinh'`), 51 | `tenTiengViet`, `diaChi`, `dienThoai`, `soGpTlhdLanDau`, `ngayCapGpTlhdLanDau`, `maCongTy`, `sanNiemYet`, `maChungKhoan`, `vonDieuLe`, `website`, `tenTrangThai`, `nganhNgheKinhDoanh` (12, STT 51); thêm `nganhNgheKinhDoanhPhaiSinh` (13, STT 49/50) |

Ghi chú: `soVanBan` còn liệt kê ở cột `Trường nguồn` STT 49–51 nhưng SQL đã chuyển sang `LICENSE_DECISION_DOC_NUMBER` (= `document_reference_nbr`, Data Modeler xác nhận 08/10) → không còn là trường JSON.

Bản scalar gần nghĩa ở Atomic (hiện hành, **không phải** snapshot sau thay đổi như `AFTER_DATA_JSON`; chưa chứng minh tương đương): `securities_company` (`sc_nm`, `sc_code`, `listing_exchange_code`, `securities_code`, `charter_capital_amt`, `business_lines`, `cl_firm_status_*`), `sc_organization_unit` (`ou_nm`, `director_nm`, `business_lines`, `cl_firm_status_*`, `parent_ou_*`), `ip_postal_address`, `ip_electronic_address`. **Không thấy bản scalar** cho: `soGpTlhdLanDau`, `ngayCapGpTlhdLanDau` (chưa kiểm `ip_alternative_identification`), `nganhNgheKinhDoanhPhaiSinh`, `nghiepVuUyQuyenSelected`, `nghiepVuHoTro`.

### D. `DISCLOSURE_SECURITIES_OFFERING` — 21 path, đều ✗

| Cột JSON | Path | Ứng viên scalar trong `sc_disclosure_securities_offering` (chưa chứng minh) |
|---|---|---|
| `PLAN_JSON` `$[*]` | `loaiChaoBan` | `offering_method` — nguồn SCMS chỉ có 42/532 dòng, luôn khớp khi có (đối chiếu 12/10) → **không đủ** |
| | `doiTuongChaoBan` | `target_investors` |
| | `soLuongCb` | `offered_quantity` / `total_offered_quantity` |
| | `giaCb` | `offering_price_amt` |
| | `duKienTuNgay`, `duKienDenNgay` | `expected_start_dt`, `expected_end_dt` |
| | `giaTriCbTheoMenhGia`, `soLuongNguoiCb`, `mucDichHoanDoi`, `moTaDoiTuong` | không thấy |
| `RESULT_JSON` `$[*]` | `soLuongThucTe` | `total_offered_completed` |
| | `giaTriThucTe` | `proceeds_collected_amt` — Atomic chỉ 2/84 dòng có giá trị (12/10) |
| `CAPITAL_USE_RESULT_JSON` `$[*]` | `boSungVonMgck`, `boSungVonTuDoanh`, `boSungVonBaoLanhPh`, `boSungVonTuVanDauTu`, `boSungVonVayMargin`, `boSungVonUngTruoc`, `suDungMucDichKhac`, `mucDichCuThe`, `soTienMucDichKhac` | không thấy (9/9) |

BA lấy `RESULT_JSON`/`CAPITAL_USE_RESULT_JSON` theo `SUM`/`CROSS JOIN JSON_TABLE` nên là mảng nhiều phần tử mỗi đợt → cần entity con, không nhét được vào 1 cột scalar.

## 4. Phát hiện kèm theo

- **R1 — `sc_report_deep_config.sheet_id`/`sheet_code` mapping sang cột nguồn không tồn tại.** Aggregate ghi `source_column = SCMS.FORM_REPORT_DEEP_CONFIG.SHEET_ID` / `SHEET_CODE`; BRD `brd_SCMS_FORM_REPORT_DEEP_CONFIG.yaml` chỉ có `ID`, `FORM_REPORT_ID`, `EFORM_SCHEMA_JSON`, `EXCEL_CONFIG_JSON`, `SHEETS_JSON`, `EFORM_RUNTIME_MANIFEST_JSON`, `CREATED_AT`, `LAST_MODIFIED_AT`. Mô tả "FK -> FORM_SHEET" mâu thuẫn với comment "Nguồn NCLOB — lưu nguyên dạng text". Manifest trỏ `lld_SCMS_FORM_REPORT_DEEP_CONFIG.yaml` (không tồn tại). Hệ quả: ETL không thể nạp 2 cột này theo thiết kế hiện tại.
- **R2 — `sc_report_sheet_cell`:** `notes` nói "kèm… công thức tính toán" nhưng danh sách `source_columns` không có `FORMULA`, `FORMULA_TEXT`, `SUM_FORMULA`.
- **R3 — `SCMS_PROFILE_CHANGE_ENTITY_TYPE` lệch BA:** scheme Atomic có `CTCK/CHI_NHANH/PHONG_GIAO_DICH/VPDD/NHAN_SU/CO_DONG` (source_value trùng code), BA lọc `CN`, `PGD`, `TRU_SO_CHINH`. Cần xác nhận giá trị thật ở `SC_FIRM_PROFILE_CHANGE.ENTITY_TYPE`; nếu BA đúng thì scheme sai và `profile_change_entity_tp_code` không lọc được theo BA.
- **R4 — 3 entity (`sc_report_deep_config`, `sc_report_sheet_cell`, `sc_profile_change`) mới ở lớp working/hld/aggregate (draft)**, chưa có trong `dm_manifest.yaml` và `DataModel/Atomic/*/dm_atm_*.yaml`.
- **R5 — Hệ quả phía Datamart (đã biết, nay có nguyên nhân cụ thể):** `opr_securities_company_financial_report_hist` / `report_indicator_dim` chọn ô chỉ theo `cell_id` (vd `IN ('KQ001','DT001')`), không lọc `sheet` — vì không có cầu `sheetId`↔`sheetCode`. BA lọc theo sheet qua JSON → rủi ro cộng lẫn sheet (đã ghi ở O_QLKD_34 cho Nhóm 19, nhưng áp dụng cho các dashboard đọc ô qua 2 bảng này).
- Ghi chú lỗi thời: HLD O_QLKD_35 vẫn ghi `FORM_REPORT_DEEP_CONFIG` "ngoài scope" — lỗi thời (đã có entity, nhưng mapping sai như R1).

## 5. Tác động lên Datamart (theo HLD hiện hành)

| Nhóm | KPI | Hiện trạng | Phụ thuộc JSON |
|---|---|---|---|
| STT 45–46 | K_QLKD_5000–5081 (82) | PENDING toàn bộ (O_QLKD_36) | D1–D3 |
| STT 13 | K_QLKD_66–72 (7) | READY theo cấu trúc, phân loại tạm bằng `offering_method` (O_QLKD_39) | D1 (`loaiChaoBan`) |
| STT 48–51 | K_QLKD_5093–5244 (152) | 45 READY (chiều cấu trúc) / 107 PENDING | B, C (+A) |
| STT 126 (NPF) | K_QLKD_9603–9640 (38) | 9 READY / 29 PENDING | B (+A) |
| Data Explorer còn lại, dashboard 1–31 | K_QLKD_5000–13040 | 6.977 PENDING chưa nối (O_QLKD_35) / dashboard thiếu bridge sheet | A, B |

## 6. Việc cần kiểm trên nguồn Oracle (chưa chạy — Vuong chạy được)

```sql
-- Q1: JSON sheetId có trùng FORM_SHEET.ID, sheetCode/sheetName có trùng FORM_SHEET không?
SELECT COUNT(*) AS n_json_sheet,
       COUNT(fs.ID) AS match_by_id,
       SUM(CASE WHEN fs.SHEET_CODE = jt.sheetCode THEN 1 ELSE 0 END) AS match_code,
       SUM(CASE WHEN fs.SHEET_NAME = jt.sheetName THEN 1 ELSE 0 END) AS match_name
FROM FORM_REPORT_DEEP_CONFIG dc
CROSS JOIN JSON_TABLE(dc.SHEETS_JSON, '$[*]' COLUMNS (
    sheetId VARCHAR2(200) PATH '$.sheetId',
    sheetCode VARCHAR2(100) PATH '$.sheetCode',
    sheetName VARCHAR2(500) PATH '$.sheetName')) jt
LEFT JOIN FORM_SHEET fs ON TO_CHAR(fs.ID) = jt.sheetId AND fs.FORM_REPORT_ID = dc.FORM_REPORT_ID;

-- Q2: REPORT_INPUT_CELL_VALUE.SHEET_ID có khớp FORM_SHEET.ID không?
SELECT COUNT(*) AS n_cell, COUNT(fs.ID) AS match_form_sheet
FROM REPORT_INPUT_CELL_VALUE civ
LEFT JOIN FORM_SHEET fs ON TO_CHAR(fs.ID) = civ.SHEET_ID;

-- Q3: kyApDung có những giá trị nào?
SELECT jt.ky, COUNT(*) FROM FORM_REPORT_DEEP_CONFIG dc
CROSS JOIN JSON_TABLE(dc.SHEETS_JSON, '$[*]' COLUMNS (ky VARCHAR2(2000) FORMAT JSON PATH '$.kyApDung')) jt
GROUP BY jt.ky ORDER BY 2 DESC;

-- Q4: ENTITY_TYPE thực tế ở SC_FIRM_PROFILE_CHANGE
SELECT ENTITY_TYPE, EVENT_TYPE_NAME, COUNT(*) FROM SC_FIRM_PROFILE_CHANGE GROUP BY ENTITY_TYPE, EVENT_TYPE_NAME ORDER BY 3 DESC;

-- Q5: FORMULA có luôn là JSON hợp lệ với forMulaObjectInfos[0] không?
SELECT COUNT(*) AS n, COUNT(FORMULA) AS n_formula,
       SUM(CASE WHEN JSON_EXISTS(FORMULA, '$.forMulaObjectInfos[0]') THEN 1 ELSE 0 END) AS n_obj0
FROM FORM_SHEET_CELL;
```

Nếu Q1 cho `match_by_id` = `n_json_sheet` và `match_code`/`match_name` đầy đủ thì 3/5 path của nhóm A (`sheetId`, `sheetCode`, `sheetName`) suy ra được từ `sc_report_sheet` mà không cần parse JSON (chỉ còn `kyApDung`, `cellCriteria`).

## 7. Đề xuất cho Atomic (Data Modeler quyết định)

1. **A:** sửa R1; thêm entity con `sc_report_deep_config` × sheet (grain 1 dòng/sheet: `sheet_id`, `sheet_code`, `sheet_nm`, `applicable_period`) + bảng ô tiêu chí (`cell_id`) — hoặc, nếu Q1 khớp, chỉ cần `kyApDung` và `cellCriteria`.
2. **B:** thêm vào `sc_report_sheet_cell` các cột công thức (`formula_text`, hoặc 11 cột đã parse từ `forMulaObjectInfos[0]`) + entity cho `SCMS_MAP_CT` (đã ở A1 báo cáo 12/10).
3. **C:** `AFTER_DATA_JSON` khác key theo `ENTITY_TYPE` → hợp lý nhất là lưu nguyên văn dạng text/JSON ở `sc_profile_change` (đảo quy ước "JSON excluded"), hoặc entity con key–value; sửa scheme R3.
4. **D:** 3 entity con theo đợt (plan / result / capital-use result), cùng pattern `pc_securities_offering_plan` / `pc_securities_offering_result` đã có cho nguồn IDS; thêm `created_tms` và mã `loaiChaoBan` (A2 báo cáo 12/10).
