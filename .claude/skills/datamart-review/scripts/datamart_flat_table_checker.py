# -*- coding: utf-8 -*-
"""
datamart_flat_table_checker.py — Datamart Flat Table Quality Gate 4 Checker CLI

Audits Flat Table SQL files (DDL + DML) against 5 criteria:
  1. Column Coverage: All Fact/Operational columns and joined Dim business attributes present in DDL
  2. Projection Alignment: 1-1 count, order, and alias match between CREATE TABLE and SELECT
  3. Column Drift: No orphan columns vs master datamart_attributes.csv
  4. Parameter Consistency: All daily ETL date filters use :etl_date
  5. Common Dimensions Sync: cdr_dt_flat present in Common/ with 9 required columns

Usage:
    python scripts/datamart_flat_table_checker.py --module GSTT --strict
    python scripts/datamart_flat_table_checker.py --module Common --strict
    python scripts/datamart_flat_table_checker.py --module all --strict --json
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple

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

from datamart_common import (
    find_project_root,
    get_available_modules,
    normalize_module_name,
    strip_accents,
)


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class FlatTableIssue:
    """A single issue found during flat table audit."""
    error_code: str
    severity: str  # "CRITICAL", "WARNING", "INFO"
    table_name: str
    message: str
    details: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        d = {
            "error_code": self.error_code,
            "severity": self.severity,
            "table_name": self.table_name,
            "message": self.message,
        }
        if self.details:
            d["details"] = self.details
        return d


@dataclass
class FlatTableCheckResult:
    """Aggregated results from flat table audit for one module."""
    module: str
    status: str = "PASS"
    total_tables_ddl: int = 0
    total_tables_dml: int = 0
    issues: List[FlatTableIssue] = field(default_factory=list)

    @property
    def critical_count(self) -> int:
        return sum(1 for i in self.issues if i.severity == "CRITICAL")

    @property
    def warning_count(self) -> int:
        return sum(1 for i in self.issues if i.severity == "WARNING")

    def to_dict(self) -> Dict[str, Any]:
        return {
            "module": self.module,
            "status": self.status,
            "total_tables_ddl": self.total_tables_ddl,
            "total_tables_dml": self.total_tables_dml,
            "critical_count": self.critical_count,
            "warning_count": self.warning_count,
            "issues": [i.to_dict() for i in self.issues],
        }


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

TECH_AUDIT_COLUMNS = {
    "ds_batch_date",
    "ds_population_timestamp",
    "ds_rcrd_st",
    "ds_eff_start_dt",
    "ds_eff_end_dt",
    "ds_cdc_opr_cd",
    "ds_load_ts",
    "ds_snpst_dt",
}

CDR_DT_FLAT_REQUIRED_COLS = {
    "cdr_dt_dim_id",
    "cdr_dt",
    "year",
    "quarter",
    "month",
    "day_of_week",
    "is_weekend",
    "holiday_flag",
    "is_trading_date",
}

STANDARD_CALENDAR_COLUMNS = {
    "cdr_dt",
    "is_trading_date",
    "day_of_week",
    "day_name",
    "cal_month",
    "cal_quarter",
    "cal_year",
    "year",
    "quarter",
    "month",
    "is_weekend",
    "holiday_flag",
}


# ---------------------------------------------------------------------------
# SQL Parsing Helpers
# ---------------------------------------------------------------------------

_RE_CREATE_TABLE = re.compile(
    r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(\S+)",
    re.IGNORECASE,
)
_RE_INSERT_INTO = re.compile(
    r"INSERT\s+INTO\s+([a-zA-Z0-9_.]+)(?:\s+ON\s+CLUSTER\s+(?:'[^']*'|\"[^\"]*\"|\S+))?",
    re.IGNORECASE,
)
_RE_BAD_ETL_PARAM = re.compile(
    r":\w+|\{\s*etl_date\s*\}|\$etl_date|%\(etl_date\)s|\?|'\d{4}-\d{2}-\d{2}'",
    re.IGNORECASE,
)


def _parse_create_tables(sql_text: str) -> Dict[str, List[str]]:
    """Parse CREATE TABLE blocks, return {table_name: [col_name, ...]}."""
    tables: Dict[str, List[str]] = {}
    blocks = re.split(r"(?=CREATE\s+TABLE)", sql_text, flags=re.IGNORECASE)
    for block in blocks:
        m = _RE_CREATE_TABLE.search(block)
        if not m:
            continue
        table_name = m.group(1).strip().rstrip("(")
        paren_start = block.find("(", m.end())
        if paren_start < 0:
            continue
        engine_pos = re.search(r"\)\s*ENGINE", block[paren_start:], re.IGNORECASE)
        if engine_pos:
            col_block = block[paren_start + 1:paren_start + engine_pos.start()]
        else:
            paren_end = block.rfind(")")
            col_block = block[paren_start + 1:paren_end] if paren_end > paren_start else ""

        cols = []
        for line in col_block.split("\n"):
            line_stripped = line.strip().rstrip(",")
            if not line_stripped or line_stripped.startswith("--"):
                continue
            parts = line_stripped.split()
            if parts and re.match(r"^[a-z_]\w*$", parts[0], re.IGNORECASE):
                col_name = parts[0].strip()
                cols.append(col_name)
        tables[table_name] = cols
    return tables


def _extract_alias_from_projection(item: str) -> str:
    """Extract alias or target field name from a SELECT projection item."""
    item = item.strip()
    # 1. Look for explicit AS alias: expr AS alias
    as_match = re.search(r"\bAS\s+([a-zA-Z0-9_]+)\s*$", item, re.IGNORECASE)
    if as_match:
        return as_match.group(1).strip()
    # 2. Look for table.column or column
    col_match = re.search(r"(?:[a-zA-Z0-9_]+\.)?([a-zA-Z0-9_]+)\s*$", item)
    if col_match:
        return col_match.group(1).strip()
    return item


def _parse_insert_selects(sql_text: str) -> Dict[str, List[str]]:
    """
    Parse INSERT INTO ... SELECT blocks robustly.
    Supports both:
      - Syntax A: INSERT INTO table_name (col1, col2, ...) SELECT ...
      - Syntax B: INSERT INTO table_name SELECT col1, col2 AS alias, ... FROM ...
    Properly handles single-line/multi-line comments, nested parens, quotes, and joins.
    """
    tables: Dict[str, List[str]] = {}
    matches = list(_RE_INSERT_INTO.finditer(sql_text))
    
    for idx, match in enumerate(matches):
        table_name = match.group(1).strip()
        start_pos = match.end()
        end_pos = matches[idx + 1].start() if idx + 1 < len(matches) else len(sql_text)
        block = sql_text[start_pos:end_pos]
        
        # Locate SELECT keyword in this block
        select_match = re.search(r"\bSELECT\b", block, re.IGNORECASE)
        if not select_match:
            tables[table_name] = []
            continue
            
        pre_select = block[:select_match.start()].strip()
        post_select = block[select_match.end():]
        
        # Check Syntax A: parenthesized column list before SELECT
        if pre_select.startswith("(") and pre_select.endswith(")"):
            raw_cols = pre_select[1:-1]
            cols = []
            for line in raw_cols.split(","):
                c = re.sub(r"--.*$", "", line).strip()
                if c:
                    cols.append(c)
            tables[table_name] = cols
            continue
            
        # Syntax B: parse SELECT projection expressions up to top-level FROM
        proj_chars = []
        i = 0
        depth = 0
        in_single = False
        in_double = False
        in_comment_line = False
        in_comment_block = False
        n = len(post_select)
        
        while i < n:
            ch = post_select[i]
            
            # Handle comment state
            if in_comment_line:
                if ch == "\n":
                    in_comment_line = False
                    proj_chars.append(" ")
                i += 1
                continue
            if in_comment_block:
                if ch == "*" and i + 1 < n and post_select[i + 1] == "/":
                    in_comment_block = False
                    i += 2
                    proj_chars.append(" ")
                    continue
                i += 1
                continue
                
            if not in_single and not in_double:
                if ch == "-" and i + 1 < n and post_select[i + 1] == "-":
                    in_comment_line = True
                    i += 2
                    continue
                if ch == "/" and i + 1 < n and post_select[i + 1] == "*":
                    in_comment_block = True
                    i += 2
                    continue
            
            # Handle strings
            if ch == "'" and not in_double:
                in_single = not in_single
                proj_chars.append(ch)
                i += 1
                continue
            if ch == '"' and not in_single:
                in_double = not in_double
                proj_chars.append(ch)
                i += 1
                continue
                
            if in_single or in_double:
                proj_chars.append(ch)
                i += 1
                continue
                
            # Depth tracking
            if ch == "(":
                depth += 1
                proj_chars.append(ch)
                i += 1
                continue
            elif ch == ")":
                depth -= 1
                proj_chars.append(ch)
                i += 1
                continue
                
            # Top-level FROM marks end of SELECT projection
            if depth == 0:
                if (i == 0 or post_select[i - 1].isspace() or post_select[i - 1] in "),") and \
                   post_select[i:i + 4].upper() == "FROM" and \
                   (i + 4 >= n or post_select[i + 4].isspace() or post_select[i + 4] == "("):
                    break
                    
            proj_chars.append(ch)
            i += 1
            
        proj_str = "".join(proj_chars)
        
        # Split proj_str by top-level commas (depth == 0, not in string)
        items = []
        cur = []
        d = 0
        s_quote = False
        d_quote = False
        for c in proj_str:
            if c == "'" and not d_quote:
                s_quote = not s_quote
                cur.append(c)
            elif c == '"' and not s_quote:
                d_quote = not d_quote
                cur.append(c)
            elif not s_quote and not d_quote:
                if c == "(":
                    d += 1
                    cur.append(c)
                elif c == ")":
                    d -= 1
                    cur.append(c)
                elif c == "," and d == 0:
                    item = "".join(cur).strip()
                    if item:
                        items.append(item)
                    cur = []
                else:
                    cur.append(c)
            else:
                cur.append(c)
        if cur:
            item = "".join(cur).strip()
            if item:
                items.append(item)
                
        # Extract column aliases
        cols = [_extract_alias_from_projection(item) for item in items if item.strip()]
        tables[table_name] = cols
        
    return tables


def _read_csv_rows(csv_path: Path) -> List[Dict[str, str]]:
    """Helper to read CSV with dynamic delimiter detection and UTF-8 handling."""
    if not csv_path.exists():
        return []
    text = csv_path.read_text(encoding="utf-8", errors="replace")
    if not text.strip():
        return []
    first_line = text.split("\n")[0]
    delim = ";" if ";" in first_line else ","
    reader = csv.DictReader(text.splitlines(), delimiter=delim)
    return list(reader)


# ---------------------------------------------------------------------------
# Criterion 1: Column Coverage Check
# ---------------------------------------------------------------------------

def _check_column_coverage(
    root: Path,
    module: str,
    ddl_tables: Dict[str, List[str]],
) -> List[FlatTableIssue]:
    """
    Criterion 1: Flat Table Column Coverage Check (L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING)
    Verifies that:
      1. 100% of Fact and Operational columns from LLD (excluding tech audit columns) exist in DDL.
      2. Calendar date columns exist in DDL when date FKs are present in Fact.
    """
    issues: List[FlatTableIssue] = []
    mod = normalize_module_name(module)
    mod_stripped = strip_accents(mod)
    
    lld_dir = root / "Datamart" / "lld" / mod
    if not lld_dir.is_dir():
        lld_dir = root / "Datamart" / "lld" / mod_stripped
    if not lld_dir.is_dir():
        return issues
        
    # Map LLD tables to their business columns
    lld_tables: Dict[str, List[str]] = {}
    for csv_file in lld_dir.glob("*.csv"):
        rows = _read_csv_rows(csv_file)
        if not rows:
            continue
        t_name = rows[0].get("datamart_table", "").strip().lower()
        if not t_name:
            continue
        b_cols = [
            r.get("datamart_column", "").strip()
            for r in rows
            if r.get("datamart_column", "").strip().lower() not in TECH_AUDIT_COLUMNS
        ]
        lld_tables[t_name] = b_cols

    # For each flat table in DDL, find matching Fact/Operational table
    for flat_tbl, d_cols in ddl_tables.items():
        core = flat_tbl.split(".")[-1].lower()
        if core.endswith("_flat"):
            core = core[:-5]
        for pfx in [f"{mod.lower()}_", f"{mod_stripped.lower()}_"]:
            if core.startswith(pfx):
                core = core[len(pfx):]
                break
                
        # Check against LLD tables
        lld_cols = lld_tables.get(core)
        if lld_cols:
            d_cols_lower = {c.lower() for c in d_cols}
            missing_fact_cols = [c for c in lld_cols if c.lower() not in d_cols_lower]
            if missing_fact_cols:
                issues.append(FlatTableIssue(
                    error_code="L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING",
                    severity="CRITICAL",
                    table_name=flat_tbl,
                    message=f"DDL missing Fact/Operational columns from LLD: {sorted(missing_fact_cols)}",
                ))
                
            # Date dimension column coverage check
            has_date_fk = any(c.lower().endswith("_dt_dim_id") for c in lld_cols)
            if has_date_fk:
                has_date_col = any(
                    c.lower() in ("cdr_dt", "is_trading_date") or c.lower().endswith("_cdr_dt") or c.lower().endswith("_dt")
                    for c in d_cols
                )
                if not has_date_col:
                    issues.append(FlatTableIssue(
                        error_code="L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING",
                        severity="CRITICAL",
                        table_name=flat_tbl,
                        message="DDL missing calendar date columns (e.g. cdr_dt, is_trading_date) for table with Date FK",
                    ))
                    
    return issues


# ---------------------------------------------------------------------------
# Criterion 2: 1-1 Projection Alignment Check
# ---------------------------------------------------------------------------

def _check_projection_alignment(
    ddl_tables: Dict[str, List[str]],
    dml_tables: Dict[str, List[str]],
) -> List[FlatTableIssue]:
    """
    Criterion 2: 1-1 Projection Alignment Check (L4-FLAT-TABLE-PROJECTION-MISALIGNMENT)
    Verifies 1-1 count, order, and alias matching between CREATE TABLE and SELECT.
    """
    issues: List[FlatTableIssue] = []
    ddl_table_set = set(ddl_tables.keys())
    dml_table_set = set(dml_tables.keys())

    for table_name, ddl_cols in ddl_tables.items():
        dml_cols = dml_tables.get(table_name)
        if dml_cols is None:
            issues.append(FlatTableIssue(
                error_code="L4-FLAT-TABLE-PROJECTION-MISALIGNMENT",
                severity="CRITICAL",
                table_name=table_name,
                message=f"Table {table_name} in DDL but not found in DML INSERT INTO",
            ))
            continue
        if len(ddl_cols) != len(dml_cols):
            issues.append(FlatTableIssue(
                error_code="L4-FLAT-TABLE-PROJECTION-MISALIGNMENT",
                severity="CRITICAL",
                table_name=table_name,
                message=f"Column count mismatch: DDL has {len(ddl_cols)} columns, DML INSERT has {len(dml_cols)} columns",
            ))
        else:
            for i, (dc, ic) in enumerate(zip(ddl_cols, dml_cols)):
                if dc.lower() != ic.lower():
                    issues.append(FlatTableIssue(
                        error_code="L4-FLAT-TABLE-PROJECTION-MISALIGNMENT",
                        severity="CRITICAL",
                        table_name=table_name,
                        message=f"Column name mismatch at position {i+1}: DDL='{dc}', DML INSERT='{ic}'",
                    ))
                    break

    for table_name in dml_table_set - ddl_table_set:
        issues.append(FlatTableIssue(
            error_code="L4-FLAT-TABLE-PROJECTION-MISALIGNMENT",
            severity="CRITICAL",
            table_name=table_name,
            message=f"Table {table_name} in DML but not found in DDL CREATE TABLE",
        ))

    return issues


# ---------------------------------------------------------------------------
# Criterion 3: Column Drift Control
# ---------------------------------------------------------------------------

def _check_column_drift(
    root: Path,
    module: str,
    ddl_tables: Dict[str, List[str]],
) -> List[FlatTableIssue]:
    """
    Criterion 3: Column Drift Control (L4-FLAT-TABLE-COLUMN-DRIFT)
    Detects unapproved columns in DDL that do not exist in master datamart_attributes.csv
    or standard dimensional/role-playing aliases.
    """
    issues: List[FlatTableIssue] = []
    master_path = root / "Datamart" / "lld" / "datamart_attributes.csv"
    if not master_path.exists():
        return issues
        
    master_rows = _read_csv_rows(master_path)
    master_cols = {r.get("datamart_column", "").strip().lower() for r in master_rows if r.get("datamart_column")}

    for table_name, ddl_cols in ddl_tables.items():
        for col in ddl_cols:
            cl = col.lower()
            if cl in master_cols or cl in STANDARD_CALENDAR_COLUMNS:
                continue
            # Fact disambiguation prefix
            if cl.startswith("fct_") and cl[4:] in master_cols:
                continue
            # Qualified source system code
            if cl.endswith("_src_stm_code"):
                continue
            # Flattened role-playing date
            if cl.endswith("_cdr_dt") or cl.endswith("_dt"):
                continue
            issues.append(FlatTableIssue(
                error_code="L4-FLAT-TABLE-COLUMN-DRIFT",
                severity="CRITICAL",
                table_name=table_name,
                message=f"Column drift detected: column '{col}' does not exist in master datamart_attributes.csv or standard alias",
            ))

    return issues


# ---------------------------------------------------------------------------
# Criterion 4: Parameter Consistency Check
# ---------------------------------------------------------------------------

def _check_etl_date_params(sql_text: str) -> List[FlatTableIssue]:
    """Criterion 4: Check all WHERE date filter clauses use :etl_date."""
    issues: List[FlatTableIssue] = []
    for line_num, line in enumerate(sql_text.split("\n"), 1):
        line_upper = line.upper().strip()
        if ("WHERE" in line_upper or "AND" in line_upper) and "CDR_DT" in line_upper and "=" in line:
            eq_pos = line.find("=")
            if eq_pos >= 0:
                value_part = line[eq_pos + 1:].strip().rstrip(";").strip()
                if value_part and value_part != ":etl_date":
                    if _RE_BAD_ETL_PARAM.search(value_part):
                        issues.append(FlatTableIssue(
                            error_code="L4-FLAT-TABLE-PARAMETER-INCONSISTENT",
                            severity="CRITICAL",
                            table_name="(DML file)",
                            message=f"Line {line_num}: ETL date filter uses non-standard parameter: '{value_part}' (expected ':etl_date')",
                        ))
    return issues


# ---------------------------------------------------------------------------
# Criterion 5: Common Dimensions Sync Check
# ---------------------------------------------------------------------------

def check_common_dimensions(root: Path) -> List[FlatTableIssue]:
    """Criterion 5: Common Dimensions Sync — datamart.cdr_dt_flat in Common/."""
    issues: List[FlatTableIssue] = []
    common_dir = root / "Datamart" / "flat-table" / "Common"

    ddl_file = common_dir / "01_create_common_flat_tables.sql"
    dml_file = common_dir / "02_populate_common_flat_tables.sql"

    if not ddl_file.exists():
        issues.append(FlatTableIssue(
            error_code="L4-COMMON-DIM-CLICKHOUSE-MISSING",
            severity="CRITICAL",
            table_name="datamart.cdr_dt_flat",
            message="Missing DDL file: Datamart/flat-table/Common/01_create_common_flat_tables.sql",
        ))
        return issues

    if not dml_file.exists():
        issues.append(FlatTableIssue(
            error_code="L4-COMMON-DIM-CLICKHOUSE-MISSING",
            severity="CRITICAL",
            table_name="datamart.cdr_dt_flat",
            message="Missing DML file: Datamart/flat-table/Common/02_populate_common_flat_tables.sql",
        ))
        return issues

    ddl_text = ddl_file.read_text(encoding="utf-8", errors="replace")
    ddl_tables = _parse_create_tables(ddl_text)
    cdr_dt_flat_cols: Optional[List[str]] = None
    for tname, cols in ddl_tables.items():
        if "cdr_dt_flat" in tname.lower():
            cdr_dt_flat_cols = cols
            break

    if cdr_dt_flat_cols is None:
        issues.append(FlatTableIssue(
            error_code="L4-COMMON-DIM-CLICKHOUSE-MISSING",
            severity="CRITICAL",
            table_name="datamart.cdr_dt_flat",
            message="DDL file exists but does not contain CREATE TABLE for datamart.cdr_dt_flat",
        ))
        return issues

    # Check 9 required columns
    col_set = {c.lower() for c in cdr_dt_flat_cols}
    missing = CDR_DT_FLAT_REQUIRED_COLS - col_set
    if missing:
        issues.append(FlatTableIssue(
            error_code="L4-COMMON-DIM-CLICKHOUSE-MISSING",
            severity="CRITICAL",
            table_name="datamart.cdr_dt_flat",
            message=f"DDL missing required columns: {sorted(missing)}",
        ))

    # Check DML sources from datamart.cdr_dt_dim
    dml_text = dml_file.read_text(encoding="utf-8", errors="replace")
    if "cdr_dt_flat" not in dml_text.lower():
        issues.append(FlatTableIssue(
            error_code="L4-COMMON-DIM-CLICKHOUSE-MISSING",
            severity="CRITICAL",
            table_name="datamart.cdr_dt_flat",
            message="DML file does not contain INSERT INTO datamart.cdr_dt_flat",
        ))
    if "cdr_dt_dim" not in dml_text.lower():
        issues.append(FlatTableIssue(
            error_code="L4-COMMON-DIM-CLICKHOUSE-MISSING",
            severity="CRITICAL",
            table_name="datamart.cdr_dt_flat",
            message="DML file does not source data FROM datamart.cdr_dt_dim",
        ))

    return issues


# ---------------------------------------------------------------------------
# Core Module Auditor
# ---------------------------------------------------------------------------

def audit_module_flat_table(
    root: Path,
    module: str,
) -> FlatTableCheckResult:
    """Run full Gate 4 audit for a single module."""
    mod = normalize_module_name(module)
    mod_stripped = strip_accents(mod)
    result = FlatTableCheckResult(module=mod)

    # Handle Common module
    if mod.upper() == "COMMON":
        common_issues = check_common_dimensions(root)
        result.issues.extend(common_issues)
        common_dir = root / "Datamart" / "flat-table" / "Common"
        ddl_file = common_dir / "01_create_common_flat_tables.sql"
        if ddl_file.exists():
            ddl_text = ddl_file.read_text(encoding="utf-8", errors="replace")
            ddl_tables = _parse_create_tables(ddl_text)
            result.total_tables_ddl = len(ddl_tables)
            dml_file = common_dir / "02_populate_common_flat_tables.sql"
            if dml_file.exists():
                dml_text = dml_file.read_text(encoding="utf-8", errors="replace")
                dml_tables = _parse_insert_selects(dml_text)
                result.total_tables_dml = len(dml_tables)
                # Also verify projection alignment for Common
                align_issues = _check_projection_alignment(ddl_tables, dml_tables)
                result.issues.extend(align_issues)
        result.status = "FAIL" if result.critical_count > 0 else "PASS"
        return result

    # Regular business module
    ft_dir = root / "Datamart" / "flat-table"
    ddl_path: Optional[Path] = None
    dml_path: Optional[Path] = None

    for candidate_name in [mod, mod_stripped, mod.upper(), mod_stripped.upper()]:
        sdir = ft_dir / candidate_name
        if sdir.is_dir():
            for f in sdir.glob("01_create*.sql"):
                ddl_path = f
                break
            for f in sdir.glob("02_populate*.sql"):
                dml_path = f
                break
            if ddl_path:
                break

    if ddl_path is None:
        result.issues.append(FlatTableIssue(
            error_code="L4-FLAT-TABLE-COLUMN-COVERAGE-MISSING",
            severity="CRITICAL",
            table_name=f"(module {mod})",
            message=f"No DDL file found for module {mod} in Datamart/flat-table/",
        ))
        result.status = "FAIL"
        return result

    ddl_text = ddl_path.read_text(encoding="utf-8", errors="replace")
    ddl_tables = _parse_create_tables(ddl_text)
    result.total_tables_ddl = len(ddl_tables)

    if dml_path is None:
        result.issues.append(FlatTableIssue(
            error_code="L4-FLAT-TABLE-PROJECTION-MISALIGNMENT",
            severity="CRITICAL",
            table_name=f"(module {mod})",
            message=f"No DML file found for module {mod} in Datamart/flat-table/",
        ))
        result.status = "FAIL"
        return result

    dml_text = dml_path.read_text(encoding="utf-8", errors="replace")
    dml_tables = _parse_insert_selects(dml_text)
    result.total_tables_dml = len(dml_tables)

    # 1. Criterion 1: Column Coverage
    cov_issues = _check_column_coverage(root, mod, ddl_tables)
    result.issues.extend(cov_issues)

    # 2. Criterion 2: 1-1 Projection Alignment
    align_issues = _check_projection_alignment(ddl_tables, dml_tables)
    result.issues.extend(align_issues)

    # 3. Criterion 3: Column Drift Control
    drift_issues = _check_column_drift(root, mod, ddl_tables)
    result.issues.extend(drift_issues)

    # 4. Criterion 4: Parameter Consistency
    param_issues = _check_etl_date_params(dml_text)
    result.issues.extend(param_issues)

    # 5. Criterion 5: Common Dimensions Sync
    common_issues = check_common_dimensions(root)
    result.issues.extend(common_issues)

    # Status evaluation
    result.status = "FAIL" if result.critical_count > 0 else "PASS"
    return result


def audit_all_flat_tables(root: Path) -> List[FlatTableCheckResult]:
    """Run Gate 4 audit on all discovered modules."""
    modules = get_available_modules(root)
    results = []
    for mod in modules:
        results.append(audit_module_flat_table(root, mod))
    return results


# ---------------------------------------------------------------------------
# Console Output
# ---------------------------------------------------------------------------

def print_console_summary(result: FlatTableCheckResult) -> None:
    """Print formatted console summary for one module."""
    status_label = "[PASS]" if result.status == "PASS" else "[FAIL]"
    print(f"\n{'='*70}")
    print(f" Datamart Flat Table Gate 4 Audit: {result.module} {status_label}")
    print(f"{'='*70}")
    print(f"  Tables in DDL (CREATE):  {result.total_tables_ddl}")
    print(f"  Tables in DML (INSERT):  {result.total_tables_dml}")
    print(f"  Critical Issues:         {result.critical_count}")
    print(f"  Warning Issues:          {result.warning_count}")

    if result.issues:
        print(f"\n  --- Issues ---")
        for iss in result.issues:
            icon = "🔴" if iss.severity == "CRITICAL" else "🟡" if iss.severity == "WARNING" else "🔵"
            print(f"  {icon} [{iss.error_code}] {iss.table_name}")
            print(f"     {iss.message}")
            if iss.details:
                print(f"     Details: {iss.details}")

    print(f"{'='*70}\n")


# ---------------------------------------------------------------------------
# CLI Main
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Datamart Flat Table Quality Gate 4 Checker",
    )
    parser.add_argument(
        "-m", "--module",
        required=True,
        help="Module code (e.g. GSTT, Common, all)",
    )
    parser.add_argument(
        "--root",
        default=None,
        help="Project root directory (auto-detected if omitted)",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Exit with code 1 if any Critical or Warning issue found",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        dest="json_output",
        help="Output results as JSON",
    )
    args = parser.parse_args()

    root = find_project_root(args.root) if args.root else find_project_root()

    if args.module.strip().upper() == "ALL":
        results = audit_all_flat_tables(root)
    else:
        results = [audit_module_flat_table(root, args.module)]

    has_fail = any(r.status == "FAIL" for r in results)
    has_critical = any(r.critical_count > 0 for r in results)
    has_warning = any(r.warning_count > 0 for r in results)

    if args.json_output:
        output = {
            "overall_status": "FAIL" if has_fail else "PASS",
            "modules": [r.to_dict() for r in results],
        }
        print(json.dumps(output, indent=2, ensure_ascii=False))
    else:
        for r in results:
            print_console_summary(r)

    if args.strict:
        if has_critical or has_warning:
            sys.exit(1)
    else:
        if has_critical:
            sys.exit(1)
    sys.exit(0)


if __name__ == "__main__":
    main()
