# -*- coding: utf-8 -*-
"""
tests/run_tests.py
Unified E2E Test Suite Runner for Datamart Review Quality Gatekeeping

Supports 4-tier execution hierarchy:
- Tier 1: Feature Coverage (Unit & Interface Contracts)
- Tier 2: Boundary & Corner Cases (Robustness & Encoding)
- Tier 3: Cross-Feature Combinations (Flag interactions & Pipelines)
- Tier 4: Real-World Workloads (TKNB, GSTT, QLCB baselines)

Usage:
    python tests/run_tests.py               # Run all 4 E2E tiers (default)
    python tests/run_tests.py --tier 1      # Run Tier 1 only
    python tests/run_tests.py --tier 2      # Run Tier 2 only
    python tests/run_tests.py --tier 3      # Run Tier 3 only
    python tests/run_tests.py --tier 4      # Run Tier 4 only
    python tests/run_tests.py --all         # Run all tests in repo (including legacy)
    python tests/run_tests.py --json        # Emit summary as JSON
    python tests/run_tests.py -v            # Verbose test runner output
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import sys
import time
import unittest

# Reconfigure stdout/stderr for Windows UTF-8 console output
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

REPO_ROOT = Path(__file__).resolve().parents[1]
TESTS_DIR = REPO_ROOT / "tests"

if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

TIER_MAP = {
    1: ("Tier 1: Feature Coverage", "test_e2e_tier1_features.py"),
    2: ("Tier 2: Boundary & Corner Cases", "test_e2e_tier2_boundaries.py"),
    3: ("Tier 3: Cross-Feature Combinations", "test_e2e_tier3_combinations.py"),
    4: ("Tier 4: Real-World Workloads", "test_e2e_tier4_real_workloads.py"),
}


def run_test_module(test_filename: str, verbose: bool = False) -> dict:
    """Run a single test module using unittest and return detailed metrics."""
    test_path = TESTS_DIR / test_filename
    if not test_path.exists():
        return {
            "filename": test_filename,
            "status": "ERROR",
            "tests_run": 0,
            "passed": 0,
            "skipped": 0,
            "failures": 1,
            "errors": 0,
            "duration": 0.0,
            "error_msg": f"File not found: {test_path}",
        }

    module_name = f"tests.{test_path.stem}"
    loader = unittest.defaultTestLoader
    try:
        suite = loader.loadTestsFromName(module_name)
    except Exception as e:
        return {
            "filename": test_filename,
            "status": "ERROR",
            "tests_run": 0,
            "passed": 0,
            "skipped": 0,
            "failures": 0,
            "errors": 1,
            "duration": 0.0,
            "error_msg": str(e),
        }

    start_time = time.time()
    stream = sys.stderr if verbose else open(os.devnull, "w", encoding="utf-8")
    verbosity = 2 if verbose else 0
    runner = unittest.TextTestRunner(stream=stream, verbosity=verbosity)
    result = runner.run(suite)
    duration = time.time() - start_time

    if not verbose:
        stream.close()

    total_run = result.testsRun
    failures_cnt = len(result.failures)
    errors_cnt = len(result.errors)
    skipped_cnt = len(result.skipped)
    passed_cnt = total_run - failures_cnt - errors_cnt - skipped_cnt

    status = "PASS" if (failures_cnt == 0 and errors_cnt == 0) else "FAIL"

    return {
        "filename": test_filename,
        "status": status,
        "tests_run": total_run,
        "passed": passed_cnt,
        "skipped": skipped_cnt,
        "failures": failures_cnt,
        "errors": errors_cnt,
        "duration": round(duration, 3),
        "error_details": [str(f[1]) for f in result.failures] + [str(e[1]) for e in result.errors],
    }


def main():
    parser = argparse.ArgumentParser(
        description="Unified E2E Test Suite Runner for Datamart Review Quality Gatekeeping"
    )
    parser.add_argument(
        "--tier",
        type=int,
        choices=[1, 2, 3, 4],
        help="Execute only the specified testing tier (1-4)",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Execute all test files in the tests/ directory including legacy suites",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output test execution summary in JSON format",
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Verbose test execution with detailed method names",
    )

    args = parser.parse_args()

    # Determine files to execute
    targets = []
    if args.tier:
        tier_title, filename = TIER_MAP[args.tier]
        targets.append((tier_title, filename))
    elif args.all:
        for f in sorted(TESTS_DIR.glob("test_*.py")):
            targets.append((f.stem, f.name))
    else:
        # Default: All 4 E2E tiers
        for tier_num in sorted(TIER_MAP.keys()):
            tier_title, filename = TIER_MAP[tier_num]
            targets.append((tier_title, filename))

    if not args.json:
        print("=" * 80)
        print("   DATAMART REVIEW — E2E TEST RUNNER")
        print("=" * 80)
        print(f"Workspace Root : {REPO_ROOT}")
        print(f"Python Version : {sys.version.split()[0]} ({sys.platform})")
        print(f"Target Suites  : {len(targets)} test suite(s)")
        print("-" * 80)

    results = []
    total_tests = 0
    total_passed = 0
    total_skipped = 0
    total_failures = 0
    total_errors = 0
    overall_start = time.time()

    for tier_title, filename in targets:
        if not args.json and not args.verbose:
            sys.stdout.write(f"Running {tier_title:<36} ({filename}) ... ")
            sys.stdout.flush()

        res = run_test_module(filename, verbose=args.verbose)
        res["tier_title"] = tier_title
        results.append(res)

        total_tests += res["tests_run"]
        total_passed += res["passed"]
        total_skipped += res["skipped"]
        total_failures += res["failures"]
        total_errors += res["errors"]

        if not args.json and not args.verbose:
            badge = "[PASS]" if res["status"] == "PASS" else "[FAIL]"
            print(f"{badge:>6}  ({res['tests_run']} tests, {res['skipped']} skipped, {res['duration']}s)")

    total_duration = round(time.time() - overall_start, 3)
    all_passed = (total_failures == 0 and total_errors == 0)

    if args.json:
        output_payload = {
            "overall_status": "PASS" if all_passed else "FAIL",
            "total_suites": len(results),
            "total_tests": total_tests,
            "total_passed": total_passed,
            "total_skipped": total_skipped,
            "total_failures": total_failures,
            "total_errors": total_errors,
            "duration_seconds": total_duration,
            "suites": results,
        }
        print(json.dumps(output_payload, indent=2, ensure_ascii=False))
        sys.exit(0 if all_passed else 1)

    # Print human-readable summary table
    print("\n" + "=" * 80)
    print("   TEST EXECUTION SUMMARY MATRIX")
    print("=" * 80)
    header = f"{'Tier / Suite':<35} | {'Tests':<6} | {'Pass':<5} | {'Skip':<5} | {'Fail':<5} | {'Time':<7} | {'Status'}"
    print(header)
    print("-" * len(header))

    for r in results:
        status_str = "PASS" if r["status"] == "PASS" else "FAIL"
        line = (
            f"{r['tier_title']:<35} | "
            f"{r['tests_run']:<6} | "
            f"{r['passed']:<5} | "
            f"{r['skipped']:<5} | "
            f"{r['failures'] + r['errors']:<5} | "
            f"{r['duration']:<6}s | "
            f"{status_str}"
        )
        print(line)

    print("-" * len(header))
    summary_line = (
        f"{'TOTAL':<35} | "
        f"{total_tests:<6} | "
        f"{total_passed:<5} | "
        f"{total_skipped:<5} | "
        f"{total_failures + total_errors:<5} | "
        f"{total_duration:<6}s | "
        f"{'PASS' if all_passed else 'FAIL'}"
    )
    print(summary_line)
    print("=" * 80)

    if all_passed:
        print("\nSUCCESS: All executed test cases passed successfully.")
        if total_skipped > 0:
            print(f"Notice: {total_skipped} test cases were progressively skipped awaiting subsequent milestone implementation (M2).")
        sys.exit(0)
    else:
        print(f"\nFAILURE: {total_failures + total_errors} test case(s) failed.")
        for r in results:
            if r["failures"] > 0 or r["errors"] > 0:
                print(f"\n--- Discrepancies in {r['tier_title']} ({r['filename']}) ---")
                for err in r.get("error_details", []):
                    print(err)
        sys.exit(1)


if __name__ == "__main__":
    main()
