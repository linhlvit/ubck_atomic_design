# -*- coding: utf-8 -*-
"""
scripts/datamart_common/__init__.py
Shared utility module for Datamart Review skills.
"""
from __future__ import annotations

from .csv_utils import (
    detect_delimiter,
    detect_delimiter_and_header,
    read_csv_dynamic,
)
from .encoding import (
    detect_file_encoding,
    read_file_safe,
)
from .module_resolver import (
    MODULE_ALIASES,
    find_project_root,
    get_available_modules,
    get_module_files,
    normalize_module_name,
    resolve_entities_csv,
    resolve_flat_table_sql,
    resolve_module_path,
    strip_accents,
)
from .orphan_checker import (
    OrphanAuditResult,
    OrphanCheckResult,
    OrphanItem,
    OrphanType,
    ResolutionBranch,
    audit_all_orphans,
    audit_module_orphans,
    check_orphan_3way,
    generate_orphan_markdown_report,
)
from .parity_checker import (
    ParityAuditResult,
    ParityCheckResult,
    ParityDiscrepancy,
    ParityDiscrepancyType,
    audit_all_parity,
    audit_module_parity,
    check_etl_logic_parity,
    generate_fix_commands,
    generate_parity_markdown_report,
)
from .whitelist import (
    DEFAULT_FALLBACK_RULES,
    is_group_whitelisted,
    load_whitelist,
)

__all__ = [
    "detect_file_encoding",
    "read_file_safe",
    "detect_delimiter",
    "detect_delimiter_and_header",
    "read_csv_dynamic",
    "normalize_module_name",
    "resolve_module_path",
    "get_module_files",
    "resolve_entities_csv",
    "resolve_flat_table_sql",
    "get_available_modules",
    "find_project_root",
    "MODULE_ALIASES",
    "strip_accents",
    "load_whitelist",
    "is_group_whitelisted",
    "DEFAULT_FALLBACK_RULES",
    # Orphan Checker
    "check_orphan_3way",
    "audit_module_orphans",
    "audit_all_orphans",
    "generate_orphan_markdown_report",
    "OrphanCheckResult",
    "OrphanAuditResult",
    "OrphanItem",
    "OrphanType",
    "ResolutionBranch",
    # Parity Checker
    "check_etl_logic_parity",
    "audit_module_parity",
    "audit_all_parity",
    "generate_parity_markdown_report",
    "generate_fix_commands",
    "ParityCheckResult",
    "ParityAuditResult",
    "ParityDiscrepancy",
    "ParityDiscrepancyType",
]

