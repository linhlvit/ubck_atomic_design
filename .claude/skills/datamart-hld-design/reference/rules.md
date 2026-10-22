# Luật chống tái diễn H1–H14 — HLD Datamart

Bản đầy đủ của bảng tóm tắt trong `SKILL.md`: mỗi luật kèm sự cố gốc và cách kiểm. Đọc đúng mục cần dùng, ví dụ `grep -n "^### H7" .claude/skills/datamart-hld-design/reference/rules.md`, không cần đọc cả file.

## Mục lục

- H1 — Một HLD là MỘT nguồn sự thật: sửa Section 1 phải sửa cả Section 3/4/5
- H2 — Đóng Open Issue mặc định là "Resolved một phần" `[partial-resolution]`
- H3 — Reuse Fact xuyên module: grain là hợp đồng bất biến `[L1-GRAIN-MISMATCH]`
- H4 — Trạng thái KPI phải đồng bộ 2 chiều với Detail Mapping `[L0-HLD-LLD-STATUS-DESYNC]`
- H5 — Mọi tên cột Atomic viết vào HLD phải grep được `[L0-ATOMIC-COLUMN-NOT-FOUND]`
- H6 — BA tách/gộp/dồn số Nhóm: đánh số lại TRƯỚC, thiết kế SAU `[L1-GROUP-NUMBER-DRIFT]` `[L1-BA-STT-COLLISION]`
- H7 — Khóa JOIN giữa 2 bảng nguồn phải có BẰNG CHỨNG, không chép từ ghi chú cũ `[L1-JOIN-KEY-UNVERIFIED]`
- H8 — Loại measure (Giá trị vs Khối lượng) phải khớp Trường nguồn BA `[L3-MEASURE-TYPE-MISMATCH]`
- H9 — Đối soát NỘI DUNG từng dòng BA, không chỉ số lượng `[L3-BA-ROW-UNMAPPED]`
- H10 — Thứ tự ưu tiên khi đọc 1 dòng BA: Điều kiện chung/Mô tả > Câu lệnh tham khảo có Note "cần check" `[L3-REFERENCE-SQL-MISALIGNMENT]`
- H11 — Cột/công thức dùng chung nhiều Nhóm: đọc BA của MỌI Nhóm tiêu thụ trước khi đổi `[L3-SHARED-RULE-DRIFT]`
- H12 — BA chuyển Nhóm sang nguồn/bảng mới: kiểm bảng cũ còn KPI nào dùng không `[L2-TABLE-ZERO-USAGE]`
- H12b — Trước khi kết luận "thiếu", đọc quyết định đã duyệt của đúng KPI `[process]`
- H13 — Sửa bảng Markdown trong HLD: mỗi dòng KPI đúng 7 ô; giải trình ánh xạ phải tra lại KPI thật `[L1-HLD-KPI-ROW-CELLS]`
- H14 — Chọn chỉ số (VN-Index, VN30…) trên `market_index_snapshot`: giữ `market_code = 'HOSE'` (Data Modeler chốt 2026-10-21, đảo quyết định `index_nm` 2026-10-20) `[process]`
- Ghi chú lịch sử

### H1 — Một HLD là MỘT nguồn sự thật: sửa Section 1 phải sửa cả Section 3/4/5

Section 1 (Lineage), Section 3 (Mô hình), Section 4 (Reuse), Section 5 (Open Issue) mô tả cùng một
tập bảng. Sửa lẻ một Section tạo ra HLD tự mâu thuẫn.

Thực tế đã sai: Section 1 và Section 5 tuyên bố `O_PTTT_13` đã giải quyết và thay Fact mới, nhưng
Section 3 vẫn giữ node `fct_mbr_sfty_per_mbr_snpst` + entity giả `Member Report Indicator Value`
và ghi "PENDING"; Section 3 còn để tên vật lý cũ `fct_mcr_ind_snpst` trong khi Entities/LLD đã đổi.

**Checklist khi thay/bãi bỏ một bảng:** Section 1 flowchart → Section 3.1 graph TB → bảng 3.2/3.3/3.4
→ Section 4 reuse_status → Section 5 issue → Entities.csv/.md. Đủ 6 nơi, không thiếu nơi nào.

### H2 — Đóng Open Issue mặc định là "Resolved một phần" `[partial-resolution]`

Nguồn Atomic mới xuất hiện **không** đồng nghĩa mọi KPI trong danh sách issue đều READY được.
Bắt buộc tách theo grain / theo nhánh nguồn:

1. Liệt kê KPI chuyển READY **kèm grain đạt được**.
2. KPI chưa đạt → mở Open Issue mới (`O_{MODULE}_{N+1}`) ghi rõ còn thiếu gì.
3. Issue gốc để trạng thái `Resolved một phần`, không phải `Resolved`.

Thực tế đã sai: O_PTTT_11 và O_PTTT_13 bị đóng toàn phần → 9 KPI grain ngày bị đánh READY trong khi
nguồn chỉ có grain kỳ báo cáo tháng/quý.

### H3 — Reuse Fact xuyên module: grain là hợp đồng bất biến `[L1-GRAIN-MISMATCH]`

Trước khi ghi `reuse` vào Section 4:
1. Mở Entities.csv của **module chủ sở hữu**, copy nguyên văn chuỗi grain.
2. Đối chiếu với Presentation Grain của mockup module mình (Thang 6 bậc hạt ở Bước 4B).
3. Grain Fact **kỳ báo cáo** không phục vụ được chỉ tiêu rolling theo **phiên giao dịch** — trường hợp này
   phải giữ PENDING và mở Open Issue, không được reuse rồi viết công thức như thể có dữ liệu ngày.
4. Cột "Nguồn Atomic" trong Section 3 và `source_table` trong Entities.csv ghi **entity Atomic**,
   tuyệt đối không ghi tên bảng Datamart (`fct_*`).

### H4 — Trạng thái KPI phải đồng bộ 2 chiều với Detail Mapping `[L0-HLD-LLD-STATUS-DESYNC]`

Bảng KPI trong HLD và Detail Mapping là hai bản ghi của cùng một trạng thái. Sau khi sửa cột
`Trạng thái` trong HLD, chạy ngay:

```bash
python .claude/skills/datamart-review/scripts/check_references.py --module {MODULE}
```

Nhóm chuyển từ 100% PENDING sang có KPI READY còn phải bổ sung đủ: `**Source:**`, `**Star Schema:**`,
`**Lineage Mart → Báo cáo:**`, `**Bảng grain:**` — và gỡ bảng "Bảng mapping nguồn (Atomic Placeholder)"
nếu nhóm đã hết PENDING.

### H5 — Mọi tên cột Atomic viết vào HLD phải grep được `[L0-ATOMIC-COLUMN-NOT-FOUND]`

Áp dụng cho công thức KPI, ghi chú nguồn và erDiagram. Không suy tên từ nghĩa nghiệp vụ:
`cl_risk_indicator` có `ind_nm` chứ không phải `cl_risk_ind_name`; `security_trading_snapshot` có
`symbol` chứ không phải `security_symbol_code`. Xem bảng đối chiếu đầy đủ ở mục **A1** của
`datamart-lld-design/reference/rules.md`.

> Các quy tắc H6–H9 dưới đây rút ra từ sự cố GSTT ngày 2026-09-23: BA tách Nhóm 28/29 thành 28–31
> rồi sau đó thành 37 Nhóm. Cả 4 quy tắc là lỗi **thật đã lọt lưới**, và cả 4 đều **không** bị
> `run_quality_gates.py` hay `datamart_progress_analyzer.py` bắt được. Script bắt được chúng là
> `ba_hld_sync_check.py` (mã S1–S5).

### H6 — BA tách/gộp/dồn số Nhóm: đánh số lại TRƯỚC, thiết kế SAU `[L1-GROUP-NUMBER-DRIFT]` `[L1-BA-STT-COLLISION]`

Số Nhóm trong HLD và Detail Mapping PHẢI bằng STT của BA. Khi BA tách một Nhóm, các Nhóm phía sau bị
dồn số. Lúc đó `datamart_progress_analyzer.py` so số lượng theo **số** Nhóm, nên sẽ:
- báo 🔴 hàng loạt ở các Nhóm không liên quan, hoặc tệ hơn,
- báo **🟢 Khớp giả**. Thực tế đã xảy ra: HLD Nhóm 30 cũ (PTKT, 14 KPI) "khớp" với BA Nhóm 30 mới
  (bản đồ nhiệt, 14 dòng) chỉ vì trùng số lượng.

**Trình tự bắt buộc khi file BA vừa đổi:**
1. Chạy `ba_hld_sync_check.py --module {M}` **trước khi đọc bất kỳ Nhóm nào**. S3 liệt kê Nhóm lệch
   số hoặc lệch tên màn hình. S2 liệt kê STT bị BA dùng chung cho 2 màn hình, hoặc dòng bị gán nhầm
   STT (so theo cột Dashboard/báo cáo).
2. Lập bảng ánh xạ `số cũ → số mới` từ **cột Dashboard/báo cáo** (tên màn hình), không từ số lượng.
3. Đánh số lại **toàn bộ tham chiếu**: HLD (heading, bảng KPI, Section 1/3/4/5, changelog), Detail
   Mapping (cột `nhom`), Entities.md, comment Flat SQL, `description` trong Attributes/master/model
   (chỉ dòng của module mình). Ánh xạ phải áp **một lượt đồng thời** (VD 35→36 và 34→35 cùng lúc),
   không áp tuần tự từng số, vì áp tuần tự sẽ đẩy số lên 2 lần. Nhớ đổi cả số nằm trong danh sách
   `Nhóm 5/6/32/33`, không chỉ số đứng ngay sau chữ "Nhóm".
4. Sau đó mới thiết kế các Nhóm có nội dung đổi.

**BA gộp 2 màn hình chung 1 STT (S2):** mặc định gộp vào 1 Nhóm HLD theo quy tắc "1 STT = 1 Nhóm",
dùng mockup (a)/(b) và **mở Open Issue để BA tách STT**. Khi BA tách xong, tách lại HLD ngay; không để
Δ âm dai dẳng.

**Dòng BA gán nhầm STT (S2, 1–2 dòng mà Dashboard là của Nhóm khác):** thiết kế theo **Dashboard**,
ghi Open Issue. Không tự sửa file BA.

### H7 — Khóa JOIN giữa 2 bảng nguồn phải có BẰNG CHỨNG, không chép từ ghi chú cũ `[L1-JOIN-KEY-UNVERIFIED]`

Ghi chú trong HLD kiểu *"khóa X = Y đã xác nhận"* **không phải bằng chứng**. Trước khi dùng một khóa
JOIN giữa 2 entity khác hệ định danh, bắt buộc có ít nhất 1 trong 3 nguồn sau, và ghi rõ nguồn vào
Ghi chú:
1. SQL tham khảo của BA nối đúng 2 cột đó. Grep toàn file BA qua `ba_slice.py --with-sql`, **không
   chỉ Nhóm đang làm**.
2. Mô tả cột trong `Source/{SOURCE}_Columns.csv` hoặc tài liệu API nguồn (VD bảng getIndexCode/getIndexName
   của jadapter).
3. Data Modeler xác nhận trực tiếp **trong phiên hiện tại**, kèm ví dụ giá trị.

Thực tế đã sai: ghi chú ngày 2026-09-22 dùng khóa `Market Index Snapshot.Index Name = Index Constituent
Snapshot.Index Code`, và khóa này bị chép sang Fact mới cùng 4 KPI khác. Nhưng SQL BA STT 5 nối
`marketcode = indexcode`, và `INDEXNAME` chỉ là tên hiển thị (`VNINDEX`, `VN30`), còn mã là `HOSE`,
`30`. Hậu quả: khóa không bao giờ khớp và toàn bộ điểm chỉ số ra NULL. Dấu hiệu nhận biết sớm: khi thấy
một cột **tên** (`_nm`, `Name`) được đặt bằng một cột **mã** (`_code`), dừng lại kiểm tra.

### H8 — Loại measure (Giá trị vs Khối lượng) phải khớp Trường nguồn BA `[L3-MEASURE-TYPE-MISMATCH]`

Khi dùng lại KPI có sẵn cho một dòng BA, phải đối chiếu **Trường nguồn** của dòng đó (VD
`foreignBuyVal` là giá trị, `foreignBuyVol` là khối lượng), không chỉ nhìn tên màn hình hay tên Nhóm.
Thực tế đã sai: Nhóm 26 có BA ghi "GTNN mua/bán/ròng" (`foreignBuyVal`/`foreignSellVal`), nhưng HLD
dùng lại KLNN (K_GSTT_70/71/19, khối lượng), và tên Nhóm cũng bị ghi thành "bản đồ nhiệt KLNN".
S5 của `ba_hld_sync_check.py` bắt được lỗi này.

### H9 — Đối soát NỘI DUNG từng dòng BA, không chỉ số lượng `[L3-BA-ROW-UNMAPPED]`

`Δ = 0` không có nghĩa là không thiếu gì. Một dòng BA bị bỏ sót vẫn có thể bị che bởi một KPI tách
thêm ở chỗ khác. Thực tế đã sai: Nhóm 7 thiếu "Thay đổi giá (+/-)" nhưng lại dư Từ ngày/Đến ngày, nên
tổng số lượng lệch rất ít. Nhóm 11/13/15/17/19 cùng thiếu dòng này.

Sau khi viết xong bảng KPI của một Nhóm, chạy `ba_hld_sync_check.py --module {M} --nhom {N}` và xử lý
**từng** cảnh báo S4:
- bổ sung KPI còn thiếu, hoặc
- ghi giải trình vào Ghi chú HLD (VD dòng BA trùng nghĩa với dòng khác, dòng BA bị BA gán nhầm STT).

> Các quy tắc H10–H13 dưới đây rút ra từ phiên 2026-09-24/25 (NDTNN/PTTT/TKNB/GSTT). Mỗi quy tắc
> tương ứng 1 lỗi thật đã phải hoàn tác hoặc sửa lại.

### H10 — Thứ tự ưu tiên khi đọc 1 dòng BA: Điều kiện chung/Mô tả > Câu lệnh tham khảo có Note "cần check" `[L3-REFERENCE-SQL-MISALIGNMENT]`

Câu lệnh tham khảo có thể là bản cũ. Ví dụ GSTT Nhóm 35 dòng 515: SQL còn bảng mã phân loại NĐT theo
từng sàn, nhưng Note ghi "Cần check lại điều kiện" và Điều kiện chung chỉ ghi "phân loại theo Invest
Type / Client-House / Foreigner type" — tức là dùng chung quy tắc của Nhóm 28–31. Đã từng thiết kế
theo SQL cũ và phải làm lại.
- Khi SQL và Điều kiện chung / Mô tả mâu thuẫn: theo Điều kiện chung / Mô tả, ghi mâu thuẫn vào Open Issue.
- Khi dòng BA có Note kiểu "cần check lại": **không** coi SQL là quy tắc chốt; hỏi Data Modeler.

### H11 — Cột/công thức dùng chung nhiều Nhóm: đọc BA của MỌI Nhóm tiêu thụ trước khi đổi `[L3-SHARED-RULE-DRIFT]`

Trước khi sửa `etl_logic` của một cột, grep Detail Mapping xem những KPI/Nhóm nào đang dùng cột đó
(`logic` chứa `{table}.{column}`), rồi đọc BA của **từng** Nhóm đó. Ví dụ đã sai:
- 8 cột Cá nhân/Tổ chức trên `fct_stock_portfolio_snpst` chỉ phục vụ Nhóm 35, nhưng được sửa theo BA Nhóm 28 mà chưa đọc Nhóm 35 (khác nhau ở bộ lọc bảng lệnh).
- Khi BA đơn giản hóa quy tắc phân loại (2026-09-22), chỉ 2 Fact mới được cập nhật, còn 8 cột cũ cùng khái niệm giữ quy tắc cũ.

Khi BA đổi một quy tắc nghiệp vụ, grep toàn module mọi `etl_logic` hiện thực cùng quy tắc (VD `client_house_cl_code`, `investor_tp_code`) và sửa **đồng loạt** hoặc ghi rõ lý do giữ khác.

### H12 — BA chuyển Nhóm sang nguồn/bảng mới: kiểm bảng cũ còn KPI nào dùng không `[L2-TABLE-ZERO-USAGE]`

Khi Nhóm chuyển sang Fact mới, bảng cũ có thể còn đủ 3 tầng LLD/Entities/Flat nên Gate 3 vẫn PASS,
dù 0 KPI dùng (VD `opr_public_company_shareholding`, `legal_entity_position_dim` — GSTT 2026-09-25).
Chạy Gate 8 (`check_design_lint.py`), cảnh báo `L2-TABLE-ZERO-USAGE` nghĩa là phải:
- All-Tier Cleanup (xóa LLD per-table, dòng master, entity trong `datamart_model.yaml`, Entities.csv/.md, flat SQL), **và**
- giữ lịch sử ở Section 4 HLD với `reuse_status = DEPRECATED`.

### H12b — Trước khi kết luận "thiếu", đọc quyết định đã duyệt của đúng KPI `[process]`

Đọc `ghi_chu` Detail Mapping và Ghi chú HLD của KPI trước khi đề xuất bổ sung/đổi cách khai thác. Đã đề xuất nhầm "Nhóm 28 thiếu chế độ Khớp lệnh" trong khi ghi chú 2026-09-23 ghi rõ BI swap sang KPI khớp lệnh riêng (Data Modeler duyệt, không CASE tham số).

### H13 — Sửa bảng Markdown trong HLD: mỗi dòng KPI đúng 7 ô; giải trình ánh xạ phải tra lại KPI thật `[L1-HLD-KPI-ROW-CELLS]`

- Thêm ghi chú vào dòng KPI thì **gộp vào ô Ghi chú**, không chèn `| ... |` thành ô mới (đã sinh dòng 8 ô ở PTTT K_PTTT_44). Gate 8 bắt lỗi này.
- Khi viết giải trình "dòng BA N → K_xxx", lấy K_xxx từ bảng KPI của chính Nhóm đó (grep tên KPI), **không** suy theo tên gần giống (đã ghi nhầm dòng 188 TradingValue_i → K_PTTT_96 thay vì K_PTTT_270).
- Khối entity trong erDiagram của một bảng đã xuất hiện ở Nhóm khác phải chép **nguyên văn** khối đang có (Gate 5 #11 `L1-INCONSISTENT-ENTITY-BLOCKS`).


### H14 — Chọn chỉ số (VN-Index, VN30…) trên `market_index_snapshot`: giữ `market_code = 'HOSE'` (đảo quyết định 2026-10-21) `[process]`

> **[QUYẾT ĐỊNH HIỆN HÀNH — Data Modeler 2026-10-21, revert `48e849c5`]** BA ghi `IndexCode = 'VNINDEX'` / `indexname = 'VNINDEX'` là **BA nhầm**. Lọc VN-Index trên `market_index_snapshot` bằng `market_code = 'HOSE'` (+ `PARTITION BY market_code, trading_dt` ở bước bản ghi cuối ngày). KHÔNG đổi sang `index_nm = 'VNINDEX'` dù BA CSV/SQL có chữ `indexname`. Phần mô tả dưới đây là lịch sử quyết định 2026-10-20 (đã bị đảo) — chỉ giữ các bước quy trình (liệt kê đủ cột entity, không chép quyết định Nhóm này sang Nhóm khác, mở đúng dòng BA).

Điều kiện BA kiểu `IndexCode = 'VNINDEX'` (hoặc `marketCode = 'VNINDEX'`) → ở Atomic `market_index_snapshot` viết
`market_index_snapshot.index_nm = 'VNINDEX'` (`index_nm` ← `MDDS.JAD_MARKETINFOR.INDEXNAME`). Data Modeler chốt 2026-10-20:
nguồn không có cột `IndexCode`, BA gọi sai tên cột; `'VNINDEX'` là **giá trị của `INDEXNAME`**. Giữ nguyên literal của BA,
chỉ đổi tên cột sang cột Atomic thật. KHÔNG thay bằng `market_code = 'HOSE'`.

Sự cố gốc (PTTT, lộ ra 2026-10-20 khi user hỏi vì sao `fct_market_risk_snpst` lọc `HOSE` trong khi BA ghi `VNINDEX`):
1. Ghi chú HLD 2026-07-30 kết luận "entity KHÔNG có cột mã chỉ số — chỉ có `Market Code`/`Market Id`/`Index Type Code`". Sai: entity còn
   có `index_nm` (`INDEXNAME`). Cột BA ghi mà không grep thấy ở Atomic **không** đồng nghĩa entity không có cột tương ứng.
2. Quyết định đó chỉ chốt cho Nhóm 1&2 nhưng lan sang Nhóm 4/5/6 (qua "đồng bộ Attributes" 2026-09-07), khoảng 10 cột của
   `fct_market_risk_snpst` (`vnindex_val`, `vnindex_daily_return`, `vnindex_val_previous_day`, `volatility_30_days`,
   `index_log_return`, `index_val_monthly_average`…) mà không ai đọc lại BA Nhóm 4.
3. HLD ghi "BA dòng 107" cho điều kiện `market_code = 'HOSE'`, nhưng dòng BA đó ("Thời gian") để trống điều kiện. Các dòng BA Nhóm 4
   Systemic vol / Độ lệch chuẩn 20 phiên / Lợi suất ngày / Giá t / Giá t−1 đều ghi `IndexCode = 'VNINDEX'`, không dòng nào ghi `HOSE`.
4. Literal BA bị đổi (`VNINDEX` → `HOSE`) mà không kèm bằng chứng giá trị (không profile dữ liệu, không xác nhận trong phiên).

Cách làm:
1. Cột BA ghi không có ở entity Atomic: liệt kê ĐỦ `physical_name` + `source_column` của entity
   (`grep -n "physical_name:\|source_column:" DataModel/Atomic/Group/dm_atm_{entity}-*.yaml`) và mô tả cột trong
   `BRD/Source/{SRC}/brd_*.yaml` — tìm cột `_nm`, `_tp_code`, `_code` — rồi mới kết luận "không có" hoặc chọn cột đại diện.
2. Giữ literal BA. Đổi literal (VD `VNINDEX` → `HOSE`) chỉ khi có giá trị thật (1 dòng mẫu đã ẩn danh) hoặc Data Modeler xác nhận
   trong phiên; ghi nguồn bằng chứng vào Ghi chú.
3. Quyết định chốt cho Nhóm A không tự áp sang Nhóm B (H11): đọc điều kiện BA của từng Nhóm; "BA dòng N" ghi trong HLD phải mở
   dòng N kiểm tra điều kiện có thật.
4. Bước lấy bản ghi cuối ngày: `PARTITION BY` phải chứa cột định danh chỉ số đang dùng ở `WHERE` (`index_nm`).

Ranh giới với H7: H14 chỉ nói về điều kiện **lọc literal** chọn 1 chỉ số. Khóa JOIN Market Index Snapshot ↔ Index Constituent vẫn
theo H7 (`market_code = index_code`, SQL BA STT 5 GSTT) — KHÔNG nối `index_nm = index_code`: INDEXNAME là tên hiển thị (`VNINDEX`,
`VN30`) còn `index_code` là mã (`HOSE`, `30`).

Cách kiểm: `grep -n "market_code = 'HOSE'" Datamart/lld/{M}/*.csv Datamart/hld/DTM_{M}_HLD.md`; mỗi chỗ dùng để chọn VN-Index
phải đối chiếu BA của từng Nhóm tiêu thụ.

## Ghi chú lịch sử

Lô 5 luật đầu tiên (H1–H5) — ghi chú gốc:

> Rút ra từ sự cố PTTT/QLKD ngày 2026-09-18. Cả 5 quy tắc đều là lỗi **thật đã lọt lưới**,
> không phải rủi ro giả định. Mã lỗi tương ứng nằm trong Gate 0 (`check_references.py`) và
> Gate 5 (`check_hld_5b.py`).
