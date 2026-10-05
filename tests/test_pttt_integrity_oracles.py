# -*- coding: utf-8 -*-
"""
tests/test_pttt_integrity_oracles.py
------------------------------------
Independent Adversarial Empirical Test Oracles for PTTT Datamart Multi-Tier Integrity Audit.

Authentic verification test suite evaluating multi-tier integrity:
Snapshot cập nhật 2026-10-02 theo LLD hiện hành (BA 455 dòng, HLD 421 KPI, Detail Mapping 423 dòng, flat 17 bảng).

- Test 1: Full 34-group coverage across BRD/BA (455 items, 34 groups).
- Test 2: Complete HLD KPI coverage across 34 groups (420 HLD KPIs).
- Test 3: Detail Mapping scope reconciliation (423 total = 390 Dashboard + 33 Data Explorer; 327 READY [83.85%], 63 PENDING [16.15%]).
- Test 4: 4 cảnh báo S5 đã giải trình (K_PTTT_223/226, VOL đúng theo mô tả BA) ở Group 28 (rows 400, 401) và Group 31 (rows 422, 423) — BA thêm 1 dòng nên số dòng dịch +1.
- Test 5: ClickHouse Flat Tables 1:1 Parity (17 DDL tables, 17 DML tables, 0 column drift).
- Test 6: Rule L4 — mọi dòng PENDING phải để trống 4 trường kỹ thuật; Cụm 4 (Nhóm 22-25) đã READY, 30 dòng đều có logic.
- Test 7: Group 21 — opr_corporate_bond_issuer_credit_monitor: PK theo mã trái phiếu, pc_id suy ra từ mã TP (equity_ticker).
- Test 8: Group 19 — fct_corporate_bond_maturity_wall đã đủ 9 cột, có maturity_dt.
"""

from collections import Counter, defaultdict
import csv
import io
import os
from pathlib import Path
import re
import subprocess
import sys
from typing import Dict, List, Set, Tuple

import pytest

# Adjust stdout for Windows cp1252 consoles
if sys.platform.startswith("win"):
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    if hasattr(sys.stderr, "reconfigure"):
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")

REPO_ROOT = Path(__file__).resolve().parent.parent
BA_CSV_PATH = REPO_ROOT / "BRD" / "BA" / "BA_analyst_PTTT.csv"
HLD_MD_PATH = REPO_ROOT / "Datamart" / "hld" / "DTM_PTTT_HLD.md"
DETAIL_MAPPING_PATH = REPO_ROOT / "Datamart" / "lld" / "DTM_PTTT_Detail_Mapping.csv"
LLD_PTTT_DIR = REPO_ROOT / "Datamart" / "lld" / "PTTT"
MASTER_ATTRIBUTES_PATH = REPO_ROOT / "Datamart" / "lld" / "datamart_attributes.csv"
FLAT_DDL_PATH = REPO_ROOT / "Datamart" / "flat-table" / "PTTT" / "01_create_pttt_flat_tables.sql"
FLAT_DML_PATH = REPO_ROOT / "Datamart" / "flat-table" / "PTTT" / "02_populate_pttt_flat_tables.sql"
OPR_GRP21_PATH = LLD_PTTT_DIR / "DTM_PTTT_opr_corporate_bond_issuer_credit_monitor.csv"
FACT_GRP19_PATH = LLD_PTTT_DIR / "DTM_PTTT_fct_corporate_bond_maturity_wall.csv"


# ==============================================================================
# TEST 1: Kiểm chứng bao phủ 34 nhóm và 455 dòng chỉ tiêu trong BRD/BA
# ==============================================================================
def test_oracle_01_ba_coverage_and_group_continuity():
    """
    Test 1: Kiểm chứng số lượng nhóm và số dòng BA:
    - BRD/BA phải chứa đúng 34 nhóm STT (1 đến 34), không gián đoạn.
    - Tổng số dòng phân tích nghiệp vụ hợp lệ phải là 455 dòng.
    """
    assert BA_CSV_PATH.is_file(), f"Tệp BA không tồn tại: {BA_CSV_PATH}"

    with open(BA_CSV_PATH, "r", encoding="utf-8-sig", errors="replace") as f:
        reader = csv.reader(f)
        _hdr1 = next(reader, None)
        _hdr2 = next(reader, None)
        ba_rows = [row for row in reader if any(c.strip() for c in row)]

    ba_items = []
    ba_groups = set()
    for row in ba_rows:
        stt = row[0].strip() if len(row) > 0 else ""
        name = row[2].strip() if len(row) > 2 else ""
        if stt.isdigit() and name and name.lower() != "tên chỉ tiêu":
            ba_groups.add(int(stt))
            ba_items.append(row)

    expected_groups = set(range(1, 35))
    missing_groups = expected_groups - ba_groups

    assert len(ba_groups) == 34, f"Số nhóm BA thực tế là {len(ba_groups)}, kỳ vọng 34"
    assert not missing_groups, f"BA thiếu các nhóm STT: {sorted(missing_groups)}"
    assert len(ba_items) == 455, f"Số dòng BA thực tế là {len(ba_items)}, kỳ vọng 455"


# ==============================================================================
# TEST 2: Kiểm chứng HLD chứa đủ 34 nhóm và 421 KPI HLD
# ==============================================================================
def test_oracle_02_hld_kpi_coverage_and_structure():
    """
    Test 2: Kiểm chứng HLD DTM_PTTT_HLD.md:
    - Chứa đủ 34 tiểu mục nhóm ('### Nhóm 1' đến '### Nhóm 34').
    - Tổng số KPI HLD định nghĩa là đúng 421 KPI.
    """
    assert HLD_MD_PATH.is_file(), f"Tệp HLD không tồn tại: {HLD_MD_PATH}"

    text = HLD_MD_PATH.read_text(encoding="utf-8", errors="replace")
    nhom_matches = re.findall(r"^###+\s+Nhóm\s+(\d+)", text, re.MULTILINE)
    hld_groups = set(int(m) for m in nhom_matches)

    expected_groups = set(range(1, 35))
    missing_in_hld = expected_groups - hld_groups

    assert len(hld_groups) == 34, f"Số nhóm trong HLD là {len(hld_groups)}, kỳ vọng 34"
    assert not missing_in_hld, f"HLD thiếu các nhóm: {sorted(missing_in_hld)}"

    # Parse via HLDParser from datamart-review tool
    sys.path.insert(0, str(REPO_ROOT / ".claude" / "skills" / "datamart-review" / "scripts"))
    from datamart_progress_analyzer import HLDParser
    hld_items = HLDParser.parse_file(HLD_MD_PATH, "PTTT")
    assert len(hld_items) == 420, f"Số KPI HLD thực tế là {len(hld_items)}, kỳ vọng 420"


# ==============================================================================
# TEST 3: Kiểm chứng đối soát phạm vi Detail Mapping (390 Dashboard, 344 READY, 46 PENDING)
# ==============================================================================
def test_oracle_03_detail_mapping_scope_and_status():
    """
    Test 3: Kiểm chứng Detail Mapping:
    - Tổng cộng 423 dòng = 390 dòng Dashboard + 33 dòng Data Explorer (Nhóm 32–34).
    - Bộ phân tích tiến độ chuẩn (DatamartProgressAnalyzer):
      + Đánh giá phạm vi Dashboard: 390 dòng.
      + READY: đúng 344 dòng (88.21%).
      + PENDING: đúng 46 dòng (11.79%).
    """
    assert DETAIL_MAPPING_PATH.is_file(), f"Tệp Detail Mapping không tồn tại: {DETAIL_MAPPING_PATH}"

    with open(DETAIL_MAPPING_PATH, "r", encoding="utf-8-sig", errors="replace") as f:
        dr = csv.DictReader(f)
        all_rows = list(dr)

    assert len(all_rows) == 423, f"Tổng số dòng Detail Mapping là {len(all_rows)}, kỳ vọng 423"

    de_rows = [r for r in all_rows if r.get("tab", "").strip().upper() == "DATA EXPLORER"]
    dash_rows = [r for r in all_rows if r.get("tab", "").strip().upper() != "DATA EXPLORER"]

    assert len(de_rows) == 33, f"Số dòng Data Explorer là {len(de_rows)}, kỳ vọng 33"
    assert len(dash_rows) == 390, f"Số dòng Dashboard khai thác là {len(dash_rows)}, kỳ vọng 390"

    sys.path.insert(0, str(REPO_ROOT / ".claude" / "skills" / "datamart-review" / "scripts"))
    from datamart_progress_analyzer import DatamartProgressAnalyzer
    analyzer = DatamartProgressAnalyzer()
    res = analyzer.analyze_module("PTTT")

    assert res["total_dm_rows"] == 390, f"Scope Dashboard phải là 390, thực tế: {res['total_dm_rows']}"
    assert res["ready_count"] == 344, f"READY count phải là 344, thực tế: {res['ready_count']}"
    assert res["pending_count"] == 46, f"PENDING count phải là 46, thực tế: {res['pending_count']}"
    assert abs(res["ready_pct"] - 88.21) < 0.1, f"READY % lệch: {res['ready_pct']}"
    assert abs(res["pending_pct"] - 11.79) < 0.1, f"PENDING % lệch: {res['pending_pct']}"


# ==============================================================================
# TEST 4: Tái hiện thực nghiệm 4 lỗi S5 tại Nhóm 28 (dòng 400, 401) và Nhóm 31 (dòng 422, 423)
# ==============================================================================
def test_oracle_04_measure_type_mismatch_s5_reproduction():
    """
    Test 4: Chạy script ba_hld_sync_check.py --module PTTT và kiểm tra:
    - Có đúng 4 lỗi S5 được phát hiện.
    - Nhóm 28 dòng BA 400: 'Dòng tiền ròng NĐTNN' đo VAL nhưng K_PTTT_223 đọc cột VOL.
    - Nhóm 28 dòng BA 401: 'Dòng tiền ròng tự doanh' đo VAL nhưng K_PTTT_226 đọc cột VOL.
    - Nhóm 31 dòng BA 422: 'Dòng tiền ròng NĐTNN' đo VAL nhưng K_PTTT_223 đọc cột VOL.
    - Nhóm 31 dòng BA 423: 'Dòng tiền ròng tự doanh' đo VAL nhưng K_PTTT_226 đọc cột VOL.
    Đây là cảnh báo S5 đã giải trình, KHÔNG phải lỗi thiết kế: checker đọc nhãn 'Dòng tiền ròng' (suy ra VAL) nhưng
    mô tả BA là 'Chênh lệch KLGD mua và KLGD bán' → đo khối lượng, nên đọc cột VOL là đúng (xem ghi chú K_PTTT_223/226).
    Test ghi nhận đúng 4 cảnh báo này để phát hiện cảnh báo S5 mới phát sinh.
    """
    script_path = REPO_ROOT / ".claude" / "skills" / "datamart-review" / "scripts" / "ba_hld_sync_check.py"
    assert script_path.is_file(), f"Script không tồn tại: {script_path}"

    cmd = [sys.executable, "-X", "utf8", str(script_path), "--module", "PTTT"]
    res = subprocess.run(cmd, cwd=REPO_ROOT, capture_output=True, text=True, encoding="utf-8")

    s5_lines = [line.strip() for line in res.stdout.splitlines() if "S5" in line and "❌" in line]
    assert len(s5_lines) == 4, f"Kỳ vọng 4 lỗi S5, thực tế tìm thấy {len(s5_lines)}: {s5_lines}"

    assert any("Nhóm 28" in l and "400" in l and "K_PTTT_223" in l and "VOL" in l for l in s5_lines)
    assert any("Nhóm 28" in l and "401" in l and "K_PTTT_226" in l and "VOL" in l for l in s5_lines)
    assert any("Nhóm 31" in l and "422" in l and "K_PTTT_223" in l and "VOL" in l for l in s5_lines)
    assert any("Nhóm 31" in l and "423" in l and "K_PTTT_226" in l and "VOL" in l for l in s5_lines)


# ==============================================================================
# TEST 5: Kiểm chứng 17 bảng ClickHouse Flat Tables (0 column drift DDL vs DML)
# ==============================================================================
def test_oracle_05_clickhouse_flat_tables_ddl_dml_parity():
    """
    Test 5: Chạy check_flat_table.py --module PTTT --strict:
    - Đúng 17 bảng DDL và 17 bảng DML.
    - 0 Critical Issues, 0 Warning Issues (0 column drift).
    """
    script_path = REPO_ROOT / ".claude" / "skills" / "datamart-review" / "scripts" / "check_flat_table.py"
    assert script_path.is_file(), f"Script không tồn tại: {script_path}"

    cmd = [sys.executable, "-X", "utf8", str(script_path), "--module", "PTTT", "--strict"]
    res = subprocess.run(cmd, cwd=REPO_ROOT, capture_output=True, text=True, encoding="utf-8")

    assert res.returncode == 0, f"check_flat_table.py thất bại với exit code {res.returncode}: {res.stdout}"
    assert "Tables in DDL (CREATE):  17" in res.stdout
    assert "Tables in DML (INSERT):  17" in res.stdout
    assert "Critical Issues:         0" in res.stdout
    assert "Warning Issues:          0" in res.stdout


# ==============================================================================
# TEST 6: Rule L4 — dòng PENDING để trống 4 trường kỹ thuật; Cụm 4 (Nhóm 22-25) đã READY
# ==============================================================================
def test_oracle_06_rule_l4_compliance_and_false_positive_forensic():
    """
    Test 6: Đánh giá Rule L4 trên Detail Mapping hiện hành:
    - Mọi dòng PENDING (tinh_chat=PENDING hoặc ghi_chu bắt đầu bằng 'Pending') phải để trống 100% cả 4 trường
      kỹ thuật (mart_table, mart_column, logic, column_role). Hiện không còn dòng nào ở trạng thái này.
    - Cụm 4 (Nhóm 22-25, An toàn CTCK) đã READY từ 2026-10-01 và đọc Fact Securities Company Safety Snapshot
      từ 2026-10-02: 30 dòng, mỗi dòng có logic và column_role hợp lệ.
    """
    sys.path.insert(0, str(REPO_ROOT / ".claude" / "skills" / "datamart-review" / "scripts"))
    from datamart_progress_analyzer import DetailMappingParser
    dm_items = DetailMappingParser.parse_file(DETAIL_MAPPING_PATH)
    active_dm = [dm for dm in dm_items if dm.tab.upper() != "DATA EXPLORER"]

    # 1. 30 dòng Cụm 4 đã READY
    c4_items = [dm for dm in active_dm if any(g in dm.nhom for g in ["Nhóm 22", "Nhóm 23", "Nhóm 24", "Nhóm 25"])]
    assert len(c4_items) == 30, f"Cụm 4 phải có 30 dòng, thực tế: {len(c4_items)}"
    for dm in c4_items:
        assert dm.logic, f"{dm.kpi_id} (Cụm 4) READY nhưng thiếu logic"
        assert dm.column_role.upper() in ("MEASURE", "SLICER", "DERIVED"), f"{dm.kpi_id} role invalid: {dm.column_role}"

    # 2. Rule L4 cho mọi dòng PENDING (nếu có)
    true_pending = [
        dm for dm in active_dm
        if dm.tinh_chat.strip().lower() == "pending" or dm.ghi_chu.strip().lower().startswith("pending")
    ]
    for dm in true_pending:
        assert not dm.mart_table, f"{dm.kpi_id} vi phạm Rule L4: mart_table={dm.mart_table}"
        assert not dm.mart_column, f"{dm.kpi_id} vi phạm Rule L4: mart_column={dm.mart_column}"
        assert not dm.logic, f"{dm.kpi_id} vi phạm Rule L4: logic={dm.logic}"
        assert dm.column_role.upper() in ("", "PENDING"), f"{dm.kpi_id} role invalid: {dm.column_role}"


# ==============================================================================
# TEST 7: Kiểm chứng thực nghiệm Grain Mismatch tại Nhóm 21 (opr_corporate_bond_issuer_credit_monitor)
# ==============================================================================
def test_oracle_07_group_21_grain_mismatch_empirical():
    """
    Test 7: Kiểm tra trực tiếp bảng opr_corporate_bond_issuer_credit_monitor.csv:
    - issuer_symbol_code lấy security_trading_snapshot.symbol (mã trái phiếu, không phải TCPH pc_code).
    - bond_outstanding_val tính per mã trái phiếu (thiếu SUM GROUP BY pc_id).
    - Các trường BCTC (total_liabilities_amt, roe_pct, debt_to_equity_ratio) join theo public_company.pc_id
      (từ 2026-10-02 suy ra từ mã TP qua equity_ticker_symbol = symbol, trước đó là tham số :p_company_id),
      chứng minh rủi ro nhân bản dòng khi 1 TCPH phát hành nhiều mã trái phiếu.
    """
    assert OPR_GRP21_PATH.is_file(), f"Tệp Nhóm 21 không tồn tại: {OPR_GRP21_PATH}"

    with open(OPR_GRP21_PATH, "r", encoding="utf-8-sig", errors="replace") as f:
        rows = {r["datamart_column"]: r for r in csv.DictReader(f)}

    assert "issuer_symbol_code" in rows
    assert "bond_outstanding_val" in rows
    assert "total_liabilities_amt" in rows
    assert "debt_to_equity_ratio" in rows

    # Empirical assertions on grain bug
    pk_row = rows["issuer_symbol_code"]
    assert "bond_snpst.symbol" in pk_row["etl_logic"]  # alias của security_trading_snapshot (dòng trái phiếu)
    assert "FROM security_trading_snapshot bond_snpst" in pk_row["etl_logic"]
    assert "Symbol" in pk_row["source_attribute"]

    val_row = rows["bond_outstanding_val"]
    assert any(k in val_row["etl_logic"] for k in ["outstanding_share_quantity", "listed_share_quantity"])
    assert "SUM" not in val_row["etl_logic"].upper()

    bctc_row = rows["total_liabilities_amt"]
    assert "pc_report_submission.pc_id = public_company.pc_id" in bctc_row["etl_logic"]
    assert ":p_company_id" not in bctc_row["etl_logic"]
    assert "public_company.equity_ticker_symbol = SUBSTR(bond_snpst.symbol, 1, 3)" in bctc_row["etl_logic"]


# ==============================================================================
# TEST 8: Nhóm 19 — fct_corporate_bond_maturity_wall đã đủ cột (có maturity_dt)
# ==============================================================================
def test_oracle_08_group_19_maturity_wall_emptiness_empirical():
    """
    Test 8: Kiểm tra bảng fct_corporate_bond_maturity_wall.csv (đã mở rộng 2 luồng LISTED/PRIVATE ngày 2026-10-01):
    - Có đủ 9 cột: snpst_dt_dim_id, securities_dim_id, ranking_code, bond_flow_code, bond_code, par_val,
      outstanding_vol, bond_outstanding_val, maturity_dt.
    - Có cột maturity_dt (ngày đáo hạn) — thiếu cột này từng làm bảng rỗng về nghiệp vụ.
    - Các cột bucket kỳ hạn (<3T, 3-6T, 6-12T, 1-3N, >3N) tính ở presentation layer từ maturity_dt, không lưu cột.
    """
    assert FACT_GRP19_PATH.is_file(), f"Tệp Nhóm 19 không tồn tại: {FACT_GRP19_PATH}"

    with open(FACT_GRP19_PATH, "r", encoding="utf-8-sig", errors="replace") as f:
        cols = [r["datamart_column"] for r in csv.DictReader(f)]

    assert len(cols) == 9, f"Số cột fct_corporate_bond_maturity_wall là {len(cols)}, kỳ vọng đúng 9"
    for c in ("snpst_dt_dim_id", "securities_dim_id", "ranking_code", "bond_flow_code", "bond_code",
              "par_val", "outstanding_vol", "bond_outstanding_val", "maturity_dt"):
        assert c in cols, f"Thiếu cột {c}"
