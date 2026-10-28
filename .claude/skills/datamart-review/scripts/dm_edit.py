# -*- coding: utf-8 -*-
"""
dm_edit.py — sửa có kiểm soát cột `logic` / `ghi_chu` của Detail Mapping theo KPI/Nhóm (slice → sửa → apply_patch).

VÌ SAO
    Phiên QLQ/QLKD 2026-10-28 phải viết 7 script tạm cùng 1 khung: ctx_slice → đọc CSV → `replace` có assert 'đúng 1 lần' → ghi CSV → apply_patch.
    Mỗi script tự tay xử lý quoting/EOL/BOM và có thể sai nhẹ (thay trùng, nhầm dòng FILTER, nối ghi chú 2 lần khi chạy lại). Công cụ này gom khung đó:
    chọn dòng theo (Nhóm, kpi_id, column_role), thay thế/regex/nối ghi chú, báo dòng nào KHÔNG đổi, rồi giao cho apply_patch ghi (backup + chốt co file).

AN TOÀN
    - Mặc định DRY-RUN (in diff của apply_patch, không ghi). Ghi thật: --apply (apply_patch --quiet).
    - --sub OLD NEW: OLD phải xuất hiện ĐÚNG 1 lần trong cột của MỖI dòng được chọn (không thì dừng, không ghi gì). --any-count cho phép ≥1 lần.
    - --regex PATTERN REPL: thay mọi lần khớp; dòng được chọn mà không khớp lần nào → dừng (trừ --allow-unchanged).
    - --append TEXT: nối cuối cột; bỏ qua dòng đã có sẵn đúng TEXT (chạy lại không nhân đôi).
    - Không bao giờ động tới dòng không được chọn (apply_patch thay nguyên khối Nhóm nhưng dòng ngoài lựa chọn giữ nguyên văn bản).

DÙNG
    # QLQ N8/9/11/12: lowerUTF8 + nhãn cột prefix (regex), ghi chú đi kèm
    python dm_edit.py -m QLQ --nhom 8 9 11 12 --field logic --regex "LOWER\\((\\w+\\.fmr_nm)\\)" "lowerUTF8(\\1)"
    # QLKD K_QLKD_12: thêm sheet_code
    python dm_edit.py -m QLKD --nhom 1 --kpi K_QLKD_12 --role MEASURE --field logic \\
        --sub "cell_id = 'TS046' AND " "cell_id = 'TS046' AND report_indicator_dim.sheet_code = 'II.4' AND"
    python dm_edit.py -m QLKD --nhom 1 --kpi K_QLKD_12 --field ghi_chu --append "[SỬA 2026-10-28] …" --apply
"""
from __future__ import annotations

import argparse
import csv
import io
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Tuple

_script_dir = Path(__file__).resolve().parent
if str(_script_dir) not in sys.path:
    sys.path.insert(0, str(_script_dir))
for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from datamart_common import find_project_root  # noqa: E402

FIELDS = ("logic", "ghi_chu")


def edit_rows(hdr: Sequence[str], body: List[List[str]], *, kpis: Optional[Sequence[str]], roles: Optional[Sequence[str]], field: str,
              subs: Sequence[Tuple[str, str]] = (), regexes: Sequence[Tuple[str, str]] = (), appends: Sequence[str] = (),
              any_count: bool = False, allow_unchanged: bool = False, sep: str = " ") -> Tuple[List[str], List[str]]:
    """Sửa tại chỗ các dòng được chọn. Trả (kpi/role đã đổi, thông báo lỗi). Có lỗi → body KHÔNG bị sửa (hàm thuần, dùng cho test)."""
    ix = {h: i for i, h in enumerate(hdr)}
    for need in ("kpi_id", "column_role", field):
        if need not in ix:
            return [], [f"thiếu cột {need} trong header"]
    sel = [r for r in body if (not kpis or r[ix["kpi_id"]] in kpis) and (not roles or r[ix["column_role"]] in roles)]
    if not sel:
        return [], ["không có dòng nào khớp bộ chọn (--kpi/--role/--nhom)"]
    errs: List[str] = []
    new_vals: List[str] = []
    for r in sel:
        v = r[ix[field]]
        label = f"{r[ix['kpi_id']]} {r[ix['column_role']]}"
        for old, new in subs:
            n = v.count(old)
            if n == 0 or (n > 1 and not any_count):
                errs.append(f"{label}: --sub '{old[:60]}' khớp {n} lần (cần đúng 1; --any-count cho phép ≥1)")
                continue
            v = v.replace(old, new)
        for pat, repl in regexes:
            v, n = re.subn(pat, repl, v)
            if n == 0 and not allow_unchanged:
                errs.append(f"{label}: --regex '{pat[:60]}' không khớp lần nào")
        for txt in appends:
            if txt and txt not in v:
                v = (v.rstrip() + sep + txt) if v.strip() else txt
        if v == r[ix[field]] and not allow_unchanged and not errs:
            errs.append(f"{label}: không đổi gì (đã có sẵn nội dung?) — thêm --allow-unchanged nếu chấp nhận")
        new_vals.append(v)
    if errs:
        return [], errs
    changed = []
    for r, v in zip(sel, new_vals):
        if v != r[ix[field]]:
            r[ix[field]] = v
            changed.append(f"{r[ix['kpi_id']]}/{r[ix['column_role']]}")
    return changed, []


def run_cmd(cmd: List[str], cwd: Path) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, cwd=cwd, capture_output=True, encoding="utf-8", errors="replace")


def main() -> int:
    ap = argparse.ArgumentParser(description="Sửa logic/ghi_chu Detail Mapping theo KPI (dry-run mặc định)")
    ap.add_argument("-m", "--module", required=True)
    ap.add_argument("--nhom", nargs="+", required=True, help="Một hoặc nhiều số Nhóm")
    ap.add_argument("--kpi", help="kpi_id, phân cách bằng dấu phẩy (mặc định: mọi KPI của Nhóm)")
    ap.add_argument("--role", help="column_role, phân cách bằng dấu phẩy (MEASURE,FILTER,SLICER,GROUP_BY,DERIVED)")
    ap.add_argument("--field", required=True, choices=FIELDS)
    ap.add_argument("--sub", nargs=2, action="append", default=[], metavar=("OLD", "NEW"))
    ap.add_argument("--regex", nargs=2, action="append", default=[], metavar=("PATTERN", "REPL"))
    ap.add_argument("--append", action="append", default=[], metavar="TEXT")
    ap.add_argument("--sep", default=" ", help="Dấu nối khi --append (mặc định 1 khoảng trắng; dùng ' | ' cho ghi_chu nhiều khối)")
    ap.add_argument("--any-count", action="store_true")
    ap.add_argument("--allow-unchanged", action="store_true")
    ap.add_argument("--apply", action="store_true", help="Ghi thật qua apply_patch --quiet (mặc định dry-run)")
    ap.add_argument("--root", default=None)
    a = ap.parse_args()
    if not (a.sub or a.regex or a.append):
        ap.error("cần ít nhất 1 trong --sub / --regex / --append")

    root = Path(a.root) if a.root else find_project_root()
    sd = root / ".claude" / "skills" / "datamart-review" / "scripts"
    kpis = [k.strip() for k in a.kpi.split(",")] if a.kpi else None
    roles = [x.strip() for x in a.role.split(",")] if a.role else None
    plans = []
    for n in a.nhom:
        r = run_cmd([sys.executable, str(sd / "ctx_slice.py"), "-m", a.module, "--nhom", str(n)], root)
        src = root / "Datamart" / "context" / "dm" / a.module / f"nhom_{n}.csv"
        if r.returncode != 0 or not src.exists():
            print(f"❌ ctx_slice Nhóm {n} lỗi:\n{r.stdout}{r.stderr}")
            return 2
        rows = list(csv.reader(io.StringIO(src.read_text(encoding="utf-8-sig"))))
        hdr, body = rows[0], rows[1:]
        changed, errs = edit_rows(hdr, body, kpis=kpis, roles=roles, field=a.field, subs=a.sub, regexes=a.regex,
                                  appends=a.append, any_count=a.any_count, allow_unchanged=a.allow_unchanged, sep=a.sep)
        if errs:
            print(f"❌ Nhóm {n}: dừng, KHÔNG ghi gì:")
            for e in errs:
                print("   -", e)
            return 1
        out = src.with_name(f"nhom_{n}.edit.csv")
        with out.open("w", encoding="utf-8-sig", newline="") as fh:
            w = csv.writer(fh, quoting=csv.QUOTE_ALL, lineterminator="\n")
            w.writerow(hdr)
            w.writerows(body)
        print(f"Nhóm {n}: {len(changed)} dòng đổi — {', '.join(changed[:12])}{' …' if len(changed) > 12 else ''}")
        plans.append((n, out))

    for n, out in plans:
        cmd = [sys.executable, str(sd / "apply_patch.py"), "-m", a.module, "--target", "dm", "--nhom", str(n), "--from", str(out)]
        r = run_cmd(cmd + (["--quiet"] if a.apply else ["--dry-run"]), root)
        for line in (r.stdout + r.stderr).splitlines():
            if a.apply and not line.startswith(("✅", "❌", "⚠")):
                continue
            print(line[:260])
        if r.returncode != 0:
            print(f"❌ apply_patch Nhóm {n} lỗi (mã {r.returncode})")
            return r.returncode
    if not a.apply:
        print("ⓘ dry-run: chưa ghi gì. Duyệt diff rồi chạy lại với --apply.")
    else:
        print(f"→ Chạy tiếp: build_kpi_index.py; run_quality_gates.py -m {a.module} --nhom {' '.join(a.nhom)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
