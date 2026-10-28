# -*- coding: utf-8 -*-
"""
apply_open_item.py — sửa / thêm dòng bảng Open Items (Section 5) trong HLD Datamart.

VÌ SAO
    `apply_patch.py --target hld` chỉ ghi được khối `#### Nhóm N`. Bảng Open Items (`| O_{M}_nn | … |`) và các đoạn Section 4
    nằm ngoài khối Nhóm nên không có đường ghi chính thức: dm_guard R2 chặn Edit/Write tay, agent phải viết script thay thế ad-hoc
    (QLQ 2026-10-28 sửa tay O_QLQ_44; QLKD 2026-10-27 'chờ Vuong chạy apply_open_items.py' mà dòng O_QLKD_63/64 treo nhiều ngày).
    Script này là đường ghi chính thức: thay đúng 1 đoạn văn bản trong đúng dòng Open Item, hoặc thêm dòng mới, có dry-run + backup.

AN TOÀN
    - Mặc định DRY-RUN; ghi thật cần --apply. Mỗi lần ghi thật sao lưu vào Datamart/context/.backup/.
    - --replace chỉ tác động vào dòng bắt đầu bằng `| O_` (có thể thu hẹp bằng --id); --old phải xuất hiện ĐÚNG 1 lần trong các dòng đó.
    - Số ký tự `|` của --old và --new phải bằng nhau (giữ nguyên số ô của dòng bảng, D14-style).
    - Giữ nguyên EOL (CRLF/LF) của file; số dòng chỉ đổi khi --add-row (+1 mỗi dòng).

DÙNG
    python apply_open_item.py -m QLKD --id O_QLKD_61 --old "(a) chưa lọc được mã sheet" --new "(a) [ĐÃ ĐÓNG 2026-10-28] mã sheet lọc bằng sheet_code"
    python apply_open_item.py -m QLKD --id O_QLKD_61 --old ... --new ... --apply
    python apply_open_item.py -m QLKD --add-row "| O_QLKD_65 | **[MỚI …]** … | K_QLKD_1 | Open — BA |" --after O_QLKD_64 --apply
"""
from __future__ import annotations

import argparse
import difflib
import re
import shutil
import sys
from datetime import datetime
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
from datamart_common.module_resolver import resolve_module_path  # noqa: E402

BACKUP_REL = "Datamart/context/.backup"
RE_OI_ROW = re.compile(r"^\|\s*(O_[A-Z0-9]+_\d+)\s*\|")


def plan_replace(lines, ident, old, new):
    """Trả (new_lines, chỉ số dòng đổi). Hàm thuần (dùng cho test). Raise ValueError nếu vi phạm an toàn."""
    if old == new:
        raise ValueError("--old và --new giống nhau")
    if old.count("|") != new.count("|"):
        raise ValueError("số ký tự '|' của --old và --new khác nhau — sẽ đổi số ô của dòng bảng")
    hits = []
    for i, ln in enumerate(lines):
        m = RE_OI_ROW.match(ln)
        if not m or (ident and m.group(1) != ident):
            continue
        n = ln.count(old)
        if n:
            hits.append((i, n))
    if not hits:
        raise ValueError("không thấy --old trong dòng Open Item nào" + (f" của {ident}" if ident else ""))
    if len(hits) > 1 or hits[0][1] > 1:
        where = ", ".join(f"dòng {i + 1} ×{n}" for i, n in hits)
        raise ValueError(f"--old xuất hiện nhiều hơn 1 lần ({where}) — thu hẹp bằng --id hoặc kéo dài đoạn --old")
    i = hits[0][0]
    out = list(lines)
    out[i] = lines[i].replace(old, new, 1)
    return out, i


def plan_add_row(lines, row, after):
    """Chèn dòng Open Item mới sau dòng `after` (id) hoặc sau dòng Open Item cuối cùng. Hàm thuần."""
    m = RE_OI_ROW.match(row)
    if not m:
        raise ValueError("--add-row phải bắt đầu bằng '| O_{M}_nn |'")
    new_id = m.group(1)
    idx = [(i, RE_OI_ROW.match(ln).group(1)) for i, ln in enumerate(lines) if RE_OI_ROW.match(ln)]
    if not idx:
        raise ValueError("HLD chưa có bảng Open Items (không có dòng '| O_… |')")
    if any(k == new_id for _, k in idx):
        raise ValueError(f"{new_id} đã tồn tại — dùng --replace để sửa")
    pos = idx[-1][0]
    if after:
        found = [i for i, k in idx if k == after]
        if not found:
            raise ValueError(f"không thấy --after {after}")
        pos = found[0]
    out = list(lines)
    out.insert(pos + 1, row)
    return out, pos + 1


def main() -> None:
    ap = argparse.ArgumentParser(description="Sửa/thêm dòng Open Items trong HLD Datamart (dry-run mặc định)")
    ap.add_argument("-m", "--module", required=True)
    ap.add_argument("--id", help="Chỉ xét dòng Open Item này (VD O_QLKD_61)")
    ap.add_argument("--old", help="Đoạn văn bản cần thay (đúng 1 lần)")
    ap.add_argument("--new", help="Đoạn văn bản thay thế")
    ap.add_argument("--add-row", help="Dòng Open Item mới, nguyên văn '| O_… | … |'")
    ap.add_argument("--after", help="Với --add-row: chèn sau Open Item này (mặc định: sau dòng Open Item cuối)")
    ap.add_argument("--apply", action="store_true", help="Ghi thật (mặc định chỉ in diff)")
    ap.add_argument("--root", default=None)
    a = ap.parse_args()
    if bool(a.add_row) == bool(a.old is not None):
        ap.error("chọn đúng 1 trong: (--old + --new) hoặc --add-row")
    if a.old is not None and a.new is None:
        ap.error("--old cần kèm --new")

    root = Path(a.root) if a.root else find_project_root()
    hld = resolve_module_path(root, a.module, "hld")
    if not (hld and Path(hld).exists()):
        sys.exit(f"Không thấy HLD của {a.module}")
    p = Path(hld)
    raw = p.read_bytes()
    eol = "\r\n" if b"\r\n" in raw else "\n"
    text = raw.decode("utf-8")
    bom = text.startswith("﻿")
    lines = text.lstrip("﻿").split(eol)
    try:
        new_lines, at = plan_add_row(lines, a.add_row, a.after) if a.add_row else plan_replace(lines, a.id, a.old, a.new)
    except ValueError as e:
        sys.exit(f"❌ {e}")

    diff = list(difflib.unified_diff(lines, new_lines, f"a/{p.name}", f"b/{p.name}", lineterm="", n=0))
    for d in diff:
        print(d[:260] + ("…" if len(d) > 260 else ""))
    print(f"→ dòng {at + 1}: {len(new_lines) - len(lines):+d} dòng; {sum(1 for d in diff if d.startswith('+') and not d.startswith('+++'))} thêm, "
          f"{sum(1 for d in diff if d.startswith('-') and not d.startswith('---'))} bớt.")
    if not a.apply:
        print("ⓘ dry-run: chưa ghi gì. Thêm --apply để ghi.")
        return
    bk = root / BACKUP_REL / f"{p.stem}.{datetime.now():%Y%m%d-%H%M%S}{p.suffix}"
    bk.parent.mkdir(parents=True, exist_ok=True)
    k = 1
    while bk.exists():  # nhiều lần ghi trong cùng 1 giây không được ghi đè bản sao lưu trước
        bk = bk.with_name(f"{p.stem}.{datetime.now():%Y%m%d-%H%M%S}_{k}{p.suffix}")
        k += 1
    shutil.copy2(p, bk)
    out = ("﻿" if bom else "") + eol.join(new_lines)
    p.write_bytes(out.encode("utf-8"))
    back = p.read_bytes().decode("utf-8").lstrip("﻿").split(eol)
    if back != new_lines:
        shutil.copy2(bk, p)
        sys.exit("❌ đọc lại không khớp — đã khôi phục từ bản sao lưu")
    print(f"✅ Đã ghi {p.relative_to(root)}. Sao lưu: {bk.relative_to(root)}")
    print("→ Chạy lại: python .claude/skills/datamart-review/scripts/build_kpi_index.py --check ; run_quality_gates.py -m", a.module)


if __name__ == "__main__":
    main()
