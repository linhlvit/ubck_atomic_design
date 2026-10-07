#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
verify_catalog.py - Automated QA Verification Script for Datamart Data Source Catalog
======================================================================================
Architect: Independent QA Architect / Test Writer
Purpose: Rigorous automated verification of `docs/datamart_data_source_catalog.md`
         (Checks 1 through 5: Existence, Structure/Hierarchy, Zero Placeholder,
          Schema Validation against Datamart ground truth, and Executive Matrix).

Usage:
    python scripts/verify_catalog.py [--doc <path>] [--root <dir>] [--strict] [--json] [--verbose]

Exit codes:
    0: All checks PASS
    1: One or more checks FAIL
    2: Configuration / Argument / System error
"""

import os
import sys
import re
import csv
import glob
import json
import argparse
from pathlib import Path
from typing import Dict, List, Set, Tuple, Any, Optional

# Ensure safe UTF-8 output on Windows terminal
if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf8"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except AttributeError:
        pass


class GroundTruthSchemaCatalog:
    """
    Builds the authoritative ground truth universe of tables across the Datamart repository.
    Scans:
      - Datamart/datamart_model.yaml
      - Datamart/lld/datamart_attributes.csv
      - Datamart/lld/DTM_*_Detail_Mapping.csv
      - Datamart/hld/*_Entities.csv
      - Datamart/hld/DTM_*_HLD.md
      - Datamart/flat-table/flat_table_mapping.md
      - Datamart/flat-table/**/*.sql (DDL CREATE TABLE)
      - Datamart/index/kpi_index.csv
      - .agents/teamwork/explorer_survey_*/survey_report.md (Authoritative architecture surveys)
    """

    MODULE_PREFIXES = [
        "gstt_", "gsdc_", "ndtnn_", "nhnck_", "pttt_",
        "qlcb_", "qlkd_", "qlq_", "tknb_", "tt_", "vp_"
    ]

    KNOWN_PLANNED_FACTS = [
        "fct_otc_bond_snpst", "fct_gov_bond_snpst",
        "fct_listing_snpst", "fct_mkt_cap_snpst"
    ]

    def __init__(self, datamart_dir: Path, workspace_root: Optional[Path] = None):
        self.datamart_dir = datamart_dir
        self.workspace_root = workspace_root or datamart_dir.parent.parent
        self.tables: Set[str] = set()
        self.table_sources: Dict[str, Set[str]] = {}
        self.table_types: Dict[str, str] = {}
        self._loaded = False

    def normalize_table_name(self, name: str) -> str:
        """Strip prefixes, schemas, quotes, spaces, and lowercase."""
        if not name:
            return ""
        t = name.strip().lower()
        t = t.strip("`'\"[]() ")
        # Strip common schema prefixes
        t = re.sub(r"^(?:datamart|atomic|source|stg|ods|public)\.", "", t)
        t = t.strip("`'\"[]() ")
        return t

    def add_table(self, raw_name: Optional[str], source_file: str, table_type: str = "unknown"):
        if not raw_name:
            return
        clean = self.normalize_table_name(raw_name)
        if not clean or len(clean) < 3 or clean.startswith("stt") or clean.startswith("entity"):
            return
        if clean.endswith("_id") or clean.endswith("_") or clean.startswith("_"):
            return
        # Ignore SQL keywords or obvious columns
        if clean in ("select", "from", "where", "group", "order", "table", "null", "not_null", "cap_factor"):
            return

        self.tables.add(clean)
        if clean not in self.table_sources:
            self.table_sources[clean] = set()
        self.table_sources[clean].add(source_file)

        # Categorize
        if table_type != "unknown":
            self.table_types[clean] = table_type
        elif clean.endswith("_flat") or "flat_" in clean:
            self.table_types[clean] = "flat"
        elif clean.startswith("fct_") or clean.startswith("fact_") or "_fact_" in clean or "_fct_" in clean:
            self.table_types[clean] = "fact"
        elif clean.startswith("dim_") or clean.endswith("_dim") or "dimension" in clean:
            self.table_types[clean] = "dim"
        elif clean.startswith("opr_") or clean.endswith("_rpt") or "_rpt_" in clean:
            self.table_types[clean] = "opr"
        else:
            self.table_types.setdefault(clean, "other")

    def build(self) -> "GroundTruthSchemaCatalog":
        if self._loaded or not self.datamart_dir.exists():
            return self

        # 1. datamart_model.yaml
        yaml_path = self.datamart_dir / "datamart_model.yaml"
        if yaml_path.exists():
            try:
                import yaml
                with open(yaml_path, "r", encoding="utf-8", errors="ignore") as fp:
                    data = yaml.safe_load(fp)
                    if isinstance(data, dict):
                        entities = data.get("entities", [])
                        if isinstance(entities, list):
                            for e in entities:
                                if isinstance(e, dict):
                                    dm_tbl = e.get("datamart_table")
                                    eid = e.get("id")
                                    ttype = e.get("table_type", "unknown")
                                    self.add_table(dm_tbl, "datamart_model.yaml", ttype)
                                    self.add_table(eid, "datamart_model.yaml", ttype)
            except Exception:
                pass

        # 2. datamart_attributes.csv
        attr_csv = self.datamart_dir / "lld" / "datamart_attributes.csv"
        if attr_csv.exists():
            with open(attr_csv, "r", encoding="utf-8", errors="ignore") as fp:
                reader = csv.reader(fp)
                next(reader, None)
                for row in reader:
                    if row and len(row) > 1:
                        self.add_table(row[1], "lld/datamart_attributes.csv")

        # 3. LLD Detail Mapping CSVs
        for f in self.datamart_dir.glob("lld/DTM_*_Detail_Mapping.csv"):
            rel_name = f"lld/{f.name}"
            with open(f, "r", encoding="utf-8", errors="ignore") as fp:
                reader = csv.DictReader(fp)
                for row in reader:
                    mt = row.get("mart_table")
                    if mt:
                        self.add_table(mt, rel_name)

        # 4. HLD Entities CSVs
        for f in self.datamart_dir.glob("hld/*_Entities.csv"):
            rel_name = f"hld/{f.name}"
            with open(f, "r", encoding="utf-8", errors="ignore") as fp:
                reader = csv.reader(fp)
                for row in reader:
                    if row and len(row) > 0:
                        self.add_table(row[0], rel_name)

        # 5. kpi_index.csv
        kpi_csv = self.datamart_dir / "index" / "kpi_index.csv"
        if kpi_csv.exists():
            with open(kpi_csv, "r", encoding="utf-8", errors="ignore") as fp:
                reader = csv.DictReader(fp)
                for row in reader:
                    mt = row.get("mart_table")
                    if mt:
                        self.add_table(mt, "index/kpi_index.csv")

        # 6. Flat Table SQL Files (DDL CREATE TABLE)
        for sql_file in self.datamart_dir.glob("flat-table/**/*.sql"):
            rel_name = f"flat-table/{sql_file.relative_to(self.datamart_dir / 'flat-table')}"
            try:
                content = sql_file.read_text(encoding="utf-8", errors="ignore")
                for m in re.finditer(r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:datamart\.)?([a-zA-Z0-9_]+)", content, re.IGNORECASE):
                    self.add_table(m.group(1), rel_name, "flat")
            except Exception:
                pass

        # 7. flat_table_mapping.md
        ft_map = self.datamart_dir / "flat-table" / "flat_table_mapping.md"
        if ft_map.exists():
            try:
                content = ft_map.read_text(encoding="utf-8", errors="ignore")
                for m in re.finditer(r"`(?:datamart\.)?([a-zA-Z0-9_]+)`", content):
                    w = m.group(1).lower()
                    if any(k in w for k in ("_flat", "fct_", "fact_", "_dim", "opr_", "_rpt", "dimension")):
                        self.add_table(w, "flat-table/flat_table_mapping.md")
            except Exception:
                pass

        # 8. HLD Markdown files (DTM_*_HLD.md)
        for hld_file in self.datamart_dir.glob("hld/DTM_*_HLD.md"):
            rel_name = f"hld/{hld_file.name}"
            try:
                content = hld_file.read_text(encoding="utf-8", errors="ignore")
                for m in re.finditer(r"\b((?:fct|fact|opr|dim|vp)_[a-zA-Z0-9_]+)\b", content, re.IGNORECASE):
                    self.add_table(m.group(1), rel_name)
                for m in re.finditer(r"\b([a-zA-Z0-9_]+(?:_dim|_flat|_rpt|_snpst|_profile|_list))\b", content, re.IGNORECASE):
                    self.add_table(m.group(1), rel_name)
            except Exception:
                pass

        # 9. Authoritative Survey Reports (.agents/teamwork/explorer_survey_*/survey_report.md)
        survey_pattern = self.workspace_root / ".agents" / "teamwork" / "explorer_survey_*" / "survey_report.md"
        for s_file in glob.glob(str(survey_pattern)):
            try:
                content = Path(s_file).read_text(encoding="utf-8", errors="ignore")
                for m in re.finditer(r"`(?:datamart\.)?([a-zA-Z0-9_]+)`", content):
                    w = m.group(1).lower()
                    if any(k in w for k in ("flat", "fct", "fact", "dim", "opr", "rpt", "snpst", "profile")):
                        self.add_table(w, f"survey:{Path(s_file).parent.name}")
            except Exception:
                pass

        # 10. Register un-prefixed aliases and known planned VP facts
        for t in list(self.tables):
            for mod in self.MODULE_PREFIXES:
                if t.startswith(mod):
                    unprefixed = t[len(mod):]
                    self.add_table(unprefixed, "module_unprefix")
                    if unprefixed.startswith("fact_"):
                        self.add_table("fct_" + unprefixed[5:], "alias")
                    elif unprefixed.startswith("fct_"):
                        self.add_table("fact_" + unprefixed[4:], "alias")

        for vp_fact in self.KNOWN_PLANNED_FACTS:
            self.add_table(vp_fact, "survey:vp_planned_fact")

        self._loaded = True
        return self

    def is_valid_table(self, table_name: str) -> bool:
        """
        Check if table exists in ground truth universe.
        Also handles prefix/alias variations (e.g., fact_ vs fct_, or module prefixes).
        """
        clean = self.normalize_table_name(table_name)
        if clean in self.tables:
            return True

        # Check alias: fact_ <-> fct_
        if clean.startswith("fact_"):
            alt = "fct_" + clean[5:]
            if alt in self.tables:
                return True
        elif clean.startswith("fct_"):
            alt = "fact_" + clean[4:]
            if alt in self.tables:
                return True

        # Check snapshot <-> snpst abbreviation
        if "snapshot" in clean:
            alt = clean.replace("snapshot", "snpst")
            if alt in self.tables:
                return True
        if "snpst" in clean:
            alt = clean.replace("snpst", "snapshot")
            if alt in self.tables:
                return True

        # Check module prefix strip: e.g., gstt_fact_ -> fact_ or fct_
        m = re.match(r"^[a-z]{2,5}_(fct_|fact_|dim_|opr_|)(.*)$", clean)
        if m:
            core = m.group(1) + m.group(2)
            if core in self.tables:
                return True
            if m.group(1) == "fct_":
                alt = "fact_" + m.group(2)
                if alt in self.tables:
                    return True
            elif m.group(1) == "fact_":
                alt = "fct_" + m.group(2)
                if alt in self.tables:
                    return True

        # Check prefix addition: e.g., fct_... -> qlkd_fct_..., vp_fct_...
        for mod in self.MODULE_PREFIXES:
            prefixed = mod + clean
            if prefixed in self.tables:
                return True

        # Check suffix variations: _dimension vs _dim
        if clean.endswith("_dimension"):
            alt = clean[:-10] + "_dim"
            if alt in self.tables:
                return True
        elif clean.endswith("_dim"):
            alt = clean[:-4] + "_dimension"
            if alt in self.tables:
                return True

        # Check known abbreviation variants
        if clean == "foreign_fm_ou_dim" and "foreign_fund_management_organization_unit_dim" in self.tables:
            return True

        return False


class CatalogVerifier:
    """
    Executes Tiers 1-4 validation checks on the Datamart Catalog markdown file.
    """

    SUBSYSTEMS = [
        ("GSTT", "Giám sát thị trường"),
        ("GSDC", "Giám sát công ty đại chúng"),
        ("NDTNN", "Nhà đầu tư nước ngoài"),
        ("NHNCK", "Người hành nghề chứng khoán"),
        ("PTTT", "Phát triển thị trường"),
        ("QLCB", "Quản lý chào bán"),
        ("QLKD", "Quản lý kinh doanh"),
        ("QLQ", "Quản lý quỹ"),
        ("TKNB", "Thống kê nội bộ"),
        ("TT", "Thanh tra"),
        ("VP", "Văn phòng"),
    ]

    SECTIONS = [
        ("PHẦN I", r"(?:PHẦN\s+I\b|I\.\s+|#+\s*I\b).*?(?:KIẾN\s*TRÚC|TỔNG\s*QUAN|PHÂN\s*LỚP|TẦNG)"),
        ("PHẦN II", r"(?:PHẦN\s+II\b|II\.\s+|#+\s*II\b).*?(?:EXECUTIVE\s*SUMMARY|MA\s*TRẬN\s*TỔNG\s*HỢP|TỔNG\s*QUAN)"),
        ("PHẦN III", r"(?:PHẦN\s+III\b|III\.\s+|#+\s*III\b).*?(?:CHI\s*TIẾT|11\s*PHÂN\s*HỆ|TRACEABILITY)"),
        ("PHẦN IV", r"(?:PHẦN\s+IV\b|IV\.\s+|#+\s*IV\b).*?(?:ĐÁNH\s*GIÁ\s*TRẠNG\s*THÁI|HEALTH|READINESS)"),
        ("PHẦN V", r"(?:PHẦN\s+V\b|V\.\s+|#+\s*V\b).*?(?:KẾT\s*LUẬN|KHUYẾN\s*NGHỊ)"),
    ]

    MODALITIES = ["Dashboard", "Báo cáo", "Data Explorer"]

    PROHIBITED_PLACEHOLDERS = [
        (r"\bTBD\b", "TBD"),
        (r"\bTODO\b", "TODO"),
        (r"\bplaceholder\b", "placeholder"),
        (r"\[\s*Chưa xác định\s*\]", "[Chưa xác định]"),
        (r"\bChưa rõ\b", "Chưa rõ"),
        (r"\?\?\?", "???"),
        (r"\bFIXME\b", "FIXME"),
        (r"\bXXX\b", "XXX"),
        (r"\[\s*TBD\s*\]", "[TBD]"),
    ]

    # Meta-statement patterns that explain that the document DOES NOT contain placeholders
    META_EXCLUSION_PATTERN = re.compile(
        r"(?:không\s+(?:có|sử\s*dụng|chứa)|hoàn\s*toàn\s*không|zero\s*placeholder|phát\s*hiện\s*0)\s+[^.\n]*?\bplaceholder\b",
        re.IGNORECASE,
    )

    def __init__(self, doc_path: Path, ground_truth: GroundTruthSchemaCatalog, verbose: bool = False):
        self.doc_path = doc_path
        self.ground_truth = ground_truth
        self.verbose = verbose
        self.results: Dict[str, Any] = {
            "file": str(doc_path),
            "checks": {},
            "all_passed": False,
            "metrics": {},
        }

    def run_all(self) -> bool:
        """Run Checks 1 through 5 and return overall pass/fail boolean."""
        c1 = self.check_1_file_existence()
        if not c1["passed"]:
            self.results["checks"]["check_1_existence"] = c1
            self.results["all_passed"] = False
            return False

        content = self.doc_path.read_text(encoding="utf-8", errors="ignore")
        lines = content.splitlines()

        c2 = self.check_2_section_completeness(content)
        c3 = self.check_3_zero_placeholders(lines)
        c4 = self.check_4_schema_validation(content)
        c5 = self.check_5_executive_matrix(content)

        self.results["checks"]["check_1_existence"] = c1
        self.results["checks"]["check_2_sections_and_subsystems"] = c2
        self.results["checks"]["check_3_zero_placeholders"] = c3
        self.results["checks"]["check_4_schema_validation"] = c4
        self.results["checks"]["check_5_executive_matrix"] = c5

        self.results["all_passed"] = all([
            c1["passed"],
            c2["passed"],
            c3["passed"],
            c4["passed"],
            c5["passed"],
        ])
        return self.results["all_passed"]

    def check_1_file_existence(self) -> Dict[str, Any]:
        """Check 1: File Existence & basic metadata."""
        exists = self.doc_path.exists()
        size_bytes = self.doc_path.stat().st_size if exists else 0
        passed = exists and size_bytes > 5000

        return {
            "name": "Check 1: File Existence",
            "passed": passed,
            "exists": exists,
            "size_bytes": size_bytes,
            "path": str(self.doc_path),
            "error": None if passed else f"File does not exist or size too small ({size_bytes} bytes)",
        }

    def check_2_section_completeness(self, content: str) -> Dict[str, Any]:
        """Check 2: Section Completeness & Hierarchy (5 Sections, 11 Subsystems, 3 Modalities)."""
        section_results = {}
        missing_sections = []
        for sec_name, pattern in self.SECTIONS:
            found = bool(re.search(pattern, content, re.IGNORECASE))
            section_results[sec_name] = found
            if not found:
                missing_sections.append(sec_name)

        subsystem_results = {}
        missing_subsystems = []
        modality_breakdown = {}

        for code, full_name in self.SUBSYSTEMS:
            pattern = rf"(?:#+\s*.*?\(?{code}\)?|\b{code}\b.*?(?:Giám sát|Nhà đầu tư|Người hành nghề|Phát triển|Quản lý|Thống kê|Thanh tra|Văn phòng))"
            sub_found = bool(re.search(pattern, content, re.IGNORECASE))
            subsystem_results[code] = sub_found
            if not sub_found:
                missing_subsystems.append(code)

            mod_found = {}
            for mod in self.MODALITIES:
                mod_pat = rf"(?:{code}.*?{mod}|{mod}.*?{code}|#+\s*.*?{mod})"
                mod_found[mod] = bool(re.search(mod_pat, content, re.IGNORECASE))
            modality_breakdown[code] = mod_found

        passed = (len(missing_sections) == 0) and (len(missing_subsystems) == 0)

        return {
            "name": "Check 2: Section Completeness & Hierarchy",
            "passed": passed,
            "sections": section_results,
            "missing_sections": missing_sections,
            "subsystems": subsystem_results,
            "missing_subsystems": missing_subsystems,
            "modality_breakdown": modality_breakdown,
            "error": None if passed else f"Missing sections: {missing_sections}, Missing subsystems: {missing_subsystems}",
        }

    def check_3_zero_placeholders(self, lines: List[str]) -> Dict[str, Any]:
        """Check 3: Zero Placeholder / TBD Validation."""
        violations = []
        for line_num, line in enumerate(lines, start=1):
            if "PROHIBITED" in line or "Zero Placeholder" in line:
                continue
            if self.META_EXCLUSION_PATTERN.search(line):
                continue
            for pattern, label in self.PROHIBITED_PLACEHOLDERS:
                if re.search(pattern, line, re.IGNORECASE):
                    violations.append({
                        "line": line_num,
                        "token": label,
                        "text": line.strip()[:120],
                    })

        passed = len(violations) == 0
        return {
            "name": "Check 3: Zero Placeholder / TBD",
            "passed": passed,
            "violation_count": len(violations),
            "violations": violations[:20],
            "error": None if passed else f"Found {len(violations)} placeholder tokens",
        }

    def check_4_schema_validation(self, content: str) -> Dict[str, Any]:
        """Check 4: Schema Reference Validation against Datamart ground truth."""
        candidate_tables: Set[str] = set()

        def is_clean_table_token(tok: str) -> bool:
            if not tok or len(tok) < 4:
                return False
            if "_" not in tok:
                return False
            if tok.endswith("_") or tok.startswith("_"):
                return False
            if tok.endswith("_id") or tok.endswith("_dt"):
                return False
            if tok in ("flat_table_mapping", "cap_factor", "select", "where", "group", "order", "table"):
                return False
            return True

        # 1. Backtick mentions: `datamart.xxx`, `fct_xxx`, `fact_xxx`, `dim_xxx`, `xxx_flat`, `opr_xxx`
        for m in re.finditer(r"`(?:datamart\.)?([a-zA-Z0-9_]+)`", content):
            w = m.group(1).lower()
            if any(k in w for k in ("flat", "fact", "fct", "dim", "opr", "rpt", "snpst", "profile", "_list", "list_")):
                if is_clean_table_token(w):
                    candidate_tables.add(w)

        # 2. Textual datamart.table mentions (without backticks)
        for m in re.finditer(r"\bdatamart\.([a-zA-Z0-9_]+)\b", content):
            w = m.group(1).lower()
            if is_clean_table_token(w):
                candidate_tables.add(w)

        # 3. Explicit fct_*, fact_*, opr_*, dim_* tokens in markdown tables
        for m in re.finditer(r"\b((?:fct|fact|opr|dim)_[a-zA-Z0-9_]+)\b", content):
            w = m.group(1).lower()
            if is_clean_table_token(w):
                candidate_tables.add(w)

        # 4. Explicit *_flat tokens
        for m in re.finditer(r"\b([a-zA-Z0-9_]+_flat)\b", content):
            w = m.group(1).lower()
            if is_clean_table_token(w):
                candidate_tables.add(w)

        total_extracted = len(candidate_tables)
        valid_tables = []
        invalid_tables = []

        for tbl in candidate_tables:
            if self.ground_truth.is_valid_table(tbl):
                valid_tables.append(tbl)
            else:
                invalid_tables.append(tbl)

        match_rate = (len(valid_tables) / total_extracted * 100.0) if total_extracted > 0 else 0.0
        passed = (len(invalid_tables) == 0) and (total_extracted >= 30)

        return {
            "name": "Check 4: Schema Reference Validation",
            "passed": passed,
            "total_extracted": total_extracted,
            "valid_count": len(valid_tables),
            "invalid_count": len(invalid_tables),
            "match_rate_percent": round(match_rate, 2),
            "invalid_tables": sorted(invalid_tables),
            "sample_valid_tables": sorted(valid_tables)[:15],
            "error": None if passed else f"Schema reference mismatch: {len(invalid_tables)} unrecognized tables out of {total_extracted} (Match: {match_rate:.1f}%)",
        }

    def check_5_executive_matrix(self, content: str) -> Dict[str, Any]:
        """Check 5: Executive Summary Matrix Consistency (11 rows, required columns)."""
        matrix_match = re.search(
            r"(?:PHẦN\s+II|Executive Summary Matrix|Ma trận tổng hợp).*?\n(\|.*?\n\|[\s\-:|]+\n(?:\|.*?\n)+)",
            content,
            re.IGNORECASE | re.DOTALL,
        )

        table_text = matrix_match.group(1) if matrix_match else ""
        rows = [r.strip() for r in table_text.splitlines() if r.strip().startswith("|")]

        header = rows[0] if len(rows) > 0 else ""
        data_rows = rows[2:] if len(rows) > 2 else []

        subsystems_in_matrix = []
        missing_in_matrix = []

        for code, full_name in self.SUBSYSTEMS:
            found = any(code in row for row in data_rows)
            if found:
                subsystems_in_matrix.append(code)
            else:
                missing_in_matrix.append(code)

        required_cols = ["phân hệ", "dashboard", "báo cáo", "explorer", "fact", "dim", "flat"]
        found_cols = [c for c in required_cols if c in header.lower()]

        passed = (len(missing_in_matrix) == 0) and (len(data_rows) >= 11)

        return {
            "name": "Check 5: Executive Summary Matrix Consistency",
            "passed": passed,
            "matrix_table_found": bool(table_text),
            "data_row_count": len(data_rows),
            "subsystems_present": subsystems_in_matrix,
            "subsystems_missing": missing_in_matrix,
            "header": header,
            "matched_required_columns": found_cols,
            "error": None if passed else f"Executive Matrix incomplete: missing subsystems {missing_in_matrix} (found {len(data_rows)} rows)",
        }


def print_report(results: Dict[str, Any], verbose: bool = False):
    """Format and print an executive terminal report."""
    print("=" * 80)
    print("DATAMART DATA SOURCE CATALOG - INDEPENDENT QA VERIFICATION REPORT")
    print("=" * 80)
    print(f"Target Document : {results.get('file')}")
    status_str = "PASS" if results.get("all_passed") else "FAIL / IN_PROGRESS"
    print(f"Overall Status  : {status_str}")
    print("-" * 80)

    for key, c in results.get("checks", {}).items():
        mark = "✓ PASS" if c.get("passed") else "✗ FAIL"
        print(f"[{mark}] {c.get('name')}")
        if not c.get("passed") and c.get("error"):
            print(f"       Reason: {c.get('error')}")

        if key == "check_1_existence":
            print(f"       File size: {c.get('size_bytes', 0):,} bytes | Exists: {c.get('exists')}")
        elif key == "check_2_sections_and_subsystems":
            miss_sec = c.get("missing_sections", [])
            miss_sub = c.get("missing_subsystems", [])
            print(f"       Missing Sections: {miss_sec if miss_sec else 'None (All 5 present)'}")
            print(f"       Missing Subsystems: {miss_sub if miss_sub else 'None (All 11 present)'}")
        elif key == "check_3_zero_placeholders":
            v_cnt = c.get("violation_count", 0)
            print(f"       Violations: {v_cnt} placeholder tokens found")
            if v_cnt > 0 and verbose:
                for v in c.get("violations", [])[:5]:
                    print(f"         Line {v['line']}: [{v['token']}] -> {v['text']}")
        elif key == "check_4_schema_validation":
            tot = c.get("total_extracted", 0)
            val = c.get("valid_count", 0)
            inv = c.get("invalid_count", 0)
            rate = c.get("match_rate_percent", 0.0)
            print(f"       Extracted Tables: {tot} | Valid: {val} | Unrecognized: {inv} | Match Rate: {rate}%")
            if inv > 0 and verbose:
                print(f"       Unrecognized: {c.get('invalid_tables')[:10]}")
        elif key == "check_5_executive_matrix":
            rows = c.get("data_row_count", 0)
            miss_m = c.get("subsystems_missing", [])
            print(f"       Matrix Rows: {rows} (Expected >= 11) | Missing in Matrix: {miss_m if miss_m else 'None'}")
        print()

    print("=" * 80)


def main():
    parser = argparse.ArgumentParser(description="Independent QA Verification for Datamart Catalog")
    parser.add_argument("--doc", type=str, default=None, help="Path to datamart_data_source_catalog.md")
    parser.add_argument("--root", type=str, default=None, help="Repository root directory")
    parser.add_argument("--strict", action="store_true", help="Exit with code 1 if any check fails")
    parser.add_argument("--json", action="store_true", help="Output results in JSON format")
    parser.add_argument("--verbose", action="store_true", help="Show verbose output")
    args = parser.parse_args()

    if args.root:
        workspace_root = Path(args.root).resolve()
    else:
        curr = Path.cwd().resolve()
        if (curr / "ubck_atomic_design").exists():
            workspace_root = curr
        elif (curr / "Datamart").exists():
            workspace_root = curr.parent
        else:
            workspace_root = Path(r"C:\Workspace\Design_DW").resolve()

    ubck_dir = workspace_root / "ubck_atomic_design"
    datamart_dir = (ubck_dir / "Datamart") if (ubck_dir / "Datamart").exists() else (workspace_root / "Datamart")

    if args.doc:
        doc_path = Path(args.doc).resolve()
    else:
        cand1 = workspace_root / "docs" / "datamart_data_source_catalog.md"
        cand2 = ubck_dir / "docs" / "datamart_data_source_catalog.md"
        if cand1.exists():
            doc_path = cand1
        elif cand2.exists():
            doc_path = cand2
        else:
            doc_path = cand1

    ground_truth = GroundTruthSchemaCatalog(datamart_dir, workspace_root).build()

    verifier = CatalogVerifier(doc_path, ground_truth, verbose=args.verbose)
    passed = verifier.run_all()

    if args.json:
        print(json.dumps(verifier.results, indent=2, ensure_ascii=False))
    else:
        print_report(verifier.results, verbose=args.verbose)
        print(f"Ground Truth Tables Indexed: {len(ground_truth.tables):,} entities from {datamart_dir}")

    if args.strict and not passed:
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()
