# -*- coding: utf-8 -*-
"""
ctx_budget.py — Gate 6: ước lượng ngữ cảnh một bước thiết kế có vượt trần hay không.

VÌ SAO
    Trần ngữ cảnh là 500.000 token input. Bốn phân hệ (QLKD, GSĐC, TKNB, GSTT) vượt trần
    nếu nạp artifact nguyên khối. Gate này tính trước, theo đúng danh sách file mà từng
    bước thực sự đọc, để biết ngay bước nào sắp tràn thay vì phát hiện lúc đang chạy.

    Gate này cũng là gate đầu tiên đọc tới file BA — Gate 0–5 không gate nào đọc.

DÙNG
    python ctx_budget.py -m QLKD --step lld-phase2 --nhom 48
    python ctx_budget.py -m QLKD --all-steps
    python ctx_budget.py -m QLKD --worst              # Nhóm nặng nhất của mỗi bước
    python ctx_budget.py -m ALL  --worst --strict     # dùng trong run_quality_gates
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

_script_dir = Path(__file__).resolve().parent
if str(_script_dir) not in sys.path:
    sys.path.insert(0, str(_script_dir))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from datamart_common import find_project_root, get_available_modules, resolve_module_path  # noqa: E402
from datamart_common.ba_parser import (drop_column_indices, group_ba_items, list_ba_modules,  # noqa: E402
                                       parse_ba_file, profile_for, resolve_ba_path)
from datamart_common.module_resolver import (normalize_module_name, resolve_entities_csv,  # noqa: E402
                                             strip_accents)

TOK = 3.3
DEFAULT_LIMIT = 500_000
SKILLS = Path(".claude/skills")

STEPS = ["hld-phase1", "hld-phase2", "lld-phase1", "lld-phase2", "lld-phase3", "review"]


def _tok_file(p: Optional[Path]) -> int:
    try:
        return int(round(p.stat().st_size / TOK)) if p and Path(p).is_file() else 0
    except OSError:
        return 0


def _tok_dir(p: Path, pattern: str = "*") -> int:
    return sum(_tok_file(f) for f in p.glob(pattern)) if p.is_dir() else 0


def _mod_dir(module: str) -> str:
    return strip_accents(normalize_module_name(module)).upper()


def ba_group_tokens(root: Path, module: str, nhom: Optional[str],
                    with_sql: bool) -> Tuple[int, Optional[str]]:
    """Token lát cắt BA của một Nhóm; nhom=None -> Nhóm nặng nhất. -> (token, tên nhóm)."""
    p = resolve_ba_path(root, module)
    if not p:
        return 0, None
    prof = profile_for(root, module)
    items, meta = parse_ba_file(p, prof)
    groups = group_ba_items(items)
    keep = [i for i in range(len(meta.header))
            if i not in drop_column_indices(meta.header, prof, with_sql=with_sql)]

    def size(its) -> int:
        # xấp xỉ nội dung lát cắt: ô dữ liệu + nhãn "- **Tên cột:** " mỗi ô
        return int(round(sum(len(r.raw_row[i]) + len(meta.header[i]) + 10
                             for r in its for i in keep if i < len(r.raw_row)) / TOK))

    if nhom is not None:
        return (size(groups[nhom]), nhom) if nhom in groups else (0, None)
    if not groups:
        return 0, None
    k = max(groups, key=lambda g: size(groups[g]))
    return size(groups[k]), k


def hld_group_tokens(root: Path, module: str, nhom: Optional[str]) -> int:
    """Token khối `#### Nhóm N` trong HLD; nhom=None -> khối lớn nhất."""
    import re
    p = resolve_module_path(root, module, "hld")
    if not p:
        return 0
    lines = Path(p).read_text(encoding="utf-8").split("\n")
    starts = [i for i, l in enumerate(lines) if l.startswith("#### ")]
    if not starts:
        return 0
    bounds = []
    for k, i in enumerate(starts):
        end = starts[k + 1] if k + 1 < len(starts) else len(lines)
        for j in range(i + 1, end):
            if lines[j].startswith("### ") or lines[j].startswith("## "):
                end = j
                break
        bounds.append((lines[i], i, end))
    if nhom is not None:
        pat = re.compile(rf"^####\s*(?:Nhóm|Nhom|Group)\s*0*{re.escape(nhom)}\b", re.IGNORECASE)
        sel = [b for b in bounds if pat.match(b[0])]
        if not sel:
            return 0
        _, i, e = sel[0]
        return int(round(sum(len(x) + 1 for x in lines[i:e]) / TOK))
    return max(int(round(sum(len(x) + 1 for x in lines[i:e]) / TOK)) for _, i, e in bounds)


def hld_sections_tokens(root: Path, module: str, skip_section_2: bool = True) -> int:
    import re
    p = resolve_module_path(root, module, "hld")
    if not p:
        return 0
    lines = Path(p).read_text(encoding="utf-8").split("\n")
    marks = [(i, int(m.group(1))) for i, l in enumerate(lines)
             if (m := re.match(r"^##\s+Section\s+(\d+)\b", l, re.IGNORECASE))]
    total = 0
    for k, (i, num) in enumerate(marks):
        end = marks[k + 1][0] if k + 1 < len(marks) else len(lines)
        if skip_section_2 and num == 2:
            continue
        total += int(round(sum(len(x) + 1 for x in lines[i:end]) / TOK))
    return total


def dm_group_tokens(root: Path, module: str, nhom: Optional[str]) -> int:
    import re
    p = resolve_module_path(root, module, "detail_mapping")
    if not p:
        return 0
    from datamart_common.csv_io import read_design_csv
    t = read_design_csv(Path(p), strict=False)
    if "nhom" not in t.ix:
        return 0
    j = t.ix["nhom"]
    buckets: Dict[str, int] = {}
    for r in t.rows:
        m = re.search(r"(?:Nhóm|Nhom|Group)\s*(\d+)", r[j], re.IGNORECASE) if j < len(r) else None
        if not m:
            continue
        buckets[m.group(1)] = buckets.get(m.group(1), 0) + sum(len(c) + 3 for c in r)
    if not buckets:
        return 0
    n = int(round((buckets.get(nhom, 0) if nhom is not None else max(buckets.values())) / TOK))
    return n


# ---------------------------------------------------------------------------
def components(root: Path, module: str, step: str, nhom: Optional[str]) -> List[Tuple[str, int]]:
    hld_sk = root / SKILLS / "datamart-hld-design"
    lld_sk = root / SKILLS / "datamart-lld-design"
    rv_sk = root / SKILLS / "datamart-review"
    md = _mod_dir(module)
    lld_mod = root / "Datamart" / "lld" / md
    base = [("CLAUDE.md", _tok_file(root / "CLAUDE.md"))]

    if step == "hld-phase1":
        ba, _ = ba_group_tokens(root, module, nhom, with_sql=False)
        return base + [
            ("SKILL datamart-hld-design", _tok_file(hld_sk / "SKILL.md")),
            ("reference/ (hld)", _tok_dir(hld_sk / "reference", "*.md")),
            ("BA index (bản đồ Nhóm)", _tok_file(root / "Datamart/context/ba" / f"BA_index_{md}.csv")),
            ("BA lát cắt 1 Nhóm", ba),
            ("HLD Section 1+3+4+5", hld_sections_tokens(root, module)),
            ("HLD khối Nhóm", hld_group_tokens(root, module, nhom)),
        ]
    if step == "hld-phase2":
        return base + [
            ("SKILL datamart-hld-design", _tok_file(hld_sk / "SKILL.md")),
            ("reference/phase2_entities.md", _tok_file(hld_sk / "reference/phase2_entities.md")),
            ("HLD Section 1+3+4+5", hld_sections_tokens(root, module)),
            ("Entities.csv", _tok_file(Path(resolve_entities_csv(root, module))
                                       if resolve_entities_csv(root, module) else None)),
        ]
    if step == "lld-phase1":
        return base + [
            ("SKILL datamart-lld-design", _tok_file(lld_sk / "SKILL.md")),
            ("reference/phase1_attributes.md", _tok_file(lld_sk / "reference/phase1_attributes.md")),
            ("HLD khối Nhóm", hld_group_tokens(root, module, nhom)),
            ("Entities.csv", _tok_file(Path(resolve_entities_csv(root, module))
                                       if resolve_entities_csv(root, module) else None)),
            ("Attributes per-table của module", _tok_dir(lld_mod, "DTM_*.csv")),
        ]
    if step == "lld-phase2":
        ba, _ = ba_group_tokens(root, module, nhom, with_sql=True)
        return base + [
            ("SKILL datamart-lld-design", _tok_file(lld_sk / "SKILL.md")),
            ("reference/phase2_detail_mapping.md",
             _tok_file(lld_sk / "reference/phase2_detail_mapping.md")),
            ("BA lát cắt 1 Nhóm (kèm SQL)", ba),
            ("Detail Mapping lát cắt 1 Nhóm", dm_group_tokens(root, module, nhom)),
            ("Attributes per-table của module", _tok_dir(lld_mod, "DTM_*.csv")),
        ]
    if step == "lld-phase3":
        return base + [
            ("SKILL datamart-lld-design", _tok_file(lld_sk / "SKILL.md")),
            ("reference/phase3_flat_table.md", _tok_file(lld_sk / "reference/phase3_flat_table.md")),
            ("Attributes per-table của module", _tok_dir(lld_mod, "DTM_*.csv")),
        ]
    if step == "review":
        return base + [
            ("SKILL datamart-review", _tok_file(rv_sk / "SKILL.md")),
            ("reference/ (review)", _tok_dir(rv_sk / "reference", "*.md")),
            ("báo cáo gate (ước lượng)", 8000),
        ]
    raise SystemExit(f"Bước không hợp lệ: {step}. Hợp lệ: {', '.join(STEPS)}")


def render(module: str, step: str, nhom: Optional[str], comps: List[Tuple[str, int]],
           limit: int) -> Tuple[str, bool]:
    total = sum(v for _, v in comps)
    L = [f"  {step:<12} {'Nhóm ' + nhom if nhom else 'Nhóm nặng nhất':<16} "
         f"tổng {total:>8,} / {limit:,} token  "
         f"({'✅ còn ' + format(limit - total, ',') if total <= limit else '❌ VƯỢT ' + format(total - limit, ',')})"]
    for k, v in comps:
        if v:
            L.append(f"        {k:<38} {v:>8,}")
    return "\n".join(L), total <= limit


def main() -> None:
    ap = argparse.ArgumentParser(description="Gate 6 — ước lượng ngữ cảnh theo bước thiết kế")
    ap.add_argument("-m", "--module", required=True, help="Tên phân hệ hoặc ALL")
    ap.add_argument("--step", choices=STEPS, help="Bước cần ước lượng")
    ap.add_argument("--all-steps", action="store_true", help="Ước lượng cả 6 bước")
    ap.add_argument("--worst", action="store_true",
                    help="Dùng Nhóm nặng nhất thay vì một Nhóm cụ thể (mặc định khi thiếu --nhom)")
    ap.add_argument("--nhom", help="Số Nhóm cụ thể")
    ap.add_argument("--limit", type=int, default=DEFAULT_LIMIT)
    ap.add_argument("--strict", action="store_true")
    ap.add_argument("--json", dest="as_json", action="store_true")
    ap.add_argument("--root", default=None)
    args = ap.parse_args()

    root = find_project_root(args.root) if args.root else find_project_root()
    steps = STEPS if (args.all_steps or not args.step) else [args.step]
    if args.module.upper() == "ALL":
        mods = sorted(set(list_ba_modules(root)) | set(get_available_modules(root)))
    else:
        mods = [args.module]

    over = False
    payload: Dict[str, Dict[str, object]] = {}
    for mod in mods:
        if not args.as_json:
            print("=" * 78)
            print(f" Ngân sách ngữ cảnh: {mod}   (trần {args.limit:,} token)")
            print("=" * 78)
        for st in steps:
            comps = components(root, mod, st, args.nhom)
            body, ok = render(mod, st, args.nhom, comps, args.limit)
            over = over or not ok
            if args.as_json:
                payload.setdefault(mod, {})[st] = {
                    "total": sum(v for _, v in comps), "ok": ok,
                    "components": {k: v for k, v in comps},
                }
            else:
                print(body)
        if not args.as_json:
            print()
    if args.as_json:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    sys.exit(1 if (over and args.strict) else 0)


if __name__ == "__main__":
    main()
