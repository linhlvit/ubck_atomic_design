---
name: silver-gen-docs
description: |
  Sinh tài liệu Word bàn giao Silver Lakehouse theo template chuẩn UBCK
  (Thiết kế CSDL — UBCKNN_Thiet ke co so du lieu_Template.docx).
  Pipeline 3-bước MD → review → DOCX.

  MVP scope: chỉ Tài liệu Thiết kế CSDL. PTTK Q5 sẽ làm ở phase tiếp theo.

  Sử dụng khi: cần xuất 1 source mới (FIMS/FMS/IDS/...) ra file Word handover,
  cập nhật fragment cho source đã có sau khi điều chỉnh HLD/LLD,
  hoặc rebuild file All_Silver_DBDesign.docx tổng hợp.

  Yêu cầu: HLD Overview + LLD attr_*.csv của source đã được duyệt
  (status=approved cho phần lớn entity), pending_design.csv đã review.
  Output: docs/output/All_Silver_DBDesign.docx (final) + docs/output/silver_dbdesign.md (master MD interim).
---

# Skill: Sinh tài liệu Word bàn giao Silver Lakehouse — Thiết kế CSDL

Đọc file này TRƯỚC KHI sinh handover doc cho bất kỳ source nào.

## Tài nguyên đi kèm

- **Templates MD (Jinja2):**
  - `docs/templates/silver_dbdesign.md` — master template
  - `docs/templates/silver_dbdesign_fragment.md` — fragment per-source
- **Template Word UBCK gốc (chỉ tham khảo, không edit):**
  - `docs/templates/sample/UBCKNN_Thiet ke co so du lieu_Template.docx`
- **Scripts Python:**
  - `.claude/skills/silver-gen-docs/scripts/gen_handover.py` — CLI entry point
  - `data_loader.py` — đọc HLD/LLD CSV
  - `render_md.py` — Jinja2 render
  - `filters.py` — custom filter (data_domain → SQL type, P/F Key label, ...)

## Điều kiện tiên quyết

- [ ] `Silver/hld/{SOURCE}_HLD_Overview.md` tồn tại
- [ ] `Silver/lld/{SOURCE}/` có ít nhất 1 file `attr_{SOURCE}_*.csv`
- [ ] `Silver/lld/manifest.csv` đã sync (chứa rows của SOURCE)
- [ ] `Silver/hld/silver_entities.csv` đã sync (đã chạy `aggregate_silver.py`)
- [ ] `pending_design.csv` đã review — đã quyết định cho từng pending
- [ ] Python deps: `python -c "import jinja2"` OK
- [ ] (Phase 2) `pandoc --version` ≥ 3.0 — chỉ cần cho `--mode docx`

## Quy trình 3 bước

### Bước 1 — Sinh sample (review nhanh)

```bash
python .claude/skills/silver-gen-docs/scripts/gen_handover.py \
  --source {SOURCE} --mode sample
```

Output: `docs/output/{SOURCE}/sample_dbdesign.md` (chứa 1-2 entity tiêu biểu, đầy đủ format).

**CHECKPOINT BẮT BUỘC** — User mở file sample trong VS Code (mermaid preview) và xác nhận:

- [ ] Tên Silver entity đúng
- [ ] Mô tả tiếng Việt đầy đủ, không mất diacritic
- [ ] Bảng attribute hiển thị đủ 8 cột
- [ ] Mermaid diagram syntax hợp lệ
- [ ] BCV Concept / Tier / Source Table đúng

Nếu user reject → sửa template MD hoặc data_loader, rerun bước 1. **Không** chạy bước 2 cho đến khi sample được duyệt.

### Bước 2 — Sinh fragment đầy đủ

```bash
python .claude/skills/silver-gen-docs/scripts/gen_handover.py \
  --source {SOURCE} --mode full
```

Output: `docs/output/fragments/{SOURCE}_dbdesign.md`.

**Idempotent:** chạy lại cho cùng SOURCE chỉ ghi đè đúng file đó. Fragment các SOURCE khác **không bị động chạm**.

Có thể chạy cho nhiều source liên tục:

```bash
python ... --source FIMS --mode full
python ... --source FMS --mode full
python ... --source IDS --mode full
```

### Bước 3 — Build master MD + DOCX (Phase 2 cho DOCX)

```bash
python .claude/skills/silver-gen-docs/scripts/gen_handover.py --mode docx
```

Hiện tại MVP chỉ build master MD interim: `docs/output/silver_dbdesign.md`.
Phase 2 sẽ thêm Pandoc convert sang `docs/output/All_Silver_DBDesign.docx`.

Thứ tự source trong master MD:
- Mặc định: alphabetical
- Override: tạo `docs/output/sources_order.txt` với 1 source/dòng theo thứ tự mong muốn

## Quy tắc khi LLM được gọi skill

1. **KHÔNG** tự viết fragment markdown bằng tay — luôn chạy script generator.
2. **KHÔNG** sửa file `docs/output/silver_dbdesign.md` trực tiếp — đó là interim file, sẽ bị overwrite ở mode docx.
3. **CÓ** quyền sửa `docs/templates/silver_dbdesign*.md` khi cần thay đổi structure tài liệu — sau đó chạy lại bước 2 cho **tất cả** source rồi bước 3.
4. Sample (Bước 1) **bắt buộc** trước Full (Bước 2) cho lần đầu của 1 source. Lần sau cập nhật incremental có thể skip.

## TODO / Open items

- **§3 OLAP** — chờ user định hướng (sẽ thiết kế ở Gold layer riêng?)
- **§6 Vật lý** — retention chưa chốt với DBA
- **CDE rule** (Phase 2 PTTK) — chưa có cột `is_cde` trong LLD
- **Pandoc + reference docx** — Phase 2
- **mermaid → PNG embed** trong DOCX — cần `mermaid-filter` (Phase 2)

## Xử lý error thường gặp

| Lỗi | Nguyên nhân | Fix |
|---|---|---|
| `FileNotFoundError: Silver/hld/{X}_HLD_Overview.md` | HLD chưa tạo | Báo user — phải hoàn thành HLD trước. STOP. |
| `Không tìm thấy entity nào cho source 'X'` | Manifest chưa có rows source X | Kiểm tra `Silver/lld/manifest.csv` — chạy `aggregate_silver.py` từ skill silver-lld-design |
| Diacritic vỡ | CSV không phải UTF-8 BOM | Re-encode `attr_*.csv` về `utf-8-sig` |
| `jinja2.exceptions.UndefinedError` | Field thiếu trong source data | Sửa `data_loader.py` để default empty string, hoặc cập nhật template `| default('')` |
