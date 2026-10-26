# -*- coding: utf-8 -*-
"""
ba_diff.py — BA vừa đổi gì? So `BRD/BA/BA_analyst_{MODULE}.csv` hiện tại với một phiên bản cũ, THEO NHÓM / DÒNG BA (H11, bổ sung 2026-10-26).

VÌ SAO
    Phiên QLKD 2026-10-26: tracker chỉ ghi "Nhóm 1 dòng 15,16 — Thay đổi Mapping", "Nhóm 28, 29, 30", "Nhóm 14"…; BA thực tế còn đổi mô tả trục ngày ở 24 Nhóm
    (bỏ 'T-1'), SQL Nhóm 15 dòng 89, tách 3 dòng thành 15 dòng ở Nhóm 42 — những thay đổi KHÔNG nằm trong tracker và chỉ lộ ra khi diff. `git diff` trên CSV
    8.000+ dòng nhiều dòng nhúng SQL không đọc được; `ba_hld_sync_check.py` chỉ so BA với HLD/Detail Mapping hiện tại, không cho biết BA đổi gì.

DÙNG
    # BA đã sửa trong working tree (chưa commit) — so với HEAD
    python scripts/ba_diff.py -m QLKD
    # so với commit/nhánh cụ thể, hoặc file CSV lưu tay
    python scripts/ba_diff.py -m QLKD --against 70f3a69b
    python scripts/ba_diff.py -m QLKD --against C:/tmp/BA_old.csv --nhom 1 14 28
    # kèm diff từng trường (sql/note/mô tả/cột nguồn)
    python scripts/ba_diff.py -m QLKD --nhom 14 --sql

  Dòng KHÔNG đổi không in. Mặc định mức tóm tắt (tên trường đổi); `--sql` in unified diff. Cuối báo cáo có gợi ý khi cùng 1 loại thay đổi lặp ở ≥ 3 Nhóm
  (quy tắc dùng chung → phải grep và đồng bộ ghi chú ở Detail Mapping + HLD + O_ issue trong CÙNG lượt, xem H11).
"""
from __future__ import annotations

import argparse
import difflib
import subprocess
import sys
import tempfile
from collections import Counter, defaultdict
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

FIELDS = ["description", "classification", "evaluation", "mapping_status", "source_table", "source_column", "data_type", "condition", "sql", "note"]


def _norm(x) -> str:
    return " ".join((x or "").split())


def load_items(path: Path, root: Path, module: str):
    r = parse_ba_file(path, profile_for(root, module))
    return r[0] if isinstance(r, tuple) else r


def old_path(root: Path, module: str, against: str, cur: Path, tmpdir: Path) -> Path:
    p = Path(against)
    if p.is_file():
        return p
    rel = cur.relative_to(root).as_posix()
    cp = subprocess.run(["git", "show", f"{against}:{rel}"], capture_output=True, cwd=root)
    if cp.returncode != 0:
        sys.exit(f"git show {against}:{rel} thất bại: {cp.stderr.decode('utf-8', 'replace')[:200]}")
    out = tmpdir / f"BA_{module}_old.csv"
    out.write_bytes(cp.stdout)
    return out


def _ranges(nhoms) -> str:
    """{'1','2','3','7','146'} → '1–3, 7, 146' (gộp dãy liên tiếp cho dễ đọc)."""
    nums = sorted({int(x) for x in nhoms if str(x).isdigit()})
    other = sorted(str(x) for x in nhoms if not str(x).isdigit())
    out, i = [], 0
    while i < len(nums):
        j = i
        while j + 1 < len(nums) and nums[j + 1] == nums[j] + 1:
            j += 1
        out.append(str(nums[i]) if i == j else f"{nums[i]}–{nums[j]}")
        i = j + 1
    return ", ".join(out + other)


def keyed(items):
    """{(nhom, tên chuẩn hóa, thứ tự trùng tên): item} — tên trùng trong 1 Nhóm đánh số theo thứ tự xuất hiện."""
    seen = Counter()
    out = {}
    for i in items:
        k0 = (str(i.stt), _norm(i.name))
        seen[k0] += 1
        out[k0 + (seen[k0],)] = i
    return out


def main():
    ap = argparse.ArgumentParser(description="BA đổi gì so với phiên bản cũ (theo Nhóm / dòng BA)")
    ap.add_argument("-m", "--module", required=True)
    ap.add_argument("--against", default="HEAD", help="git rev (mặc định HEAD) hoặc đường dẫn file CSV BA cũ")
    ap.add_argument("--nhom", nargs="*", default=None, help="Chỉ xét các Nhóm (STT BA)")
    ap.add_argument("--sql", action="store_true", help="In unified diff từng trường đổi (sql/note/mô tả/…)")
    ap.add_argument("--root", default=None)
    a = ap.parse_args()
    root = Path(a.root) if a.root else find_project_root()
    cur = resolve_ba_path(root, a.module)
    if not cur:
        sys.exit(f"Không thấy file BA của {a.module}")
    with tempfile.TemporaryDirectory() as td:
        old = load_items(old_path(root, a.module, a.against, Path(cur), Path(td)), root, a.module)
    new = load_items(Path(cur), root, a.module)
    ko, kn = keyed(old), keyed(new)
    want = {str(x) for x in a.nhom} if a.nhom else None
    nhoms = sorted({k[0] for k in list(ko) + list(kn)}, key=lambda s: (len(s), s))
    changed_nhom, kinds = set(), defaultdict(set)
    lines = []
    for n in nhoms:
        if want and n not in want:
            continue
        block = []
        for k in kn:
            if k[0] != n:
                continue
            if k not in ko:
                block.append(f"  + MỚI  [dòng {kn[k].line_num}] {k[1]}")
                kinds["MỚI"].add(n)
                continue
            diffs = [f for f in FIELDS if _norm(getattr(ko[k], f)) != _norm(getattr(kn[k], f))]
            if diffs:
                block.append(f"  ~ ĐỔI  [dòng {kn[k].line_num}] {k[1]}: {', '.join(diffs)}")
                for f in diffs:
                    kinds[(f, "mô tả trục ngày" if k[1].lower().startswith("chiều thời gian") else "chỉ tiêu")].add(n)
                if a.sql:
                    for f in diffs:
                        d = list(difflib.unified_diff((getattr(ko[k], f) or "").splitlines(), (getattr(kn[k], f) or "").splitlines(), "cũ", "mới", lineterm="", n=1))
                        block.append(f"      --- {f}")
                        block += [f"      {x}" for x in d[2:]]
        for k in ko:
            if k[0] == n and k not in kn:
                block.append(f"  - BỎ   [dòng {ko[k].line_num}] {k[1]}")
                kinds["BỎ"].add(n)
        if block:
            changed_nhom.add(n)
            lines.append(f"\n===== Nhóm {n}: cũ {sum(1 for k in ko if k[0] == n)} dòng | mới {sum(1 for k in kn if k[0] == n)} dòng =====")
            lines += block
    print(f"== BA {a.module}: so {Path(cur).name} (working tree) với {a.against} — {len(changed_nhom)} Nhóm có thay đổi: {_ranges(changed_nhom)}")
    print("\n".join(lines) if lines else "  (không có thay đổi ở các trường theo dõi)")
    rep = [(k, v) for k, v in kinds.items() if len(v) >= 3]
    if rep:
        print("\n⚠ Cùng loại thay đổi lặp ở ≥ 3 Nhóm (quy tắc dùng chung — grep + đồng bộ ghi chú Detail Mapping/HLD/O_ issue cùng lượt, luật H11):")
        for k, v in rep:
            print(f"   {k if isinstance(k, str) else ' / '.join(k)}: Nhóm {_ranges(v)}")
    print("→ So kết quả với tracker của Data Modeler: dòng BA đổi mà tracker không nêu vẫn phải xử lý hoặc hỏi lại (H11).")


if __name__ == "__main__":
    main()
