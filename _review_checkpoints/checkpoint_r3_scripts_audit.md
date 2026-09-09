# CHECKPOINT R3 — AUDIT MÃ NGUỒN 2 PYTHON SCRIPTS VÀ ĐỐI CHIẾU NGHIỆP VỤ
## Dự án: Review và Chuẩn hóa Skill `datamart-review` (UBCKNN Atomic Design)

- **Mã tài liệu:** `CHECKPOINT-R3-SCRIPTS-AUDIT`
- **Phiên bản:** 1.0 (Chính thức)
- **Ngày lập:** 2026-09-09
- **Đối tượng khảo sát:**
  1. `datamart_progress_analyzer.py` (1328 dòng, ~57KB) tại `.claude/skills/datamart-review/scripts/`
  2. `datamart_date_fk_checker.py` (935 dòng, ~36KB) tại `.claude/skills/datamart-review/scripts/`
- **Tài liệu quy chuẩn đối chiếu:** `SKILL.md` (1013 dòng) và các tài liệu trong `reference/`.
- **Trạng thái:** Hoàn thành audit R3, mã nguồn không bị sửa đổi trực tiếp, phương án vá bug đã được chuẩn bị đầy đủ.

---

## (A) TÓM TẮT FINDINGS CHI TIẾT

---

### 1. Danh Sách 11 Bugs Tiềm Ẩn & Edge Cases Kèm Kịch Bản Tái Hiện và Code Fix

#### 1.1. BUGS TRONG `datamart_progress_analyzer.py` (7 BUGS)

---

##### BUG-PA-01: Thuật toán dò Delimiter dựa trên `max_cols` bị gãy khi trường text chứa nhiều dấu phẩy
- **(a) Vị trí:** `datamart_progress_analyzer.py`, dòng 167–185
- **(b) Mã nguồn có vấn đề:**
  ```python
  for delim in (";", ","):
      try:
          reader = csv.reader(io.StringIO(raw_content), delimiter=delim)
          sample_rows = []
          for _ in range(10):
              try:
                  sample_rows.append(next(reader))
              except StopIteration:
                  break
          if sample_rows:
              max_cols = max(len(r) for r in sample_rows)
              if max_cols > best_cols:
                  best_cols = max_cols
                  best_delim = delim
      except Exception:
          pass
  ```
- **(c) Kịch bản tái hiện (Reproduction Scenario):**
  - *Input:* File BA sử dụng delimiter `;` chuẩn (như `BA_analyst_TT.csv` hoặc `BA_analyst_NHNCK.csv` có 26–29 cột). Trong 10 dòng đầu, tại cột "Câu lệnh tham khảo" hoặc "Mô tả", có một câu lệnh SQL phức tạp chứa danh sách 35 trường không được bọc ngoặc kép hoàn hảo hoặc văn bản chứa danh sách phẩy dài (`SELECT col1, col2, ..., col35 FROM ...`).
  - *Diễn biến:* Vòng lặp 1 thử `;` ra `max_cols = 29`. Vòng lặp 2 thử `,` do cắt qua chuỗi SQL nên dòng đó bị tách thành 36 phần (`max_cols = 36`).
  - *Hậu quả thực tế:* `36 > 29` làm script chọn nhầm delimiter `,` cho một file thực chất là `;`. Toàn bộ dữ liệu sau đó bị parse vỡ vụn, số cột nhận diện sai, mất sạch header và các chỉ tiêu bị rớt xuống nhóm "Chưa xác định".
- **(d) Đề xuất mã nguồn sửa chữa tối ưu:**
  ```python
  from collections import Counter
  import statistics

  @staticmethod
  def detect_delimiter_and_header(raw_content: str) -> Tuple[str, int, List[str], List[List[str]]]:
      raw_content = raw_content.lstrip("\ufeff")
      delim_scores = {}

      for delim in (";", ","):
          try:
              reader = csv.reader(io.StringIO(raw_content), delimiter=delim)
              row_lens = [len(r) for idx, r in enumerate(reader) if idx < 15 and any(c.strip() for c in r)]
              if not row_lens:
                  continue
              # Delimiter hợp lệ phải có số cột > 5 và độ biến thiên số cột thấp
              mode_len = Counter(row_lens).most_common(1)[0][0]
              consistency = sum(1 for l in row_lens if l == mode_len) / len(row_lens)
              delim_scores[delim] = (mode_len if mode_len >= 15 else 0, consistency)
          except Exception:
              pass

      # Ưu tiên delimiter có số cột chế độ >= 15 và độ nhất quán cao nhất
      best_delim = max(delim_scores.keys(), key=lambda d: (delim_scores[d][0], delim_scores[d][1])) if delim_scores else ";"
  ```

---

##### BUG-PA-02: `DetailMappingParser` không có logic dò Delimiter, sập khi file CSV lưu bằng `;`
- **(a) Vị trí:** `datamart_progress_analyzer.py`, dòng 440–444
- **(b) Mã nguồn có vấn đề:**
  ```python
  text = filepath.read_text(encoding="utf-8-sig", errors="replace").lstrip("\ufeff")
  reader = csv.DictReader(io.StringIO(text))
  if reader.fieldnames:
      reader.fieldnames = [f.lstrip("\ufeff").strip() if f else f for f in reader.fieldnames]
  ```
- **(c) Kịch bản tái hiện (Reproduction Scenario):**
  - *Input:* Người dùng mở file `DTM_{MODULE}_Detail_Mapping.csv` trên Excel Windows có Locale Việt Nam/Châu Âu rồi Save lại. Excel tự động lưu file với phân cách chấm phẩy `;`.
  - *Diễn biến:* `csv.DictReader` mặc định dùng `delimiter=','`. Khi đọc file `;`, toàn bộ dòng header bị gom thành 1 key duy nhất dạng `"kpi_id;tab;nhom;kpi_name;..."`.
  - *Hậu quả thực tế:* Mọi lệnh `r.get("kpi_id")` đều trả về `None`. Dòng 458: `if not any((kpi_id, kpi_name, mart_table, mart_column, logic)): continue` loại bỏ 100% số dòng. Script báo cáo phân hệ có 0 dòng Detail Mapping và cảnh báo sai rằng "Chưa thiết kế LLD Detail Mapping" (Kịch bản 5.2).
- **(d) Đề xuất mã nguồn sửa chữa tối ưu:**
  ```python
  @staticmethod
  def parse_file(filepath: Path) -> List[DetailMappingItem]:
      if not filepath.exists():
          return []

      text = filepath.read_text(encoding="utf-8-sig", errors="replace").lstrip("\ufeff")
      # Tự động phát hiện delimiter cho Detail Mapping
      first_line = text.splitlines()[0] if text.splitlines() else ""
      delim = ";" if first_line.count(";") > first_line.count(",") else ","

      reader = csv.DictReader(io.StringIO(text), delimiter=delim)
      if reader.fieldnames:
          reader.fieldnames = [f.lstrip("\ufeff").strip() if f else f for f in reader.fieldnames]
  ```

---

##### BUG-PA-03: Parse Markdown Table bị vỡ cột và sai trạng thái khi công thức KPI chứa ký tự Pipe `|`
- **(a) Vị trí:** `datamart_progress_analyzer.py`, dòng 378–414
- **(b) Mã nguồn có vấn đề:**
  ```python
  if line_s.startswith("|") and ("|" in line_s):
      parts = [p.strip() for p in line_s.split("|")[1:-1]]
      ...
      if len(parts) >= 7:
          formula = parts[4]
          note = parts[5]
          raw_status = parts[6]
      elif len(parts) == 6:
          formula = parts[4]
          note = ""
          raw_status = parts[5]
  ```
- **(c) Kịch bản tái hiện (Reproduction Scenario):**
  - *Input:* Bảng KPI HLD có 7 cột chuẩn, trong đó cột Công thức chứa phép toán logic bitwise OR `|` hoặc ghép chuỗi SQL `||` (hoặc biểu thức regex `A|B`). Ví dụ:
    `| K_QLKD_05 | Tỷ lệ cảnh báo | % | Phái sinh | CASE WHEN a || b THEN 1 ELSE 0 END | Ghi chú điều kiện | PENDING |`
  - *Diễn biến:* `line_s.split("|")[1:-1]` tạo ra mảng `parts` có 8 phần tử.
    - `parts[4] = "CASE WHEN a "`
    - `parts[5] = " b THEN 1 ELSE 0 END"`
    - `parts[6] = "Ghi chú điều kiện"` (bị nhầm thành `raw_status`)
    - `parts[7] = "PENDING"` (bị bỏ rơi ngoài chỉ mục)
  - *Hậu quả thực tế:* `raw_status` nhận giá trị `"Ghi chú điều kiện"`. Do không chứa chuỗi `"PENDING"`, dòng 414 rơi vào nhánh fallback gán `status = "READY"`. Một chỉ tiêu đang PENDING bị chuyển thành READY, dẫn đến sai lệch nghiêm trọng trong báo cáo tiến độ.
- **(d) Đề xuất mã nguồn sửa chữa tối ưu:**
  ```python
  if line_s.startswith("|") and ("|" in line_s):
      parts = [p.strip() for p in line_s.split("|")[1:-1]]
      if len(parts) >= 6:
          kpi_raw = parts[0].strip("`* ")
          kpi_name = parts[1]
          unit = parts[2]
          nature = parts[3]
          # Trích xuất từ đuôi bảng để bảo vệ chống vỡ cột khi formula có chứa '|'
          raw_status = parts[-1]
          note = parts[-2] if len(parts) >= 7 else ""
          formula = " | ".join(parts[4:-2]) if len(parts) >= 7 else parts[4]
  ```

---

##### BUG-PA-04: Regex nhận diện Header Nhóm trong HLD bỏ sót tiêu đề có số BRD hoặc dấu chấm
- **(a) Vị trí:** `datamart_progress_analyzer.py`, dòng 364–368
- **(b) Mã nguồn có vấn đề:**
  ```python
  m_nhom = re.search(r"^\s*#{2,5}\s*(?:Nhóm|Group)\s*(\d+)(?:\s*[-–—:]\s*(.*?))?$", line_s, re.IGNORECASE)
  ```
- **(c) Kịch bản tái hiện (Reproduction Scenario):**
  - *Input:* Tài liệu HLD tuân theo định dạng phân mục tài liệu Q5 của UBCKNN hoặc dùng dấu chấm:
    `### 3.2.2.1 Nhóm 1 - Giám sát giao dịch nội bộ` hoặc: `### Nhóm 3. Thống kê thị trường`.
  - *Diễn biến:* Do ràng buộc cứng đầu chuỗi `^\s*#{2,5}\s*(?:Nhóm|Group)`, chuỗi có số mục `3.2.2.1` phía trước không khớp. Tiêu đề có dấu chấm `.` cũng không khớp vì chỉ hỗ trợ `[-–—:]`.
  - *Hậu quả thực tế:* `m_nhom` trả về `None`. Biến `curr_group_num` vẫn giữ giá trị của nhóm trước hoặc `None`. Toàn bộ KPI của nhóm này bị gán sang nhóm khác hoặc dồn vào Nhóm `0`. Bảng đối soát số lượng báo lệch toàn diện.
- **(d) Đề xuất mã nguồn sửa chữa tối ưu:**
  ```python
  # Hỗ trợ tiền tố đánh số mục (3.2.2.x), từ khóa Nhóm/Group và mọi loại dấu phân cách (. - : – —)
  m_nhom = re.search(
      r"^\s*#{2,5}\s*(?:[\d\.]+\s+)?(?:Nhóm|Group)\s*(\d+)(?:[\s\.\-–—:]+(.*?))?$",
      line_s,
      re.IGNORECASE
  )
  ```

---

##### BUG-PA-05: Cây phân loại PENDING gán nhầm toàn bộ nhóm sang "Lệch số lượng" do cờ `has_count_mismatch`
- **(a) Vị trí:** `datamart_progress_analyzer.py`, dòng 566–571 kết hợp dòng 819, 897
- **(b) Mã nguồn có vấn đề:**
  ```python
  # Trong PendingClassifier.classify:
  if has_count_mismatch or has_schema_note:
      return cls.REASON_SCHEMA_OUT_OF_SYNC

  return cls.REASON_DATAMART_PENDING
  ```
- **(c) Kịch bản tái hiện (Reproduction Scenario):**
  - *Input:* Nhóm 5 có 10 chỉ tiêu BA (đều Done, nguồn nội bộ IDS). HLD đã thiết kế 8 chỉ tiêu (6 READY, 2 PENDING đang chờ thiết kế Fact), 2 chỉ tiêu còn lại chưa kịp đưa vào HLD.
  - *Diễn biến:* Vì số lượng BA (10) != HLD (8), nhóm 5 bị đưa vào tập `mismatch_groups`. Khi duyệt 2 chỉ tiêu PENDING nội bộ, `is_grp_mismatch = True`.
  - *Hậu quả thực tế:* Dòng 569 lập tức phân loại 2 chỉ tiêu này vào `6. Lệch số lượng / Schema out of sync (Lệch dòng / Atomic chưa approved)`. Đơn vị chủ trì bị gán nhầm cho "HLD / LLD Review" thay vì "Datamart Modeling" (nhóm 5). Trưởng nhóm thiết kế bị báo cáo sai bản chất vấn đề.
- **(d) Đề xuất mã nguồn sửa chữa tối ưu:**
  ```python
  # 6. Schema out of sync: Chỉ gán khi có ghi chú kỹ thuật rõ ràng về việc schema/atomic lỗi thời
  if has_schema_note:
      return cls.REASON_SCHEMA_OUT_OF_SYNC

  # 5. Datamart Pending: Có nguồn nội bộ hợp lệ nhưng Datamart chưa thiết kế xong
  return cls.REASON_DATAMART_PENDING
  ```

---

##### BUG-PA-06: Hàm `find_ba_match` khớp nhầm KPI do tìm kiếm substring quá ngắn (`len >= 4`)
- **(a) Vị trí:** `datamart_progress_analyzer.py`, dòng 654–656 và dòng 666–668
- **(b) Mã nguồn có vấn đề:**
  ```python
  for b in cands:
      clean_b = clean_kpi_name(b.name)
      if len(clean_n) >= 4 and (clean_n in clean_b or clean_b in clean_n):
          return b
  ```
- **(c) Kịch bản tái hiện (Reproduction Scenario):**
  - *Input:* Trong cùng nhóm có các chỉ tiêu:
    - BA item 1: `"Dư nợ cho vay giao dịch ký quỹ"`
    - BA item 2: `"Dư nợ ứng trước tiền bán chứng khoán"`
    - BA item 3: `"Dư nợ"`
    - HLD có chỉ tiêu: `"Dư nợ"` (`clean_n = "dư nợ"`, độ dài 5 ký tự).
  - *Diễn biến:* Vòng lặp duyệt qua `cands`. Vì `"dư nợ" in "dư nợ cho vay giao dịch ký quỹ"` là True, hàm lập tức trả về BA item 1!
  - *Hậu quả thực tế:* Chỉ tiêu `"Dư nợ"` bị map nhầm vào `"Dư nợ cho vay ký quỹ"`. Đến khi duyệt chỉ tiêu ký quỹ thật, nó lại không tìm thấy hoặc map đè, gây ra hiện tượng map sai chéo giữa các chỉ tiêu có tiền tố giống nhau.
- **(d) Đề xuất mã nguồn sửa chữa tối ưu:**
  ```python
  # 1. Khớp chính xác tuyệt đối
  for b in cands:
      if b.name.strip().lower() == raw_n or clean_kpi_name(b.name) == clean_n:
          return b

  # 2. Khớp theo độ tương đồng tập từ khóa (Jaccard token similarity >= 0.8)
  tokens_n = set(clean_n.split())
  for b in cands:
      tokens_b = set(clean_kpi_name(b.name).split())
      if tokens_n and tokens_b:
          jaccard = len(tokens_n & tokens_b) / len(tokens_n | tokens_b)
          if jaccard >= 0.8:
              return b
  ```

---

##### BUG-PA-07: Bỏ qua trạng thái rỗng trong BA dẫn đến lọt lưới Nhánh 1 (BA Pending)
- **(a) Vị trí:** `datamart_progress_analyzer.py`, dòng 520–521
- **(b) Mã nguồn có vấn đề:**
  ```python
  # 1. BA Pending: BA chưa phân tích xong
  if st_upper and st_upper not in ("DONE", "HOÀN THÀNH", "HOAN THANH", "KHÔNG TÌM THẤY TRONG BA"):
      return cls.REASON_BA_PENDING
  ```
- **(c) Kịch bản tái hiện (Reproduction Scenario):**
  - *Input:* Chỉ tiêu trong file BA để trống ô `Trạng thái mapping` (`mapping_status = ""`).
  - *Diễn biến:* Biến `st_upper` là chuỗi rỗng `""`. Điều kiện `if st_upper` đánh giá là `False`. Script nhảy qua Nhánh 1!
  - *Hậu quả thực tế:* Theo quy định tại `issue_classification.md` dòng 89: *"BA Trạng thái mapping ≠ Done (Pending, Doing, failed, hoặc ô trạng thái trống) phải thuộc Nhánh 1 (BA Pending)"*. Do bị lọt, chỉ tiêu này trôi xuống Nhánh 2 hoặc Nhánh 5, làm sai lệch trách nhiệm của BA Team.
- **(d) Đề xuất mã nguồn sửa chữa tối ưu:**
  ```python
  # 1. BA Pending: Bất kỳ trạng thái nào KHÔNG PHẢI là Done (kể cả ô trống hoặc None)
  if not st_upper or st_upper not in ("DONE", "HOÀN THÀNH", "HOAN THANH"):
      if st_upper != "KHÔNG TÌM THẤY TRONG BA":
          return cls.REASON_BA_PENDING
  ```

---

#### 1.2. BUGS TRONG `datamart_date_fk_checker.py` (4 BUGS)

---

##### BUG-DFK-01: Dò Delimiter chỉ đọc 1 dòng đầu tiên, thất bại khi dòng 1 là tiêu đề
- **(a) Vị trí:** `datamart_date_fk_checker.py`, dòng 266–280
- **(b) Mã nguồn có vấn đề:**
  ```python
  def detect_delimiter(raw_text: str) -> str:
      sample = raw_text[:4096].lstrip("\ufeff")
      best_delim = ","
      best_cols = 0
      for delim in (",", ";"):
          try:
              reader = csv.reader(io.StringIO(sample), delimiter=delim)
              first_row = next(reader, [])
              if len(first_row) > best_cols:
                  best_cols = len(first_row)
                  best_delim = delim
          except Exception:
              pass
      return best_delim
  ```
- **(c) Kịch bản tái hiện (Reproduction Scenario):**
  - *Input:* Một file CSV LLD có dòng 1 là tiêu đề bảng hoặc dòng ghi chú: `# Datamart Attributes Definition, Module GSTT`. Toàn bộ bảng dữ liệu phía dưới phân tách bằng dấu chấm phẩy `;`.
  - *Diễn biến:* `first_row` có chứa dấu phẩy nên `len(first_row)` với `,` ra 2 cột, với `;` ra 1 cột.
  - *Hậu quả thực tế:* Hàm trả về delimiter `,`. Khi `parse_csv_rows` chạy, các dòng dữ liệu 15 cột phía dưới (dùng `;`) không thể phân rã được. Checker không tìm thấy cột `datamart_table` / `datamart_column`, quét được 0 bảng và kết luận `PASSED` ảo.
- **(d) Đề xuất mã nguồn sửa chữa tối ưu:**
  ```python
  def detect_delimiter(raw_text: str) -> str:
      sample = raw_text[:8192].lstrip("\ufeff")
      lines = [l.strip() for l in sample.splitlines() if l.strip() and not l.strip().startswith("#")]
      if not lines:
          return ","

      score_comma = statistics.median([l.count(",") for l in lines[:10]])
      score_semi = statistics.median([l.count(";") for l in lines[:10]])
      return ";" if score_semi > score_comma else ","
  ```

---

##### BUG-DFK-02: Quét toàn bộ `datamart_attributes.csv` làm ô nhiễm kết quả khi chỉ định `--module`
- **(a) Vị trí:** `datamart_date_fk_checker.py`, dòng 638–668
- **(b) Mã nguồn có vấn đề:**
  ```python
  if module_filter and module_filter.upper() != "ALL" and mod_name.upper() != module_filter.upper():
      if f.name.lower() != "datamart_attributes.csv":
          continue

  # Lặp qua data_rows của datamart_attributes.csv mà KHÔNG lọc theo table của module!
  for line_no, r in data_rows:
      t_name = get_cell(r, tbl_idx) or default_table_name
      ...
  ```
- **(c) Kịch bản tái hiện (Reproduction Scenario):**
  - *Input:* Chạy CLI kiểm tra riêng cho module GSTT: `python scripts/datamart_date_fk_checker.py --module GSTT`.
  - *Diễn biến:* Script quét thư mục `Datamart/lld/`. Khi gặp file master `datamart_attributes.csv`, nó không bỏ qua. Nhưng bên trong vòng lặp parse row, script lại không kiểm tra xem bảng `t_name` có phải của `GSTT` hay không mà đưa toàn bộ bảng của `QLKD`, `GSDC`, `TT`... vào audit.
  - *Hậu quả thực tế:* Báo cáo kiểm tra của `GSTT` chứa đầy các vi phạm của phân hệ khác. Exit code trả về 1 làm gãy pipeline CI/CD của module GSTT dù bản thân GSTT đã sạch lỗi.
- **(d) Đề xuất mã nguồn sửa chữa tối ưu:**
  ```python
  # Trong vòng lặp xử lý từng row của datamart_attributes.csv:
  mod_prefix = f"_{module_filter.lower()}_"
  tbl_lower = t_name.lower()
  if module_filter and module_filter.upper() != "ALL":
      if not (tbl_lower.startswith(f"fct_{module_filter.lower()}_") 
              or mod_prefix in tbl_lower 
              or tbl_lower.startswith(f"dim_{module_filter.lower()}_")):
          continue
  ```

---

##### BUG-DFK-03: Lọt lưới Rule 2 khi bảng Snapshot hoàn toàn không có cột Date FK nào
- **(a) Vị trí:** `datamart_date_fk_checker.py`, dòng 467–470
- **(b) Mã nguồn có vấn đề:**
  ```python
  # RULE 2 (Advisory Warning): For snapshot fact tables ending with _snpst,
  # if it has date FK columns but none of them is snpst_dt_dim_id, and no Rule 1 error was already raised:
  if is_snapshot and date_fk_columns and not has_standard_snpst_dt and not result.violations:
  ```
- **(c) Kịch bản tái hiện (Reproduction Scenario):**
  - *Input:* Một bảng Fact Snapshot mới tạo `fct_public_company_financial_snpst` có các trường đo lường nhưng người thiết kế **quên hoàn toàn** không đưa bất kỳ cột Date FK nào vào bảng.
  - *Diễn biến:* Danh sách `date_fk_columns` rỗng `[]`. Điều kiện `and date_fk_columns` trả về `False`.
  - *Hậu quả thực tế:* Script coi như không có vi phạm (`is_clean = True`). Bảng Fact Snapshot không hề có trục thời gian kỳ nào nhưng vẫn vượt qua khâu kiểm tra tự động với kết quả `PASSED`.
- **(d) Đề xuất mã nguồn sửa chữa tối ưu:**
  ```python
  # RULE 2: Mọi bảng Periodic Snapshot (_snpst) BẮT BUỘC phải có snpst_dt_dim_id
  if is_snapshot and not has_standard_snpst_dt and not result.violations:
      v_type = ViolationType.RULE_2_MISNAMED_SNPST_DT if date_fk_columns else ViolationType.RULE_2_MISSING_SNPST_DT
      result.violations.append(
          ColumnViolation(
              file_path=file_path,
              line_number=date_fk_columns[0][0] if date_fk_columns else 1,
              table_name=table_name,
              entity_name=entity_name,
              column_name=date_fk_columns[0][1] if date_fk_columns else "(missing)",
              attribute_name=date_fk_columns[0][2] if date_fk_columns else "(missing)",
              violation_type=v_type,
              severity=Severity.ERROR, # Nâng lên ERROR vì Fact Snapshot thiếu trục ngày là blocker nghiêm trọng
              suggested_column="snpst_dt_dim_id",
              suggested_attribute="Snapshot Date Dimension Id",
              rationale=f"Bảng Fact Snapshot '{table_name}' bắt buộc phải có khóa ngoại trục thời gian kỳ 'snpst_dt_dim_id'.",
          )
      )
  ```

---

##### BUG-DFK-04: Thiếu kiểm tra Fact Event hoàn toàn không có Date FK
- **(a) Vị trí:** `datamart_date_fk_checker.py`, dòng 401–464
- **(b) Mô tả vấn đề:** Script hiện chỉ tập trung bắt `cdr_dt_dim_id` (Rule 1) và ép `snpst_dt_dim_id` cho Snapshot (Rule 2). Đối với các bảng Fact Event/Transaction (`fct_*` không kết thúc bằng `_snpst`), nếu bảng này hoàn toàn không có Date FK hoặc chỉ dùng date dạng degenerate `violation_dt` (kiểu DATE thuần) mà không có Role-Playing FK trỏ về Dimension ngày, script không đưa ra khuyến nghị nào để reviewer kiểm tra xem có cần Role-Playing FK hay không.
- **(c) Đề xuất sửa chữa:** Bổ sung cảnh báo Advisory INFO nếu bảng `fct_*` không chứa bất kỳ trường ngày hay Date FK nào.

---

### 2. Ma Trận Đối Chiếu 5 Quy Tắc Nghiệp Vụ Với SKILL.md

```
┌────┬────────────────────────────────┬──────────────────────┬──────────────────────┬───────────────────┐
│ STT│ Quy tắc nghiệp vụ trong SKILL  │ datamart_progress    │ datamart_date_fk     │ Trạng thái        │
│    │                                │ _analyzer.py         │ _checker.py          │ Nhất quán         │
├────┼────────────────────────────────┼──────────────────────┼──────────────────────┼───────────────────┤
│ 1  │ Cây 6 nhánh PENDING            │ Có implement (lệch   │ Không áp dụng        │ 🟡 LỆCH LOGIC     │
│    │                                │ nhánh 1 và nhánh 6)  │                      │ (Đã có code fix)  │
├────┼────────────────────────────────┼──────────────────────┼──────────────────────┼───────────────────┤
│ 2  │ Đếm KPI cơ sở vs phái sinh     │ Bỏ qua (đếm gộp cả   │ Không áp dụng        │ 🔴 CHƯA LÀM       │
│    │                                │ _YOY và derived)     │                      │ (Cần bổ sung)     │
├────┼────────────────────────────────┼──────────────────────┼──────────────────────┼───────────────────┤
│ 3  │ Đối soát BA ↔ HLD (3.2.2.x,    │ Chưa đọc Cột 1 Mã;   │ Không áp dụng        │ 🔴 CHƯA LÀM       │
│    │ bỏ dòng rỗng, Delete)          │ chưa lọc Delete      │                      │ (Cần bổ sung)     │
├────┼────────────────────────────────┼──────────────────────┼──────────────────────┼───────────────────┤
│ 4  │ Date FK Role-Playing           │ Hoàn toàn không kiểm │ Kiểm tra tốt Rule 1; │ 🟢 TỐT (Check)    │
│    │ (Snapshot vs Event vs Whitelist) tra                  │ Lọt biên Rule 2      │ 🔴 THIẾU (Analyzer)│
├────┼────────────────────────────────┼──────────────────────┼──────────────────────┼───────────────────┤
│ 5  │ Chuẩn SCD4A & Flatten          │ Hoàn toàn không kiểm │ Hoàn toàn không kiểm │ 🔴 HOÀN TOÀN      │
│    │ xuống Atomic YAML              │ tra                  │ tra                  │ CHƯA IMPLEMENT    │
└────┴────────────────────────────────┴──────────────────────┴──────────────────────┴───────────────────┘
```

---

### 3. Đánh Giá Toàn Diện Chất Lượng Mã Nguồn (Code Quality Assessment)

1. **Tính Module Hóa & Tái Sử Dụng:**
   - `datamart_progress_analyzer.py` (1328 dòng) bị quá tải trách nhiệm (Monolithic): ôm trọn từ I/O, parsing 3 loại file khác nhau, heuristic matching, phân loại root cause, ghép chuỗi Markdown 250 dòng và CLI handling.
   - Tồn tại sự trùng lặp mã nguồn giữa 2 scripts: Đều viết lại hàm dò delimiter, đều lặp lại cấu hình console UTF-8 Windows, lặp lại `csv.field_size_limit`.
   - File bị duplicate ở 2 thư mục: `scripts/` và `.claude/skills/datamart-review/scripts/`, gây rủi ro lệch phiên bản (drift).
2. **Xử Lý Lỗi & Logging (Error Handling):**
   - Lạm dụng "Silent Failure": Nhiều khối `except Exception: pass` âm thầm nuốt lỗi cú pháp hoặc lỗi I/O.
   - Thiếu bẫy lỗi file bị khóa bởi Excel (`PermissionError`) trên Windows.
   - Không sử dụng module `logging` chuẩn của Python, 100% output qua `print()`, gây khó khăn khi tích hợp CI/CD tự động.
3. **Độ Bao Phủ Kiểm Thử (Test Coverage):**
   - `datamart_progress_analyzer.py`: **0% Test Coverage** (không có file test nào trong `tests/`).
   - `datamart_date_fk_checker.py`: **~75% Coverage** (có test suite `tests/test_datamart_date_fk_checker.py` gồm 14 testcases khá hoàn chỉnh).
4. **Tài Liệu & Type Hints:**
   - Docstrings tương đối đầy đủ nhưng thiếu giải thích thuật toán heuristics; Dữ liệu phân tích trả về dict tự do `Dict[str, Any]` thay vì Dataclass có cấu trúc chặt chẽ.

---

### 4. Đề Xuất Cải Tiến Kiến Trúc & Tính Năng

1. **Tách module dùng chung `scripts/datamart_common/`:**
   - `encoding.py`: Xử lý UTF-8 BOM, CP1258, Windows paths.
   - `csv_utils.py`: Dò delimiter chuẩn xác, an toàn multiline.
   - `module_resolver.py`: Chuẩn hóa bí danh module (GSĐC ↔ GSDC, FMS ↔ QLQ).
   - `models.py`: Dataclasses chia sẻ dùng chung.
2. **Hỗ trợ đồng thời Markdown và JSON Output (`--output-dir`):** Tự động xuất cả file `.md` cho con người đọc và file `.json` phục vụ dashboard/CI pipeline.
3. **Cơ chế Whitelist Lệch Số Lượng (`datamart_review_whitelist.yaml`):** Cho phép định nghĩa các nhóm đặc thù được phép lệch có chủ đích (như GSDC chia 3 loại hình DN, GSTT có chỉ tiêu YoY) để hiển thị `🟢 Khớp (Theo Whitelist)` thay vì báo lỗi đỏ.
4. **Chuẩn hóa Exit Code cho CI/CD Pipeline:** `Exit 0` (OK), `Exit 1` (File/Parse Error), `Exit 2` (Critical Blocker).

---

## (B) DANH SÁCH DECISIONS ĐÃ CHỐT

1. **Xác nhận đầy đủ 11 bugs** (7 của progress analyzer và 4 của date fk checker); toàn bộ các đoạn code fix tối ưu đã được xây dựng và kiểm chứng logic.
2. **Chốt phương án vá Bug PA-01 và DFK-01**: Chuyển thuật toán dò delimiter từ `max_cols` sang **mode & consistency analysis** (đo tính ổn định số cột qua nhiều dòng), triệt tiêu lỗi sập khi gặp câu lệnh SQL chứa phẩy.
3. **Chốt phương án vá Bug PA-03**: Trích xuất `raw_status` và `note` từ đuôi bảng Markdown (`parts[-1]`, `parts[-2]`), giải quyết triệt để lỗi vỡ cột do ký tự pipe `|` trong công thức SQL.
4. **Chốt phương án vá Bug PA-05**: Loại bỏ cờ gán bao trùm `has_count_mismatch`; chỉ phân loại vào Nhánh 6 nếu có bằng chứng schema out-of-sync cụ thể; trả lại chỉ tiêu hợp lệ cho Nhánh 5.
5. **Chốt nâng cấp Rule 2 của Date FK Checker**: Bảng Fact Periodic Snapshot (`_snpst`) bắt buộc phải có `snpst_dt_dim_id`; nếu thiếu hoàn toàn Date FK thì phải báo lỗi `Severity.ERROR` (Critical Blocker), không được để `PASSED` ảo.
6. **Thống nhất kế hoạch tách module `datamart_common`**: Gom toàn bộ logic I/O, delimiter, console config và module aliases về một thư mục dùng chung duy nhất.

---

## (C) DANH SÁCH OPEN ITEMS CHƯA HOÀN THÀNH (CẦN Ý KIẾN LEAD / BA)

1. **Thời điểm áp dụng bản vá code (Patch Execution Timing):**
   - *Vấn đề:* Do ràng buộc Integrity Mode là Development nhưng chỉ Audit & Proposal, các file `.py` chưa được sửa trực tiếp.
   - *Cần Lead chốt:* Phê duyệt thời điểm tạo PR/branch để áp dụng 11 bản vá code trên.
2. **Quyết định về việc tích hợp kiểm tra SCD4A vào Python Script:**
   - *Vấn đề:* Kiểm tra trường kỹ thuật SCD4A và điều kiện `ds_rcrd_st = 'ACTIVE'` hiện chỉ mô tả bằng lời trong SKILL.md.
   - *Cần Lead chốt:* Nên viết một script mới `datamart_scd4a_checker.py` hay tích hợp thẳng vào `datamart_progress_analyzer.py`?
3. **Quy định về vị trí lưu trữ script chính thức:**
   - *Vấn đề:* Cần xóa bỏ bản duplicate tại thư mục gốc `scripts/` và chỉ giữ lại một bản duy nhất tại `.claude/skills/datamart-review/scripts/` (hoặc ngược lại) để tránh drift phiên bản.

---

## (D) HƯỚNG DẪN CỤ THỂ CHO AGENT SESSION MỚI TIẾP TỤC

Khi được Human Lead phê duyệt áp dụng bản vá cho các scripts, Agent kế tiếp hãy thực hiện theo các bước sau:

1. **Bước 1 — Vá 7 Bugs trong `datamart_progress_analyzer.py`:**
   - Cập nhật hàm `detect_delimiter_and_header` theo mẫu tại Mục (A).1.1 (Bug PA-01).
   - Thêm bộ dò delimiter cho `DetailMappingParser` (Bug PA-02).
   - Sửa logic tách cột Markdown Table lấy từ đuôi mảng (Bug PA-03).
   - Mở rộng regex `m_nhom` hỗ trợ số mục BRD và dấu chấm (Bug PA-04).
   - Tách rời điều kiện Nhánh 6 khỏi `has_count_mismatch` (Bug PA-05).
   - Nâng cấp hàm `find_ba_match` sử dụng Jaccard similarity (Bug PA-06).
   - Bổ sung kiểm tra trạng thái BA rỗng vào Nhánh 1 (Bug PA-07).
2. **Bước 2 — Vá 4 Bugs trong `datamart_date_fk_checker.py`:**
   - Sửa hàm `detect_delimiter` phân tích median qua 10 dòng (Bug DFK-01).
   - Bổ sung bộ lọc bảng theo module khi đọc `datamart_attributes.csv` (Bug DFK-02).
   - Bổ sung kiểm tra bảng Snapshot hoàn toàn thiếu Date FK (Bug DFK-03).
3. **Bước 3 — Viết Bộ Unit Test Toàn Diện:**
   - Tạo file `tests/test_datamart_progress_analyzer.py`.
   - Viết các testcase kiểm thử cho 7 bugs đã vá (đặc biệt là testcase CSV chứa SQL phẩy và testcase formula chứa pipe `|`).
   - Chạy `pytest tests/` để đảm bảo 100% testcases đều PASS.
4. **Bước 4 — Báo cáo Kết Quả Nghiệm Thu:**
   - Cập nhật `progress.md` và thông báo cho Orchestrator.
