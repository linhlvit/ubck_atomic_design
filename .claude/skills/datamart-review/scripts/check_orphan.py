# -*- coding: utf-8 -*-
"""
check_orphan.py — Alias / Entry-point for datamart_orphan_checker.py
"""
from __future__ import annotations

import sys
from pathlib import Path

script_dir = Path(__file__).resolve().parent
if str(script_dir) not in sys.path:
    sys.path.insert(0, str(script_dir))

from datamart_orphan_checker import (
    OrphanAuditResult,
    OrphanCheckResult,
    OrphanItem,
    OrphanType,
    ResolutionBranch,
    audit_all_orphans,
    audit_module_orphans,
    check_orphan_3way,
    main,
)

if __name__ == "__main__":
    main()
