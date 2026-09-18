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
    enc = "utf-8-sig" if (bom if bom is not None else False) else "utf-8"
    path.write_text(text, encoding=enc, newline="")

    # xác minh vòng tròn
    check = read_design_csv(path, strict=False)
    if len(check.header) != n:
        raise CsvStructureError(f"Ghi {path} xong nhưng header lệch: {len(check.header)} vs {n}")
    if len(check.rows) != len(table.rows):
        raise CsvStructureError(
            f"Ghi {path} xong nhưng số dòng lệch: đọc lại {len(check.rows)} vs ghi {len(table.rows)} "
            f"— có dòng bị vỡ cột.")


def scan_all(paths) -> List[str]:
    """Quét nhanh danh sách file, trả về mô tả các dòng lệch cột (rỗng = sạch)."""
    problems: List[str] = []
    for p in paths:
        try:
            read_design_csv(p, strict=True)
        except CsvStructureError as e:
            problems.append(str(e))
    return problems
