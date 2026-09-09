# -*- coding: utf-8 -*-
"""
datamart_date_fk_checker.py — Datamart Date FK Role-Playing Validator

Enforces Ralph Kimball Dimensional Modeling standards for Date Dimension foreign keys
across Datamart LLD (Low-Level Design) CSV tables:
- Rule 1: Prohibition of generic Calendar Date Dimension PK (`cdr_dt_dim_id`,
  `calendar_dt_dim_id`, or logical `Calendar Date Dimension Id`) on any Fact table.
- Rule 2: Snapshot Fact tables (`_snpst`) must use `snpst_dt_dim_id` (`Snapshot Date Dimension Id`).
- Rule 3: Context-aware role-playing date foreign key naming suggestions (`trade_dt_dim_id`,
  `decision_dt_dim_id`, `issue_dt_dim_id`, `submission_dt_dim_id`, etc.).
- Zero False Positives on `cdr_dt_dim` (the Calendar Date Dimension itself).

Usage:
    python scripts/datamart_date_fk_checker.py --module GSTT --strict
    python scripts/datamart_date_fk_checker.py --module all --strict
    python scripts/datamart_date_fk_checker.py --path Datamart/lld/GSDC/DTM_GSDC_fct_public_company_listing_info_snpst.csv
    python scripts/datamart_date_fk_checker.py --json --strict
"""

from __future__ import annotations

import argparse
from collections import Counter
import csv
from dataclasses import asdict, dataclass, field
from enum import Enum
import io
import json
import os
from pathlib import Path
import re
import sys
from typing import Any, Dict, List, Optional, Set, Tuple
import unicodedata

# Reconfigure standard output streams to utf-8 for Windows PowerShell / cmd
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

# Increase CSV field size limit to handle large SQL expressions or descriptions safely
try:
    csv.field_size_limit(min(sys.maxsize, 2147483647))
except (OverflowError, AttributeError):
    pass


# Import shared utilities from datamart_common with safe fallback
try:
    from datamart_common import (
        detect_file_encoding as _common_detect_encoding,
        read_file_safe as _common_read_file_safe,
        detect_delimiter as _common_detect_delimiter,
        detect_delimiter_and_header as _common_detect_delimiter_and_header,
        read_csv_dynamic as _common_read_csv_dynamic,
        normalize_module_name as _common_normalize_module_name,
        resolve_module_path as _common_resolve_module_path,
        get_module_files as _common_get_module_files,
        strip_accents as _common_strip_accents,
    )
except ImportError:
    _script_parent = str(Path(__file__).resolve().parent)
    if _script_parent not in sys.path:
        sys.path.insert(0, _script_parent)
    try:
        from datamart_common import (
            detect_file_encoding as _common_detect_encoding,
            read_file_safe as _common_read_file_safe,
            detect_delimiter as _common_detect_delimiter,
            detect_delimiter_and_header as _common_detect_delimiter_and_header,
            read_csv_dynamic as _common_read_csv_dynamic,
            normalize_module_name as _common_normalize_module_name,
            resolve_module_path as _common_resolve_module_path,
            get_module_files as _common_get_module_files,
            strip_accents as _common_strip_accents,
        )
    except ImportError:
        _common_detect_encoding = None
        _common_read_file_safe = None
        _common_detect_delimiter = None
        _common_detect_delimiter_and_header = None
        _common_read_csv_dynamic = None
        _common_normalize_module_name = None
        _common_resolve_module_path = None
        _common_get_module_files = None
        _common_strip_accents = None


def strip_accents(s: str) -> str:
    """Strip Vietnamese accents for flexible matching (e.g. GSĐC -> GSDC)."""
    if _common_strip_accents is not None:
        return _common_strip_accents(s)
    s = s.replace("Đ", "D").replace("đ", "d")
    nfkd = unicodedata.normalize("NFKD", s)
    return "".join([c for c in nfkd if not unicodedata.combining(c)])


class Severity(str, Enum):
    ERROR = "ERROR"      # Blocker - violation must be fixed before LLD sign-off
    WARNING = "WARNING"  # Discretionary review required


class ViolationType(str, Enum):
    RULE_1_FORBIDDEN_CDR_DT = "RULE_1_FORBIDDEN_CDR_DT"
    RULE_2_MISSING_SNPST_DT = "RULE_2_MISSING_SNPST_DT"
    RULE_2_MISNAMED_SNPST_DT = "RULE_2_MISNAMED_SNPST_DT"


@dataclass
class ColumnViolation:
    file_path: str
    line_number: int
    table_name: str
    entity_name: str
    column_name: str
    attribute_name: str
    violation_type: ViolationType
    severity: Severity
    suggested_column: str
    suggested_attribute: str
    rationale: str
    etl_logic: str = ""
    description: str = ""
    issue_code: str = "L2-DATE-FK-ROLE-PLAYING"

    def to_dict(self) -> Dict[str, Any]:
        d = asdict(self)
        d["violation_type"] = self.violation_type.value
        d["severity"] = self.severity.value
        return d


@dataclass
class TableAuditResult:
    table_name: str
    entity_name: str
    file_path: str
    is_fact: bool
    is_snapshot: bool
    is_cdr_dt_dim: bool
    violations: List[ColumnViolation] = field(default_factory=list)

    @property
    def is_clean(self) -> bool:
        return len(self.violations) == 0

    def to_dict(self) -> Dict[str, Any]:
        return {
            "table_name": self.table_name,
            "entity_name": self.entity_name,
            "file_path": self.file_path,
            "is_fact": self.is_fact,
            "is_snapshot": self.is_snapshot,
            "is_cdr_dt_dim": self.is_cdr_dt_dim,
            "is_clean": self.is_clean,
            "violations": [v.to_dict() for v in self.violations],
        }


@dataclass
class CheckerSummary:
    scanned_files_count: int = 0
    scanned_tables_count: int = 0
    fact_tables_count: int = 0
    dim_tables_count: int = 0
    clean_fact_tables_count: int = 0
    violating_fact_tables_count: int = 0
    total_violations_count: int = 0
    results_by_module: Dict[str, List[TableAuditResult]] = field(default_factory=dict)

    @property
    def all_violations(self) -> List[ColumnViolation]:
        all_v: List[ColumnViolation] = []
        for results in self.results_by_module.values():
            for r in results:
                all_v.extend(r.violations)
        return all_v

    @property
    def violations(self) -> List[ColumnViolation]:
        return self.all_violations

    def to_dict(self) -> Dict[str, Any]:
        return {
            "summary": {
                "total_files": self.scanned_files_count,
                "total_tables": self.scanned_tables_count,
                "total_fact_tables": self.fact_tables_count,
                "total_dim_tables": self.dim_tables_count,
                "clean_fact_tables": self.clean_fact_tables_count,
                "violating_fact_tables": self.violating_fact_tables_count,
                "total_violations": self.total_violations_count,
                "status": "FAILED" if self.total_violations_count > 0 else "PASSED",
            },
            "violations": [v.to_dict() for v in self.all_violations],
        }


def suggest_role_playing_date_column(
    table_name: str,
    entity_name: str,
    current_col: str = "",
    current_attr: str = "",
    etl_logic: str = "",
    description: str = "",
    atomic_col: str = "",
) -> Tuple[str, str, str]:
    """
    Suggests context-aware role-playing Date FK column name and logical attribute name.
    Returns: (suggested_column, suggested_attribute, rationale)
    """
    table_lower = table_name.lower().strip()
    entity_lower = entity_name.lower().strip()

    # Case 1: Snapshot Fact tables (_snpst)
    if table_lower.endswith("_snpst") or "snapshot" in entity_lower:
        return (
            "snpst_dt_dim_id",
            "Snapshot Date Dimension Id",
            "Fact Snapshot periodic time-axis mandates standard 'snpst_dt_dim_id' (Snapshot Date Dimension Id).",
        )

    # Case 2: Heuristic context analysis for other Fact tables
    context = f"{table_lower} {entity_lower} {current_attr.lower()} {etl_logic.lower()} {description.lower()} {atomic_col.lower()}"

    # Market / Trading / Intraday
    if any(k in context for k in ("trading_dt", "trade_dt", "giao dịch", "phiên", "intraday", "market_index", "security_trading")):
        return (
            "trade_dt_dim_id",
            "Trade Date Dimension Id",
            "Market/trading event role detected -> standardized to 'trade_dt_dim_id' (Trade Date Dimension Id).",
        )

    # Inspection / Examination / Administrative Decisions
    if any(k in context for k in ("penalty_decision", "quyết định xử phạt", "issued_dt", "decision_dt", "quyết định", "examination_team", "inspection_team", "thanh tra", "kiểm tra", "violation_case", "violation_record")):
        return (
            "decision_dt_dim_id",
            "Decision Date Dimension Id",
            "Inspection/examination/penalty decision event role detected -> standardized to 'decision_dt_dim_id' (Decision Date Dimension Id).",
        )

    # Licensing / Issuance
    if any(k in context for k in ("issue_dt", "ngày cấp", "ban hành", "license", "giấy phép")):
        return (
            "issue_dt_dim_id",
            "Issue Date Dimension Id",
            "Licensing/issuance event role detected -> standardized to 'issue_dt_dim_id' (Issue Date Dimension Id).",
        )

    # Submission / Filing
    if any(k in context for k in ("submission_dt", "nộp báo cáo", "gửi hồ sơ", "tiếp nhận")):
        return (
            "submission_dt_dim_id",
            "Submission Date Dimension Id",
            "Document submission/filing event role detected -> standardized to 'submission_dt_dim_id' (Submission Date Dimension Id).",
        )

    # Evaluation / Scoring
    if any(k in context for k in ("evaluation_dt", "đánh giá", "xếp hạng")):
        return (
            "evaluation_dt_dim_id",
            "Evaluation Date Dimension Id",
            "Evaluation/scoring event role detected -> standardized to 'evaluation_dt_dim_id' (Evaluation Date Dimension Id).",
        )

    # Effective / Maturity
    if any(k in context for k in ("effective_dt", "hiệu lực")):
        return (
            "effective_dt_dim_id",
            "Effective Date Dimension Id",
            "Effective date role detected -> standardized to 'effective_dt_dim_id' (Effective Date Dimension Id).",
        )

    # Fallback generic role-playing guideline
    return (
        "<role>_dt_dim_id",
        "<Role> Date Dimension Id",
        "Fact Date FK must reflect specific business role (e.g., trade_dt_dim_id, decision_dt_dim_id, issue_dt_dim_id).",
    )


def decode_bytes(raw_bytes: bytes) -> str:
    """Decode raw bytes using BOM detection, UTF-16, UTF-8-sig, CP1258, and Latin-1 fallbacks."""
    # UTF-16 BOM
    if raw_bytes.startswith(b"\xff\xfe") or raw_bytes.startswith(b"\xfe\xff"):
        try:
            return raw_bytes.decode("utf-16")
        except UnicodeDecodeError:
            pass

    # Check null bytes for UTF-16 without BOM
    if b"\x00" in raw_bytes[:100]:
        for enc in ("utf-16", "utf-16le", "utf-16be"):
            try:
                return raw_bytes.decode(enc)
            except UnicodeDecodeError:
                pass

    # Standard fallback sequence
    for enc in ("utf-8-sig", "cp1258", "mac_roman", "latin-1"):
        try:
            return raw_bytes.decode(enc)
        except UnicodeDecodeError:
            pass

    return raw_bytes.decode("latin-1", errors="replace")


def detect_delimiter(raw_text: str) -> str:
    """Auto-detect CSV delimiter (',' or ';') using mode and consistency analysis."""
    if _common_detect_delimiter is not None:
        return _common_detect_delimiter(raw_text)

    sample = raw_text[:8192].lstrip("\ufeff").replace("\r\n", "\n").replace("\r", "\n")
    delim_scores = {}

    for delim in (",", ";"):
        try:
            reader = csv.reader(io.StringIO(sample, newline=""), delimiter=delim)
            row_lens = [
                len(r)
                for idx, r in enumerate(reader)
                if idx < 15 and any(c.strip() for c in r) and not (r and r[0].strip().startswith("#"))
            ]
            if not row_lens:
                continue
            mode_len = Counter(row_lens).most_common(1)[0][0]
            consistency = sum(1 for l in row_lens if l == mode_len) / len(row_lens)
            effective_cols = mode_len if mode_len >= 2 else 0
            delim_scores[delim] = (effective_cols, consistency)
        except Exception:
            pass

    if not delim_scores:
        return ","

    best_delim = max(delim_scores.keys(), key=lambda d: (delim_scores[d][0] >= 2, delim_scores[d][0], delim_scores[d][1]))
    return best_delim


def parse_csv_rows(raw_text: str) -> Tuple[List[str], List[Tuple[int, List[str]]]]:
    """
    Parse CSV text into header list and list of (1-based line number, row tokens).
    Robustly handles multi-line cells and quotation errors.
    """
    raw_text = raw_text.lstrip("\ufeff").replace("\r\n", "\n").replace("\r", "\n")
    delim = detect_delimiter(raw_text)

    try:
        reader = csv.reader(io.StringIO(raw_text, newline=""), delimiter=delim)
        all_rows = list(reader)
    except csv.Error:
        reader = csv.reader(io.StringIO(raw_text, newline=""), delimiter=delim, quoting=csv.QUOTE_NONE)
        all_rows = list(reader)

    if not all_rows:
        return [], []

    # Detect header row: scan first 10 rows
    header_idx = 0
    best_score = -1
    for idx in range(min(10, len(all_rows))):
        row = all_rows[idx]
        row_str = " ".join(c.lower() for c in row)
        score = sum(1 for c in row if c.strip())
        if any(k in row_str for k in ("datamart_table", "table_name", "bảng")):
            score += 10
        if any(k in row_str for k in ("datamart_column", "column_name", "cột")):
            score += 10
        if any(k in row_str for k in ("datamart_attribute", "attribute_name", "thuộc tính")):
            score += 5
        if any(k in row_str for k in ("datamart_entity", "entity_name")):
            score += 5
        if score > best_score:
            best_score = score
            header_idx = idx

    header = [c.strip() for c in all_rows[header_idx]]
    # 1-based line number calculation
    data_rows: List[Tuple[int, List[str]]] = []
    for offset, r in enumerate(all_rows[header_idx + 1 :]):
        line_no = header_idx + 2 + offset
        if any(cell.strip() for cell in r):
            data_rows.append((line_no, r))

    return header, data_rows


def is_fact_table(table_name: str, entity_name: str = "", table_type: str = "") -> bool:
    """
    Determines whether a table is a Fact table.
    CRITICAL: Dimension table 'cdr_dt_dim' is explicitly excluded to ensure zero false positives.
    """
    tbl = table_name.strip().lower()
    ent = entity_name.strip().lower()
    tt = table_type.strip().lower()

    # Rule 0: Dimension Whitelist & Exclusions
    if tbl == "cdr_dt_dim" or ent == "calendar date dimension":
        return False
    if tbl.endswith("_dim") or tbl.startswith("dim_"):
        return False
    if tbl.startswith("opr_"):
        return False
    if tbl.endswith("_rpt") and not tbl.startswith("fct_"):
        return False

    # Positive Fact conditions
    if tt == "fact":
        return True
    if tbl.startswith("fct_"):
        return True
    if tbl.endswith("_snpst"):
        return True
    if ent.startswith("fact "):
        return True

    return False


def is_snapshot_fact(table_name: str, entity_name: str = "") -> bool:
    """Checks if a fact table is a Periodic Snapshot Fact."""
    tbl = table_name.strip().lower()
    ent = entity_name.strip().lower()
    return tbl.endswith("_snpst") or "snapshot" in ent


def audit_table_rows(
    table_name: str,
    entity_name: str,
    file_path: str,
    rows: List[Tuple[int, Dict[str, str]]],
) -> TableAuditResult:
    """
    Audits attribute rows for a single table.
    Enforces Rule 1 (prohibition of cdr_dt_dim_id on Facts) and Rule 2 (snapshot date FK standardization).
    """
    is_fact = is_fact_table(table_name, entity_name)
    is_snapshot = is_snapshot_fact(table_name, entity_name) if is_fact else False
    is_cdr = (table_name.strip().lower() == "cdr_dt_dim" or entity_name.strip().lower() == "calendar date dimension")

    result = TableAuditResult(
        table_name=table_name,
        entity_name=entity_name,
        file_path=file_path,
        is_fact=is_fact,
        is_snapshot=is_snapshot,
        is_cdr_dt_dim=is_cdr,
        violations=[],
    )

    # Whitelist dimension tables and non-facts
    if not is_fact or is_cdr:
        return result

    date_fk_columns: List[Tuple[int, str, str, str, str, str]] = []
    has_standard_snpst_dt = False

    for line_no, row in rows:
        col_name = row.get("datamart_column", "").strip()
        attr_name = row.get("datamart_attribute", "").strip()
        key_type = row.get("key", "").strip().upper()
        etl_logic = row.get("etl_logic", "").strip()
        desc = row.get("description", "").strip()
        atomic_col = row.get("atomic_column", "").strip()

        col_lower = col_name.lower()
        attr_lower = attr_name.lower()

        # Track date FK candidate columns
        if (
            col_lower.endswith("_dt_dim_id")
            or col_lower in ("cdr_dt_dim_id", "calendar_dt_dim_id")
            or "date dimension" in attr_lower
            or "lookup cdr_dt_dim" in etl_logic.lower()
        ):
            date_fk_columns.append((line_no, col_name, attr_name, etl_logic, desc, atomic_col))

        if col_lower == "snpst_dt_dim_id":
            has_standard_snpst_dt = True

        # RULE 1: Flag cdr_dt_dim_id / calendar_dt_dim_id / Calendar Date Dimension Id on Fact tables
        is_violating_col = col_lower in ("cdr_dt_dim_id", "calendar_dt_dim_id")
        is_violating_attr = attr_lower in (
            "calendar date dimension id",
            "calendar date dim id",
            "calendar date id",
        )

        if is_violating_col or is_violating_attr:
            sugg_col, sugg_attr, rationale = suggest_role_playing_date_column(
                table_name=table_name,
                entity_name=entity_name,
                current_col=col_name,
                current_attr=attr_name,
                etl_logic=etl_logic,
                description=desc,
                atomic_col=atomic_col,
            )

            v_type = ViolationType.RULE_1_FORBIDDEN_CDR_DT
            if is_snapshot:
                v_type = ViolationType.RULE_2_MISNAMED_SNPST_DT

            result.violations.append(
                ColumnViolation(
                    file_path=file_path,
                    line_number=line_no,
                    table_name=table_name,
                    entity_name=entity_name,
                    column_name=col_name,
                    attribute_name=attr_name,
                    violation_type=v_type,
                    severity=Severity.ERROR,
                    suggested_column=sugg_col,
                    suggested_attribute=sugg_attr,
                    rationale=rationale,
                    etl_logic=etl_logic,
                    description=desc,
                )
            )

    # RULE 2: For snapshot fact tables ending with _snpst, snpst_dt_dim_id is mandatory.
    if is_snapshot and not has_standard_snpst_dt and not result.violations:
        if date_fk_columns:
            line_no, col_name, attr_name, etl_logic, desc, atomic_col = date_fk_columns[0]
            sugg_col, sugg_attr, rationale = suggest_role_playing_date_column(
                table_name=table_name,
                entity_name=entity_name,
                current_col=col_name,
                current_attr=attr_name,
                etl_logic=etl_logic,
                description=desc,
                atomic_col=atomic_col,
            )
            result.violations.append(
                ColumnViolation(
                    file_path=file_path,
                    line_number=line_no,
                    table_name=table_name,
                    entity_name=entity_name,
                    column_name=col_name,
                    attribute_name=attr_name,
                    violation_type=ViolationType.RULE_2_MISSING_SNPST_DT,
                    severity=Severity.WARNING,
                    suggested_column="snpst_dt_dim_id",
                    suggested_attribute="Snapshot Date Dimension Id",
                    rationale=(
                        f"Snapshot fact table '{table_name}' uses role '{col_name}' instead of standard 'snpst_dt_dim_id'. "
                        "Confirm if snapshot periodic grain should be standardized."
                    ),
                    etl_logic=etl_logic,
                    description=desc,
                )
            )
        else:
            result.violations.append(
                ColumnViolation(
                    file_path=file_path,
                    line_number=1,
                    table_name=table_name,
                    entity_name=entity_name,
                    column_name="(missing)",
                    attribute_name="(missing)",
                    violation_type=ViolationType.RULE_2_MISSING_SNPST_DT,
                    severity=Severity.ERROR,
                    suggested_column="snpst_dt_dim_id",
                    suggested_attribute="Snapshot Date Dimension Id",
                    rationale=f"Bảng Fact Snapshot '{table_name}' bắt buộc phải có khóa ngoại trục thời gian kỳ 'snpst_dt_dim_id'.",
                )
            )

    return result


def audit_csv_content(csv_data: str | bytes, file_name: str = "memory.csv") -> List[ColumnViolation]:
    """
    Audits raw CSV text or bytes and returns list of ColumnViolation objects.
    Useful for in-memory unit tests and streaming pipelines.
    """
    if isinstance(csv_data, bytes):
        raw_text = decode_bytes(csv_data)
    else:
        raw_text = csv_data

    header, data_rows = parse_csv_rows(raw_text)
    if not header or not data_rows:
        return []

    header_map = {name.lower().strip(): idx for idx, name in enumerate(header) if name}

    def get_col_idx(aliases: List[str]) -> Optional[int]:
        for alias in aliases:
            if alias.lower() in header_map:
                return header_map[alias.lower()]
        return None

    tbl_idx = get_col_idx(["datamart_table", "table_name", "table", "bảng"])
    ent_idx = get_col_idx(["datamart_entity", "entity_name", "entity"])
    col_idx = get_col_idx(["datamart_column", "column_name", "physical_name", "cột", "column"])
    attr_idx = get_col_idx(["datamart_attribute", "attribute_name", "logical_name", "thuộc tính"])
    key_idx = get_col_idx(["key", "khóa", "column_role"])
    etl_idx = get_col_idx(["etl_logic", "logic_etl", "etl", "logic"])
    desc_idx = get_col_idx(["description", "mô tả", "ghi chú"])
    atm_col_idx = get_col_idx(["atomic_column", "source_column"])

    def get_cell(row: List[str], idx: Optional[int]) -> str:
        if idx is not None and len(row) > idx:
            return row[idx].strip()
        return ""

    # Group rows by table_name (supports single-table CSV and multi-table master datamart_attributes.csv)
    tables_data: Dict[str, Tuple[str, List[Tuple[int, Dict[str, str]]]]] = {}

    default_table_name = Path(file_name).stem.replace("DTM_", "").split(".")[0]

    for line_no, r in data_rows:
        t_name = get_cell(r, tbl_idx) or default_table_name
        e_name = get_cell(r, ent_idx)
        row_dict = {
            "datamart_column": get_cell(r, col_idx),
            "datamart_attribute": get_cell(r, attr_idx),
            "key": get_cell(r, key_idx),
            "etl_logic": get_cell(r, etl_idx),
            "description": get_cell(r, desc_idx),
            "atomic_column": get_cell(r, atm_col_idx),
        }
        if t_name not in tables_data:
            tables_data[t_name] = (e_name, [])
        tables_data[t_name][1].append((line_no, row_dict))

    violations: List[ColumnViolation] = []
    for t_name, (e_name, rows_list) in tables_data.items():
        audit_res = audit_table_rows(
            table_name=t_name,
            entity_name=e_name,
            file_path=file_name,
            rows=rows_list,
        )
        violations.extend(audit_res.violations)

    return violations


def audit_file(file_path: str | Path) -> List[ColumnViolation]:
    """Audits a single CSV file on disk."""
    path = Path(file_path).resolve()
    if not path.is_file():
        return []
    raw_bytes = path.read_bytes()
    return audit_csv_content(raw_bytes, file_name=str(path))


def audit_directory(dir_path: str | Path, module_filter: Optional[str] = None) -> CheckerSummary:
    """Audits an entire LLD directory or module directory."""
    path = Path(dir_path).resolve()
    summary = CheckerSummary()

    if not path.exists():
        return summary

    csv_files: List[Path] = []
    if path.is_file():
        csv_files = [path]
    else:
        # Gather all csv files recursively
        for f in sorted(path.rglob("*.csv")):
            # Skip detail mapping files and temporary files
            if "detail_mapping" in f.name.lower() or f.name.startswith("."):
                continue
            csv_files.append(f)

    summary.scanned_files_count = len(csv_files)
    audited_files: Set[Path] = set()

    for f in csv_files:
        raw_bytes = f.read_bytes()
        raw_text = decode_bytes(raw_bytes)
        header, data_rows = parse_csv_rows(raw_text)
        if not header or not data_rows:
            continue

        header_map = {name.lower().strip(): idx for idx, name in enumerate(header) if name}

        def get_col_idx(aliases: List[str]) -> Optional[int]:
            for alias in aliases:
                if alias.lower() in header_map:
                    return header_map[alias.lower()]
            return None

        tbl_idx = get_col_idx(["datamart_table", "table_name", "table", "bảng"])
        ent_idx = get_col_idx(["datamart_entity", "entity_name", "entity"])
        col_idx = get_col_idx(["datamart_column", "column_name", "physical_name", "cột", "column"])
        attr_idx = get_col_idx(["datamart_attribute", "attribute_name", "logical_name", "thuộc tính"])
        key_idx = get_col_idx(["key", "khóa", "column_role"])
        etl_idx = get_col_idx(["etl_logic", "logic_etl", "etl", "logic"])
        desc_idx = get_col_idx(["description", "mô tả", "ghi chú"])
        atm_col_idx = get_col_idx(["atomic_column", "source_column"])

        def get_cell(row: List[str], idx: Optional[int]) -> str:
            if idx is not None and len(row) > idx:
                return row[idx].strip()
            return ""

        # Determine module name from directory structure
        mod_name = "Common"
        if f.parent.name in ("GSDC", "GSTT", "NDTNN", "NHNCK", "PTTT", "QLCB", "QLKD", "TKNB", "TT", "Common"):
            mod_name = f.parent.name
        elif "lld" in [p.name for p in f.parents]:
            mod_name = f.parent.name

        if module_filter and module_filter.upper() != "ALL" and strip_accents(mod_name).upper() != strip_accents(module_filter).upper():
            # If scanning datamart_attributes.csv at root, we can still process matching tables
            if f.name.lower() != "datamart_attributes.csv":
                continue

        tables_data: Dict[str, Tuple[str, List[Tuple[int, Dict[str, str]]]]] = {}
        default_table_name = f.stem.replace("DTM_", "").split(".")[0]

        for line_no, r in data_rows:
            t_name = get_cell(r, tbl_idx) or default_table_name
            if f.name.lower() == "datamart_attributes.csv" and module_filter and module_filter.upper() != "ALL":
                mod_lower = strip_accents(module_filter).lower()
                tbl_lower = t_name.lower()
                if not (
                    tbl_lower.startswith(f"fct_{mod_lower}_")
                    or f"_{mod_lower}_" in tbl_lower
                    or tbl_lower.startswith(f"dim_{mod_lower}_")
                    or (mod_lower == "gsdc" and ("public_company" in tbl_lower or "corporate" in tbl_lower or "listing" in tbl_lower))
                ):
                    continue
            e_name = get_cell(r, ent_idx)
            row_dict = {
                "datamart_column": get_cell(r, col_idx),
                "datamart_attribute": get_cell(r, attr_idx),
                "key": get_cell(r, key_idx),
                "etl_logic": get_cell(r, etl_idx),
                "description": get_cell(r, desc_idx),
                "atomic_column": get_cell(r, atm_col_idx),
            }
            if t_name not in tables_data:
                tables_data[t_name] = (e_name, [])
            tables_data[t_name][1].append((line_no, row_dict))

        if tables_data:
            audited_files.add(f)

        for t_name, (e_name, rows_list) in tables_data.items():
            audit_res = audit_table_rows(
                table_name=t_name,
                entity_name=e_name,
                file_path=str(f),
                rows=rows_list,
            )
            summary.scanned_tables_count += 1
            if audit_res.is_fact:
                summary.fact_tables_count += 1
                if audit_res.is_clean:
                    summary.clean_fact_tables_count += 1
                else:
                    summary.violating_fact_tables_count += 1
            else:
                summary.dim_tables_count += 1

            if audit_res.violations:
                summary.total_violations_count += len(audit_res.violations)

            mod_key = module_filter if (f.name.lower() == "datamart_attributes.csv" and module_filter and module_filter.upper() != "ALL") else mod_name
            if mod_key not in summary.results_by_module:
                summary.results_by_module[mod_key] = []
            summary.results_by_module[mod_key].append(audit_res)

    if module_filter and module_filter.upper() != "ALL":
        summary.scanned_files_count = len(audited_files)

    return summary


class DatamartDateFKChecker:
    """High-level checker engine managing workspace discovery and auditing."""

    def __init__(self, root_dir: Optional[str | Path] = None):
        if root_dir:
            self.root_dir = Path(root_dir).resolve()
        else:
            curr = Path.cwd().resolve()
            if (curr / "Datamart" / "lld").exists():
                self.root_dir = curr
            elif (curr / "ubck_atomic_design" / "Datamart" / "lld").exists():
                self.root_dir = curr / "ubck_atomic_design"
            elif (curr.parent / "Datamart" / "lld").exists():
                self.root_dir = curr.parent
            else:
                self.root_dir = curr

        self.lld_dir = self.root_dir / "Datamart" / "lld"

    def scan_module(self, module_name: str) -> CheckerSummary:
        """Scan a specific module directory."""
        mod = module_name.strip()
        if mod.lower() == "all":
            return self.scan_all()

        mod_dir = self.lld_dir / mod
        if not mod_dir.is_dir():
            ascii_mod = strip_accents(mod)
            if (self.lld_dir / ascii_mod).is_dir():
                mod_dir = self.lld_dir / ascii_mod
                mod = ascii_mod

        if mod_dir.is_dir():
            return audit_directory(mod_dir, module_filter=mod)

        # Fallback to scanning entire lld filtered by module
        return audit_directory(self.lld_dir, module_filter=mod)

    def scan_path(self, target_path: str | Path) -> CheckerSummary:
        """Scan a specific target path (file or directory)."""
        p = Path(target_path).resolve()
        return audit_directory(p)

    def scan_all(self) -> CheckerSummary:
        """Scan all LLD directories across all modules."""
        return audit_directory(self.lld_dir)


def generate_markdown_report(summary: CheckerSummary, scope_desc: str = "All Modules") -> str:
    """Formats CheckerSummary into a polished Markdown report."""
    s = summary.to_dict()["summary"]
    status_icon = "PASS" if s["total_violations"] == 0 else "FAIL"

    lines = [
        f"# Datamart Role-Playing Date FK Validation Report",
        f"",
        f"- **Audit Scope**: {scope_desc}",
        f"- **Validation Status**: **{status_icon}** ({s['total_violations']} violations found)",
        f"- **Total CSV Files Scanned**: {s['total_files']}",
        f"- **Total Tables Inspected**: {s['total_tables']}",
        f"- **Fact Tables**: {s['total_fact_tables']} (Clean: {s['clean_fact_tables']}, Violating: {s['violating_fact_tables']})",
        f"- **Dimension / Other Tables**: {s['total_dim_tables']}",
        f"",
        f"---",
        f"",
        f"## 1. Executive Summary",
        f"",
        f"| Metric | Count | Status |",
        f"|---|---|---|",
        f"| Scanned Files | {s['total_files']} | OK |",
        f"| Fact Tables | {s['total_fact_tables']} | - |",
        f"| Clean Fact Tables | {s['clean_fact_tables']} | OK |",
        f"| Violating Fact Tables | {s['violating_fact_tables']} | {'FAIL' if s['violating_fact_tables'] > 0 else 'PASS'} |",
        f"| Total Violations | {s['total_violations']} | {'FAIL' if s['total_violations'] > 0 else 'PASS'} |",
        f"",
    ]

    if not summary.all_violations:
        lines.extend([
            "## 2. Violation Registry",
            "",
            "No Date FK role-playing violations detected. All Fact tables adhere to Ralph Kimball dimensional modeling standards.",
            "",
        ])
    else:
        lines.extend([
            "## 2. Violation Registry (Action Required)",
            "",
            "The following Fact tables violate the Role-Playing Date Dimension convention by using `cdr_dt_dim_id`, `calendar_dt_dim_id`, or omitting `snpst_dt_dim_id` on snapshot facts.",
            "",
            "| # | Module | Table Name | Line | Current Physical | Current Logical | Recommended Physical | Recommended Logical | Issue Code | Severity |",
            "|---|---|---|---|---|---|---|---|---|---|",
        ])

        for idx, v in enumerate(summary.all_violations, start=1):
            p = Path(v.file_path)
            mod = p.parent.name if p.parent.name != "lld" else "master"
            lines.append(
                f"| {idx} | `{mod}` | `{v.table_name}` | {v.line_number} | `{v.column_name}` | `{v.attribute_name}` | **`{v.suggested_column}`** | **`{v.suggested_attribute}`** | `{v.issue_code}` | `{v.severity.value}` |"
            )

        lines.extend([
            "",
            "---",
            "",
            "## 3. Remediation Protocol (Call `datamart-lld-design`)",
            "",
            "To remediate these violations:",
            "1. For Snapshot Facts (`_snpst`): Rename physical column to `snpst_dt_dim_id` and logical attribute to `Snapshot Date Dimension Id`.",
            "2. For Intraday/Trading Facts: Rename physical column to `trade_dt_dim_id` and logical attribute to `Trade Date Dimension Id`.",
            "3. For Inspection/Decision Facts (Module TT): Rename physical column to `decision_dt_dim_id` and logical attribute to `Decision Date Dimension Id`.",
            "4. Synchronize `datamart_attributes.csv`, module `DTM_{MODULE}_Detail_Mapping.csv`, and `datamart_model.yaml`.",
        ])

    return "\n".join(lines)


def print_console_report(summary: CheckerSummary, scope_desc: str = "All Modules") -> None:
    """Prints formatted summary and violation tables to console."""
    s = summary.to_dict()["summary"]
    status_str = "[PASS] ALL CLEAN" if s["total_violations"] == 0 else f"[FAIL] {s['total_violations']} VIOLATION(S) DETECTED"

    print("=" * 80)
    print(f" DATAMART DATE FK ROLE-PLAYING VALIDATOR — {status_str}")
    print("=" * 80)
    print(f"Scope: {scope_desc}")
    print(f"Files Scanned: {s['total_files']:<6} | Total Tables: {s['total_tables']:<6}")
    print(f"Fact Tables:   {s['total_fact_tables']:<6} | Clean Facts:  {s['clean_fact_tables']:<6} | Violating: {s['violating_fact_tables']:<6}")
    print(f"Dim Tables:    {s['total_dim_tables']:<6} | Violations:   {s['total_violations']:<6}")
    print("-" * 80)

    if not summary.all_violations:
        print("[SUCCESS] Zero violations detected! All Fact tables comply with Role-Playing Date standards.")
        print("          Dimension table 'cdr_dt_dim' verified safe with 0 false positives.")
        print("=" * 80)
        return

    print(f"{'#':<3} | {'Table':<38} | {'Current Col':<18} | {'Suggested Col':<18}")
    print("-" * 80)
    for idx, v in enumerate(summary.all_violations, start=1):
        print(f"{idx:<3} | {v.table_name:<38} | {v.column_name:<18} | {v.suggested_column:<18}")
    print("=" * 80)


def main() -> None:
    """CLI entrypoint."""
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

    parser = argparse.ArgumentParser(
        description="Datamart Date FK Role-Playing Validator — Kimball standards validator for Date FKs on Fact tables"
    )
    parser.add_argument(
        "-m", "--module",
        type=str,
        default="all",
        help="Module to audit (e.g. GSTT, QLKD, TT, GSDC, or 'all')",
    )
    parser.add_argument(
        "-p", "--path",
        type=str,
        default=None,
        help="Path to specific CSV file or directory to audit",
    )
    parser.add_argument(
        "--root",
        type=str,
        default=None,
        help="Root directory of repository (auto-detected if omitted)",
    )
    parser.add_argument(
        "-o", "--output",
        type=str,
        default=None,
        help="Output Markdown report file path",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output JSON format instead of console table",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Exit with code 1 if any violations are detected, 0 if clean",
    )
    parser.add_argument(
        "--warn-only",
        action="store_true",
        help="Exit with code 0 even if violations are found",
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Verbose console logging",
    )

    args = parser.parse_args()

    checker = DatamartDateFKChecker(root_dir=args.root)

    scope_desc = "All Modules"
    if args.path:
        target_p = Path(args.path).resolve()
        if not target_p.exists():
            print(f"Error: Target path '{args.path}' does not exist.", file=sys.stderr)
            sys.exit(2)
        summary = checker.scan_path(args.path)
        scope_desc = f"Path: {args.path}"
    elif args.module:
        target_mod = args.module.strip()
        if target_mod.lower() != "all":
            ascii_mod = strip_accents(target_mod)
            has_mod_dir = (checker.lld_dir / target_mod).is_dir() or (checker.lld_dir / ascii_mod).is_dir()
            if not has_mod_dir:
                mod_found = False
                if checker.lld_dir.exists():
                    for f in checker.lld_dir.glob("*.csv"):
                        if target_mod.upper() in f.name.upper() or ascii_mod.upper() in f.name.upper():
                            mod_found = True
                            break
                if not mod_found:
                    print(f"Error: No LLD files found for module '{target_mod}'. Expected Datamart/lld/{target_mod}/ or matching CSV file.", file=sys.stderr)
                    sys.exit(2)
        summary = checker.scan_module(args.module)
        scope_desc = f"Module: {args.module}"
    else:
        summary = checker.scan_all()

    if args.json:
        out_json = json.dumps(summary.to_dict(), ensure_ascii=False, indent=2)
        if args.output:
            out_p = Path(args.output).resolve()
            out_p.parent.mkdir(parents=True, exist_ok=True)
            out_p.write_text(out_json, encoding="utf-8")
            if args.verbose:
                print(f"JSON output written to {out_p}")
        else:
            print(out_json)
    else:
        if args.output:
            md_rep = generate_markdown_report(summary, scope_desc=scope_desc)
            out_p = Path(args.output).resolve()
            out_p.parent.mkdir(parents=True, exist_ok=True)
            out_p.write_text(md_rep, encoding="utf-8")
            print(f"Markdown report written to: {out_p}")
        else:
            print_console_report(summary, scope_desc=scope_desc)

    total_violations = summary.total_violations_count

    # Strict mode exit code handling:
    # Exit 1 if violations found and (--strict is set, or strict is enforced without --warn-only)
    if total_violations > 0:
        if args.strict and not args.warn_only:
            sys.exit(1)

    sys.exit(0)


if __name__ == "__main__":
    main()
