# GSTT — Đề xuất tách nhỏ tầng flat theo logic "buffer theo ngày"

> **CẬP NHẬT 2026-10-17 (sau phản hồi của Data Modeler): KHÔNG gộp — áp dụng 46 bảng, mỗi template một bảng.** Mục 10 là thiết kế áp dụng; SQL đã sinh tại `Datamart/flat-table/GSTT/buffer/`. Mục 4–5 (phương án 5 bảng gộp) giữ lại để tham khảo, **không áp dụng**.


> **Trạng thái: bản nháp cần Data Modeler duyệt.** Chưa sửa LLD / HLD / Entities / 18 flat hiện có. Đã thêm 2 file SQL buffer mới (mục 10), chưa chạy thử.
> Nguồn: `C:\Users\ADMIN\Downloads\buffer_chart_templates_v4.sql` (46 buffer tự tách + 5 template thủ công + 6 template không tham số ngày) đối chiếu `Datamart/flat-table/GSTT/01_create_gstt_flat_tables.sql` (18 bảng).
> Mọi con số do script đếm từ 2 file trên. Chỗ **chưa chạy thử trên ClickHouse** đánh dấu ⚠ (máy này không có ClickHouse).

## 1. Kết luận

- 46 buffer của file tham chiếu chỉ có **12 hình dạng** (mục 3.1). 36 buffer đọc từ hub `gstt_fct_stock_portfolio_snpst_flat` (112 cột) nhưng mỗi buffer `SELECT *` chép đủ 112 cột, trong khi toàn bộ template chỉ đọc tối đa 61/112 cột hub (51 cột không template nào đọc).
- Đề xuất: **5 bảng buffer vật lý** (B1–B5) + 1 view (heat-map) + 7 template đọc thẳng flat nguồn (bản sao 1:1, không cần bảng). Khác file tham chiếu ở 3 điểm: (a) gộp theo *universe + grain*, không theo từng template; (b) danh sách cột tường minh thay `SELECT *`; (c) cột dẫn xuất định nghĩa **1 lần**.
- Số cột chép mỗi ngày (đếm cột × bảng, chưa nhân số dòng) của nhóm hub: **~4.514 → ~175** (−96%).
- Trước khi áp dụng cần chốt 5 quyết định (mục 8) và xử lý các lỗi của file tham chiếu (mục 6) — **18 template bước 2 nhiều khả năng không chạy được nếu giữ nguyên** (⚠ chưa chạy thử).

## 2. Logic của file tham chiếu — phần giữ lại

| # | Quy tắc | Giữ / đổi |
|---|---|---|
| L1 | 1 buffer = 1 grain + 1 nguồn chính; bảng thứ 2/3 trong SQL chart đọc thẳng nguồn | Giữ |
| L2 | **Lọc tĩnh** (universe, khung giờ) đẩy vào buffer; **lọc động** (symbol, rổ chỉ số, sàn, loại CK, khoảng ngày) ở truy vấn | Giữ |
| L3 | Cột nghiệp vụ dẫn xuất theo dòng (34 cột `[CỘT MỚI]`) tính ở buffer, không tính trong SQL chart | Giữ, nhưng định nghĩa 1 lần (mục 4.3) |
| L4 | Nạp tăng dần theo ngày, idempotent: xoá `cdr_dt = ngày` rồi `INSERT`; backfill chạy lại không trùng | Giữ — dùng `DELETE FROM` nhẹ như flat hiện tại thay `ALTER…DELETE` |
| L5 | `PARTITION BY toYYYYMM(cdr_dt)` | Giữ; thêm `ORDER BY` theo kiểu truy cập (file gốc dùng `tuple()` nên không cắt được granule) |
| L6 | Pre-join hub × rổ chỉ số khi nhiều chart cần | Giữ nhưng join **một lần** (B2), không 18 lần |

## 3. Đo hiện trạng

### 3.1 46 buffer → 12 hình dạng

| Hình dạng | Mô tả | Số buffer | Nguồn |
|---|---|---:|---|
| S1 | Cổ phiếu/CCQ/CW (loại trái phiếu + phái sinh), không join rổ | 12 | hub |
| S2 | như S1 nhưng không loại sàn 03 (top-giảm-giá / top-tăng-giá theo sàn) | 2 | hub |
| S3 | S1 + LEFT JOIN rổ chỉ số (`s.*, b.*`) | 11 | hub ⨝ rổ |
| S4 | S2 + LEFT JOIN rổ chỉ số (6 template "theo-san") | 6 | hub ⨝ rổ |
| S5 | Trái phiếu (`stock_tp_code=1`) | 2 | hub |
| S6 | Phái sinh (`floor_code=03`) | 1 | hub |
| S7 | Heat-map (sàn 10/02/04 + có công ty/CTCK) | 1 | hub |
| S8 | dinh-gia (rổ ⨝ hub, INNER) | 1 | rổ ⨝ hub |
| S9 | Bản sao 1:1 + 1 cột tỷ lệ từ bảng rổ chỉ số | 2 | rổ |
| S10 | Bản sao 1:1 (chỉ lọc ngày) từ flat khác — chi-so-eod/history, phan-loai-ndt(-index), co-dong-lon | 5 | flat khác |
| S11 | Bản sao + lọc khung giờ (chi-so-realtime) / lọc ngày nghỉ (ngay-nghi) | 2 | flat khác |
| S12 | Nến phút NN + universe cổ phiếu + khung giờ 09:00–14:45 | 1 | foreign_min |

Universe chuẩn hoá (dùng lại ở mục 4):

| Mã | Điều kiện | Ngữ nghĩa theo LLD `stock_tp_nm` |
|---|---|---|
| `U_EQ` | `NOT ((floor_code='02' AND stock_tp_code IN ('1','4')) OR (floor_code='10' AND stock_tp_code='1')) AND floor_code != '03'` | loại trái phiếu HOSE/HNX + phái sinh HNX + sàn 03; còn cổ phiếu, CCQ/ETF, chứng quyền |
| `U_BOND` | `stock_tp_code='1' AND floor_code IN ('04','10','03','02')` | trái phiếu (xem câu hỏi Q4) |
| `U_DER` | `floor_code='03'` | phái sinh (FDS) |

### 3.2 Cột thực sự cần

Đếm token trong SQL bước 2 + biểu thức dẫn xuất + mệnh đề WHERE của buffer (cận trên, có thể thừa vài cột trùng tên alias).

| Nhóm | Template | Cột hub cần / 112 | Cột rổ cần / 27 | Cột dẫn xuất |
|---|---:|---:|---:|---:|
| B1 equity | 14 | 47 | 0 | 14 |
| B2 equity×rổ | 20 | 33 | 9 | 18 |
| B3 trái phiếu | 2 | 22 | 0 | 2 |
| B4 phái sinh | 1 | 18 | 0 | 0 |
| heat-map | 1 | 19 | 0 | 0 |

**51 cột hub không template nào đọc** (vẫn bị chép vào 36 buffer): `security_trading_snpst_dim_id`, `snpst_dt_dim_id`, `fr_period_end_dt_dim_id`, `revenue`, `foreign_buy_derivative_vol`, `foreign_sell_derivative_vol`, `fr_period_end_dt`, `fct_high_price`, `fct_low_price`, `fct_reference_price`, `prior_market_cap`, `prior_free_float_market_cap`, `is_trading_date`, `isin_code`, `last_trading_dt`, `issue_dt`, `fund_tp_code`, `covered_warrant_tp_code`, `exercise_price`, `exercise_ratio`, `exercise_style_code`, `put_or_call_code`, `contract_multiplier`, `maturity_month_year`, `security_trading_snpst_src_stm_code`, `public_company_code`, `equity_ticker_symbol`, `public_company_nm`, `equity_listing_exchange_code`, `business_line_level_1_code`, `ids_registration_dt`, `public_company_status_code`, `public_company_english_nm`, `enterprise_tp_code`, `public_company_tp_code`, `head_office_province_nm`, `operating_status_code`, `has_state_ownership_indicator`, `charter_capital_amt`, `first_registration_dt`, `latest_registration_dt`, `latest_registration_province_nm`, `ids_registration_indicator`, `public_company_form_code`, `former_state_owned_indicator`, `foreign_direct_investment_indicator`, `has_parent_company_indicator`, `has_subsidiary_indicator`, `has_joint_venture_indicator`, `ipo_company_indicator`, `public_company_src_stm_code`.

**Cột dẫn xuất:** 0/34 cột được bước 2 của template nào đó dùng (không cột nào) — 34 cột chỉ mới được thêm vào buffer, chưa chart nào đọc (xem Q2).

## 4. Thiết kế đề xuất

### 4.1 Quy ước chung (cho cả 5 bảng)

| Hạng mục | Đề xuất | Lý do / khác file tham chiếu |
|---|---|---|
| Tên | `mart.buffer_gstt_<slice>` | Có tiền tố module, tránh đụng buffer của QLKD/NDTNN |
| Engine | `ReplicatedMergeTree()` `ON CLUSTER 'my_cluster'` | Khớp flat hiện tại; file gốc dùng `MergeTree` thường ⚠ (Q3) |
| Partition | `toYYYYMM(cdr_dt)` | Giữ |
| Order by | xem từng bảng | File gốc `tuple()` |
| Cột khoá | `cdr_dt`, `symbol`, `index_code` **không Nullable** (`ifNull(...,'')` khi nạp) | Tránh `assumeNotNull` trong khoá như flat hiện tại |
| Nạp ngày | `DELETE FROM … WHERE cdr_dt = :etl_date` rồi `INSERT … SELECT` | Cùng mẫu flat; tham số `:etl_date` theo quy ước repo (job BI đang dùng `{ngay:Date}` — Q3) |
| Join | `SETTINGS join_use_nulls = 1` khi LEFT JOIN rổ | Kết quả không phụ thuộc cấu hình server |
| Cột | liệt kê tường minh, không `SELECT *` / `s.*, b.*` | File gốc còn trùng 3 tên cột sau `EXCEPT (cdr_dt, symbol)` (mục 6, P2) |
| Chia số | `toFloat64(a) / nullIf(toFloat64(b), 0)` | ⚠ mục 6, P6 |

### 4.2 Năm bảng buffer

#### B1 `mart.buffer_gstt_equity_day`
- **Grain:** 1 dòng / mã CK / ngày. **Nguồn:** `gstt_fct_stock_portfolio_snpst_flat`. **Universe:** `U_EQ`.
- **ORDER BY:** `(cdr_dt, floor_code, symbol)`. **Phục vụ:** 14 template (+ view heat-map).
- **Cột hub (49):** `public_company_dim_id`, `securities_company_dim_id`, `total_vol`, `total_val`, `total_matched_vol`, `total_matched_val`, `total_derivative_vol`, `total_derivative_val`, `total_negotiated_vol`, `total_negotiated_val`, `foreign_net_vol`, `outstanding_share_quantity`, `net_profit_after_tax`, `net_profit_after_tax_ttm`, `owner_equity`, `weighted_average_outstanding_share_quantity`, `weighted_average_outstanding_share_quantity_ttm`, `owner_equity_weighted_average_outstanding_share_quantity`, `owner_equity_weighted_average_outstanding_share_quantity_ttm`, `owner_equity_average_4_quarter`, `securities_company_net_profit_after_tax_ttm`, `securities_company_owner_equity`, `foreign_buy_vol`, `foreign_sell_vol`, `foreign_buy_val`, `foreign_sell_val`, `proprietary_buy_val`, `proprietary_sell_val`, `proprietary_buy_vol`, `proprietary_sell_vol`, `fct_close_price`, `free_float_share_quantity`, `cdr_dt`, `symbol`, `security_full_nm`, `floor_code`, `stock_tp_code`, `stock_tp_nm`, `listed_share_count`, `first_trading_dt`, `open_price`, `high_price`, `low_price`, `ceiling_price`, `floor_price`, `reference_price`, `close_price`, `price_change`, `classification_business_line_nm`
- **Cột dẫn xuất (24):** `bien_do_so_voi_san`, `bien_do_so_voi_tran`, `chenh_lech_gia_dong_vs_mo_cua_pct`, `chenh_lech_gia_tran_san`, `chenh_lech_von_hoa_freefloat_vs_thuong`, `do_cao_vuot_dinh_pct`, `do_sau_thung_day_pct`, `gia_tri_binh_quan_mot_lenh`, `khoang_cach_den_gia_san_pct`, `khoang_cach_den_gia_tran_pct`, `pb_uoc_tinh`, `pct_bien_dong_ngay`, `pe_uoc_tinh`, `thanh_khoan_theo_freefloat`, `ty_le_mua_rong_nn_gtgd`, `ty_le_mua_rong_nn_klgd`, `ty_trong_gtgd_nn_tren_tong_gtgd`, `ty_trong_gtgd_phai_sinh`, `ty_trong_gtgd_tren_von_hoa`, `ty_trong_klgd_nn_tren_tong_klgd`, `ty_trong_klgd_phai_sinh`, `ty_trong_thoa_thuan`, `vi_the_gia_trong_bien_do`, `von_hoa_free_float`

#### B2 `mart.buffer_gstt_equity_index_day`
- **Grain:** 1 dòng / mã CK / chỉ số / ngày (+ 1 dòng `index_code=''` cho mã không thuộc rổ nào). **Nguồn:** `INSERT … SELECT FROM buffer_gstt_equity_day b1 LEFT JOIN gstt_fct_index_constituent_snpst_flat idx ON idx.symbol=b1.symbol AND idx.cdr_dt=b1.cdr_dt` — nạp **từ B1** để công thức hub-only chỉ định nghĩa ở B1.
- **ORDER BY:** `(cdr_dt, index_code, symbol)`. **Phục vụ:** 20 template (gồm dinh-gia và 2 template nước ngoài theo chỉ số).
- **Cột hub (33):** `total_vol`, `total_val`, `total_matched_vol`, `total_matched_val`, `total_derivative_val`, `total_negotiated_vol`, `total_negotiated_val`, `outstanding_share_quantity`, `net_profit_after_tax`, `net_profit_after_tax_ttm`, `owner_equity`, `securities_company_net_profit_after_tax_ttm`, `securities_company_owner_equity`, `foreign_buy_vol`, `foreign_sell_vol`, `foreign_buy_val`, `foreign_sell_val`, `free_float_share_quantity`, `cdr_dt`, `symbol`, `security_full_nm`, `floor_code`, `stock_tp_code`, `stock_tp_nm`, `open_price`, `high_price`, `low_price`, `ceiling_price`, `floor_price`, `reference_price`, `close_price`, `price_change`, `classification_business_line_nm`
- **Cột rổ (9):** `idx_foreign_net_vol`, `idx_foreign_net_val`, `idx_market_index_val`, `idx_market_cap`, `idx_free_float_market_cap`, `idx_pe`, `idx_pb`, `idx_eps`, `index_code`
- **Cột dẫn xuất copy từ B1 (10):** `chenh_lech_gia_dong_vs_mo_cua_pct`, `chenh_lech_von_hoa_freefloat_vs_thuong`, `do_cao_vuot_dinh_pct`, `do_sau_thung_day_pct`, `khoang_cach_den_gia_san_pct`, `khoang_cach_den_gia_tran_pct`, `ty_trong_gtgd_nn_tren_tong_gtgd`, `ty_trong_gtgd_phai_sinh`, `ty_trong_gtgd_tren_von_hoa`, `ty_trong_klgd_nn_tren_tong_klgd`
- **Cột dẫn xuất cần cột rổ (8):** `bien_dao_dong_so_voi_idx_level`, `dong_gop_von_hoa_freefloat_idx`, `eps_vs_chi_so_eps`, `ty_le_von_hoa_so_voi_idx_level`, `ty_trong_klgd_tren_idx_level`, `ty_trong_von_hoa_trong_chi_so`, `dinh_gia_theo_pe_pb`, `ty_trong_freefloat_tren_tong_von_hoa_idx`

#### B3 `mart.buffer_gstt_bond_day`
- **Grain:** 1 dòng / mã trái phiếu / ngày. **Nguồn:** hub. **Universe:** `U_BOND`. **ORDER BY:** `(cdr_dt, symbol)`. **Phục vụ:** 2 template.
- **Cột hub (22):** `total_matched_vol`, `total_negotiated_vol`, `bond_trading_vol`, `bond_negotiated_vol`, `bond_trading_val`, `bond_negotiated_val`, `cdr_dt`, `symbol`, `security_full_nm`, `floor_code`, `stock_tp_code`, `issuer_nm`, `maturity_dt`, `coupon_rate`, `yield`, `open_price`, `high_price`, `low_price`, `reference_price`, `close_price`, `price_change`, `classification_business_line_nm`
- **Cột dẫn xuất (2):** `klgd_rong` = `total_matched_vol - total_negotiated_vol`; `bien_dong_gia_tuyet_doi` = `high_price - low_price`

#### B4 `mart.buffer_gstt_derivative_day`
- **Grain:** 1 dòng / hợp đồng / ngày. **Nguồn:** hub. **Universe:** `U_DER`. **ORDER BY:** `(cdr_dt, symbol)`. **Phục vụ:** 1 template (`bang-phai-sinh`). Nếu Q1 chọn "VIEW" thì bảng này thành view.
- **Cột hub (18):** `total_derivative_vol`, `total_derivative_negotiated_vol`, `total_derivative_val`, `total_derivative_negotiated_val`, `foreign_net_derivative_vol`, `foreign_buy_vol`, `foreign_sell_vol`, `foreign_buy_val`, `foreign_sell_val`, `cdr_dt`, `symbol`, `security_full_nm`, `floor_code`, `underlying_symbol`, `maturity_dt`, `reference_price`, `close_price`, `price_change`

#### B5 `mart.buffer_gstt_foreign_minute_equity`
- **Grain:** 1 dòng / mã CK / phút / ngày. **Nguồn:** `gstt_fct_foreign_trading_min_snpst_flat`. **Universe:** `U_EQ` + `(toHour(trade_minute_tms)*60 + toMinute(trade_minute_tms)) BETWEEN 540 AND 885` (09:00–14:45).
- **ORDER BY:** `(cdr_dt, symbol, trade_minute_tms)`. **Phục vụ:** `nuoc-ngoai-gtnn-intraday` + `nuoc-ngoai-theo-chi-so-intraday` (template này hiện đọc thẳng flat và lặp lại đúng 2 điều kiện lọc ở bước 2).
- **Cột (5):** `cdr_dt`, `symbol`, `trade_minute_tms`, `foreign_buy_val_at_min`, `foreign_sell_val_at_min`

### 4.3 Cột dẫn xuất — định nghĩa 1 lần

Công thức chép từ file tham chiếu (bỏ tiền tố `s.`/`b.`); khi nạp bọc `toFloat64` (P6). Đặt ở bảng nào = bảng đầu tiên có đủ cột đầu vào.

| Cột | Công thức (file tham chiếu) | Bảng | Template gốc |
|---|---|---|---|
| `bien_do_so_voi_san` | `(close_price - floor_price) / nullIf(ceiling_price - floor_price, 0) * 100` | B1 | top-giam-gia-theo-chi-so |
| `bien_do_so_voi_tran` | `(ceiling_price - close_price) / nullIf(ceiling_price - floor_price, 0) * 100` | B1 | tu-doanh |
| `chenh_lech_gia_dong_vs_mo_cua_pct` | `(close_price - open_price) / nullIf(open_price, 0) * 100` | B1 | top-dot-pha-toan-tt |
| `chenh_lech_gia_tran_san` | `ceiling_price - floor_price` | B1 | top-tang-gia-theo-san |
| `chenh_lech_von_hoa_freefloat_vs_thuong` | `close_price * (outstanding_share_quantity - free_float_share_quantity)` | B1 | tong-quan |
| `do_cao_vuot_dinh_pct` | `(high_price - reference_price) / nullIf(reference_price, 0) * 100` | B1 | top-vuot-dinh-theo-san |
| `do_sau_thung_day_pct` | `(reference_price - low_price) / nullIf(reference_price, 0) * 100` | B1 | top-thung-day-theo-san |
| `gia_tri_binh_quan_mot_lenh` | `total_matched_val / nullIf(total_matched_vol, 0)` | B1 | phan-loai-ndt-heatmap |
| `khoang_cach_den_gia_san_pct` | `(close_price - floor_price) / nullIf(floor_price, 0) * 100` | B1 | top-thung-day-theo-chi-so |
| `khoang_cach_den_gia_tran_pct` | `(ceiling_price - close_price) / nullIf(close_price, 0) * 100` | B1 | top-vuot-dinh-theo-chi-so |
| `pb_uoc_tinh` | `close_price * outstanding_share_quantity / nullIf(owner_equity, 0)` | B1 | top-tang-gia-theo-chi-so |
| `pct_bien_dong_ngay` | `(high_price - low_price) / nullIf(reference_price, 0) * 100` | B1 | bm021-mss-dinh-gia |
| `pe_uoc_tinh` | `close_price * outstanding_share_quantity / nullIf(net_profit_after_tax_ttm, 0)` | B1 | top-giam-gia-toan-tt |
| `thanh_khoan_theo_freefloat` | `total_matched_vol / nullIf(free_float_share_quantity, 0) * 100` | B1 | top-thung-day-toan-tt |
| `ty_le_mua_rong_nn_gtgd` | `(foreign_buy_val - foreign_sell_val) / nullIf(total_matched_val, 0) * 100` | B1 | nuoc-ngoai-gtnn |
| `ty_le_mua_rong_nn_klgd` | `(foreign_buy_vol - foreign_sell_vol) / nullIf(total_matched_vol, 0) * 100` | B1 | nuoc-ngoai |
| `ty_trong_gtgd_nn_tren_tong_gtgd` | `(foreign_buy_val + foreign_sell_val) / nullIf(total_matched_val, 0) * 100` | B1 | top-kl-theo-san |
| `ty_trong_gtgd_phai_sinh` | `total_derivative_val / nullIf(total_matched_val, 0) * 100` | B1 | top-dot-pha-theo-chi-so |
| `ty_trong_gtgd_tren_von_hoa` | `total_matched_val / nullIf(close_price * outstanding_share_quantity, 0) * 100` | B1 | top-gt-theo-san |
| `ty_trong_klgd_nn_tren_tong_klgd` | `(foreign_buy_vol + foreign_sell_vol) / nullIf(total_matched_vol, 0) * 100` | B1 | top-nn-theo-san |
| `ty_trong_klgd_phai_sinh` | `total_derivative_vol / nullIf(total_matched_vol, 0) * 100` | B1 | top-vuot-dinh-toan-tt |
| `ty_trong_thoa_thuan` | `total_negotiated_vol / nullIf(total_matched_vol + total_negotiated_vol, 0) * 100` | B1 | top-giam-gia-theo-san |
| `vi_the_gia_trong_bien_do` | `(close_price - low_price) / nullIf(high_price - low_price, 0) * 100` | B1 | bang-co-phieu |
| `von_hoa_free_float` | `close_price * free_float_share_quantity` | B1 | top-tang-gia-toan-tt |
| `bien_dao_dong_so_voi_idx_level` | `(high_price - low_price) / nullIf(idx_market_index_val, 0) * 100` | B2 | top-kl-toan-tt |
| `dinh_gia_theo_pe_pb` | `idx_pe / nullIf(idx_pb, 0)` | B2 | nuoc-ngoai-theo-chi-so-intraday |
| `dong_gop_von_hoa_freefloat_idx` | `(close_price * free_float_share_quantity) / nullIf(idx_free_float_market_cap, 0) * 100` | B2 | top-gt-toan-tt |
| `eps_vs_chi_so_eps` | `(net_profit_after_tax_ttm / nullIf(outstanding_share_quantity, 0)) - idx_eps` | B2 | top-nn-theo-chi-so |
| `ty_le_von_hoa_so_voi_idx_level` | `(close_price * outstanding_share_quantity) / nullIf(idx_market_index_val, 0)` | B2 | top-nn-toan-tt |
| `ty_trong_freefloat_tren_tong_von_hoa_idx` | `idx_free_float_market_cap / nullIf(idx_market_cap, 0) * 100` | B2 | nuoc-ngoai-theo-chi-so |
| `ty_trong_klgd_tren_idx_level` | `total_matched_vol / nullIf(idx_market_index_val, 0)` | B2 | top-kl-theo-chi-so |
| `ty_trong_von_hoa_trong_chi_so` | `(close_price * outstanding_share_quantity) / nullIf(idx_market_cap, 0) * 100` | B2 | top-gt-theo-chi-so |
| `bien_dong_gia_tuyet_doi` | `high_price - low_price` | B3 | lich-su-gia-khoi-luong |
| `klgd_rong` | `total_matched_vol - total_negotiated_vol` | B3 | bang-trai-phieu |

### 4.4 View và template đọc thẳng flat

| Template | Xử lý | Ghi chú |
|---|---|---|
| heat-map | `VIEW mart.buffer_gstt_heat_map` trên B1 | `WHERE floor_code IN ('10','02','04') AND (ifNull(public_company_dim_id,'') != '' OR ifNull(securities_company_dim_id,'') != '')` — B1 giữ 2 cột `*_dim_id` này |
| chi-so-eod, chi-so-history, phan-loai-ndt, phan-loai-ndt-index, co-dong-lon | Đọc thẳng flat nguồn (hoặc view 1:1 nếu nền tảng đòi tên `mart.*`) | Buffer gốc là bản sao `SELECT *` chỉ lọc ngày — không giảm dòng, không thêm cột; chi-so-eod thuộc QLKD, co-dong-lon thuộc NDTNN |
| chi-so-realtime | View trên `gstt_fct_market_index_intraday_flat` | Chỉ thêm lọc `substring(index_time,1,5) BETWEEN '09:00' AND '14:45'` |
| ngay-nghi-giao-dich | View trên `cdr_dt_flat` (`is_trading_date != 'Y'`) | Thuộc Common |

### 4.5 Thứ tự nạp (cùng `:etl_date`, sau khi các flat 01–02 nạp xong)

```
hub ─────► B1 ─────► B2
  │
  ├──────► B3
  └──────► B4
foreign_min ──► B5
```

Backfill: lặp theo ngày theo đúng thứ tự trên; mỗi bước idempotent nên chạy lại không trùng.

## 5. Ánh xạ 46 template

| ID | Template | Buffer gốc | → Đối tượng mới |
|---|---|---|---|
| 2336 | bang-co-phieu | `mart.buffer_bang_co_phieu` | B1 equity_day |
| 2337 | bang-trai-phieu | `mart.buffer_bang_trai_phieu` | B3 bond_day |
| 2338 | bang-phai-sinh | `mart.buffer_bang_phai_sinh` | B4 derivative_day |
| 2341 | ngay-nghi-giao-dich | `mart.buffer_ngay_nghi_giao_dich` | view trên cdr_dt_flat |
| 2349 | chi-so-realtime | `mart.buffer_chi_so_realtime` | view trên flat intraday |
| 2350 | chi-so-history | `mart.buffer_chi_so_history` | đọc thẳng flat / view 1:1 |
| 2351 | chi-so-eod | `mart.buffer_chi_so_eod` | đọc thẳng flat / view 1:1 |
| 2352 | dinh-gia | `mart.buffer_dinh_gia` | B2 equity_index_day |
| 2354 | top-kl-toan-tt | `mart.buffer_top_kl_toan_tt` | B2 equity_index_day |
| 2355 | top-kl-theo-san | `mart.buffer_top_kl_theo_san` | B2 equity_index_day |
| 2356 | top-kl-theo-chi-so | `mart.buffer_top_kl_theo_chi_so` | B2 equity_index_day |
| 2357 | top-tang-gia-toan-tt | `mart.buffer_top_tang_gia_toan_tt` | B1 equity_day |
| 2358 | top-tang-gia-theo-san | `mart.buffer_top_tang_gia_theo_san` | B1 equity_day |
| 2359 | top-tang-gia-theo-chi-so | `mart.buffer_top_tang_gia_theo_chi_so` | B1 equity_day |
| 2360 | top-giam-gia-toan-tt | `mart.buffer_top_giam_gia_toan_tt` | B1 equity_day |
| 2361 | top-giam-gia-theo-san | `mart.buffer_top_giam_gia_theo_san` | B1 equity_day |
| 2362 | top-giam-gia-theo-chi-so | `mart.buffer_top_giam_gia_theo_chi_so` | B1 equity_day |
| 2363 | top-vuot-dinh-toan-tt | `mart.buffer_top_vuot_dinh_toan_tt` | B1 equity_day |
| 2364 | top-vuot-dinh-theo-san | `mart.buffer_top_vuot_dinh_theo_san` | B2 equity_index_day |
| 2365 | top-vuot-dinh-theo-chi-so | `mart.buffer_top_vuot_dinh_theo_chi_so` | B2 equity_index_day |
| 2366 | top-thung-day-toan-tt | `mart.buffer_top_thung_day_toan_tt` | B1 equity_day |
| 2367 | top-thung-day-theo-san | `mart.buffer_top_thung_day_theo_san` | B2 equity_index_day |
| 2368 | top-thung-day-theo-chi-so | `mart.buffer_top_thung_day_theo_chi_so` | B2 equity_index_day |
| 2369 | top-dot-pha-toan-tt | `mart.buffer_top_dot_pha_toan_tt` | B2 equity_index_day |
| 2370 | top-dot-pha-theo-san | `mart.buffer_top_dot_pha_theo_san` | B2 equity_index_day |
| 2371 | top-dot-pha-theo-chi-so | `mart.buffer_top_dot_pha_theo_chi_so` | B2 equity_index_day |
| 2372 | top-nn-toan-tt | `mart.buffer_top_nn_toan_tt` | B2 equity_index_day |
| 2373 | top-nn-theo-san | `mart.buffer_top_nn_theo_san` | B2 equity_index_day |
| 2374 | top-nn-theo-chi-so | `mart.buffer_top_nn_theo_chi_so` | B2 equity_index_day |
| 2375 | top-gt-toan-tt | `mart.buffer_top_gt_toan_tt` | B2 equity_index_day |
| 2376 | top-gt-theo-san | `mart.buffer_top_gt_theo_san` | B2 equity_index_day |
| 2377 | top-gt-theo-chi-so | `mart.buffer_top_gt_theo_chi_so` | B2 equity_index_day |
| 2378 | tong-quan | `mart.buffer_tong_quan` | B2 equity_index_day |
| 2379 | nuoc-ngoai | `mart.buffer_nuoc_ngoai` | B1 equity_day |
| 2380 | nuoc-ngoai-gtnn | `mart.buffer_nuoc_ngoai_gtnn` | B1 equity_day |
| 2381 | nuoc-ngoai-gtnn-intraday | `mart.buffer_nuoc_ngoai_gtnn_intraday` | B5 foreign_minute_equity |
| 2382 | nuoc-ngoai-theo-chi-so | `mart.buffer_nuoc_ngoai_theo_chi_so` | B2 equity_index_day |
| 2383 | nuoc-ngoai-theo-chi-so-intraday | `mart.buffer_nuoc_ngoai_theo_chi_so_intraday` | B2 equity_index_day |
| 2384 | tu-doanh | `mart.buffer_tu_doanh` | B1 equity_day |
| 2385 | phan-loai-ndt | `mart.buffer_phan_loai_ndt` | đọc thẳng flat / view 1:1 |
| 2386 | phan-loai-ndt-index | `mart.buffer_phan_loai_ndt_index` | đọc thẳng flat / view 1:1 |
| 2387 | phan-loai-ndt-heatmap | `mart.buffer_phan_loai_ndt_heatmap` | B1 equity_day |
| 2391 | bm021-mss-dinh-gia | `mart.buffer_bm021_mss_dinh_gia` | B1 equity_day |
| 2392 | lich-su-gia-khoi-luong | `mart.buffer_lich_su_gia_khoi_luong` | B3 bond_day |
| 2397 | co-dong-lon | `mart.buffer_co_dong_lon` | đọc thẳng flat / view 1:1 |
| 2399 | heat-map | `mart.buffer_heat_map` | view trên B1 |

Ngoài phạm vi (giữ nguyên file tham chiếu): 5 template thủ công `ohlcv`, `instrument-ohlcv`, `so-lenh-danh-sach-chi-so`, `so-lenh-danh-sach-ma`, `nguoi-noi-bo` (xem P3) và 6 template không có tham số ngày.

## 6. Phát hiện ở file tham chiếu (cần xử lý trước khi áp dụng)

| # | Phát hiện | Mức chắc chắn |
|---|---|---|
| P1 | 18 template bước 2 (`dinh-gia`, `tong-quan`, `top-dot-pha-*`×3, `top-gt-*`×3, `top-kl-*`×3, `top-nn-*`×3, `top-thung-day-theo-chi-so/-theo-san`, `top-vuot-dinh-theo-chi-so/-theo-san`) viết `s.cdr_dt`, `b.index_code`, `idx.cdr_dt`… nhưng `FROM mart.buffer_*` không có alias `s`/`b`/`idx` (buffer đã phẳng). Header ghi "SQL bước 2 KHÔNG đổi" nên không đúng cho 18 template này. | Đã đọc tay 5/18 (dinh-gia, tong-quan, top-kl ×3), 13 còn lại phát hiện bằng script cùng mẫu. ⚠ ClickHouse sẽ báo unknown identifier — chưa chạy thử |
| P2 | `s.*, b.* EXCEPT (cdr_dt, symbol)` còn trùng 3 tên cột giữa hub và bảng rổ: `is_trading_date`, `security_trading_snpst_dim_id`, `snpst_dt_dim_id`. | Đã xác nhận (hub ∩ rổ). ⚠ cách ClickHouse xử lý khi CTAS chưa thử |
| P3 | Phần 2 tham chiếu `gstt_fct_security_trading_intraday_flat` — bảng đã bãi bỏ (DDL repo: thay bằng `gstt_fct_instrument_price_intraday_flat`); 3 template `so-lenh-danh-sach-chi-so/-ma`, `nguoi-noi-bo` dùng `ds_snpst_dt` — DDL repo không có cột này (`gstt_opr_security_*_ref_flat` dùng `as_of_dt`, `gstt_opr_public_company_insider_ownership_flat` không có cột ngày snapshot). | Đã đối chiếu DDL repo. Có thể prod khác repo — cần xác nhận |
| P4 | Nguồn đọc `default.gstt_*_flat`, trong khi DDL repo tạo `datamart.gstt_*_flat`. | Đã xác nhận lệch tên DB; chưa biết `default` là alias/view hay DB khác — Q3 |
| P5 | Buffer tạo bằng `MergeTree` thường, không `ON CLUSTER`; flat dùng `ReplicatedReplacingMergeTree ON CLUSTER 'my_cluster'`. Nếu cluster nhiều node thì dữ liệu buffer chỉ nằm trên node chạy lệnh. | Đã xác nhận khác biệt; hậu quả phụ thuộc topology |
| P6 | Các cột tỷ lệ chia 2 cột `Decimal(23,2)` không `toFloat64` (vd `(high_price-low_price)/nullIf(reference_price,0)*100`). ClickHouse chia Decimal giữ scale của số bị chia nên 1,2/25 có thể ra 0,04 thay vì 0,048. Bước 2 hiện có đã tự `toFloat64` trước khi chia. | ⚠ Theo ngữ nghĩa Decimal của ClickHouse, chưa chạy thử 1 mẫu |
| P7 | Universe không nhất quán: (a) 8 template "theo-san" thiếu `floor_code != '03'` nhưng bước 2 chỉ chọn sàn 10/02/04 (đã kiểm 8/8) → gộp được với `U_EQ`; (b) `U_BOND` gồm sàn 04 và 03 với `stock_tp_code='1'`, còn `U_EQ` chỉ loại (02: 1,4) và (10: 1) — mã UPCOM `stock_tp_code='1'` không bị loại khỏi nhóm cổ phiếu; LLD `stock_tp_nm` trả 'Khác' cho sàn ngoài 10/02/04. | (a) đã xác nhận; (b) cần xác nhận dữ liệu — Q4 |
| P8 | 9 template bước 2 đọc thẳng hub để tra lookback (tong-quan, chi-so-eod, phan-loai-ndt, top-thung-day ×3, top-vuot-dinh ×3) nên không hưởng buffer. | Đã xác nhận. Thiết kế mới chuyển phần lookback sang B1/B2 |
| P9 | 46 lệnh `ALTER TABLE … DELETE` (mutation) mỗi ngày; repo flat đang dùng `DELETE FROM` nhẹ. | Khuyến nghị, không phải lỗi |

## 7. Đặt vào repo — tác động

- **Không đụng:** LLD per-table, `datamart_attributes.csv`, Detail Mapping, `datamart_model.yaml`, Entities, 18 flat hiện có. Buffer là đối tượng *phục vụ phía sau flat*, không phải Fact/Operational mới.
- **File mới (khi duyệt):** `Datamart/flat-table/GSTT/buffer/01_create_gstt_buffer_tables.sql` + `02_populate_gstt_buffer_tables.sql`; thêm mục vào `Datamart/flat-table/flat_table_mapping.md`.
- **Phải nằm thư mục con** vì `datamart_flat_table_checker.py:789-794` lấy file ĐẦU TIÊN khớp `01_create*.sql` / `02_populate*.sql` (có `break`) ngay trong thư mục module — thêm file cùng mẫu cạnh flat có thể khiến Gate 4 đọc nhầm file buffer. Glob không đệ quy nên thư mục con an toàn. Sau khi tạo, chạy `check_flat_table.py --module GSTT --strict` xác nhận kết quả Gate 4 không đổi.
- **HLD:** thêm 1 mục "Tầng buffer phục vụ BI" + Open Issue (dự kiến `O_GSTT_74`) bằng `apply_patch.py --dry-run`, sau đó chạy `run_quality_gates.py --module GSTT --strict` (Bước 5B). Chưa làm.
- **34 cột dẫn xuất không có trong BA/KPI.** Giữ ở buffer dưới dạng *serving-only*; không đưa vào Attributes/Detail Mapping (nếu đưa vào phải có KPI và lên flat theo A20).
- **Rủi ro trôi cột:** A20 chỉ ép LLD ↔ flat. Đề xuất thêm 1 kiểm tra nhỏ: mọi cột nguồn trong buffer phải tồn tại ở flat nguồn (đã làm thủ công cho file này: 0 lệch ở bước 1).

## 8. Quyết định cần chốt

| # | Câu hỏi | Đề xuất |
|---|---|---|
| Q1 | Nền tảng chart có bắt buộc mỗi template một bảng `mart.buffer_<template>` riêng không? | Nếu **không**: đổi `FROM` trong bước 2 sang 5 bảng. Nếu **có**: giữ 46 tên bằng view mỏng trên B1–B5 (không tốn lưu trữ) |
| Q2 | 34 cột dẫn xuất có yêu cầu thật từ BA/BI không? | Hiện không bước 2 nào đọc. Nếu chưa có chart → bỏ khỏi buffer ở đợt này, thêm khi có yêu cầu |
| Q3 | DB đích `mart`, engine Replicated + `ON CLUSTER`, tham số `:etl_date` hay `{ngay:Date}`; nguồn đọc `datamart.` hay `default.`? | `mart` + Replicated + `:etl_date`; nguồn `datamart.` (theo repo) — cần xác nhận P4/P5 |
| Q4 | `U_BOND` có gồm sàn 04 và 03 không; `U_EQ` có phải loại cả UPCOM `stock_tp_code='1'` không? | Chạy 1 truy vấn đếm theo `(floor_code, stock_tp_code)` trên hub để quyết |
| Q5 | 5 template thủ công và 7 template bản sao 1:1 để ngoài phạm vi? | Có — xử lý riêng sau P3 |

## 9. Bước tiếp theo (nếu duyệt)

1. Chốt Q1–Q5.
2. Sinh `01_create` / `02_populate` cho B1–B5 trong thư mục `buffer/` (bản nháp, có `--dry-run` đếm cột CREATE = SELECT).
3. Sinh bản sửa bước 2 cho 18 template (bỏ tiền tố `s.`/`b.`/`idx.`, đổi `FROM`) — cơ học, có thể script hoá.
4. Chạy thử trên ClickHouse dev: P1, P2, P6; đối chiếu số dòng B1/B2 với tổng các buffer cũ trên 1 ngày mẫu.
5. Cập nhật HLD + Gate.

## 10. Thiết kế áp dụng — 46 bảng, không gộp

**File:** `Datamart/flat-table/GSTT/buffer/01_create_gstt_buffer_tables.sql` (46 `CREATE TABLE`) + `02_populate_gstt_buffer_tables.sql` (46 khối `DELETE` + `INSERT`). Bản nháp, chưa chạy thử trên ClickHouse.

**Giữ nguyên file tham chiếu:** tên `mart.buffer_<template>`; mỗi template một bảng; lọc universe/khung giờ copy nguyên; mỗi bảng giữ đúng 1 cột dẫn xuất `[CỘT MỚI]` của template; nạp theo ngày bằng xoá + nạp lại.

**Khác file tham chiếu (có chủ đích):**

| Hạng mục | Áp dụng | File tham chiếu |
|---|---|---|
| Cột | Liệt kê tường minh: cột bước 2 đọc + cột trong biểu thức dẫn xuất/WHERE + khoá | `SELECT *` (112 cột hub mỗi bảng) |
| Engine | `ReplicatedMergeTree()` `ON CLUSTER 'my_cluster'` | `MergeTree` |
| Nạp | `DELETE FROM … WHERE <cột ngày> = :etl_date` + `INSERT` (như flat hiện tại) | `ALTER TABLE … DELETE` + `{ngay:Date}` |
| Nguồn | `datamart.*` (theo DDL repo) | `default.*` |
| Cột dẫn xuất | bọc `toFloat64` khi chia | không bọc |
| Join rổ chỉ số | `LEFT JOIN` + `SETTINGS join_use_nulls = 1`, không còn cột trùng tên | `s.*, b.* EXCEPT (cdr_dt, symbol)` |
| ORDER BY | `assumeNotNull` trên khoá tự nhiên (như flat hiện tại) | `tuple()` |

Các giá trị cấu hình (DB đích, engine, tham số ngày, DB nguồn) nằm ở đầu script sinh; đổi 1 dòng là sinh lại được.

### 10.1 Danh mục 46 bảng

| # | ID | Template | Bảng | Nguồn | Số cột | Cột dẫn xuất |
|--:|---|---|---|---|--:|---|
| 1 | 2399 | heat-map | `mart.buffer_heat_map` | stock_portfolio | 19 | — |
| 2 | 2391 | bm021-mss-dinh-gia | `mart.buffer_bm021_mss_dinh_gia` | stock_portfolio | 20 | `pct_bien_dong_ngay` |
| 3 | 2351 | chi-so-eod | `mart.buffer_chi_so_eod` | qlkd_fct_market_index | 15 | — |
| 4 | 2350 | chi-so-history | `mart.buffer_chi_so_history` | market_index_intraday | 4 | — |
| 5 | 2349 | chi-so-realtime | `mart.buffer_chi_so_realtime` | market_index_intraday | 5 | — |
| 6 | 2352 | dinh-gia | `mart.buffer_dinh_gia` | index_constituent ⨝ stock_portfolio | 14 | — |
| 7 | 2336 | bang-co-phieu | `mart.buffer_bang_co_phieu` | stock_portfolio | 25 | `vi_the_gia_trong_bien_do` |
| 8 | 2338 | bang-phai-sinh | `mart.buffer_bang_phai_sinh` | stock_portfolio | 18 | — |
| 9 | 2341 | ngay-nghi-giao-dich | `mart.buffer_ngay_nghi_giao_dich` | cdr_dt | 2 | — |
| 10 | 2379 | nuoc-ngoai | `mart.buffer_nuoc_ngoai` | stock_portfolio | 19 | `ty_le_mua_rong_nn_klgd` |
| 11 | 2380 | nuoc-ngoai-gtnn | `mart.buffer_nuoc_ngoai_gtnn` | stock_portfolio | 8 | `ty_le_mua_rong_nn_gtgd` |
| 12 | 2381 | nuoc-ngoai-gtnn-intraday | `mart.buffer_nuoc_ngoai_gtnn_intraday` | foreign_trading_min | 7 | — |
| 13 | 2382 | nuoc-ngoai-theo-chi-so | `mart.buffer_nuoc_ngoai_theo_chi_so` | index_constituent | 8 | `ty_trong_freefloat_tren_tong_von_hoa_idx` |
| 14 | 2383 | nuoc-ngoai-theo-chi-so-intraday | `mart.buffer_nuoc_ngoai_theo_chi_so_intraday` | index_constituent | 6 | `dinh_gia_theo_pe_pb` |
| 15 | 2385 | phan-loai-ndt | `mart.buffer_phan_loai_ndt` | investor_category_trading | 7 | — |
| 16 | 2387 | phan-loai-ndt-heatmap | `mart.buffer_phan_loai_ndt_heatmap` | stock_portfolio | 13 | `gia_tri_binh_quan_mot_lenh` |
| 17 | 2386 | phan-loai-ndt-index | `mart.buffer_phan_loai_ndt_index` | investor_category_index_trading | 8 | — |
| 18 | 2378 | tong-quan | `mart.buffer_tong_quan` | stock_portfolio ⨝ index_constituent | 21 | `chenh_lech_von_hoa_freefloat_vs_thuong` |
| 19 | 2384 | tu-doanh | `mart.buffer_tu_doanh` | stock_portfolio | 15 | `bien_do_so_voi_tran` |
| 20 | 2397 | co-dong-lon | `mart.buffer_co_dong_lon` | ndtnn_fct_public_company_foreign_ownership | 5 | — |
| 21 | 2371 | top-dot-pha-theo-chi-so | `mart.buffer_top_dot_pha_theo_chi_so` | stock_portfolio ⨝ index_constituent | 22 | `ty_trong_gtgd_phai_sinh` |
| 22 | 2370 | top-dot-pha-theo-san | `mart.buffer_top_dot_pha_theo_san` | stock_portfolio ⨝ index_constituent | 20 | — |
| 23 | 2369 | top-dot-pha-toan-tt | `mart.buffer_top_dot_pha_toan_tt` | stock_portfolio ⨝ index_constituent | 22 | `chenh_lech_gia_dong_vs_mo_cua_pct` |
| 24 | 2362 | top-giam-gia-theo-chi-so | `mart.buffer_top_giam_gia_theo_chi_so` | stock_portfolio | 25 | `bien_do_so_voi_san` |
| 25 | 2361 | top-giam-gia-theo-san | `mart.buffer_top_giam_gia_theo_san` | stock_portfolio | 23 | `ty_trong_thoa_thuan` |
| 26 | 2360 | top-giam-gia-toan-tt | `mart.buffer_top_giam_gia_toan_tt` | stock_portfolio | 23 | `pe_uoc_tinh` |
| 27 | 2377 | top-gt-theo-chi-so | `mart.buffer_top_gt_theo_chi_so` | stock_portfolio ⨝ index_constituent | 24 | `ty_trong_von_hoa_trong_chi_so` |
| 28 | 2376 | top-gt-theo-san | `mart.buffer_top_gt_theo_san` | stock_portfolio ⨝ index_constituent | 23 | `ty_trong_gtgd_tren_von_hoa` |
| 29 | 2375 | top-gt-toan-tt | `mart.buffer_top_gt_toan_tt` | stock_portfolio ⨝ index_constituent | 25 | `dong_gop_von_hoa_freefloat_idx` |
| 30 | 2356 | top-kl-theo-chi-so | `mart.buffer_top_kl_theo_chi_so` | stock_portfolio ⨝ index_constituent | 24 | `ty_trong_klgd_tren_idx_level` |
| 31 | 2355 | top-kl-theo-san | `mart.buffer_top_kl_theo_san` | stock_portfolio ⨝ index_constituent | 25 | `ty_trong_gtgd_nn_tren_tong_gtgd` |
| 32 | 2354 | top-kl-toan-tt | `mart.buffer_top_kl_toan_tt` | stock_portfolio ⨝ index_constituent | 26 | `bien_dao_dong_so_voi_idx_level` |
| 33 | 2374 | top-nn-theo-chi-so | `mart.buffer_top_nn_theo_chi_so` | stock_portfolio ⨝ index_constituent | 28 | `eps_vs_chi_so_eps` |
| 34 | 2373 | top-nn-theo-san | `mart.buffer_top_nn_theo_san` | stock_portfolio ⨝ index_constituent | 27 | `ty_trong_klgd_nn_tren_tong_klgd` |
| 35 | 2372 | top-nn-toan-tt | `mart.buffer_top_nn_toan_tt` | stock_portfolio ⨝ index_constituent | 28 | `ty_le_von_hoa_so_voi_idx_level` |
| 36 | 2359 | top-tang-gia-theo-chi-so | `mart.buffer_top_tang_gia_theo_chi_so` | stock_portfolio | 23 | `pb_uoc_tinh` |
| 37 | 2358 | top-tang-gia-theo-san | `mart.buffer_top_tang_gia_theo_san` | stock_portfolio | 25 | `chenh_lech_gia_tran_san` |
| 38 | 2357 | top-tang-gia-toan-tt | `mart.buffer_top_tang_gia_toan_tt` | stock_portfolio | 24 | `von_hoa_free_float` |
| 39 | 2368 | top-thung-day-theo-chi-so | `mart.buffer_top_thung_day_theo_chi_so` | stock_portfolio ⨝ index_constituent | 24 | `khoang_cach_den_gia_san_pct` |
| 40 | 2367 | top-thung-day-theo-san | `mart.buffer_top_thung_day_theo_san` | stock_portfolio ⨝ index_constituent | 23 | `do_sau_thung_day_pct` |
| 41 | 2366 | top-thung-day-toan-tt | `mart.buffer_top_thung_day_toan_tt` | stock_portfolio | 23 | `thanh_khoan_theo_freefloat` |
| 42 | 2365 | top-vuot-dinh-theo-chi-so | `mart.buffer_top_vuot_dinh_theo_chi_so` | stock_portfolio ⨝ index_constituent | 24 | `khoang_cach_den_gia_tran_pct` |
| 43 | 2364 | top-vuot-dinh-theo-san | `mart.buffer_top_vuot_dinh_theo_san` | stock_portfolio ⨝ index_constituent | 23 | `do_cao_vuot_dinh_pct` |
| 44 | 2363 | top-vuot-dinh-toan-tt | `mart.buffer_top_vuot_dinh_toan_tt` | stock_portfolio | 23 | `ty_trong_klgd_phai_sinh` |
| 45 | 2337 | bang-trai-phieu | `mart.buffer_bang_trai_phieu` | stock_portfolio | 21 | `klgd_rong` |
| 46 | 2392 | lich-su-gia-khoi-luong | `mart.buffer_lich_su_gia_khoi_luong` | stock_portfolio | 9 | `bien_dong_gia_tuyet_doi` |

### 10.2 Đã kiểm

- 46 `CREATE` = 46 `DELETE` = 46 `INSERT`; tên bảng khớp 46 buffer của file tham chiếu.
- Mỗi bảng: danh sách cột `CREATE` = danh sách cột `SELECT` (cùng tên, cùng thứ tự); cột copy tồn tại ở flat nguồn với **cùng kiểu**; khoá/partition nằm trong bảng.
- Mọi cột của flat nguồn xuất hiện trong SQL bước 2 của template đều có mặt trong bảng tương ứng.
- Công thức 34 cột dẫn xuất khớp file tham chiếu (cùng toán hạng, cùng thứ tự; chỉ thêm `toFloat64`); điều kiện `WHERE` tĩnh khớp file tham chiếu.
- Gate 4 (`check_flat_table.py --module GSTT --strict`) vẫn PASS 18/18 như trước khi thêm file; Gate 8 không đổi (1 WARNING `opr_security_ref` có sẵn từ trước).

### 10.3 Chưa làm / chưa kiểm

- **Chưa chạy trên ClickHouse** (không có môi trường) — chưa kiểm cú pháp thật, chưa so số dòng với buffer cũ.
- **SQL bước 2 của 18 template join rổ chỉ số đã chỉnh** tại `Datamart/flat-table/GSTT/buffer/03_chart_step2_join_templates.sql` (thêm alias `AS s` cho bảng buffer, đổi `b.`/`idx.` → `s.`, gộp `index_code` trùng; không đổi logic). Đã kiểm tĩnh (token khớp bản gốc, mọi `s.<cột>` có trong buffer), chưa chạy thử. 28 template còn lại giữ nguyên.
- **5 template thủ công** (`ohlcv`, `instrument-ohlcv`, `so-lenh-danh-sach-chi-so`, `so-lenh-danh-sach-ma`, `nguoi-noi-bo`) và 6 template không tham số ngày không nằm trong 46 bảng.
- **Universe chưa chuẩn hoá** (mục 6, P7b): điều kiện trái phiếu gồm sàn 04/03, điều kiện cổ phiếu không loại mã UPCOM `stock_tp_code='1'`.
- **34 cột dẫn xuất chưa bước 2 nào đọc** (mục 3.2); giữ theo file tham chiếu.
- 3 bảng có nguồn thuộc module khác: `buffer_chi_so_eod` (QLKD), `buffer_co_dong_lon` (NDTNN), `buffer_ngay_nghi_giao_dich` (Common). Phải nạp sau flat của các module đó.
- Chưa ghi HLD / `flat_table_mapping.md` (mục GSTT trong file này đã cũ so với flat hiện tại, không phải do thay đổi này).
