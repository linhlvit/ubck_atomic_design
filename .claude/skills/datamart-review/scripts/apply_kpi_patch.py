# -*- coding: utf-8 -*-
"""
apply_kpi_patch.py — 1 lệnh JSON, patch ĐỒNG THỜI 3 tầng cho MỘT KPI/cột mới:
    HLD (1 dòng trong bảng KPI 7 cột của khối `#### Nhóm N`)
    Detail Mapping (1 dòng, upsert theo kpi_id — không đụng các dòng khác của Nhóm)
    Attributes CSV per-module (0..n dòng cột vật lý mới, upsert theo datamart_table+datamart_column)

VÌ SAO
    apply_patch.py đã có nhưng thao tác theo ĐƠN VỊ "cả khối Nhóm" (HLD) hoặc "cả bộ dòng của
    1 Nhóm" (Detail Mapping) — đúng khi soạn nguyên 1 Nhóm mới, nhưng THÊM 1 KPI VÀO NHÓM ĐÃ CÓ
    SẴN thì phải gõ lại y nguyên các dòng khác để không bị patch_dm() ghi đè mất. Trong phiên
    PTTT 2026-09-21, cùng 1 công thức etl_logic dài phải gõ lặp 3 lần (Attributes/Detail Mapping/
    HLD) qua 3 lệnh apply_patch.py riêng — đây là script gộp 1 lệnh cho đúng use case đó.

    KHÔNG thay thế apply_patch.py cho việc soạn nguyên 1 Nhóm mới hoặc sửa nhiều dòng cùng lúc —
    dùng apply_patch.py --target dm cho việc đó.

AN TOÀN
    - `--dry-run` in diff cả 3 tầng, không ghi gì.
    - Mỗi file ghi thật đều sao lưu vào `Datamart/context/.backup/` (dùng chung apply_patch.backup).
    - Attributes/Detail Mapping ghi qua `csv_io` (QUOTE_ALL + UTF-8 BOM + đọc lại xác minh).
    - HLD: chỉ thay 1 dòng trong bảng KPI của khối Nhóm N đã tồn tại — Nhóm chưa có khối thì
      báo lỗi, dùng `apply_patch.py --target hld --insert-after` để tạo khối Nhóm mới trước.

DÙNG
    python apply_kpi_patch.py -m PTTT --nhom 12 --json spec.json --dry-run
    python apply_kpi_patch.py -m PTTT --nhom 12 --json spec.json
    python apply_kpi_patch.py -m PTTT --nhom 12 --json spec.json --quiet   # sau khi đã --dry-run duyệt

JSON SPEC
{
  "kpi_id": "K_PTTT_120",
  "hld_row": {"ten_kpi": "...", "don_vi": "...", "tinh_chat": "...",
              "cong_thuc": "...", "ghi_chu": "...", "trang_thai": "READY"},
  "attributes": [
    {"file": "Datamart/lld/PTTT/DTM_PTTT_fct_cap_grp_snpst.csv",
     "row": {"datamart_entity": "...", "datamart_table": "...", "datamart_attribute": "...",
             "datamart_column": "...", "nullable": "true|false", "data_domain": "...",
             "data_type": "...", "key": "", "description": "...", "etl_logic": "...",
             "etl_logic_type": "...", "source_entity": "...", "atomic_table": "...",
             "source_attribute": "...", "atomic_column": "..."}}
  ],
  "detail_mapping_row": {"kpi_id": "K_PTTT_120", "tab": "...", "nhom": "Nhóm 12 - ...",
                          "kpi_name": "...", "tinh_chat": "...", "source_module": "PTTT",
                          "mart_table": "...", "mart_column": "...", "column_role": "MEASURE",
                          "logic": "...", "ghi_chu": "..."}
}
  "hld_row" và/hoặc "attributes" và/hoặc "detail_mapping_row" đều CÓ THỂ bỏ trống (KPI thuần
  DERIVED không cột vật lý thì bỏ "attributes"; KPI chỉ đổi 1 dòng HLD không cần Detail Mapping
  mới thì bỏ "detail_mapping_row") — script chỉ patch tầng nào có mặt trong JSON.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

_script_dir = Path(__file__).resolve().parent
if str(_script_dir) not in sys.path:
    sys.path.insert(0, str(_script_dir))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from datamart_common import find_project_root, resolve_module_path  # noqa: E402
from datamart_common.csv_io import read_design_csv, write_design_csv, DesignCsv  # noqa: E402
import apply_patch  # noqa: E402 — reuse backup(), show_diff(), patch_hld(), find_nhom_block()

_RE_NHOM_NUM = re.compile(r"(?:Nhóm|Nhom|Group)\s*(\d+)", re.IGNORECASE)
_RE_KPI_NUM = re.compile(r"_(\d+)$")

HLD_TABLE_HEADER_RE = re.compile(r"^\|\s*KPI[ _]?ID\s*\|", re.IGNORECASE)
HLD_ROW_COLS = ["ten_kpi", "don_vi", "tinh_chat", "cong_thuc", "ghi_chu", "trang_thai"]


# ---------------------------------------------------------------------------
# Tầng 1 — HLD: 1 dòng trong bảng KPI 7 cột của khối Nhóm N
# ---------------------------------------------------------------------------
def _esc(cell: str) -> str:
    return str(cell).replace("|", "\\|").replace("\n", " ")


def _kpi_num(kpi_id: str) -> Optional[int]:
    m = _RE_KPI_NUM.search(kpi_id)
    return int(m.group(1)) if m else None


def upsert_kpi_row_in_block(block_text: str, kpi_id: str, hld_row: Dict[str, str]) -> str:
    lines = block_text.split("\n")
    hdr_idx = next((i for i, l in enumerate(lines) if HLD_TABLE_HEADER_RE.match(l.strip())), None)
    if hdr_idx is None:
        raise SystemExit("❌ Không thấy bảng KPI 7 cột (`| KPI ID | ... |`) trong khối Nhóm này. "
                          "Dùng apply_patch.py --target hld để soạn cả khối trước.")
    sep_idx = hdr_idx + 1  # dòng |---|---|...|
    data_start = sep_idx + 1
    data_end = data_start
    while data_end < len(lines) and lines[data_end].lstrip().startswith("|"):
        data_end += 1

    missing = [c for c in HLD_ROW_COLS if c not in hld_row]
    if missing:
        raise SystemExit(f"❌ hld_row thiếu cột bắt buộc: {missing} (cần đủ {HLD_ROW_COLS})")
    new_row = "| " + " | ".join([_esc(kpi_id)] + [_esc(hld_row[c]) for c in HLD_ROW_COLS]) + " |"

    data_rows = lines[data_start:data_end]
    existing_idx = next((i for i, l in enumerate(data_rows)
                          if re.match(rf"^\|\s*{re.escape(kpi_id)}\s*\|", l.strip())), None)
    if existing_idx is not None:
        data_rows[existing_idx] = new_row
    else:
        target_n = _kpi_num(kpi_id)
        pos = len(data_rows)
        if target_n is not None:
            for k, l in enumerate(data_rows):
                cell1 = l.strip().split("|")[1].strip() if l.strip().startswith("|") else ""
                n = _kpi_num(cell1)
                if n is not None and n > target_n:
                    pos = k
                    break
        data_rows.insert(pos, new_row)

    new_lines = lines[:data_start] + data_rows + lines[data_end:]
    return "\n".join(new_lines)


# ---------------------------------------------------------------------------
# Tầng 2 — Detail Mapping: upsert 1 dòng theo kpi_id, không đụng dòng khác của Nhóm
# ---------------------------------------------------------------------------
def upsert_dm_row(cur: DesignCsv, nhom: str, row: Dict[str, str]) -> DesignCsv:
    header = [h.strip() for h in cur.header]
    missing = [h for h in header if h not in row]
    if missing:
        raise SystemExit(f"❌ detail_mapping_row thiếu cột: {missing} (cần đủ header: {header})")
    new_row = [str(row[h]) for h in header]

    j_kpi = header.index("kpi_id")
    j_nhom = header.index("nhom")
    kpi_id = new_row[j_kpi]

    pat = re.compile(rf"^\s*(?:Nhóm|Nhom|Group)?\s*0*{re.escape(str(nhom))}\b", re.IGNORECASE)
    target = int(nhom) if str(nhom).isdigit() else None

    rows = list(cur.rows)
    # QUAN TRỌNG: 1 kpi_id có thể xuất hiện ở NHIỀU Nhóm khác nhau (reuse hợp lệ, VD K_GSTT_85
    # ở cả Nhóm 28 và Nhóm 29) — khớp CẢ kpi_id LẪN nhom, không chỉ kpi_id, nếu không sẽ ghi đè
    # nhầm dòng của Nhóm khác (đã xảy ra thực tế 2026-09-21, xem CLAUDE.md/session note).
    existing_idx = next((i for i, r in enumerate(rows)
                          if j_kpi < len(r) and r[j_kpi] == kpi_id
                          and j_nhom < len(r) and pat.match(r[j_nhom])), None)
    if existing_idx is not None:
        rows[existing_idx] = new_row
        return DesignCsv(header=cur.header, rows=rows, quote_all=cur.quote_all, path=cur.path)
    last_same_nhom = None
    for i, r in enumerate(rows):
        if j_nhom < len(r) and pat.match(r[j_nhom]):
            last_same_nhom = i
    if last_same_nhom is not None:
        pos = last_same_nhom + 1
    else:
        pos = len(rows)
        if target is not None:
            for k, r in enumerate(rows):
                m = _RE_NHOM_NUM.search(r[j_nhom]) if j_nhom < len(r) else None
                if m and int(m.group(1)) > target:
                    pos = k
                    break
    rows = rows[:pos] + [new_row] + rows[pos:]
    return DesignCsv(header=cur.header, rows=rows, quote_all=cur.quote_all, path=cur.path)


# ---------------------------------------------------------------------------
# Tầng 3 — Attributes CSV per-module: upsert theo (datamart_table, datamart_column)
# ---------------------------------------------------------------------------
def upsert_attr_row(cur: DesignCsv, row: Dict[str, str]) -> DesignCsv:
    header = [h.strip() for h in cur.header]
    missing = [h for h in header if h not in row]
    if missing:
        raise SystemExit(f"❌ attributes[].row thiếu cột: {missing} (cần đủ header: {header})")
    new_row = [str(row[h]) for h in header]

    j_table = header.index("datamart_table")
    j_col = header.index("datamart_column")
    key = (new_row[j_table], new_row[j_col])

    rows = list(cur.rows)
    existing_idx = next((i for i, r in enumerate(rows)
                          if j_table < len(r) and j_col < len(r) and (r[j_table], r[j_col]) == key), None)
    if existing_idx is not None:
        rows[existing_idx] = new_row
    else:
        rows = rows + [new_row]
    return DesignCsv(header=cur.header, rows=rows, quote_all=cur.quote_all, path=cur.path)


def main() -> None:
    ap = argparse.ArgumentParser(description="1 lệnh JSON, patch HLD + Detail Mapping + Attributes cho 1 KPI mới")
    ap.add_argument("-m", "--module", required=True)
    ap.add_argument("--nhom", required=True, help="Số Nhóm (dùng để định vị khối HLD và vị trí chèn Detail Mapping)")
    ap.add_argument("--json", dest="spec", required=True, help="File JSON spec (xem docstring script)")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--quiet", action="store_true",
                     help="Bỏ in nguyên văn diff khi ghi thật — dùng SAU KHI đã --dry-run và được duyệt.")
    ap.add_argument("--root", default=None)
    args = ap.parse_args()

    root = find_project_root(args.root) if args.root else find_project_root()
    spec_path = Path(args.spec)
    if not spec_path.is_file():
        raise SystemExit(f"❌ Không thấy file JSON spec: {spec_path}")
    spec: Dict[str, Any] = json.loads(spec_path.read_text(encoding="utf-8"))

    kpi_id = spec.get("kpi_id")
    if not kpi_id:
        raise SystemExit("❌ JSON spec thiếu 'kpi_id'.")

    quiet_effective = args.quiet and not args.dry_run
    any_change = False

    # --- Tầng 1: HLD ---
    if spec.get("hld_row"):
        hld_path = resolve_module_path(root, args.module, "hld")
        if not hld_path:
            raise SystemExit(f"❌ Không thấy HLD của module {args.module}")
        hld_path = Path(hld_path)
        rel = hld_path.relative_to(root).as_posix()
        block = apply_patch.get_nhom_block_text(hld_path, args.nhom)
        new_block = upsert_kpi_row_in_block(block, kpi_id, spec["hld_row"])
        old_lines, new_lines = apply_patch.patch_hld(root, hld_path, args.nhom, new_block, insert_after=None)
        print(f"\n— HLD ({rel}, Nhóm {args.nhom}, KPI {kpi_id}) —")
        changed = apply_patch.show_diff(old_lines, new_lines, rel, quiet=quiet_effective)
        if changed:
            any_change = True
            if not args.dry_run:
                b = apply_patch.backup(root, hld_path)
                hld_path.write_text("\n".join(new_lines), encoding="utf-8", newline="\n")
                print(f"✅ Đã ghi {rel}. Sao lưu: {b.relative_to(root).as_posix()}")

    # --- Tầng 2: Detail Mapping ---
    if spec.get("detail_mapping_row"):
        dm_path = resolve_module_path(root, args.module, "detail_mapping")
        if not dm_path:
            raise SystemExit(f"❌ Không thấy Detail Mapping của module {args.module}")
        dm_path = Path(dm_path)
        rel = dm_path.relative_to(root).as_posix()
        cur = read_design_csv(dm_path, strict=False)
        new = upsert_dm_row(cur, args.nhom, spec["detail_mapping_row"])
        fmt = lambda t: [",".join(r) for r in t.rows]  # noqa: E731
        print(f"\n— Detail Mapping ({rel}, KPI {kpi_id}) —")
        changed = apply_patch.show_diff(fmt(cur), fmt(new), rel, quiet=quiet_effective)
        if changed:
            any_change = True
            if not args.dry_run:
                b = apply_patch.backup(root, dm_path)
                write_design_csv(dm_path, new, quote_all=cur.quote_all)
                chk = read_design_csv(dm_path, strict=False)
                if len(chk.rows) != len(new.rows) or chk.header != new.header:
                    raise SystemExit(f"❌ Xác minh sau ghi THẤT BẠI. Khôi phục từ {b}")
                print(f"✅ Đã ghi {rel}: {len(cur.rows)} → {len(new.rows)} dòng. "
                      f"Sao lưu: {b.relative_to(root).as_posix()}")

    # --- Tầng 3: Attributes CSV per-module ---
    for entry in spec.get("attributes", []):
        attr_path = root / entry["file"]
        if not attr_path.is_file():
            raise SystemExit(f"❌ Không thấy Attributes CSV: {attr_path}")
        rel = attr_path.relative_to(root).as_posix()
        cur = read_design_csv(attr_path, strict=False)
        new = upsert_attr_row(cur, entry["row"])
        fmt = lambda t: [",".join(r) for r in t.rows]  # noqa: E731
        print(f"\n— Attributes ({rel}) —")
        changed = apply_patch.show_diff(fmt(cur), fmt(new), rel, quiet=quiet_effective)
        if changed:
            any_change = True
            if not args.dry_run:
                b = apply_patch.backup(root, attr_path)
                write_design_csv(attr_path, new, quote_all=cur.quote_all)
                chk = read_design_csv(attr_path, strict=False)
                if len(chk.rows) != len(new.rows) or chk.header != new.header:
                    raise SystemExit(f"❌ Xác minh sau ghi THẤT BẠI. Khôi phục từ {b}")
                print(f"✅ Đã ghi {rel}: {len(cur.rows)} → {len(new.rows)} dòng. "
                      f"Sao lưu: {b.relative_to(root).as_posix()}")

    if not any_change:
        print("\nⓘ Không có tầng nào thay đổi (hoặc JSON spec rỗng cả 3 khóa).")
        return

    if args.dry_run:
        print("\nⓘ --dry-run: chưa ghi gì.")
        return

    print("\n→ Sau khi ghi cả 3 tầng, nhớ chạy (nếu có cột Attributes mới):")
    print("   python .claude/skills/datamart-review/scripts/build_registry.py")
    print("   python .claude/skills/datamart-review/scripts/build_model_yaml.py")
    print("   python .claude/skills/datamart-review/scripts/build_kpi_index.py")
    print(f"→ Rồi kiểm tra lại: python .claude/skills/datamart-review/scripts/run_quality_gates.py -m {args.module}")


if __name__ == "__main__":
    main()
