# -*- coding: utf-8 -*-
"""
run_quality_gates.py — Unified Datamart Quality Gate Runner (Gate 0 → Gate 8)

Runs all quality gate checks sequentially and aggregates results.

Gates:
  Gate 0 (Reference Integrity): check_references.py --strict
  Gate 1 (Macro-Review Sanity): check_date_fk.py
  Gate 2 (Parity Check):       check_parity.py --strict
  Gate 3 (Orphan Check):       check_orphan.py --strict
  Gate 4 (Flat Table):         check_flat_table.py --strict
  Gate 5 (HLD Structure 5B):   check_hld_5b.py --strict
  Gate 6 (Context Budget):     ctx_budget.py --all-steps --strict
  Gate 7 (LLD Self-Check):     lld_selfcheck.py
  Gate 8 (Design Lint):        check_design_lint.py --strict  [MỚI 2026-09-25]
  Gate 9 (Derived Freshness):  build_flat_tables.py -m M --check (FAIL) +
                               build_registry/build_kpi_index/build_model_yaml --check (WARN — toàn cục)
                               [MỚI 2026-10-15] — chỉ ĐỌC, không bao giờ tự sinh lại file.
  Gate 10 (BA ↔ HLD theo Nhóm): chỉ chạy khi có --nhom N…: ba_hld_sync_check.py --nhom +
                               dòng delta của đúng Nhóm đó từ datamart_progress_analyzer.py
                               (in nguyên dòng, không cắt tail/head). WARN, không FAIL — delta có
                               thể đã giải trình trong Ghi chú HLD; người chạy phải đọc từng dòng.

Exit Code:
  0 on PASS (all gates pass or skip)
  1 on FAIL (any active gate fails; under --strict also fails on warnings)

Usage:
    python scripts/run_quality_gates.py -m GSTT
    python scripts/run_quality_gates.py -m Common
    python scripts/run_quality_gates.py -m ALL --strict
    python scripts/run_quality_gates.py -m GSTT --json
    python scripts/run_quality_gates.py -m GSTT --strict --nhom 28 29   # sau khi sửa Nhóm 28, 29
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

_script_dir = Path(__file__).resolve().parent
if str(_script_dir) not in sys.path:
    sys.path.insert(0, str(_script_dir))

# Windows UTF-8 stdout/stderr reconfiguration
if sys.platform.startswith("win"):
    if hasattr(sys.stdout, "reconfigure"):
        try:
            sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        except Exception:
            pass
    if hasattr(sys.stderr, "reconfigure"):
        try:
            sys.stderr.reconfigure(encoding="utf-8", errors="replace")
        except Exception:
            pass

from datamart_common import find_project_root, get_available_modules, resolve_module_path


GATE_SPECS = [
    {
        "gate": "Gate 0",
        "name": "Reference Integrity (Atomic/Mart column, CSV, HLD-LLD status)",
        "script": "check_references.py",
        "supports_strict": True,
        "supports_json": False,
    },
    {
        "gate": "Gate 1",
        "name": "Role-Playing Date FK Sanity",
        "script": "check_date_fk.py",
        "supports_strict": True,
        "supports_json": False,
    },
    {
        "gate": "Gate 2",
        "name": "Attribute & ETL Logic Parity",
        "script": "check_parity.py",
        "supports_strict": True,
        "supports_json": True,
    },
    {
        "gate": "Gate 3",
        "name": "3-Way Orphan Entity",
        "script": "check_orphan.py",
        "supports_strict": True,
        "supports_json": True,
    },
    {
        "gate": "Gate 4",
        "name": "Flat Table Delivery",
        "script": "check_flat_table.py",
        "supports_strict": True,
        "supports_json": True,
    },
    {
        "gate": "Gate 5",
        "name": "HLD Structure (Bước 5B — 14 mục)",
        "script": "check_hld_5b.py",
        "supports_strict": True,
        "supports_json": False,
    },
    {
        "gate": "Gate 6",
        "name": "Context Budget (trần 500K token/bước)",
        "script": "ctx_budget.py",
        "supports_strict": True,
        "supports_json": True,
    },
    {
        "gate": "Gate 7",
        "name": "LLD Self-Check module-level (TC4–TC7)",
        "script": "lld_selfcheck.py",
        "supports_strict": True,
        "supports_json": True,
    },
    {
        "gate": "Gate 8",
        "name": "Design Lint (KPI row cells, zero-usage table, flat comment param)",
        "script": "check_design_lint.py",
        "supports_strict": True,
        "supports_json": False,
    },
]

# NOTE: datamart_progress_analyzer.py (BA <-> HLD count reconciliation) is
# deliberately NOT wired in as a module-wide FAIL gate. Its exit code is 1 whenever
# ANY delta exists, including deltas that are legitimate and already explained
# in the HLD Ghi chú (derived/reuse KPIs, per-Nhom whitelisted exceptions).
# Since 2026-10-15 it IS wired in as Gate 10 (WARN) scoped to the Nhóm passed via
# --nhom: the runner extracts exactly those rows from the delta table and prints
# them in full, so the GSTT 2026-09-22 failure mode (`| tail -30` hid the 🔴 row)
# cannot recur when the runner is used.

_RE_DELTA_ROW = r"^\| Nhóm {n} \|"


def _run_capture(cmd: List[str], timeout: int = 180) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace", timeout=timeout)


_GLOBAL_FRESHNESS_CACHE: Dict[str, Any] = {}


def derived_freshness(module: str, root: Path) -> Dict[str, Any]:
    """Gate 9 — các file SINH RA còn khớp nguồn không. Chỉ chạy `--check`, không ghi.

    - FAIL: flat table của module thiếu khối SQL / thiếu cột (build_flat_tables --check, = A20).
    - WARN: master registry / kpi_index / datamart_model.yaml lệch (toàn cục, có thể do module khác).
      KHÔNG tự chạy build_* để "sửa" — build_registry từng xóa trọn 26 bảng có trong master nhưng
      mất file LLD per-module; nay đã có chốt chặn, nhưng quyết định khôi phục/bỏ bảng là của human.
    """
    base = {"gate": "Gate 9", "name": "Derived Freshness (flat / registry / kpi_index / model.yaml)"}
    out_lines: List[str] = []
    status = "PASS"
    msgs: List[str] = []

    if module.strip().upper() != "COMMON":
        r = _run_capture([sys.executable, str(_script_dir / "build_flat_tables.py"), "-m", module,
                          "--check", "--root", str(root)])
        out_lines.append("[flat] " + r.stdout.strip())
        if r.returncode != 0:
            status = "FAIL"
            msgs.append(f"flat table {module} thiếu khối/cột — chạy build_flat_tables.py -m {module} "
                        f"--sync-columns rồi --apply (A20)")

    if not _GLOBAL_FRESHNESS_CACHE:
        for script in ("build_registry.py", "build_kpi_index.py", "build_model_yaml.py"):
            r = _run_capture([sys.executable, str(_script_dir / script), "--check", "--root", str(root)])
            _GLOBAL_FRESHNESS_CACHE[script] = (r.returncode, r.stdout.strip())
    for script, (rc, text) in _GLOBAL_FRESHNESS_CACHE.items():
        first = text.splitlines()[0] if text else ""
        out_lines.append(f"[{script}] {text}")
        if rc != 0:
            if status == "PASS":
                status = "WARN"
            msgs.append(f"{script}: {first}")

    res = {**base, "status": status, "exit_code": 0 if status == "PASS" else 1,
           "output": "\n".join(out_lines)}
    if msgs:
        res["message"] = " | ".join(msgs)
    return res


def ba_hld_by_nhom(module: str, root: Path, nhoms: List[str]) -> Dict[str, Any]:
    """Gate 10 — BA ↔ HLD ↔ DM cho đúng các Nhóm vừa sửa (CLAUDE.md: 2 bước bắt buộc chạy riêng)."""
    import re
    base = {"gate": "Gate 10", "name": f"BA ↔ HLD ↔ DM theo Nhóm ({', '.join(nhoms)})"}
    lines: List[str] = []
    warn: List[str] = []

    r = _run_capture([sys.executable, str(_script_dir / "ba_hld_sync_check.py"), "-m", module, "--nhom", *nhoms])
    lines.append("── ba_hld_sync_check.py ──")
    lines.append(r.stdout.strip())
    if r.returncode != 0 or re.search(r"TỔNG: [1-9]\d* lỗi", r.stdout):
        warn.append("ba_hld_sync_check có lỗi — đọc mục S1–S5 ở output")

    r = _run_capture([sys.executable, str(_script_dir / "datamart_progress_analyzer.py"), "--module", module,
                      "--root", str(root)])
    lines.append("── datamart_progress_analyzer.py (đúng dòng các Nhóm yêu cầu, không cắt) ──")
    text = r.stdout.splitlines()
    hdr = next((l for l in text if l.startswith("| Nhóm | ")), None)
    if hdr:
        lines.append(hdr)
    for n in nhoms:
        rows = [l for l in text if re.match(_RE_DELTA_ROW.format(n=re.escape(n)), l)]
        if not rows:
            lines.append(f"| Nhóm {n} | (không có dòng trong bảng delta — kiểm tra số Nhóm / S3) |")
            warn.append(f"Nhóm {n} không có trong bảng delta")
        for row in rows:
            lines.append(row)
            if "🔴" in row or "🟡" in row:
                warn.append(f"Nhóm {n} lệch số lượng — xác nhận đã giải trình trong Ghi chú HLD")

    status = "WARN" if warn else "PASS"
    res = {**base, "status": status, "exit_code": 0 if status == "PASS" else 1, "output": "\n".join(lines)}
    if warn:
        res["message"] = " | ".join(warn)
    return res


def _git_lines(root: Path, rev: str, rel: str) -> int:
    try:
        out = subprocess.run(["git", "show", f"{rev}:{rel}"], cwd=root, capture_output=True, timeout=60)
        return out.stdout.count(b"\n") if out.returncode == 0 else -1
    except Exception:
        return -1


def preflight_integrity(module: str, root: Path) -> Dict[str, Any]:
    """Pre-flight S1 — Detail Mapping / HLD không bị cắt so với HEAD (cùng ngưỡng 80% với ba_hld_sync_check S1).

    Chạy ĐẦU TIÊN và tính vào kết quả tổng. Lý do: khi Detail Mapping/HLD mất cả Nhóm, Gate 0/1/2/3/5/6 vẫn
    PASS vì chúng chỉ đối chiếu các dòng CÒN LẠI với nhau (QLQ 2026-10-14: DM 2699→183 dòng, Gate 0/1/2/3/5/6 PASS;
    GSTT 2026-09-23: 577→101) — trước đây chỉ `ba_hld_sync_check.py` (không nằm trong runner) mới nhìn ra.

    LƯU Ý: không phân biệt được cắt CHỦ Ý với hư hỏng. QLQ 2026-10-14 là cắt chủ ý của user (bỏ Nhóm 29–91)
    nên Pre-flight FAIL là đúng cho tới khi human commit bản mới (HEAD đổi thì cờ tự hết). FAIL ⇒ đọc MEMORY.md,
    kiểm mtime, hỏi human — KHÔNG tự khôi phục.
    """
    base = {"gate": "Pre-flight", "name": "File Integrity S1 (Detail Mapping/HLD không bị cắt so với HEAD)"}
    if module.strip().upper() == "COMMON":
        return {**base, "status": "SKIP", "exit_code": 0, "message": "N/A — Common", "output": ""}
    problems: List[str] = []
    lines: List[str] = []
    for kind, label in (("detail_mapping", "Detail Mapping"), ("hld", "HLD")):
        p = resolve_module_path(root, module, kind)
        if not p:
            continue
        rel = Path(p).relative_to(root).as_posix()
        cur = Path(p).read_bytes().count(b"\n")
        head, prev = _git_lines(root, "HEAD", rel), _git_lines(root, "HEAD~1", rel)
        lines.append(f"{label}: working={cur} | HEAD={head} | HEAD~1={prev}")
        if head > 0 and cur < 0.8 * head:
            problems.append(f"{label} working ({cur}) < 80% HEAD ({head}) — nghi bị cắt/ghi đè. "
                            f"DỪNG, không ghi thêm; báo human rồi mới khôi phục (có thể phiên khác đang sửa)")
        elif head > 0 and prev > 0 and head < 0.8 * prev and cur < 0.8 * prev:
            problems.append(f"{label}: HEAD ({head}) < 80% HEAD~1 ({prev}) — commit gần nhất đã cắt file, "
                            f"khôi phục từ HEAD~1 trước")
    if problems:
        return {**base, "status": "FAIL", "exit_code": 1, "message": " | ".join(problems),
                "output": "\n".join(lines)}
    return {**base, "status": "PASS", "exit_code": 0, "output": "\n".join(lines)}


def run_gate(
    gate_spec: Dict[str, Any],
    module: str,
    root: Path,
    strict: bool = False,
    json_output: bool = False,
) -> Dict[str, Any]:
    """Run a single gate check script and capture result."""
    mod_clean = module.strip()
    
    # Common module is a shared ClickHouse flat dimension table (no LLD CSV files)
    # Handle Gates 2 and 3 gracefully by marking them as SKIP / N/A
    if mod_clean.upper() == "COMMON" and gate_spec["gate"] in ("Gate 2", "Gate 3"):
        return {
            "gate": gate_spec["gate"],
            "name": gate_spec["name"],
            "status": "SKIP",
            "exit_code": 0,
            "message": "N/A — Common is a shared ClickHouse flat dimension table (no LLD CSV module)",
            "output": "",
            "stderr": None,
        }

    script_path = _script_dir / gate_spec["script"]
    if not script_path.exists():
        return {
            "gate": gate_spec["gate"],
            "name": gate_spec["name"],
            "status": "SKIP",
            "exit_code": -1,
            "message": f"Script not found: {gate_spec['script']}",
            "output": "",
        }

    cmd = [sys.executable, str(script_path), "-m", mod_clean, "--root", str(root)]
    if strict and gate_spec.get("supports_strict"):
        cmd.append("--strict")
    if json_output and gate_spec.get("supports_json"):
        cmd.append("--json")

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            encoding="utf-8",
            errors="replace",
            timeout=120,
        )
        status = "PASS" if result.returncode == 0 else "FAIL"
        return {
            "gate": gate_spec["gate"],
            "name": gate_spec["name"],
            "status": status,
            "exit_code": result.returncode,
            "output": result.stdout.strip(),
            "stderr": result.stderr.strip() if result.stderr.strip() else None,
        }
    except subprocess.TimeoutExpired:
        return {
            "gate": gate_spec["gate"],
            "name": gate_spec["name"],
            "status": "TIMEOUT",
            "exit_code": -2,
            "message": "Script execution timed out (120s)",
            "output": "",
        }
    except Exception as e:
        return {
            "gate": gate_spec["gate"],
            "name": gate_spec["name"],
            "status": "ERROR",
            "exit_code": -3,
            "message": str(e),
            "output": "",
        }


def print_summary(results: List[Dict[str, Any]], module: str) -> None:
    """Print formatted console summary."""
    print(f"\n{'='*70}")
    print(f" Datamart Unified Quality Gate Report: {module}")
    print(f"{'='*70}")

    all_pass = True
    for r in results:
        icon = "✅" if r["status"] == "PASS" else "❌" if r["status"] == "FAIL" else "⏭️" if r["status"] == "SKIP" else "⚠️"
        status_disp = r["status"]
        if r["status"] == "SKIP" and r.get("message"):
            status_disp = f"SKIP ({r['message']})"
        print(f"  {icon} {r['gate']} — {r['name']}: {status_disp}")
        if r["status"] not in ("PASS", "SKIP", "WARN"):
            all_pass = False
        if r["status"] not in ("PASS", "SKIP") and r.get("message"):
            print(f"     ↳ {r['message']}")
        # Gate 10 phải in NGUYÊN chi tiết — đây là chỗ GSTT 2026-09-22 bị bỏ lỡ do chỉ xem `tail`.
        if r["gate"] == "Gate 10" and r.get("output"):
            for line in r["output"].splitlines():
                print(f"       {line}")

    print(f"\n{'─'*70}")
    overall = "✅ ALL GATES PASSED" if all_pass else "❌ ONE OR MORE GATES FAILED"
    print(f"  Overall: {overall}")
    print(f"{'='*70}\n")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Unified Datamart Quality Gate Runner (Pre-flight + Gate 0-10)",
    )
    parser.add_argument(
        "--nhom",
        nargs="+",
        default=None,
        help="Các Nhóm vừa sửa — bật Gate 10 (BA ↔ HLD ↔ DM theo Nhóm, in nguyên dòng delta)",
    )
    parser.add_argument(
        "--skip-freshness",
        action="store_true",
        help="Bỏ Gate 9 (Derived Freshness) — chỉ dùng khi chạy lặp nhiều lần trong 1 phiên",
    )
    parser.add_argument(
        "-m", "--module",
        required=True,
        help="Module code (e.g. GSTT, Common, all)",
    )
    parser.add_argument(
        "--root",
        default=None,
        help="Project root directory (auto-detected if omitted)",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Strict mode: pass --strict to gates and exit with code 1 on any failure or warning",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        dest="json_output",
        help="Output results as JSON",
    )
    args = parser.parse_args()

    root = find_project_root(args.root) if args.root else find_project_root()

    if args.module.strip().upper() == "ALL":
        modules = get_available_modules(root)
    else:
        modules = [args.module.strip()]

    all_results: Dict[str, List[Dict[str, Any]]] = {}
    has_fail = False
    has_warning = False

    for mod in modules:
        mod_results = []
        pf = preflight_integrity(mod, root)
        mod_results.append(pf)
        if pf["status"] not in ("PASS", "SKIP"):
            has_fail = True
        extra = []
        if not args.skip_freshness:
            extra.append(lambda m=mod: derived_freshness(m, root))
        if args.nhom and mod.strip().upper() != "COMMON":
            extra.append(lambda m=mod: ba_hld_by_nhom(m, root, [str(n) for n in args.nhom]))
        results_iter = [run_gate(g, mod, root, strict=args.strict, json_output=args.json_output)
                        for g in GATE_SPECS] + [f() for f in extra]
        for r in results_iter:
            mod_results.append(r)
            if r["status"] == "WARN":
                has_warning = True
            elif r["status"] not in ("PASS", "SKIP"):
                has_fail = True
        all_results[mod] = mod_results

    if args.json_output:
        overall_status = "FAIL" if has_fail or (args.strict and has_warning) else "PASS"
        output = {
            "overall_status": overall_status,
            "modules": {},
        }
        for mod, results in all_results.items():
            output["modules"][mod] = results
        print(json.dumps(output, indent=2, ensure_ascii=False))
    else:
        for mod, results in all_results.items():
            print_summary(results, mod)

    # Exit code: 0 on PASS, 1 on FAIL.
    if args.strict:
        if has_fail or has_warning:
            sys.exit(1)
    else:
        if has_fail:
            sys.exit(1)
    sys.exit(0)


if __name__ == "__main__":
    main()
