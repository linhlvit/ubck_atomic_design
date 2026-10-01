# Changelog — Cập nhật và Hoàn thiện Thiết kế Datamart GSTT Nhóm 35 (2026-10-01)

> **Ngày cập nhật:** 2026-10-01  
> **Nhánh:** `main`  
> **Phạm vi cập nhật:** Module GSTT (Giám sát thị trường) — Nhóm 35 "Sở hữu và giao dịch nội bộ" theo BA mapping lại (`BRD/BA/BA_analyst_GSTT.csv` dòng 502–513)  
> **Trạng thái kiểm tra Quality Gates:** ✅ **Gate 0 đến Gate 8 PASS 100%**  
> **Commit message:** `feat(GSTT): cap nhat thiet ke Nhom 35 (So huu va GD noi bo), bo sung entity opr_public_company_insider_ownership, dong bo 5 tang du lieu va flat table ClickHouse`

---

## 1. Bối cảnh và Mục tiêu Cập nhật

Từ phản hồi và mapping lại mới nhất của Business Analyst (BA) tại file [`BRD/BA/BA_analyst_GSTT.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/BRD/BA/BA_analyst_GSTT.csv) (dòng 502–513), phân hệ **Giám sát Thị trường (GSTT)** cần chuẩn hóa và tái cấu trúc lại **Nhóm 35 — Sở hữu và giao dịch nội bộ** để giải quyết triệt để các vấn đề:
1. **Tách biệt giữa Cổ đông lớn và Người nội bộ:** Bổ sung thực thể tác nghiệp riêng cho Người nội bộ của Công ty đại chúng thay vì gộp chung vào bảng snapshot cổ đông lớn.
2. **Chuẩn hóa tỷ lệ sở hữu:** Chuyển đổi các chỉ tiêu sở hữu nước ngoài/trong nước từ số lượng cổ phiếu sang tỷ lệ phần trăm (%), tận dụng tái sử dụng từ Fact NDTNN.
3. **Cơ chế As-of theo từng mã chứng khoán:** Đồng bộ cơ chế lọc ngày hiệu lực mới nhất (`MAX(eff_dt)`) theo từng mã chứng khoán cho danh sách cổ đông lớn.
4. **Bổ sung tên chức vụ (`position_nm`):** Đảm bảo giao diện người dùng hiển thị đúng tên chức vụ tiếng Việt từ bộ từ điển `cl_value` (nhóm `IDS_POSITION`).

---

## 2. Chi tiết Thay đổi Nghiệp vụ & Kỹ thuật

### 2.1. Bảng đối chiếu thiết kế trước và sau cập nhật

| Hạng mục | Trước cập nhật | Sau cập nhật (2026-10-01) | Ghi chú kỹ thuật |
| :--- | :--- | :--- | :--- |
| **K_GSTT_120 / K_GSTT_121** (Sở hữu nước ngoài / trong nước) | Số lượng CP (`MEASURE` / `DERIVED`) | **Tỷ lệ %** = `foreign / NULLIF(total_issued, 0) * 100` | Vai trò `DERIVED`, tính ở tầng BI từ `Fact Public Company Foreign Ownership Snapshot` |
| **K_GSTT_102 / K_GSTT_103 / K_GSTT_177** (Chọn kỳ cổ đông lớn) | Theo từng cổ đông riêng lẻ | **As-of theo từng mã**: `asof = MAX(eff_dt)` | Lọc trên bản ghi mới nhất của các cổ đông cùng mã; chỉ giữ các cổ đông có `eff_dt = asof` |
| **Tên chỉ tiêu K_GSTT_102 / K_GSTT_103** | "Tỷ lệ sở hữu", "Ngày cập nhật" | **"Tỷ lệ sở hữu của cổ đông lớn"**, **"Ngày cập nhật của cổ đông lớn"** | Làm rõ ngữ nghĩa, phân biệt với Người nội bộ |
| **K_GSTT_103b** (VSDC, lọc có chức vụ) | Trạng thái READY | **Loại bỏ (Bỏ)** | BA không còn dòng này trong file phân tích mới |
| **K_GSTT_104** (Chức vụ người nội bộ) | Khai sinh tại Nhóm 35 | **Chuyển khai sinh sang Nhóm 38** | Cột `position_code` trên Fact cổ đông lớn vẫn giữ nguyên để đảm bảo backward-compatibility |
| **Danh mục Người nội bộ** | Chưa có bảng riêng | **Thực thể Tác nghiệp mới:** `opr_public_company_insider_ownership` | Bổ sung dải KPI mới: **K_GSTT_354 đến K_GSTT_358** |

---

### 2.2. Chi tiết Thực thể mới: `opr_public_company_insider_ownership`

- **Mã thực thể:** `DTM-opr_public_company_insider_ownership`
- **Tên vật lý:** `opr_public_company_insider_ownership`
- **Loại bảng:** `Operational` (Current-state, 1 dòng / Công ty × Người nội bộ)
- **Nguồn Atomic:** 
  - Bảng driving: `pc_entity_role` (IDS.COMPANY_ENTITY_ROLE, lọc `role_tp_code = 'NNB'`)
  - Bảng liên kết: `legal_entity`, `pc_shareholding` (lấy bản ghi sở hữu mới nhất), `legal_entity_position`, `public_company`, `cl_value` (danh mục `IDS_POSITION`)
- **Danh sách cột vật lý (15 cột):**
  1. `public_company_entity_role_code` (PK)
  2. `public_company_code` (BK)
  3. `legal_entity_code` (BK)
  4. `equity_ticker_symbol` (Khóa lọc theo mã CK)
  5. `legal_entity_nm` (Tên người nội bộ)
  6. `ownership_quantity` (Số lượng CP sở hữu, `bigint`)
  7. `ownership_ratio_percentage` (Tỷ lệ % sở hữu, `decimal(5,2)`)
  8. `ownership_dt` (Ngày cập nhật sở hữu — `OWNERSHIP_DATE`)
  9. `position_code` (Mảng mã chức vụ, `array<string>`)
  10. `position_nm` (Mảng tên chức vụ tiếng Việt, `array<string>`)
  11. `src_stm_code` (Mã hệ thống nguồn = `'IDS_COMPANY_ENTITY_ROLE'`)
  12. `ds_rcrd_st` (Audit SCD4A - Record status)
  13. `ds_rcrd_isrt_dt` (Audit SCD4A - Insert date)
  14. `ds_rcrd_udt_dt` (Audit SCD4A - Update date)
  15. `ds_etl_pcs_tms` (Audit SCD4A - ETL timestamp)

---

### 2.3. Bổ sung Bảng Phẳng ClickHouse (Flat Table)

Cập nhật 2 tệp script ClickHouse Flat Table:
- **`Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql`**:
  - Bổ sung định nghĩa bảng `gstt_opr_public_company_insider_ownership_flat` (Engine = `ReplacingMergeTree(ds_etl_pcs_tms)`, `ORDER BY (public_company_code, legal_entity_code, public_company_entity_role_code)`).
- **`Datamart/flat-table/GSTT/02_populate_gstt_flat_tables.sql`**:
  - Bổ sung lệnh `INSERT INTO ... SELECT` truy vấn dữ liệu từ Datamart sang Flat Table, sử dụng hàm tối ưu của ClickHouse `groupUniqArray` để gom nhóm các chức vụ người nội bộ.

---

## 3. Danh mục Tệp Thay đổi (File Impact Analysis)

| STT | Tệp tin | Trạng thái | Nội dung thay đổi |
| :---: | :--- | :---: | :--- |
| 1 | [`BRD/BA/BA_analyst_GSTT.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/BRD/BA/BA_analyst_GSTT.csv) | Modified | Cập nhật dòng 502–513 theo mapping mới của BA |
| 2 | [`Datamart/datamart_model.yaml`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/datamart_model.yaml) | Modified | Đăng ký entity `DTM-opr_public_company_insider_ownership` |
| 3 | [`Datamart/hld/DTM_GSTT_HLD.md`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/hld/DTM_GSTT_HLD.md) | Modified | Cập nhật v4.24: Nhóm 35, Section 1 (Cụm 3a/3b), Section 3.1/3.2/3.3, Section 4 & 5 (O_GSTT_53–55) |
| 4 | [`Datamart/hld/DTM_GSTT_Entities.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/hld/DTM_GSTT_Entities.csv) | Modified | Bổ sung thực thể Operational mới, sửa FK sang `Snapshot Date Dimension Id` |
| 5 | [`Datamart/hld/DTM_GSTT_Entities.md`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/hld/DTM_GSTT_Entities.md) | Modified | Đồng bộ bảng mô tả thực thể tương ứng với file CSV |
| 6 | [`Datamart/lld/DTM_GSTT_Detail_Mapping.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/DTM_GSTT_Detail_Mapping.csv) | Modified | Nhóm 35: Mở rộng từ 11 dòng lên 14 dòng chỉ tiêu, ánh xạ K_GSTT_354–358 |
| 7 | [`Datamart/lld/GSTT/DTM_GSTT_fct_major_shareholder_ownership_snpst.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/GSTT/DTM_GSTT_fct_major_shareholder_ownership_snpst.csv) | Modified | Cập nhật `etl_logic` cho 7 cột (cơ chế as-of theo mã CK) |
| 8 | [`Datamart/lld/GSTT/DTM_GSTT_opr_public_company_insider_ownership_IDS_COMPANY_ENTITY_ROLE.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/GSTT/DTM_GSTT_opr_public_company_insider_ownership_IDS_COMPANY_ENTITY_ROLE.csv) | **New** | File LLD mapping chi tiết 15 thuộc tính của bảng tác nghiệp Người nội bộ |
| 9 | [`Datamart/lld/datamart_attributes.csv`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/lld/datamart_attributes.csv) | Modified | Bổ sung 15 thuộc tính vào từ điển thuộc tính master của Datamart |
| 10 | [`Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql) | Modified | DDL bảng `gstt_opr_public_company_insider_ownership_flat` |
| 11 | [`Datamart/flat-table/GSTT/02_populate_gstt_flat_tables.sql`](file:///c:/Workspace/Design_DW/ubck_atomic_design/Datamart/flat-table/GSTT/02_populate_gstt_flat_tables.sql) | Modified | ETL DML đổ dữ liệu cho bảng flat người nội bộ |
| 12 | [`docs/changelog_2026-10-01.md`](file:///c:/Workspace/Design_DW/ubck_atomic_design/docs/changelog_2026-10-01.md) | **New** | Nhật ký và báo cáo mô tả chi tiết toàn bộ đợt cập nhật GSTT |

---

## 4. Kết quả Kiểm định Tính Toàn vẹn (Quality Gates)

Đã chạy kiểm tra tự động toàn diện qua runner:
`python .claude/skills/datamart-review/scripts/run_quality_gates.py --module GSTT`

**Kết quả:**
- ✅ **Gate 0 — Reference Integrity:** PASS (0 Critical error)
- ✅ **Gate 1 — Role-Playing Date FK Sanity:** PASS
- ✅ **Gate 2 — Attribute & ETL Logic Parity:** PASS
- ✅ **Gate 3 — 3-Way Orphan Entity:** PASS
- ✅ **Gate 4 — Flat Table Delivery:** PASS
- ✅ **Gate 5 — HLD Structure (Bước 5B — 14 mục chuẩn):** PASS
- ✅ **Gate 6 — Context Budget (trần token):** PASS
- ✅ **Gate 7 — LLD Self-Check module-level (TC4–TC7):** PASS
- ✅ **Gate 8 — Design Lint (KPI row cells, flat comment):** PASS
- ⭐ **Overall: ALL GATES PASSED (100%)**

---

## 5. Theo dõi Câu hỏi Mở (Open Issues)

| Mã Issue | Nội dung chi tiết | Trạng thái & Hướng xử lý |
| :---: | :--- | :--- |
| **O_GSTT_53** | BA dòng 509/513 thiếu STT/Phân loại, dòng 513 thiếu Trạng thái mapping. | Đã thống nhất với Data Modeler coi là **READY** và bổ sung đầy đủ metadata trong LLD. |
| **O_GSTT_54** | Logic As-of theo mã áp dụng cho cả Nhóm 38 (`K_GSTT_178`). Cần BA đối soát lại lỗi gõ trong SQL tham khảo. | Tạm thời lấy mã đối chiếu theo tên trong lúc chờ BA chuẩn hóa tệp nguồn. |
| **O_GSTT_55** | Nguồn Atomic Nguồn 2 draft: bảng `pc_entity_role` thiếu cờ `DELETE/ACTIVE`; cần nối chức vụ thêm `pc_id`. | Đã đưa vào danh mục theo dõi đồng bộ Atomic Data Model đợt kế tiếp. |
| **O_GSTT_31** | Nhóm 35 và cấu trúc sở hữu cổ đông lớn/người nội bộ. | Đã **Resolved** phần lớn thông qua việc tách thực thể `opr_public_company_insider_ownership`. |

---

# Phần 2 — Module TT: BA cập nhật mapping + 2 yêu cầu dev (2026-10-01)

**Phạm vi:** Nhóm 1–19 (Nhóm 20 không đổi). Chưa commit.

| Nhóm | Thay đổi chính |
|---|---|
| 1, 2, 6, 7, 11, 12, 16, 17 | `COUNT(ID)` → `COUNT(DISTINCT ID)`; thêm KPI Chiều "Thời gian": K_TT_87 (STT 2), K_TT_88 (STT 7), K_TT_89 (STT 12), K_TT_90 (STT 17), K_TT_91 (STT 18) |
| 3, 8 | Bỏ nhãn 'Khác' — loại dòng tên hành vi NULL (`violation_behavior_nm` nullable ở 2 Dimension, KPI lọc `IS NOT NULL`) |
| 4 | Nhãn đối tượng 6 giá trị; `Fact Inspection Team Target Activity` driving `inspection_team` + LEFT JOIN đối tượng (FK nullable); flat LEFT JOIN |
| 5, 9, 10 | Nhãn hiển thị đối tượng (Thanh tra 6 nhãn, Kiểm tra 8 nhãn HOA); STT 9/10 vẫn INNER JOIN |
| 13 (dev #1) | Cột mới `violation_behavior_group_nm` trên `Fact Penalty Decision Subject Behavior` — QĐ nhiều hành vi đếm ở nhiều nhóm; flat cột cuối + LEFT JOIN |
| 14 | `COUNT(DISTINCT QĐ)`, `Fact Penalty Decision Subject` driving `penalty_decision` + FK đối tượng nullable, nhãn Tổ chức/Cá nhân/Khác |
| 16–18 (dev #2) | `COUNT(DISTINCT petition_id)`; `Operational Petition List` PK `petition_code` → `petition_id`; mẫu số % STT 18 = mọi loại đơn; thêm `MULTI_CONTENT` |
| 19 | Nhãn loại đơn/trạng thái; K_TT_68 'Đối tượng' **dùng TẠM** `petition.target_nm` (Data Modeler duyệt; BA chỉ định `PETITION_TARGET.TARGET_NAME` nhưng Atomic chưa có Petition Target) — cột mới `target_nm` |

Open Issue mới: O_TT_19–22. Gate 0–4, 6, 7, 8 PASS; Gate 5 (4 mục) có sẵn từ HEAD.

**Tạo lại flat (Data Modeler xác nhận):** `Datamart/flat-table/TT/00_recreate_tt_flat_tables_20261001.sql` — DROP 4 flat bị ảnh hưởng (target activity Thanh tra, penalty decision subject behavior, penalty decision subject, petition list); sau đó chạy lại CREATE/INSERT tương ứng trong 01/02. Script KHÔNG tự chạy.

## Phần 4 — PTTT: Nhóm 22–25 + K_PTTT_239/240 nâng READY theo BA SQL + cell_id

- BA STT 22–25 có SQL trên `SCMS_UAT.REPORT_INPUT_CELL_VALUE`: dư nợ margin `TS024` (BCTHHD_CTCK, kỳ THANG), VCSH `TS359` (BCTCHN) / `TS223`,`TS221` (BCTCRL), tỷ lệ vốn khả dụng `TS006` (BCTLAT).
- Reuse Case 1 Fact `fct_securities_company_financial_structure_snpst` (QLKD); Detail Mapping dùng MEASURE + FILTER `cell_id`/`rpt_code`/`rpt_period_tp_code`/`submission_status_code` (mẫu K_QLKD_105), thay khóa `indicator_code` cũ.
- READY: K_PTTT_254, 58, 197, 199, 201–208, 251–253 (Nhóm 22–25), K_PTTT_239/240 (Nhóm 32, reuse `fct_market_risk_snpst`, lặp theo chỉ số).
- Giữ PENDING: K_PTTT_198, 200 (Tổng nợ phải trả, D/E) — BA dòng 357 Pending, SQL còn schema cũ SSC_SCMS.
- Open issue mới O_PTTT_28 (cell_id trùng giữa sheet, LEGAL_BASIS, K_198/200, lặp theo chỉ số, rpt_code BCTHHD_CTCK/BCTLAT).
- Không đổi LLD/master/model.yaml/flat. Gate PTTT: 1–8 PASS trừ Gate 0 (15 warning có sẵn ở `fct_market_risk_snpst`/`fct_sector_risk_snpst`).
- Lưu ý: commit `4549dcb2` đã revert phần PTTT của `0b725a9d` → Nhóm 18 (K_171/173), Nhóm 19 (K_174–178), Nhóm 29 (K_214) đang PENDING; chưa thiết kế lại.

## Phần 5 — PTTT Nhóm 18: K_PTTT_171/173 nâng READY

- Thêm 2 cột vào `fct_corporate_bond_market_snpst`: `bond_trading_val` (SUM `securities_trade.execution_val`, `market_id_code = 'BDO'`, HOSE + HNX) và `bond_yield_weighted_average` (Σ(YTMi × GTGDi)/ΣGTGDi, YTMi = `security_trading_snapshot.yield`, floorcode '06', bản ghi cuối ngày, INNER JOIN như SQL BA dòng 305).
- Không cần entity `Corporate Bond Match Log`. Đồng bộ LLD, master, `model.yaml`, flat 01/02, HLD Nhóm 18, Detail Mapping, Entities.csv. Open issue O_PTTT_29 (khóa nối mã TP HNX Issue_Code, execution_val HNX).
- Gate PTTT: 1–8 PASS trừ Gate 0 (15 warning có sẵn). Analyzer Nhóm 18 Δ = 0.

## Phần 6 — PTTT Nhóm 19: K_PTTT_174/175/176/178 nâng READY (2 luồng)

- `fct_corporate_bond_maturity_wall` mở rộng 2 luồng bằng `bond_flow_code` (LISTED/PRIVATE) + `bond_code`; thêm `par_val`, `outstanding_vol`, `bond_outstanding_val`, `maturity_dt`; `securities_dim_id` nullable (chỉ LISTED). Ngày chốt quý: LISTED = ngày GD cuối quý, PRIVATE = cuối tháng của quý (BA dòng 322).
- Luồng PRIVATE lấy từ `private_corp_bond_offering` (HNX BM29, VSDC mapping md Bảng 15). K_PTTT_178 = SUM(bond_outstanding_val) WHERE ranking_code IN (:nguong_xep_hang_thap) AND maturity_dt trong kỳ xét (FILTER trong Detail Mapping).
- Đồng bộ LLD, master, model.yaml, flat 01/02 (ORDER BY đổi sang bond_flow_code, bond_code), HLD Nhóm 19 + Section 3/4/5, Detail Mapping, Entities.csv/.md. O_PTTT_7 đóng; mở O_PTTT_30 (nối DN ↔ xếp hạng, ngưỡng xếp hạng thấp, src_stm_code giả định, offering vs outstanding).
- Gate PTTT 1–8 PASS; Gate 0 thêm 1 warning (`private_corp_bond_offering` chưa có YAML Atomic, chỉ có mapping md).

## Phần 7 — PTTT: rà từng dòng các Nhóm lệch số lượng BA ↔ HLD

- Đối chiếu từng dòng BA ↔ KPI HLD cho Nhóm 1, 2, 4, 5, 7, 8, 9, 10, 12, 14, 15, 20, 21, 27, 31, 34: không phát hiện KPI thiếu; các dòng "không ghép được" đều là dòng BA Trùng/cùng nghĩa với KPI đã có (reuse), HLD dư KPI là KPI trung gian (β hồi quy Nhóm 1, tử/mẫu của tỷ lệ).
- Sửa ghi chú cũ: Nhóm 12/13/14 ghi "BA còn Pending" nhưng BA đã Done 100% (dòng 241–250 / 251–265 / 266–277); Nhóm 14 trích dẫn dòng BA lệch 1 (K_135/138/145/146/147); Nhóm 5/7/15/33 trích dẫn dòng đầu Nhóm lệch 1. Cập nhật O_PTTT_23/24/25.
- Còn mở: Nhóm 31 BA ghi GTGD mua/bán NĐTNN, Tự doanh (dòng 418–421) nhưng KPI K_221/222/224/225 là KLGD (O_PTTT_18); Nhóm 28 tương tự (S5).

## Phần 8 — PTTT Nhóm 29: K_PTTT_214 (OI VN100) nâng READY

- Dùng lại cột `open_interest_quantity` của `Fact Futures Intraday Snapshot` (đã có từ Nhóm 26), `underlying_symbol = 'VN100'`; nguồn Atomic `end_of_day_open_interest` (VSDC mapping md Bảng 6). BA dòng 408 Done.
- Open issue O_PTTT_31: BA Nhóm 29 lọc `StockType = '4'` còn Nhóm 26/27 dùng `'FU'`. Gate PTTT 1–8 PASS; analyzer Nhóm 29 Δ = 0.

## Phần 9 — PTTT Nhóm 26–31: loại CK hợp đồng tương lai 'FU' → '4'

- Data Modeler chốt dùng `stock_tp_code = '4'` thay `'FU'` (khớp BA Nhóm 29). Đổi đồng loạt vì `fct_futures_intraday_snpst` / `fct_futures_investor_flow_snpst` dùng chung Nhóm 26–31: LLD (4 chỗ), master (4 dòng), HLD (18 chỗ), Section 3. Không đổi `security_trading_snpst_dim` (GSTT). O_PTTT_31 đóng.

## Phần 10 — PTTT Nhóm 22: K_PTTT_198/200 READY (hết KPI PENDING của PTTT)

- Theo chỉ đạo dùng mapping BA dòng 339 Nhóm 21: Fact mới `fct_securities_company_balance_snpst` (grain 1 CTCK niêm yết × quý, IDS BCDKT row 300/400 nợ phải trả, 400/500 VCSH; nối `securities_company.securities_code = public_company.equity_ticker_symbol`). K_PTTT_198 = Σ nợ phải trả quý gần nhất; K_PTTT_200 = Σ nợ / Σ VCSH cùng tập CTCK (không dùng VCSH SCMS K_PTTT_197).
- Đồng bộ LLD mới, master, model.yaml, flat 01/02 (mục 15), Entities.csv/.md, HLD Nhóm 22 + Section 3/4/5, Detail Mapping. O_PTTT_32 (chỉ phủ CTCK niêm yết, khớp mã, đơn vị VND). Gate PTTT 1–8 PASS.
