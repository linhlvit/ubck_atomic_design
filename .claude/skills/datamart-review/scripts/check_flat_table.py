# -*- coding: utf-8 -*-
"""
check_flat_table.py — Alias / Entry-point for datamart_flat_table_checker.py
"""
from __future__ import annotations

import sys
from pathlib import Path

script_dir = Path(__file__).resolve().parent
if str(script_dir) not in sys.path:
    sys.path.insert(0, str(script_dir))

from datamart_flat_table_checker import (
    FlatTableCheckResult,
    FlatTableIssue,
    audit_all_flat_tables,
    audit_module_flat_table,
    main,
)

if __name__ == "__main__":
    main()
