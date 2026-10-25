# TKNB — Chuyển 14 bảng EAV sang `item_value` (2026-10-25)

> Draft cần human review. Nguồn: `full_items.csv` (363 item, 14 báo cáo, bản 10/10/2026 — không đổi so với lần đồng bộ item-level trước) + `atomic_to_clickhouse_flow.md` (dev). Chi tiết thiết kế: `Datamart/hld/DTM_TKNB_HLD.md` Open Issue 41.

## 1. Quyết định

Data Modeler chọn 2026-10-25: **thay 14 bảng EAV theo báo cáo bằng 1 bảng `item_value`** như pipeline dev (`item_rule` → `datamart.uat_dtm.item_value` → ClickHouse `tknb_fct_{report}_snpst_flat`). Đảo quyết định Open Issue 37(5) (trước đó giữ per-report EAV).

`full_items.csv` không có item mới: 355/363 item đã đồng bộ từ 10/10; 8 item còn lại dev để `rule` rỗng. Phần thay đổi là **cấu trúc**, không phải nội dung chỉ tiêu.

## 2. Cấu trúc mới

`item_value` (entity `Report Item Value`, LLD `Datamart/lld/TKNB/DTM_TKNB_item_value.csv`):

| Cột | Kiểu | Ghi chú |
|---|---|---|
| `report_code` | string | BK — mã báo cáo (14 giá trị) |
| `report_name` | string | |
| `item_code` | string | BK — mã dev (`HNX03_1`, `BM030CMSS_03`…) |
| `item_name` | string | |
| `item_type` | string | `Co so` / `Phai sinh` / rỗng (header) |
| `calc_date` | date | BK — ngày tính, partition |
| `value` | decimal(23,2) | |
| `ds_etl_pcs_tms` | timestamp | |

14 bảng bị thay: `hnx01_stock_trading_rpt`, `hnx02_gov_bond_otc_trading_rpt`, `hnx03_derivative_trading_rpt`, `hnx06_gov_bond_bidding_rpt`, `hnx07_corp_bond_trading_rpt`, `hsx01_stock_trading_rpt`, `hsx04_proprietary_trading_rpt`, `bm030b/c/d/e/f…_rpt`, `bm031b/c…_rpt`.
Giữ nguyên 7 bảng EAV/danh sách chưa có trong pipeline dev (HNX04, HSX02, TTLK10, 0513, TK-04.BTC, TK_NienGiam, BM031d) và mọi Fact/Dimension.

## 3. Artifact đã sửa (chưa commit)

| Artifact | Thay đổi |
|---|---|
| `Datamart/lld/TKNB/DTM_TKNB_item_value.csv` | mới (8 dòng) |
| `Datamart/lld/datamart_attributes.csv` | `build_registry.py` sinh lại (+8 dòng) |
| `Datamart/datamart_model.yaml` | −14 entity EAV, +`item_value` (columns sinh bởi `build_model_yaml.py`) |
| `Datamart/hld/DTM_TKNB_Entities.csv/.md` | −14 entity, +`Report Item Value`; ghi chú thiết kế, bảng tóm tắt, nguồn Atomic |
| `Datamart/hld/DTM_TKNB_HLD.md` | 14 node Cụm Section 1; graph 3.1; bảng 3.3 + khóa nghiệp vụ + erDiagram; câu 3.4; Section 4 (ngoại lệ thứ 6); Open Issue 41; Ghi chú KPI đổi `item_code` sang mã dev |
| `Datamart/lld/DTM_TKNB_Detail_Mapping.csv` | 417 dòng trỏ `Report Item Value` (MEASURE/DERIVED→`Value`, LABEL và Chiều Loại CK/Chỉ số→`Item Name`, Chiều Sàn→`Report Code`, Chiều thời gian→`Calculation Date`, lọc nguồn→`Report Code`); sửa theo byte, giữ CRLF và 26 CR lẻ |
| `Datamart/flat-table/TKNB/01_*.sql`, `02_*.sql` | −14 flat EAV; `item_value` không có flat gộp (Data Modeler bỏ 2026-10-25) |
| `Datamart/flat-table/TKNB/03_clickhouse_per_report_flat_from_item_value.sql` | mới — 14 flat ClickHouse theo báo cáo của dev; **ngoài** luồng Gate 3/4/9 vì Gate coi mỗi flat là 1 bảng LLD |
| `Datamart/index/kpi_index.csv` | sinh lại (chỉ dòng TKNB đổi) |
| `docs/TKNB_item_code_mapping_2026-10-25.csv` | KPI → `item_code` cũ/mới/phân loại (616 KPI của 14 Nhóm) |

Công cụ dùng một lần (gitignored): `Datamart/context/tools/tknb_iv_step*.py`.

## 4. Kết quả Gate TKNB (trước → sau)

| Gate | Trước | Sau |
|---|---|---|
| Pre-flight S1 | PASS | PASS |
| Gate 0 (CRITICAL) | 760 | 343 (−417 = đúng 417 dòng DM đã đổi) |
| Gate 3 (entity mồ côi) | 42 | 15 (7 entity + 7 flat của 7 bảng EAV giữ nguyên + `item_value` Branch A thiếu flat — chủ ý) |
| Gate 4 (CRITICAL) | 108 | 25 (cùng 7 bảng EAV) |
| Gate 7 TC7 (lỗi) | 659 | 294 (cùng 7 bảng EAV) |
| Gate 8 | 0 ERROR / 25 WARNING | 0 ERROR / 25 WARNING |
| Gate 9 | WARN (kpi_index) | FAIL — chủ ý: `item_value` không có flat gộp (Data Modeler bỏ 2026-10-25), Gate đòi 1 flat/bảng LLD |
| Gate 10 S5 | 34 lỗi đã giải trình (vol×price) | 34 — không đổi |
| Số KPI HLD / dòng DM | 1297 / 1314 | 1297 / 1314 |

Gate 9 và dòng `item_value` ở Gate 3 đỏ do quyết định chủ ý (không có flat gộp; giữ ngoại lệ, không sửa whitelist Gate) — ghi ở Open Issue 41(8). Các Gate khác vẫn FAIL do nợ có từ trước, không do thay đổi này: 7 bảng EAV chưa có LLD per-table, `securities_trade` không còn trong Atomic (Gate 0 `L0-ATOMIC-COLUMN-NOT-FOUND`), 4 entity VSDC/HNX/ISS chưa YAML Atomic.

## 5. KPI chưa có item trong `item_rule` (73 KPI READY)

- **37 chiều/nhãn** (Sàn, Loại CK, Thời gian, header): không cần dòng riêng.
- **36 chỉ tiêu cần dev bổ sung vào `item_rule`** (giữ `item_code` đề xuất cũ, đánh dấu trong HLD/Detail Mapping):

| Báo cáo | KPI |
|---|---|
| TK-HNX01 | K_TKNB_3 (giá trị chỉ số) |
| HNX02 | K_TKNB_113, 117, 121, 136, 159, 163, 167 (7 KPI BA theo loại hình GD; dev chỉ có 42 item theo loại TP) |
| TK-HSX01 | K_TKNB_588, 589 (vốn hóa) và 18 dòng tổng NĐTNN: 633, 636, 640, 643, 647, 650, 654, 657, 662, 665, 669, 672, 676, 679, 683, 686, 690, 693 |
| TK-HSX04 | K_TKNB_794, 797, 801, 804, 808, 811, 815, 818 (tổng mua + bán) |

Công thức thiết kế của từng KPI nằm ở cột cuối của `docs/TKNB_item_code_mapping_2026-10-25.csv`.

- **8 item dev rule rỗng:** `HNX01_6`, `HNX01_6_01`, `HNX01_6_02`, `HNX01_9`, `HNX01_9_01`, `HNX01_9_02`, `HNX06_3_08`, `HNX06_4_09` — đã gắn cho K_TKNB_20/21/22, 47/48/108, 485/495.

## 6. Cần dev/BA xác nhận

1. `item_value` không có `item_stt`/`item_unit`/`item_order`/`note`: đơn vị và thứ tự hiển thị chỉ ở `item_rule` — BI JOIN `item_rule` hay dev thêm cột?
2. `value` DECIMAL(23,2) ở Datamart, Float64 ở ClickHouse (mất chính xác khi > 2^53).
3. Tên flat với `report_code` có dấu `-`: thiết kế giả định `TK-HNX01` → `tk_hnx01`.
4. Flat dev ở db `default`, cluster `ssc_cluster`, ReplicatedMergeTree, PARTITION BY `ds_snpst_dt` — khác quy ước repo (`datamart`, `my_cluster`, ReplacingMergeTree).
5. Báo cáo kỳ tháng (HNX06, HNX02) không có cột kỳ riêng: `calc_date` = ngày chạy kỳ tháng?
6. `Phai sinh` tính từ `Co so` cùng `calc_date`: engine phải chạy theo thứ tự phụ thuộc.
7. Các nghi vấn dev đã ghi ở Open Issue 38–40 vẫn mở (header cộng KL + GT, `IN ('10','20')`, vol×price).

## 7. Việc chưa làm

- Chưa commit (working tree còn thay đổi VP của phiên trước trong `datamart_model.yaml`, `kpi_index.csv`, `datamart_attributes.csv`, `CLAUDE.md`).
- Chưa regenerate `docs/datamart_data_source_catalog.md`, `docs/output/*` (sinh tự động, còn tên bảng EAV cũ).
- 7 bảng EAV còn lại chưa có LLD per-table; master `datamart_attributes.csv` bản làm việc không còn dòng của chúng (có từ trước khi tôi sửa; HEAD vẫn có).
