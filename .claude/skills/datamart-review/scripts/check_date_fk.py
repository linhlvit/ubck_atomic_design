# -*- coding: utf-8 -*-
"""
check_date_fk.py — Alias / Entry-point for datamart_date_fk_checker.py
"""
import sys
from pathlib import Path

script_dir = Path(__file__).resolve().parent
if str(script_dir) not in sys.path:
    sys.path.insert(0, str(script_dir))

from datamart_date_fk_checker import (
    main,
    DatamartDateFKChecker,
    detect_delimiter,
    audit_csv_content,
    audit_file,
    audit_directory,
    ViolationType,
    Severity,
    ColumnViolation,
    TableAuditResult,
    CheckerSummary,
)

if __name__ == "__main__":
    main()
