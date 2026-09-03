#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generate Datamart/lld/DTM_PTTT_Detail_Mapping.csv from:
  - BRD/BA/BA_analyst_PTTT.csv
  - Datamart/hld/DTM_PTTT_HLD.md
  - Datamart/lld/DTM_PTTT_Attributes.csv
"""

import csv
import re
import sys
from pathlib import Path

BASE = Path("/Users/chiennguyen/ubck_atomic_design")
BA_FILE = BASE / "BRD/BA/BA_analyst_PTTT.csv"
HLD_FILE = BASE / "Datamart/hld/DTM_PTTT_HLD.md"
ATTR_FILE = BASE / "Datamart/lld/DTM_PTTT_Attributes.csv"
OUT_FILE = BASE / "Datamart/lld/DTM_PTTT_Detail_Mapping.csv"

# ──────────────────────────────────────────────────────────────
# 1. Physical→Logical entity mapping
# ──────────────────────────────────────────────────────────────
ENTITY_MAP = {
    "fct_mkt_rsk_snpst":          "Fact Market Risk Snapshot",
    "fct_mcr_ind_snpst":          "Fact Macro Indicator Snapshot",
    "fct_sctr_rsk_snpst":         "Fact Sector Risk Snapshot",
    "fct_ordr_sz_snpst":          "Fact Order Size Snapshot",
    "fct_ivsr_flw_snpst":         "Fact Investor Flow Snapshot",
    "fct_frgn_net_trd_snpst":     "Fact Foreign Net Trade Snapshot",
    "fct_prpty_net_trd_snpst":    "Fact Proprietary Net Trade Snapshot",
    "fct_corp_bond_sctr_snpst":   "Fact Corporate Bond Sector Snapshot",
    "fct_mbr_sfty_snpst":         "Fact Member Safety Snapshot",
    "fct_mbr_sfty_per_mbr_snpst": "Fact Member Safety Per Member Snapshot",
    "opr_corp_bond_issuer_credit": "Operational Corporate Bond Issuer Credit Monitor",
    "opr_mbr_sfty_monitor":       "Operational Member Safety Monitor",
    "sctr_dim":                   "Sector Dimension",
    "corp_bond_sctr_dim":         "Corp Bond Sector Dimension",
    "ivsr_grp_dim":               "Investor Group Dimension",
    "scr_co_dim":                 "Securities Company Dimension",
}
ENTITY_MAP_REV = {v: k for k, v in ENTITY_MAP.items()}

# ──────────────────────────────────────────────────────────────
# 2. Source module mapping
# ──────────────────────────────────────────────────────────────
def map_source_module(nguon: str) -> str:
    n = nguon.strip()
    n_low = n.lower()
    if any(x in n for x in ("Sổ lệnh", "MSS")):
        return "MDDS"
    if any(x in n for x in ("MDDS", "Thông tin thị trường", "IDXInfor",
                             "MarketInfor", "StockInfor", "GSGD")):
        return "MDDS"
    if any(x in n for x in ("RISK_INDICATOR", "MRMS")):
        return "MRMS"
    if any(x in n for x in ("SCMS", "BC_BAO_CAO_GT", "báo cáo SCMS")):
        return "SCMS"
    if any(x in n for x in ("Kho dữ liệu", "KhoDL", "WeightConfig")):
        return "KhoDL"
    if any(x in n for x in ("IDS", "pblc_co", "IDS-GSĐC", "Báo cáo tài chính")):
        return "IDS"
    return ""

# ──────────────────────────────────────────────────────────────
# 3. Parse Attributes CSV → lookup maps
# ──────────────────────────────────────────────────────────────
# (entity_name, col_logical) → (phys_table, phys_col)
attr_entity_map = {}        # entity_name -> phys_table
attr_col_map = {}           # (entity_name, attr_logical) -> (phys_table, phys_col, attr_logical_name)
# Also build by phys_table -> entity_name
phys_to_entity = {}

with open(ATTR_FILE, newline="", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    # Strip BOM from first field name if present
    fields = reader.fieldnames or []
    clean_fields = [f.lstrip("﻿").strip('"') for f in fields]
    reader.fieldnames = clean_fields
    for row in reader:
        # Also clean keys that might have quotes
        row = {k.strip('"'): v for k, v in row.items()}
        ent = row["datamart_entity"].strip()
        tbl = row["datamart_table"].strip()
        attr_log = row["datamart_attribute"].strip()
        col_phys = row["datamart_column"].strip()
        attr_entity_map[ent] = tbl
        attr_col_map[(ent, attr_log)] = col_phys
        phys_to_entity[tbl] = ent

# ──────────────────────────────────────────────────────────────
# 4. Parse HLD → kpi_map and stt_kpi_map
# ──────────────────────────────────────────────────────────────
# kpi_map: kpi_id -> {nhom, tab, kpi_name, tinh_chat, pending, formula, mart_table}
# stt_kpi_map: stt -> [kpi_id, ...] in order (READY first, then PENDING)

kpi_map = {}
stt_kpi_map = {}   # stt (int) -> list of kpi_ids in order

hld_text = HLD_FILE.read_text(encoding="utf-8")

# Parse tab names from headings like "### Tab Dashboard Giám sát rủi ro"
TAB_RE = re.compile(r'^### Tab (.+)$', re.MULTILINE)
# Parse group headings like "#### Nhóm 1 - ..." or "#### Nhóm 22 - ..."
GROUP_RE = re.compile(r'^#### Nhóm (\d+)\s*[-–]\s*(.+)$', re.MULTILINE)
# KPI table rows: | K_PTTT_N | name | ... | tinh_chat | formula | ghi_chu |
KPI_ROW_RE = re.compile(
    r'^\|\s*(K_PTTT_\d+)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(Cơ sở|Phái sinh|Chiều)\s*\|([^|]*)\|([^|]*)\|',
    re.MULTILINE
)
# PENDING KPI table rows (4-col): | K_PTTT_N | name | tinh_chat | Trạng thái |
PENDING_ROW_RE = re.compile(
    r'^\|\s*(K_PTTT_\d+)\s*\|\s*([^|]+?)\s*\|\s*(Cơ sở|Phái sinh|Chiều)\s*\|\s*PENDING\s*\|',
    re.MULTILINE
)
# "Source:" line to determine mart_table for group
SOURCE_RE = re.compile(r'\*\*Source:\*\*\s*`([^`]+)`')

# Split HLD into sections per Tab, then per Nhóm
def parse_hld(text):
    """Parse HLD into kpi_map and stt_kpi_map."""

    # Find tab positions
    tab_matches = list(TAB_RE.finditer(text))
    # Add a sentinel at the end
    tab_positions = [(m.start(), m.group(1).strip()) for m in tab_matches]
    tab_positions.append((len(text), "__END__"))

    for i, (tab_start, tab_name) in enumerate(tab_positions[:-1]):
        tab_end = tab_positions[i + 1][0]
        tab_text = text[tab_start:tab_end]

        # Find groups within this tab
        group_matches = list(GROUP_RE.finditer(tab_text))
        group_positions = [(m.start(), int(m.group(1)), m.group(2).strip()) for m in group_matches]
        group_positions.append((len(tab_text), -1, "__END__"))

        for j, (g_start, nhom_num, nhom_name) in enumerate(group_positions[:-1]):
            g_end = group_positions[j + 1][0]
            g_text = tab_text[g_start:g_end]

            if nhom_num == -1:
                continue

            # Determine mart_table from Source line
            source_match = SOURCE_RE.search(g_text)
            mart_table_logical = ""
            if source_match:
                # First entity in the source line
                src_raw = source_match.group(1).split("→")[0].strip().split(",")[0].strip()
                mart_table_logical = src_raw

            phys_table = ENTITY_MAP_REV.get(mart_table_logical, "")

            # Parse READY KPIs (6-col table)
            ready_kpis = []
            for m in KPI_ROW_RE.finditer(g_text):
                kpi_id = m.group(1).strip()
                kpi_name = m.group(2).strip()
                tinh_chat = m.group(4).strip()
                formula = m.group(5).strip()

                if kpi_id not in kpi_map:
                    kpi_map[kpi_id] = {
                        "nhom": str(nhom_num),
                        "tab": tab_name,
                        "kpi_name": kpi_name,
                        "tinh_chat": tinh_chat,
                        "pending": False,
                        "formula": formula,
                        "mart_table_logical": mart_table_logical,
                        "mart_phys": phys_table,
                    }
                ready_kpis.append(kpi_id)

            # Parse PENDING KPIs (4-col table)
            pending_kpis = []
            for m in PENDING_ROW_RE.finditer(g_text):
                kpi_id = m.group(1).strip()
                kpi_name = m.group(2).strip()
                tinh_chat = m.group(3).strip()

                if kpi_id not in kpi_map:
                    kpi_map[kpi_id] = {
                        "nhom": str(nhom_num),
                        "tab": tab_name,
                        "kpi_name": kpi_name,
                        "tinh_chat": tinh_chat,
                        "pending": True,
                        "formula": "",
                        "mart_table_logical": mart_table_logical,
                        "mart_phys": phys_table,
                    }
                else:
                    # Mark as pending if already registered from another group
                    # (could be "reuse" with PENDING status in this group)
                    pass
                pending_kpis.append(kpi_id)

            # Build stt_kpi_map: READY first, then PENDING, dedup
            if nhom_num not in stt_kpi_map:
                stt_kpi_map[nhom_num] = []

            # Deduplicate while preserving order
            existing = set(stt_kpi_map[nhom_num])
            for kid in ready_kpis:
                if kid not in existing:
                    stt_kpi_map[nhom_num].append(kid)
                    existing.add(kid)
            for kid in pending_kpis:
                if kid not in existing:
                    stt_kpi_map[nhom_num].append(kid)
                    existing.add(kid)

parse_hld(hld_text)

print(f"[HLD] Total KPI IDs parsed: {len(kpi_map)}")
for nhom in sorted(stt_kpi_map.keys()):
    print(f"  Nhóm {nhom}: {len(stt_kpi_map[nhom])} KPIs → {stt_kpi_map[nhom][:3]}...")

# ──────────────────────────────────────────────────────────────
# 5. Parse BA file
# ──────────────────────────────────────────────────────────────
ba_rows = []

with open(BA_FILE, newline="", encoding="utf-8-sig") as f:
    raw_lines = f.readlines()

# rows[0] = extra header row (skip), rows[1] = column headers, rows[2:] = data
reader = csv.reader(raw_lines[1:], delimiter=";")
headers = None
for i, row in enumerate(reader):
    if i == 0:
        headers = row
        continue
    if len(row) < 15:
        continue

    stt_raw = row[0].strip() if len(row) > 0 else ""
    if not stt_raw.isdigit():
        continue

    status = row[13].strip() if len(row) > 13 else ""
    if status not in ("Done", "Doing", "Pending"):
        continue

    danh_gia = row[7].strip().lower() if len(row) > 7 else ""
    if "trùng" in danh_gia or "trung" in danh_gia:
        continue

    stt = int(stt_raw)
    dashboard = row[2].strip() if len(row) > 2 else ""
    thong_tin = row[3].strip() if len(row) > 3 else ""
    phan_loai = row[6].strip() if len(row) > 6 else ""
    nguon = row[9].strip() if len(row) > 9 else ""
    mapping_nv = row[14].strip() if len(row) > 14 else ""

    ba_rows.append({
        "stt": stt,
        "dashboard": dashboard,
        "thong_tin": thong_tin,
        "phan_loai": phan_loai,
        "danh_gia": danh_gia,
        "nguon": nguon,
        "status": status,
        "mapping_nv": mapping_nv,
    })

print(f"\n[BA] Total valid rows (non-Trùng, valid status): {len(ba_rows)}")

# Group BA rows by STT
from collections import defaultdict
ba_by_stt = defaultdict(list)
for r in ba_rows:
    ba_by_stt[r["stt"]].append(r)

print(f"[BA] Unique STT values: {sorted(ba_by_stt.keys())}")

# ──────────────────────────────────────────────────────────────
# 6. Build column lookup from Attributes CSV
# ──────────────────────────────────────────────────────────────
# (phys_table, partial_col_name_search) -> phys_col
# Map: phys_table -> {attr_logical -> phys_col}
table_col_lookup = defaultdict(dict)
with open(ATTR_FILE, newline="", encoding="utf-8-sig") as f:
    reader2 = csv.DictReader(f)
    fields2 = reader2.fieldnames or []
    clean_fields2 = [f.lstrip("﻿").strip('"') for f in fields2]
    reader2.fieldnames = clean_fields2
    for row in reader2:
        row = {k.strip('"'): v for k, v in row.items()}
        ent = row["datamart_entity"].strip()
        tbl = row["datamart_table"].strip()
        attr_log = row["datamart_attribute"].strip()
        col_phys = row["datamart_column"].strip()
        table_col_lookup[tbl][attr_log] = col_phys

# ──────────────────────────────────────────────────────────────
# 7. Determine mart_table and mart_column for a BA row
# ──────────────────────────────────────────────────────────────
def get_mart_table_col(ba_row, kpi_info):
    """Return (mart_table_logical, mart_table_phys, mart_column_logical, mart_column_phys)"""
    phan_loai = ba_row["phan_loai"]

    # DERIVED: no table/column
    if phan_loai == "Chỉ tiêu phái sinh":
        return ("", "", "", "")

    # Get the mart table from KPI info
    mart_phys = kpi_info.get("mart_phys", "")
    mart_logical = kpi_info.get("mart_table_logical", "")

    if not mart_phys and mart_logical:
        mart_phys = ENTITY_MAP_REV.get(mart_logical, "")

    if not mart_phys:
        return (mart_logical, "", "", "")

    # Try to find the column by matching thong_tin to attribute names
    thong_tin = ba_row["thong_tin"].strip()
    cols = table_col_lookup.get(mart_phys, {})

    # Exact match first
    if thong_tin in cols:
        return (mart_logical, mart_phys, thong_tin, cols[thong_tin])

    # Partial match (thong_tin is substring of attr_log or vice versa)
    for attr_log, col_phys in cols.items():
        if thong_tin.lower() in attr_log.lower() or attr_log.lower() in thong_tin.lower():
            return (mart_logical, mart_phys, attr_log, col_phys)

    # Fallback: use Snapshot Date Dimension Id for MEASURE
    if phan_loai == "Chỉ tiêu cơ sở":
        return (mart_logical, mart_phys, thong_tin, "")

    return (mart_logical, mart_phys, thong_tin, "")

# ──────────────────────────────────────────────────────────────
# 8. Build column_role logic
# ──────────────────────────────────────────────────────────────
def get_column_role(phan_loai, thong_tin, mapping_nv):
    """Return column_role string."""
    if phan_loai == "Chỉ tiêu phái sinh":
        return "DERIVED"
    if phan_loai == "Chỉ tiêu cơ sở":
        return "MEASURE"
    if phan_loai == "Chiều":
        # Fixed-value dimensions are FILTER, others are SLICER
        m_low = mapping_nv.lower()
        t_low = thong_tin.lower()
        if ("=" in mapping_nv and ("src_stm_code" in m_low or "flr_code" in m_low)):
            return "FILTER"
        return "SLICER"
    return "SLICER"

# ──────────────────────────────────────────────────────────────
# 9. Build logic string for each row
# ──────────────────────────────────────────────────────────────
def build_logic(ba_row, kpi_info, mart_phys, mart_col_phys, column_role):
    """Build the logic/formula string."""
    phan_loai = ba_row["phan_loai"]
    status = ba_row["status"]

    if status == "Doing":
        return ""

    if status == "Pending":
        return ""

    formula = kpi_info.get("formula", "").strip()
    mapping_nv = ba_row["mapping_nv"].strip()

    if column_role == "DERIVED":
        # Use formula from HLD if available
        if formula:
            return formula
        return mapping_nv if mapping_nv else ""

    if column_role in ("MEASURE", "SLICER", "FILTER"):
        if mapping_nv:
            return mapping_nv
        if formula:
            return formula

    return ""

# ──────────────────────────────────────────────────────────────
# 10. Generate Detail Mapping rows
# ──────────────────────────────────────────────────────────────
output_rows = []

# Snapshot Date Filter logic template
SNAPSHOT_FILTER_LOGIC = (
    "JOIN cdr_dt_dim ON cdr_dt_dim.cdr_dt_dim_id = {fact_table}.snpst_dt_dim_id "
    "WHERE cdr_dt_dim.yr = :Y AND cdr_dt_dim.mo = :M"
)

stt_kpi_used = defaultdict(int)  # stt -> count of BA rows matched so far

for ba_row in ba_rows:
    stt = ba_row["stt"]
    status = ba_row["status"]
    phan_loai = ba_row["phan_loai"]
    thong_tin = ba_row["thong_tin"]
    nguon = ba_row["nguon"]
    mapping_nv = ba_row["mapping_nv"]
    dashboard = ba_row["dashboard"]

    # Get KPI IDs for this STT group
    kpi_list = stt_kpi_map.get(stt, [])

    # Get next KPI for this STT
    idx = stt_kpi_used[stt]
    stt_kpi_used[stt] += 1

    if idx < len(kpi_list):
        kpi_id = kpi_list[idx]
    else:
        # No KPI available — generate a placeholder
        kpi_id = f"K_PTTT_STT{stt}_{idx+1}"

    kpi_info = kpi_map.get(kpi_id, {
        "nhom": str(stt),
        "tab": dashboard,
        "kpi_name": thong_tin,
        "tinh_chat": phan_loai,
        "pending": (status == "Pending"),
        "formula": mapping_nv,
        "mart_table_logical": "",
        "mart_phys": "",
    })

    nhom = kpi_info.get("nhom", str(stt))
    tab = kpi_info.get("tab", dashboard)
    kpi_name = kpi_info.get("kpi_name", thong_tin)
    tinh_chat = phan_loai  # use BA's classification
    is_pending = kpi_info.get("pending", False) or (status == "Pending")

    # Override pending if status says Pending
    if status == "Pending":
        is_pending = True

    # Determine mart_table and mart_column
    mart_logical = kpi_info.get("mart_table_logical", "")
    mart_phys = kpi_info.get("mart_phys", "")

    if phan_loai == "Chỉ tiêu phái sinh":
        mart_table_out = ""
        mart_col_out = ""
    elif is_pending:
        mart_table_out = mart_logical
        mart_col_out = ""
    else:
        # Try to match column
        mart_table_out = mart_logical
        cols = table_col_lookup.get(mart_phys, {})

        # Try exact match
        found_col = ""
        if thong_tin in cols:
            found_col = cols[thong_tin]
        else:
            # Partial match
            for attr_log, col_phys in cols.items():
                t_lower = thong_tin.lower().replace("(", "").replace(")", "")
                a_lower = attr_log.lower().replace("(", "").replace(")", "")
                if t_lower in a_lower or a_lower in t_lower:
                    found_col = col_phys
                    mart_table_out = mart_logical
                    break
        mart_col_out = found_col if found_col else thong_tin

    # Column role
    column_role = get_column_role(phan_loai, thong_tin, mapping_nv)

    # Source module
    source_module = map_source_module(nguon)

    # Logic
    if is_pending:
        logic_str = ""
        ghi_chu = "Pending - chưa thiết kế nguồn"
    elif status == "Doing":
        logic_str = ""
        ghi_chu = "Doing — chờ BA xác nhận"
    else:
        formula = kpi_info.get("formula", "").strip()
        if column_role == "DERIVED":
            if formula:
                logic_str = formula
            elif mapping_nv:
                logic_str = mapping_nv
            else:
                logic_str = ""
            # Check if formula references other KPI IDs
            if re.search(r'K_PTTT_\d+', logic_str):
                ghi_chu = "Refer KPI ID — cần presentation layer resolve"
            else:
                ghi_chu = ""
        else:
            if mapping_nv:
                logic_str = mapping_nv
            elif formula:
                logic_str = formula
            else:
                logic_str = ""
            ghi_chu = ""

    # Build main row
    main_row = {
        "kpi_id": kpi_id,
        "tab": tab,
        "nhom": nhom,
        "kpi_name": kpi_name,
        "tinh_chat": tinh_chat,
        "source_module": source_module,
        "mart_table": mart_table_out,
        "mart_column": mart_col_out,
        "column_role": column_role,
        "logic": logic_str,
        "ghi_chu": ghi_chu,
    }
    output_rows.append(main_row)

    # MEASURE rows get a companion FILTER row for Snapshot Date
    if column_role == "MEASURE" and not is_pending and status != "Doing":
        filter_logic = SNAPSHOT_FILTER_LOGIC.format(fact_table=mart_phys if mart_phys else mart_table_out)
        filter_row = {
            "kpi_id": kpi_id,
            "tab": tab,
            "nhom": nhom,
            "kpi_name": kpi_name,
            "tinh_chat": tinh_chat,
            "source_module": source_module,
            "mart_table": mart_table_out,
            "mart_column": "Snapshot Date Dimension Id",
            "column_role": "FILTER",
            "logic": filter_logic,
            "ghi_chu": "",
        }
        output_rows.append(filter_row)

# ──────────────────────────────────────────────────────────────
# 11. Write output CSV
# ──────────────────────────────────────────────────────────────
FIELDNAMES = ["kpi_id", "tab", "nhom", "kpi_name", "tinh_chat",
              "source_module", "mart_table", "mart_column",
              "column_role", "logic", "ghi_chu"]

with open(OUT_FILE, "w", newline="", encoding="utf-8-sig") as f:
    writer = csv.DictWriter(f, fieldnames=FIELDNAMES, quoting=csv.QUOTE_ALL)
    writer.writeheader()
    writer.writerows(output_rows)

print(f"\n[OUTPUT] Total rows written: {len(output_rows)}")

# ──────────────────────────────────────────────────────────────
# 12. Verification
# ──────────────────────────────────────────────────────────────
unique_kpi_ids = {r["kpi_id"] for r in output_rows}
print(f"[OUTPUT] Unique KPI IDs: {len(unique_kpi_ids)}")

print("\n=== Sample 5 rows (beginning) ===")
for r in output_rows[:5]:
    print(r)

# Sample rows for STT 22 (An toàn CTCK)
print("\n=== Sample rows for Nhóm 22 (An toàn CTCK) ===")
nhom22_rows = [r for r in output_rows if r["nhom"] == "22"]
for r in nhom22_rows[:5]:
    print(r)

print(f"\n[DONE] Output file: {OUT_FILE}")
print(f"[SUMMARY]")
print(f"  BA rows processed: {len(ba_rows)}")
print(f"  Output rows total: {len(output_rows)}")
print(f"  Unique KPI IDs:    {len(unique_kpi_ids)}")
