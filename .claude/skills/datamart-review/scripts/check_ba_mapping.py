# -*- coding: utf-8 -*-
"""
check_ba_mapping.py — Alias / CLI shortcut for datamart_ba_cross_checker.py
"""
from __future__ import annotations

import sys
from pathlib import Path

script_dir = Path(__file__).resolve().parent
if str(script_dir) not in sys.path:
    sys.path.insert(0, str(script_dir))

from datamart_ba_cross_checker import (
    BAItem,
    BAParser,
    DatamartBACrossChecker,
    DetailMappingItem,
    DetailMappingLinter,
    DetailMappingParser,
    MappingViolation,
    ModuleAuditResult,
    PendingClassification,
    PendingClassifier,
    PendingItemDetail,
    main,
)

if __name__ == "__main__":
    sys.exit(main())
