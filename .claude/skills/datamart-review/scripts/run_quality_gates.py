# -*- coding: utf-8 -*-
"""
run_quality_gates.py — Unified Datamart Quality Gate Runner (Gate 0 → Gate 5)

Runs all quality gate checks sequentially and aggregates results.

Gates:
  Gate 0 (Reference Integrity): check_references.py --strict
  Gate 1 (Macro-Review Sanity): check_date_fk.py
  Gate 2 (Parity Check):       check_parity.py --strict
  Gate 3 (Orphan Check):       check_orphan.py --strict
  Gate 4 (Flat Table):         check_flat_table.py --strict
  Gate 5 (HLD Structure 5B):   check_hld_5b.py --strict

Exit Code:
  0 on PASS (all gates pass or skip)
  1 on FAIL (any active gate fails; under --strict also fails on warnings)

Usage:
    python scripts/run_quality_gates.py -m GSTT
    python scripts/run_quality_gates.py -m Common
    python scripts/run_quality_gates.py -m ALL --strict
    python scripts/run_quality_gates.py -m GSTT --json
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

from datamart_common import find_project_root, get_available_modules


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
]


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
        if r["status"] not in ("PASS", "SKIP"):
            all_pass = False
            if r.get("message"):
                print(f"     ↳ {r['message']}")

    print(f"\n{'─'*70}")
    overall = "✅ ALL GATES PASSED" if all_pass else "❌ ONE OR MORE GATES FAILED"
    print(f"  Overall: {overall}")
    print(f"{'='*70}\n")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Unified Datamart Quality Gate Runner (Gate 0-5)",
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
        for gate_spec in GATE_SPECS:
            r = run_gate(gate_spec, mod, root, strict=args.strict, json_output=args.json_output)
            mod_results.append(r)
            if r["status"] not in ("PASS", "SKIP"):
                has_fail = True
            elif r["status"] == "WARN":
                has_warning = True
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
