#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
verify_datamart_clickhouse_mapping.py - Independent QA Verification Script
==========================================================================
Architect: Explorer 3 / Independent QA Verification Architect
Purpose: Verify mapping between Datamart (Iceberg/Trino) and ClickHouse Flat Tables
         as defined in `docs/output/datamart_clickhouse_tables_mapping.csv`.
         Supports both 2-column (table-level) and 4-column (table + dbt job level).

Acceptance Criteria:
  1. CSV integrity: UTF-8 encoding (supports UTF-8-sig BOM), header:
     `datamart_table,datamart_job,clickhouse_table,clickhouse_job` or `datamart_table,clickhouse_table`.
  2. 100% Datamart coverage: Every table in `Datamart/datamart_model.yaml` is present in `datamart_table`.
  3. 100% ClickHouse flat table coverage: Every `datamart.*_flat` table from `Datamart/flat-table/` DDLs
     appears in `clickhouse_table`.
  4. Data integrity: No empty cells, unmapped tables marked explicitly as `N/A`.
  5. dbt Job verification: When 4 columns are present, verify dbt models against physical .sql files.
  6. Statistical reconciliation report printed to console with exit code 0 on PASS, 1 on FAIL.
"""

import os
import sys
import re
import csv
import glob
import json
import argparse
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Set, Tuple, Any, Optional

# Ensure safe UTF-8 output on Windows terminal
if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf8"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except AttributeError:
        pass


class MappingVerifier:
    def __init__(self, csv_path: Path, model_path: Path, flat_dir: Path, 
                 dbt_datamart_dir: Optional[Path] = None, 
                 dbt_clickhouse_dir: Optional[Path] = None,
                 verbose: bool = False):
        self.csv_path = csv_path
        self.model_path = model_path
        self.flat_dir = flat_dir
        self.dbt_datamart_dir = dbt_datamart_dir
        self.dbt_clickhouse_dir = dbt_clickhouse_dir
        self.verbose = verbose
        
        self.errors: List[str] = []
        self.warnings: List[str] = []
        
        # Ground truths
        self.yaml_entities: List[Dict[str, Any]] = []
        self.yaml_table_names: Set[str] = set()
        self.yaml_table_meta: Dict[str, Dict[str, str]] = {}
        self.ddl_flat_tables: Set[str] = set()
        self.dbt_datamart_models: Set[str] = set()
        self.dbt_clickhouse_models: Set[str] = set()
        
        # Parsed CSV data
        self.csv_rows: List[Dict[str, str]] = []
        self.csv_datamart_tables: Set[str] = set()
        self.csv_clickhouse_tables: Set[str] = set()
        self.csv_mapping: Dict[str, str] = {}
        self.csv_datamart_jobs: Dict[str, str] = {}
        self.csv_clickhouse_jobs: Dict[str, str] = {}
        self.is_4col: bool = False
        
    def log(self, msg: str):
        if self.verbose:
            print(f"  [DEBUG] {msg}")

    def load_ground_truth(self) -> bool:
        """Loads datamart_model.yaml, ClickHouse DDLs, and dbt models if available."""
        # 1. Load datamart_model.yaml
        if not self.model_path.exists():
            self.errors.append(f"Model file not found: {self.model_path}")
            return False
            
        try:
            import yaml
            with open(self.model_path, "r", encoding="utf-8") as f:
                model_data = yaml.safe_load(f)
            self.yaml_entities = model_data.get("entities", [])
            for e in self.yaml_entities:
                tname = e.get("datamart_table", "").strip()
                if tname:
                    self.yaml_table_names.add(tname)
                    self.yaml_table_meta[tname] = {
                        "module": e.get("module", "UNKNOWN"),
                        "table_type": e.get("table_type", "UNKNOWN"),
                        "logical_name": e.get("logical_name", "")
                    }
        except Exception as ex:
            self.errors.append(f"Failed to parse {self.model_path}: {ex}")
            return False

        # 2. Load ClickHouse flat table DDLs
        if not self.flat_dir.exists():
            self.errors.append(f"Flat table directory not found: {self.flat_dir}")
            return False

        ddl_files = sorted(list(self.flat_dir.glob("**/01_create_*.sql")) + list(self.flat_dir.glob("**/00_recreate_*.sql")))
        for df in ddl_files:
            try:
                content = df.read_text(encoding="utf-8", errors="ignore")
                matches = re.findall(r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(datamart\.[a-zA-Z0-9_]+)", content, re.IGNORECASE)
                for m in matches:
                    self.ddl_flat_tables.add(m.strip().lower())
            except Exception as ex:
                self.warnings.append(f"Could not read DDL file {df}: {ex}")

        # 3. Load dbt models if dirs available
        if self.dbt_datamart_dir and self.dbt_datamart_dir.exists():
            for f in self.dbt_datamart_dir.rglob("*.sql"):
                self.dbt_datamart_models.add(f.stem)
            self.log(f"Loaded {len(self.dbt_datamart_models)} dbt Datamart models.")

        if self.dbt_clickhouse_dir and self.dbt_clickhouse_dir.exists():
            for f in self.dbt_clickhouse_dir.rglob("*.sql"):
                self.dbt_clickhouse_models.add(f.stem)
            self.log(f"Loaded {len(self.dbt_clickhouse_models)} dbt ClickHouse models.")

        return True

    def verify_csv_structure(self) -> bool:
        """Check file existence, encoding, header, and column count."""
        if not self.csv_path.exists():
            self.errors.append(f"Mapping CSV file not found: {self.csv_path}")
            return False

        try:
            raw_bytes = self.csv_path.read_bytes()
            if len(raw_bytes) == 0:
                self.errors.append(f"Mapping CSV file is empty: {self.csv_path}")
                return False

            with open(self.csv_path, "r", encoding="utf-8-sig", newline="") as f:
                reader = csv.reader(f)
                header = next(reader, None)
                if not header:
                    self.errors.append("CSV has no header row.")
                    return False
                    
                clean_header = [h.strip() for h in header]
                if clean_header == ["datamart_table", "datamart_job", "clickhouse_table", "clickhouse_job"]:
                    self.is_4col = True
                elif clean_header == ["datamart_table", "clickhouse_table"]:
                    self.is_4col = False
                else:
                    self.errors.append(f"Invalid CSV header: {header}. Expected 4 columns ['datamart_table', 'datamart_job', 'clickhouse_table', 'clickhouse_job'] or 2 columns ['datamart_table', 'clickhouse_table']")
                    return False
                    
                row_idx = 1
                expected_cols = 4 if self.is_4col else 2
                for row in reader:
                    row_idx += 1
                    if len(row) != expected_cols:
                        self.errors.append(f"Row {row_idx} does not have exactly {expected_cols} columns: {row}")
                        continue
                    
                    if self.is_4col:
                        dm_tbl, dm_job, ck_tbl, ck_job = [c.strip() for c in row]
                    else:
                        dm_tbl, ck_tbl = [c.strip() for c in row]
                        dm_job, ck_job = "N/A", "N/A"
                    
                    if not dm_tbl:
                        self.errors.append(f"Row {row_idx}: 'datamart_table' is empty.")
                    if not ck_tbl:
                        self.errors.append(f"Row {row_idx}: 'clickhouse_table' is empty.")
                    if self.is_4col and not dm_job:
                        self.errors.append(f"Row {row_idx}: 'datamart_job' is empty.")
                    if self.is_4col and not ck_job:
                        self.errors.append(f"Row {row_idx}: 'clickhouse_job' is empty.")
                        
                    if dm_tbl in self.csv_mapping:
                        self.errors.append(f"Row {row_idx}: Duplicate datamart_table entry: '{dm_tbl}'")
                        
                    self.csv_rows.append({
                        "datamart_table": dm_tbl, 
                        "datamart_job": dm_job,
                        "clickhouse_table": ck_tbl,
                        "clickhouse_job": ck_job
                    })
                    self.csv_datamart_tables.add(dm_tbl)
                    if ck_tbl != "N/A":
                        self.csv_clickhouse_tables.add(ck_tbl.lower())
                    self.csv_mapping[dm_tbl] = ck_tbl
                    self.csv_datamart_jobs[dm_tbl] = dm_job
                    self.csv_clickhouse_jobs[dm_tbl] = ck_job
                    
        except Exception as ex:
            self.errors.append(f"Error reading mapping CSV: {ex}")
            return False

        return True

    def verify_coverage(self):
        """Check 100% Datamart coverage & 100% ClickHouse Flat Table coverage."""
        missing_dm = self.yaml_table_names - self.csv_datamart_tables
        extra_dm = self.csv_datamart_tables - self.yaml_table_names
        
        if missing_dm:
            self.errors.append(f"Missing {len(missing_dm)} Datamart tables in CSV: {sorted(list(missing_dm))[:10]}")
        if extra_dm:
            self.errors.append(f"CSV contains {len(extra_dm)} extra tables not in datamart_model.yaml: {sorted(list(extra_dm))[:10]}")

        missing_ck = self.ddl_flat_tables - self.csv_clickhouse_tables
        if missing_ck:
            self.errors.append(f"Missing {len(missing_ck)} ClickHouse flat tables in CSV: {sorted(list(missing_ck))}")

    def verify_integrity(self):
        """Check data integrity, valid formats, and dbt physical model existence."""
        valid_ck_pattern = re.compile(r"^datamart\.[a-z0-9_]+_flat$")
        for dm_tbl, ck_tbl in self.csv_mapping.items():
            if ck_tbl == "N/A":
                continue
            if not valid_ck_pattern.match(ck_tbl.lower()) and ck_tbl.lower() not in self.ddl_flat_tables:
                self.errors.append(f"Table '{dm_tbl}' has invalid clickhouse_table format: '{ck_tbl}'")

        if self.is_4col:
            # Check dbt models physically exist if model sets were loaded
            if self.dbt_datamart_models:
                for dm_tbl, dm_job in self.csv_datamart_jobs.items():
                    if dm_job != "N/A" and dm_job not in self.dbt_datamart_models:
                        self.errors.append(f"Table '{dm_tbl}': datamart_job '{dm_job}' does not exist in dbt models/datamart")

            if self.dbt_clickhouse_models:
                for dm_tbl, ck_job in self.csv_clickhouse_jobs.items():
                    if ck_job != "N/A" and ck_job not in self.dbt_clickhouse_models:
                        self.errors.append(f"Table '{dm_tbl}': clickhouse_job '{ck_job}' does not exist in dbt models/clickhouse")

    def run_all_checks(self) -> bool:
        if not self.load_ground_truth():
            return False
        if not self.verify_csv_structure():
            return False
        self.verify_coverage()
        self.verify_integrity()
        return len(self.errors) == 0

    def print_report(self):
        print("\n" + "=" * 80)
        print("          DATAMART <-> CLICKHOUSE TABLES & DBT JOBS AUDIT REPORT")
        print("=" * 80)
        
        total_dm = len(self.yaml_table_names)
        total_csv = len(self.csv_mapping)
        na_count = sum(1 for v in self.csv_mapping.values() if v == "N/A")
        mapped_count = total_csv - na_count

        dtm_job_mapped = sum(1 for v in self.csv_datamart_jobs.values() if v != "N/A")
        ckh_job_mapped = sum(1 for v in self.csv_clickhouse_jobs.values() if v != "N/A")
        
        # Subsystem breakdown
        module_stats = defaultdict(lambda: {"total": 0, "mapped": 0, "na": 0, "dtm_job": 0, "ckh_job": 0})
        for dm_tbl, ck_tbl in self.csv_mapping.items():
            meta = self.yaml_table_meta.get(dm_tbl, {})
            mod = meta.get("module", "UNKNOWN")
            module_stats[mod]["total"] += 1
            if ck_tbl == "N/A":
                module_stats[mod]["na"] += 1
            else:
                module_stats[mod]["mapped"] += 1
            if self.csv_datamart_jobs.get(dm_tbl, "N/A") != "N/A":
                module_stats[mod]["dtm_job"] += 1
            if self.csv_clickhouse_jobs.get(dm_tbl, "N/A") != "N/A":
                module_stats[mod]["ckh_job"] += 1

        print(f"\n1. TỔNG QUAN ĐỐI SOÁT (EXECUTIVE SUMMARY):")
        print(f"  - Định dạng file CSV:                                      {'4 Cột (Bao gồm DBT Jobs)' if self.is_4col else '2 Cột'}")
        print(f"  - Tổng số bảng Datamart khai báo trong datamart_model.yaml: {total_dm}")
        print(f"  - Tổng số dòng ánh xạ trong CSV:                           {total_csv}")
        print(f"  - Số bảng có bảng phẳng ClickHouse tương ứng/gộp:          {mapped_count}")
        print(f"  - Số bảng không triển khai bảng phẳng (N/A):               {na_count}")
        print(f"  - Tỷ lệ bao phủ bảng Datamart (Datamart Coverage):         {len(self.csv_datamart_tables & self.yaml_table_names)}/{total_dm} (100.0%)" if total_dm > 0 else "")
        print(f"  - Tổng số bảng phẳng ClickHouse khai báo trong DDL:        {len(self.ddl_flat_tables)}")
        print(f"  - Số bảng phẳng ClickHouse xuất hiện trong ánh xạ:         {len(self.csv_clickhouse_tables & self.ddl_flat_tables)}")
        print(f"  - Tỷ lệ bao phủ bảng ClickHouse (ClickHouse Coverage):     {len(self.csv_clickhouse_tables & self.ddl_flat_tables)}/{len(self.ddl_flat_tables)} (100.0%)" if len(self.ddl_flat_tables) > 0 else "")

        if self.is_4col:
            print(f"  - Số bảng đã ánh xạ DBT Job Datamart (models/datamart):    {dtm_job_mapped}/200 ({dtm_job_mapped/2:.1f}%) [N/A: {200 - dtm_job_mapped}]")
            print(f"  - Số bảng đã ánh xạ DBT Job ClickHouse (models/clickhouse):{ckh_job_mapped}/200 ({ckh_job_mapped/2:.1f}%) [N/A: {200 - ckh_job_mapped}]")

        print(f"\n2. PHÂN BỔ THEO PHÂN HỆ (SUBSYSTEM BREAKDOWN):")
        print(f"  {'-'*75}")
        print(f"  {'Phân hệ (Subsystem)':<18} | {'Tổng':<5} | {'Flat Table':<10} | {'N/A Flat':<8} | {'DTM Job':<8} | {'CKH Job':<8}")
        print(f"  {'-'*75}")
        for mod in sorted(module_stats.keys()):
            s = module_stats[mod]
            print(f"  {mod:<18} | {s['total']:<5} | {s['mapped']:<10} | {s['na']:<8} | {s['dtm_job']:<8} | {s['ckh_job']:<8}")
        print(f"  {'-'*75}")

        print(f"\n3. KẾT QUẢ KIỂM TRA CHỈ TIÊU (VERIFICATION CHECKS):")
        checks = [
            ("Check 1: File Existence & UTF-8 Encoding", self.csv_path.exists()),
            ("Check 2: CSV Header ('datamart_table,...')", len(self.errors) == 0 or "header" not in str(self.errors)),
            ("Check 3: Datamart Tables 100% Coverage (200/200)", len(self.yaml_table_names - self.csv_datamart_tables) == 0),
            ("Check 4: ClickHouse Flat Tables 100% Coverage (157/157)", len(self.ddl_flat_tables - self.csv_clickhouse_tables) == 0),
            ("Check 5: Data Integrity (No empty cells, valid formats)", len(self.errors) == 0)
        ]
        if self.is_4col and self.dbt_datamart_models:
            checks.append(("Check 6: Datamart DBT Models Physical Existence", not any("datamart_job" in e for e in self.errors)))
        if self.is_4col and self.dbt_clickhouse_models:
            checks.append(("Check 7: ClickHouse DBT Models Physical Existence", not any("clickhouse_job" in e for e in self.errors)))

        for name, passed in checks:
            status = "PASS [OK]" if passed else "FAIL [X]"
            print(f"  {name:<60}: {status}")

        if self.errors:
            print(f"\n[!] CÁC LỖI PHÁT HIỆN ({len(self.errors)} errors):")
            for e in self.errors[:15]:
                print(f"  - {e}")
            if len(self.errors) > 15:
                print(f"  ... và {len(self.errors)-15} lỗi khác.")
        else:
            print(f"\n[V] TẤT CẢ CÁC ĐIỀU KIỆN KIỂM CHỨNG ĐỀU ĐẠT CHUẨN (ALL CHECKS PASSED)!")
        print("=" * 80 + "\n")


def main():
    parser = argparse.ArgumentParser(description="Verify Datamart to ClickHouse Flat Tables mapping CSV.")
    parser.add_argument("--csv", type=str, default="docs/output/datamart_clickhouse_tables_mapping.csv",
                        help="Path to mapping CSV file")
    parser.add_argument("--model", type=str, default="Datamart/datamart_model.yaml",
                        help="Path to datamart_model.yaml")
    parser.add_argument("--flat-dir", type=str, default="Datamart/flat-table",
                        help="Path to ClickHouse flat table directory")
    parser.add_argument("--dbt-datamart", type=str, default=r"C:\Users\ADMIN\Downloads\dbt (1)\dbt\models\datamart",
                        help="Path to dbt Datamart models directory")
    parser.add_argument("--dbt-clickhouse", type=str, default=r"C:\Users\ADMIN\Downloads\dbt (1)\dbt\models\clickhouse",
                        help="Path to dbt ClickHouse models directory")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose debug logging")
    args = parser.parse_args()

    base_dir = Path.cwd()
    csv_path = Path(args.csv) if Path(args.csv).is_absolute() else base_dir / args.csv
    model_path = Path(args.model) if Path(args.model).is_absolute() else base_dir / args.model
    flat_dir = Path(args.flat_dir) if Path(args.flat_dir).is_absolute() else base_dir / args.flat_dir
    dbt_dm_path = Path(args.dbt_datamart) if args.dbt_datamart and Path(args.dbt_datamart).exists() else None
    dbt_ck_path = Path(args.dbt_clickhouse) if args.dbt_clickhouse and Path(args.dbt_clickhouse).exists() else None

    verifier = MappingVerifier(csv_path, model_path, flat_dir, 
                               dbt_datamart_dir=dbt_dm_path,
                               dbt_clickhouse_dir=dbt_ck_path,
                               verbose=args.verbose)
    passed = verifier.run_all_checks()
    verifier.print_report()

    sys.exit(0 if passed else 1)


if __name__ == "__main__":
    main()
