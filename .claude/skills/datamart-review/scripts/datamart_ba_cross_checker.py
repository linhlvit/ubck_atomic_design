# -*- coding: utf-8 -*-
"""
datamart_ba_cross_checker.py — BA vs Datamart Cross-Checker, PENDING Classifier & Detail Mapping Linter

Features:
1. Windows UTF-8 console safety (sys.stdout/stderr reconfigure, CSV field size limit).
2. Flexible BA file parsing:
   - Dynamic delimiter detection (',' vs ';').
   - Heuristic keyword scoring for header line detection (Line 1 vs Line 2).
   - Robust multi-encoding support (utf-8, utf-8-sig / BOM, cp1258, utf-16, latin-1).
   - Column alias dictionary mapping across all 11 BA analyst file variations.
3. 5-Category PENDING Root-Cause Decision Tree:
   (1) BA chưa mapping xong (BA Team)
   (2) Chưa có mapping nguồn từ BA (BA Team)
   (3) Thiếu nguồn dữ liệu / Atomic entity ngoài scope (Data Architecture / Atomic)
   (4) Cần join phức tạp đa nguồn (Atomic Modeling)
   (5) Datamart chưa thiết kế Fact/Dim (Datamart Modeling Team)
4. Detail Mapping Linter Engine:
   - REUSE rule: If role != DERIVED, must have mart_table and mart_column.
   - PENDING rule (Rule L4): All 4 columns (mart_table, mart_column, column_role, logic) must be empty.
   - DERIVED rule: mart_table and mart_column must both be empty; formula in logic.
   - DEPRECATED rule: column_role = 'DEPRECATED' and mart_table/mart_column empty.
5. CLI options: --module, --strict, --lint-detail-mapping, --json, --output, --path.

Usage:
    python scripts/datamart_ba_cross_checker.py --module GSTT
    python scripts/datamart_ba_cross_checker.py --module all --strict
    python scripts/datamart_ba_cross_checker.py --module TKNB --lint-detail-mapping
    python scripts/datamart_ba_cross_checker.py -m QLKD --json -o reports/qlkd_audit.json
"""
from __future__ import annotations

import argparse
import csv
import io
import json
import os
import difflib
import re
import sys
import unicodedata
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple, Union

# ---------------------------------------------------------------------------
# 1. Windows Console Safety & Environment Initialization
# ---------------------------------------------------------------------------
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

# Increase CSV field size limit to handle large SQL queries or multi-line cells safely
try:
    csv.field_size_limit(min(sys.maxsize, 2147483647))
except (OverflowError, AttributeError):
    pass


# ---------------------------------------------------------------------------
# 2. Module Name Normalization & Path Resolution
# ---------------------------------------------------------------------------
MODULE_ALIASES: Dict[str, str] = {
    "GSDC": "GSĐC",
    "GSĐC": "GSĐC",
    "GSTT": "GSTT",
    "QLKD": "QLKD",
    "TT": "TT",
    "NHNCK": "NHNCK",
    "PTTT": "PTTT",
    "QLQ": "QLQ",
    "FMS": "QLQ",
    "QLCB": "QLCB",
    "TKNB": "TKNB",
    "VP": "VP",
    "NDTNN": "NĐTNN",
    "NĐTNN": "NĐTNN",
}


def strip_accents(s: str) -> str:
    """Strip Vietnamese diacritics for flexible file matching."""
    s = s.replace("Đ", "D").replace("đ", "d")
    nfkd = unicodedata.normalize("NFKD", s)
    return "".join([c for c in nfkd if not unicodedata.combining(c)])


def normalize_module_name(module_name: str) -> str:
    """Normalize module name to standard uppercase representation."""
    cleaned = module_name.strip().upper()
    return MODULE_ALIASES.get(cleaned, cleaned)


def find_project_root(start_path: Optional[Union[str, Path]] = None) -> Path:
    """Auto-detect repository root directory containing 'Datamart' and 'BRD'."""
    p = Path(start_path).resolve() if start_path else Path.cwd().resolve()
    curr: Optional[Path] = p
    while curr is not None and curr != curr.parent:
        if (curr / "Datamart").is_dir() and (curr / "BRD").is_dir():
            return curr
        if (curr / "ubck_atomic_design" / "Datamart").is_dir():
            return curr / "ubck_atomic_design"
        curr = curr.parent
    file_dir = Path(__file__).resolve().parent
    for parent in [file_dir] + list(file_dir.parents):
        if (parent / "Datamart").is_dir() and (parent / "BRD").is_dir():
            return parent
    return p


def resolve_ba_path(root_dir: Path, module: str) -> Optional[Path]:
    """Find BA CSV file for the given module in BRD/BA."""
    mod_norm = normalize_module_name(module)
    mod_stripped = strip_accents(mod_norm)
    candidates = [mod_norm, mod_stripped, module.strip()]
    ba_dir = root_dir / "BRD" / "BA"
    if not ba_dir.is_dir():
        return None

    for m in candidates:
        candidate = ba_dir / f"BA_analyst_{m}.csv"
        if candidate.is_file():
            return candidate
        candidate_part1 = ba_dir / f"BA_analyst_{m}_part1.csv"
        if candidate_part1.is_file():
            return candidate_part1

    # Case-insensitive fallback
    for f in ba_dir.glob("*.csv"):
        f_name_upper = f.name.upper()
        for m in candidates:
            if f"BA_ANALYST_{m.upper()}" in f_name_upper:
                return f
    return None


def resolve_detail_mapping_path(root_dir: Path, module: str) -> Optional[Path]:
    """Find Detail Mapping CSV file for the given module in Datamart/lld."""
    mod_norm = normalize_module_name(module)
    mod_stripped = strip_accents(mod_norm)
    candidates = [mod_norm, mod_stripped, module.strip()]
    lld_dir = root_dir / "Datamart" / "lld"
    if not lld_dir.is_dir():
        return None

    for m in candidates:
        candidate = lld_dir / f"DTM_{m}_Detail_Mapping.csv"
        if candidate.is_file():
            return candidate

    for f in lld_dir.glob("*.csv"):
        f_upper = f.name.upper()
        for m in candidates:
            if f"DTM_{m.upper()}_DETAIL_MAPPING" in f_upper:
                return f
    return None


def get_available_modules(root_dir: Path) -> List[str]:
    """Discover all available Datamart module codes that have a Detail Mapping CSV."""
    lld_dir = root_dir / "Datamart" / "lld"
    found_modules: Set[str] = set()
    if lld_dir.is_dir():
        for f in lld_dir.glob("DTM_*_Detail_Mapping.csv"):
            stem = f.stem  # e.g. DTM_GSTT_Detail_Mapping
            parts = stem.split("_")
            if len(parts) >= 3 and parts[0] == "DTM":
                mod = parts[1]
                found_modules.add(mod)
    return sorted(list(found_modules))


# ---------------------------------------------------------------------------
# 3. BA File Parsing & Column Aliases
# ---------------------------------------------------------------------------
COLUMN_ALIASES: Dict[str, List[str]] = {
    "stt": ["stt", "tt"],
    "ma": ["mã", "mã dashboard/bc", "ma", "group", "nhóm", "pic"],
    "dashboard": ["dashboard/báo cáo", "dashboard >> báo cáo", "dashboard/bc", "mã dashboard/bc"],
    "name": ["thông tin", "thông tin (chỉ tiêu)", "tên chỉ tiêu", "chỉ tiêu"],
    "description": ["mô tả"],
    "requirement_group": ["nhóm yêu cầu"],
    "classification": ["phân loại"],
    "evaluation": ["đánh giá"],
    "mapping_status": ["trạng thái mapping", "trạng thái"],
    "source_table": ["bảng nguồn", "nguồn", "khai thác nguồn", "nguồn chi tiết", "nguồn dữ liệu", "mapping nguồn dữ liệu"],
    "source_column": ["trường nguồn", "cột nguồn"],
    "data_type": ["loại dữ liệu"],
    "condition": ["điều kiện", "điều kiện chung", "điều kiện dữ liệu"],
    "sql": ["câu lệnh tham khảo", "câu lệnh sql", "sit sql", "câu lệnh update sit", "câu lệnh update (sit)"],
    "note": ["note", "chú ý", "ghi chú"],
}


def clean_kpi_name(name: str) -> str:
    """Normalize indicator name for robust cross-matching."""
    if not name:
        return ""
    n = re.sub(r"\((?:reuse\s+từ|chiều\s*lọc|tham\s*số\s*lọc|filter|slicer).*?\)", "", name, flags=re.IGNORECASE)
    n = re.sub(r"\[(?:reuse\s+từ|chiều\s*lọc|tham\s*số\s*lọc|filter|slicer).*?\]", "", n, flags=re.IGNORECASE)
    n = re.sub(r"\s*\(\s*%\s*\)", "", n)
    n = re.sub(r"\s*\((?:giá\s+trị\s+trúng\s+thầu).*?\)", "", n, flags=re.IGNORECASE)
    n = re.sub(r"[\u2010\u2011\u2012\u2013\u2014\u2015\u2212\-]+", "-", n)
    n = re.sub(r"\s*-\s*", " - ", n)
    n = re.sub(r"so\s+(?:sánh\s+)?với\s+kỳ\s+trước", "so kỳ trước", n, flags=re.IGNORECASE)
    n = re.sub(r"\bny/", "niêm yết/", n, flags=re.IGNORECASE)
    n = re.sub(r"\bdòng\s+tiền\s+vào\b", "dòng vào", n, flags=re.IGNORECASE)
    n = re.sub(r"\bdòng\s+tiền\s+ra\b", "dòng ra", n, flags=re.IGNORECASE)
    # Abbreviation normalization — specific patterns first, then general
    n = re.sub(r"\bkhối\s+lượng\s+giao\s+dịch\b", "klgd", n, flags=re.IGNORECASE)
    n = re.sub(r"\bgiá\s+trị\s+giao\s+dịch\b", "gtgd", n, flags=re.IGNORECASE)
    n = re.sub(r"\bkhối\s+lượng\b", "kl", n, flags=re.IGNORECASE)
    n = re.sub(r"\bgiá\s+trị\b", "gt", n, flags=re.IGNORECASE)
    n = re.sub(r"\btpdn\s+riêng\s+lẻ\b", "tp", n, flags=re.IGNORECASE)
    n = re.sub(r"\btpdn\b", "tp", n, flags=re.IGNORECASE)
    # Synonym normalization for common Vietnamese wording variants
    n = re.sub(r"\bđang\s+lưu\s+hành\b", "lưu hành", n, flags=re.IGNORECASE)
    n = re.sub(r"\btrong\s+1\s+ngày\b", "trong ngày", n, flags=re.IGNORECASE)
    n = re.sub(r"\bcủa\s+các\s+loại\s+hợp\s+đồng\s+phái\s+sinh\b", "phái sinh", n, flags=re.IGNORECASE)
    n = re.sub(r"\bcủa\s+trái\s+phiếu\b", "phái sinh", n, flags=re.IGNORECASE)
    # GSTT specific domain pattern alignments
    n = re.sub(r"\bgiữa\s+klgd/klgdtb\s+trong\s+(\d+)\s+ngày\s+lớn\s+hơn\s+x\s+lần\b", r"klgd/klgdtb \1 ngày", n, flags=re.IGNORECASE)
    n = re.sub(r"\btỷ\s+lệ\s+klgd/klgdtb\s+(\d+)\s+ngày\b", r"klgd/klgdtb \1 ngày", n, flags=re.IGNORECASE)
    n = re.sub(r"\bcủa\s+cổ\s+phiếu\s+(?:đang\s+)?lưu\s+hành\b", "lưu hành", n, flags=re.IGNORECASE)
    n = re.sub(r"\bcủa\s+cổ\s+phiếu\s+tự\s+do\s+chuyển\s+nhượng\b", "tự do chuyển nhượng", n, flags=re.IGNORECASE)
    n = re.sub(r"\bđiểm\s+đóng\s+góp\s+tương\s+đối\b", "tương đối", n, flags=re.IGNORECASE)
    n = re.sub(r"\s*-\s*tương\s*đối(?:\s*\([^)]*\))?", " tương đối", n, flags=re.IGNORECASE)
    n = re.sub(r"\b(?:theo\s+từng\s+time|tại\s+thời\s+điểm\s+time)\s+trong\s+(?:1\s+)?ngày\b", "theo time trong ngày", n, flags=re.IGNORECASE)
    n = re.sub(r"\b(?:khối\s+lượng|kl)\s+niêm\s+(?:cổ\s+phiếu\s+)?niêm\s+yết\s+hiện\s+tại\b", "kl niêm yết hiện tại", n, flags=re.IGNORECASE)
    n = re.sub(r"\b4/52\s+tuần\b", "52 tuần", n, flags=re.IGNORECASE)
    n = re.sub(r"\btổng\s+klgd\s+khớp\s+lệnh\b", "klgd khớp lệnh", n, flags=re.IGNORECASE)
    n = re.sub(r"\btổng\s+gtgd\s+khớp\s+lệnh\b", "gtgd khớp lệnh", n, flags=re.IGNORECASE)
    n = re.sub(r"\btổng\s+kl\s+thỏa\s+thuận\b", "klgd thỏa thuận", n, flags=re.IGNORECASE)
    n = re.sub(r"\btổng\s+gt\s+thỏa\s+thuận\b", "gtgd thỏa thuận", n, flags=re.IGNORECASE)
    # Normalize spaces inside parentheses: "( thỏa thuận )" -> "(thỏa thuận)"
    n = re.sub(r"\(\s+", "(", n)
    n = re.sub(r"\s+\)", ")", n)
    # Collapse whitespace — do NOT strip () to avoid asymmetric parenthesis removal
    n = re.sub(r"\s+", " ", n).strip(" -:–—[]%")
    return n.lower()


def strip_qualifiers(name: str) -> str:
    """Strip all parenthesized qualifiers for fallback matching.

    Useful when DTM adds context in parens that BA doesn't have, e.g.:
    - DTM: 'Giá đóng cửa (điểm chỉ số)' -> 'Giá đóng cửa'
    - DTM: 'KLNN ròng (theo chỉ số)' -> 'KLNN ròng'
    """
    return re.sub(r"\s*\([^)]*\)", "", name).strip()


@dataclass
class BAItem:
    line_num: int
    stt: str
    ma: str
    dashboard: str
    name: str
    description: str
    requirement_group: str
    classification: str
    evaluation: str
    mapping_status: str
    source_table: str
    source_column: str
    data_type: str
    condition: str
    sql: str
    note: str
    raw_row: List[str] = field(default_factory=list)


class BAParser:
    """Flexible parser for BA analyst CSV files."""

    @staticmethod
    def read_text_safe(filepath: Path) -> Tuple[str, str]:
        """Read file raw bytes and detect encoding safely."""
        raw = filepath.read_bytes()
        # UTF-8 BOM
        if raw.startswith(b"\xef\xbb\xbf"):
            return raw.decode("utf-8-sig", errors="replace").lstrip("\ufeff"), "utf-8-sig"
        # UTF-16 BOM
        if raw.startswith(b"\xff\xfe") or raw.startswith(b"\xfe\xff"):
            try:
                return raw.decode("utf-16", errors="replace"), "utf-16"
            except Exception:
                pass
        # Try UTF-8 strict
        try:
            return raw.decode("utf-8"), "utf-8"
        except UnicodeDecodeError:
            pass
        # Fallback cp1258 / latin-1
        for enc in ("cp1258", "latin-1"):
            try:
                return raw.decode(enc, errors="replace"), enc
            except Exception:
                pass
        return raw.decode("latin-1", errors="replace"), "latin-1"

    @staticmethod
    def detect_delimiter_and_header(raw_content: str) -> Tuple[str, int, List[str], List[List[str]]]:
        """
        Dynamically detect delimiter (',' or ';') and header row index (Line 1 vs Line 2).
        Uses heuristic keyword scoring on top rows.
        """
        content = raw_content.lstrip("\ufeff").replace("\r\n", "\n").replace("\r", "\n")
        delim_scores: Dict[str, Tuple[int, float]] = {}

        for delim in (";", ","):
            try:
                reader = csv.reader(io.StringIO(content, newline=""), delimiter=delim)
                row_lens = [len(r) for idx, r in enumerate(reader) if idx < 15 and any(c.strip() for c in r)]
                if not row_lens:
                    continue
                mode_len = Counter(row_lens).most_common(1)[0][0]
                consistency = sum(1 for l in row_lens if l == mode_len) / len(row_lens)
                effective_cols = mode_len if mode_len >= 2 else 0
                delim_scores[delim] = (effective_cols, consistency)
            except Exception:
                pass

        best_delim = (
            max(delim_scores.keys(), key=lambda d: (delim_scores[d][0] >= 15, delim_scores[d][0], delim_scores[d][1]))
            if delim_scores
            else ","
        )

        try:
            reader = csv.reader(io.StringIO(content, newline=""), delimiter=best_delim)
            all_rows = list(reader)
        except csv.Error:
            reader = csv.reader(io.StringIO(content, newline=""), delimiter=best_delim, quoting=csv.QUOTE_NONE)
            all_rows = list(reader)

        if not all_rows:
            return best_delim, 0, [], []

        # Heuristic keyword scoring for header row (scan first 10 rows)
        best_hdr_idx = 0
        best_score = -1
        for idx in range(min(10, len(all_rows))):
            row = all_rows[idx]
            non_empty = sum(1 for x in row if x.strip())
            row_str = " ".join(x.lower() for x in row)
            score = non_empty

            if any(k in row_str for k in ("stt", "tt")):
                score += 6
            if any(k in row_str for k in ("thông tin", "chỉ tiêu", "tên chỉ tiêu")):
                score += 6
            if "phân loại" in row_str:
                score += 5
            if "trạng thái" in row_str:
                score += 5
            if any(k in row_str for k in ("bảng nguồn", "nguồn", "khai thác nguồn")):
                score += 5
            if any(k in row_str for k in ("loại dữ liệu", "điều kiện", "mô tả", "dashboard")):
                score += 3
            if any(k in row_str for k in ("câu lệnh", "sql", "note", "chú ý")):
                score += 3

            # Heavily penalize rows with 2 or fewer non-empty cells (like section labels 'Khai thác nguồn')
            if non_empty <= 2:
                score -= 20

            if score > best_score:
                best_score = score
                best_hdr_idx = idx

        hdr_idx = best_hdr_idx
        header = [x.lstrip("\ufeff").strip() for x in all_rows[hdr_idx]]
        data_rows = all_rows[hdr_idx + 1 :]
        return best_delim, hdr_idx, header, data_rows

    @classmethod
    def parse_file(cls, filepath: Path, include_deleted: bool = False) -> Tuple[List[BAItem], str, str, int]:
        """Parse BA CSV file into a list of BAItem objects using column alias mappings."""
        if not filepath.is_file():
            return [], "unknown", ",", 0

        raw_text, enc = cls.read_text_safe(filepath)
        delim, hdr_idx, header, data_rows = cls.detect_delimiter_and_header(raw_text)

        col_map = {name.lower().strip(): idx for idx, name in enumerate(header) if name.strip()}

        def get_col_idx(field_key: str) -> Optional[int]:
            aliases = COLUMN_ALIASES.get(field_key, [])
            for alias in aliases:
                for col_name, idx in col_map.items():
                    if col_name == alias.lower() or alias.lower() in col_name:
                        return idx
            return None

        stt_idx = get_col_idx("stt")
        ma_idx = get_col_idx("ma")
        dash_idx = get_col_idx("dashboard")
        name_idx = get_col_idx("name")
        desc_idx = get_col_idx("description")
        req_idx = get_col_idx("requirement_group")
        pl_idx = get_col_idx("classification")
        dg_idx = get_col_idx("evaluation")
        status_idx = get_col_idx("mapping_status")
        src_tbl_idx = get_col_idx("source_table")
        src_col_idx = get_col_idx("source_column")
        type_idx = get_col_idx("data_type")
        cond_idx = get_col_idx("condition")
        sql_idx = get_col_idx("sql")
        note_idx = get_col_idx("note")

        def val(row: List[str], idx: Optional[int]) -> str:
            if idx is not None and len(row) > idx:
                return row[idx].strip()
            return ""

        items: List[BAItem] = []
        for row_offset, r in enumerate(data_rows):
            line_num = hdr_idx + 2 + row_offset
            if not any(x.strip() for x in r):
                continue

            # Skip duplicate header rows or instruction rows
            pl_val = val(r, pl_idx).lower()
            if pl_val in ("phân loại", "chiều/chỉ tiêu cơ sở/chỉ tiêu phái sinh"):
                continue
            stt_val = val(r, stt_idx).lower()
            if stt_val in ("stt", "tt"):
                continue

            name = val(r, name_idx)
            # Skip instruction rows like 'Tên chiều/chỉ tiêu/thuộc tính'
            if not name or "tên chiều/chỉ tiêu" in name.lower() or name.lower() == "thông tin (chỉ tiêu)":
                continue

            # Skip section header/title rows that have no classification, status, and source table
            if not val(r, pl_idx) and not val(r, status_idx) and not val(r, src_tbl_idx):
                continue

            # Check deleted status
            st_val = val(r, status_idx).lower()
            is_deleted = any(w in st_val for w in ["delete", "deleted", "xóa", "xoá", "bãi bỏ", "hủy"])
            if is_deleted and not include_deleted:
                continue

            ma_val = val(r, ma_idx)
            if ma_val and (not stt_val or "." in stt_val or not stt_val.isdigit()):
                clean_ma = re.sub(r"^(?:nhóm|group)\s*", "", ma_val, flags=re.IGNORECASE).strip()
                if clean_ma.isdigit():
                    stt_val = clean_ma
                elif not stt_val:
                    stt_val = ma_val

            item = BAItem(
                line_num=line_num,
                stt=stt_val,
                ma=ma_val,
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

        return items, enc, delim, hdr_idx + 1


# ---------------------------------------------------------------------------
# 4. Detail Mapping Parser & Data Model
# ---------------------------------------------------------------------------
@dataclass
class DetailMappingItem:
    line_num: int
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


class DetailMappingParser:
    """Parser for Datamart Detail Mapping CSV files."""

    @staticmethod
    def parse_file(filepath: Path) -> Tuple[List[DetailMappingItem], str, str]:
        """Parse Detail Mapping CSV file into DetailMappingItem records with line numbers."""
        if not filepath.is_file():
            return [], "unknown", ","

        raw_text, enc = BAParser.read_text_safe(filepath)
        content = raw_text.lstrip("\ufeff").replace("\r\n", "\n").replace("\r", "\n")
        lines = content.splitlines()
        if not lines:
            return [], enc, ","

        # Delimiter detection
        delim = ";" if lines[0].count(";") > lines[0].count(",") else ","
        try:
            reader = csv.reader(io.StringIO(content, newline=""), delimiter=delim)
            rows = list(reader)
        except csv.Error:
            reader = csv.reader(io.StringIO(content, newline=""), delimiter=delim, quoting=csv.QUOTE_NONE)
            rows = list(reader)

        if not rows:
            return [], enc, delim

        header = [c.strip().lower() for c in rows[0]]
        col_indices: Dict[str, int] = {}
        for idx, col in enumerate(header):
            col_indices[col] = idx

        def get_field(r: List[str], key: str, fallback_indices: List[int]) -> str:
            if key in col_indices and col_indices[key] < len(r):
                return r[col_indices[key]].strip()
            for fb in fallback_indices:
                if fb < len(r):
                    return r[fb].strip()
            return ""

        items: List[DetailMappingItem] = []
        for idx, r in enumerate(rows[1:], start=2):
            if not any(c.strip() for c in r):
                continue
            item = DetailMappingItem(
                line_num=idx,
                kpi_id=get_field(r, "kpi_id", [0]),
                tab=get_field(r, "tab", [1]),
                nhom=get_field(r, "nhom", [2]),
                kpi_name=get_field(r, "kpi_name", [3]),
                tinh_chat=get_field(r, "tinh_chat", [4]),
                source_module=get_field(r, "source_module", [5]),
                mart_table=get_field(r, "mart_table", [6]),
                mart_column=get_field(r, "mart_column", [7]),
                column_role=get_field(r, "column_role", [8]),
                logic=get_field(r, "logic", [9]),
                ghi_chu=get_field(r, "ghi_chu", [10]),
            )
            items.append(item)

        return items, enc, delim


# ---------------------------------------------------------------------------
# 5. Detail Mapping Linter Engine
# ---------------------------------------------------------------------------
@dataclass
class MappingViolation:
    module: str
    line_num: int
    kpi_id: str
    rule_code: str
    severity: str  # CRITICAL or WARNING
    message: str
    mart_table: str = ""
    mart_column: str = ""
    column_role: str = ""
    logic: str = ""
    ghi_chu: str = ""


class DetailMappingLinter:
    """
    Validates Detail Mapping rows against strict architectural rules:
    - REUSE: If role != DERIVED, must have mart_table and mart_column.
    - PENDING (Rule L4): All 4 columns (mart_table, mart_column, column_role, logic) must be empty.
    - DERIVED: mart_table and mart_column must both be empty; formula in logic.
    - DEPRECATED: column_role = 'DEPRECATED' and mart_table/mart_column empty.
    """

    @classmethod
    def lint_module(cls, module: str, items: List[DetailMappingItem]) -> List[MappingViolation]:
        violations: List[MappingViolation] = []

        for item in items:
            tc_lower = item.tinh_chat.lower()
            role_upper = item.column_role.strip().upper()
            tbl = item.mart_table.strip()
            col = item.mart_column.strip()
            logic = item.logic.strip()
            gc_lower = item.ghi_chu.lower()
            name_lower = item.kpi_name.lower()

            is_pending = (
                (
                    "pending" in tc_lower
                    or "pending" in gc_lower
                    or role_upper == "PENDING"
                    or "chưa thiết kế" in gc_lower
                )
                and "resolved" not in gc_lower
            )

            is_deprecated = (
                (
                    "deprecated" in tc_lower
                    or role_upper == "DEPRECATED"
                    or "loại bỏ" in gc_lower
                    or "deprecated" in gc_lower
                )
                and not is_pending
            )

            is_reuse = (
                ("reuse" in gc_lower or "tái sử dụng" in gc_lower)
                and not is_pending
                and not is_deprecated
            )

            # ----------------------------------------------------------------
            # Rule 1: REUSE physical column enforcement
            # (Applies to active designed items, not PENDING or DEPRECATED)
            # ----------------------------------------------------------------
            if is_reuse and role_upper != "DERIVED":
                # Must have both mart_table and mart_column
                if not tbl or not col:
                    missing = []
                    if not tbl:
                        missing.append("mart_table")
                    if not col:
                        missing.append("mart_column")
                    violations.append(
                        MappingViolation(
                            module=module,
                            line_num=item.line_num,
                            kpi_id=item.kpi_id,
                            rule_code="L3-REUSE-MISSING-PHYSICAL-COLUMN",
                            severity="CRITICAL",
                            message=f"Chỉ tiêu REUSE vật lý nhưng thiếu {', '.join(missing)}. Nếu là reuse thuần BI layer, phải đặt column_role='DERIVED'.",
                            mart_table=tbl,
                            mart_column=col,
                            column_role=role_upper,
                            logic=logic,
                            ghi_chu=item.ghi_chu,
                        )
                    )

            # ----------------------------------------------------------------
            # Rule 2: PENDING (Rule L4) enforcement: all 4 fields must be empty
            # ----------------------------------------------------------------
            if is_pending:
                filled_fields = []
                if tbl:
                    filled_fields.append(f"mart_table='{tbl}'")
                if col:
                    filled_fields.append(f"mart_column='{col}'")
                if role_upper:
                    filled_fields.append(f"column_role='{role_upper}'")
                if logic:
                    filled_fields.append(f"logic='{logic[:30]}...'")

                if filled_fields:
                    violations.append(
                        MappingViolation(
                            module=module,
                            line_num=item.line_num,
                            kpi_id=item.kpi_id,
                            rule_code="L3-PENDING-RULE-L4-VIOLATION",
                            severity="CRITICAL",
                            message=f"Chỉ tiêu PENDING vi phạm Quy tắc L4: bắt buộc để trống cả 4 cột (mart_table, mart_column, column_role, logic). Hiện đang điền: {', '.join(filled_fields)}.",
                            mart_table=tbl,
                            mart_column=col,
                            column_role=role_upper,
                            logic=logic,
                            ghi_chu=item.ghi_chu,
                        )
                    )

            # ----------------------------------------------------------------
            # Rule 3: DERIVED rule: mart_table and mart_column must both be empty
            # ----------------------------------------------------------------
            if role_upper == "DERIVED":
                if tbl or col:
                    filled = []
                    if tbl:
                        filled.append(f"mart_table='{tbl}'")
                    if col:
                        filled.append(f"mart_column='{col}'")
                    violations.append(
                        MappingViolation(
                            module=module,
                            line_num=item.line_num,
                            kpi_id=item.kpi_id,
                            rule_code="L3-DERIVED-FILLED-MART-VIOLATION",
                            severity="CRITICAL",
                            message=f"Chỉ tiêu DERIVED vi phạm quy chuẩn: mart_table và mart_column bắt buộc để trống. Hiện đang điền: {', '.join(filled)}.",
                            mart_table=tbl,
                            mart_column=col,
                            column_role=role_upper,
                            logic=logic,
                            ghi_chu=item.ghi_chu,
                        )
                    )

            # ----------------------------------------------------------------
            # Rule 4: DEPRECATED rule: must have role DEPRECATED and empty mart
            # ----------------------------------------------------------------
            if is_deprecated:
                if tbl or col:
                    violations.append(
                        MappingViolation(
                            module=module,
                            line_num=item.line_num,
                            kpi_id=item.kpi_id,
                            rule_code="L3-DEPRECATED-FILLED-MART-VIOLATION",
                            severity="CRITICAL",
                            message="Chỉ tiêu DEPRECATED bắt buộc để trống mart_table và mart_column.",
                            mart_table=tbl,
                            mart_column=col,
                            column_role=role_upper,
                            logic=logic,
                            ghi_chu=item.ghi_chu,
                        )
                    )
                elif "deprecated" in tc_lower and role_upper != "DEPRECATED":
                    violations.append(
                        MappingViolation(
                            module=module,
                            line_num=item.line_num,
                            kpi_id=item.kpi_id,
                            rule_code="L3-DEPRECATED-ROLE-MISMATCH",
                            severity="WARNING",
                            message=f"Chỉ tiêu có tinh_chat='Deprecated' nhưng column_role='{role_upper}' (phải là 'DEPRECATED').",
                            mart_table=tbl,
                            mart_column=col,
                            column_role=role_upper,
                            logic=logic,
                            ghi_chu=item.ghi_chu,
                        )
                    )

            # ----------------------------------------------------------------
            # Rule 5: Reference SQL Alignment (Rule L17) check
            # Detect measure mismatches where KPI name indicates matched trading
            # ("khớp lệnh") but logic uses total_vol or total_val without matched
            # ----------------------------------------------------------------
            kpi_name_lower = item.kpi_name.lower()
            if role_upper == "MEASURE":
                is_khop_lenh = "khớp lệnh" in kpi_name_lower and "thỏa thuận" not in kpi_name_lower
                if is_khop_lenh:
                    logic_lower = logic.lower()
                    if "total_vol" in logic_lower and "total_matched_vol" not in logic_lower:
                        violations.append(
                            MappingViolation(
                                module=module,
                                line_num=item.line_num,
                                kpi_id=item.kpi_id,
                                rule_code="L3-REFERENCE-SQL-MISALIGNMENT",
                                severity="CRITICAL",
                                message="Chỉ tiêu khớp lệnh vi phạm Quy tắc L17: logic dùng total_vol (gộp cả thỏa thuận) thay vì total_matched_vol theo đúng SQL tham khảo BA.",
                                mart_table=tbl,
                                mart_column=col,
                                column_role=role_upper,
                                logic=logic,
                                ghi_chu=item.ghi_chu,
                            )
                        )
                    if "total_val" in logic_lower and "total_matched_val" not in logic_lower:
                        violations.append(
                            MappingViolation(
                                module=module,
                                line_num=item.line_num,
                                kpi_id=item.kpi_id,
                                rule_code="L3-REFERENCE-SQL-MISALIGNMENT",
                                severity="CRITICAL",
                                message="Chỉ tiêu khớp lệnh vi phạm Quy tắc L17: logic dùng total_val (gộp cả thỏa thuận) thay vì total_matched_val theo đúng SQL tham khảo BA.",
                                mart_table=tbl,
                                mart_column=col,
                                column_role=role_upper,
                                logic=logic,
                                ghi_chu=item.ghi_chu,
                            )
                        )

        return violations


# ---------------------------------------------------------------------------
# 6. 5-Category PENDING Decision Tree
# ---------------------------------------------------------------------------
@dataclass
class PendingClassification:
    group_id: int
    group_name: str
    responsibility: str
    description: str


PENDING_5_GROUPS: Dict[int, PendingClassification] = {
    1: PendingClassification(
        group_id=1,
        group_name="BA chưa mapping xong",
        responsibility="BA Team",
        description="BA Status != Done (Doing, Pending, Draft, Rỗng, hoặc ghi chú 'chờ BA confirm/xác nhận')",
    ),
    2: PendingClassification(
        group_id=2,
        group_name="Chưa có mapping nguồn từ BA",
        responsibility="BA Team",
        description="BA Status = Done nhưng Bảng nguồn trống / N/A / Chưa có CSDL / Biểu mẫu giấy / Báo cáo bản cứng",
    ),
    3: PendingClassification(
        group_id=3,
        group_name="Thiếu nguồn dữ liệu / Atomic entity ngoài scope",
        responsibility="Data Architecture / Atomic",
        description="Nguồn ngoại lai (VSD, VSDC, HOSE, HNX ngoài DW, SBV) hoặc Atomic entity ngoài scope / chưa duyệt attribute",
    ),
    4: PendingClassification(
        group_id=4,
        group_name="Cần join phức tạp đa nguồn",
        responsibility="Atomic Modeling",
        description="Liên kết phức tạp đa hệ thống chưa có cấu trúc chuẩn (SCMS + NHNCK, join đa nguồn, cross-system)",
    ),
    5: PendingClassification(
        group_id=5,
        group_name="Datamart chưa thiết kế Fact/Dim",
        responsibility="Datamart Modeling Team",
        description="BA Done, nguồn Atomic đã có và approved, nhưng Datamart chưa thiết kế Fact/Dim (LLD/HLD Pending)",
    ),
}


class PendingClassifier:
    """5-Category PENDING Decision Tree."""

    @classmethod
    def classify(
        cls,
        kpi_name: str,
        ba_source: str = "",
        ba_status: str = "",
        ghi_chu: str = "",
        note_ba: str = "",
        data_type_ba: str = "",
        group_name: str = "",
    ) -> Tuple[int, str, str]:
        """
        Classifies a PENDING item into exactly one of the 5 standard categories.
        Returns: (group_id, group_name, responsibility)
        """
        kpi_lower = kpi_name.lower().strip()
        src_lower = ba_source.lower().strip()
        st_upper = ba_status.upper().strip()
        gc_lower = ghi_chu.lower().strip()
        note_lower = note_ba.lower().strip()
        dt_lower = data_type_ba.lower().strip()
        nhom_lower = group_name.lower().strip()

        combined_notes = f"{gc_lower} {note_lower}"

        # ------------------------------------------------------------------
        # 1. Check external sources or Atomic out-of-scope / schema cues
        # ------------------------------------------------------------------
        external_keywords = [
            "vsdc",
            "vsd",
            "uat_vsdc",
            "hose",
            "hnx",
            "sbv",
            "ngoại lai",
            "ngoại lai",
            "external",
            "administrative sanction",
            "administrative procedure document",
            "chưa có attribute",
            "chưa duyệt atomic",
            "atomic chưa",
            "schema mismatch",
            "chưa approved",
            "out of sync",
            "eform",
            "contentitem",
            "gap marketcap",
        ]
        if (
            any(k in combined_notes for k in external_keywords)
            or any(k in src_lower for k in ["vsd", "vsdc", "uat_vsdc", "sbv", "ngoại lai", "ngoại lai"])
            or "thị phần" in kpi_lower
            or "vsd" in kpi_lower
            or "vsdc" in kpi_lower
        ):
            c = PENDING_5_GROUPS[3]
            return c.group_id, c.group_name, c.responsibility

        # ------------------------------------------------------------------
        # 2. Check multi-source / complex join cues
        # ------------------------------------------------------------------
        multi_source_keywords = [
            "scms_nhnck",
            "scms_uat",
            "join đa nguồn",
            "multi-source",
            "liên hệ thống",
            "cross-system",
            "scms và nhnck",
        ]
        if (
            any(k in combined_notes for k in multi_source_keywords)
            or any(k in src_lower for k in ["scms_nhnck", "scms_uat"])
            or ("scms" in src_lower and "nhnck" in src_lower)
            or ("chứng chỉ" in kpi_lower and "hành nghề" in kpi_lower and "scms" in src_lower)
            or ("người hành nghề" in nhom_lower and "scms" in src_lower)
        ):
            c = PENDING_5_GROUPS[4]
            return c.group_id, c.group_name, c.responsibility

        # ------------------------------------------------------------------
        # 3. Check BA pending cues in notes or BA status != Done
        # ------------------------------------------------------------------
        ba_pending_keywords = [
            "chờ ba xác nhận",
            "chờ ba confirm",
            "chờ confirm",
            "chờ xác nhận",
            "chờ ba",
            "ba đang làm",
            "ba chưa xong",
        ]
        if any(phrase in combined_notes for phrase in ba_pending_keywords):
            c = PENDING_5_GROUPS[1]
            return c.group_id, c.group_name, c.responsibility

        if ba_status and st_upper not in ("DONE", "HOÀN THÀNH", "HOAN THANH"):
            c = PENDING_5_GROUPS[1]
            return c.group_id, c.group_name, c.responsibility

        # ------------------------------------------------------------------
        # 4. Check Missing Source from BA (Status = Done but source empty/paper)
        # ------------------------------------------------------------------
        if (
            (ba_status and (not src_lower or src_lower in ("n/a", "(trống)", "null", "none", "chưa có")))
            or any(k in src_lower for k in ["chưa có csdl", "chưa có nguồn", "chưa số hóa", "biểu mẫu giấy", "báo cáo bản cứng"])
            or any(k in dt_lower for k in ["chưa có csdl", "map biểu mẫu"])
            or any(k in combined_notes for k in ["chưa có csdl", "chưa có nguồn", "chưa số hóa", "biểu mẫu giấy", "map biểu mẫu", "báo cáo bản cứng"])
        ):
            c = PENDING_5_GROUPS[2]
            return c.group_id, c.group_name, c.responsibility

        # ------------------------------------------------------------------
        # 5. Datamart chưa thiết kế Fact/Dim (default for Datamart pending)
        # ------------------------------------------------------------------
        c = PENDING_5_GROUPS[5]
        return c.group_id, c.group_name, c.responsibility


# ---------------------------------------------------------------------------
# 7. Cross-Check & Delta Reconciliation Engine
# ---------------------------------------------------------------------------
@dataclass
class PendingItemDetail:
    kpi_id: str
    kpi_name: str
    group_id: int
    group_name: str
    responsibility: str
    ba_status: str
    ba_source: str
    ghi_chu: str
    line_num: int


@dataclass
class ModuleAuditResult:
    module: str
    ba_file: Optional[str]
    ba_encoding: str
    ba_delimiter: str
    ba_header_line: int
    ba_total_rows: int
    detail_mapping_file: Optional[str]
    detail_mapping_encoding: str
    detail_mapping_delimiter: str
    detail_mapping_total_rows: int
    unique_kpi_count: int
    violations: List[MappingViolation]
    critical_violation_count: int
    warning_violation_count: int
    pending_items: List[PendingItemDetail]
    pending_group_counts: Dict[int, int]
    status_matrix: Dict[str, Dict[str, int]]
    reconciled_delta: Dict[str, Any]


class DatamartBACrossChecker:
    """Coordinates cross-checking, linter validation, and report generation."""

    def __init__(self, root_dir: Optional[Union[str, Path]] = None):
        self.root_dir = find_project_root(root_dir)

    def audit_module(self, module: str) -> ModuleAuditResult:
        mod_norm = normalize_module_name(module)
        ba_path = resolve_ba_path(self.root_dir, module)
        dtm_path = resolve_detail_mapping_path(self.root_dir, module)

        ba_items: List[BAItem] = []
        ba_enc, ba_delim, ba_hdr_line = "N/A", ",", 0
        if ba_path and ba_path.is_file():
            ba_items, ba_enc, ba_delim, ba_hdr_line = BAParser.parse_file(ba_path, include_deleted=True)

        dtm_items: List[DetailMappingItem] = []
        dtm_enc, dtm_delim = "N/A", ","
        if dtm_path and dtm_path.is_file():
            dtm_items, dtm_enc, dtm_delim = DetailMappingParser.parse_file(dtm_path)

        # 1. Lint Detail Mapping
        violations = DetailMappingLinter.lint_module(mod_norm, dtm_items)
        crit_count = sum(1 for v in violations if v.severity == "CRITICAL")
        warn_count = sum(1 for v in violations if v.severity == "WARNING")

        # 2. Build BA lookup indices (exact, stripped-qualifier, and fuzzy)
        ba_by_clean_name: Dict[str, List[BAItem]] = defaultdict(list)
        ba_by_stripped: Dict[str, List[BAItem]] = defaultdict(list)
        for b in ba_items:
            c_name = clean_kpi_name(b.name)
            if c_name:
                ba_by_clean_name[c_name].append(b)
                sq = strip_qualifiers(c_name)
                if sq:
                    ba_by_stripped[sq].append(b)

        ba_clean_keys = list(ba_by_clean_name.keys())

        def _match_ba(kpi_name: str) -> Optional[List[BAItem]]:
            """Multi-pass BA matching: exact → stripped-qualifier → fuzzy."""
            c_name = clean_kpi_name(kpi_name)
            if not c_name:
                return None
            # Pass 1: exact clean name match
            if c_name in ba_by_clean_name:
                return ba_by_clean_name[c_name]
            # Pass 2: match after stripping parenthesized qualifiers
            sq = strip_qualifiers(c_name)
            if sq and sq in ba_by_stripped:
                return ba_by_stripped[sq]
            # Pass 3: fuzzy match (ratio >= 0.85)
            matches = difflib.get_close_matches(c_name, ba_clean_keys, n=1, cutoff=0.85)
            if matches:
                return ba_by_clean_name[matches[0]]
            return None

        # 3. Classify PENDING items & compute Status Matrix
        pending_items: List[PendingItemDetail] = []
        pending_counts: Dict[int, int] = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}

        # Status matrix: BA status -> Datamart status -> count
        # BA statuses: Done, Doing, Pending, Delete, Other
        # DTM statuses: READY, PENDING, DEPRECATED, UNMAPPED
        status_matrix: Dict[str, Dict[str, int]] = defaultdict(lambda: defaultdict(int))

        unique_kpi_ids: Set[str] = set()
        for d in dtm_items:
            kpi_id = d.kpi_id.strip()
            if kpi_id:
                unique_kpi_ids.add(kpi_id)

            tc_lower = d.tinh_chat.lower()
            role_upper = d.column_role.strip().upper()
            gc_lower = d.ghi_chu.lower()

            is_pending = (
                (
                    "pending" in tc_lower
                    or "pending" in gc_lower
                    or role_upper == "PENDING"
                    or "chưa thiết kế" in gc_lower
                )
                and "resolved" not in gc_lower
            )

            is_deprecated = (
                (
                    "deprecated" in tc_lower
                    or role_upper == "DEPRECATED"
                    or "loại bỏ" in gc_lower
                    or "deprecated" in gc_lower
                )
                and not is_pending
            )

            dtm_status = "PENDING" if is_pending else ("DEPRECATED" if is_deprecated else "READY")

            # Match to BA item (multi-pass: exact → stripped-qualifier → fuzzy)
            matched_ba = _match_ba(d.kpi_name) or []
            primary_ba = matched_ba[0] if matched_ba else None

            ba_st = (primary_ba.mapping_status if primary_ba else "").strip().title()
            if not ba_st:
                ba_st = "Không tìm thấy trong BA"
            elif any(w in ba_st.lower() for w in ["delete", "xóa", "xoá"]):
                ba_st = "Delete"
            elif ba_st.lower() in ("done", "hoàn thành", "hoan thanh"):
                ba_st = "Done"
            elif ba_st.lower() in ("doing", "đang làm", "đang thực hiện"):
                ba_st = "Doing"
            elif ba_st.lower() in ("pending", "chờ"):
                ba_st = "Pending"
            else:
                ba_st = "Khác"

            status_matrix[ba_st][dtm_status] += 1

            if is_pending:
                ba_src = primary_ba.source_table if primary_ba else ""
                ba_status_val = primary_ba.mapping_status if primary_ba else ""
                note_ba = primary_ba.note if primary_ba else ""
                dt_ba = primary_ba.data_type if primary_ba else ""

                grp_id, grp_name, resp = PendingClassifier.classify(
                    kpi_name=d.kpi_name,
                    ba_source=ba_src,
                    ba_status=ba_status_val,
                    ghi_chu=d.ghi_chu,
                    note_ba=note_ba,
                    data_type_ba=dt_ba,
                    group_name=d.nhom,
                )
                pending_counts[grp_id] += 1
                pending_items.append(
                    PendingItemDetail(
                        kpi_id=d.kpi_id,
                        kpi_name=d.kpi_name,
                        group_id=grp_id,
                        group_name=grp_name,
                        responsibility=resp,
                        ba_status=ba_status_val,
                        ba_source=ba_src,
                        ghi_chu=d.ghi_chu,
                        line_num=d.line_num,
                    )
                )

        # 4. Delta Reconciliation (multi-pass consistent)
        matched_dtm_count = sum(1 for d in dtm_items if _match_ba(d.kpi_name))
        unmatched_dtm_count = len(dtm_items) - matched_dtm_count

        matched_ba_ids = set()
        for d in dtm_items:
            m = _match_ba(d.kpi_name)
            if m:
                for b in m:
                    matched_ba_ids.add(id(b))
        ba_unmapped = [b for b in ba_items if id(b) not in matched_ba_ids]

        reconciled_delta = {
            "ba_total_indicators": len(ba_items),
            "dtm_total_rows": len(dtm_items),
            "dtm_unique_kpi_ids": len(unique_kpi_ids),
            "dtm_matched_in_ba": matched_dtm_count,
            "dtm_unmatched_in_ba": unmatched_dtm_count,
            "ba_unmapped_in_dtm": len(ba_unmapped),
        }

        return ModuleAuditResult(
            module=mod_norm,
            ba_file=ba_path.name if ba_path else None,
            ba_encoding=ba_enc,
            ba_delimiter=ba_delim,
            ba_header_line=ba_hdr_line,
            ba_total_rows=len(ba_items),
            detail_mapping_file=dtm_path.name if dtm_path else None,
            detail_mapping_encoding=dtm_enc,
            detail_mapping_delimiter=dtm_delim,
            detail_mapping_total_rows=len(dtm_items),
            unique_kpi_count=len(unique_kpi_ids),
            violations=violations,
            critical_violation_count=crit_count,
            warning_violation_count=warn_count,
            pending_items=pending_items,
            pending_group_counts=pending_counts,
            status_matrix=dict(status_matrix),
            reconciled_delta=reconciled_delta,
        )

    def audit_all(self) -> List[ModuleAuditResult]:
        modules = get_available_modules(self.root_dir)
        return [self.audit_module(m) for m in modules]


# ---------------------------------------------------------------------------
# 8. Markdown & JSON Report Formatters
# ---------------------------------------------------------------------------
def render_markdown_report(results: List[ModuleAuditResult], lint_detail: bool = False) -> str:
    md: List[str] = []
    md.append("# Datamart & BA Cross-Check Audit Scorecard\n")

    # Macro Summary Table
    md.append("## 1. Tổng Quan Cấp Module (Macro Scorecard)\n")
    md.append("| Phân Hệ | File BA (Encoding / Delim) | File Detail Mapping | Tổng Dòng BA | Dòng Mapping | KPI Unique | Vi Phạm CRITICAL | Vi Phạm WARN | PENDING | Trạng Thái |")
    md.append("|---|---|---|---|---|---|---|---|---|---|")

    total_crit = 0
    total_warn = 0
    total_pending = 0
    for r in results:
        total_crit += r.critical_violation_count
        total_warn += r.warning_violation_count
        pending_sum = sum(r.pending_group_counts.values())
        total_pending += pending_sum

        status_badge = "✅ PASS"
        if r.critical_violation_count > 0:
            status_badge = f"❌ FAIL ({r.critical_violation_count} CRITICAL)"
        elif r.warning_violation_count > 0:
            status_badge = f"⚠️ WARN ({r.warning_violation_count})"

        ba_info = f"{r.ba_file or 'N/A'} ({r.ba_encoding}, '{r.ba_delimiter}', L{r.ba_header_line})"
        dtm_info = f"{r.detail_mapping_file or 'N/A'} ({r.detail_mapping_encoding}, '{r.detail_mapping_delimiter}')"

        md.append(
            f"| **{r.module}** | {ba_info} | {dtm_info} | {r.ba_total_rows} | {r.detail_mapping_total_rows} | {r.unique_kpi_count} | {r.critical_violation_count} | {r.warning_violation_count} | {pending_sum} | {status_badge} |"
        )
    md.append("")

    # 5-Category PENDING Summary across modules
    md.append("## 2. Phân Loại 5 Nhóm Nguyên Nhân PENDING\n")
    md.append("| Nhóm | Tên Nhóm Nguyên Nhân | Trách Nhiệm | Tiêu Chí Phân Loại | Số Lượng KPI | Tỷ Lệ PENDING |")
    md.append("|---|---|---|---|---|---|")

    agg_pending_counts: Dict[int, int] = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
    for r in results:
        for gid, count in r.pending_group_counts.items():
            agg_pending_counts[gid] += count

    for gid in range(1, 6):
        info = PENDING_5_GROUPS[gid]
        cnt = agg_pending_counts.get(gid, 0)
        pct = (cnt / total_pending * 100) if total_pending > 0 else 0.0
        md.append(f"| **Nhóm {gid}** | {info.group_name} | `{info.responsibility}` | {info.description} | {cnt:,} | {pct:.1f}% |")
    md.append(f"| **TỔNG** | **Toàn bộ PENDING** | | | **{total_pending:,}** | **100.0%** |")
    md.append("")

    # Detail Mapping Linter Violations Section
    md.append("## 3. Danh Mục Vi Phạm Detail Mapping (Linter Violations)\n")
    total_violations = sum(len(r.violations) for r in results)
    if total_violations == 0:
        md.append("🎉 **Không phát hiện vi phạm quy chuẩn nào trong Detail Mapping!**\n")
    else:
        md.append(f"Phát hiện tổng cộng **{total_violations}** vi phạm ({total_crit} CRITICAL, {total_warn} WARNING):\n")
        md.append("| Phân Hệ | Dòng | KPI ID | Mã Vi Phạm | Mức Độ | Chi Tiết Vi Phạm | mart_table | mart_column | role |")
        md.append("|---|---|---|---|---|---|---|---|---|")
        for r in results:
            for v in r.violations:
                msg_sanitized = v.message.replace("|", "\\|").replace("\n", " ")
                tbl_sanitized = (v.mart_table or "").replace("|", "\\|")
                col_sanitized = (v.mart_column or "").replace("|", "\\|")
                md.append(
                    f"| {v.module} | L{v.line_num} | `{v.kpi_id}` | `{v.rule_code}` | **{v.severity}** | {msg_sanitized} | {tbl_sanitized} | {col_sanitized} | `{v.column_role}` |"
                )
        md.append("")

    # Reconciled Delta & Status Cross-Matrix per module
    md.append("## 4. Chi Tiết Đối Soát BA ↔ Datamart Từng Phân Hệ\n")
    for r in results:
        md.append(f"### Phân Hệ {r.module}")
        md.append(f"- **File BA:** `{r.ba_file}` | Encoding: `{r.ba_encoding}` | Delimiter: `'{r.ba_delimiter}'` | Header Line: {r.ba_header_line}")
        md.append(f"- **File Detail Mapping:** `{r.detail_mapping_file}` | Encoding: `{r.detail_mapping_encoding}` | Delimiter: `'{r.detail_mapping_delimiter}'`")
        md.append(
            f"- **Chỉ số đối soát:** BA Indicators: {r.reconciled_delta.get('ba_total_indicators')}, "
            f"Mapping Rows: {r.reconciled_delta.get('dtm_total_rows')}, Unique KPIs: {r.reconciled_delta.get('dtm_unique_kpi_ids')}, "
            f"Khớp BA: {r.reconciled_delta.get('dtm_matched_in_ba')}, Unmatched BA: {r.reconciled_delta.get('dtm_unmatched_in_ba')}"
        )

        # Status Matrix Table
        if r.status_matrix:
            md.append("\n**Ma trận trạng thái (BA Status vs Datamart Status):**")
            all_dtm_statuses = sorted(list({st for row in r.status_matrix.values() for st in row.keys()}))
            header_str = "| Trạng Thái BA | " + " | ".join(all_dtm_statuses) + " | Tổng |"
            sep_str = "|---|" + "|".join(["---"] * len(all_dtm_statuses)) + "|---|"
            md.append(header_str)
            md.append(sep_str)
            for ba_st, row in sorted(r.status_matrix.items()):
                counts = [str(row.get(ds, 0)) for ds in all_dtm_statuses]
                row_total = sum(row.values())
                md.append(f"| {ba_st} | " + " | ".join(counts) + f" | **{row_total}** |")
        md.append("")

        # PENDING Breakdown for module if present
        mod_pending_total = sum(r.pending_group_counts.values())
        if mod_pending_total > 0:
            md.append(f"**Phân bổ 5 Nhóm PENDING ({mod_pending_total} dòng):**")
            for gid in range(1, 6):
                cnt = r.pending_group_counts.get(gid, 0)
                if cnt > 0:
                    info = PENDING_5_GROUPS[gid]
                    pct = cnt / mod_pending_total * 100
                    md.append(f"- **Nhóm {gid}** ({info.group_name} — `{info.responsibility}`): {cnt} KPI ({pct:.1f}%)")
            md.append("")

    return "\n".join(md)


def format_json_output(results: List[ModuleAuditResult]) -> Dict[str, Any]:
    """Serialize audit results into structured JSON for CI/CD or agent consumption."""
    modules_json = []
    total_crit = 0
    total_warn = 0
    total_pending = 0

    for r in results:
        total_crit += r.critical_violation_count
        total_warn += r.warning_violation_count
        total_pending += sum(r.pending_group_counts.values())

        modules_json.append(
            {
                "module": r.module,
                "ba_file": r.ba_file,
                "ba_encoding": r.ba_encoding,
                "ba_delimiter": r.ba_delimiter,
                "ba_header_line": r.ba_header_line,
                "ba_total_rows": r.ba_total_rows,
                "detail_mapping_file": r.detail_mapping_file,
                "detail_mapping_encoding": r.detail_mapping_encoding,
                "detail_mapping_delimiter": r.detail_mapping_delimiter,
                "detail_mapping_total_rows": r.detail_mapping_total_rows,
                "unique_kpi_count": r.unique_kpi_count,
                "critical_violations": r.critical_violation_count,
                "warning_violations": r.warning_violation_count,
                "pending_group_counts": r.pending_group_counts,
                "status_matrix": r.status_matrix,
                "reconciled_delta": r.reconciled_delta,
                "violations": [asdict(v) for v in r.violations],
                "pending_sample": [asdict(p) for p in r.pending_items[:10]],
            }
        )

    return {
        "status": "FAIL" if total_crit > 0 else ("WARN" if total_warn > 0 else "PASS"),
        "total_critical_violations": total_crit,
        "total_warning_violations": total_warn,
        "total_pending_indicators": total_pending,
        "modules_analyzed": len(results),
        "modules": modules_json,
    }


# ---------------------------------------------------------------------------
# 9. CLI Entrypoint
# ---------------------------------------------------------------------------
def main() -> int:
    parser = argparse.ArgumentParser(
        description="BA vs Datamart Cross-Checker, PENDING Classifier & Detail Mapping Linter"
    )
    parser.add_argument(
        "-m",
        "--module",
        type=str,
        default="all",
        help="Module name (e.g. GSTT, QLKD, QLCB, TKNB, GSDC) or 'all' (default: all)",
    )
    parser.add_argument(
        "--path",
        type=str,
        default=None,
        help="Optional direct path to a Detail Mapping or BA CSV file",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Strict mode: exit with code 1 if any CRITICAL violations (Rule L4, REUSE missing col, DERIVED filled mart) are detected",
    )
    parser.add_argument(
        "--lint-detail-mapping",
        action="store_true",
        help="Run deep linting of Detail Mapping CSV files and print individual violations",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output results in JSON format",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=str,
        default=None,
        help="Path to save output report (Markdown or JSON depending on --json flag)",
    )

    args = parser.parse_args()

    checker = DatamartBACrossChecker()

    try:
        if args.path:
            p = Path(args.path).resolve()
            if not p.is_file():
                print(f"Error: File not found: {args.path}", file=sys.stderr)
                return 2
            # Infer module name from filename if possible
            mod_guess = "CUSTOM"
            m_match = re.search(r"DTM_([A-Za-z0-9_]+?)_Detail_Mapping", p.name, re.IGNORECASE)
            if m_match:
                mod_guess = m_match.group(1)
            results = [checker.audit_module(mod_guess)]
        elif args.module.lower() == "all":
            results = checker.audit_all()
        else:
            results = [checker.audit_module(args.module)]
    except Exception as e:
        print(f"Unhandled exception during audit: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        return 2

    # Check for critical violations
    total_crit = sum(r.critical_violation_count for r in results)

    # Output formatting
    if args.json:
        payload = format_json_output(results)
        out_str = json.dumps(payload, ensure_ascii=False, indent=2)
        if args.output:
            Path(args.output).write_text(out_str, encoding="utf-8")
            print(f"JSON report saved to {args.output}")
        else:
            print(out_str)
    else:
        report_md = render_markdown_report(results, lint_detail=args.lint_detail_mapping)
        if args.output:
            Path(args.output).write_text(report_md, encoding="utf-8")
            print(f"Markdown report saved to {args.output}")
        else:
            print(report_md)

    if args.strict and total_crit > 0:
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
