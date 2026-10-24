# Luật chống tái diễn A1–A26 — LLD Datamart

Bản đầy đủ của bảng tóm tắt trong `SKILL.md`: mỗi luật kèm ví dụ sai thực tế, cách kiểm và lệnh liên quan. Đọc đúng mục cần dùng, ví dụ `grep -n "^### A19" .claude/skills/datamart-lld-design/reference/rules.md`, không cần đọc cả file.

## Mục lục

- A1 — CẤM tự đặt tên cột Atomic `[L0-ATOMIC-COLUMN-NOT-FOUND]`
- A2 — CẤM tự đặt tên cột Mart trong Detail Mapping `[L0-MART-COLUMN-NOT-FOUND]`
- A3 — Ghi CSV bắt buộc qua `csv.writer`, cấm nối chuỗi `[L0-CSV-STRUCTURE-BROKEN]`
- A4 — Nâng READY ở LLD phải đồng bộ ngược lên HLD `[L0-HLD-LLD-STATUS-DESYNC]`
- A5 — Reuse Fact xuyên module: grain là hợp đồng, không được diễn giải lại `[L1-GRAIN-MISMATCH]`
- A6 — Đóng Open Issue: mặc định là "Resolved một phần"
- A7 — Không áp convention của module khác lên file đang sửa
- A8 — Window function: cửa sổ phải chạy trên cột ngày, không trên surrogate key
- A9 — Registry: chỉ append/patch, cấm dump lại toàn file
- A10 — Ghi chú "đã lọc sẵn tại ETL" phải trích được `etl_logic` thật `[L3-REFERENCE-SQL-MISALIGNMENT]`
- A11 — Kiểm toàn vẹn Detail Mapping TRƯỚC khi sửa `[L0-DM-FILE-INTEGRITY]`
- A12 — Không kết luận cột Atomic thiếu/rỗng chỉ từ YAML LLD `[L0-ATOMIC-PHYSICAL-UNVERIFIED]`
- A13 — Câu trả lời 1 chữ cho câu hỏi kép: xác nhận lại nghĩa trước khi sửa `[process]`
- A14 — PII đã mã hóa từ nguồn: lên Datamart như cột thường; KHÔNG chặn, KHÔNG "ngoại lệ", KHÔNG hạ PENDING `[process]`
- A15 — Comment trong flat SQL không viết `:etl_date` dính dấu câu `[L4-FLAT-COMMENT-PARAM]`
- A16 — Cột Atomic của dòng NHIỀU bảng phải ghi `bảng.cột` `[L0-MULTI-TABLE-COLUMN-NOT-FOUND]`
- A17 — Nối `securities_trade` ↔ `security_trading_snapshot`: HNX nối bằng ISIN `[L3-HNX-ISSUE-CODE-JOIN]`
- A18 — Chỉ tiêu theo mã CK × ngày: dùng `security_trading_snapshot` cuối ngày, không tổng hợp lại từ `securities_trade` `[L3-CUMULATIVE-SNAPSHOT-NOT-DEDUPED]`
- A19 — Bảng Atomic snapshot/event: MỌI tham chiếu phải có giới hạn ngày tường minh `[L2-DATE-BOUND-MISSING]`
- A20 — Cột mới ở Fact/Operational phải lên flat DDL + DML TRONG CÙNG LƯỢT `[L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING]`
- A21 — Lọc chỉ số trên `market_index_snapshot`: giữ `market_code = 'HOSE'` (đảo quyết định `index_nm`, 2026-10-21) `[process]`
- A22 — Mọi Fact khai báo khóa dòng (`key = PK`); flat `ORDER BY` chứa PK `[L2-FACT-NO-ROW-KEY]`
- A23 — PK Dimension = id Atomic khi có cột khác carry id đó `[L2-DIM-PK-GENERATED-CARRIED]`
- A24 — `bảng.cột` viết trong `logic` Detail Mapping và công thức HLD phải tồn tại thật `[L0-DM-LOGIC-COLUMN-NOT-FOUND]`
- A25 — Thuộc tính trùng tên ở nhiều bảng Atomic: bảng nguồn do SQL BA dùng quyết định `[L3-SOURCE-TABLE-MISMATCH]`
- A26 — Kiểm kê MỌI điều kiện của SQL BA; "Active-only" chỉ miễn điều kiện slicer thời gian `[L3-BA-FILTER-UNMAPPED]`
- Lệnh bổ sung — Gate 8 Design Lint
- Ghi chú lịch sử

### A1 — CẤM tự đặt tên cột Atomic `[L0-ATOMIC-COLUMN-NOT-FOUND]`

Mọi `atomic_column` và mọi tham chiếu `bảng.cột` trong `etl_logic` phải **grep được trong YAML Atomic thật**.

| Đã viết sai (thực tế) | Tên đúng trong YAML |
|---|---|
| `cl_risk_indicator.cl_risk_ind_name` | `ind_nm` |
| `sc_periodic_report.submission_dt` | không tồn tại → dùng `sent_tms` |
| `sc_periodic_report.record_status` | `rpt_submission_status_code` |
| `sc_report_input_value.numeric_val` | `item_val` |
| `security_trading_snapshot.security_symbol_code` | `symbol` |
| `sc_alert_indicator.indicator_code` | `ind_code` |

Cách kiểm nhanh 1 cột trước khi viết:
```bash
grep -rn "physical_name: \"\?{column}" DataModel/Atomic DataModel/working/Atomic/lld
```
**Đừng suy tên cột từ tên thuộc tính nghiệp vụ.** `Name` không đồng nghĩa `_name`; nhiều entity dùng `_nm`, `_cd`, `_ind`.

### A2 — CẤM tự đặt tên cột Mart trong Detail Mapping `[L0-MART-COLUMN-NOT-FOUND]`

`mart_column` phải tồn tại trong Attributes CSV của chính bảng đó (chấp nhận tên physical hoặc logical,
nhưng phải là **một trong hai** — không được bịa tên thứ ba).

Thực tế đã sai: Detail Mapping PTTT/QLKD trỏ tới `margin_balance_amt`, `owner_equity_amt`,
`total_debt_amt`, `financial_leverage_ratio`, `capital_adequacy_ratio`, `active_account_count`,
`client_deposit_balance_amt` — **không cột nào tồn tại**. Bảng nguồn thực tế là Fact EAV chỉ có
duy nhất `indicator_val_amt` + FK `report_indicator_dim_id`.

> **Dấu hiệu nhận biết sớm:** nếu Fact là EAV (một cột giá trị + một chiều chỉ tiêu) mà bạn đang
> viết ra 5–10 tên cột nghiệp vụ khác nhau → chắc chắn sai. Mọi measure phải là
> `SUM(<fact>.indicator_val_amt) WHERE <dim>.indicator_code = '...'`.

### A3 — Ghi CSV bắt buộc qua `csv.writer`, cấm nối chuỗi `[L0-CSV-STRUCTURE-BROKEN]`

`etl_logic` thường chứa dấu phẩy (`hash_id('X', y)`, `LPAD(..., 2, '0')`, `IN ('A','B')`).
Nối chuỗi thủ công làm vỡ dòng → 4 file LLD QLKD từng có dòng 16–19 cột trong khi header 15 cột.

```python
with open(path, "w", encoding="utf-8", newline="") as f:
    csv.writer(f, quoting=csv.QUOTE_ALL, lineterminator="\n").writerows(rows)
```
Sau khi ghi, **luôn đọc lại và đối chiếu số cột từng dòng** với header.

### A4 — Nâng READY ở LLD phải đồng bộ ngược lên HLD `[L0-HLD-LLD-STATUS-DESYNC]`

Trạng thái KPI tồn tại ở **hai nơi**: bảng KPI trong HLD (cột `Trạng thái`) và Detail Mapping
(4 cột `mart_table`/`mart_column`/`column_role`/`logic`). Sửa một bên mà quên bên kia là lỗi đã xảy ra
trên diện rộng (HLD ghi PENDING trong khi Detail Mapping đã điền mapping đầy đủ).

- Nâng PENDING → READY: sửa **cả** dòng KPI trong HLD **và** dòng Detail Mapping.
- Hạ READY → PENDING: để trống đủ 4 cột Detail Mapping (Rule L4) **và** sửa cột `Trạng thái` trong HLD.
- Ngoại lệ hợp lệ duy nhất: `column_role = DERIVED`/`DEPRECATED` được phép trống 2 cột mart.

### A5 — Reuse Fact xuyên module: grain là hợp đồng, không được diễn giải lại `[L1-GRAIN-MISMATCH]`

Khi module B reuse Fact của module A:
1. Copy **nguyên văn** chuỗi grain từ Entities.csv của module A. Cấm viết lại theo cách hiểu của mình.
2. Cột `source_table` của module B ghi **entity Atomic của module A**, tuyệt đối không ghi tên bảng
   Datamart (`fct_*`) — đó không phải nguồn Atomic.
3. Đối chiếu grain đó với công thức đang định viết. Fact grain **kỳ báo cáo** không đỡ được
   `ROWS BETWEEN 19 PRECEDING` theo **phiên giao dịch**.

Thực tế đã sai: cùng `fct_securities_company_financial_structure_snpst` được khai 3 grain khác nhau
ở 3 nơi (1 CTCK/ngày — 1 CTCK × 1 tháng — 1 CTCK × 1 kỳ × 1 chỉ tiêu).

### A6 — Đóng Open Issue: mặc định là "Resolved một phần"

Khi nguồn Atomic mới xuất hiện, **không** đánh dấu issue là "ĐÃ GIẢI QUYẾT" cho toàn bộ danh sách KPI
đính kèm. Bắt buộc:
1. Liệt kê rõ KPI nào chuyển READY và **ở grain nào**.
2. KPI còn lại → tách sang Open Issue mới, ghi lý do cụ thể.
3. Trạng thái issue gốc → `Resolved một phần`.

Thực tế đã sai: O_PTTT_11 và O_PTTT_13 bị đóng toàn phần trong khi nhóm chỉ tiêu grain ngày vẫn
không có nguồn — kéo theo 9 KPI bị đánh READY sai.

### A7 — Không áp convention của module khác lên file đang sửa

Trước khi thêm dòng vào một CSV có sẵn, **đếm giá trị đang dùng** ở cột `column_role` và `tinh_chat`
rồi theo đa số của chính file đó:

```bash
python -c "import csv,collections;r=list(csv.reader(open('<file>',encoding='utf-8-sig')));print(collections.Counter(x[8] for x in r[1:]))"
```

PTTT dùng `MEASURE/SLICER/DERIVED/FILTER` + `Base/Phái sinh`; QLKD dùng `MEASURE/SLICER/FILTER` +
`Cơ sở/Chiều`. Trộn lẫn (`Measure`, `Dimension`, `Attribute`, `Thuộc tính`) làm linter và BI layer sai.
Tương tự: `mart_table` ghi tên **logical** — không trộn physical.

### A8 — Window function: cửa sổ phải chạy trên cột ngày, không trên surrogate key

- Đủ mệnh đề: `PARTITION BY <entity>` + `ORDER BY <date_col> ASC` + `ROWS BETWEEN n-1 PRECEDING AND CURRENT ROW`.
- Số phiên chuẩn: 52W = 260, 6M = 130, 3M = 65, 1M/MA20 = 20, MA10 = 10, MA5 = 5.
- **CẤM** `ORDER BY snpst_dt_dim_id` và `TRUNC(snpst_dt_dim_id, 'MM')` — khoá đại diện không đảm bảo
  thứ tự thời gian. Gom nhóm theo tháng phải qua `cdr_dt_dim.cdr_year` / `.cdr_month`.
- **CẤM** ghi tắt `OVER 20 phiên` — phải viết đủ mệnh đề cửa sổ.

### A9 — Registry: chỉ append/patch, cấm dump lại toàn file

`Datamart/datamart_model.yaml` chứa 28 dòng comment header là quy tắc ghi registry.
Ghi lại bằng `yaml.dump()` xoá sạch comment và reformat 100% file (diff 27.885 dòng để thêm 6 entity).

- Thêm entity: đọc file, nối thêm block text đúng định dạng thủ công, giữ nguyên phần còn lại.
- Sửa 1 entity: patch đúng block đó.
- Sau khi ghi: `python -c "import yaml;yaml.safe_load(open('Datamart/datamart_model.yaml',encoding='utf-8'))"`
  và kiểm `grep -c '^#'` vẫn còn đủ dòng comment.
- `source_atomic_table`/`source_atomic_column` là **chuỗi**, không phải list — `"['x']"` là lỗi serialize.

### A10 — Ghi chú "đã lọc sẵn tại ETL" phải trích được `etl_logic` thật `[L3-REFERENCE-SQL-MISALIGNMENT]`

Quy tắc L17 cho phép thay điều kiện trong `WHERE` của MEASURE (hoặc dòng FILTER) bằng ghi chú *"đã lọc sẵn tại ETL Fact"*, nhưng chỉ khi điều
kiện đó **thực sự có trong `etl_logic`** của Fact. Trước khi viết ghi chú này, grep đúng điều kiện
trong file Attributes:

```bash
grep -n "stock_tp_code\|floor_code" Datamart/lld/{MODULE}/DTM_{MODULE}_{fact}.csv
```

Nếu không grep thấy, phải đưa điều kiện vào `logic` của dòng SLICER/MEASURE (KPI không có MEASURE thì tạo dòng FILTER).
Thực tế đã sai: GSTT Nhóm 29 ghi `FloorCode IN ('10','02','04')`, `StockType NOT IN ('B','1','BO','D')`
là "đã lọc sẵn tại ETL `fct_investor_category_trading_snpst`", nhưng ETL của Fact đó chỉ lọc
`market_id_code`.

Cùng tinh thần H7 bên skill HLD: khóa JOIN giữa 2 entity nguồn (VD `market_code = index_code`) trong
`etl_logic` phải có bằng chứng từ SQL tham khảo BA hoặc tài liệu cột nguồn. Không chép từ ghi chú
"đã xác nhận" của lượt trước.

### A11 — Kiểm toàn vẹn Detail Mapping TRƯỚC khi sửa `[L0-DM-FILE-INTEGRITY]`

Detail Mapping là file lớn, nhiều người cùng sửa. Thực tế đã xảy ra:
1. Commit của module khác (`1b7b7011`, TKNB) cắt `DTM_GSTT_Detail_Mapping.csv` từ 577 xuống 101 dòng — hư hỏng thật.
2. File bị xóa khỏi working copy giữa phiên.
3. **QLQ 2026-10-14 — KHÔNG phải hư hỏng:** user chủ động cắt `DTM_QLQ_Detail_Mapping.csv` từ 2699 xuống 183 dòng
   (bỏ Nhóm 29–91, "không cần quan tâm nhóm dashboard nữa"), phiên khác ghi quyết định vào MEMORY.md. Số liệu y
   hệt một vụ mất dữ liệu (S1 FAIL, TC5 thiếu 63 Nhóm); một phiên đã "khôi phục" nối lại 2516 dòng và phải hoàn tác.
   **Bài học: S1 không phân biệt được cắt chủ ý với hư hỏng — người đọc phải phân biệt.**

**Khi S1 báo cắt: dừng ghi, KHÔNG tự khôi phục.** Theo thứ tự:
1. Đọc lại `MEMORY.md` (đặc biệt mục mới) — phiên song song có thể vừa ghi quyết định cắt/gộp có chủ ý.
2. `ls -l --time-style=full-iso` DM/HLD/master: mtime vài phút trước ⇒ phiên khác đang ghi cùng working tree.
3. Hỏi human kèm đường dẫn bản sao lưu đầy đủ gần nhất; chỉ khôi phục sau khi human xác nhận là hư hỏng.
   "Bổ sung"/"rà" không phải xác nhận khôi phục. Khôi phục = NỐI phần mất vào bản hiện tại (không chép đè bản
   backup — bản đang có thể chứa sửa hợp lệ sau thời điểm backup).
Cắt chủ ý được human xác nhận thì cờ S1 hết khi human **commit** bản mới (HEAD đổi) — không cần "sửa" gì.

Chốt chặn hiện có (không thay cho việc tự kiểm đầu phiên):
- `run_quality_gates.py` có **Pre-flight S1** chạy đầu tiên và tính vào kết quả tổng — file co > 20% so với HEAD là FAIL ngay
  (kể cả khi cắt chủ ý, cho tới khi commit).
- `apply_patch.py` **từ chối ghi** (kể cả `--dry-run`) nếu file co > 20%; chỉ vượt được bằng `--allow-shrink` sau khi human duyệt.
- Script ad-hoc tự viết ghi thẳng Detail Mapping/HLD không có chốt này — tự so số dòng trước/sau và dừng nếu tụt > 20%.

Đầu mỗi phiên sửa LLD, và ngay trước mỗi `apply_patch.py --target dm`, chạy:

```bash
python .claude/skills/datamart-review/scripts/ba_hld_sync_check.py --module {MODULE} --nhom {N}
```

Mục S1 dừng hẳn nếu file không tồn tại, nếu working copy ít hơn 80% số dòng của HEAD, hoặc nếu HEAD
ít hơn 80% số dòng của HEAD~1. Cách khôi phục:
- Lấy bản mới nhất trong `Datamart/context/.backup/` hoặc từ `git show HEAD~1:...`.
- Áp lại các patch đã ghi sau bản sao lưu đó, rồi mới làm tiếp.
- Nếu file bị xóa mà không rõ lý do, **hỏi human trước khi khôi phục**, vì có thể họ xóa có chủ ý.

> A12–A15 rút ra từ phiên 2026-09-24/25. Xem thêm H10–H13 trong `datamart-hld-design/reference/rules.md`
> (thứ tự ưu tiên đọc BA, quy tắc dùng chung nhiều Nhóm, bảng 0 KPI, bảng Markdown).

### A12 — Không kết luận cột Atomic thiếu/rỗng chỉ từ YAML LLD `[L0-ATOMIC-PHYSICAL-UNVERIFIED]`

YAML LLD Atomic có thể không khai báo cột mà bảng vật lý vẫn có. Ví dụ: `lld_ORDERTRADE_TRADE_BOOK_HNX.yaml`
không có `execution_val`, nhưng `uat_atm.securities_trade` dòng HNX vẫn có giá trị (= Trade price × Trade
quantity). Đã sửa sai 37 cột GSTT/NDTNN sang `execution_price × execution_vol` và phải hoàn tác.
Trước khi sửa hàng loạt vì "cột không tồn tại/rỗng":
1. Đối chiếu `BRD/Source/{SRC}/brd_*.yaml` của **cả hai** nguồn (HOSE và HNX…) và file mapping md.
2. Hỏi Data Modeler xác nhận bằng dữ liệu vật lý (1 dòng mẫu đã ẩn danh là đủ).
3. Nếu YAML thiếu mà bảng vật lý có → ghi đề xuất cho Atomic Team, **không** đổi `etl_logic` Datamart.

### A13 — Câu trả lời 1 chữ cho câu hỏi kép: xác nhận lại nghĩa trước khi sửa `[process]`

"có"/"không"/"ok" cho câu hỏi dạng "kiểm tra xem X có … không" là mơ hồ (có dữ liệu? hay có lỗi?).
Đã hiểu "4 có" thành "HNX bị rỗng" trong khi ý là "có giá trị". Trước khi thực hiện thay đổi lớn
(≥ 5 cột hoặc nhiều module), nhắc lại cách hiểu bằng 1 câu và chờ xác nhận.

### A14 — PII đã mã hóa từ nguồn: lên Datamart như cột thường; KHÔNG chặn, KHÔNG "ngoại lệ", KHÔNG hạ PENDING `[process]`

Số giấy tờ định danh (CMND/CCCD/hộ chiếu — `identification_nbr`), số tài khoản… **đã được mã hóa từ nguồn**
(Data Modeler xác nhận 2026-10-14). Vì vậy: khi BA yêu cầu hiển thị/lọc theo các trường này thì tạo cột Datamart/flat
table bình thường (map từ `ip_alternative_identification.identification_nbr`, `*_account_nbr`…).
- **Cấm** tự đặt "ngoại lệ quy tắc PII", cấm chặn cột, cấm đánh PENDING hoặc "không xuất cột" với lý do PII/NĐ 13/2023.
- Quy tắc cũ "PII chỉ dùng để JOIN, không thành cột" (A14 trước 2026-10-14, `[L2-PII-IN-MART]`) **đã bãi bỏ**.
- Khi nghiệp vụ không cần hiển thị giá trị mà chỉ cần phân biệt chủ thể, vẫn ưu tiên surrogate của Atomic làm grain key
  (VD `major_shareholder_ownership_id`) — đây là lựa chọn thiết kế, không phải ràng buộc PII.
- Chỉ báo user **1 câu** nếu dữ liệu mẫu thật sự cho thấy cột là plaintext; không tự chặn.

### A15 — Comment trong flat SQL không viết `:etl_date` dính dấu câu `[L4-FLAT-COMMENT-PARAM]`

`check_flat_table.py` quét cả dòng comment; `-- ... = :etl_date. Chuỗi …` bị hiểu là tham số lạ →
Gate 4 FAIL giả. Trong comment viết "ngày chạy ETL" thay cho `:etl_date`. Gate 8 bắt lỗi này.

### A16 — Cột Atomic của dòng NHIỀU bảng phải ghi `bảng.cột` `[L0-MULTI-TABLE-COLUMN-NOT-FOUND]`

Dòng có `atomic_table = a / b / c` mà `atomic_column` chỉ liệt kê tên cột trần (`close_price / outstanding_share_quantity / val`) làm người đọc
và script KHÔNG biết cột nào thuộc bảng nào (`build_model_yaml` từng sinh `a / b / c.close_price / …` — trông như mọi cột đều của bảng cuối;
Gate 0 trước 2026-10-09 bỏ qua hẳn mọi dòng nhiều bảng nên cột sai vẫn PASS). Quy ước bắt buộc cho dòng ≥ 2 bảng:

- `source_entity` = `EntityA / EntityB`; `atomic_table` = `table_a / table_b`.
- `source_attribute` = `EntityA.AttrA / EntityB.AttrB`; `atomic_column` = `table_a.col_a / table_b.col_b` — **mỗi cột kèm bảng chứa nó**, bảng phải nằm trong `atomic_table`.
- Cột có thật trên bảng đó (grep YAML Atomic hoặc `mapping_*_atm.md` nếu bảng chưa có YAML, VD `listed_share_info`). Gate 0 kiểm chặt từng cặp (`CRITICAL` nếu cột không tồn tại trên bảng khai báo).
- Chỉ khi nhiều cột CÙNG 1 bảng mới dùng `col_a / col_b` (cột trần).

VD đúng: `atomic_table = security_trading_snapshot / listed_share_info / cl_risk_indicator_value`, `atomic_column = security_trading_snapshot.close_price / listed_share_info.outstanding_share_quantity / cl_risk_indicator_value.val`.

### A17 — Nối `securities_trade` ↔ `security_trading_snapshot`: HNX nối bằng ISIN `[L3-HNX-ISSUE-CODE-JOIN]`

`securities_trade.security_symbol_code` của **HNX là `ISSUE_CODE` (mã quốc tế/ISIN)**, của HOSE mới là mã CK (`symbol`). Nối `security_trading_snapshot.symbol = securities_trade.security_symbol_code` làm rơi toàn bộ giao dịch HNX. Công thức đúng: `(securities_trade.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' AND security_trading_snapshot.symbol = securities_trade.security_symbol_code) OR (securities_trade.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' AND security_trading_snapshot.isin_code = securities_trade.security_symbol_code)`, kèm lấy bản ghi cuối ngày của `symbol × trading_dt` (`ROW_NUMBER() OVER (PARTITION BY symbol, trading_dt ORDER BY trading_time DESC, sequence DESC) = 1`) để không nhân dòng. (Phát hiện 2026-10-09; NDTNN đã làm đúng từ 2026-09-18; PTTT còn 10 dòng LLD ở 4 bảng nối bằng `symbol` — `fct_sector_risk_snpst`, `fct_futures_investor_flow_snpst`, `fct_futures_intraday_snpst`, `fct_corporate_bond_market_snpst` — cần rà từng bảng, xem O_PTTT_38.)

Ngoại lệ có truy vết: nếu SQL BA CHÍNH nó nối `Issue_Code = symbol` (VD HĐTL DVX, trái phiếu HCX — mã hợp đồng/trái phiếu có thể trùng `symbol`) và chưa xác nhận được với dữ liệu thật, ghi `[HNX-KEY-REVIEWED <ngày>: <lý do>; O_xxx]` vào `description` của cột và mở Open Issue cho dev xác nhận khóa — D6 sẽ bỏ qua dòng đó. Marker không thay cho xác nhận: đóng Open Issue rồi sửa join hoặc bỏ marker.

### A18 — Chỉ tiêu theo mã CK × ngày: dùng `security_trading_snapshot` cuối ngày, không tổng hợp lại từ `securities_trade` `[L3-CUMULATIVE-SNAPSHOT-NOT-DEDUPED]`

`security_trading_snapshot` (MDDS.JAD_STOCKINFOR) đã có sẵn theo mã × ngày: `close_price`, `average_price` (giá khớp TB), `total_trading_vol`/`total_trading_val` (KL/GTGD **khớp** cộng dồn từ đầu ngày), `pt_total_traded_*` (thỏa thuận, tách riêng), `floor_code`. Khi BA cần GTGD/KL/giá khớp **theo mã CK theo ngày** (hoặc gộp theo nhóm mã/ngành/nhóm vốn hóa), ưu tiên nguồn này thay vì `SUM` lại `securities_trade`: cùng bản ghi với giá đóng cửa, không phải nối ISIN HNX (A17), không nhân dòng. `securities_trade` chỉ dùng khi cần grain giao dịch/lệnh, chiều board, loại NĐT, bên mua/bán… mà snapshot không có (VD NDTNN, Data Explorer sổ lệnh).

**Bắt buộc:** các cột cộng dồn (`total_trading_*`, `pt_total_traded_*`) mỗi ngày có nhiều bản ghi intraday, mỗi bản ghi là số cộng dồn tại thời điểm đó → luôn lấy bản tin cuối ngày của `symbol × trading_dt` (`ROW_NUMBER() OVER (PARTITION BY symbol, trading_dt ORDER BY trading_time DESC, sequence DESC) = 1`) rồi mới `SUM`/`AVG`. `SUM` trên mọi bản ghi sẽ nhân lặp. Gate 8 (D7) cảnh báo khi thiếu điều kiện `trading_time`.

**Quy tắc chọn bản tin MDDS (O_GSTT_64, 2026-10-13):** MDDS gửi nhiều bản tin trùng đúng `trading_time` (`JAD_STOCKINFOR`) / `index_time` (`JAD_MARKETINFOR`) nhưng khác giá, nên chỉ `MAX(trading_time)`/`ORDER BY trading_time DESC` cho kết quả ngẫu nhiên khi trùng — luôn thêm `sequence DESC` làm tiêu chí phụ. Cuối ngày theo mã: `PARTITION BY symbol, trading_dt ORDER BY trading_time DESC, sequence DESC`; current-state theo mã (Dimension/Operational): `PARTITION BY symbol ORDER BY trading_dt DESC, trading_time DESC, sequence DESC` (`trading_time` là giờ trong ngày, không chứa ngày nên phải có `trading_dt DESC` đứng đầu) — **luôn kèm giới hạn ngày theo A19-R5** (`trading_dt = :etl_date` hoặc cửa sổ lookback), cấm chạy `ROW_NUMBER` này trên toàn lịch sử tick; chỉ số: `PARTITION BY market_id, market_code, trading_dt ORDER BY index_time DESC, sequence DESC`; theo phút: `MAX_BY(val, STRUCT(trading_time, sequence))`. Join `security_trading_snapshot` theo (mã, ngày) chỉ để tra thuộc tính phải lọc `rn = 1` như trên, nếu không sẽ nhân dòng Fact. `security_trading_snapshot.sequence` chờ Atomic bổ sung (Gate 0 báo `L0-ATOMIC-COLUMN-NOT-FOUND` cho đến khi có). Lưu ý đối chiếu: bản ghi cuối ngày của snapshot có thể không phải số chốt của sở — dev đối chiếu với sổ lệnh trước khi chốt (ghi vào Open Issue).

### A19 — Bảng Atomic snapshot/event: MỌI tham chiếu phải có giới hạn ngày tường minh `[L2-DATE-BOUND-MISSING]`

> **Nguồn gốc (rà soát GSTT 2026-10-14):** 55 cell / 8 bảng Datamart đọc `securities_trade`, `securities_order`,
> `security_trading_snapshot`, `index_constituent_snapshot`, `market_index_snapshot` mà **không có điều kiện ngày**
> (hoặc chỉ có `trading_dt <= :etl_date` không chặn dưới) → mỗi lần chạy quét TOÀN BỘ lịch sử, bảng Fact event
> HLD ghi "append theo ngày" nhưng etl_logic không thể hiện. Không Gate nào bắt được (Gate 0–8 đều không đọc điều kiện ngày).
> **Gốc rễ nằm ở chính skill này:** các mẫu `lookup_date` trước đây KHÔNG có điều kiện ngày (đã sửa 2026-10-14),
> nên thiết kế đúng theo mẫu vẫn sai. Mẫu lỗi điển hình (dbt):
> `FROM {{ ref('atm_market_index_snapshot') }} WHERE market_code = 'HOSE' AND trading_dt <= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')`
> — chỉ chặn trên, không chặn dưới.

**Phạm vi — thế nào là bảng "snapshot/event":** Atomic có `table_type` = `Fact Snapshot` hoặc `Fact Append` trong
`DataModel/Atomic/dm_manifest.yaml`, cộng mọi bảng lưu theo kỳ có cột `ds_snpst_dt` (History companion `*_hstr`, VSDC ODS
như `listed_share_info`). Lưu ý: `securities_trade`/`securities_order` có thể không còn entry trong manifest (Atomic Team
gỡ YAML 2026-10-14) nhưng vẫn là bảng event — kiểm theo `table_type` ở YAML/mapping md, không theo việc có mặt trong manifest.
Bảng `Fundamental`/`Relative` (SCD4A/SCD2 current-state) **không** thuộc A19 — chúng lọc bằng `ds_rcrd_st = 'ACTIVE'`.

| Bảng Atomic | Cột ngày phải khóa |
|---|---|
| `security_trading_snapshot`, `market_price_snapshot`, `index_constituent_snapshot`, `market_index_snapshot`, `corporate_bond_trading_snapshot`, `security_match_log` | `trading_dt` |
| `securities_trade`, `securities_order` | `trade_dt` (sổ lệnh còn có `order_dt` — vẫn khóa theo `trade_dt`) |
| History `*_hstr`, `listed_share_info` | `ds_snpst_dt` |
| Bảng khác | tra YAML Atomic: cột kiểu `Date` đóng vai ngày sự kiện/snapshot |

**6 quy tắc bắt buộc:**

- **R1 — Driving phải khóa ngày.** Dòng `lookup_date` (`snpst_dt_dim_id` / `<role>_dt_dim_id`) của Fact có Driving là snapshot/event
  PHẢI chứa `<driving>.<cột ngày> = :etl_date` (hoặc `BETWEEN`), không chỉ `src_stm_code`. Dimension/Operational dựng từ snapshot
  cũng phải khóa ngày ở mỗi cell có `WHERE` (xem R5).
- **R2 — Bảng join thêm:** hoặc nối ngày bằng bằng với bảng đã bị khóa (`securities_trade.trade_dt = security_trading_snapshot.trading_dt`),
  hoặc tự có điều kiện ngày. Nối chỉ theo mã (symbol/ISIN) mà thiếu ngày = quét toàn lịch sử và nhân dòng.
- **R3 — Subquery/CTE/derived table phải khóa ngày BÊN TRONG**, kể cả khi outer JOIN đã nối ngày — không dựa vào optimizer đẩy
  điều kiện xuống. Điều kiện viết theo alias của chính subquery (`ics2.trading_dt = :etl_date`). Cấm `GROUP BY`/`ROW_NUMBER` trên toàn lịch sử rồi mới JOIN.
- **R4 — Cấm "mới nhất/as-of" không chặn dưới.** Cấm `MAX(trading_dt)`, `ROW_NUMBER() ... ORDER BY trading_dt DESC = 1`, `ds_snpst_dt <= X`
  chạy trên toàn lịch sử. Dùng `= :etl_date`, hoặc cửa sổ `BETWEEN (:etl_date − N) AND :etl_date` với N ghi rõ trong `description`
  (N theo phiên giao dịch → `cdr_dt_dim.is_trading_date`). As-of tới bảng History (VD `listed_share_info` lấy kỳ gần nhất ≤ ngày) cũng cần cận dưới,
  hoặc ghi ngoại lệ có truy vết (xem dưới).
- **R5 — Dimension/Operational dựng từ snapshot (current-state).** Nạp incremental `= :etl_date` (SCD4A upsert: bản ghi của ngày trước vẫn còn;
  lần nạp đầu/backfill phải chạy từng ngày). Nếu bảng nạp kiểu `TRUNCATE + INSERT` và grain là "bản ghi mới nhất / ngày giao dịch mới nhất"
  thì `= :etl_date` làm bảng RỖNG khi ETL chạy vào ngày không có bản tin → dùng cửa sổ lookback bó theo R4, ghi N, và hỏi Data Modeler (A13)
  — grain "mới nhất" thường là quyết định đã duyệt ở HLD, không tự đổi sang `= :etl_date`.
- **R6 — LAG/LEAD/window liên ngày.** Bảng đã khóa `= :etl_date` chỉ còn 1 ngày → `LAG(...) OVER (ORDER BY trading_dt)` luôn NULL. Muốn giá trị kỳ trước phải
  (a) mở cửa sổ ở dòng khóa ngày: `BETWEEN <phiên T−k> AND :etl_date`, hoặc (b) đọc cột kỳ trước có sẵn ở nguồn (VD `market_index_snapshot.prior_index`),
  hoặc (c) lấy từ chính Fact ở kỳ trước. Cấm khai LAG liên ngày mà vẫn khóa 1 ngày. LAG trong cùng ngày (`ORDER BY index_time`) không bị ảnh hưởng.

```text
❌ SAI — lookup_date chỉ lọc nguồn, không khóa ngày (4 fact trade/order GSTT, sửa 2026-10-14):
   LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = securities_trade.trade_dt AND securities_trade.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE'
✅ ĐÚNG:
   LOOKUP cdr_dt_dim ON cdr_dt_dim.cdr_dt = securities_trade.trade_dt AND securities_trade.trade_dt = :etl_date AND securities_trade.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE'

❌ SAI — subquery quét toàn lịch sử rồi mới join theo (mã, ngày):
   LEFT JOIN (SELECT m.market_code, m.trading_dt, m.market_index_val, ROW_NUMBER() OVER (...) rn FROM market_index_snapshot m WHERE m.src_stm_code = 'MDDS_JAD_MARKETINFOR') ...
✅ ĐÚNG:  ... WHERE m.src_stm_code = 'MDDS_JAD_MARKETINFOR' AND m.trading_dt = :etl_date) ...

❌ SAI — Dimension "mới nhất" trên toàn lịch sử tick:
   security_trading_snapshot.symbol WHERE security_trading_snapshot.src_stm_code = 'MDDS_JAD_STOCKINFOR' AND row_number() over (partition by security_trading_snapshot.symbol order by security_trading_snapshot.trading_dt desc, ...) = 1
✅ ĐÚNG:  ... src_stm_code = 'MDDS_JAD_STOCKINFOR' AND security_trading_snapshot.trading_dt = :etl_date AND row_number() over (...) = 1

❌ SAI — LAG liên ngày trên bảng đã khóa 1 ngày (prior_market_cap luôn NULL):
   LAG(security_trading_snapshot.close_price * ...) OVER (PARTITION BY symbol ORDER BY security_trading_snapshot.trading_dt)   -- với lookup_date: ... trading_dt = :etl_date
```

**Ngoại lệ có truy vết:** chỉ khi BA/Data Modeler chấp nhận as-of không cận dưới (VD số CP lưu hành lấy kỳ VSDC gần nhất ≤ ngày, SQL BA cũng không có cận dưới)
hoặc grain "mới nhất" đã duyệt, ghi `[DATE-BOUND-REVIEWED <ngày>: <lý do>; O_xxx]` vào `description` của cột và mở Open Issue. `check_date_bound.py` bỏ qua dòng có marker.
Marker không thay cho quyết định: đóng Open Issue rồi bổ sung cận dưới hoặc xóa marker.

**Phạm vi Phase 2 (Detail Mapping):** A19 ràng buộc `etl_logic` Phase 1. Với `logic` KPI aggregate nhiều ngày trên `fct_*_snpst`: xem mục "Mốc ngày của KPI" trong Checklist Phase 2 (`reference/phase2_workflow.md`).

**Tự kiểm (TC12, bắt buộc sau mỗi file Fact/Dimension/Operational đọc bảng snapshot/event):**

```bash
python .claude/skills/datamart-review/scripts/check_date_bound.py --module {MODULE} --file {mart_table}
```

Heuristic tĩnh (R1/R3/R4/R6) — có thể báo thừa hoặc sót (điều kiện viết bằng alias), phải đọc từng phát hiện; **chưa nằm trong `run_quality_gates.py`**.

### A20 — Cột mới ở Fact/Operational phải lên flat DDL + DML TRONG CÙNG LƯỢT `[L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING]`

Mọi đường thêm cột vào bảng Fact/Operational — Phase 1, `apply_kpi_patch.py`, `apply_patch.py`, hay sửa
tay Attributes CSV — đều kết thúc bằng đồng bộ flat. **Không phụ thuộc có đang ở Phase 3 hay không**:
Trigger 1 của ma trận đồng bộ (`reference/phase3_workflow.md`) chỉ nằm trong Phase 3, nên khi thêm KPI vào Nhóm đã có
(đúng use case của `apply_kpi_patch.py`) quy tắc đó không được đọc tới.

Sự cố thật (QLQ, phát hiện 2026-10-14): **29 cột** của 5 bảng `opr_*` (VD `assets_under_management_amt`,
`owner_equity_amt`, `issued_amt`…) có đủ trong LLD per-table, master, model yaml, Detail Mapping và có 29 KPI
READY tiêu thụ (K_QLQ_22/27/29–32/35/100/102/143–157/174–178), nhưng **không có** trong `01_create`/`02_populate`
nên dashboard Nhóm 3/4/13/22/26 không đọc được từ flat. Thiếu từ commit `2f62880d`, qua nhiều phiên. Ba lý do:
1. `build_flat_tables.py` cũ chỉ sinh khối cho **bảng chưa có**; không thêm cột vào bảng đã có — không công cụ nào sửa.
2. `apply_kpi_patch.py` chỉ patch HLD/Detail Mapping/Attributes, im lặng về flat.
3. Gate 4 **đã báo FAIL** nhưng bị xếp vào "Gate tồn đọng từ trước" và bỏ qua. Gate FAIL tồn đọng là nợ,
   không phải trạng thái bình thường.

**Lệnh (chạy ngay sau khi thêm/đổi cột Fact/Operational, trước khi báo kết quả):**

```bash
python .claude/skills/datamart-review/scripts/build_flat_tables.py --module {MODULE} --sync-columns          # dry-run: in kế hoạch
python .claude/skills/datamart-review/scripts/build_flat_tables.py --module {MODULE} --sync-columns --apply  # ghi thật + sao lưu
python .claude/skills/datamart-review/scripts/check_flat_table.py   --module {MODULE} --strict               # Gate 4
```

- Công cụ chèn đúng thứ tự LLD vào **cả** DDL lẫn DML (SELECT khớp theo vị trí). Cột nào không định vị được
  (projection phức tạp) được liệt kê để chèn tay — không được bỏ qua.
- Kiểu ClickHouse theo quy ước sẵn có: `int/bigint→Int64`, `decimal(p,s)→Decimal(p,s)`, `float→Float64`, bọc `Nullable` theo `nullable`.
- **Gate 4 FAIL không bao giờ là "tồn đọng"**: gặp thì sửa bằng lệnh trên hoặc ghi rõ lý do không sửa được kèm tên chủ xử lý.
  Chỉ cột Dimension denormalize (`snpst_cdr_dt`, `fund_type_nm`…) mới được phép có ở flat mà không có ở LLD của bảng đó.
- Phép thử nhanh cho người thiết kế: *"cột có trong Detail Mapping mà không có trong flat DDL?"* — Gate 4 tiêu chí 1 trả lời đúng câu này.

### A21 — Lọc chỉ số trên `market_index_snapshot`: giữ `market_code = 'HOSE'` `[process]`

Quyết định hiện hành (Data Modeler 2026-10-21, revert `48e849c5`; đảo quyết định `index_nm` 2026-10-20): BA ghi `IndexCode`/`indexname = 'VNINDEX'` là BA nhầm. Chi tiết ở **H14** (`datamart-hld-design/reference/rules.md`). Với LLD:
- `etl_logic` chọn VN-Index viết `market_index_snapshot.market_code = 'HOSE'`, KHÔNG viết `market_index_snapshot.index_nm = 'VNINDEX'`.
- `ROW_NUMBER() OVER (PARTITION BY ...)` lấy bản ghi cuối ngày phải chứa `market_index_snapshot.market_code`.
- Đổi điều kiện này ở một cột là đổi ở MỌI cột cùng quy tắc (H11): grep `index_nm = 'VNINDEX'` / `market_code = 'HOSE'` trong `Datamart/lld/{M}/`,
  Detail Mapping và Ghi chú HLD, sửa đồng loạt, rồi kiểm flat DML cùng lượt (A20).
- Cột BA ghi (`IndexCode`) không có ở Atomic: liệt kê đủ `physical_name`/`source_column` của entity trước khi kết luận
  "không có cột" (A1, A12).

### A22 — Mọi Fact khai báo khóa dòng (`key = PK`); flat `ORDER BY` chứa PK `[L2-FACT-NO-ROW-KEY]`

**Đảo quy ước 2026-07-21/22** ("Fact không có `key = PK`"): quy ước cũ sinh ra từ việc dọn cột surrogate `_id` thừa trên Fact (TT, GSDC), nhưng
hệ quả là Fact không có khóa dòng nào — grain chỉ tồn tại dưới dạng chữ trong description. Quy ước mới: PK bắt buộc, nhưng phải CÓ VAI TRÒ (khóa MERGE/UPSERT
của ETL, vế trái của grain, nằm trong `ORDER BY` của flat). Cột `_id` thừa không phải PK vẫn bị coi là cột dư.

Sự cố thật (QLKD `fct_securities_company_financial_structure_snpst`, phát hiện 2026-10-23): Fact EAV theo ô báo cáo, grain khai báo "1 CTCK × 1 kỳ × 1 chỉ tiêu",
KHÔNG có cột khóa. Hậu quả đã đo:
1. **Grain trôi qua nhiều lần sửa** — 2026-09-18 phát hiện thiếu `rpt_code`; sau đó vẫn thiếu `sheet_id` (sửa 2026-10-15) và `rpt_input_submission_id` (2026-10-23);
   Atomic còn có `section_id`/`row_index` mà Fact không mang. Tuple CTCK×kỳ×ô KHÔNG đảm bảo duy nhất.
2. **Không có khóa MERGE/UPSERT** — dev phải tự ghép tổ hợp FK để merge, mỗi người một kiểu.
3. **Flat ClickHouse mất dòng** — `ReplicatedReplacingMergeTree ORDER BY (cdr_dt, snpst_dt_dim_id)`: ReplacingMergeTree dedup theo **ORDER BY**, nên mọi ô cùng ngày bị
   gộp thành 1 dòng khi merge nền. `build_flat_tables.py` cũ lấy `*_dim_id` đầu tiên làm khóa sắp xếp.
Khảo sát toàn repo 2026-10-23: 91/99 Fact không có khóa dòng; 164 flat có `ORDER BY` chỉ (ngày, 1 cột).

**Quy tắc**
1. Mỗi Fact có **ĐÚNG 1** dòng `key = PK`: `nullable = false`, `data_domain = Surrogate Key`, `data_type = string`, đặt **đầu bảng** (trước các FK).
2. **Dạng A — Fact giữ nguyên grain 1 dòng Atomic driving** (không GROUP BY / UNION / pivot): PK = cột id surrogate của entity driving,
   `etl_logic_type = direct`, `etl_logic = <driving>.<id>`, 4 cột source điền như attribute thường (VD `sc_report_input_value.sc_rpt_input_val_id` →
   `rpt_input_val_id`). Không dùng `_code`/BK nguồn thay cho `_id` khi `_id` đã có. Đây là khóa MERGE của ETL.
3. **Dạng B — Fact gộp nhiều dòng nguồn:** PK = surrogate sinh = hash toàn bộ cột grain (+ `src_stm_code`); format như PK Dimension (`etl_logic` trống,
   `etl_logic_type = Generated`, `source_entity = Generated`, 3 cột source còn lại trống) và **`description` liệt kê đủ cột grain** (Gate 8 đòi có chữ "grain" hoặc "hash").
4. **Grain nêu bằng PK:** mô tả entity ở `datamart_model.yaml`, `Entities.csv`, bảng grain Section 4 HLD và comment đầu khối flat phải nói "1 dòng Atomic X" (Dạng A)
   hoặc liệt kê cột grain (Dạng B) **và tên cột PK**. Đổi grain = đổi PK + sửa đồng loạt LLD/master/yaml/Entities/HLD/flat (A5, H11).
5. **Flat (Phase 3, A20):** `ORDER BY (assumeNotNull(<cột ngày>), <PK>)` — PK PHẢI nằm trong ORDER BY. `build_flat_tables.py` tự dùng PK cho khối mới; flat đã có thì sửa tay,
   Gate 8 `L4-FLAT-ORDERBY-MISSING-PK` bắt. Không gộp PK vào `PARTITION BY`.
6. **Cột tọa độ/ngữ cảnh không đưa vào Fact** (VD `section_id`, `row_index`) phải được giải thích trong `description` của PK vì sao PK đã đủ, không để im lặng.
7. **Merge key của ETL = PK.** Không merge theo tổ hợp FK, trừ Dạng B (hash của chính tổ hợp đó).
8. **Fact đã có trước 2026-10-23** mà chưa có PK nằm trong `datamart-review/reference/fact_row_key_baseline.yaml` (nợ có tên, Gate 8 in `[i]`, không chặn). **Cấm thêm Fact mới vào baseline.**
   Thêm PK cho Fact cũ thì GỠ tên khỏi baseline trong cùng lượt và chạy A20 (flat DDL + DML + ORDER BY) — lint cảnh báo `L2-FACT-BASELINE-STALE` nếu quên.

**Lệnh sau khi thêm PK:**

```bash
python .claude/skills/datamart-review/scripts/build_flat_tables.py --module {MODULE} --sync-columns --apply   # chèn cột PK vào flat DDL + DML (A20)
# sửa tay ORDER BY của flat đã có: ORDER BY (assumeNotNull(cdr_dt), <PK>)
python .claude/skills/datamart-review/scripts/check_design_lint.py --module {MODULE} --strict               # D10/D11
python .claude/skills/datamart-review/scripts/build_model_yaml.py --check                                  # yaml khớp registry
```

**Đã sửa (QLKD, 2026-10-23):** thêm `rpt_input_val_id` (`sc_report_input_value.sc_rpt_input_val_id`, Dạng A) vào LLD, master, yaml, flat DDL + DML; ORDER BY flat đổi từ
`(cdr_dt, snpst_dt_dim_id)` sang `(cdr_dt, rpt_input_val_id)`; grain ở yaml/Entities/HLD/flat viết lại. **Chưa sửa:** 81 Fact trong baseline (và 10 Fact chỉ có ở master).

### A23 — PK Dimension = id Atomic khi có cột khác carry id đó `[L2-DIM-PK-GENERATED-CARRIED]`

Sự cố thật (QLQ `fund_management_company_dim.fmc_id`, phát hiện 2026-10-24): PK Dim khai `Generated` (etl_logic trống) nên generator hash lại từ BK (`fmc_code`),
trong khi Atomic hash `fmc_id` từ khóa nguồn `SECURITIES.ID`. 8 cột khác mang id Atomic sang bằng `direct` — `fund_management_company_dim.parent_fmc_id`,
`investment_fund_dim.fmc_id`, `opr_fund_management_company_fund_list.fmc_id`, `custodian_bank_id` (2 Dim), `foreign_fund_management_organization_unit_id`
(staff dim), `opr_investment_fund_representative_board_member_list.investment_fund_id` — nên không bao giờ nối được vào PK Dim. PK Dim sinh mới chỉ an toàn khi
mọi bảng nối vào nó đều đi qua `lookup_dim` theo BK (Fact → Dim); không còn đúng khi có cột `direct` từ Atomic. Gate cũ không bắt vì không Gate nào đối chiếu
"PK Dim sinh" với "cột carry id".

**Quy tắc**
1. Với mỗi Dim có PK `Generated`: cùng module có cột `etl_logic_type = direct` nào mà `atomic_column` là PK của entity driving, hoặc là FK Atomic có comment
   `FK target: <driving>.<pk>`? (Không tính cột thuộc tính của CHÍNH Dim đó chép id Atomic của nó, VD `securities_company_dim.sc_id`; FK tự tham chiếu như
   `parent_fmc_id` thì tính.)
2. **Có** → PK Dim `etl_logic_type = direct`, `etl_logic = <driving>.<pk>`, `source_entity` = tên logic entity Atomic, `atomic_table`/`source_attribute`/`atomic_column`
   điền đủ; giữ description `PK — Driving: {table}`. KHÔNG hash lại ở Datamart.
3. **Không** → giữ `Generated`. Fact → Dim nối qua `lookup_dim` theo BK nên không phụ thuộc cách sinh PK Dim.
4. Sửa đồng loạt per-table, master `datamart_attributes.csv` và `datamart_model.yaml` (`source_atomic_table/column`); `build_model_yaml.py --check` phải khớp.
5. **Kiểm tay (chưa có Gate):** BK `*_code` của Dim phải cùng giá trị với cột `*_code` mà entity con Atomic mang. Sự cố cùng đợt: Atomic `fmc_code` cha ← `SECURITIES.CODE`
   (mã ngắn) trong khi 8 entity con ← `SEC_ID` (= `SECURITIES.ID`), nên BK cha/con lệch và KPI so `fmr_submission.fmc_code = fund_management_company.fmc_code` không khớp.

**Lệnh:** `python .claude/skills/datamart-review/scripts/check_design_lint.py --module {MODULE} --strict` (D12).

**Đã sửa (QLQ, 2026-10-24):** `fund_management_company_dim`, `investment_fund_dim`, `custodian_bank_dim`, `foreign_fund_management_organization_unit_dim` → PK `direct`
(per-table + master + yaml). `fund_distribution_agent_dim`, `securities_distribution_agent_dim` (trùng tên PK Atomic nhưng chưa có cột carry) giữ `Generated`.
Atomic `fmc_code` đổi nguồn `SECURITIES.CODE` → `SECURITIES.ID`; cột `CODE` chuyển vào `pending_design.yaml`. Dev cần đổi code dbt tương ứng.

### A24 — `bảng.cột` viết trong `logic` Detail Mapping và công thức HLD phải tồn tại thật `[L0-DM-LOGIC-COLUMN-NOT-FOUND]`

Sự cố thật (rà soát QLQ 28 Nhóm, 2026-10-24): Detail Mapping dùng `cdr_dt_dim.cdr_year` / `cdr_month` (7 KPI; dim chỉ có `year` / `quarter` / `month`),
`investment_fund.fund_tp_code` (Atomic: `cl_fms_fund_tp_code`), `fund_management_company.operation_status_code`, `foreign_fm_ou.branch_tp_code`, `member_rating.data_dt`…
— cột không tồn tại, nằm yên qua nhiều phiên và nhiều lượt "rà soát". Gate 0 chỉ kiểm CẶP `mart_table` / `mart_column` (A2) và `bảng.cột` trong `etl_logic` của LLD (A1);
**không ai kiểm các `bảng.cột` viết TRONG cột `logic` của Detail Mapping hay ô Công thức của bảng KPI HLD.** Quét toàn repo cùng ngày còn 120 tham chiếu cùng loại ở 5 module
khác (QLKD 82, TKNB 18, GSTT 8, PTTT 7, GSDC 5 — VD `bond_order_book.order_book_type_code` đúng là `order_book_tp`, `market_index_snapshot.market_id_code` đúng là `market_code`).

**Quy tắc**
1. Trước khi viết `bảng.cột` vào `logic` / công thức: grep cột ở Attributes CSV (bảng Datamart: `grep -n "<cột>" Datamart/lld/{M}/DTM_{M}_<bảng>.csv`) hoặc YAML Atomic (A1).
2. **Đổi tên / xóa cột ở LLD (hoặc Atomic đổi tên) ⇒ grep tên cũ trong Detail Mapping + HLD + yaml + flat NGAY TRONG LƯỢT ĐÓ** (cùng tinh thần A20):
   `grep -rn "<tên cũ>" Datamart/hld Datamart/lld Datamart/flat-table`.
3. Cột chưa tồn tại mà KPI cần ⇒ thêm cột vào LLD (A20); không viết trước tên "dự kiến" vào `logic`.
4. Ghi chú lịch sử nhắc tên cột cũ phải nằm trong `[...]` (lint bỏ qua phần trong ngoặc vuông) hoặc ở `ghi_chu`, không nằm trong công thức.

**Máy kiểm:** Gate 8 D13 (`check_design_lint.py`), mã `L0-DM-LOGIC-COLUMN-NOT-FOUND`. Vi phạm MỚI = ERROR. Nợ có từ trước nằm trong
`datamart-review/reference/dm_logic_column_baseline.yaml` (in `[i]`; CẤM thêm mục mới để "cho qua"; sửa xong thì GỠ — lint báo WARNING nếu còn). Sinh lại baseline khi human duyệt:
`check_design_lint.py --module ALL --print-dm-logic-baseline`. Giới hạn: chỉ bắt `bảng.cột` có tiền tố bảng viết liền với bảng Datamart/Atomic đã biết (bỏ alias, bỏ phần trong `[...]`);
cột đứng một mình (VD `active_status_flag`) vẫn phải tra tay. Một số mục baseline có thể là false positive (hậu tố `_i` ký hiệu mẫu, cột Atomic mới) — xác nhận từng mục trước khi gỡ.

### A25 — Thuộc tính trùng tên ở nhiều bảng Atomic: bảng nguồn do SQL BA dùng quyết định `[L3-SOURCE-TABLE-MISMATCH]`

Sự cố thật (QLQ, 2026-10-24): `period_tp_code`, `period_val`, `rpt_year`, `record_tp` có ở CẢ `fmr_value` (RPT_VALUES) và `fmr_submission` (RPT_MEMBER). SQL BA chọn kỳ và loại đối tượng theo
RPT_MEMBER (`RPT_MEMBER.RECORD_TYPE`, `PERIOD_TYPE`, `PERIOD_VALUE`, `YEAR_VALUE`, `RECORD_STATUS`) nhưng Fact `fct_fund_management_rpt_cell_val`, 2 `contract_list` và 22 subquery Operational đọc
`fmr_value.period_*` / `fmr_value.record_tp`. Tên cột giống nhau nên không Gate nào thấy; trục thời gian của mọi KPI RPT bị gắn sai nguồn qua nhiều phiên. Cùng mẫu: `period_val` dạng chữ `'T03/2024'`
trong khi SQL BA so với số `'3'` — định dạng cũng phải lấy từ đúng bảng.

**Quy tắc**
1. Với mỗi cột Atomic đọc vào `etl_logic` / `logic`, lập cặp (cột BA → bảng BA ở `FROM` / `JOIN` của SQL tham khảo → entity Atomic của bảng đó). Cột đọc phải thuộc entity ứng với bảng BA.
2. Cột trùng tên ở ≥ 2 bảng cùng nguồn (`grep -rn "physical_name: {cột}" DataModel/Atomic`): chọn bảng mà SQL BA dùng; ghi lý do ở `description` và lineage (`source_entity` / `atomic_table`) đúng bảng đó.
3. Nghi bảng BA ghi sai (hai bảng chứa cùng thuộc tính, khác nhau về kỳ nộp/phiên bản) ⇒ mở O_ issue; KHÔNG tự chọn bảng "tiện hơn".
4. Đổi bảng nguồn của một cột dùng chung ⇒ grep mọi KPI tiêu thụ (H11) và sửa đồng loạt; ghi định dạng giá trị chưa xác nhận (chữ/số) thành O_ issue kèm câu `SELECT ... GROUP BY` cho dev.

**Máy kiểm:** chưa có (đọc tay khi review Lớp 2/3; `datamart-review` mục "Checklist rà soát" điểm 1).

### A26 — Kiểm kê MỌI điều kiện của SQL BA; "Active-only" chỉ miễn điều kiện slicer thời gian `[L3-BA-FILTER-UNMAPPED]`

Sự cố thật (QLQ, 2026-10-24): thiết kế bỏ qua hàng loạt điều kiện có trong SQL BA — `PERIOD_TYPE = 3` (42 KPI RPT + 5 cột Operational lấy mọi loại kỳ), `ID_DATE ≤ kỳ` (số CCQ Nhóm 11 và hồ sơ quỹ Nhóm 13
không xét ngày cấp phép), `COALESCE(START_DATE, LICENSE_DATE)` (Nhóm 24/26 chỉ dùng `START_DATE`), `BRANCH_FLAG = 1` (hồ sơ chi nhánh lẫn văn phòng đại diện), `NULLIF` hai vế và `*100` (tăng trưởng NAV, NAV/GDP),
GDP chọn theo năm (`ord_pd = 1`), `DISTRIBUTION_CERT_DATE ≤ kỳ` (hồ sơ ĐLPP). Nguyên nhân chung: quyết định "Operational / Periodic Snapshot lấy trạng thái hiện tại, không có slicer tháng" bị áp rộng thành
bỏ cả điều kiện loại đối tượng / loại kỳ / ngày hiệu lực; ghi chú "luôn hiển thị trạng thái hiện tại" che mất chỗ bỏ điều kiện. L17 (`phase2_detail_mapping.md`) chỉ yêu cầu `WHERE` tĩnh nằm trong `logic` hoặc "đã lọc sẵn tại ETL"
(A10) — không có bước kiểm kê, và L17 chỉ áp cho Detail Mapping, không áp cho `etl_logic` của bảng Operational/Fact.

**Quy tắc**
1. Với mỗi KPI (hoặc cột Fact/Operational): liệt kê MỌI điều kiện trong cột Điều kiện BA và SQL tham khảo — `WHERE`, `ON` của `LEFT JOIN`, CTE, `HAVING`, `ROW_NUMBER ... = 1`, và biểu thức trong `SELECT`
   (`NULLIF`, `*100`, `COALESCE`, `CASE`). Mỗi điều kiện thuộc đúng 1 loại: (a) **có** trong `etl_logic` / `logic` — trích đúng chỗ; (b) **thay thế có chủ ý** — VD `= :filter_month` → `<= :etl_date` ở bảng Active-only,
   ghi ở `ghi_chu` (+ O_ issue nếu BA chưa duyệt); (c) **không áp dụng** — ghi lý do. Không có loại "quên".
2. Chỉ **điều kiện slicer thời gian** (`:filter_month` / `_fr` / `_to`, `= "filter_value"`) được thay bằng `:etl_date` ở bảng không có chiều tháng. Điều kiện **loại đối tượng** (`RECORD_TYPE`, `BRANCH_FLAG`, `ou_tp_code`),
   **loại kỳ** (`PERIOD_TYPE`), **trạng thái** (`RECORD_STATUS IN (...)`), **ngày hiệu lực** (`ID_DATE`, `START_DATE`, `DISTRIBUTION_CERT_DATE`) và **biểu thức tính** KHÔNG được miễn.
3. SQL BA nghi sai/ngược (VD `CASE WHEN TERMINATION_DATE IS NOT NULL THEN 'Hoạt động'`; `ID_DATE =` thay vì `<=`; chia NAV cho GDP không quy đổi đơn vị): giữ thiết kế hợp lý HOẶC theo BA — nhưng
   **ghi chỗ lệch và mở O_ issue (Open — chờ BA) trong CÙNG lượt**, kèm câu truy vấn dữ liệu để BA/dev xác nhận. Không im lặng đổi, không im lặng chép.
4. Câu "Active-only / luôn hiển thị trạng thái hiện tại" ở `ghi_chu` chỉ hợp lệ khi đi kèm danh sách điều kiện loại (b)/(c) còn lại.

**Máy kiểm:** chưa tự động (điều kiện là ngữ nghĩa SQL). `datamart-review` mục "Checklist rà soát" điểm 2–3 và Lớp 3 L17(e).

### Lệnh bổ sung — Gate 8 Design Lint

```bash
python .claude/skills/datamart-review/scripts/check_design_lint.py --module {MODULE} --strict
```

Đã nằm trong `run_quality_gates.py` (Gate 8). Bắt: `bảng.cột` không tồn tại trong `logic` Detail Mapping / công thức HLD (A24, D13 `L0-DM-LOGIC-COLUMN-NOT-FOUND`, nợ cũ ở `reference/dm_logic_column_baseline.yaml`), dòng "Bảng mapping nguồn" của HLD sai số ô (D14 `L1-HLD-MAPPING-ROW-CELLS`), Fact thiếu khóa dòng PK (A22, D10 `L2-FACT-NO-ROW-KEY`) và flat `ORDER BY` thiếu PK (A22, D11), PK Dim `Generated` bị cột khác carry id Atomic (A23, D12), dòng bảng KPI HLD sai số ô (H13), bảng Datamart
0 KPI dùng (H12), comment flat SQL dính `:etl_date` (A15), KPI có MEASURE bị nhân dòng (L18, D5 — chỉ ép với
module trong `L18_MODULES` của `check_design_lint.py`; thiết kế module mới theo L18 thì thêm module vào tập đó).
**Gate 8 KHÔNG kiểm A19 (giới hạn ngày)** — chạy tay `check_date_bound.py` (TC12); `run_quality_gates.py` PASS không có nghĩa etl_logic đã khóa ngày.

## Ghi chú lịch sử

Lô 9 luật đầu tiên (A1–A9) — ghi chú gốc:

> **Nguồn gốc:** toàn bộ 9 quy tắc dưới đây được rút ra từ sự cố thiết kế PTTT/QLKD phát hiện ngày
> 2026-09-18. Tất cả đều **đã lọt qua Gate 1–4 cũ** — nghĩa là không có checker nào bắt được.
> Chúng được bổ sung thành **Gate 0 (`check_references.py`)** và **Gate 5 (`check_hld_5b.py`)**.

Chốt chặn của các script build (chuyển từ `SKILL.md`, mục "Artifact sinh tự động"):

Ghi thật (bỏ `--check`) chỉ khi `--check` cho thấy phần lệch **chỉ** thuộc bảng vừa sửa. Từ 2026-10-15 cả 3
script có chốt chặn: `build_registry` từ chối nếu sinh lại sẽ xóa trọn bảng có trong master nhưng mất file LLD
per-module (2026-10-15: 26 bảng TKNB `_rpt`/VP `fct_derv_*` đang ở tình trạng này — chờ human quyết khôi phục
file hay bỏ bảng), `build_model_yaml` từ chối khi entity bị bớt cột, `build_kpi_index` từ chối khi co > 20%.
`--allow-drop` / `--allow-shrink` chỉ dùng khi human đã duyệt (hook `dm_guard` sẽ hỏi lại).
