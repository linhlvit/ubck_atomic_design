# -*- coding: utf-8 -*-
"""
ctx_slice.py — cắt HLD và Detail Mapping thành lát cắt theo Nhóm / theo Section.

VÌ SAO
    `datamart-lld-design/SKILL.md` bắt đọc "HLD Section 2 từ đầu đến hết" ở Phase 0 rồi
    QUÉT LẠI lần 2 ở Phase 2; `DTM_QLKD_Detail_Mapping.csv` là 552K token. Agent không
    cần cả file — nó làm việc trên đúng MỘT Nhóm mỗi lượt.

KHÔNG SỬA FILE GỐC. Đường ghi ngược lại là `apply_patch.py`.

DÙNG
    python ctx_slice.py --module PTTT --nhom 8          # HLD block + DM rows của Nhóm 8
    python ctx_slice.py --module PTTT --sections        # Section 1 + 3 + 4 + 5 (bỏ Section 2)
    python ctx_slice.py --module PTTT --sections 3,4    # chọn Section cụ thể
    python ctx_slice.py --module PTTT --nhom 8 --print
"""
from __future__ import annotations

import argparse
import csv
import re
import sys
from pathlib import Path
from typing import List, Optional, Tuple

_script_dir = Path(__file__).resolve().parent
if str(_script_dir) not in sys.path:
    sys.path.insert(0, str(_script_dir))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

csv.field_size_limit(10_000_000)

from datamart_common import find_project_root, resolve_module_path, strip_accents  # noqa: E402
from datamart_common.csv_io import DesignCsv, read_design_csv, write_design_csv  # noqa: E402

TOK = 3.3
HLD_REL = "Datamart/context/hld"
DM_REL = "Datamart/context/dm"

_RE_H2 = re.compile(r"^##\s+Section\s+(\d+)\b", re.IGNORECASE)
_RE_H3 = re.compile(r"^###\s+")
_RE_H4 = re.compile(r"^####\s+")


def _tok(n: int) -> int:
    return int(round(n / TOK))


def _mod_dir(module: str) -> str:
    return strip_accents(module.strip()).upper()


def _nhom_heading_re(nhom: str) -> re.Pattern:
    """Khớp `#### Nhóm 8`, `#### Nhóm 08`, `#### Nhóm 8a`, `#### Nhóm 8 - …`, `… — …`."""
    return re.compile(rf"^####\s*(?:Nhóm|Nhom|Group)\s*0*{re.escape(str(nhom))}\b", re.IGNORECASE)


# ---------------------------------------------------------------------------
# HLD
# ---------------------------------------------------------------------------
def hld_group_block(hld_path: Path, nhom: str) -> Tuple[str, int, int]:
    """Trả (nội dung khối Nhóm kèm dòng `### Tab` bao ngoài, dòng bắt đầu, dòng kết thúc).

    Khối chạy từ `#### Nhóm N` tới ngay trước heading cùng cấp hoặc cao hơn kế tiếp.
    """
    lines = hld_path.read_text(encoding="utf-8").split("\n")
    pat = _nhom_heading_re(nhom)
    start = next((i for i, l in enumerate(lines) if pat.match(l)), None)
    if start is None:
        found = [l.strip() for l in lines if _RE_H4.match(l)]
        raise KeyError(f"{hld_path.name} không có `#### Nhóm {nhom}`. "
                       f"Có {len(found)} khối Nhóm: " + "; ".join(x[:40] for x in found[:20]))
    end = len(lines)
    for i in range(start + 1, len(lines)):
        if _RE_H4.match(lines[i]) or _RE_H3.match(lines[i]) or lines[i].startswith("## "):
            end = i
            break
    tab = next((lines[i] for i in range(start - 1, -1, -1) if _RE_H3.match(lines[i])), "")
    body = ([tab, ""] if tab else []) + lines[start:end]
    return "\n".join(body).rstrip() + "\n", start + 1, end


def hld_sections(hld_path: Path, wanted: List[int]) -> str:
    """Ghép các Section cấp `##` theo số. Section 2 (Tổng quan báo cáo) cố tình không
    nằm trong mặc định — nó là phần cắt theo Nhóm, lấy qua --nhom."""
    lines = hld_path.read_text(encoding="utf-8").split("\n")
    bounds: List[Tuple[int, int, int]] = []   # (số section, dòng bắt đầu, dòng kết thúc)
    marks = [(i, int(m.group(1))) for i, l in enumerate(lines) if (m := _RE_H2.match(l))]
    for k, (i, num) in enumerate(marks):
        end = marks[k + 1][0] if k + 1 < len(marks) else len(lines)
        bounds.append((num, i, end))
    out: List[str] = [lines[0], ""] if lines and lines[0].startswith("# ") else []
    got = []
    for num, i, end in bounds:
        if num in wanted:
            out.extend(lines[i:end])
            got.append(num)
    missing = [n for n in wanted if n not in got]
    if missing:
        out.append(f"> ⚠️ Không thấy Section {', '.join(map(str, missing))} trong {hld_path.name}.")
    return "\n".join(out).rstrip() + "\n"


# ---------------------------------------------------------------------------
# Detail Mapping
# ---------------------------------------------------------------------------
def dm_group_rows(dm_path: Path, nhom: str) -> Tuple[DesignCsv, List[int]]:
    """Lọc dòng Detail Mapping thuộc Nhóm N. Trả (bảng đã lọc, số dòng gốc 1-based)."""
    t = read_design_csv(dm_path, strict=False)
    if "nhom" not in t.ix:
        raise KeyError(f"{dm_path.name} không có cột `nhom` (header: {t.header})")
    j = t.ix["nhom"]
    pat = re.compile(rf"^\s*(?:Nhóm|Nhom|Group)?\s*0*{re.escape(str(nhom))}\b", re.IGNORECASE)
    rows, lines = [], []
    for n, r in enumerate(t.rows, start=2):
        if j < len(r) and pat.match(r[j]):
            rows.append(r)
            lines.append(n)
    return DesignCsv(header=t.header, rows=rows, quote_all=t.quote_all), lines


def main() -> None:
    ap = argparse.ArgumentParser(description="Cắt HLD/Detail Mapping theo Nhóm hoặc Section")
    ap.add_argument("-m", "--module", required=True)
    ap.add_argument("--nhom", help="Số Nhóm — cắt cả HLD block lẫn DM rows")
    ap.add_argument("--sections", nargs="?", const="1,3,4,5",
                    help="Danh sách Section cấp ## cần lấy (mặc định 1,3,4,5 — Section 2 lấy qua --nhom)")
    ap.add_argument("--print", dest="do_print", action="store_true")
    ap.add_argument("--root", default=None)
    args = ap.parse_args()

    if not args.nhom and args.sections is None:
        ap.error("cần --nhom N hoặc --sections")

    root = find_project_root(args.root) if args.root else find_project_root()
    md = _mod_dir(args.module)

    hld_p = resolve_module_path(root, args.module, "hld")
    dm_p = resolve_module_path(root, args.module, "detail_mapping")

    try:
        if args.sections is not None:
            if not hld_p:
                raise FileNotFoundError(f"Không thấy HLD của module {args.module}")
            want = [int(x) for x in str(args.sections).replace(" ", "").split(",") if x]
            body = hld_sections(Path(hld_p), want)
            out = root / HLD_REL / md / ("sections_" + "-".join(map(str, want)) + ".md")
            out.parent.mkdir(parents=True, exist_ok=True)
            out.write_text(body, encoding="utf-8", newline="\n")
            print(body if args.do_print else
                  f"✅ {out.relative_to(root).as_posix()} — ~{_tok(len(body))} token")

        if args.nhom:
            if hld_p:
                # Nhóm có trong BA nhưng chưa có trong HLD là trạng thái BÌNH THƯỜNG khi
                # bắt đầu thiết kế nhóm đó — cảnh báo rồi đi tiếp, không chặn.
                try:
                    body, s, e = hld_group_block(Path(hld_p), args.nhom)
                except KeyError as exc:
                    print(f"⚠️  {exc}", file=sys.stderr)
                    print(f"⚠️  HLD chưa có Nhóm {args.nhom} — nếu đang thiết kế mới thì đúng; "
                          f"nếu không, kiểm tra lại số Nhóm.")
                else:
                    out = root / HLD_REL / md / f"nhom_{args.nhom}.md"
                    out.parent.mkdir(parents=True, exist_ok=True)
                    hdr = (f"<!-- Nguồn: {Path(hld_p).relative_to(root).as_posix()} dòng {s}–{e} — "
                           f"chỉ đọc; ghi ngược qua apply_patch.py --target hld --nhom {args.nhom} -->\n\n")
                    out.write_text(hdr + body, encoding="utf-8", newline="\n")
                    print(hdr + body if args.do_print else
                          f"✅ {out.relative_to(root).as_posix()} — ~{_tok(len(body))} token "
                          f"(HLD dòng {s}–{e})")
            else:
                print(f"⚠️  Không thấy HLD của module {args.module}", file=sys.stderr)

            if dm_p:
                tbl, lines = dm_group_rows(Path(dm_p), args.nhom)
                out = root / DM_REL / md / f"nhom_{args.nhom}.csv"
                out.parent.mkdir(parents=True, exist_ok=True)
                write_design_csv(out, tbl, quote_all=True)
                rng = f"dòng {lines[0]}–{lines[-1]}" if lines else "không có dòng nào"
                print(f"✅ {out.relative_to(root).as_posix()} — {len(tbl.rows)} dòng "
                      f"(~{_tok(out.stat().st_size)} token, {Path(dm_p).name} {rng})")
            else:
                print(f"⚠️  Không thấy Detail Mapping của module {args.module}", file=sys.stderr)
    except (FileNotFoundError, KeyError) as exc:
        print(f"❌ {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
