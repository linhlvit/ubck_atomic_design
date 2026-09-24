# -*- coding: utf-8 -*-
"""
test_ndtnn_challenger2_oracles.py — Quantitative & Integrity Oracles for NDTNN Datamart Audit

Independent Verification Test Suite by Challenger 2:
1. Exact row count of BA in BRD/BA/BA_analyst_NDTNN.csv (expected: 260 data rows across 43 groups)
2. Status breakdown in BA: 258 Done, 2 Doing, 0 Pending
3. READY (62) and PENDING (196) counts in Datamart/lld/DTM_NDTNN_Detail_Mapping.csv
   (+ 1 Out-of-scope K_NDTNN_70, total 259 indicators mapped)
4. Rule L4 compliance: 100% of PENDING indicators have empty mart_table, mart_column, column_role, and logic
5. Physical column count across 9 LLD table CSVs (expected: 69 columns) and 1-to-1 match with datamart_attributes.csv
"""
from collections import defaultdict
import csv
import glob
import os
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple

if sys.platform.startswith("win"):
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    if hasattr(sys.stderr, "reconfigure"):
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")

import pytest

# Project root
REPO_ROOT = Path(__file__).resolve().parent.parent
BA_CSV_PATH = REPO_ROOT / "BRD" / "BA" / "BA_analyst_NDTNN.csv"
DETAIL_MAPPING_PATH = REPO_ROOT / "Datamart" / "lld" / "DTM_NDTNN_Detail_Mapping.csv"
LLD_TABLES_DIR = REPO_ROOT / "Datamart" / "lld" / "NDTNN"
MASTER_ATTRIBUTES_PATH = REPO_ROOT / "Datamart" / "lld" / "datamart_attributes.csv"
REPORT_PATH = REPO_ROOT / "docs" / "output" / "datamart" / "NDTNN" / "NDTNN_MultiAgent_Review_Report.md"

csv.field_size_limit(min(sys.maxsize, 2147483647))


def load_ba_rows() -> Tuple[List[str], List[Dict[str, str]]]:
    """Parse BA_analyst_NDTNN.csv properly handling header row at line 2 and description at line 3."""
    with open(BA_CSV_PATH, "r", encoding="utf-8-sig", errors="replace") as f:
        reader = csv.reader(f)
        row1 = next(reader)  # Group banner / empty banner line 1
        header = next(reader)  # Line 2: STT, Mã, Dashboard/báo cáo, ...
        header = [h.strip() for h in header]
        
        rows = []
        for line_idx, r in enumerate(reader, start=3):
            row_dict = {}
            for col_idx, col_name in enumerate(header):
                val = r[col_idx] if col_idx < len(r) else ""
                row_dict[col_name] = val.strip()
            
            stt = row_dict.get("STT", "")
            ma = row_dict.get("Mã", "")
            
            # Line 3 is legend/description row (empty STT and empty Mã)
            if not stt and not ma:
                continue
            
            row_dict["_line_number"] = str(line_idx)
            rows.append(row_dict)
            
    return header, rows


def test_ba_row_count_and_groups():
    """Verify BA has exactly 260 rows across 43 groups."""
    header, rows = load_ba_rows()
    total_rows = len(rows)
    print(f"\n[ORACLE 1.1 - BA ROW COUNT] Total data rows in BA: {total_rows}")
    
    # Collect unique groups (STT)
    groups = set()
    for r in rows:
        stt = r.get("STT", "")
        if stt:
            groups.add(int(stt))
            
    print(f"[ORACLE 1.2 - BA GROUPS] Groups present (STT): min={min(groups)}, max={max(groups)}, total_groups={len(groups)}")
    
    assert total_rows == 260, f"Expected 260 BA data rows, got {total_rows}"
    assert len(groups) == 43, f"Expected 43 groups, got {len(groups)}"
    assert sorted(list(groups)) == list(range(1, 44)), f"Groups are not contiguous 1 to 43: {sorted(list(groups))}"


def test_ba_status_breakdown():
    """Verify BA status breakdown: 258 Done, 2 Doing, 0 Pending."""
    header, rows = load_ba_rows()
    status_counts = {}
    doing_items = []
    for r in rows:
        status = r.get("Trạng thái mapping", "").strip()
        status_counts[status] = status_counts.get(status, 0) + 1
        if status == "Doing":
            doing_items.append((r.get("STT"), r.get("Mã"), r.get("Thông tin")))
            
    print(f"\n[ORACLE 2 - BA STATUS BREAKDOWN] Status counts: {status_counts}")
    print(f"  Doing items: {doing_items}")
    
    assert status_counts.get("Done", 0) == 258, f"Expected 258 Done, got {status_counts.get('Done')}"
    assert status_counts.get("Doing", 0) == 2, f"Expected 2 Doing, got {status_counts.get('Doing')}"
    assert status_counts.get("Pending", 0) == 0, f"Expected 0 Pending in BA, got {status_counts.get('Pending')}"
    assert status_counts.get("", 0) == 0, f"Expected 0 empty status, got {status_counts.get('')}"


def load_detail_mapping_rows() -> Tuple[List[str], List[Dict[str, str]]]:
    """Parse DTM_NDTNN_Detail_Mapping.csv."""
    with open(DETAIL_MAPPING_PATH, "r", encoding="utf-8-sig", errors="replace") as f:
        reader = csv.reader(f)
        header = [h.strip() for h in next(reader)]
        rows = []
        for line_idx, r in enumerate(reader, start=2):
            if not any(cell.strip() for cell in r):
                continue
            row_dict = {}
            for col_idx, col_name in enumerate(header):
                val = r[col_idx] if col_idx < len(r) else ""
                row_dict[col_name] = val.strip()
            row_dict["_line_number"] = str(line_idx)
            rows.append(row_dict)
    return header, rows


def test_detail_mapping_ready_and_pending_counts():
    """
    Verify READY (62) and PENDING (196) counts in DTM_NDTNN_Detail_Mapping.csv.
    Plus 1 OUT-OF-SCOPE indicator (K_NDTNN_70) -> Total 259 indicators mapped.
    Total mapping rows in CSV: 299 rows.
    """
    header, rows = load_detail_mapping_rows()
    print(f"\n[ORACLE 3.1 - DETAIL MAPPING TOTAL ROWS] Total mapping rows: {len(rows)}")
    assert len(rows) == 299, f"Expected 299 mapping rows, got {len(rows)}"
    
    # Classify indicators by (nhom, kpi_id, kpi_name)
    nhom_ready = defaultdict(set)
    nhom_pending = defaultdict(set)
    nhom_oos = defaultdict(set)
    
    empty_4col_rows = []
    populated_rows = []
    
    for r in rows:
        nhom = r["nhom"]
        kpi_id = r["kpi_id"]
        kpi_name = r["kpi_name"]
        mt = r.get("mart_table", "")
        mc = r.get("mart_column", "")
        cr = r.get("column_role", "")
        lg = r.get("logic", "")
        gc = r.get("ghi_chu", "")
        
        is_empty = (not mt and not mc and not cr and not lg)
        ind_key = (kpi_id, kpi_name)
        
        if is_empty:
            empty_4col_rows.append(r)
            if "out-of-scope" in gc.lower():
                nhom_oos[nhom].add(ind_key)
            else:
                nhom_pending[nhom].add(ind_key)
        else:
            populated_rows.append(r)
            nhom_ready[nhom].add(ind_key)
            
    total_ready_indicators = sum(len(s) for s in nhom_ready.values())
    total_pending_indicators = sum(len(s) for s in nhom_pending.values())
    total_oos_indicators = sum(len(s) for s in nhom_oos.values())
    
    print(f"[ORACLE 3.2 - SCOPE BREAKDOWN]")
    print(f"  Total READY indicators:       {total_ready_indicators} (Expected: 62)")
    print(f"  Total PENDING indicators:     {total_pending_indicators} (Expected: 196)")
    print(f"  Total OUT-OF-SCOPE indicators:{total_oos_indicators} (Expected: 1)")
    print(f"  Total indicators mapped:      {total_ready_indicators + total_pending_indicators + total_oos_indicators} (Expected: 259)")
    print(f"  Empty 4-column rows:          {len(empty_4col_rows)} (196 PENDING + 1 OUT-OF-SCOPE = 197)")
    print(f"  Populated mapping rows:       {len(populated_rows)} (102 rows covering 62 READY indicators)")
    
    # Assertions
    assert total_ready_indicators == 62, f"Expected 62 READY indicators, got {total_ready_indicators}"
    assert total_pending_indicators == 196, f"Expected 196 PENDING indicators, got {total_pending_indicators}"
    assert total_oos_indicators == 1, f"Expected 1 OUT-OF-SCOPE indicator, got {total_oos_indicators}"
    assert len(empty_4col_rows) == 197, f"Expected 197 empty 4-column rows, got {len(empty_4col_rows)}"
    assert len(populated_rows) == 102, f"Expected 102 populated rows, got {len(populated_rows)}"


def test_rule_l4_strict_compliance():
    """
    Kiểm tra 100% chỉ tiêu PENDING có tuân thủ tuyệt đối Rule L4:
    Cả 4 cột mart_table, mart_column, column_role, logic đều để trống.
    
    Quy tắc L4 (phase2_detail_mapping.md / issue_classification.md):
    - PENDING: Bắt buộc để trống cả 4 cột mart_table, mart_column, column_role, logic.
      Ghi rõ blocker/nguyên nhân tại ghi_chu.
    - DERIVED: Bắt buộc để trống mart_table, mart_column, nhưng column_role='DERIVED' và logic có công thức.
    """
    header, rows = load_detail_mapping_rows()
    
    # Define the 196 PENDING KPI IDs as documented in HLD and Report
    cum1_pending = {'K_NDTNN_5', 'K_NDTNN_6', 'K_NDTNN_7'} | {f'K_NDTNN_{i}' for i in range(20, 33)} | {'K_NDTNN_35'} | {f'K_NDTNN_{i}' for i in range(90, 95)}
    cum2_pending = {f'K_NDTNN_{i}' for i in range(37, 50)} | {f'K_NDTNN_{i}' for i in range(95, 99)}
    cum3_pending = {'K_NDTNN_65'}
    cum4_pending = {f'K_NDTNN_{i}' for i in range(99, 255)}
    all_pending_kpis = cum1_pending | cum2_pending | cum3_pending | cum4_pending
    assert len(all_pending_kpis) == 196, f"Expected 196 PENDING KPIs, got {len(all_pending_kpis)}"
    
    pending_conforming_count = 0
    violations = []
    
    for r in rows:
        kpi_id = r.get("kpi_id", "")
        mt = r.get("mart_table", "")
        mc = r.get("mart_column", "")
        cr = r.get("column_role", "")
        lg = r.get("logic", "")
        gc = r.get("ghi_chu", "")
        line_no = r.get("_line_number", "")
        
        # If this row is one of the 196 PENDING indicators:
        if kpi_id in all_pending_kpis:
            if mt != "" or mc != "" or cr != "" or lg != "":
                violations.append({
                    "line": line_no,
                    "kpi_id": kpi_id,
                    "mart_table": mt,
                    "mart_column": mc,
                    "column_role": cr,
                    "logic": lg,
                    "ghi_chu": gc
                })
            else:
                pending_conforming_count += 1
                
    print(f"\n[ORACLE 4 - RULE L4 AUDIT]")
    print(f"  Total PENDING indicators audited:            {len(all_pending_kpis)} (Expected: 196)")
    print(f"  PENDING indicators strictly conforming L4:   {pending_conforming_count} / 196 (100.0%)")
    print(f"  Total Rule L4 violations:                    {len(violations)}")
    
    assert len(violations) == 0, f"Found {len(violations)} Rule L4 violations: {violations}"
    assert pending_conforming_count == 196, f"Expected exactly 196 conforming PENDING rows, got {pending_conforming_count}"


def load_lld_table_csvs() -> Dict[str, List[Dict[str, str]]]:
    """Load all 9 LLD Table CSVs in Datamart/lld/NDTNN/."""
    csv_files = sorted(glob.glob(str(LLD_TABLES_DIR / "*.csv")))
    tables_data = {}
    for fpath in csv_files:
        p = Path(fpath)
        with open(p, "r", encoding="utf-8-sig", errors="replace") as f:
            reader = csv.reader(f)
            header = [h.strip() for h in next(reader)]
            rows = []
            for line_no, r in enumerate(reader, start=2):
                if not any(cell.strip() for cell in r):
                    continue
                row_dict = {header[i]: r[i].strip() if i < len(r) else "" for i in range(len(header))}
                row_dict["_file"] = p.name
                row_dict["_line"] = str(line_no)
                rows.append(row_dict)
            tables_data[p.name] = rows
    return tables_data


def test_lld_physical_columns_and_master_attributes_parity():
    """
    Đếm số cột vật lý trong 9 file LLD Table CSVs (phải đúng 69 cột)
    và kiểm tra khớp 1-1 với datamart_attributes.csv.
    """
    tables_data = load_lld_table_csvs()
    print(f"\n[ORACLE 5.1 - LLD PHYSICAL COLUMNS COUNT]")
    print(f"  Total LLD table CSV files found: {len(tables_data)} (Expected: 9)")
    
    total_physical_columns = 0
    table_column_map: Dict[str, List[str]] = {}
    table_file_map: Dict[str, str] = {}
    
    for filename, rows in tables_data.items():
        col_count = len(rows)
        total_physical_columns += col_count
        table_name = rows[0].get("datamart_table", "")
        cols = [r.get("datamart_column", "") for r in rows]
        table_column_map[table_name] = cols
        table_file_map[table_name] = filename
        print(f"  {len(table_column_map)}. [{filename}] -> Table: '{table_name}' | Columns: {col_count}")
        
    print(f"  Total physical columns across all 9 tables: {total_physical_columns} (Expected: 69)")
    assert len(tables_data) == 9, f"Expected 9 LLD table CSVs, found {len(tables_data)}"
    assert total_physical_columns == 69, f"Expected exactly 69 physical columns, got {total_physical_columns}"
    
    # Load Master Registry
    with open(MASTER_ATTRIBUTES_PATH, "r", encoding="utf-8-sig", errors="replace") as f:
        reader = csv.reader(f)
        m_header = [h.strip() for h in next(reader)]
        master_rows = []
        for line_no, r in enumerate(reader, start=2):
            if not any(cell.strip() for cell in r):
                continue
            row_dict = {m_header[i]: r[i].strip() if i < len(r) else "" for i in range(len(m_header))}
            row_dict["_line"] = str(line_no)
            master_rows.append(row_dict)
            
    # Filter Master Registry for the 9 NDTNN tables
    ndtnn_table_names = set(table_column_map.keys())
    master_ndtnn_rows = [r for r in master_rows if r.get("datamart_table") in ndtnn_table_names]
    
    print(f"\n[ORACLE 5.2 - MASTER REGISTRY 1-TO-1 PARITY]")
    print(f"  Total NDTNN columns found in master registry: {len(master_ndtnn_rows)} (Expected: 69)")
    assert len(master_ndtnn_rows) == 69, f"Expected 69 NDTNN columns in master registry, got {len(master_ndtnn_rows)}"
    
    # Build sets of (datamart_table, datamart_column)
    lld_pairs = set()
    for t_name, cols in table_column_map.items():
        for c_name in cols:
            lld_pairs.add((t_name, c_name))
            
    master_pairs = set((r.get("datamart_table"), r.get("datamart_column")) for r in master_ndtnn_rows)
    
    missing_in_master = lld_pairs - master_pairs
    missing_in_lld = master_pairs - lld_pairs
    
    print(f"  Missing in Master: {len(missing_in_master)}")
    print(f"  Missing in LLD:    {len(missing_in_lld)}")
    assert len(missing_in_master) == 0, f"Columns missing in master: {missing_in_master}"
    assert len(missing_in_lld) == 0, f"Columns missing in LLD: {missing_in_lld}"
    assert lld_pairs == master_pairs, "LLD columns do not match master registry 1-to-1"
    
    # Character-level ETL logic and attribute field parity
    logic_mismatches = []
    type_mismatches = []
    master_lookup = {(r["datamart_table"], r["datamart_column"]): r for r in master_ndtnn_rows}
    
    for filename, rows in tables_data.items():
        for r in rows:
            pair = (r["datamart_table"], r["datamart_column"])
            m_row = master_lookup[pair]
            
            if r.get("etl_logic") != m_row.get("etl_logic"):
                logic_mismatches.append((pair, r.get("etl_logic"), m_row.get("etl_logic")))
            if r.get("data_type") != m_row.get("data_type"):
                type_mismatches.append((pair, r.get("data_type"), m_row.get("data_type")))
                
    print(f"  Character-level ETL logic mismatches: {len(logic_mismatches)}")
    print(f"  Data type mismatches:                {len(type_mismatches)}")
    assert len(logic_mismatches) == 0, f"ETL logic mismatches found: {logic_mismatches}"
    assert len(type_mismatches) == 0, f"Data type mismatches found: {type_mismatches}"
    print("  1-to-1 exact parity CONFIRMED across all 69 attributes!")


if __name__ == "__main__":
    print("=" * 80)
    print("RUNNING INDEPENDENT QUANTITATIVE & INTEGRITY ORACLES (CHALLENGER 2)")
    print("=" * 80)
    test_ba_row_count_and_groups()
    test_ba_status_breakdown()
    test_detail_mapping_ready_and_pending_counts()
    test_rule_l4_strict_compliance()
    test_lld_physical_columns_and_master_attributes_parity()
    print("\n" + "=" * 80)
    print("ALL QUANTITATIVE & INTEGRITY ORACLES PASSED EMPIRICALLY (100%)!")
    print("=" * 80)
