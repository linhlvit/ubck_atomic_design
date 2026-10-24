# Quy tắc tên physical và Kịch bản C — LLD Datamart

Đọc trước khi đặt tên `datamart_table` / `datamart_column`, và khi sửa lỗi đặt tên hoặc logic trên file Attributes đã tồn tại (Kịch bản C).

## Mục lục

- PHYSICAL NAMING RULE (BẮT BUỘC — đọc trước khi đặt tên cột/bảng)
  - Quy tắc cốt lõi
  - Cách áp dụng
  - Khi đặt tên `datamart_column`
  - Khi review/detect lỗi

## PHYSICAL NAMING RULE (BẮT BUỘC — đọc trước khi đặt tên cột/bảng)

**Nguồn sự thật:** `system/rules/rule_physical_name_exceptions_datamart.csv` — danh sách duy nhất các từ được phép viết tắt.

### Quy tắc cốt lõi

> **Chỉ những từ có trong `rule_physical_name_exceptions_datamart.csv` mới được viết tắt. Mọi từ khác phải dùng full word.**

> ⛔ **KHÔNG chép bảng exceptions vào file này hay bất kỳ skill/tài liệu nào khác.** Danh sách chỉ tồn tại ở đúng 1 nơi là CSV trên. Mọi bản sao nhúng đều sẽ lệch khỏi CSV theo thời gian — đây là lỗi đã xảy ra thật: bản sao cũ trong skill thiếu entry `Calendar → cdr`, kèm ví dụ mẫu dạy `Calendar Date → calendar_dt`, dẫn tới master hiện có 2 tên song song cho cùng 1 logical (`calendar_dt_dim_id` 9 dòng vs `cdr_dt_dim_id` 3 dòng).

**Bắt buộc đọc CSV trước mỗi lần đặt tên** (không nhớ theo trí nhớ, không đọc lại từ ví dụ bên dưới):

```bash
cat system/rules/rule_physical_name_exceptions_datamart.csv
```

Nội dung CSV là **cố định, không được tự bổ sung** — thêm exception mới phải qua human duyệt và sửa trực tiếp CSV, không sửa trong skill.

### Cách áp dụng

1. **Tách tên logical thành từng token** theo dấu cách
2. **Với mỗi token:**
   - Nếu từ có trong bảng exceptions → dùng dạng viết tắt tương ứng
   - Nếu không → dùng **đúng từ đó** dạng full word — **KHÔNG được thay bằng từ đồng nghĩa hay dạng mở rộng khác**
3. **Nối lại** bằng dấu gạch dưới `_`

> **Ràng buộc cốt lõi — bắt buộc:** Physical name phải derive trực tiếp từ **tên logical**, không được thay thế token bằng từ khác dù tương đồng về nghĩa. Quy tắc chỉ cho phép **viết tắt** các từ trong exceptions, không cho phép **mở rộng** hay **đổi từ**.
>
> Ví dụ vi phạm điển hình: logical "Exam Score" → physical `examination_score` ❌ — chữ "exam" bị mở rộng thành "examination" dù không được phép. Đúng phải là `exam_score` ✅.

**Ví dụ đúng:**
```
Certificate Type Code          →  certificate_tp_code             (type → tp; certificate KHÔNG có trong exceptions → full)
Practitioner Code              →  practitioner_code               (không có token nào trong exceptions)
Issue Decision Number          →  issue_decision_nbr              (number → nbr; issue, decision → full)
Organization Name              →  organization_nm                 (name → nm; organization → full)
Source System Code             →  src_stm_code                    (source → src; system → stm; code → full)
Snapshot Date                  →  snpst_dt                        (snapshot → snpst; date → dt)
Calendar Date                  →  cdr_dt                          (calendar → cdr; date → dt — CẢ HAI đều có trong CSV)
Calendar Date Dimension Id     →  cdr_dt_dim_id                   (CHỈ dùng làm PK của Dimension cdr_dt_dim; CẤM dùng làm FK trên Fact)
Snapshot Date Dimension Id     →  snpst_dt_dim_id                 (FK snapshot date trên Fact Snapshot — role-playing date)
Issue Date Dimension Id        →  issue_dt_dim_id                 (FK issue date trên Fact — role-playing date)
Trade Date Dimension Id        →  trade_dt_dim_id                 (FK trade date trên Fact — role-playing date)
Practitioner Dimension ID      →  practitioner_dim_id             (dimension → dim; id → id; practitioner → full)
Fact Practitioner Daily Snapshot → fct_practitioner_daily_snpst   (fact → fct; snapshot → snpst; practitioner, daily → full — "daily" KHÔNG có trong CSV)
Operational History            →  opr_hist                        (operational → opr; history → hist)
Classification Code            →  cl_code                         (classification → cl; code → full)
Scheme Code                    →  scm_code                        (scheme → scm; code → full)
Exam Score                     →  exam_score                      (exam, score KHÔNG có trong exceptions → full; giữ nguyên "exam", KHÔNG đổi thành "examination")
Exam Start Date                →  exam_start_dt                   (date → dt; exam, start → full)
```

**Ví dụ SAI (phổ biến trước đây):**
```
ctf_tp_code     ❌  (ctf không phải exception)          →   certificate_tp_code  ✅
prac_code       ❌  (prac không phải exception)         →   practitioner_code    ✅
trn_rslt_nm     ❌  (trn, rslt không phải exception)    →   training_result_nm   ✅
org_tp_nm       ❌  (org không phải exception)          →   organization_tp_nm   ✅
examination_score  ❌  (logical là "Exam Score" — "exam" bị mở rộng thành "examination")  →   exam_score  ✅
calendar_dt_dim_id ❌  ("calendar" CÓ trong CSV → phải rút gọn thành cdr)  →   cdr_dt_dim_id  ✅ (chỉ dùng trên cdr_dt_dim)
cdr_dt_dim_id trên Fact table ❌ (làm mất role ngày, vi phạm role-playing) →  snpst_dt_dim_id ✅ (Fact Snapshot) hoặc <role>_dt_dim_id ✅
dly / smy / list   ❌  (viết tắt của daily/summary/listed — không có trong CSV)  →   daily / summary / listed  ✅
```

> ⛔ **QUY TẮC BẮT BUỘC: ROLE-PLAYING DATE DIMENSION TRÊN FACT TABLE (BÀI HỌC GSDC 2026-09-08):**
> - `Calendar Date Dimension Id` (`cdr_dt_dim_id`) **CHỈ là Primary Key của chính bảng Dimension `cdr_dt_dim`** (`table_type = dim`).
> - **TUYỆT ĐỐI CẤM dùng `Calendar Date Dimension Id` / `cdr_dt_dim_id` làm Foreign Key trên bất kỳ Fact table nào!**
> - Mọi FK trỏ tới `cdr_dt_dim` trên Fact table là **Role-Playing Dimension Key**, PHẢI đặt tên theo đúng vai trò nghiệp vụ (Role):
>   1. **Fact Snapshot (`fct_*_snpst`):** Cột ngày snapshot kỳ bắt buộc là `Snapshot Date Dimension Id` → `snpst_dt_dim_id` (snapshot → snpst, date → dt, dimension → dim, id → id).
>   2. **Các vai trò ngày khác trên Fact:** `<Role> Date Dimension Id` → `<role>_dt_dim_id` (ví dụ: `Issue Date Dimension Id` → `issue_dt_dim_id`, `Trade Date Dimension Id` → `trade_dt_dim_id`, `Evaluation Date Dimension Id` → `evaluation_dt_dim_id`, `Submission Date Dimension Id` → `submission_dt_dim_id`, `Effective Date Dimension Id` → `effective_dt_dim_id`...).
> - **Nguyên nhân gốc rễ gây lỗi:** Do tên logical trong HLD/LLD bị ghi generic là "Calendar Date Dimension Id" thay vì "Snapshot Date Dimension Id", dẫn tới thuật toán derive physical name sinh ra `cdr_dt_dim_id`. Khi thiết kế Fact, phải đặt tên logical theo vai trò ngày trước khi sinh physical name.

> **Bài học từ các ví dụ SAI:** Cần luôn `cat` CSV trước khi đặt tên và đối chiếu vai trò nghiệp vụ của cột — bản thân danh sách ví dụ này cũng chỉ là minh hoạ, KHÔNG phải nguồn sự thật.

> ⚠️ **PHÂN ĐỊNH: ROLE-PLAYING DATE FK vs DEGENERATE DATE ATTRIBUTE:**
> Không phải mọi cột ngày trên Fact table đều trỏ sang Date Dimension. Chỉ **trục thời gian phân tích chính** mới là Role-Playing Date FK:
>
> | Tiêu chí | Role-Playing Date FK | Degenerate Date Attribute |
> |---|---|---|
> | **Khi nào dùng** | Trục thời gian phân tích chính: snapshot date, trade date, event date | Thuộc tính ngày mô tả nghiệp vụ: ngày ký, ngày sinh, ngày lập biên bản |
> | **Data Domain** | `Surrogate Dimension Key` | `Date` hoặc `Timestamp` |
> | **Data Type** | `string` | `date` hoặc `timestamp` |
> | **Key** | `FK` | Trống (`""`) — **CẤM** `FK`, `BK`, `DD` |
> | **etl_logic_type** | `lookup_date` | `direct` hoặc `join_atomic` — **CẤM** `lookup_date` |
> | **Hậu tố tên** | `_dt_dim_id` | `_dt` (VD: `violation_record_dt`, `birth_dt`) — **CẤM** `_Dimension_Id` |
>
> **Bài học thực tế (NHNCK):** `violation_record_dt` từng bị đặt nhầm thành `violation_record_dt_dim_id` (commit 742aede) — đây là Degenerate Date, KHÔNG phải FK.

> **Lỗi tái diễn — 2 biến thể viết tắt song song cho CÙNG một tên bảng/entity (phát hiện ở GSDC 2026-07-16):**
> Khi module có nhiều bảng Fact/Dim cùng gắn với 1 khái niệm nghiệp vụ (VD: "Public Company"), rất dễ đặt tên bảng đầu tiên theo 1 kiểu viết tắt tự nghĩ ra (`pblc_co_dim`) rồi bảng sau lại đặt theo kiểu khác (`fct_pc_risk_score_snpst`) — cả 2 đều KHÔNG có trong exceptions và KHÔNG nhất quán với nhau.
> **Nguyên nhân sâu xa:** dễ nhầm lẫn giữa 2 ngữ cảnh — (a) `atomic_table`/`atomic_column` là tên **Atomic gốc** (read-only, VD: `pc_evaluation_detail`, `pc_report_submission`, `pc_id` — những tên này giữ nguyên, không đổi), và (b) `datamart_table`/`datamart_column` là tên **Datamart tự đặt**, phải tuân physical naming rule độc lập với cách Atomic đặt tên. Thấy Atomic dùng tiền tố `pc_` rồi bắt chước đặt tên Datamart cũng `pc_`/`pblc_co` là sai — hai tầng đặt tên độc lập nhau.
> **Quy tắc phòng ngừa:** Trước khi đặt tên bảng/cột Datamart mới cho 1 entity xuất hiện ở nhiều bảng trong cùng module, `grep` toàn bộ tên hiện có của entity đó trong `datamart_attributes.csv` + các file Attributes detail đã duyệt trước — đảm bảo dùng lại đúng 1 biến thể duy nhất, không tự nghĩ ra biến thể mới giữa chừng.

### Khi đặt tên `datamart_column`

- Mọi cột trong Attributes CSV phải tuân thủ rule này
- Khi kế thừa từ `atomic_column`: nếu Atomic column dùng tên chuẩn (ví dụ `sp_code`, `practitioner_position_at_rpt`) → giữ nguyên; chỉ đổi nếu Atomic column đang dùng sai convention
- Khi đặt tên mới (ETL-derived, computed): áp dụng rule từ đầu
- **Không copy tiền tố viết tắt từ tên Atomic sang tên Datamart** — `atomic_table`/`atomic_column` (VD: `pc_evaluation_detail`) là namespace riêng của Atomic, không phải gợi ý cách viết tắt cho `datamart_table`/`datamart_column`

### Khi review/detect lỗi

Nếu phát hiện `datamart_column` hoặc `datamart_table` dùng từ viết tắt không có trong exceptions, HOẶC dùng 2 biến thể viết tắt khác nhau cho cùng 1 entity/khái niệm trong cùng module:
1. Tra `system/rules/rule_physical_name_exceptions_datamart.csv` xác nhận
2. Đây là **Kịch bản C — Lỗi thiết kế** → sửa trực tiếp file Attributes detail + `Detail_Mapping.csv` (cột `logic`) + `HLD.md` (tên bảng trong text/mermaid) + `datamart_model.yaml` (chỉ field `id`/`datamart_table`/`physical_name` — KHÔNG dùng `yaml.dump` để ghi lại toàn file vì sẽ phá format/comment gốc, chỉ sửa bằng text-replace theo dòng cụ thể) + tên file Attributes detail (nếu tên file chứa physical_name cũ) + 2 file SQL Phase 3 (nếu đã sinh); sau đó sinh lại master `datamart_attributes.csv` bằng `build_registry.py --check` → ghi thật (không sửa tay master)
3. Dùng `grep -rn "tên_cũ" Datamart/` để tìm tất cả vị trí trước khi sửa
4. **Tuyệt đối không sửa cột `source_entity`/`atomic_table`/`source_attribute`/`atomic_column`** trong Attributes, hay `source_atomic_table`/`source_atomic_column` trong `datamart_model.yaml` — đây là tên Atomic gốc (read-only), kể cả khi trùng chuỗi ký tự với tên Datamart bị đổi (VD: đổi `pc_code` Datamart-side nhưng KHÔNG đổi `pc_code` xuất hiện trong `source_atomic_column: "public_company.pc_code"`)
5. Sau khi sửa: chạy lại SELF-REVIEW đầy đủ (Phase 1 — đủ 14 TC + Phase 2 TC5/TC6 module-level) để xác nhận số dòng/cấu trúc không đổi trước và sau khi đổi tên

> ⛔ **QUY TẮC BẮT BUỘC — MỞ RỘNG NGOÀI PHẠM VI ĐẶT TÊN: MỌI sửa `etl_logic` (join-key, filter, công thức) vào 1 file Attributes detail đã tồn tại PHẢI sinh lại ngay master `datamart_attributes.csv` bằng `build_registry.py` — không riêng lỗi đặt tên vật lý:**
> - 5 bước trên viết cho lỗi **đặt tên** (Kịch bản C — naming) — nhưng nguyên tắc "sửa module file thì phải đồng bộ master" áp dụng cho **MỌI loại Kịch bản C**, kể cả sửa lỗi *logic nghiệp vụ* (sai điều kiện JOIN, thiếu filter, sai công thức) không đổi tên bảng/cột nào.
> - **Bài học thực tế (module GSTT, 2026-09-11):** Qua review phát hiện + sửa 2 bug join-key/filter trực tiếp vào `Datamart/lld/GSTT/DTM_GSTT_fct_stock_portfolio_snpst.csv` — chỉ sửa file module, KHÔNG đồng bộ `datamart_attributes.csv`. Vì tên bảng/cột không đổi (chỉ nội dung `etl_logic` đổi), TC7 (bản cũ) không phát hiện được, và bug fix được báo cáo "hoàn tất" trong khi master registry vẫn chứa logic sai. Chỉ lộ ra khi user hỏi lại ở lượt hội thoại sau.
> - **Quy tắc bắt buộc:** Sau BẤT KỲ Edit nào vào `etl_logic`/`description` của 1 file `Datamart/lld/{MODULE}/DTM_{MODULE}_*.csv` đã tồn tại (không phân biệt sinh mới hay sửa lỗi, không phân biệt lối vào là Phase 1 hay bàn giao từ `datamart-review`) — **ngay lập tức** sinh lại master bằng `build_registry.py --check` → ghi thật (không chép chuỗi vào master bằng tay; bị chặn vì master còn bảng không có file per-module thì dừng, báo human — không sửa tay master để lách), rồi chạy TC7 Sub-check E (xem TC7 trong [`phase1_selfreview.md`](phase1_selfreview.md)) để xác nhận khớp — **trước khi báo cáo hoàn tất cho human**, không đợi tới lần chạy SELF-REVIEW đầy đủ tiếp theo.
> - Không có ngoại lệ "sửa nhỏ", "chỉ đổi 1 điều kiện AND" — mọi thay đổi nội dung `etl_logic`, dù nhỏ, đều phải sinh lại master ngay.

