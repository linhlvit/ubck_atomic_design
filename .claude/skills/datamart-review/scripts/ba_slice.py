# -*- coding: utf-8 -*-
"""
ba_slice.py — cắt `BRD/BA/BA_analyst_{MODULE}.csv` thành lát cắt theo Nhóm.

VÌ SAO
    File BA của QLKD là 998K token, một mình đã vượt trần ngữ cảnh 500K. Nhưng đơn vị
    công việc thật là MỘT NHÓM KPI, không phải cả phân hệ: Nhóm lớn nhất toàn repo chỉ
    45K token, trung vị 2,7–9,2K. Cắt theo Nhóm là đủ; cắt theo Tab thì không
    (tab DATA EXPLORER của QLKD một mình đã 470K).

KHÔNG SỬA FILE GỐC. Mọi thứ ghi ra `Datamart/context/ba/`.

DÙNG
    # bản đồ điều hướng, nạp một lần đầu phiên (~4-6K token)
    python ba_slice.py --module QLKD --index
    python ba_slice.py --module ALL  --index

    # lát cắt một Nhóm — đây là thứ agent đọc khi thiết kế
    python ba_slice.py --module QLKD --nhom 8
    python ba_slice.py --module QLKD --nhom 8 --with-sql   # LLD Phase 2 cần SQL (Quy tắc L17)
    python ba_slice.py --module QLKD --nhom 8 --print      # in luôn ra stdout, khỏi Read file
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Set

_script_dir = Path(__file__).resolve().parent
if str(_script_dir) not in sys.path:
    sys.path.insert(0, str(_script_dir))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from datamart_common import find_project_root, strip_accents  # noqa: E402
from datamart_common.ba_parser import (  # noqa: E402
    BAItem,
    BaProfileMismatch,
    drop_column_indices,
    group_ba_items,
    list_ba_modules,
    parse_ba_file,
    profile_for,
    resolve_ba_path,
)
from datamart_common.csv_io import DesignCsv, write_design_csv  # noqa: E402

CTX_REL = "Datamart/context/ba"
TOK = 3.3  # ký tự / token — hệ số dùng nhất quán trong toàn bộ đo đạc của dự án

INDEX_HEADER = [
    "nhom", "ten_nhom", "so_dong", "done", "doing", "pending", "khac",
    "chieu", "chi_tieu_co_so", "chi_tieu_phai_sinh",
    "token_khong_sql", "token_co_sql",
]


def _tok(n_chars: int) -> int:
    return int(round(n_chars / TOK))


def _mod_dir(module: str) -> str:
    """Tên thư mục ASCII: BA dùng 'GSĐC' nhưng artifact Datamart dùng 'GSDC'."""
    return strip_accents(module.strip()).upper()


def _row_chars(items: Sequence[BAItem], keep: Sequence[int]) -> int:
    return sum(len(r.raw_row[i]) for r in items for i in keep if i < len(r.raw_row))


# ---------------------------------------------------------------------------
# --index
# ---------------------------------------------------------------------------
def build_index(root: Path, module: str) -> Path:
    path = resolve_ba_path(root, module)
    if not path:
        raise FileNotFoundError(f"Không thấy file BA của module {module}")
    prof = profile_for(root, module)
    items, meta = parse_ba_file(path, prof, include_deleted=True)
    groups = group_ba_items(items)

    keep_no_sql = [i for i in range(len(meta.header))
                   if i not in drop_column_indices(meta.header, prof, with_sql=False)]
    keep_sql = [i for i in range(len(meta.header))
                if i not in drop_column_indices(meta.header, prof, with_sql=True)]

    rows: List[List[str]] = []
    for key, its in groups.items():
        live = [x for x in its if not x.is_deleted]
        st = [x.mapping_status.strip().lower() for x in live]
        cls = [x.classification.strip().lower() for x in live]
        name = next((x.dashboard for x in its if x.dashboard), "")
        rows.append([
            key, name, str(len(live)),
            str(sum(1 for s in st if s in ("done", "hoàn thành"))),
            str(sum(1 for s in st if s == "doing")),
            str(sum(1 for s in st if s in ("pending", "chờ"))),
            str(sum(1 for s in st if s not in ("done", "hoàn thành", "doing", "pending", "chờ"))),
            str(sum(1 for c in cls if c.startswith("chiều"))),
            str(sum(1 for c in cls if "cơ sở" in c)),
            str(sum(1 for c in cls if "phái sinh" in c)),
            str(_tok(_row_chars(live, keep_no_sql))),
            str(_tok(_row_chars(live, keep_sql))),
        ])

    out = root / CTX_REL / f"BA_index_{_mod_dir(module)}.csv"
    out.parent.mkdir(parents=True, exist_ok=True)
    write_design_csv(out, DesignCsv(header=INDEX_HEADER, rows=rows, quote_all=False, path=out),
                     quote_all=False)
    return out


# ---------------------------------------------------------------------------
# --nhom N
# ---------------------------------------------------------------------------
def render_group(root: Path, module: str, nhom: str, with_sql: bool) -> str:
    path = resolve_ba_path(root, module)
    if not path:
        raise FileNotFoundError(f"Không thấy file BA của module {module}")
    prof = profile_for(root, module)
    items, meta = parse_ba_file(path, prof, include_deleted=False)
    groups = group_ba_items(items)

    key = str(nhom).strip()
    its = groups.get(key)
    if its is None:
        avail = ", ".join(list(groups)[:40])
        raise KeyError(f"Module {module} không có Nhóm {key!r}. Nhóm sẵn có: {avail}"
                       f"{' …' if len(groups) > 40 else ''}")

    dropped = drop_column_indices(meta.header, prof, with_sql=with_sql)
    keep = [i for i in range(len(meta.header)) if i not in dropped]

    # `Dashboard/báo cáo` lặp nguyên văn trên mọi dòng (QLKD: 138K token chỉ riêng cột này).
    # Giá trị giống nhau trong cả nhóm -> đưa lên header nhóm, bỏ khỏi từng dòng.
    dash_vals = {r.dashboard for r in its}
    dash_hoisted = len(dash_vals) == 1 and next(iter(dash_vals)) != ""
    dash_idx = next((i for i, h in enumerate(meta.header)
                     if h.strip().lower() == (prof.get("dashboard_column") or "").strip().lower()), None)
    if dash_hoisted and dash_idx is not None:
        keep = [i for i in keep if i != dash_idx]

    st = [x.mapping_status.strip().lower() for x in its]
    L: List[str] = []
    L.append(f"# BA — {module} / Nhóm {key}")
    L.append("")
    if dash_hoisted:
        L.append(f"**Dashboard/báo cáo:** {next(iter(dash_vals))}")
    L.append(f"**Số chỉ tiêu:** {len(its)}  "
             f"(Done {sum(1 for s in st if s in ('done', 'hoàn thành'))} / "
             f"Doing {sum(1 for s in st if s == 'doing')} / "
             f"Pending {sum(1 for s in st if s in ('pending', 'chờ'))})")
    L.append(f"**Nguồn:** `{path.as_posix()}` (dòng {its[0].line_num}–{its[-1].line_num}) — "
             f"chỉ đọc, mọi sửa đổi đi qua file gốc")
    if dropped:
        names = [meta.header[i] or f"<cột {i}>" for i in sorted(dropped)]
        L.append(f"**Đã bỏ {len(dropped)} cột khỏi lát cắt:** {', '.join(names)}")
    if not with_sql:
        L.append("**Lưu ý:** lát cắt này KHÔNG có cột SQL. LLD Phase 2 (Detail Mapping) phải "
                 "chạy lại với `--with-sql` để bóc 4 thành phần theo Quy tắc L17.")
    for w in meta.warnings:
        L.append(f"> ⚠️ {w}")
    L.append("")
    L.append("---")
    L.append("")

    for r in its:
        L.append(f"## [dòng {r.line_num}] {r.name}")
        for i in keep:
            v = r.raw_row[i].strip() if i < len(r.raw_row) else ""
            if not v:
                continue
            h = meta.header[i].strip() or f"<cột {i}>"
            if h.lower() == (prof.get("name_column") or "").strip().lower():
                continue  # đã là tiêu đề
            if "\n" in v:
                L.append(f"- **{h}:**")
                L.extend("  " + ln for ln in v.split("\n"))
            else:
                L.append(f"- **{h}:** {v}")
        L.append("")

    return "\n".join(L)


def main() -> None:
    ap = argparse.ArgumentParser(
        description="Cắt file BA thành lát cắt theo Nhóm (không sửa file gốc)")
    ap.add_argument("-m", "--module", required=True, help="Tên phân hệ, hoặc ALL (chỉ với --index)")
    ap.add_argument("--index", action="store_true", help="Sinh bản đồ Nhóm của phân hệ")
    ap.add_argument("--nhom", help="Số Nhóm cần cắt")
    ap.add_argument("--with-sql", action="store_true", help="Kèm cột SQL (LLD Phase 2)")
    ap.add_argument("--print", dest="do_print", action="store_true",
                    help="In lát cắt ra stdout thay vì chỉ ghi file")
    ap.add_argument("--root", default=None)
    args = ap.parse_args()

    root = find_project_root(args.root) if args.root else find_project_root()

    if not args.index and not args.nhom:
        ap.error("cần --index hoặc --nhom N")

    try:
        if args.index:
            mods = list_ba_modules(root) if args.module.upper() == "ALL" else [args.module]
            for mod in mods:
                out = build_index(root, mod)
                n = len(out.read_text(encoding="utf-8-sig").splitlines()) - 1
                print(f"✅ {out.relative_to(root).as_posix()} — {n} Nhóm "
                      f"(~{_tok(out.stat().st_size)} token)")
            if not args.nhom:
                return

        if args.nhom:
            if args.module.upper() == "ALL":
                raise SystemExit("--nhom không dùng được với ALL")
            body = render_group(root, args.module, args.nhom, args.with_sql)
            suffix = "_sql" if args.with_sql else ""
            out = root / CTX_REL / _mod_dir(args.module) / f"nhom_{args.nhom}{suffix}.md"
            out.parent.mkdir(parents=True, exist_ok=True)
            out.write_text(body, encoding="utf-8", newline="\n")
            if args.do_print:
                print(body)
            else:
                print(f"✅ {out.relative_to(root).as_posix()} — ~{_tok(len(body))} token")
    except (BaProfileMismatch, FileNotFoundError, KeyError) as exc:
        print(f"❌ {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
