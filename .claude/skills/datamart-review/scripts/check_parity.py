# -*- coding: utf-8 -*-
"""
check_parity.py — Alias / Entry-point for datamart_parity_checker.py
"""
from __future__ import annotations

import sys
from pathlib import Path

script_dir = Path(__file__).resolve().parent
if str(script_dir) not in sys.path:
    sys.path.insert(0, str(script_dir))

from datamart_parity_checker import (
    ParityAuditResult,
    ParityCheckResult,
    ParityDiscrepancy,
    ParityDiscrepancyType,
    audit_all_parity,
    audit_module_parity,
    check_etl_logic_parity,
    main,
)

if __name__ == "__main__":
    main()
