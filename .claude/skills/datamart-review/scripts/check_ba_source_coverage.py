# -*- coding: utf-8 -*-
"""
check_ba_source_coverage.py — Cột nguồn BA dùng mà Atomic KHÔNG map (luật A29, bổ sung 2026-10-26).

VÌ SAO
    Phiên QLKD 2026-10-26: Nhóm 31 giả định 'END_DATE ≡ DISMISSAL_DATE' — nguồn `SC_FIRM_SENIOR_PERSONNEL` có CẢ HAI cột còn Atomic chỉ map
    DISMISSAL_DATE; BA dùng `POSITION_IDS`, `RECORD_STATUS`, `LOOKUP_VALUES`… mà Atomic chưa map — thiết kế cứ READY với thay thế gần đúng và
    không Gate nào cảnh báo (Gate 0 chỉ kiểm cột Atomic mà LLD đã viết, không kiểm cột BA cần). Script này đảo chiều: lấy cột BA liệt kê ở
    "Trường nguồn" của từng dòng, đối chiếu với `source_column` (dạng `HỆ.BẢNG.CỘT`) của mọi YAML Atomic.

KẾT QUẢ LÀ THÔNG TIN (INFO), KHÔNG PHẢI GATE: cột có thể được map qua entity khác/đã có thay thế hợp lý, và `Trường nguồn` của BA đôi khi
liệt kê alias không thuộc `Bảng nguồn` của dòng. Dùng để (1) mở đầu phiên thiết kế một Nhóm: biết cột BA nào chưa có ở Atomic; (2) khi định
viết 'tạm xem A ≡ B' hoặc 'thay thế gần đúng' — nếu A nằm trong danh sách này thì phải đối chiếu BRD/Source (cả A lẫn B có cùng tồn tại?) rồi
ghi O_ issue + yêu cầu Atomic, không tự suy.

Usage:
    python scripts/check_ba_source_coverage.py --module QLKD --nhom 31
    python scripts/check_ba_source_coverage.py --module QLKD            # toàn module, gom theo cột
"""
from __future__ import annotations

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path

_script_dir = Path(__file__).resolve().parent
if str(_script_dir) not in sys.path:
    sys.path.insert(0, str(_script_dir))
for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from datamart_common import find_project_root  # noqa: E402
from datamart_common.ba_parser import group_ba_items, parse_ba_file, profile_for, resolve_ba_path  # noqa: E402

_SYS_ALIAS = {"GMS_IDS": "IDS", "SSC_SCMS": "SCMS"}
_RE_ATOMIC_SRC = re.compile(r"^\s*source_column:\s*([A-Za-z0-9_]+\.[A-Za-z0-9_]+\.[A-Za-z0-9_]+)\s*$", re.M)
_NOISE_COLS = {"*"}


def atomic_source_columns(root: Path) -> set[str]:
    """{'SCMS.SC_FIRM_SENIOR_PERSONNEL.END_DATE', …} từ mọi YAML Atomic (source_column đã đủ 3 phần)."""
    out = set()
    for f in (root / "DataModel" / "Atomic").rglob("dm_atm_*.yaml"):
        try:
            for m in _RE_ATOMIC_SRC.finditer(f.read_text(encoding="utf-8")):
                out.add(m.group(1).upper())
        except Exception:
            continue
    return out


def norm_table(t: str):
    """'SCMS_UAT.SC_FIRM_INFO' → ('SCMS', 'SC_FIRM_INFO'); không có tiền tố hệ thống → (None, tên)."""
    t = t.strip().strip(",").upper()
    if not t:
        return None
    if "." not in t:
        return (None, t)
    sysn, tbl = t.split(".", 1)
    sysn = re.sub(r"_UAT$|_PROD$", "", sysn)
    return (_SYS_ALIAS.get(sysn, sysn), tbl)


def split_tokens(text: str):
    for tok in re.split(r"[,\n;]", text or ""):
        tok = tok.strip()
        if not tok or " " in tok or "(" in tok or "'" in tok:
            continue
        col = tok.split(".")[-1].upper()
        if col and col not in _NOISE_COLS and re.fullmatch(r"[A-Z][A-Z0-9_]*", col):
            yield col


def uncovered(items, atomic: set[str]):
    """[(bảng 'SYS.TBL', cột, stt, line_num, tên dòng)] — cột BA không có `SYS.TBL.COL` nào ở Atomic cho BẤT KỲ bảng nào trong Bảng nguồn của dòng."""
    res = []
    for it in items:
        tabs = [x for x in (norm_table(t) for t in re.split(r"[,\n]", it.source_table or "")) if x and x[0]]
        if not tabs:
            continue
        for col in dict.fromkeys(split_tokens(it.source_column)):
            if any(f"{s}.{t}.{col}" in atomic for s, t in tabs):
                continue
            res.append((", ".join(f"{s}.{t}" for s, t in tabs[:3]) + (" …" if len(tabs) > 3 else ""), col, it.stt, it.line_num, (it.name or "").strip()))
    return res


def main():
    ap = argparse.ArgumentParser(description="Cột nguồn BA mà Atomic chưa map (thông tin, luật A29)")
    ap.add_argument("-m", "--module", required=True)
    ap.add_argument("--nhom", default=None, help="Chỉ xét Nhóm này (STT BA)")
    ap.add_argument("--root", default=None)
    a = ap.parse_args()
    root = Path(a.root) if a.root else find_project_root()
    ba = resolve_ba_path(root, a.module)
    if not ba:
        sys.exit(f"Không thấy file BA của {a.module}")
    r = parse_ba_file(ba, profile_for(root, a.module))
    items = r[0] if isinstance(r, tuple) else r
    if a.nhom:
        items = [i for i in items if str(i.stt) == str(a.nhom)]
    atomic = atomic_source_columns(root)
    res = uncovered(items, atomic)
    by = defaultdict(list)
    tabs_of = defaultdict(set)
    for tab, col, stt, ln, nm in res:
        by[col].append((stt, ln, nm))
        tabs_of[col].add(tab.split(",")[0].replace(" …", ""))
    print(f"== Cột nguồn BA chưa có ở Atomic — {a.module}" + (f" Nhóm {a.nhom}" if a.nhom else "") + f": {len(by)} cột (INFO, không phải Gate)")
    for col, v in sorted(by.items(), key=lambda kv: (-len(kv[1]), kv[0])):
        nhoms = sorted({x[0] for x in v}, key=lambda s: (len(str(s)), str(s)))
        tb = sorted(tabs_of[col])
        print(f"  {col:26s} {len(v):4d} dòng BA, Nhóm {', '.join(map(str, nhoms[:6]))}{' …' if len(nhoms) > 6 else ''}; bảng nguồn VD {', '.join(tb[:2])}{' …' if len(tb) > 2 else ''}; VD dòng {v[0][1]} '{v[0][2][:38]}'")
    print("→ Trước khi viết 'tạm xem A ≡ B' / 'thay thế gần đúng': đối chiếu BRD/Source (A và B có cùng tồn tại không?), ghi O_ issue + yêu cầu Atomic.")


if __name__ == "__main__":
    main()
