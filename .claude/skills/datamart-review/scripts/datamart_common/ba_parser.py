# -*- coding: utf-8 -*-
"""
datamart_common/ba_parser.py — bộ đọc file BA duy nhất cho toàn bộ skill Datamart.

LÝ DO TỒN TẠI
    Trước file này có 3 bản BAParser song song:
      - datamart_progress_analyzer.py (định nghĩa lại detect_delimiter_and_header + tự decode bytes)
      - datamart_ba_cross_checker.py  (chép lại cả MODULE_ALIASES/strip_accents/find_project_root,
                                       không import datamart_common một lần nào)
      - csv_utils.detect_delimiter_and_header (bản dùng chung, thiếu logic group key)
    Ba bản dò delimiter/header bằng heuristic riêng -> đã dẫn tới nhận nhầm file ';' thành ','
    và nhận nhầm dòng legend thành dòng dữ liệu.

KHÁC BIỆT SO VỚI BẢN CŨ
    Delimiter / header_row / legend_rows / stt_column lấy từ `system/rules/ba_column_profile.yaml`
    thay vì đoán. Profile là khẳng định có kiểm chứng: lệch với file thật -> ném BaProfileMismatch,
    KHÔNG lặng lẽ fallback. Module chưa có trong profile thì mới dùng heuristic cũ (kèm cảnh báo),
    để `-m ALL` vẫn chạy khi có phân hệ mới.

    Toàn bộ logic nghiệp vụ (COLUMN_ALIASES, bộ lọc dòng rác, cách suy ra group key từ STT/Mã)
    giữ NGUYÊN của datamart_ba_cross_checker.py để không đổi kết quả của 2 script cũ.

API
    load_ba_profile(root)                         -> dict toàn bộ file profile
    profile_for(root, module)                     -> dict đã merge defaults + module
    parse_ba_file(path, profile=None, ...)        -> (List[BAItem], BAFileMeta)
    group_ba_items(items)                         -> OrderedDict[group_key, List[BAItem]]
    drop_column_indices(header, profile, with_sql)-> Set[int]
"""
from __future__ import annotations

import csv
import io
import re
import sys
from collections import Counter, OrderedDict
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Set, Tuple

from .module_resolver import find_project_root, normalize_module_name, resolve_module_path, strip_accents

csv.field_size_limit(10_000_000)

PROFILE_REL = "system/rules/ba_column_profile.yaml"

__all__ = [
    "BAItem",
    "BAFileMeta",
    "BaProfileMismatch",
    "COLUMN_ALIASES",
    "clean_kpi_name",
    "strip_qualifiers",
    "load_ba_profile",
    "profile_for",
    "parse_ba_file",
    "group_ba_items",
    "drop_column_indices",
    "resolve_ba_path",
    "read_ba_text",
    "list_ba_modules",
]


class BaProfileMismatch(ValueError):
    """File BA thật lệch với khai báo trong ba_column_profile.yaml."""


# ---------------------------------------------------------------------------
# 1. Column aliases — bê nguyên từ datamart_ba_cross_checker.py:185-201
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
    "source_table": ["bảng nguồn", "nguồn", "khai thác nguồn", "nguồn chi tiết", "nguồn dữ liệu",
                     "mapping nguồn dữ liệu"],
    "source_column": ["trường nguồn", "cột nguồn"],
    "data_type": ["loại dữ liệu"],
    "condition": ["điều kiện", "điều kiện chung", "điều kiện dữ liệu"],
    "sql": ["câu lệnh tham khảo", "câu lệnh sql", "sit sql", "câu lệnh update sit",
            "câu lệnh update (sit)"],
    "note": ["note", "chú ý", "ghi chú"],
}

_DELETED_WORDS = ("delete", "deleted", "xóa", "xoá", "bãi bỏ", "hủy")
_DONE_STATUSES = ("done", "doing", "hoàn thành")


def read_ba_text(filepath: Path) -> Tuple[str, str]:
    """Đọc file BA -> (text, tên encoding thật).

    Giữ nguyên thứ tự dò của BAParser.read_text_safe cũ: BOM utf-8 -> BOM utf-16 ->
    utf-8 strict -> cp1258 -> latin-1. Tên encoding trả về được in ra báo cáo nên phải
    khớp bản cũ, không được rút gọn thành 'utf-8-sig' cho mọi file.
    """
    raw = Path(filepath).read_bytes()
    if raw.startswith(b"\xef\xbb\xbf"):
        return raw.decode("utf-8-sig", errors="replace").lstrip("﻿"), "utf-8-sig"
    if raw.startswith(b"\xff\xfe") or raw.startswith(b"\xfe\xff"):
        try:
            return raw.decode("utf-16", errors="replace"), "utf-16"
        except Exception:
            pass
    try:
        return raw.decode("utf-8"), "utf-8"
    except UnicodeDecodeError:
        pass
    for enc in ("cp1258", "latin-1"):
        try:
            return raw.decode(enc, errors="replace"), enc
        except Exception:
            pass
    return raw.decode("latin-1", errors="replace"), "latin-1"


def _norm(s: str) -> str:
    """Chuẩn hoá tên cột để so khớp: bỏ BOM, gộp whitespace, lower."""
    return re.sub(r"\s+", " ", (s or "").replace("﻿", "")).strip().lower()


# ---------------------------------------------------------------------------
# 2. clean_kpi_name / strip_qualifiers — bê nguyên từ cross_checker (dòng 204-263)
# ---------------------------------------------------------------------------
def clean_kpi_name(name: str) -> str:
    """Chuẩn hoá tên chỉ tiêu để cross-match giữa BA / HLD / Detail Mapping."""
    if not name:
        return ""
    n = re.sub(r"\((?:reuse\s+từ|chiều\s*lọc|tham\s*số\s*lọc|filter|slicer).*?\)", "", name, flags=re.IGNORECASE)
    n = re.sub(r"\[(?:reuse\s+từ|chiều\s*lọc|tham\s*số\s*lọc|filter|slicer).*?\]", "", n, flags=re.IGNORECASE)
    n = re.sub(r"\s*\(\s*%\s*\)", "", n)
    n = re.sub(r"\s*\((?:giá\s+trị\s+trúng\s+thầu).*?\)", "", n, flags=re.IGNORECASE)
    n = re.sub(r"[‐‑‒–—―−\-]+", "-", n)
    n = re.sub(r"\s*-\s*", " - ", n)
    n = re.sub(r"so\s+(?:sánh\s+)?với\s+kỳ\s+trước", "so kỳ trước", n, flags=re.IGNORECASE)
    n = re.sub(r"\bny/", "niêm yết/", n, flags=re.IGNORECASE)
    n = re.sub(r"\bdòng\s+tiền\s+vào\b", "dòng vào", n, flags=re.IGNORECASE)
    n = re.sub(r"\bdòng\s+tiền\s+ra\b", "dòng ra", n, flags=re.IGNORECASE)
    n = re.sub(r"\bkhối\s+lượng\s+giao\s+dịch\b", "klgd", n, flags=re.IGNORECASE)
    n = re.sub(r"\bgiá\s+trị\s+giao\s+dịch\b", "gtgd", n, flags=re.IGNORECASE)
    n = re.sub(r"\bkhối\s+lượng\b", "kl", n, flags=re.IGNORECASE)
    n = re.sub(r"\bgiá\s+trị\b", "gt", n, flags=re.IGNORECASE)
    n = re.sub(r"\btpdn\s+riêng\s+lẻ\b", "tp", n, flags=re.IGNORECASE)
    n = re.sub(r"\btpdn\b", "tp", n, flags=re.IGNORECASE)
    n = re.sub(r"\bđang\s+lưu\s+hành\b", "lưu hành", n, flags=re.IGNORECASE)
    n = re.sub(r"\btrong\s+1\s+ngày\b", "trong ngày", n, flags=re.IGNORECASE)
    n = re.sub(r"\bcủa\s+các\s+loại\s+hợp\s+đồng\s+phái\s+sinh\b", "phái sinh", n, flags=re.IGNORECASE)
    n = re.sub(r"\bcủa\s+trái\s+phiếu\b", "phái sinh", n, flags=re.IGNORECASE)
    n = re.sub(r"\bgiữa\s+klgd/klgdtb\s+trong\s+(\d+)\s+ngày\s+lớn\s+hơn\s+x\s+lần\b",
               r"klgd/klgdtb \1 ngày", n, flags=re.IGNORECASE)
    n = re.sub(r"\btỷ\s+lệ\s+klgd/klgdtb\s+(\d+)\s+ngày\b", r"klgd/klgdtb \1 ngày", n, flags=re.IGNORECASE)
    n = re.sub(r"\bcủa\s+cổ\s+phiếu\s+(?:đang\s+)?lưu\s+hành\b", "lưu hành", n, flags=re.IGNORECASE)
    n = re.sub(r"\bcủa\s+cổ\s+phiếu\s+tự\s+do\s+chuyển\s+nhượng\b", "tự do chuyển nhượng", n, flags=re.IGNORECASE)
    n = re.sub(r"\bđiểm\s+đóng\s+góp\s+tương\s+đối\b", "tương đối", n, flags=re.IGNORECASE)
    n = re.sub(r"\s*-\s*tương\s*đối(?:\s*\([^)]*\))?", " tương đối", n, flags=re.IGNORECASE)
    n = re.sub(r"\b(?:theo\s+từng\s+time|tại\s+thời\s+điểm\s+time)\s+trong\s+(?:1\s+)?ngày\b",
               "theo time trong ngày", n, flags=re.IGNORECASE)
    n = re.sub(r"\b(?:khối\s+lượng|kl)\s+niêm\s+(?:cổ\s+phiếu\s+)?niêm\s+yết\s+hiện\s+tại\b",
               "kl niêm yết hiện tại", n, flags=re.IGNORECASE)
    n = re.sub(r"\b4/52\s+tuần\b", "52 tuần", n, flags=re.IGNORECASE)
    n = re.sub(r"\btổng\s+klgd\s+khớp\s+lệnh\b", "klgd khớp lệnh", n, flags=re.IGNORECASE)
    n = re.sub(r"\btổng\s+gtgd\s+khớp\s+lệnh\b", "gtgd khớp lệnh", n, flags=re.IGNORECASE)
    n = re.sub(r"\btổng\s+kl\s+thỏa\s+thuận\b", "klgd thỏa thuận", n, flags=re.IGNORECASE)
    n = re.sub(r"\btổng\s+gt\s+thỏa\s+thuận\b", "gtgd thỏa thuận", n, flags=re.IGNORECASE)
    n = re.sub(r"\(\s+", "(", n)
    n = re.sub(r"\s+\)", ")", n)
    n = re.sub(r"\s+", " ", n).strip(" -:–—[]%")
    return n.lower()


def strip_qualifiers(name: str) -> str:
    """Bỏ mọi cụm trong ngoặc đơn — dùng cho fallback matching."""
    return re.sub(r"\s*\([^)]*\)", "", name).strip()


# ---------------------------------------------------------------------------
# 3. Data model
# ---------------------------------------------------------------------------
@dataclass
class BAItem:
    line_num: int          # số dòng 1-based trong file gốc — để truy vết
    stt: str               # đã áp dụng logic group key -> đây CHÍNH LÀ khoá Nhóm
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

    @property
    def is_done_or_doing(self) -> bool:
        return self.mapping_status.strip().lower() in _DONE_STATUSES

    @property
    def is_deleted(self) -> bool:
        return any(w in self.mapping_status.lower() for w in _DELETED_WORDS)


@dataclass
class BAFileMeta:
    module: str
    path: Path
    encoding: str
    delimiter: str
    header_row: int            # 0-indexed
    header: List[str]
    legend_rows: List[int]
    n_raw_rows: int            # tổng số dòng trong file
    n_items: int               # số BAItem sau khi lọc
    profile_source: str        # "yaml" | "heuristic"
    warnings: List[str] = field(default_factory=list)


# ---------------------------------------------------------------------------
# 4. Profile loading
# ---------------------------------------------------------------------------
_PROFILE_CACHE: Dict[str, dict] = {}


def load_ba_profile(root: Optional[Path] = None) -> dict:
    """Đọc system/rules/ba_column_profile.yaml (có cache theo đường dẫn)."""
    root = Path(root) if root else find_project_root()
    key = str(root)
    if key in _PROFILE_CACHE:
        return _PROFILE_CACHE[key]
    path = root / PROFILE_REL
    data: dict = {}
    if path.is_file():
        try:
            import yaml  # PyYAML 6.x có sẵn trong môi trường
            data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
        except Exception as exc:  # pragma: no cover
            print(f"⚠️  Không đọc được {PROFILE_REL}: {exc}", file=sys.stderr)
            data = {}
    _PROFILE_CACHE[key] = data
    return data


def profile_for(root: Optional[Path], module: str) -> dict:
    """Trả profile đã merge `defaults` + entry của module. Không có entry -> {} rỗng + defaults."""
    data = load_ba_profile(root)
    defaults = dict(data.get("defaults") or {})
    modules = data.get("modules") or {}

    # Thử cả tên THÔ lẫn tên đã normalize: MODULE_ALIASES ánh xạ FMS -> QLQ (tên phân hệ
    # trong Datamart), nhưng profile khoá theo tên file BA nên phải khớp được cả "FMS".
    wants = {strip_accents(module.strip()).upper(),
             strip_accents(normalize_module_name(module)).upper()}
    entry = None
    for key, val in modules.items():
        cands = [key] + list((val or {}).get("aliases") or [])
        if any(strip_accents(str(c)).upper() in wants for c in cands):
            entry = dict(val or {})
            entry["_key"] = key
            break

    merged = defaults
    if entry:
        drop = list(defaults.get("drop") or []) + list(entry.get("drop_extra") or [])
        if "drop" in entry:
            drop = list(entry["drop"])
        merged.update(entry)
        merged["drop"] = drop
        merged["_found"] = True
    else:
        merged["_found"] = False
    merged["_drop_rules"] = data.get("drop_rules") or []
    merged["_group_key"] = data.get("group_key") or {}
    return merged


def list_ba_modules(root: Optional[Path] = None) -> List[str]:
    """Liệt kê module theo FILE BA thật trong BRD/BA/, không theo artifact Datamart.

    `get_available_modules()` dò từ `Datamart/hld|lld|flat-table` nên bỏ sót phân hệ đã có BA
    mà chưa có artifact (VP), và trả `QLQ` cho FMS. Lát cắt BA phải bám file BA.
    """
    root = Path(root) if root else find_project_root()
    d = root / "BRD" / "BA"
    if not d.is_dir():
        return []
    return sorted(f.stem[len("BA_analyst_"):] for f in d.glob("BA_analyst_*.csv") if f.is_file())


def resolve_ba_path(root: Optional[Path], module: str) -> Optional[Path]:
    """Tìm BRD/BA/BA_analyst_{module}.csv.

    Thử tên thô trước module_resolver: `MODULE_ALIASES["FMS"] = "QLQ"` (tên phân hệ trong
    Datamart) nhưng file BA vẫn tên `BA_analyst_FMS.csv`, nên đi qua normalize sẽ không thấy.
    """
    root = Path(root) if root else find_project_root()
    d = root / "BRD" / "BA"
    want = strip_accents(module.strip()).upper()
    for f in sorted(d.glob("BA_analyst_*.csv")) if d.is_dir() else []:
        if strip_accents(f.stem[len("BA_analyst_"):]).upper() == want:
            return f
    p = resolve_module_path(root, module, "ba")
    return Path(p) if p else None


# ---------------------------------------------------------------------------
# 5. Heuristic cũ — chỉ dùng khi module chưa có trong profile
# ---------------------------------------------------------------------------
def _legacy_detect(content: str) -> Tuple[str, int, List[str], List[List[str]]]:
    """Bản dò động nguyên gốc của datamart_ba_cross_checker.py:312-386."""
    content = content.lstrip("﻿").replace("\r\n", "\n").replace("\r", "\n")
    delim_scores: Dict[str, Tuple[int, float]] = {}
    for delim in (";", ","):
        try:
            reader = csv.reader(io.StringIO(content, newline=""), delimiter=delim)
            row_lens = [len(r) for idx, r in enumerate(reader) if idx < 15 and any(c.strip() for c in r)]
            if not row_lens:
                continue
            mode_len = Counter(row_lens).most_common(1)[0][0]
            consistency = sum(1 for l in row_lens if l == mode_len) / len(row_lens)
            delim_scores[delim] = (mode_len if mode_len >= 2 else 0, consistency)
        except Exception:
            pass
    best_delim = (max(delim_scores, key=lambda d: (delim_scores[d][0] >= 15, delim_scores[d][0], delim_scores[d][1]))
                  if delim_scores else ",")
    try:
        all_rows = list(csv.reader(io.StringIO(content, newline=""), delimiter=best_delim))
    except csv.Error:
        all_rows = list(csv.reader(io.StringIO(content, newline=""), delimiter=best_delim, quoting=csv.QUOTE_NONE))
    if not all_rows:
        return best_delim, 0, [], []

    best_idx, best_score = 0, -1
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
        if non_empty <= 2:
            score -= 20
        if score > best_score:
            best_score, best_idx = score, idx
    header = [x.lstrip("﻿").strip() for x in all_rows[best_idx]]
    return best_delim, best_idx, header, all_rows[best_idx + 1:]


# ---------------------------------------------------------------------------
# 6. Column resolution
# ---------------------------------------------------------------------------
def _build_col_map(header: Sequence[str]) -> Dict[str, int]:
    """{tên cột lower: index}.

    Tên trùng -> giữ index CUỐI CÙNG. Đây là hành vi của dict comprehension trong bản cũ
    (datamart_ba_cross_checker.py:394) và phải giữ nguyên: FMS/NĐTNN có 2 cột 'Note',
    NHNCK có 2 cột 'Kết quả'. Ở NĐTNN bản cuối rỗng nên `BAItem.note` luôn rỗng — đây là
    lỗi thật, nhưng `note` nuôi PendingClassifier nên sửa ở đây sẽ đổi kết quả phân loại
    5 nhóm PENDING. Xử lý riêng, không gộp vào việc rút trùng lặp này.
    """
    out: Dict[str, int] = {}
    for idx, name in enumerate(header):
        key = (name or "").strip().lower()
        if key:
            out[key] = idx
    return out


def _duplicate_columns(header: Sequence[str]) -> Dict[str, List[int]]:
    """{tên cột: [các index]} cho những tên xuất hiện nhiều hơn một lần."""
    seen: Dict[str, List[int]] = {}
    for idx, name in enumerate(header):
        key = (name or "").strip().lower()
        if key:
            seen.setdefault(key, []).append(idx)
    return {k: v for k, v in seen.items() if len(v) > 1}


def _col_idx(col_map: Dict[str, int], field_key: str, override: Optional[str] = None) -> Optional[int]:
    """Tra index cột. `override` (từ profile) được thử trước, rồi mới tới COLUMN_ALIASES."""
    if override:
        o = _norm(override)
        for col_name, idx in col_map.items():
            if _norm(col_name) == o:
                return idx
    for alias in COLUMN_ALIASES.get(field_key, []):
        a = alias.lower()
        for col_name, idx in col_map.items():
            if col_name == a or a in col_name:
                return idx
    return None


def drop_column_indices(header: Sequence[str], profile: dict, with_sql: bool = False) -> Set[int]:
    """Tập index cột cần bỏ khỏi lát cắt.

    Ba nguồn:
      1. `drop` trong profile (cột theo dõi dự án, không mang ngữ nghĩa thiết kế)
      2. `drop_rules` có điều kiện (VD: bỏ 'Câu lệnh tham khảo…' khi có 'Câu lệnh update (SIT)')
      3. `sql_columns` khi with_sql=False
    Cột không khớp nguồn nào thì được GIỮ — cột mới lạ không bị mất im lặng.
    """
    normed = [_norm(h) for h in header]
    out: Set[int] = set()

    for name in (profile.get("drop") or []):
        n = _norm(name)
        out.update(i for i, h in enumerate(normed) if h == n)

    for rule in (profile.get("_drop_rules") or []):
        pat = rule.get("drop_column_matches")
        guard = rule.get("only_if_column_exists")
        if not pat:
            continue
        if guard and not any(re.search(guard, h, re.IGNORECASE) for h in normed):
            continue
        out.update(i for i, h in enumerate(normed) if re.search(pat, h, re.IGNORECASE))

    if not with_sql:
        for name in (profile.get("sql_columns") or []):
            n = _norm(name)
            out.update(i for i, h in enumerate(normed) if h == n)

    return out


# ---------------------------------------------------------------------------
# 7. Parser chính
# ---------------------------------------------------------------------------
def parse_ba_file(
    filepath: Path,
    profile: Optional[dict] = None,
    include_deleted: bool = False,
    strict: bool = True,
) -> Tuple[List[BAItem], BAFileMeta]:
    """Đọc file BA -> (items, meta).

    profile=None  -> dùng heuristic cũ (tương thích ngược hoàn toàn).
    profile có `_found=True` -> dùng delimiter/header_row/legend_rows đã khai báo và
    kiểm chứng `expect_columns` / `expect_header_contains`; lệch thì ném BaProfileMismatch
    (strict=True) hoặc cảnh báo rồi rơi về heuristic (strict=False).
    """
    filepath = Path(filepath)
    module = filepath.stem.replace("BA_analyst_", "")
    if not filepath.is_file():
        raise FileNotFoundError(f"Không thấy file BA: {filepath}")

    raw_text, enc = read_ba_text(filepath)
    warnings: List[str] = []
    source = "heuristic"

    use_yaml = bool(profile and profile.get("_found"))
    if use_yaml:
        delim = profile.get("delimiter", ",")
        hdr_idx = int(profile.get("header_row", 1))
        legend = [int(x) for x in (profile.get("legend_rows") or [])]
        content = raw_text.lstrip("﻿").replace("\r\n", "\n").replace("\r", "\n")
        try:
            all_rows = list(csv.reader(io.StringIO(content, newline=""), delimiter=delim))
        except csv.Error:
            all_rows = list(csv.reader(io.StringIO(content, newline=""), delimiter=delim,
                                       quoting=csv.QUOTE_NONE))
        problems: List[str] = []
        if len(all_rows) <= hdr_idx:
            problems.append(f"file chỉ có {len(all_rows)} dòng, không tới header_row={hdr_idx}")
            header: List[str] = []
        else:
            header = [x.lstrip("﻿").strip() for x in all_rows[hdr_idx]]
            exp_n = profile.get("expect_columns")
            if exp_n and len(header) != int(exp_n):
                problems.append(f"số cột {len(header)} != expect_columns {exp_n}")
            normed = {_norm(h) for h in header}
            missing = [c for c in (profile.get("expect_header_contains") or []) if _norm(c) not in normed]
            if missing:
                problems.append("thiếu cột khai báo: " + ", ".join(missing))
        if problems:
            msg = (f"{filepath.name} lệch với {PROFILE_REL}: " + "; ".join(problems) +
                   ". Cập nhật profile trước khi chạy tiếp — KHÔNG đoán lại cấu trúc.")
            if strict:
                raise BaProfileMismatch(msg)
            warnings.append(msg)
            use_yaml = False
        else:
            source = "yaml"
            data_rows = [r for i, r in enumerate(all_rows) if i > hdr_idx and i not in legend]
            n_raw = len(all_rows)

    if not use_yaml:
        delim, hdr_idx, header, data_rows = _legacy_detect(raw_text)
        legend = []
        n_raw = hdr_idx + 1 + len(data_rows)
        if profile is not None and not profile.get("_found"):
            warnings.append(f"Module '{module}' chưa có trong {PROFILE_REL} — dùng heuristic dò động. "
                            f"Bổ sung profile để tránh parse sai.")

    col_map = _build_col_map(header)
    dups = _duplicate_columns(header)
    if dups:
        warnings.append(
            "Cột trùng tên (lấy index cuối, theo hành vi bản cũ): "
            + "; ".join(f"{k!r}@{v}" for k, v in dups.items())
        )
    idx = {
        "stt": _col_idx(col_map, "stt", (profile or {}).get("stt_column")),
        "ma": _col_idx(col_map, "ma", (profile or {}).get("ma_column")),
        "dashboard": _col_idx(col_map, "dashboard", (profile or {}).get("dashboard_column")),
        "name": _col_idx(col_map, "name", (profile or {}).get("name_column")),
        "description": _col_idx(col_map, "description"),
        "requirement_group": _col_idx(col_map, "requirement_group"),
        "classification": _col_idx(col_map, "classification"),
        "evaluation": _col_idx(col_map, "evaluation"),
        "mapping_status": _col_idx(col_map, "mapping_status", (profile or {}).get("status_column")),
        "source_table": _col_idx(col_map, "source_table"),
        "source_column": _col_idx(col_map, "source_column"),
        "data_type": _col_idx(col_map, "data_type"),
        "condition": _col_idx(col_map, "condition"),
        "sql": _col_idx(col_map, "sql"),
        "note": _col_idx(col_map, "note"),
    }

    def val(row: List[str], i: Optional[int]) -> str:
        return row[i].strip() if (i is not None and len(row) > i) else ""

    gk = (profile or {}).get("_group_key") or {}
    strip_re = gk.get("strip_prefix_regex") or r"^(?:nhóm|group)\s*"

    items: List[BAItem] = []
    # line_num 1-based trong file gốc. Với đường yaml, data_rows đã bỏ legend nên
    # phải bám theo chỉ số thật; tính lại bằng cách duyệt song song.
    row_indices = ([i for i in range(hdr_idx + 1, n_raw) if i not in legend]
                   if source == "yaml" else list(range(hdr_idx + 1, hdr_idx + 1 + len(data_rows))))

    for pos, r in enumerate(data_rows):
        line_num = (row_indices[pos] + 1) if pos < len(row_indices) else (hdr_idx + 2 + pos)
        if not any(x.strip() for x in r):
            continue

        # --- bộ lọc dòng rác: giữ NGUYÊN thứ tự và điều kiện của bản cũ ---
        pl_val = val(r, idx["classification"]).lower()
        if pl_val in ("phân loại", "chiều/chỉ tiêu cơ sở/chỉ tiêu phái sinh"):
            continue
        stt_val = val(r, idx["stt"]).lower()
        if stt_val in ("stt", "tt"):
            continue
        name = val(r, idx["name"])
        if not name or "tên chiều/chỉ tiêu" in name.lower() or name.lower() == "thông tin (chỉ tiêu)":
            continue
        if not val(r, idx["classification"]) and not val(r, idx["mapping_status"]) \
                and not val(r, idx["source_table"]):
            continue
        st_val = val(r, idx["mapping_status"]).lower()
        if any(w in st_val for w in _DELETED_WORDS) and not include_deleted:
            continue

        # --- suy ra group key từ STT / Mã ---
        ma_val = val(r, idx["ma"])
        if ma_val and (not stt_val or "." in stt_val or not stt_val.isdigit()):
            clean_ma = re.sub(strip_re, "", ma_val, flags=re.IGNORECASE).strip()
            if clean_ma.isdigit():
                stt_val = clean_ma
            elif not stt_val:
                stt_val = ma_val

        items.append(BAItem(
            line_num=line_num,
            stt=stt_val,
            ma=ma_val,
            dashboard=val(r, idx["dashboard"]),
            name=name,
            description=val(r, idx["description"]),
            requirement_group=val(r, idx["requirement_group"]),
            classification=val(r, idx["classification"]),
            evaluation=val(r, idx["evaluation"]),
            mapping_status=val(r, idx["mapping_status"]),
            source_table=val(r, idx["source_table"]),
            source_column=val(r, idx["source_column"]),
            data_type=val(r, idx["data_type"]),
            condition=val(r, idx["condition"]),
            sql=val(r, idx["sql"]),
            note=val(r, idx["note"]),
            raw_row=r,
        ))

    meta = BAFileMeta(
        module=module, path=filepath, encoding=enc, delimiter=delim, header_row=hdr_idx,
        header=header, legend_rows=legend, n_raw_rows=n_raw, n_items=len(items),
        profile_source=source, warnings=warnings,
    )
    return items, meta


def group_ba_items(items: Sequence[BAItem]) -> "OrderedDict[str, List[BAItem]]":
    """Gom BAItem theo khoá Nhóm (`BAItem.stt`), giữ thứ tự xuất hiện trong file."""
    out: "OrderedDict[str, List[BAItem]]" = OrderedDict()
    for it in items:
        out.setdefault(it.stt or "?", []).append(it)
    return out
