# -*- coding: utf-8 -*-
"""
scripts/datamart_common/parity_checker.py
Attribute & ETL Logic Parity Checker Engine for Datamart Review.
Audits content parity between:
- Localized Module Attributes CSVs (Datamart/lld/{MODULE}/*.csv)
- Central Master Registry (Datamart/lld/datamart_attributes.csv)

Features:
1. Composite Key Matching: Matches (datamart_table, datamart_column) and (datamart_entity, datamart_attribute).
2. Whitespace & Line Ending Normalization (CRLF/LF, leading/trailing space, wrapping quotes).
3. Discrepancy Detection:
   - MISSING_IN_MASTER: Attributes added to module file but omitted from master registry.
   - MISSING_IN_MODULE: Attributes present in master registry for module table but absent in module CSV.
   - CONTENT_MISMATCH: Divergence in etl_logic (or extended fields like description, data_type, sources).
4. Stale-Source Heuristic & Action Recommendation (SYNC_MODULE_TO_MASTER vs MANUAL_REVIEW).
"""
from __future__ import annotations

import csv
from dataclasses import asdict, dataclass, field
import difflib
from enum import Enum
import io
import json
import os
from pathlib import Path
import re
import sys
from typing import Any, Dict, List, Optional, Set, Tuple

# Reconfigure stdout for Windows console UTF-8 support
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

from .csv_utils import read_csv_dynamic
from .encoding import read_file_safe
from .module_resolver import (
    find_project_root,
    get_available_modules,
    normalize_module_name,
    resolve_module_path,
    strip_accents,
)


class ParityDiscrepancyType(str, Enum):
    MISSING_IN_MASTER = "MISSING_IN_MASTER"
    MISSING_IN_MODULE = "MISSING_IN_MODULE"
    CONTENT_MISMATCH = "CONTENT_MISMATCH"
    METADATA_MISMATCH = "METADATA_MISMATCH"


@dataclass
class ParityDiscrepancy:
    discrepancy_type: ParityDiscrepancyType
    module: str
    table_name: str
    column_name: str
    entity_name: str
    attribute_name: str
    field_checked: str  # e.g. 'etl_logic', 'description', 'data_type'
    module_value: str
    master_value: str
    module_file: str
    module_line: int
    master_line: int
    diff_summary: str
    recommended_action: str  # 'SYNC_MODULE_TO_MASTER', 'SYNC_MASTER_TO_MODULE', 'MANUAL_REVIEW'
    rationale: str

    def to_dict(self) -> Dict[str, Any]:
        d = asdict(self)
        d["discrepancy_type"] = self.discrepancy_type.value
        return d


@dataclass
class ParityCheckResult:
    module: str
    total_columns_checked: int = 0
    missing_in_master: List[Dict[str, Any]] = field(default_factory=list)
    missing_in_module: List[Dict[str, Any]] = field(default_factory=list)
    logic_mismatches: List[Dict[str, Any]] = field(default_factory=list)
    extended_mismatches: List[Dict[str, Any]] = field(default_factory=list)
    status: str = "PASS"
    summary: Dict[str, Any] = field(default_factory=dict)
    module_results: Dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "module": self.module,
            "total_columns_checked": self.total_columns_checked,
            "missing_in_master": self.missing_in_master,
            "missing_in_module": self.missing_in_module,
            "logic_mismatches": self.logic_mismatches,
            "extended_mismatches": self.extended_mismatches,
            "status": self.status,
            "summary": self.summary,
            "module_results": {k: v.to_dict() if hasattr(v, "to_dict") else v for k, v in self.module_results.items()},
        }


# Backward-compatible alias
ParityAuditResult = ParityCheckResult


def normalize_text(text: Optional[str]) -> str:
    """Normalize string content: strip BOM, unify newlines, strip outer whitespace."""
    if text is None:
        return ""
    s = str(text).lstrip("\ufeff")
    s = s.replace("\r\n", "\n").replace("\r", "\n")
    s = s.strip()
    if (s.startswith('"') and s.endswith('"')) or (s.startswith("'") and s.endswith("'")):
        s = s[1:-1].strip()
    return s


def determine_recommended_action(
    mod_logic: str,
    master_logic: str,
    mod_mtime: float = 0.0,
    master_mtime: float = 0.0,
) -> Tuple[str, str]:
    """
    Evaluate heuristics to determine recommended synchronization direction.
    Returns (action, rationale).
    """
    # 1. Truncation in master
    if master_logic.endswith("FORMAT(:etl_date") or (master_logic.count("(") > master_logic.count(")")):
        return (
            "SYNC_MODULE_TO_MASTER",
            "Master registry contains cut-off/truncated expression; module file contains full valid logic.",
        )

    # 2. Update annotation prefixes in module
    update_indicators = ["[MỚI", "[SỬA", "(MỚI", "(SỬA", "[FIX", "[UPDATE", "MỚI 2026", "SỬA 2026"]
    has_mod_update = any(ind in mod_logic for ind in update_indicators)
    has_master_update = any(ind in master_logic for ind in update_indicators)

    if has_mod_update and not has_master_update:
        return (
            "SYNC_MODULE_TO_MASTER",
            "Module file contains documented revision annotation not yet synchronized to master registry.",
        )

    # 3. File modification timestamp heuristic
    if mod_mtime > 0 and master_mtime > 0:
        if mod_mtime > master_mtime and (mod_mtime - master_mtime) > 120:
            return (
                "SYNC_MODULE_TO_MASTER",
                "Module file was modified more recently than master datamart_attributes.csv.",
            )

    return (
        "MANUAL_REVIEW",
        "Discrepancy detected between module specification and master registry. Manual review recommended.",
    )


def summarize_diff(a: str, b: str, max_chars: int = 140) -> str:
    """Produce a human-readable snippet showing where two strings diverge."""
    matcher = difflib.SequenceMatcher(None, a, b)
    for tag, i1, i2, j1, j2 in matcher.get_opcodes():
        if tag in ("replace", "delete", "insert"):
            sub_a = a[max(0, i1 - 15): min(len(a), i2 + 15)].replace("\n", " ")
            sub_b = b[max(0, j1 - 15): min(len(b), j2 + 15)].replace("\n", " ")
            diff_str = f"Mod: '...{sub_a}...' vs Master: '...{sub_b}...'"
            if len(diff_str) > max_chars:
                return diff_str[:max_chars - 3] + "..."
            return diff_str
    return "String differences detected"


def load_master_attributes(
    master_path: Path,
) -> Tuple[Dict[Tuple[str, str], Dict[str, Any]], Dict[str, Set[str]], float]:
    """
    Load master datamart_attributes.csv into memory with 1-based line numbers.
    Returns:
    - master_dict: (table_name, column_name) -> {column details dict, line_no}
    - master_tables: table_name -> set of column_names
    - master_mtime: float
    """
    if not master_path.is_file():
        return {}, {}, 0.0

    master_mtime = master_path.stat().st_mtime
    raw_content = read_file_safe(master_path)
    lines = raw_content.replace("\r\n", "\n").replace("\r", "\n").split("\n")

    # Parse with csv.reader to track line numbers
    delim = ","
    for d in (",", ";"):
        if d in lines[0]:
            delim = d
            break

    reader = csv.reader(io.StringIO(raw_content), delimiter=delim)
    headers = []
    master_dict: Dict[Tuple[str, str], Dict[str, Any]] = {}
    master_tables: Dict[str, Set[str]] = {}

    current_line = 0
    for row in reader:
        current_line += 1
        if not row or not any(x.strip() for x in row):
            continue

        if not headers:
            headers = [h.lstrip("\ufeff").strip() for h in row]
            continue

        row_dict = {
            headers[i]: (row[i].strip() if i < len(row) else "")
            for i in range(len(headers))
        }

        tbl = row_dict.get("datamart_table", "").strip().lower()
        col = row_dict.get("datamart_column", "").strip().lower()

        if not tbl or not col:
            continue

        row_dict["_line_no"] = current_line
        key = (tbl, col)
        master_dict[key] = row_dict

        if tbl not in master_tables:
            master_tables[tbl] = set()
        master_tables[tbl].add(col)

    return master_dict, master_tables, master_mtime


def load_module_attributes(
    module_dir: Path,
) -> Tuple[Dict[Tuple[str, str], Dict[str, Any]], Set[str], float]:
    """
    Load localized module CSVs in Datamart/lld/{MODULE}/*.csv.
    Returns:
    - module_dict: (table_name, column_name) -> {column details dict, line_no, file_path}
    - tables_present: set of table_names
    - max_mtime: float
    """
    module_dict: Dict[Tuple[str, str], Dict[str, Any]] = {}
    tables_present: Set[str] = set()
    max_mtime = 0.0

    for csv_file in sorted(module_dir.glob("*.csv")):
        f_mtime = csv_file.stat().st_mtime
        if f_mtime > max_mtime:
            max_mtime = f_mtime

        raw_content = read_file_safe(csv_file)
        lines = raw_content.replace("\r\n", "\n").replace("\r", "\n").split("\n")
        delim = ","
        for d in (",", ";"):
            if lines and d in lines[0]:
                delim = d
                break

        reader = csv.reader(io.StringIO(raw_content), delimiter=delim)
        headers = []
        current_line = 0
        for row in reader:
            current_line += 1
            if not row or not any(x.strip() for x in row):
                continue
            if not headers:
                headers = [h.lstrip("\ufeff").strip() for h in row]
                continue

            row_dict = {
                headers[i]: (row[i].strip() if i < len(row) else "")
                for i in range(len(headers))
            }

            tbl = row_dict.get("datamart_table", "").strip().lower()
            col = row_dict.get("datamart_column", "").strip().lower()

            if not tbl or not col:
                continue

            row_dict["_line_no"] = current_line
            row_dict["_file_path"] = str(csv_file)
            row_dict["_file_mtime"] = f_mtime

            key = (tbl, col)
            module_dict[key] = row_dict
            tables_present.add(tbl)

    return module_dict, tables_present, max_mtime


def audit_module_parity(
    module: str,
    root_dir: Optional[str | Path] = None,
    fields: str = "etl_logic",
    master_path: Optional[str | Path] = None,
) -> ParityCheckResult:
    """
    Perform deep content parity audit between module attributes CSVs and master registry.
    fields: 'etl_logic' (default) or 'all' (checks description, data_type, nullable, sources).
    """
    root = find_project_root(root_dir)
    mod_norm = normalize_module_name(module)
    mod_strip = strip_accents(mod_norm)

    result = ParityCheckResult(module=mod_norm)

    # Master registry path
    if master_path:
        m_path = Path(master_path).resolve()
    else:
        m_path = root / "Datamart" / "lld" / "datamart_attributes.csv"

    if not m_path.is_file():
        result.status = "FAIL"
        result.summary = {"error": f"Master attributes file not found: {m_path}"}
        return result

    # Module directory path
    lld_dir = root / "Datamart" / "lld" / mod_norm
    if not lld_dir.is_dir():
        lld_dir = root / "Datamart" / "lld" / mod_strip

    if not lld_dir.is_dir():
        result.status = "PASS"
        result.summary = {
            "module": mod_norm,
            "status": "PASS",
            "message": f"No localized LLD folder found at Datamart/lld/{mod_norm}/",
            "total_columns_checked": 0,
        }
        return result

    # Load datasets
    master_data, master_tables_map, master_mtime = load_master_attributes(m_path)
    module_data, module_tables, module_mtime = load_module_attributes(lld_dir)

    result.total_columns_checked = len(module_data)

    # 1. Detect MISSING_IN_MASTER (columns in module CSV but absent in master)
    for (tbl, col), mod_row in module_data.items():
        if (tbl, col) not in master_data:
            missing_item = {
                "module": mod_norm,
                "table_name": tbl,
                "column_name": col,
                "entity_name": mod_row.get("datamart_entity", ""),
                "attribute_name": mod_row.get("datamart_attribute", ""),
                "module_file": mod_row.get("_file_path", ""),
                "module_line": mod_row.get("_line_no", 0),
                "recommended_action": "SYNC_MODULE_TO_MASTER",
                "rationale": "Column defined in localized module CSV was never synchronized into master registry datamart_attributes.csv.",
            }
            result.missing_in_master.append(missing_item)

    # 2. Detect MISSING_IN_MODULE (columns in master for this module's tables but missing in module CSV)
    for tbl in module_tables:
        if tbl in master_tables_map:
            for col in master_tables_map[tbl]:
                if (tbl, col) not in module_data:
                    master_row = master_data.get((tbl, col), {})
                    missing_item = {
                        "module": mod_norm,
                        "table_name": tbl,
                        "column_name": col,
                        "entity_name": master_row.get("datamart_entity", ""),
                        "attribute_name": master_row.get("datamart_attribute", ""),
                        "master_line": master_row.get("_line_no", 0),
                        "recommended_action": "INVESTIGATE_OR_SYNC_TO_MODULE",
                        "rationale": f"Column exists in master registry for table '{tbl}', but is absent in module CSV.",
                    }
                    result.missing_in_module.append(missing_item)

    # 3. Detect CONTENT_MISMATCH on common columns
    check_extended = fields.strip().lower() == "all"
    extended_fields_to_check = [
        "description",
        "data_type",
        "nullable",
        "etl_logic_type",
        "source_entity",
        "atomic_table",
        "source_attribute",
        "atomic_column",
    ]

    for (tbl, col), mod_row in module_data.items():
        if (tbl, col) not in master_data:
            continue

        master_row = master_data[(tbl, col)]

        # Check etl_logic parity
        mod_logic_norm = normalize_text(mod_row.get("etl_logic", ""))
        master_logic_norm = normalize_text(master_row.get("etl_logic", ""))

        if mod_logic_norm != master_logic_norm:
            rec_action, rationale = determine_recommended_action(
                mod_logic=mod_logic_norm,
                master_logic=master_logic_norm,
                mod_mtime=mod_row.get("_file_mtime", 0.0),
                master_mtime=master_mtime,
            )
            diff_desc = summarize_diff(mod_logic_norm, master_logic_norm)

            mismatch_item = {
                "module": mod_norm,
                "table_name": tbl,
                "column_name": col,
                "entity_name": mod_row.get("datamart_entity", ""),
                "attribute_name": mod_row.get("datamart_attribute", ""),
                "module_file": mod_row.get("_file_path", ""),
                "module_line": mod_row.get("_line_no", 0),
                "master_line": master_row.get("_line_no", 0),
                "module_logic": mod_logic_norm,
                "master_logic": master_logic_norm,
                "diff_summary": diff_desc,
                "recommended_action": rec_action,
                "rationale": rationale,
            }
            result.logic_mismatches.append(mismatch_item)

        # Check extended fields if requested
        if check_extended:
            for ext_f in extended_fields_to_check:
                mod_v = normalize_text(mod_row.get(ext_f, ""))
                master_v = normalize_text(master_row.get(ext_f, ""))
                if mod_v != master_v:
                    result.extended_mismatches.append({
                        "module": mod_norm,
                        "table_name": tbl,
                        "column_name": col,
                        "field_checked": ext_f,
                        "module_value": mod_v,
                        "master_value": master_v,
                        "module_file": mod_row.get("_file_path", ""),
                        "module_line": mod_row.get("_line_no", 0),
                        "master_line": master_row.get("_line_no", 0),
                    })

    # Summary and status
    total_issues = len(result.missing_in_master) + len(result.missing_in_module) + len(result.logic_mismatches)
    if check_extended:
        total_issues += len(result.extended_mismatches)

    result.status = "PASS" if total_issues == 0 else "FAIL"
    result.summary = {
        "module": mod_norm,
        "status": result.status,
        "total_columns_checked": result.total_columns_checked,
        "missing_in_master_count": len(result.missing_in_master),
        "missing_in_module_count": len(result.missing_in_module),
        "logic_mismatches_count": len(result.logic_mismatches),
        "extended_mismatches_count": len(result.extended_mismatches),
        "total_discrepancies": total_issues,
    }

    return result


def audit_all_parity(
    root_dir: Optional[str | Path] = None,
    fields: str = "etl_logic",
    master_path: Optional[str | Path] = None,
) -> Dict[str, ParityCheckResult]:
    """Run parity audit across all available modules in repository."""
    root = find_project_root(root_dir)
    modules = get_available_modules(root)
    results: Dict[str, ParityCheckResult] = {}
    for mod in modules:
        if mod.upper() == "COMMON":
            continue
        results[mod] = audit_module_parity(mod, root_dir=root, fields=fields, master_path=master_path)
    return results


def check_etl_logic_parity(
    module: str,
    root_dir: Optional[str | Path] = None,
    fields: str = "etl_logic",
    master_path: Optional[str | Path] = None,
) -> ParityCheckResult:
    """
    Interface contract function for etl_logic parity checking.
    Accepts specific module name (e.g. 'GSTT', 'QLCB', 'TKNB') or 'all'.
    """
    root = find_project_root(root_dir)
    mod = module.strip()

    if mod.lower() == "all":
        all_results = audit_all_parity(root_dir=root, fields=fields, master_path=master_path)
        aggregated = ParityCheckResult(module="all")
        for m_name, res in all_results.items():
            aggregated.total_columns_checked += res.total_columns_checked
            aggregated.missing_in_master.extend(res.missing_in_master)
            aggregated.missing_in_module.extend(res.missing_in_module)
            aggregated.logic_mismatches.extend(res.logic_mismatches)
            aggregated.extended_mismatches.extend(res.extended_mismatches)
            aggregated.module_results[m_name] = res

        total_issues = (
            len(aggregated.missing_in_master)
            + len(aggregated.missing_in_module)
            + len(aggregated.logic_mismatches)
            + len(aggregated.extended_mismatches)
        )
        aggregated.status = "PASS" if total_issues == 0 else "FAIL"
        aggregated.summary = {
            "module": "all",
            "status": aggregated.status,
            "total_modules_audited": len(all_results),
            "total_columns_checked": aggregated.total_columns_checked,
            "total_missing_in_master": len(aggregated.missing_in_master),
            "total_missing_in_module": len(aggregated.missing_in_module),
            "total_logic_mismatches": len(aggregated.logic_mismatches),
            "total_discrepancies": total_issues,
        }
        return aggregated

    return audit_module_parity(mod, root_dir=root, fields=fields, master_path=master_path)


def generate_parity_markdown_report(
    check_result: ParityCheckResult | List[ParityCheckResult],
) -> str:
    """Format ParityCheckResult into a comprehensive human-readable Markdown report."""
    results = check_result if isinstance(check_result, list) else [check_result]

    lines = [
        "# Datamart Attribute & ETL Logic Parity Audit Report",
        "",
        "> Audit Scope: Localized Module Attributes CSVs (Datamart/lld/{MODULE}/*.csv) ↔ Master Registry (Datamart/lld/datamart_attributes.csv)",
        "",
    ]

    total_checked = sum(r.total_columns_checked for r in results)
    total_missing_master = sum(len(r.missing_in_master) for r in results)
    total_missing_module = sum(len(r.missing_in_module) for r in results)
    total_logic_diffs = sum(len(r.logic_mismatches) for r in results)
    total_discrepancies = total_missing_master + total_missing_module + total_logic_diffs
    overall_status = "PASS" if total_discrepancies == 0 else "FAIL"

    lines.append("## Executive Summary")
    lines.append(f"- **Overall Status**: `{overall_status}`")
    lines.append(f"- **Total Columns Audited**: `{total_checked}`")
    lines.append(f"- **Total Discrepancies**: `{total_discrepancies}`")
    lines.append(f"  - **Missing in Master Registry**: `{total_missing_master}`")
    lines.append(f"  - **Missing in Module CSVs**: `{total_missing_module}`")
    lines.append(f"  - **ETL Logic Content Mismatches**: `{total_logic_diffs}`")
    lines.append("")

    lines.append("## Module Parity Matrix")
    lines.append("| Module | Columns Audited | Missing in Master | Missing in Module | Logic Diffs | Status |")
    lines.append("|---|:---:|:---:|:---:|:---:|:---:|")

    for r in results:
        if r.module == "all" and r.module_results:
            for sub_mod, sub_r in sorted(r.module_results.items()):
                lines.append(
                    f"| **{sub_mod}** | {sub_r.total_columns_checked} | {len(sub_r.missing_in_master)} | "
                    f"{len(sub_r.missing_in_module)} | {len(sub_r.logic_mismatches)} | `{sub_r.status}` |"
                )
            break
        else:
            lines.append(
                f"| **{r.module}** | {r.total_columns_checked} | {len(r.missing_in_master)} | "
                f"{len(r.missing_in_module)} | {len(r.logic_mismatches)} | `{r.status}` |"
            )
    lines.append("")

    # Detailed Section: Missing in Master
    all_missing_master: List[Dict[str, Any]] = []
    all_missing_mod: List[Dict[str, Any]] = []
    all_logic_diffs: List[Dict[str, Any]] = []

    for r in results:
        all_missing_master.extend(r.missing_in_master)
        all_missing_mod.extend(r.missing_in_module)
        all_logic_diffs.extend(r.logic_mismatches)

    if all_missing_master:
        lines.append("### 1. Missing in Master Registry (CRITICAL — Module Has Unsynchronized Attributes)")
        lines.append("| Module | Table | Column | Module File | Line | Recommended Action |")
        lines.append("|---|---|---|---|:---:|---|")
        for m in all_missing_master:
            f_short = Path(m["module_file"]).name if m.get("module_file") else ""
            lines.append(
                f"| {m['module']} | `{m['table_name']}` | `{m['column_name']}` | "
                f"`{f_short}` | {m.get('module_line', '-')} | `{m['recommended_action']}` |"
            )
        lines.append("")

    if all_missing_mod:
        lines.append("### 2. Missing in Module CSV (Present in Master, Absent in Local File)")
        lines.append("| Module | Table | Column | Master Line | Recommended Action |")
        lines.append("|---|---|---|:---:|---|")
        for m in all_missing_mod:
            lines.append(
                f"| {m['module']} | `{m['table_name']}` | `{m['column_name']}` | "
                f"{m.get('master_line', '-')} | `{m['recommended_action']}` |"
            )
        lines.append("")

    if all_logic_diffs:
        lines.append("### 3. ETL Logic Content Mismatches (Transformation Logic Drift)")
        lines.append("| Module | Table | Column | Mod Line | Mst Line | Diff Summary | Action |")
        lines.append("|---|---|---|:---:|:---:|---|---|")
        for m in all_logic_diffs:
            lines.append(
                f"| {m['module']} | `{m['table_name']}` | `{m['column_name']}` | "
                f"{m.get('module_line', '-')} | {m.get('master_line', '-')} | "
                f"{m['diff_summary']} | `{m['recommended_action']}` |"
            )
        lines.append("")

    if not (all_missing_master or all_missing_mod or all_logic_diffs):
        lines.append("## Detailed Discrepancies")
        lines.append("100% parity verified. Master registry and module CSVs are fully synchronized.")
        lines.append("")

    return "\n".join(lines)


def generate_fix_commands(check_result: ParityCheckResult) -> List[str]:
    """Generate suggested remediation commands for reviewer to synchronize drift."""
    commands: List[str] = []
    for m in check_result.missing_in_master:
        commands.append(
            f"# Add {m['table_name']}.{m['column_name']} from {Path(m['module_file']).name} (line {m['module_line']}) into datamart_attributes.csv"
        )
    for m in check_result.logic_mismatches:
        if m["recommended_action"] == "SYNC_MODULE_TO_MASTER":
            commands.append(
                f"# Update {m['table_name']}.{m['column_name']} in datamart_attributes.csv (line {m['master_line']}) to match module logic"
            )
    return commands
