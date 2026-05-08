---
name: atomic-gen-docs
description: |
  Sinh tài liệu Word bàn giao Atomic Lakehouse theo template chuẩn UBCK
  (Thiết kế CSDL — UBCKNN_Thiet ke co so du lieu_Template.docx).
  Pipeline 3-bước MD → review → DOCX.

  Sử dụng khi: cần xuất 1 source mới (FIMS/FMS/IDS/...) ra file Word handover,
  cập nhật fragment cho source đã có sau khi điều chỉnh HLD/LLD,
  hoặc rebuild file Atomic_DBDesign_{SOURCE}.docx.

  Yêu cầu: HLD Overview + LLD attr_*.csv của source đã được duyệt
  (status=approved cho phần lớn entity), pending_design.csv đã review.
  Output per source: docs/output/{SOURCE}/Atomic_DBDesign_{SOURCE}.docx (final)
                   + docs/output/{SOURCE}/atomic_dbdesign_{SOURCE}.md (master MD)
                   + docs/output/{SOURCE}/fragments/ (MD + DBML)
                   + docs/output/{SOURCE}/sample/ (sample review)
---

# Skill: Sinh tài liệu Word bàn giao Atomic Lakehouse — Thiết kế CSDL

Đọc file này TRƯỚC KHI sinh handover doc cho bất kỳ source nào.

## Tài nguyên đi kèm

- **Templates MD (Jinja2):**
  - `docs/templates/atomic_dbdesign.md` — master template
  - `docs/templates/atomic_dbdesign_fragment.md` — fragment per-source
- **Template Word UBCK gốc (chỉ tham khảo, không edit):**
  - `docs/templates/sample/UBCKNN_Thiet ke co so du lieu_Template.docx`
- **Scripts Python:**
  - `.claude/skills/atomic-gen-docs/scripts/gen_handover.py` — CLI entry point
  - `data_loader.py` — đọc HLD/LLD CSV, parse UID groups, build DBML
  - `render_md.py` — Jinja2 render
  - `filters.py` — custom filter (data_domain → SQL type, P/F Key label, ...)

## Cấu trúc output

```
docs/output/
  {SOURCE}/
    sample/                        ← mode sample
      sample_dbdesign.md
      {SOURCE}.dbml
    fragments/                     ← mode full
      {SOURCE}_dbdesign.md
      {SOURCE}.dbml                ← tổng hợp tất cả entity
      {SOURCE}_UID01.dbml          ← per nhóm nghiệp vụ (nếu có Source Analysis)
      {SOURCE}_UID02.dbml
      ...
    atomic_dbdesign_{SOURCE}.md    ← mode docx (master MD interim)
    Atomic_DBDesign_{SOURCE}.docx  ← mode docx (final)
```

## Điều kiện tiên quyết

- [ ] `Atomic/hld/{SOURCE}_HLD_Overview.md` tồn tại
- [ ] `Atomic/lld/atomic_attributes.csv` đã sync (đã chạy `aggregate_atomic.py`)
- [ ] `Atomic/lld/manifest.csv` đã sync (chứa rows của SOURCE)
- [ ] `Atomic/hld/atomic_entities.csv` đã sync (đã chạy `aggregate_atomic.py`)
- [ ] Python deps: `python -c "import jinja2"` OK
- [ ] `pandoc --version` ≥ 3.0 — chỉ cần cho `--mode docx`

## Quy trình 3 bước

### Bước 1 — Sinh sample (review nhanh)

```bash
python .claude/skills/atomic-gen-docs/scripts/gen_handover.py \
  --source {SOURCE} --mode sample
```

Output: `docs/output/{SOURCE}/sample/sample_dbdesign.md` (chứa 1-2 entity tiêu biểu, đầy đủ format).

**CHECKPOINT BẮT BUỘC** — User mở file sample trong VS Code và xác nhận:

- [ ] Tên Atomic entity (logical name) đúng trong tiêu đề bảng
- [ ] Tên bảng (atomic_table, snake_case) đúng trong danh sách bảng
- [ ] Mô tả tiếng Việt đầy đủ, không mất diacritic
- [ ] Bảng attribute hiển thị đủ 13 cột
- [ ] Section Constraint có PK và FK (5 cột, kể cả Cột tham chiếu)
- [ ] Bullet metadata (Mô tả, Tên vật lý, Đường dẫn, Partition, Thời gian, Định dạng)

Nếu user reject → sửa template MD hoặc data_loader, rerun bước 1. **Không** chạy bước 2 cho đến khi sample được duyệt.

### Bước 2 — Sinh fragment đầy đủ

```bash
python .claude/skills/atomic-gen-docs/scripts/gen_handover.py \
  --source {SOURCE} --mode full
```

Output vào `docs/output/{SOURCE}/fragments/`:
- `{SOURCE}_dbdesign.md` — fragment MD đầy đủ
- `{SOURCE}.dbml` — DBML tổng hợp tất cả entity (paste vào dbdiagram.io)
- `{SOURCE}_UID01.dbml`, `{SOURCE}_UID02.dbml`, ... — DBML per nhóm nghiệp vụ (parse từ `BRD/Source/{SOURCE}_Source_Analysis.md`)

**Idempotent:** chạy lại cho cùng SOURCE chỉ ghi đè đúng folder đó.

### Bước 3 — Build DOCX

```bash
# Chỉ 1 source
python .claude/skills/atomic-gen-docs/scripts/gen_handover.py \
  --source {SOURCE} --mode docx

# Tất cả source (gom vào 1 file)
python .claude/skills/atomic-gen-docs/scripts/gen_handover.py --mode docx
```

Output: `docs/output/{SOURCE}/Atomic_DBDesign_{SOURCE}.docx`.

Thứ tự source trong master MD:
- Mặc định: alphabetical theo tên folder
- Override: tạo `docs/output/sources_order.txt` với 1 source/dòng

## Quy tắc khi LLM được gọi skill

1. **KHÔNG** tự viết fragment markdown bằng tay — luôn chạy script generator.
2. **KHÔNG** sửa file `atomic_dbdesign_{SOURCE}.md` trực tiếp — interim file, bị overwrite khi chạy lại.
3. **CÓ** quyền sửa `docs/templates/atomic_dbdesign*.md` khi cần thay đổi structure — sau đó chạy lại bước 2 rồi bước 3.
4. Sample (Bước 1) **bắt buộc** trước Full (Bước 2) cho lần đầu. Lần sau incremental có thể skip.

## Xử lý error thường gặp

| Lỗi | Nguyên nhân | Fix |
|---|---|---|
| `FileNotFoundError: Atomic/hld/{X}_HLD_Overview.md` | HLD chưa tạo | Báo user — phải hoàn thành HLD trước. STOP. |
| `Không tìm thấy entity nào cho source 'X'` | Manifest chưa có rows source X | Kiểm tra `Atomic/lld/manifest.csv` — chạy `aggregate_atomic.py` từ skill atomic-lld-design |
| Diacritic vỡ | CSV không phải UTF-8 BOM | Re-encode `attr_*.csv` về `utf-8-sig` |
| `jinja2.exceptions.UndefinedError` | Field thiếu trong source data | Sửa `data_loader.py` để default empty string, hoặc cập nhật template `\| default('')` |
| Không sinh DBML per-UID | Format heading UID trong Source Analysis không match | Các format hỗ trợ: `FIMS_UID03 —`, `UID-01 —`, `DCST-01.` |
