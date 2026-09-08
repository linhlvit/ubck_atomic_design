# -*- coding: utf-8 -*-
"""
datamart_progress_analyzer.py — Automated Datamart Progress & Cross-Check Analyzer

Analyzes Datamart implementation progress against BA analyst specifications:
- Auto-detects delimiter (',' or ';'), encoding (utf-8-sig/BOM), and header row (0 or 1).
- Supports merged 'BA_analyst_GSĐC.csv' and all other modules (QLKD, GSTT, TKNB, GSĐC, etc.).
- Cross-Status Matrix: BA Status (Done, Doing, Pending, Chưa có) <-> Datamart Status (READY, PENDING, Chưa có).
- Pending Root-Cause Classification Tree (6 distinct categories).
- Group count reconciliation (BA count <-> HLD count <-> Detail Mapping count).
- CLI for single module or all modules with Markdown summary reporting and blocker lists.

Usage:
    python scripts/datamart_progress_analyzer.py --module QLKD
    python scripts/datamart_progress_analyzer.py --module all
    python scripts/datamart_progress_analyzer.py -m GSTT --detail -o reports/gstt_progress.md
"""

from __future__ import annotations

import argparse
import csv
import io
import json
import os
import re
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple

# Reconfigure standard output streams to utf-8 for Windows PowerShell / cmd
if sys.stdout.encoding != "utf-8":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except AttributeError:
        pass

if sys.stderr.encoding != "utf-8":
    try:
        sys.stderr.reconfigure(encoding="utf-8")
    except AttributeError:
        pass

# Increase CSV field size limit to handle large SQL queries or multi-line cells safely
try:
    csv.field_size_limit(min(sys.maxsize, 2147483647))
except (OverflowError, AttributeError):
    pass


MODULE_ALIASES = {
    "GSDC": "GSĐC",
    "GSĐC": "GSĐC",
    "FMS": "QLQ",
    "QLQ": "FMS",
}

REVERSE_MODULE_ALIASES = {
    "GSĐC": "GSDC",
    "GSDC": "GSDC",
    "FMS": "QLQ",
    "QLQ": "QLQ",
}


def normalize_module_code(mod: str) -> str:
    """Normalize module code for HLD/LLD artifacts."""
    m = mod.upper().strip()
    if m in ("GSĐC", "GSDC"):
        return "GSDC"
    if m in ("FMS", "QLQ"):
        return "QLQ"
    return m


def clean_kpi_name(name: str) -> str:
    """Strip common annotations like (reuse từ Nhóm X), (chiều lọc: ...), etc. and normalize variations."""
    if not name:
        return ""
    n = re.sub(r"\((?:reuse\s+từ|chiều\s*lọc|tham\s*số\s*lọc|filter|slicer).*?\)", "", name, flags=re.IGNORECASE)
    n = re.sub(r"\[(?:reuse\s+từ|chiều\s*lọc|tham\s*số\s*lọc|filter|slicer).*?\]", "", n, flags=re.IGNORECASE)
    n = re.sub(r"\s*\(\s*%\s*\)", "", n)
    n = re.sub(r"\s*\((?:giá\s+trị\s+trúng\s+thầu).*?\)", "", n, flags=re.IGNORECASE)
    # Normalize unicode dashes (em-dash \u2014, en-dash \u2013, minus \u2212, hyphen-like) to standard ASCII '-'
    n = re.sub(r"[\u2010\u2011\u2012\u2013\u2014\u2015\u2212\-]+", "-", n)
    n = re.sub(r"\s*-\s*", " - ", n)
    n = re.sub(r"so\s+(?:sánh\s+)?với\s+kỳ\s+trước", "so kỳ trước", n, flags=re.IGNORECASE)
    n = re.sub(r"\bny/", "niêm yết/", n, flags=re.IGNORECASE)
    n = re.sub(r"\bdòng\s+tiền\s+vào\b", "dòng vào", n, flags=re.IGNORECASE)
    n = re.sub(r"\bdòng\s+tiền\s+ra\b", "dòng ra", n, flags=re.IGNORECASE)
    n = re.sub(r"\bkhối\s+lượng\s+giao\s+dịch\b", "klgd", n, flags=re.IGNORECASE)
    n = re.sub(r"\bgiá\s+trị\s+giao\s+dịch\b", "gtgd", n, flags=re.IGNORECASE)
    n = re.sub(r"\bgiá\s+trị\b", "gt", n, flags=re.IGNORECASE)
    n = re.sub(r"\btpdn\s+riêng\s+lẻ\b", "tp", n, flags=re.IGNORECASE)
    n = re.sub(r"\btpdn\b", "tp", n, flags=re.IGNORECASE)
    n = re.sub(r"\s+", " ", n).strip(" -:–—()[]%")
    return n.lower()


def format_table_cell(val: Any) -> str:
    """Sanitize cell value for Markdown table: replace newlines with '<br>' and escape '|'."""
    if val is None:
        return ""
    s = str(val).strip()
    s = re.sub(r"\r?\n", "<br>", s)
    s = s.replace("|", "\\|")
    return s


@dataclass
class BAItem:
    stt: str
    dashboard: str
    name: str
    description: str
    requirement_group: str
    classification: str  # Phân loại: Chiều, Chỉ tiêu cơ sở, Chỉ tiêu phái sinh
    evaluation: str  # Đánh giá: Dễ, TB, Khó, Trùng
    mapping_status: str  # Trạng thái mapping: Done, Doing, Pending
    source_table: str
    source_column: str
    data_type: str  # Loại dữ liệu
    condition: str
    sql: str
    note: str
    raw_row: List[str] = field(default_factory=list)


@dataclass
class HLDItem:
    kpi_id: str
    name: str
    unit: str
    nature: str
    formula: str
    note: str
    status: str  # READY, PENDING, etc.
    group_num: Optional[int] = None
    group_name: str = ""


@dataclass
class DetailMappingItem:
    kpi_id: str
    tab: str
    nhom: str
    kpi_name: str
    tinh_chat: str
    source_module: str
    mart_table: str
    mart_column: str
    column_role: str
    logic: str
    ghi_chu: str
    group_num: Optional[int] = None


class BAParser:
    """Robust parser for BA analyst CSV files."""

    @staticmethod
    def detect_delimiter_and_header(raw_content: str) -> Tuple[str, int, List[str], List[List[str]]]:
        """Detect delimiter (',' or ';') and header row index (0 or 1)."""
        raw_content = raw_content.lstrip("\ufeff")
        best_delim = ";"
        best_cols = 0

        for delim in (";", ","):
            try:
                reader = csv.reader(io.StringIO(raw_content), delimiter=delim)
                sample_rows = []
                for _ in range(10):
                    try:
                        sample_rows.append(next(reader))
                    except StopIteration:
                        break
                if sample_rows:
                    max_cols = max(len(r) for r in sample_rows)
                    if max_cols > best_cols:
                        best_cols = max_cols
                        best_delim = delim
            except Exception:
                pass

        try:
            reader = csv.reader(io.StringIO(raw_content), delimiter=best_delim)
            all_rows = list(reader)
        except csv.Error:
            reader = csv.reader(io.StringIO(raw_content), delimiter=best_delim, quoting=csv.QUOTE_NONE)
            all_rows = list(reader)

        if not all_rows:
            return best_delim, 0, [], []

        # Robust header detection: scan top 10 rows with keyword scoring
        best_hdr_idx = 0
        best_score = -1
        for idx in range(min(10, len(all_rows))):
            row = all_rows[idx]
            non_empty = sum(1 for x in row if x.strip())
            row_str = " ".join(x.lower() for x in row)
            score = non_empty
            if "stt" in row_str or "tt" in row_str:
                score += 5
            if "thông tin" in row_str or "chỉ tiêu" in row_str or "tên" in row_str:
                score += 5
            if "phân loại" in row_str:
                score += 5
            if "trạng thái" in row_str:
                score += 5
            if "bảng nguồn" in row_str or "nguồn" in row_str or "khai thác" in row_str:
                score += 5
            if "loại dữ liệu" in row_str or "điều kiện" in row_str or "mô tả" in row_str:
                score += 3
            if score > best_score:
                best_score = score
                best_hdr_idx = idx

        hdr_idx = best_hdr_idx
        header = [x.lstrip("\ufeff").strip() for x in all_rows[hdr_idx]]
        data_rows = all_rows[hdr_idx + 1 :]

        return best_delim, hdr_idx, header, data_rows

    @classmethod
    def parse_file(cls, filepath: Path) -> List[BAItem]:
        """Parse BA CSV file into a list of BAItem objects with robust encoding support."""
        if not filepath.exists():
            return []

        raw_bytes = filepath.read_bytes()
        raw_text: Optional[str] = None

        # Check BOM for UTF-16
        if raw_bytes.startswith(b"\xff\xfe") or raw_bytes.startswith(b"\xfe\xff"):
            try:
                raw_text = raw_bytes.decode("utf-16")
            except UnicodeDecodeError:
                pass

        # Check null bytes for UTF-16 without BOM
        if raw_text is None and b"\x00" in raw_bytes[:100]:
            for enc in ("utf-16", "utf-16le", "utf-16be"):
                try:
                    raw_text = raw_bytes.decode(enc)
                    break
                except UnicodeDecodeError:
                    pass

        # Fallback encodings: UTF-8 with BOM, CP1258 (Vietnamese Windows), mac_roman, latin-1
        if raw_text is None:
            for enc in ("utf-8-sig", "cp1258", "mac_roman", "latin-1"):
                try:
                    raw_text = raw_bytes.decode(enc)
                    break
                except UnicodeDecodeError:
                    pass

        if raw_text is None:
            raw_text = raw_bytes.decode("latin-1", errors="replace")

        _, _, header, data_rows = cls.detect_delimiter_and_header(raw_text)
        col_map = {name: i for i, name in enumerate(header) if name}

        def get_col(candidates: List[str]) -> Optional[int]:
            for cand in candidates:
                for col_name, idx in col_map.items():
                    if col_name.strip().lower() == cand.lower():
                        return idx
            return None

        stt_idx = get_col(["STT", "TT"])
        ma_idx = get_col(["Mã", "Ma", "Group", "Nhóm"])
        dash_idx = get_col(["Dashboard/báo cáo", "Dashboard >> báo cáo", "Dashboard/BC", "Mã dashboard/BC"])
        name_idx = get_col(["Thông tin", "Thông tin (chỉ tiêu)", "Tên chỉ tiêu", "Chỉ tiêu"])
        desc_idx = get_col(["Mô tả"])
        req_idx = get_col(["Nhóm yêu cầu"])
        pl_idx = get_col(["Phân loại"])
        dg_idx = get_col(["Đánh giá"])
        status_idx = get_col(["Trạng thái mapping", "Trạng thái"])
        src_tbl_idx = get_col(["Bảng nguồn", "Nguồn", "Khai thác nguồn", "Nguồn chi tiết"])
        src_col_idx = get_col(["Trường nguồn"])
        type_idx = get_col(["Loại dữ liệu"])
        cond_idx = get_col(["Điều kiện", "Điều kiện chung", "Điều kiện dữ liệu"])
        sql_idx = get_col(["Câu lệnh tham khảo", "Câu lệnh SQL", "Câu lệnh update SIT"])
        note_idx = get_col(["Note"])

        def val(row: List[str], idx: Optional[int]) -> str:
            if idx is not None and len(row) > idx:
                return row[idx].strip()
            return ""

        items = []
        for r in data_rows:
            if not any(x.strip() for x in r):
                continue
            # Skip duplicated header or template/instruction row
            if pl_idx is not None and val(r, pl_idx).lower() in ("phân loại", "chiều/chỉ tiêu cơ sở/chỉ tiêu phái sinh"):
                continue
            if stt_idx is not None and val(r, stt_idx).lower() in ("stt", "tt"):
                continue

            name = val(r, name_idx)
            stt = val(r, stt_idx)
            ma = val(r, ma_idx)

            # Prioritize group code from 'Mã' if 'STT' is empty or contains BRD section path like '3.2.2.1'
            if ma and (not stt or "." in stt or not stt.isdigit()):
                clean_ma = re.sub(r"^(?:nhóm|group)\s*", "", ma, flags=re.IGNORECASE).strip()
                if clean_ma.isdigit():
                    stt = clean_ma
                elif not stt:
                    stt = ma
            elif not stt and ma:
                stt = ma

            # Skip rows without dashboard or without indicator name
            if not val(r, dash_idx) or not name:
                continue

            # Skip instruction rows like 'Tên chiều/chỉ tiêu/thuộc tính'
            if "tên chiều/chỉ tiêu" in name.lower() or "thông tin (chỉ tiêu)" in name.lower():
                continue

            # Skip section header/title rows that have no classification, status, and source table
            if not val(r, pl_idx) and not val(r, status_idx) and not val(r, src_tbl_idx):
                continue

            item = BAItem(
                stt=stt,
                dashboard=val(r, dash_idx),
                name=name,
                description=val(r, desc_idx),
                requirement_group=val(r, req_idx),
                classification=val(r, pl_idx),
                evaluation=val(r, dg_idx),
                mapping_status=val(r, status_idx),
                source_table=val(r, src_tbl_idx),
                source_column=val(r, src_col_idx),
                data_type=val(r, type_idx),
                condition=val(r, cond_idx),
                sql=val(r, sql_idx),
                note=val(r, note_idx),
                raw_row=r,
            )
            items.append(item)

        return items


class HLDParser:
    """Parser for Datamart HLD Markdown documents."""

    @staticmethod
    def parse_file(filepath: Path, module: str) -> List[HLDItem]:
        if not filepath.exists():
            return []

        text = filepath.read_text(encoding="utf-8-sig", errors="replace")
        lines = text.splitlines()

        items = []
        curr_group_num: Optional[int] = None
        curr_group_name: str = ""
        in_ready_block = False
        in_pending_block = False

        mod_clean = normalize_module_code(module)
        kpi_prefix = f"K_{mod_clean}_"

        for line in lines:
            line_s = line.strip()

            m_nhom = re.search(r"^\s*#{2,5}\s*(?:Nhóm|Group)\s*(\d+)[a-zA-Z]?(?:\s*[-–—:]\s*(.*?))?$", line_s, re.IGNORECASE)
            if m_nhom:
                curr_group_num = int(m_nhom.group(1))
                curr_group_name = m_nhom.group(2).strip() if m_nhom.group(2) else f"Nhóm {curr_group_num}"
                in_ready_block = False
                in_pending_block = False

            if re.match(r"^#{4,5}\s+READY\b", line_s, re.IGNORECASE):
                in_ready_block = True
                in_pending_block = False
            elif re.match(r"^#{4,5}\s+PENDING\b", line_s, re.IGNORECASE):
                in_pending_block = True
                in_ready_block = False

            if line_s.startswith("|") and ("|" in line_s):
                parts = [p.strip() for p in line_s.split("|")[1:-1]]
                kpi_raw = parts[0].strip("`* ") if parts else ""
                if parts and (
                    re.match(rf"^{re.escape(kpi_prefix)}\d+", kpi_raw)
                    or (re.match(r"^K_[A-Z0-9]+_\d+", kpi_raw) and mod_clean in kpi_raw)
                ):
                    kpi_id = kpi_raw
                    kpi_name = parts[1] if len(parts) > 1 else ""
                    unit = parts[2] if len(parts) > 2 else ""
                    nature = parts[3] if len(parts) > 3 else ""

                    if len(parts) >= 7:
                        formula = parts[4]
                        note = parts[5]
                        raw_status = parts[6]
                    elif len(parts) == 6:
                        formula = parts[4]
                        note = ""
                        raw_status = parts[5]
                    else:
                        formula = parts[4] if len(parts) > 4 else ""
                        note = ""
                        raw_status = ""

                    raw_upper = raw_status.upper()
                    if "READY" in raw_upper:
                        status = "READY"
                    elif "PENDING" in raw_upper:
                        status = "PENDING"
                    elif in_ready_block:
                        status = "READY"
                    elif in_pending_block:
                        status = "PENDING"
                    else:
                        status = "READY" if raw_status else "READY"

                    item = HLDItem(
                        kpi_id=kpi_id,
                        name=kpi_name,
                        unit=unit,
                        nature=nature,
                        formula=formula,
                        note=note,
                        status=status,
                        group_num=curr_group_num,
                        group_name=curr_group_name,
                    )
                    items.append(item)

        return items


class DetailMappingParser:
    """Parser for Datamart Detail Mapping CSV."""

    @staticmethod
    def parse_file(filepath: Path) -> List[DetailMappingItem]:
        if not filepath.exists():
            return []

        items = []
        text = filepath.read_text(encoding="utf-8-sig", errors="replace").lstrip("\ufeff")
        reader = csv.DictReader(io.StringIO(text))
        if reader.fieldnames:
            reader.fieldnames = [f.lstrip("\ufeff").strip() if f else f for f in reader.fieldnames]

        for r in reader:
            kpi_id = (r.get("kpi_id") or "").strip().strip("`* ")
            tab = (r.get("tab") or "").strip()
            nhom = (r.get("nhom") or "").strip()
            kpi_name = (r.get("kpi_name") or "").strip()
            tinh_chat = (r.get("tinh_chat") or "").strip()
            source_module = (r.get("source_module") or "").strip()
            mart_table = (r.get("mart_table") or "").strip()
            mart_column = (r.get("mart_column") or "").strip()
            column_role = (r.get("column_role") or "").strip()
            logic = (r.get("logic") or "").strip()
            ghi_chu = (r.get("ghi_chu") or "").strip()

            if not any((kpi_id, kpi_name, mart_table, mart_column, logic)):
                continue

            m_grp = re.search(r"Nhóm\s*(\d+)", nhom, re.IGNORECASE)
            group_num = int(m_grp.group(1)) if m_grp else None

            item = DetailMappingItem(
                kpi_id=kpi_id,
                tab=tab,
                nhom=nhom,
                kpi_name=kpi_name,
                tinh_chat=tinh_chat,
                source_module=source_module,
                mart_table=mart_table,
                mart_column=mart_column,
                column_role=column_role,
                logic=logic,
                ghi_chu=ghi_chu,
                group_num=group_num,
            )
            items.append(item)

        return items


class PendingClassifier:
    """
    Pending Root-Cause Classification Tree (Requirement R2):
    1. BA Pending: BA chưa phân tích xong hoặc chưa xác định nguồn.
    2. Chưa có mapping nguồn từ BA: Cột nguồn trống, N/A hoặc chú thích chưa có CSDL / map biểu mẫu.
    3. Thiếu nguồn dữ liệu ngoại lai: Cần dữ liệu từ hệ thống ngoài (UAT_VSDC, VSD, SCMS, etc.).
    4. Join đa nguồn phức tạp: Yêu cầu kết hợp dữ liệu giữa nhiều hệ thống chưa được chuẩn hóa ở Atomic.
    5. Datamart Pending: BA đã Done và nguồn đầy đủ, nhưng Datamart chưa thiết kế Fact/Dim hoặc Detail Mapping.
    6. Lệch số lượng / Schema out of sync: Lệch số dòng KPI giữa BA và HLD, hoặc trỏ tới bảng Atomic chưa approved.
    """

    REASON_BA_PENDING = "1. BA Pending (Chưa phân tích / chưa hoàn thành)"
    REASON_NO_BA_SOURCE = "2. Chưa có mapping nguồn từ BA (Nguồn trống / N/A / Chưa có CSDL)"
    REASON_EXTERNAL_SOURCE = "3. Thiếu nguồn dữ liệu ngoại lai (VSDC, VSD, SCMS, v.v.)"
    REASON_COMPLEX_JOIN = "4. Join đa nguồn phức tạp (NHNCK & SCMS, đa hệ thống)"
    REASON_DATAMART_PENDING = "5. Datamart Pending (Có nguồn, chưa thiết kế Fact/Dim/Detail Mapping)"
    REASON_SCHEMA_OUT_OF_SYNC = "6. Lệch số lượng / Schema out of sync (Lệch dòng / Atomic chưa approved)"

    @classmethod
    def classify(
        cls,
        kpi_name: str,
        ba_status: str,
        ba_source: str,
        ba_data_type: str,
        group_name: str = "",
        ghi_chu: str = "",
        has_count_mismatch: bool = False,
    ) -> str:
        kpi_lower = kpi_name.lower()
        src_lower = ba_source.lower().strip()
        dt_lower = ba_data_type.lower()
        st_upper = ba_status.upper().strip()
        nhom_lower = group_name.lower()
        note_lower = ghi_chu.lower()

        # 1. BA Pending: BA chưa phân tích xong
        if st_upper and st_upper not in ("DONE", "HOÀN THÀNH", "HOAN THANH", "KHÔNG TÌM THẤY TRONG BA"):
            return cls.REASON_BA_PENDING

        # 2. Chưa có mapping nguồn từ BA (Nguồn trống / N/A / Chưa có CSDL / Map biểu mẫu)
        if (
            not src_lower
            or src_lower in ("n/a", "(trống)", "null", "none")
            or any(k in src_lower for k in ["chưa có csdl", "chưa có nguồn", "chưa số hóa", "biểu mẫu giấy"])
            or any(k in dt_lower for k in ["chưa có csdl", "map biểu mẫu"])
            or any(k in note_lower for k in ["chưa có csdl", "chưa có nguồn", "chưa số hóa", "biểu mẫu giấy", "map biểu mẫu"])
            or src_lower == "chưa có"
        ):
            return cls.REASON_NO_BA_SOURCE

        # 3. Thiếu nguồn dữ liệu ngoại lai (inspect both source and notes for external systems)
        external_keywords = ["uat_vsdc", "vsdc", "vsd", "hose", "hnx", "sbv", "ngoại lai", "ngoại lai"]
        if (
            any(k in src_lower for k in external_keywords)
            or any(k in note_lower for k in external_keywords)
            or "thị phần" in kpi_lower
            or "vsd" in kpi_lower
            or "vsdc" in kpi_lower
        ):
            return cls.REASON_EXTERNAL_SOURCE

        # 4. Join đa nguồn phức tạp
        multi_source_keywords = ["scms_nhnck", "scms_uat", "join", "đa nguồn", "multi-source", "liên hệ thống"]
        if (
            any(k in src_lower for k in multi_source_keywords)
            or any(k in note_lower for k in ["scms_nhnck", "scms và nhnck", "join đa nguồn", "multi-source join"])
            or ("scms" in src_lower and "nhnck" in src_lower)
            or ("chứng chỉ" in kpi_lower and "hành nghề" in kpi_lower)
            or ("người hành nghề" in nhom_lower and "scms" in src_lower)
        ):
            return cls.REASON_COMPLEX_JOIN

        # 6. Schema out of sync / count mismatch if explicitly flagged or group has count mismatch
        schema_keywords = [
            "mismatch",
            "out of sync",
            "chưa approved",
            "chưa duyệt",
            "deprecated",
            "out of date",
            "atomic chưa",
        ]
        has_schema_note = any(k in note_lower for k in schema_keywords) or bool(
            re.search(r"(?<!chênh\s)\blệch\b", note_lower)
        )
        if has_count_mismatch or has_schema_note:
            return cls.REASON_SCHEMA_OUT_OF_SYNC

        # 5. Datamart Pending (source exists and BA is done, but Datamart pending)
        return cls.REASON_DATAMART_PENDING


class DatamartProgressAnalyzer:
    """Coordinates progress analysis and cross-check reporting."""

    def __init__(self, root_dir: Path):
        self.root_dir = root_dir
        self.ba_dir = root_dir / "BRD" / "BA"
        self.hld_dir = root_dir / "Datamart" / "hld"
        self.lld_dir = root_dir / "Datamart" / "lld"

    def find_module_files(self, module: str) -> Tuple[Optional[Path], Optional[Path], Optional[Path]]:
        mod_upper = module.upper().strip()

        # BA file candidate names (e.g. QLQ -> FMS, GSDC -> GSĐC)
        ba_names = [mod_upper]
        if mod_upper in ("QLQ", "FMS"):
            ba_names.extend(["FMS", "QLQ"])
        if mod_upper in ("GSDC", "GSĐC"):
            ba_names.extend(["GSĐC", "GSDC"])

        ba_candidates = [self.ba_dir / f"BA_analyst_{n}.csv" for n in ba_names]
        ba_path = next((p for p in ba_candidates if p.exists()), None)

        # Datamart HLD/LLD candidate names (e.g. FMS -> QLQ, GSĐC -> GSDC)
        dm_names = [mod_upper]
        if mod_upper in ("FMS", "QLQ"):
            dm_names.extend(["QLQ", "FMS"])
        if mod_upper in ("GSĐC", "GSDC"):
            dm_names.extend(["GSDC", "GSĐC"])

        hld_candidates = [self.hld_dir / f"DTM_{n}_HLD.md" for n in dm_names]
        hld_path = next((p for p in hld_candidates if p.exists()), None)

        dm_candidates = [self.lld_dir / f"DTM_{n}_Detail_Mapping.csv" for n in dm_names]
        dm_path = next((p for p in dm_candidates if p.exists()), None)

        return ba_path, hld_path, dm_path

    @staticmethod
    def extract_reuse_group(text: str) -> Optional[str]:
        """Extract source group number if indicator is reused from another group."""
        m = re.search(r"reuse\s+(?:từ\s+)?(?:READY\s+)?(?:Nhóm|Group)\s*(\d+)", text, re.IGNORECASE)
        if m:
            return m.group(1)
        return None

    def find_ba_match(
        self,
        name: str,
        group_num: Optional[int],
        note: str = "",
        formula: str = "",
        ba_by_grp: Optional[Dict[str, List[BAItem]]] = None,
        ba_by_name: Optional[Dict[str, List[BAItem]]] = None,
        ba_by_name_clean: Optional[Dict[str, List[BAItem]]] = None,
    ) -> Optional[BAItem]:
        if not ba_by_grp or not ba_by_name:
            return None

        combined_text = f"{name} {note} {formula}"
        reuse_grp = self.extract_reuse_group(combined_text)

        curr_grp = str(group_num) if group_num is not None else ""
        search_grps = []
        if reuse_grp:
            search_grps.append(reuse_grp)
        if curr_grp and curr_grp not in search_grps:
            search_grps.append(curr_grp)

        clean_n = clean_kpi_name(name)
        raw_n = name.strip().lower()

        # 1. Search in target groups (reuse group first, then current group)
        for g in search_grps:
            cands = ba_by_grp.get(g, [])
            for b in cands:
                if b.name.strip().lower() == raw_n or clean_kpi_name(b.name) == clean_n:
                    return b
            for b in cands:
                clean_b = clean_kpi_name(b.name)
                if len(clean_n) >= 4 and (clean_n in clean_b or clean_b in clean_n):
                    return b

        # 2. Global search across all groups
        if ba_by_name_clean and clean_n in ba_by_name_clean:
            return ba_by_name_clean[clean_n][0]
        if raw_n in ba_by_name:
            return ba_by_name[raw_n][0]

        # 2b. Global substring match (len >= 6)
        if ba_by_name_clean:
            for b_clean, blist in ba_by_name_clean.items():
                if len(clean_n) >= 6 and (clean_n in b_clean or b_clean in clean_n):
                    return blist[0]

        return None

    def analyze_module(self, module: str, include_data_explorer: bool = False) -> Dict[str, Any]:
        mod_normalized = module.upper()
        ba_path, hld_path, dm_path = self.find_module_files(mod_normalized)

        ba_items = BAParser.parse_file(ba_path) if ba_path else []
        hld_items = HLDParser.parse_file(hld_path, mod_normalized) if hld_path else []
        dm_items = DetailMappingParser.parse_file(dm_path) if dm_path else []

        # Index BA items
        ba_by_name: Dict[str, List[BAItem]] = defaultdict(list)
        ba_by_grp: Dict[str, List[BAItem]] = defaultdict(list)
        ba_by_name_clean: Dict[str, List[BAItem]] = defaultdict(list)
        for b in ba_items:
            norm_name = b.name.strip().lower()
            clean_n = clean_kpi_name(b.name)
            ba_by_name[norm_name].append(b)
            if clean_n:
                ba_by_name_clean[clean_n].append(b)
            if b.stt:
                ba_by_grp[b.stt].append(b)

        # Index HLD items
        hld_by_id: Dict[str, HLDItem] = {h.kpi_id: h for h in hld_items}
        hld_by_name: Dict[str, HLDItem] = {h.name.strip().lower(): h for h in hld_items if h.name}
        hld_by_name_clean: Dict[str, HLDItem] = {clean_kpi_name(h.name): h for h in hld_items if h.name}

        # Filter Detail Mapping if data explorer is excluded
        active_dm_items = []
        for dm in dm_items:
            if not include_data_explorer and dm.tab.upper() == "DATA EXPLORER":
                continue
            active_dm_items.append(dm)

        has_dm_items = len(active_dm_items) > 0
        has_dm_file = dm_path is not None and dm_path.exists() and has_dm_items

        # Group reconciliation
        group_stats = defaultdict(lambda: {"ba_total": 0, "ba_done_doing": 0, "hld_kpis": 0, "dm_rows": 0, "name": ""})

        for b in ba_items:
            if b.stt:
                group_stats[b.stt]["ba_total"] += 1
                if b.mapping_status.strip() in ("Done", "Doing", "Hoàn thành"):
                    group_stats[b.stt]["ba_done_doing"] += 1
                if b.dashboard and not group_stats[b.stt]["name"]:
                    group_stats[b.stt]["name"] = b.dashboard

        for h in hld_items:
            grp_key = str(h.group_num) if h.group_num is not None else "0"
            group_stats[grp_key]["hld_kpis"] += 1
            if h.group_name and not group_stats[grp_key]["name"]:
                group_stats[grp_key]["name"] = h.group_name

        for dm in active_dm_items:
            grp_key = str(dm.group_num) if dm.group_num is not None else "0"
            group_stats[grp_key]["dm_rows"] += 1
            if dm.nhom and not group_stats[grp_key]["name"]:
                group_stats[grp_key]["name"] = dm.nhom

        # Identify groups with count mismatch
        mismatch_groups = set()
        for grp_key, st in group_stats.items():
            if grp_key in ("0", ""):
                continue
            ba_cnt = st["ba_done_doing"]
            hld_cnt = st["hld_kpis"]
            dm_cnt = st["dm_rows"]

            is_gsdc_bctc = (mod_normalized in ("GSDC", "GSĐC") and grp_key.isdigit() and 21 <= int(grp_key) <= 30)

            ba_hld_diff = (ba_cnt != hld_cnt) and (ba_cnt > 0 or hld_cnt > 0)
            if has_dm_file:
                if is_gsdc_bctc and (hld_cnt * 2 <= dm_cnt <= hld_cnt * 3):
                    hld_dm_diff = False
                else:
                    hld_dm_diff = (hld_cnt != dm_cnt) and (hld_cnt > 0 or dm_cnt > 0)
            else:
                hld_dm_diff = False

            if ba_hld_diff or hld_dm_diff:
                mismatch_groups.add(grp_key)

        matrix = {
            "Done": {"READY": 0, "PENDING": 0, "Chưa có": 0},
            "Doing": {"READY": 0, "PENDING": 0, "Chưa có": 0},
            "Pending": {"READY": 0, "PENDING": 0, "Chưa có": 0},
            "Chưa xác định": {"READY": 0, "PENDING": 0, "Chưa có": 0},
            "Chưa có trong BA": {"READY": 0, "PENDING": 0, "Chưa có": 0},
        }

        classified_pending = defaultdict(list)
        matched_ba_keys = set()

        if has_dm_items:
            evaluated_layer = "LLD"
            dm_ready_items = []
            dm_pending_items = []

            for dm in active_dm_items:
                is_pending = False
                ghi_chu_lower = dm.ghi_chu.lower()
                tinh_chat_lower = dm.tinh_chat.lower()
                is_resolved = bool(re.search(r"\b(?:resolved|đã giải quyết|đã xử lý|đã tháo gỡ)\b", ghi_chu_lower))

                hld_match = hld_by_id.get(dm.kpi_id)

                if tinh_chat_lower == "pending":
                    is_pending = True
                elif "pending" in ghi_chu_lower and not is_resolved:
                    is_pending = True
                elif dm.column_role.upper() == "DERIVED":
                    if not dm.logic or ("pending" in dm.logic.lower() and not is_resolved):
                        is_pending = True
                elif not dm.mart_table:
                    is_pending = True

                if hld_match and hld_match.status == "PENDING":
                    is_pending = True
                elif is_resolved and hld_match and hld_match.status == "READY":
                    is_pending = False

                if is_pending:
                    dm_pending_items.append(dm)
                else:
                    dm_ready_items.append(dm)

            total_dm = len(active_dm_items)
            ready_count = len(dm_ready_items)
            pending_count = len(dm_pending_items)

            for dm in dm_pending_items:
                grp_str = str(dm.group_num) if dm.group_num is not None else ""

                ba_match = self.find_ba_match(
                    name=dm.kpi_name,
                    group_num=dm.group_num,
                    note=dm.ghi_chu,
                    formula=dm.logic,
                    ba_by_grp=ba_by_grp,
                    ba_by_name=ba_by_name,
                    ba_by_name_clean=ba_by_name_clean,
                )

                ba_status = ba_match.mapping_status if ba_match else ""
                ba_source = ba_match.source_table if ba_match else ""
                ba_data_type = ba_match.data_type if ba_match else ""

                is_grp_mismatch = grp_str in mismatch_groups

                reason = PendingClassifier.classify(
                    kpi_name=dm.kpi_name,
                    ba_status=ba_status,
                    ba_source=ba_source,
                    ba_data_type=ba_data_type,
                    group_name=dm.nhom,
                    ghi_chu=dm.ghi_chu,
                    has_count_mismatch=is_grp_mismatch,
                )
                classified_pending[reason].append({
                    "kpi_id": dm.kpi_id,
                    "kpi_name": dm.kpi_name,
                    "nhom": dm.nhom,
                    "group_num": dm.group_num,
                    "ba_status": ba_status or "Không tìm thấy trong BA",
                    "ba_source": ba_source or "(trống)",
                    "ghi_chu": dm.ghi_chu,
                    "reason": reason,
                })

            for dm in active_dm_items:
                ba_match = self.find_ba_match(
                    name=dm.kpi_name,
                    group_num=dm.group_num,
                    note=dm.ghi_chu,
                    formula=dm.logic,
                    ba_by_grp=ba_by_grp,
                    ba_by_name=ba_by_name,
                    ba_by_name_clean=ba_by_name_clean,
                )

                is_ready = dm in dm_ready_items
                dm_col = "READY" if is_ready else "PENDING"

                if ba_match:
                    matched_ba_keys.add(id(ba_match))
                    st = ba_match.mapping_status.strip().title()
                    if st in ("Done", "Hoàn Thành", "Hoanthanh"):
                        matrix["Done"][dm_col] += 1
                    elif st in ("Doing", "Đang Xem Xét"):
                        matrix["Doing"][dm_col] += 1
                    elif st in ("Pending", "Failed"):
                        matrix["Pending"][dm_col] += 1
                    else:
                        matrix["Chưa xác định"][dm_col] += 1
                else:
                    matrix["Chưa có trong BA"][dm_col] += 1

        elif len(hld_items) > 0:
            # Fallback to HLD items when Detail Mapping is not yet implemented
            evaluated_layer = "HLD"
            hld_ready_items = [h for h in hld_items if h.status.upper() == "READY"]
            hld_pending_items = [h for h in hld_items if h.status.upper() == "PENDING"]

            total_dm = len(hld_items)
            ready_count = len(hld_ready_items)
            pending_count = len(hld_pending_items)

            for h in hld_pending_items:
                grp_str = str(h.group_num) if h.group_num is not None else ""
                combined_note = f"{h.formula}; {h.note}" if h.note else h.formula

                ba_match = self.find_ba_match(
                    name=h.name,
                    group_num=h.group_num,
                    note=h.note,
                    formula=h.formula,
                    ba_by_grp=ba_by_grp,
                    ba_by_name=ba_by_name,
                    ba_by_name_clean=ba_by_name_clean,
                )

                ba_status = ba_match.mapping_status if ba_match else ""
                ba_source = ba_match.source_table if ba_match else ""
                ba_data_type = ba_match.data_type if ba_match else ""

                is_grp_mismatch = grp_str in mismatch_groups

                reason = PendingClassifier.classify(
                    kpi_name=h.name,
                    ba_status=ba_status,
                    ba_source=ba_source,
                    ba_data_type=ba_data_type,
                    group_name=h.group_name or f"Nhóm {grp_str}",
                    ghi_chu=combined_note,
                    has_count_mismatch=is_grp_mismatch,
                )
                classified_pending[reason].append({
                    "kpi_id": h.kpi_id,
                    "kpi_name": h.name,
                    "nhom": h.group_name or f"Nhóm {grp_str}",
                    "group_num": h.group_num,
                    "ba_status": ba_status or "Không tìm thấy trong BA",
                    "ba_source": ba_source or "(trống)",
                    "ghi_chu": combined_note,
                    "reason": reason,
                })

            for h in hld_items:
                ba_match = self.find_ba_match(
                    name=h.name,
                    group_num=h.group_num,
                    note=h.note,
                    formula=h.formula,
                    ba_by_grp=ba_by_grp,
                    ba_by_name=ba_by_name,
                    ba_by_name_clean=ba_by_name_clean,
                )

                dm_col = "READY" if h in hld_ready_items else "PENDING"

                if ba_match:
                    matched_ba_keys.add(id(ba_match))
                    st = ba_match.mapping_status.strip().title()
                    if st in ("Done", "Hoàn Thành", "Hoanthanh"):
                        matrix["Done"][dm_col] += 1
                    elif st in ("Doing", "Đang Xem Xét"):
                        matrix["Doing"][dm_col] += 1
                    elif st in ("Pending", "Failed"):
                        matrix["Pending"][dm_col] += 1
                    else:
                        matrix["Chưa xác định"][dm_col] += 1
                else:
                    matrix["Chưa có trong BA"][dm_col] += 1

        else:
            evaluated_layer = "None"
            total_dm = 0
            ready_count = 0
            pending_count = 0

        # Check BA items that are not in Datamart ("Chưa có")
        for b in ba_items:
            if id(b) not in matched_ba_keys:
                norm_name = b.name.strip().lower()
                clean_n = clean_kpi_name(b.name)
                if norm_name not in hld_by_name and clean_n not in hld_by_name_clean:
                    st = b.mapping_status.strip().title()
                    if st in ("Done", "Hoàn Thành", "Hoanthanh"):
                        matrix["Done"]["Chưa có"] += 1
                    elif st in ("Doing", "Đang Xem Xét"):
                        matrix["Doing"]["Chưa có"] += 1
                    elif st in ("Pending", "Failed"):
                        matrix["Pending"]["Chưa có"] += 1
                    else:
                        matrix["Chưa xác định"]["Chưa có"] += 1

        return {
            "module": mod_normalized,
            "ba_file": str(ba_path) if ba_path else None,
            "hld_file": str(hld_path) if hld_path else None,
            "dm_file": str(dm_path) if dm_path else None,
            "has_dm_file": has_dm_file,
            "evaluated_layer": evaluated_layer,
            "total_ba_rows": len(ba_items),
            "total_hld_kpis": len(hld_items),
            "total_dm_rows": total_dm,
            "ready_count": ready_count,
            "pending_count": pending_count,
            "ready_pct": (ready_count / total_dm * 100.0) if total_dm > 0 else 0.0,
            "pending_pct": (pending_count / total_dm * 100.0) if total_dm > 0 else 0.0,
            "classified_pending": classified_pending,
            "cross_status_matrix": matrix,
            "group_stats": dict(sorted(group_stats.items(), key=lambda x: int(x[0]) if x[0].isdigit() else 999)),
            "mismatch_groups": sorted(list(mismatch_groups), key=lambda x: int(x) if x.isdigit() else 999),
        }

    def generate_markdown_report(self, analysis: Dict[str, Any], show_detail: bool = False) -> str:
        mod = analysis["module"]
        total_dm = analysis["total_dm_rows"]
        ready = analysis["ready_count"]
        pending = analysis["pending_count"]
        ready_pct = analysis["ready_pct"]
        pending_pct = analysis["pending_pct"]
        matrix = analysis["cross_status_matrix"]
        classified = analysis["classified_pending"]
        group_stats = analysis["group_stats"]

        has_dm_file = analysis.get("has_dm_file", False)
        layer = analysis.get("evaluated_layer", "LLD")

        if ready_pct >= 90.0:
            status_ready = "🟢 Đạt"
        elif ready_pct > 0.0:
            status_ready = "🟡 Đang hoàn thiện"
        else:
            status_ready = "🔴 Chưa có" if total_dm == 0 else "🔴 0.0%"

        if pending == 0:
            status_pending = "🟢 Không có nợ đọng"
        elif pending_pct <= 10.0:
            status_pending = "🟡 Thấp (kiểm soát được)"
        else:
            status_pending = "🔴 Cần tháo gỡ"

        md = []
        md.append(f"# Báo cáo Tiến độ & Đối soát Thiết kế Datamart — Module {mod}")
        md.append("")
        md.append("## 1. Tổng quan Trạng thái Thiết kế")
        md.append("")
        md.append(f"- **BA Analyst File:** `{analysis['ba_file'] or 'Không tìm thấy'}` (Tổng số dòng BA: **{analysis['total_ba_rows']}**)")
        md.append(f"- **HLD File:** `{analysis['hld_file'] or 'Không tìm thấy'}` (Tổng số KPI HLD: **{analysis['total_hld_kpis']}**)")
        if has_dm_file:
            md.append(f"- **Detail Mapping File:** `{analysis['dm_file']}` (Tổng số dòng Mapping: **{total_dm}**)")
        else:
            md.append("- **Detail Mapping File:** `Không tìm thấy` (Chưa thiết kế LLD Detail Mapping — tiến độ và blocker đánh giá từ HLD)")
        md.append("")
        md.append("| Chỉ số | Số lượng | Tỷ lệ (%) | Trạng thái |")
        md.append("|---|---|---|---|")
        scope_title = "Tổng số chỉ tiêu khai thác (Dashboard/Report)" if layer == "LLD" else "Tổng số chỉ tiêu khai thác (HLD)"
        md.append(f"| **{scope_title}** | **{total_dm}** | 100.0% | |")
        md.append(f"| **READY (Thiết kế hoàn tất)** | **{ready}** | **{ready_pct:.1f}%** | {status_ready} |")
        md.append(f"| **PENDING (Đang chờ xử lý)** | **{pending}** | **{pending_pct:.1f}%** | {status_pending} |")
        md.append("")

        # 2. Cross-Status Matrix
        md.append("## 2. Ma trận Đối soát Tiến độ (Cross-status Matrix)")
        md.append("")
        md.append("Đối chiếu chéo giữa trạng thái phân tích BA (`Trạng thái mapping`) và trạng thái thiết kế Datamart:")
        md.append("")
        md.append("| Trạng thái BA \\ Trạng thái Datamart | READY (Datamart) | PENDING (Datamart) | Chưa có trong Datamart | Tổng chỉ tiêu BA |")
        md.append("|---|---|---|---|---|")

        total_row_ready = 0
        total_row_pending = 0
        total_row_missing = 0

        for ba_st in ("Done", "Doing", "Pending", "Chưa xác định", "Chưa có trong BA"):
            row = matrix[ba_st]
            r_ready = row["READY"]
            r_pending = row["PENDING"]
            r_missing = row["Chưa có"]
            r_total = r_ready + r_pending + r_missing
            total_row_ready += r_ready
            total_row_pending += r_pending
            total_row_missing += r_missing
            md.append(f"| **BA {ba_st}** | {r_ready} | {r_pending} | {r_missing} | {r_total} |")

        md.append(f"| **Tổng cộng Datamart** | **{total_row_ready}** | **{total_row_pending}** | **{total_row_missing}** | **{total_row_ready + total_row_pending + total_row_missing}** |")
        md.append("")

        # 3. Pending Root Cause Classification Tree
        md.append("## 3. Cây phân loại Chi tiết Nguyên nhân PENDING")
        md.append("")
        md.append("Phân loại 100% các chỉ tiêu PENDING theo 6 nhóm nguyên nhân chuẩn hóa:")
        md.append("")
        md.append("| Nhóm nguyên nhân | Số lượng KPI | Tỷ lệ / PENDING | Đơn vị chủ trì xử lý | Hành động tháo gỡ |")
        md.append("|---|---|---|---|---|")

        all_reasons = [
            PendingClassifier.REASON_BA_PENDING,
            PendingClassifier.REASON_NO_BA_SOURCE,
            PendingClassifier.REASON_EXTERNAL_SOURCE,
            PendingClassifier.REASON_COMPLEX_JOIN,
            PendingClassifier.REASON_DATAMART_PENDING,
            PendingClassifier.REASON_SCHEMA_OUT_OF_SYNC,
        ]

        action_map = {
            PendingClassifier.REASON_BA_PENDING: ("BA Team", "BA hoàn thành khảo sát và cung cấp nguồn"),
            PendingClassifier.REASON_NO_BA_SOURCE: ("BA Team", "Làm rõ nguồn CSDL hoặc loại bỏ biểu mẫu chưa số hóa"),
            PendingClassifier.REASON_EXTERNAL_SOURCE: ("Data Architecture / VSDC", "Thiết lập kết nối/ingest dữ liệu ngoại lai vào DWH"),
            PendingClassifier.REASON_COMPLEX_JOIN: ("Atomic Modeling", "Chuẩn hóa entity và mối quan hệ join tại lớp Atomic"),
            PendingClassifier.REASON_DATAMART_PENDING: ("Datamart Modeling", "Thiết kế Fact/Dim và hoàn thiện Detail Mapping"),
            PendingClassifier.REASON_SCHEMA_OUT_OF_SYNC: ("HLD / LLD Review", "Đồng bộ lại số dòng KPI giữa BA và HLD/LLD"),
        }

        for r_name in all_reasons:
            items = classified.get(r_name, [])
            count = len(items)
            pct = (count / pending * 100.0) if pending > 0 else 0.0
            owner, action = action_map[r_name]
            md.append(f"| **{r_name}** | {count} | {pct:.1f}% | {owner} | {action} |")

        md.append("")

        # 4. Group Count Reconciliation
        md.append("## 4. Ma trận Đối soát Số lượng Chỉ tiêu theo Nhóm (BA ↔ HLD ↔ Detail Mapping)")
        md.append("")
        md.append("| Nhóm | Tên Nhóm | BA (Done/Doing) | HLD (KPI Count) | Detail Mapping | Lệch BA ↔ HLD | Lệch HLD ↔ DM | Cảnh báo |")
        md.append("|---|---|---|---|---|---|---|---|")

        for grp_key, st in group_stats.items():
            if grp_key in ("0", ""):
                continue
            ba_cnt = st["ba_done_doing"]
            hld_cnt = st["hld_kpis"]
            dm_cnt = st["dm_rows"]
            diff_ba_hld = hld_cnt - ba_cnt

            ba_hld_diff = (ba_cnt != hld_cnt) and (ba_cnt > 0 or hld_cnt > 0)
            if has_dm_file:
                diff_hld_dm = dm_cnt - hld_cnt
                hld_dm_diff = (hld_cnt != dm_cnt) and (hld_cnt > 0 or dm_cnt > 0)
                diff_dm_str = f"{'+' if diff_hld_dm > 0 else ''}{diff_hld_dm}"
                dm_cnt_str = str(dm_cnt)
            else:
                diff_hld_dm = None
                hld_dm_diff = False
                diff_dm_str = "Chưa có DM"
                dm_cnt_str = "-"

            is_mismatch = ba_hld_diff or hld_dm_diff

            # Domain awareness: GSĐC BCTC groups 21-30 are intentionally duplicated 3x
            is_gsdc_bctc = (analysis["module"] in ("GSDC", "GSĐC") and grp_key.isdigit() and 21 <= int(grp_key) <= 30)
            if is_gsdc_bctc and has_dm_file and (hld_cnt * 2 <= dm_cnt <= hld_cnt * 3):
                status_tag = "🟡 Lệch x2.7~3 (chuẩn hóa 3 loại hình DN/BH/TCTD)"
            elif is_mismatch:
                status_tag = "🔴 Lệch số lượng"
            else:
                status_tag = "🟢 Khớp" if has_dm_file else "🟢 Khớp (HLD)"

            grp_name = format_table_cell(st["name"][:45] + "..." if len(st["name"]) > 45 else st["name"])
            diff_ba_str = f"{'+' if diff_ba_hld > 0 else ''}{diff_ba_hld}"

            md.append(
                f"| Nhóm {grp_key} | {grp_name} | {ba_cnt} | {hld_cnt} | {dm_cnt_str} | "
                f"{diff_ba_str} | {diff_dm_str} | {status_tag} |"
            )

        md.append("")

        # 5. Blocker Action List
        md.append("## 5. Danh sách Blocker & Kế hoạch Hành động Cụ thể")
        md.append("")
        md.append("### 5.1. Nhóm chỉ tiêu cần BA Team giải quyết (Blocker từ Nguồn / Nghiệp vụ)")
        md.append("")
        ba_blockers = (
            classified.get(PendingClassifier.REASON_BA_PENDING, [])
            + classified.get(PendingClassifier.REASON_NO_BA_SOURCE, [])
            + classified.get(PendingClassifier.REASON_EXTERNAL_SOURCE, [])
        )
        if ba_blockers:
            md.append(f"Tổng cộng: **{len(ba_blockers)}** chỉ tiêu đang vướng nguồn/nghiệp vụ.")
            md.append("")
            md.append("| KPI ID | Tên Chỉ tiêu | Nhóm | Lý do vướng | Nguồn hiện ghi |")
            md.append("|---|---|---|---|---|")
            for b in ba_blockers[:30]:
                reason_full = b.get("reason", "")
                if "1. BA Pending" in reason_full:
                    reason_desc = "BA chưa hoàn thành khảo sát"
                elif "2. Chưa có mapping" in reason_full:
                    reason_desc = "Chưa có CSDL / Map biểu mẫu"
                elif "3. Thiếu nguồn" in reason_full:
                    reason_desc = "Thiếu nguồn dữ liệu ngoại lai"
                else:
                    reason_desc = b.get("ba_status") or "Chưa rõ lý do"
                c_kid = format_table_cell(b['kpi_id'])
                c_kn = format_table_cell(b['kpi_name'])
                c_nhom = format_table_cell(b['nhom'])
                c_reason = format_table_cell(reason_desc)
                c_src = format_table_cell(b['ba_source'])
                md.append(f"| `{c_kid}` | {c_kn} | {c_nhom} | {c_reason} | {c_src} |")
            if len(ba_blockers) > 30:
                md.append(f"| ... | *(Còn {len(ba_blockers) - 30} chỉ tiêu khác — xem chi tiết khi chạy với `--detail`)* | | | |")
        else:
            md.append("Không có blocker nào thuộc nhóm này.")
        md.append("")

        md.append("### 5.2. Nhóm chỉ tiêu cần Datamart Team giải quyết (Đã có nguồn nhưng chưa thiết kế)")
        md.append("")
        if not has_dm_file:
            md.append(f"> ⚠️ **Cảnh báo tiến độ LLD:** Phân hệ `{mod}` hiện chưa có tệp Detail Mapping (`DTM_{mod}_Detail_Mapping.csv`). Sau khi chốt HLD, cần gọi skill `datamart-lld-design` để thiết kế toàn bộ mapping bảng mart và logic ETL.")
            md.append("")
        dm_blockers = (
            classified.get(PendingClassifier.REASON_DATAMART_PENDING, [])
            + classified.get(PendingClassifier.REASON_COMPLEX_JOIN, [])
            + classified.get(PendingClassifier.REASON_SCHEMA_OUT_OF_SYNC, [])
        )
        if dm_blockers:
            md.append(f"Tổng cộng: **{len(dm_blockers)}** chỉ tiêu có nguồn khả dụng nhưng Datamart chưa hoàn thiện Fact/Dim.")
            md.append("")
            md.append("| KPI ID | Tên Chỉ tiêu | Nhóm | Bảng nguồn BA | Hướng giải quyết đề xuất |")
            md.append("|---|---|---|---|---|")
            for b in dm_blockers[:30]:
                reason_full = b.get("reason", "")
                if "6. Lệch số lượng" in reason_full:
                    action_text = "Đồng bộ lại số dòng KPI giữa BA và HLD/LLD"
                elif "4. Join đa nguồn" in reason_full:
                    action_text = "Tạo Atomic bridge / multi-source join"
                elif "join" in b["ba_source"].lower() or "scms" in b["ba_source"].lower():
                    action_text = "Tạo Atomic bridge / multi-source join"
                else:
                    action_text = "Gọi datamart-lld-design bổ sung mapping"
                c_kid = format_table_cell(b['kpi_id'])
                c_kn = format_table_cell(b['kpi_name'])
                c_nhom = format_table_cell(b['nhom'])
                c_src = format_table_cell(b['ba_source'])
                c_act = format_table_cell(action_text)
                md.append(f"| `{c_kid}` | {c_kn} | {c_nhom} | {c_src} | {c_act} |")
            if len(dm_blockers) > 30:
                md.append(f"| ... | *(Còn {len(dm_blockers) - 30} chỉ tiêu khác — xem chi tiết khi chạy với `--detail`)* | | | |")
        else:
            md.append("Không có blocker nào thuộc nhóm này.")
        md.append("")

        if show_detail:
            md.append("## 6. Danh sách Chi tiết Toàn bộ Chỉ tiêu PENDING")
            md.append("")
            for r_name, items in classified.items():
                md.append(f"### {r_name} ({len(items)} chỉ tiêu)")
                md.append("")
                md.append("| KPI ID | Tên Chỉ tiêu | Nhóm | Trạng thái BA | Nguồn BA | Ghi chú |")
                md.append("|---|---|---|---|---|---|")
                for it in items:
                    c_kid = format_table_cell(it['kpi_id'])
                    c_kn = format_table_cell(it['kpi_name'])
                    c_nhom = format_table_cell(it['nhom'])
                    c_st = format_table_cell(it['ba_status'])
                    c_src = format_table_cell(it['ba_source'])
                    c_note = format_table_cell(it['ghi_chu'])
                    md.append(f"| `{c_kid}` | {c_kn} | {c_nhom} | {c_st} | {c_src} | {c_note} |")
                md.append("")

        return "\n".join(md)

    def scan_all_modules(self) -> List[str]:
        """Discover all module codes present in BRD/BA directory."""
        modules = []
        for p in sorted(self.ba_dir.glob("BA_analyst_*.csv")):
            name = p.stem.replace("BA_analyst_", "")
            if name.endswith("_part1") or name.endswith("_part2") or name.endswith("_part3"):
                continue
            modules.append(name)
        return modules


def main():
    if sys.platform.startswith("win"):
        if hasattr(sys.stdout, "reconfigure"):
            sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        if hasattr(sys.stderr, "reconfigure"):
            sys.stderr.reconfigure(encoding="utf-8", errors="replace")

    parser = argparse.ArgumentParser(description="Datamart Progress & Cross-Check Analyzer CLI")
    parser.add_argument("-m", "--module", type=str, default="all", help="Module to analyze (e.g. QLKD, GSTT, TKNB, GSĐC, or 'all')")
    parser.add_argument("--root", type=str, default=None, help="Root directory path (default auto-detected)")
    parser.add_argument("-o", "--output", type=str, default=None, help="Output Markdown report file path")
    parser.add_argument("--detail", action="store_true", help="Include exhaustive list of all pending indicators")
    parser.add_argument("--include-de", action="store_true", help="Include DATA EXPLORER tab in counts")
    parser.add_argument("--json", action="store_true", help="Output JSON structure instead of Markdown")

    args = parser.parse_args()

    # Determine root directory
    if args.root:
        root_dir = Path(args.root).resolve()
    else:
        curr = Path.cwd().resolve()
        if (curr / "BRD" / "BA").exists():
            root_dir = curr
        elif (curr / "ubck_atomic_design" / "BRD" / "BA").exists():
            root_dir = curr / "ubck_atomic_design"
        elif (curr.parent / "BRD" / "BA").exists():
            root_dir = curr.parent
        else:
            root_dir = curr

    analyzer = DatamartProgressAnalyzer(root_dir)

    target_mod = args.module.strip()
    if target_mod.lower() == "all":
        modules = analyzer.scan_all_modules()
        if not modules:
            print("No modules found in BRD/BA.", file=sys.stderr)
            sys.exit(1)
    else:
        ba_path, hld_path, dm_path = analyzer.find_module_files(target_mod)
        if not ba_path and not hld_path and not dm_path:
            print(f"Error: No files found for module '{target_mod}'. Expected BA, HLD, or Detail Mapping file.", file=sys.stderr)
            sys.exit(1)
        modules = [target_mod]

    results = []
    reports = []

    for mod in modules:
        res = analyzer.analyze_module(mod, include_data_explorer=args.include_de)
        results.append(res)
        rep = analyzer.generate_markdown_report(res, show_detail=args.detail)
        reports.append(rep)

    if args.json:
        out_json = json.dumps(results, ensure_ascii=False, indent=2)
        if args.output:
            out_path = Path(args.output)
            out_path.parent.mkdir(parents=True, exist_ok=True)
            out_path.write_text(out_json, encoding="utf-8")
            print(f"JSON report written successfully to: {out_path}")
        else:
            print(out_json)
        return

    full_report = "\n\n---\n\n".join(reports)

    if args.output:
        out_path = Path(args.output)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(full_report, encoding="utf-8")
        print(f"Report written successfully to: {out_path}")
    else:
        print(full_report)


if __name__ == "__main__":
    main()
