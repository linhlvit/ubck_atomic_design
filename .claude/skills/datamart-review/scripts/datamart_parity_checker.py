# -*- coding: utf-8 -*-
"""
datamart_parity_checker.py — Datamart Attribute & ETL Logic Parity Checker CLI

Audits content parity between:
- Localized Module Attributes CSVs (Datamart/lld/{MODULE}/*.csv)
- Central Master Registry (Datamart/lld/datamart_attributes.csv)

Detects:
1. Missing in Master: Attributes added to localized module files but omitted from master registry.
2. Missing in Module: Attributes defined in master registry for module table but absent in local CSV.
3. Content Mismatches: Character-level divergence in etl_logic transformation expressions.
4. Extended Mismatches: Discrepancies in description, data_type, nullable, or source mappings (--fields all).

Usage:
    python scripts/datamart_parity_checker.py --module GSTT --strict
    python scripts/datamart_parity_checker.py --module all --strict
    python scripts/datamart_parity_checker.py --module QLCB --generate-fix
    python scripts/datamart_parity_checker.py --json --strict
"""
from __future__ import annotations

import argparse
import csv
import json
import os
from pathlib import Path
import sys
from typing import Any, Dict, List, Optional

# Ensure datamart_common is importable
_script_parent = str(Path(__file__).resolve().parent)
if _script_parent not in sys.path:
    sys.path.insert(0, _script_parent)

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

try:
    csv.field_size_limit(min(sys.maxsize, 2147483647))
except (OverflowError, AttributeError):
    pass

from datamart_common import (
    ParityAuditResult,
    ParityCheckResult,
    ParityDiscrepancy,
    ParityDiscrepancyType,
    audit_all_parity,
    audit_module_parity,
    check_etl_logic_parity,
    find_project_root,
    generate_fix_commands,
    generate_parity_markdown_report,
    get_available_modules,
    normalize_module_name,
    strip_accents,
)


def print_console_summary(result: ParityCheckResult, generate_fix: bool = False, verbose: bool = False) -> None:
    """Print clean formatted console summary."""
    status_color = "[PASS]" if result.status == "PASS" else "[FAIL]"
    print(f"\n{'='*70}")
    print(f" Datamart ETL Logic & Attribute Parity Audit: {result.module} {status_color}")
    print(f"{'='*70}")
    print(f"  Total Columns Audited:       {result.total_columns_checked}")
    print(f"  Missing in Master Registry:  {len(result.missing_in_master)}")
    print(f"  Missing in Module CSVs:      {len(result.missing_in_module)}")
    print(f"  ETL Logic Mismatches:        {len(result.logic_mismatches)}")
    if result.extended_mismatches:
        print(f"  Extended Field Mismatches:   {len(result.extended_mismatches)}")

    # Details for Missing in Master
    if result.missing_in_master:
        print(f"\n{'-'*70}")
        print(" [CRITICAL] Columns Missing in Master Registry datamart_attributes.csv:")
        print(f"{'-'*70}")
        for idx, m in enumerate(result.missing_in_master, 1):
            f_name = Path(m["module_file"]).name if m.get("module_file") else ""
            print(f"  {idx}. {m['table_name']}.{m['column_name']}")
            print(f"     File: {f_name} (line {m.get('module_line', '-')})")
            print(f"     Action: {m['recommended_action']} ({m['rationale']})")

    # Details for Missing in Module
    if result.missing_in_module:
        print(f"\n{'-'*70}")
        print(" Columns Missing in Module CSVs (Found in Master):")
        print(f"{'-'*70}")
        for idx, m in enumerate(result.missing_in_module, 1):
            print(f"  {idx}. {m['table_name']}.{m['column_name']}")
            print(f"     Master Line: {m.get('master_line', '-')}")
            print(f"     Action: {m['recommended_action']}")

    # Details for Logic Mismatches
    if result.logic_mismatches:
        print(f"\n{'-'*70}")
        print(" ETL Logic Content Divergences:")
        print(f"{'-'*70}")
        for idx, m in enumerate(result.logic_mismatches, 1):
            print(f"  {idx}. {m['table_name']}.{m['column_name']}")
            print(f"     Diff: {m['diff_summary']}")
            print(f"     Lines: Mod Line {m.get('module_line', '-')} vs Master Line {m.get('master_line', '-')}")
            print(f"     Recommended: {m['recommended_action']} — {m['rationale']}")
            if verbose:
                print(f"       [Mod Logic]:    {m['module_logic']}")
                print(f"       [Master Logic]: {m['master_logic']}")

    # Fix suggestions
    if generate_fix and (result.missing_in_master or result.logic_mismatches):
        print(f"\n{'-'*70}")
        print(" Suggested Fix Actions:")
        print(f"{'-'*70}")
        for cmd in generate_fix_commands(result):
            print(f"  {cmd}")

    print(f"{'='*70}\n")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Datamart Attribute & ETL Logic Parity Checker (Module Attributes ↔ Master Registry)",
    )
    parser.add_argument(
        "-m", "--module",
        type=str,
        default="all",
        help="Module to audit (e.g. GSTT, QLCB, TKNB, or 'all', default: all)",
    )
    parser.add_argument(
        "-p", "--path",
        type=str,
        default=None,
        help="Path to specific module CSV file or module directory",
    )
    parser.add_argument(
        "--master",
        type=str,
        default=None,
        help="Path to master datamart_attributes.csv (auto-detected if omitted)",
    )
    parser.add_argument(
        "--fields",
        type=str,
        default="etl_logic",
        choices=["etl_logic", "all"],
        help="Fields to verify parity: 'etl_logic' (default) or 'all'",
    )
    parser.add_argument(
        "--root",
        type=str,
        default=None,
        help="Root directory of repository (auto-detected if omitted)",
    )
    parser.add_argument(
        "-o", "--output",
        type=str,
        default=None,
        help="Output Markdown report file path",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output JSON format instead of console report",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Exit with code 1 if any parity mismatches or missing columns are detected",
    )
    parser.add_argument(
        "--warn-only",
        action="store_true",
        help="Exit with code 0 even if mismatches are found",
    )
    parser.add_argument(
        "--generate-fix",
        action="store_true",
        help="Emit suggested commands or patch snippets to synchronize",
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Verbose diagnostic logging with full expressions",
    )

    args = parser.parse_args()

    root = find_project_root(args.root)

    # Master registry check
    master_p = Path(args.master).resolve() if args.master else (root / "Datamart" / "lld" / "datamart_attributes.csv")
    if not master_p.is_file():
        print(f"Error: Master attributes file not found at: {master_p}", file=sys.stderr)
        sys.exit(2)

    # Path mode
    if args.path:
        p = Path(args.path).resolve()
        if not p.exists():
            print(f"Error: Specified path does not exist: {args.path}", file=sys.stderr)
            sys.exit(2)

        mod_name = p.stem.replace("DTM_", "").split("_")[0]
        if p.is_dir():
            mod_name = p.name
        result = audit_module_parity(mod_name, root_dir=root, fields=args.fields, master_path=master_p)
    else:
        target_mod = args.module.strip()
        if target_mod.lower() == "all":
            result = check_etl_logic_parity("all", root_dir=root, fields=args.fields, master_path=master_p)
        else:
            norm_mod = normalize_module_name(target_mod)
            avail = get_available_modules(root)
            if norm_mod not in avail and strip_accents(norm_mod) not in avail:
                print(f"Error: Module '{target_mod}' not found in Datamart artifacts. Available: {', '.join(avail)}", file=sys.stderr)
                sys.exit(2)
            result = audit_module_parity(norm_mod, root_dir=root, fields=args.fields, master_path=master_p)

    # Emit JSON or Markdown / Console
    if args.json:
        json_output = json.dumps(result.to_dict(), indent=2, ensure_ascii=False)
        if args.output:
            out_p = Path(args.output).resolve()
            out_p.parent.mkdir(parents=True, exist_ok=True)
            out_p.write_text(json_output, encoding="utf-8")
        else:
            print(json_output)
    else:
        print_console_summary(result, generate_fix=args.generate_fix, verbose=args.verbose)

        if args.output:
            md_report = generate_parity_markdown_report(result)
            out_p = Path(args.output).resolve()
            out_p.parent.mkdir(parents=True, exist_ok=True)
            out_p.write_text(md_report, encoding="utf-8")
            print(f"Report written to: {out_p}")

    # Determine exit code
    total_discrepancies = (
        len(result.missing_in_master)
        + len(result.missing_in_module)
        + len(result.logic_mismatches)
        + len(result.extended_mismatches)
    )
    if total_discrepancies > 0 and args.strict and not args.warn_only:
        sys.exit(1)

    sys.exit(0)


if __name__ == "__main__":
    main()
