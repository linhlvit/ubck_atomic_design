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
    get_module_files,
    normalize_module_name,
    resolve_module_path,
    strip_accents,
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
    "MODULE_ALIASES",
    "strip_accents",
    "load_whitelist",
    "is_group_whitelisted",
    "DEFAULT_FALLBACK_RULES",
]
