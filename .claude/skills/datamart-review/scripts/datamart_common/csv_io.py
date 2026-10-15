# -*- coding: utf-8 -*-
"""
datamart_common/csv_io.py — I/O chuẩn cho mọi file CSV thiết kế Datamart (RFC Đ6)

Mục tiêu: loại bỏ vĩnh viễn 2 lớp lỗi đã xảy ra thực tế
  1. `L0-CSV-STRUCTURE-BROKEN` — dấu phẩy trong `etl_logic`/`description` không được quote
     làm vỡ dòng (13 dòng hỏng trên 6 file, có dòng 18 cột trong khi header 15 cột).
  2. Nhiễu diff do khác kiểu quote — ghi lại 1 file 4.353 dòng sinh diff 8.706 dòng
     trong khi nội dung nghiệp vụ chỉ đổi ~40 dòng.

Quy tắc:
  - Đọc: luôn `utf-8-sig` (chịu được BOM), kiểm số cột từng dòng.
  - Ghi: giữ nguyên kiểu quote sẵn có của file (QUOTE_ALL nếu file đang QUOTE_ALL),
    xuống dòng LF, và **đọc lại xác minh** ngay sau khi ghi.

Dùng:
    from datamart_common.csv_io import read_design_csv, write_design_csv
    tbl = read_design_csv(path)          # -> DesignCsv(header, rows, quote_all)
    tbl.rows[0][9] = "..."
    write_design_csv(path, tbl)          # ghi + tự verify
"""

from __future__ import annotations

import csv
import io
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional


class CsvStructureError(ValueError):
    """Số cột của một dòng không khớp header."""


@dataclass
class DesignCsv:
    header: List[str]
    rows: List[List[str]] = field(default_factory=list)
    quote_all: bool = True
    path: Optional[Path] = None

    @property
    def ix(self) -> Dict[str, int]:
        return {n: i for i, n in enumerate(self.header)}

    def col(self, row: List[str], name: str) -> str:
        return row[self.ix[name]]

    def set(self, row: List[str], name: str, value: str) -> None:
        row[self.ix[name]] = value


def read_design_csv(path: str | Path, *, strict: bool = True) -> DesignCsv:
    """Đọc CSV thiết kế. strict=True thì ném CsvStructureError nếu có dòng lệch cột."""
    path = Path(path)
    raw = path.read_text(encoding="utf-8-sig")
    rows = list(csv.reader(io.StringIO(raw)))
    if not rows:
        return DesignCsv(header=[], rows=[], quote_all=True, path=path)
    header = rows[0]
    n = len(header)
    body: List[List[str]] = []
    broken: List[str] = []
    for i, r in enumerate(rows[1:], start=2):
        if not r or not any(x.strip() for x in r):
            continue
        if len(r) != n:
            broken.append(f"  dòng {i}: {len(r)} cột (header {n})")
            if not strict:
                continue
        else:
            body.append(r)
    if broken and strict:
        raise CsvStructureError(
            f"{path} có {len(broken)} dòng lệch cột — nhiều khả năng dấu phẩy trong "
            f"etl_logic/description chưa quote:\n" + "\n".join(broken[:10]))
    # đoán kiểu quote: file QUOTE_ALL luôn mở đầu bằng dấu "
    quote_all = raw.lstrip("﻿").startswith('"')
    return DesignCsv(header=header, rows=body, quote_all=quote_all, path=path)


def write_design_csv(path: str | Path, table: DesignCsv, *, quote_all: Optional[bool] = None,
                     bom: Optional[bool] = None) -> None:
    """Ghi CSV thiết kế rồi tự đọc lại xác minh số cột. Luôn dùng LF."""
    path = Path(path)
    qa = table.quote_all if quote_all is None else quote_all
    n = len(table.header)
    bad = [i for i, r in enumerate(table.rows, start=2) if len(r) != n]
    if bad:
        raise CsvStructureError(f"Từ chối ghi {path}: {len(bad)} dòng lệch cột (dòng {bad[:5]})")

    buf = io.StringIO()
    csv.writer(buf, quoting=csv.QUOTE_ALL if qa else csv.QUOTE_MINIMAL,
               lineterminator="\n").writerows([table.header] + table.rows)
    text = buf.getvalue()
    if bom is None:
        # Giữ nguyên BOM sẵn có của file — trước đây mặc định bỏ BOM, làm mọi lần ghi
        # qua apply_patch/apply_kpi_patch âm thầm đổi encoding (65/214 file thiết kế có BOM).
        bom = path.is_file() and path.read_bytes()[:3] == b"\xef\xbb\xbf"
    enc = "utf-8-sig" if bom else "utf-8"
    path.write_text(text, encoding=enc, newline="")

    # xác minh vòng tròn
    check = read_design_csv(path, strict=False)
    if len(check.header) != n:
        raise CsvStructureError(f"Ghi {path} xong nhưng header lệch: {len(check.header)} vs {n}")
    if len(check.rows) != len(table.rows):
        raise CsvStructureError(
            f"Ghi {path} xong nhưng số dòng lệch: đọc lại {len(check.rows)} vs ghi {len(table.rows)} "
            f"— có dòng bị vỡ cột.")


# ─── Chốt chặn ghi dùng chung (mọi script ghi file thiết kế phải gọi) ──────────────

SHRINK_MIN_LINES = 50      # file nhỏ hơn ngưỡng này không áp chốt tỉ lệ (thay đổi tỉ lệ vô nghĩa)
SHRINK_RATIO = 0.8         # cùng ngưỡng với S1 của ba_hld_sync_check.py / pre-flight run_quality_gates.py


class WriteGuardError(SystemExit):
    """Ghi file sẽ làm mất dữ liệu ngoài dự kiến — dừng, không ghi."""


def guard_shrink(label: str, old_n: int, new_n: int, allow: bool, *, flag: str = "--allow-shrink") -> None:
    """Từ chối ghi nếu file co lại > 20%.

    Sự cố thật: GSTT 2026-09-23, Detail Mapping 577 → 101 dòng do commit module khác.
    Chốt này chỉ chặn ghi VÔ Ý qua công cụ — cắt chủ ý phải đi qua cờ `flag` sau khi human duyệt.
    """
    if allow or old_n < SHRINK_MIN_LINES or new_n >= SHRINK_RATIO * old_n:
        return
    raise WriteGuardError(
        f"❌ CHỐT CHẶN CO FILE: {label} sẽ giảm {old_n} → {new_n} dòng "
        f"(< {int(SHRINK_RATIO * 100)}%). Nghi payload sai/thiếu dòng hoặc file đang bị phiên khác sửa. "
        f"KHÔNG ghi. Nếu thật sự có chủ ý (đã hỏi human): thêm {flag}.")


def dropped_groups(old_rows: List[List[str]], new_rows: List[List[str]], key_ix: int) -> Dict[str, int]:
    """Các giá trị khóa nhóm (VD datamart_table) có trong bản cũ nhưng biến mất hoàn toàn ở bản mới.

    Trả {giá trị: số dòng cũ}. Dùng cho file sinh ra (master registry, kpi_index) — co ít % nhưng
    mất trọn 1 bảng vẫn là mất dữ liệu (build_registry 2026-09-29: 20 bảng `_rpt` biến mất, chỉ co 7%).
    """
    new_keys = {r[key_ix] for r in new_rows if len(r) > key_ix}
    out: Dict[str, int] = {}
    for r in old_rows:
        if len(r) > key_ix and r[key_ix] not in new_keys:
            out[r[key_ix]] = out.get(r[key_ix], 0) + 1
    return out


def guard_no_drop(label: str, dropped: Dict[str, int], allow: bool, *, what: str = "bảng",
                  flag: str = "--allow-drop") -> None:
    """Từ chối ghi nếu có nhóm (bảng/KPI) biến mất hoàn toàn."""
    if allow or not dropped:
        return
    lines = "\n".join(f"   - {k} ({v} dòng)" for k, v in sorted(dropped.items())[:40])
    more = f"\n   … và {len(dropped) - 40} {what} khác" if len(dropped) > 40 else ""
    raise WriteGuardError(
        f"❌ CHỐT CHẶN MẤT {what.upper()}: ghi {label} sẽ xóa trọn {len(dropped)} {what} "
        f"({sum(dropped.values())} dòng):\n{lines}{more}\n"
        f"   Nguyên nhân thường gặp: file LLD per-module của {what} này đã bị xóa/đổi tên trong khi "
        f"HLD/flat/model vẫn dùng. KHÔNG ghi. Khôi phục file nguồn, hoặc nếu bỏ {what} là có chủ ý "
        f"(đã hỏi human): thêm {flag}.")


def scan_all(paths) -> List[str]:
    """Quét nhanh danh sách file, trả về mô tả các dòng lệch cột (rỗng = sạch)."""
    problems: List[str] = []
    for p in paths:
        try:
            read_design_csv(p, strict=True)
        except CsvStructureError as e:
            problems.append(str(e))
    return problems
