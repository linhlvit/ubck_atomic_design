# -*- coding: utf-8 -*-
"""
lld_selfcheck.py — TC4, TC5, TC6, TC7 của `datamart-lld-design` chạy bằng script.

VÌ SAO
    Bốn test case này là kiểm tra MODULE-LEVEL: chúng cần đọc TOÀN BỘ Detail Mapping và
    HLD. SKILL.md hiện bắt agent tự `list(csv.reader(...))` cả file ở 4 chỗ (dòng 900-918,
    1272, 1297, 1309). Với QLKD đó là 4 × 552K token — không trần ngữ cảnh nào chứa nổi.
    Chúng thuần cơ học nên thuộc về script; agent chỉ đọc báo cáo.

PHẠM VI
    TC4 — (mart_table, mart_column) trong Detail Mapping phải tồn tại trong datamart_model.yaml.
          Chấp nhận CẢ tên logical LẪN physical: thực tế repo ghi mart_table logical
          ("Calendar Date Dimension") nhưng mart_column physical ("cdr_dt").
    TC5 — tập Nhóm và tập KPI_ID của HLD Section 2 phải phủ hết trong Detail Mapping.
    TC6 — thứ tự nhóm-xuất-hiện-lần-đầu trong Detail Mapping phải tăng dần theo SỐ nhóm
          (so số, không so chuỗi: "Nhóm 11" < "Nhóm 2" theo chuỗi là SAI).
    TC7 — tên bảng/cột đồng nhất giữa 5 nguồn, anchor là `datamart_attributes.csv`.
          KHÔNG quét `HLD.md` — free-text + mermaid, regex bắt token dễ false positive
          (theo đúng ghi chú tại SKILL.md dòng 856).

DÙNG
    python lld_selfcheck.py -m PTTT
    python lld_selfcheck.py -m PTTT --tc 4,5
    python lld_selfcheck.py -m ALL --strict
    python lld_selfcheck.py -m PTTT --fix-order      # chỉ TC6: sắp lại thứ tự nhóm
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Set, Tuple

_script_dir = Path(__file__).resolve().parent
if str(_script_dir) not in sys.path:
    sys.path.insert(0, str(_script_dir))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

csv.field_size_limit(10_000_000)

from datamart_common import find_project_root, get_available_modules, resolve_module_path  # noqa: E402
from datamart_common.csv_io import DesignCsv, read_design_csv, write_design_csv  # noqa: E402
from datamart_common.module_resolver import normalize_module_name, resolve_entities_csv, strip_accents  # noqa: E402

MODEL_REL = "Datamart/datamart_model.yaml"
MASTER_REL = "Datamart/lld/datamart_attributes.csv"

# Dòng có role thuộc nhóm này được phép để trống mart_table/mart_column (Quy tắc L4).
_EXEMPT_ROLES = ("DERIVED", "PENDING", "DEPRECATED")
_RE_NHOM_NUM = re.compile(r"(?:Nhóm|Nhom|Group)\s*(\d+)", re.IGNORECASE)
_RE_KPI = re.compile(r"\b(K_[A-ZĐ]+_\d+)\b")


@dataclass
class TcResult:
    tc: str
    name: str
    passed: bool
    summary: str
    details: List[str] = field(default_factory=list)
    skipped: bool = False
    warnings: List[str] = field(default_factory=list)


# ---------------------------------------------------------------------------
# Nạp dữ liệu dùng chung
# ---------------------------------------------------------------------------
def _index(triples) -> Tuple[Dict[str, str], Dict[Tuple[str, str], str]]:
    """Dựng chỉ mục chấp nhận CẢ tên logical LẪN tên physical.

    Detail Mapping thực tế trong repo ghi `mart_table` bằng tên logical ("Calendar Date
    Dimension") nhưng `mart_column` bằng tên physical ("cdr_dt") — khác với mô tả trong
    SKILL.md (cho rằng cả hai đều logical). Nếu chỉ so theo logical thì mọi dòng như vậy
    đều thành false positive. Nên chỉ mục nhận cả hai cách viết cho cả bảng lẫn cột.

    triples: iterable of (entity_logical, table_physical, col_logical, col_physical);
    col_* có thể None khi chỉ khai báo entity.
    """
    table_of: Dict[str, str] = {}
    col_of: Dict[Tuple[str, str], str] = {}
    for ln, tbl, cl, cp in triples:
        for ek in (ln, tbl):
            if ek:
                table_of.setdefault(ek, tbl or ln)
        for ek in (ln, tbl):
            if not ek:
                continue
            for ck in (cl, cp):
                if ck:
                    col_of.setdefault((ek, ck), cp or cl)
    return table_of, col_of


def load_model(root: Path) -> Tuple[Dict[str, str], Dict[Tuple[str, str], str]]:
    """datamart_model.yaml -> (tên bảng bất kỳ -> physical, (bảng, cột bất kỳ) -> physical)."""
    import yaml
    p = root / MODEL_REL
    if not p.is_file():
        return {}, {}
    d = yaml.safe_load(p.read_text(encoding="utf-8")) or {}
    tri = []
    for e in (d.get("entities") or []):
        ln = (e.get("logical_name") or "").strip()
        tbl = (e.get("datamart_table") or "").strip()
        if not ln and not tbl:
            continue
        cs = e.get("columns") or []
        if not cs:
            tri.append((ln, tbl, None, None))
        for c in cs:
            tri.append((ln, tbl, (c.get("logical_name") or "").strip(),
                        (c.get("physical_name") or "").strip()))
    return _index(tri)


def load_master(root: Path) -> Tuple[Dict[str, str], Dict[Tuple[str, str], str]]:
    """Anchor set từ datamart_attributes.csv -> (entity->table, (entity,attr)->column)."""
    p = root / MASTER_REL
    if not p.is_file():
        return {}, {}
    t = read_design_csv(p, strict=False)
    ix = t.ix
    need = ("datamart_entity", "datamart_table", "datamart_attribute", "datamart_column")
    if any(k not in ix for k in need):
        return {}, {}
    return _index((r[ix["datamart_entity"]].strip(), r[ix["datamart_table"]].strip(),
                   r[ix["datamart_attribute"]].strip(), r[ix["datamart_column"]].strip())
                  for r in t.rows)


def _resolve_cols(cols: Dict[Tuple[str, str], str], table: str, spec: str) -> Tuple[List[str], List[str]]:
    """Giải mã ô `mart_column` -> (các cột resolve được, các cột không thấy).

    Ô này có thể chứa NHIỀU cột phân tách bằng ' / ' (VD "Business Line Level 1 Code /
    Classification Business Line Name"), nhưng '/' cũng có thể là một phần tên cột thật
    (VD "EBIT / Lãi vay"). Vì vậy: khớp NGUYÊN chuỗi trước, chỉ tách khi khớp nguyên thất bại
    — cùng quy tắc đã áp dụng ở datamart_common/reference_checker.py.
    """
    spec = spec.strip()
    if (table, spec) in cols:
        return [cols[(table, spec)]], []
    if "/" not in spec:
        return [], [spec]
    ok, bad = [], []
    for part in (x.strip() for x in spec.split("/")):
        if not part:
            continue
        if (table, part) in cols:
            ok.append(cols[(table, part)])
        else:
            bad.append(part)
    return ok, bad


def load_dm(root: Path, module: str) -> Optional[DesignCsv]:
    p = resolve_module_path(root, module, "detail_mapping")
    return read_design_csv(Path(p), strict=False) if p and Path(p).is_file() else None


def hld_groups_and_kpis(root: Path, module: str) -> Tuple[Set[int], Set[str]]:
    """Tập số Nhóm và tập KPI_ID khai sinh trong HLD Section 2."""
    p = resolve_module_path(root, module, "hld")
    if not p or not Path(p).is_file():
        return set(), set()
    groups, kpis = set(), set()
    in_s2 = False
    for line in Path(p).read_text(encoding="utf-8").split("\n"):
        if line.startswith("## "):
            in_s2 = bool(re.match(r"^##\s+Section\s+2\b", line, re.IGNORECASE))
        if not in_s2:
            continue
        if line.startswith("#### "):
            m = _RE_NHOM_NUM.search(line)
            if m:
                groups.add(int(m.group(1)))
        if line.lstrip().startswith("|"):
            kpis.update(_RE_KPI.findall(line))
    return groups, kpis


# ---------------------------------------------------------------------------
# TC4
# ---------------------------------------------------------------------------
def tc4(root: Path, module: str, dm: Optional[DesignCsv]) -> TcResult:
    name = "Trường/bảng Detail Mapping tồn tại trong datamart_model.yaml"
    if dm is None:
        return TcResult("TC4", name, True, "bỏ qua — không có Detail Mapping", skipped=True)
    ents, cols = load_model(root)
    if not ents:
        return TcResult("TC4", name, True, f"bỏ qua — không đọc được {MODEL_REL}", skipped=True)
    ix = dm.ix
    seen: Set[Tuple[str, str]] = set()
    bad: List[str] = []
    for n, r in enumerate(dm.rows, start=2):
        role = r[ix["column_role"]].strip().upper() if "column_role" in ix else ""
        mt = r[ix["mart_table"]].strip() if "mart_table" in ix else ""
        mc = r[ix["mart_column"]].strip() if "mart_column" in ix else ""
        if role in _EXEMPT_ROLES or not mt or not mc:
            continue
        if (mt, mc) in seen:
            continue
        seen.add((mt, mc))
        if mt not in ents:
            bad.append(f"dòng {n}: entity `{mt}` không có logical_name trong model")
        else:
            _, miss = _resolve_cols(cols, mt, mc)
            if miss:
                bad.append(f"dòng {n}: `{mt}`.`{'` , `'.join(miss)}` — entity có nhưng thiếu cột")
    ok = not bad
    return TcResult("TC4", name, ok,
                    f"{len(seen)} cặp (mart_table, mart_column) unique — "
                    + ("khớp hết model" if ok else f"{len(bad)} cặp KHÔNG có trong model"),
                    bad)


# ---------------------------------------------------------------------------
# TC5
# ---------------------------------------------------------------------------
def tc5(root: Path, module: str, dm: Optional[DesignCsv]) -> TcResult:
    name = "Đối chiếu tập Nhóm và tập KPI_ID: HLD Section 2 ↔ Detail Mapping"
    if dm is None:
        return TcResult("TC5", name, True, "bỏ qua — không có Detail Mapping", skipped=True)
    h_groups, h_kpis = hld_groups_and_kpis(root, module)
    if not h_groups and not h_kpis:
        return TcResult("TC5", name, True, "bỏ qua — không đọc được HLD Section 2", skipped=True)
    ix = dm.ix
    d_groups, d_kpis = set(), set()
    for r in dm.rows:
        if "nhom" in ix and (m := _RE_NHOM_NUM.search(r[ix["nhom"]])):
            d_groups.add(int(m.group(1)))
        if "kpi_id" in ix and r[ix["kpi_id"]].strip():
            d_kpis.add(r[ix["kpi_id"]].strip())
    miss_g = sorted(h_groups - d_groups)
    miss_k = sorted(h_kpis - d_kpis, key=lambda k: (len(k), k))
    ok = not miss_g and not miss_k
    det = []
    if miss_g:
        det.append(f"Nhóm có trong HLD nhưng THIẾU trong Detail Mapping: "
                   + ", ".join(map(str, miss_g)))
    if miss_k:
        det.append(f"KPI_ID có trong HLD nhưng THIẾU trong Detail Mapping ({len(miss_k)}): "
                   + ", ".join(miss_k[:40]) + (" …" if len(miss_k) > 40 else ""))
    return TcResult("TC5", name, ok,
                    f"HLD {len(h_groups)} nhóm / {len(h_kpis)} KPI_ID — "
                    f"DM {len(d_groups)} nhóm / {len(d_kpis)} KPI_ID"
                    + ("" if ok else f" — thiếu {len(miss_g)} nhóm, {len(miss_k)} KPI_ID"),
                    det)


# ---------------------------------------------------------------------------
# TC6
# ---------------------------------------------------------------------------
def tc6(root: Path, module: str, dm: Optional[DesignCsv],
        fix: bool = False, dm_path: Optional[Path] = None) -> TcResult:
    name = "Thứ tự nhóm trong Detail Mapping tăng dần theo SỐ nhóm"
    if dm is None:
        return TcResult("TC6", name, True, "bỏ qua — không có Detail Mapping", skipped=True)
    ix = dm.ix
    if "nhom" not in ix:
        return TcResult("TC6", name, True, "bỏ qua — không có cột `nhom`", skipped=True)
    j = ix["nhom"]
    first: List[Tuple[int, int]] = []          # (số nhóm, dòng xuất hiện lần đầu)
    seen: Set[int] = set()
    for n, r in enumerate(dm.rows, start=2):
        m = _RE_NHOM_NUM.search(r[j]) if j < len(r) else None
        if not m:
            continue
        num = int(m.group(1))
        if num not in seen:
            seen.add(num)
            first.append((num, n))
    bad = [f"Nhóm {a} (dòng {la}) đứng TRƯỚC Nhóm {b} (dòng {lb}) dù {a} > {b}"
           for (a, la), (b, lb) in zip(first, first[1:]) if a > b]
    ok = not bad

    if not ok and fix and dm_path is not None:
        order = {num: k for k, (num, _) in enumerate(sorted(first))}
        def key(r: List[str]) -> Tuple[int, int]:
            m = _RE_NHOM_NUM.search(r[j]) if j < len(r) else None
            return (order.get(int(m.group(1)), 10 ** 6), 0) if m else (10 ** 6, 1)
        rows = sorted(dm.rows, key=key)   # sorted() ổn định -> giữ thứ tự trong cùng nhóm
        write_design_csv(dm_path, DesignCsv(header=dm.header, rows=rows, quote_all=dm.quote_all),
                         quote_all=dm.quote_all)
        bad.append(f"→ ĐÃ sắp lại {len(rows)} dòng theo thứ tự nhóm tăng dần "
                   f"(giữ nguyên nội dung và thứ tự trong từng nhóm): {dm_path.name}")

    return TcResult("TC6", name, ok,
                    f"{len(first)} nhóm xuất hiện lần đầu — "
                    + ("thứ tự đúng 1→N_max" if ok else f"{len(bad)} cặp sai thứ tự"),
                    bad)


# ---------------------------------------------------------------------------
# TC7
# ---------------------------------------------------------------------------
def tc7(root: Path, module: str, dm: Optional[DesignCsv]) -> TcResult:
    name = "Tên bảng/cột đồng nhất giữa các nguồn (anchor: datamart_attributes.csv)"
    ents, cols = load_master(root)
    if not ents:
        return TcResult("TC7", name, True, f"bỏ qua — không đọc được {MASTER_REL}", skipped=True)
    fails: List[str] = []
    warns: List[str] = []
    n_src = 0

    # Nguồn 2 — file Attributes per-table của module
    mod_dir = root / "Datamart" / "lld" / strip_accents(normalize_module_name(module)).upper()
    if not mod_dir.is_dir():
        mod_dir = root / "Datamart" / "lld" / normalize_module_name(module)
    if mod_dir.is_dir():
        n_src += 1
        for f in sorted(mod_dir.glob(f"DTM_*.csv")):
            t = read_design_csv(f, strict=False)
            ix = t.ix
            if not all(k in ix for k in ("datamart_entity", "datamart_table",
                                         "datamart_attribute", "datamart_column")):
                continue
            for n, r in enumerate(t.rows, start=2):
                ent, tbl = r[ix["datamart_entity"]].strip(), r[ix["datamart_table"]].strip()
                at, cl = r[ix["datamart_attribute"]].strip(), r[ix["datamart_column"]].strip()
                if ent and tbl and ents.get(ent) not in (None, tbl):
                    fails.append(f"[module_file:entity] {f.name}:{n} `{ent}` → `{tbl}` "
                                 f"nhưng master ghi `{ents[ent]}`")
                if ent and at and cl and cols.get((ent, at)) not in (None, cl):
                    fails.append(f"[module_file:column] {f.name}:{n} `{ent}`.`{at}` → `{cl}` "
                                 f"nhưng master ghi `{cols[(ent, at)]}`")

    # Nguồn 3 — datamart_model.yaml
    m_ents, m_cols = load_model(root)
    if m_ents:
        n_src += 1
        for ln, tbl in m_ents.items():
            if ln in ents and tbl and ents[ln] != tbl:
                fails.append(f"[model:entity] `{ln}` → `{tbl}` nhưng master ghi `{ents[ln]}`")
        for (ln, cl), phys in m_cols.items():
            if (ln, cl) in cols and phys and cols[(ln, cl)] != phys:
                fails.append(f"[model:column] `{ln}`.`{cl}` → `{phys}` "
                             f"nhưng master ghi `{cols[(ln, cl)]}`")

    # Nguồn 4 — Detail Mapping
    if dm is not None:
        n_src += 1
        ix = dm.ix
        for n, r in enumerate(dm.rows, start=2):
            role = r[ix["column_role"]].strip().upper() if "column_role" in ix else ""
            mt = r[ix["mart_table"]].strip() if "mart_table" in ix else ""
            mc = r[ix["mart_column"]].strip() if "mart_column" in ix else ""
            logic = r[ix["logic"]] if "logic" in ix else ""
            kpi = r[ix["kpi_id"]].strip() if "kpi_id" in ix else f"dòng {n}"
            if role in _EXEMPT_ROLES or not mt or not mc:
                continue
            if mt not in ents:
                fails.append(f"[detail_mapping:entity_not_found] {kpi} — `{mt}`")
                continue
            exp_list, miss = _resolve_cols(cols, mt, mc)
            if miss:
                fails.append(f"[detail_mapping:column_not_found] {kpi} — `{mt}`.`{'` , `'.join(miss)}`")
                continue
            # ô đa giá trị: chỉ cần logic tham chiếu MỘT trong các cột là đủ
            ref = f"{ents[mt]}.{exp_list[0]}"
            if not any(f"{ents[mt]}.{e}" in logic for e in exp_list):
                # KHÔNG phải lỗi cứng. Cột tính toán (LAG/SUM/CASE/biểu thức) tham chiếu cột
                # NGUỒN chứ không tham chiếu chính nó; pattern filter theo rule L11 cũng không
                # kèm prefix bảng. SKILL.md yêu cầu xác nhận từng trường hợp, không sửa hàng
                # loạt -> xếp vào cảnh báo để không che mất lỗi cứng thật sự.
                warns.append(f"[detail_mapping:logic_missing_ref] {kpi} — `{mt}`.`{mc}` "
                             f"không thấy `{ref}` trong cột logic")

    # Nguồn 5 — Entities.csv
    ent_csv = resolve_entities_csv(root, module)
    if ent_csv and Path(ent_csv).is_file():
        n_src += 1
        t = read_design_csv(Path(ent_csv), strict=False)
        if "datamart_entity" in t.ix:
            j = t.ix["datamart_entity"]
            for n, r in enumerate(t.rows, start=2):
                v = r[j].strip() if j < len(r) else ""
                if v and v not in ents:
                    fails.append(f"[entities_csv:not_in_anchor] dòng {n} — `{v}`")

    fails = sorted(dict.fromkeys(fails))
    warns = sorted(dict.fromkeys(warns))
    ok = not fails
    det = fails[:60] + ([f"… và {len(fails) - 60} lỗi nữa"] if len(fails) > 60 else [])
    wdet = warns[:30] + ([f"… và {len(warns) - 30} cảnh báo nữa"] if len(warns) > 30 else [])
    if warns:
        wdet.append("ⓘ `logic_missing_ref` thường là false positive hợp lệ: cột tính toán "
                    "(LAG/SUM/CASE) tham chiếu cột NGUỒN chứ không tham chiếu chính nó, và "
                    "pattern filter theo rule L11 không kèm prefix bảng. Xác nhận từng trường "
                    "hợp, KHÔNG sửa hàng loạt.")
    s = f"đối chiếu {n_src} nguồn với anchor ({len(ents)} entity / {len(cols)} khoá cột) — "
    s += "đồng nhất" if ok else f"{len(fails)} lỗi"
    if warns:
        s += f", {len(warns)} cảnh báo"
    return TcResult("TC7", name, ok, s, det, warnings=wdet)


# ---------------------------------------------------------------------------
def run_module(root: Path, module: str, which: Sequence[str], fix_order: bool) -> List[TcResult]:
    dm_p = resolve_module_path(root, module, "detail_mapping")
    dm = load_dm(root, module)
    out: List[TcResult] = []
    if "4" in which:
        out.append(tc4(root, module, dm))
    if "5" in which:
        out.append(tc5(root, module, dm))
    if "6" in which:
        out.append(tc6(root, module, dm, fix_order, Path(dm_p) if dm_p else None))
    if "7" in which:
        out.append(tc7(root, module, dm))
    return out


def render(module: str, res: Sequence[TcResult]) -> str:
    L = ["=" * 70, f" LLD Self-Check (module-level): {module}", "=" * 70]
    for r in res:
        icon = "⏭️ " if r.skipped else ("✅" if r.passed else "❌")
        L.append(f"  {icon} {r.tc} — {r.name}")
        L.append(f"       {r.summary}")
        for d in r.details:
            L.append(f"       · {d}")
        for w in r.warnings:
            L.append(f"       ⚠ {w}")
    hard = [r for r in res if not r.passed and not r.skipped]
    L.append("-" * 70)
    L.append(f"  Kết luận: {'✅ PASS' if not hard else '❌ FAIL (' + ', '.join(r.tc for r in hard) + ')'}")
    return "\n".join(L)


def main() -> None:
    ap = argparse.ArgumentParser(description="TC4–TC7 module-level cho LLD Detail Mapping")
    ap.add_argument("-m", "--module", required=True, help="Tên phân hệ hoặc ALL")
    ap.add_argument("--tc", default="4,5,6,7", help="Danh sách TC cần chạy (mặc định 4,5,6,7)")
    ap.add_argument("--fix-order", action="store_true",
                    help="TC6: sắp lại thứ tự nhóm trong Detail Mapping (GHI ĐÈ file gốc)")
    ap.add_argument("--strict", action="store_true")
    ap.add_argument("--json", dest="as_json", action="store_true")
    ap.add_argument("--root", default=None)
    args = ap.parse_args()

    root = find_project_root(args.root) if args.root else find_project_root()
    which = [x.strip() for x in args.tc.split(",") if x.strip()]
    mods = get_available_modules(root) if args.module.upper() == "ALL" else [args.module]

    failed = False
    payload = {}
    for mod in mods:
        res = run_module(root, mod, which, args.fix_order)
        if any(not r.passed and not r.skipped for r in res):
            failed = True
        if args.as_json:
            payload[mod] = [{"tc": r.tc, "passed": r.passed, "skipped": r.skipped,
                             "summary": r.summary, "details": r.details,
                             "warnings": r.warnings} for r in res]
        else:
            print(render(mod, res))
            print()
    if args.as_json:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
