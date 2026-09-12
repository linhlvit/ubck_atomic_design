# -*- coding: utf-8 -*-
"""
datamart_orphan_checker.py — Datamart 3-Way Orphan Entity Checker CLI

Audits consistency across:
- Tier A: LLD Attributes CSV (Datamart/lld/{MODULE}/*.csv)
- Tier B: HLD Entities CSV (Datamart/hld/DTM_{MODULE}_Entities.csv)
- Tier C: Flat Table SQL DDL (Datamart/flat-table/{MODULE}/01_create_{module}_flat_tables.sql)

Automated 2-Branch Resolution:
- Branch A (Complete Missing): Table is active (measures exist) -> Prompt to complete Phase 2/3.
- Branch B (All-Tier Cleanup): Table is deprecated (0 measures) -> All-Tier Cleanup Protocol.

Usage:
    python scripts/datamart_orphan_checker.py --module GSTT --strict
    python scripts/datamart_orphan_checker.py --module all --strict
    python scripts/datamart_orphan_checker.py --module QLCB -o report.md
    python scripts/datamart_orphan_checker.py --json --strict
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
    OrphanAuditResult,
    OrphanCheckResult,
    OrphanItem,
    OrphanType,
    ResolutionBranch,
    audit_all_orphans,
    audit_module_orphans,
    check_orphan_3way,
    find_project_root,
    generate_orphan_markdown_report,
    get_available_modules,
    normalize_module_name,
    resolve_entities_csv,
    resolve_flat_table_sql,
    strip_accents,
)


def print_console_summary(result: OrphanCheckResult, verbose: bool = False) -> None:
    """Print clean formatted console summary."""
    status_color = "[PASS]" if result.status == "PASS" else "[FAIL]"
    print(f"\n{'='*70}")
    print(f" Datamart 3-Way Orphan Entity Audit: {result.module} {status_color}")
    print(f"{'='*70}")
    print(f"  Total LLD Tables:         {len(result.tier_a_lld_tables)}")
    print(f"  Total HLD Entities:       {len(result.tier_b_hld_entities)}")
    print(f"  Total Flat Tables (SQL):  {len(result.tier_c_flat_tables)}")
    print(f"  Conformed / Reused:       {len(result.conformed_reused_tables)}")
    print(f"  Dimensions Denormalized:  {len(result.denormalized_dims)}")
    print(f"  Total Orphan Entities:    {len(result.orphans)}")
    print(f"    - Branch A (Incomplete): {len(result.branch_a_missing)}")
    print(f"    - Branch B (Deprecated): {len(result.branch_b_orphans)}")

    if result.naming_warnings:
        print(f"\n  Naming & Normalization Notes ({len(result.naming_warnings)}):")
        for w in result.naming_warnings:
            print(f"    * {w}")

    if result.orphans:
        print(f"\n{'-'*70}")
        print(" Orphan Entities Breakdown:")
        print(f"{'-'*70}")
        for idx, o in enumerate(result.orphans, 1):
            branch_tag = "[BRANCH A - COMPLETE]" if o.branch == ResolutionBranch.BRANCH_A_COMPLETE_MISSING else "[BRANCH B - CLEANUP]"
            print(f"  {idx}. {branch_tag} {o.entity_name} ({o.table_name})")
            print(f"     Type: {o.table_type} | Detected In: LLD={o.in_tier_a_lld}, HLD={o.in_tier_b_hld}, FlatSQL={o.in_tier_c_flat}")
            print(f"     Reason: {o.reason}")
            print(f"     Action: {o.remediation_action}")

    print(f"{'='*70}\n")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Datamart 3-Way Orphan Entity Checker (LLD ↔ HLD Entities ↔ Flat Table SQL)",
    )
    parser.add_argument(
        "-m", "--module",
        type=str,
        default="all",
        help="Module to audit (e.g. GSTT, QLCB, TKNB, TT, or 'all', default: all)",
    )
    parser.add_argument(
        "-p", "--path",
        type=str,
        default=None,
        help="Path to specific module directory or HLD Entities CSV file",
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
        help="Output JSON format instead of console table",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Exit with code 1 if any orphan entities are detected, 0 if clean",
    )
    parser.add_argument(
        "--warn-only",
        action="store_true",
        help="Exit with code 0 even if orphan entities are found",
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Verbose console logging",
    )

    args = parser.parse_args()

    root = find_project_root(args.root)

    # Handle path flag if specified
    if args.path:
        p = Path(args.path).resolve()
        if not p.exists():
            print(f"Error: Specified path does not exist: {args.path}", file=sys.stderr)
            sys.exit(2)

        # Determine module name from path
        mod_name = p.stem.replace("DTM_", "").replace("_Entities", "").replace("_HLD", "")
        if p.is_dir():
            mod_name = p.name
        result = audit_module_orphans(mod_name, root_dir=root)
    else:
        target_mod = args.module.strip()
        if target_mod.lower() == "all":
            result = check_orphan_3way("all", root_dir=root)
        else:
            norm_mod = normalize_module_name(target_mod)
            avail = get_available_modules(root)
            if norm_mod not in avail and strip_accents(norm_mod) not in avail:
                print(f"Error: Module '{target_mod}' not found in Datamart artifacts. Available: {', '.join(avail)}", file=sys.stderr)
                sys.exit(2)
            result = audit_module_orphans(norm_mod, root_dir=root)

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
        print_console_summary(result, verbose=args.verbose)

        if args.output:
            md_report = generate_orphan_markdown_report(result)
            out_p = Path(args.output).resolve()
            out_p.parent.mkdir(parents=True, exist_ok=True)
            out_p.write_text(md_report, encoding="utf-8")
            print(f"Report written to: {out_p}")

    # Determine exit code
    has_orphans = len(result.orphans) > 0
    if has_orphans and args.strict and not args.warn_only:
        sys.exit(1)

    sys.exit(0)


if __name__ == "__main__":
    main()
