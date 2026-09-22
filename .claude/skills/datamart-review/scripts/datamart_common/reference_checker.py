# -*- coding: utf-8 -*-
"""
datamart_common/reference_checker.py — Gate 0: Reference Integrity Audit

Chặn nhóm lỗi "tham chiếu tới thứ không tồn tại" — nguyên nhân gốc của các sự cố
thiết kế đã xảy ra thực tế (PTTT/QLKD, 2026-09-18):

  R1 [L0-ATOMIC-COLUMN-NOT-FOUND]  cột Atomic được tham chiếu nhưng không có trong
                                   YAML Atomic approved (vd: cl_risk_indicator.cl_risk_ind_name
                                   trong khi tên thật là ind_nm; sc_periodic_report.submission_dt,
                                   .record_status và sc_report_input_value.numeric_val không tồn tại).
  R2 [L0-MART-COLUMN-NOT-FOUND]    Detail Mapping trỏ tới mart_column không có trong
                                   Attributes (vd: margin_balance_amt, owner_equity_amt,
                                   capital_adequacy_ratio, active_account_count).
  R3 [L0-CSV-STRUCTURE-BROKEN]     file LLD CSV có dòng lệch số cột do không quote dấu phẩy
                                   trong etl_logic (vd: hash_id('X', y) làm vỡ 4 file QLKD).
  R4 [L0-HLD-LLD-STATUS-DESYNC]    cùng một KPI_ID: HLD ghi PENDING nhưng Detail Mapping
                                   đã điền mapping (hoặc ngược lại).

Không có checker nào trong bộ Gate 1–4 phát hiện được 4 nhóm lỗi này: parity chỉ so
module CSV với master registry (cả hai cùng sai vẫn PASS), orphan chỉ so ở cấp bảng,
flat-table chỉ so cột giữa các tầng Datamart.
"""

from __future__ import annotations

import csv
import io
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple

try:
    from .module_resolver import find_project_root, normalize_module_name, resolve_module_path
except ImportError:  # chạy trực tiếp
    from module_resolver import find_project_root, normalize_module_name, resolve_module_path  # type: ignore


# --------------------------------------------------------------------------
# Kết quả
# --------------------------------------------------------------------------
@dataclass
class RefIssue:
    code: str
    severity: str          # CRITICAL | WARNING
    where: str             # file:line hoặc tên bảng
    message: str


@dataclass
class RefAuditResult:
    module: str
    issues: List[RefIssue] = field(default_factory=list)
    atomic_tables_indexed: int = 0
    atomic_columns_indexed: int = 0
    lld_rows_checked: int = 0
    dm_rows_checked: int = 0

    @property
    def critical(self) -> List[RefIssue]:
        return [i for i in self.issues if i.severity == "CRITICAL"]

    @property
    def passed(self) -> bool:
        return not self.critical


# --------------------------------------------------------------------------
# Index cột Atomic (2 nguồn ưu tiên, CẤM Atomic_LinhLV)
# --------------------------------------------------------------------------
_RE_LDM_PHYS = re.compile(r'^\s{0,2}physical_name:\s*"?([a-z][a-z0-9_]*)"?\s*$', re.M)
_RE_ENTITY_PHYS = re.compile(r'^\s*entity_physical_name:\s*"?([a-z][a-z0-9_]*)"?\s*$', re.M)
_RE_ANY_PHYS = re.compile(r'^\s*-?\s*physical_name:\s*"?([A-Za-z][A-Za-z0-9_]*)"?\s*$', re.M)


def build_atomic_index(root: Path) -> Dict[str, Set[str]]:
    """Trả về {atomic_table: {column, ...}} gộp từ DataModel/Atomic/ và
    DataModel/working/Atomic/lld/. Bỏ qua hoàn toàn Atomic_LinhLV (track cũ đã revert)."""
    index: Dict[str, Set[str]] = {}
    roots = [root / "DataModel" / "Atomic", root / "DataModel" / "working" / "Atomic" / "lld"]
    for base in roots:
        if not base.is_dir():
            continue
        for p in base.rglob("*.yaml"):
            if "Atomic_LinhLV" in p.as_posix():
                continue
            try:
                text = p.read_text(encoding="utf-8")
            except Exception:
                continue
            m = _RE_ENTITY_PHYS.search(text) or _RE_LDM_PHYS.search(text)
            if not m:
                continue
            tbl = m.group(1)
            cols = set(_RE_ANY_PHYS.findall(text))
            cols.discard(tbl)
            index.setdefault(tbl, set()).update(cols)
    return index


# --------------------------------------------------------------------------
# Đọc CSV an toàn + kiểm cấu trúc (R3)
# --------------------------------------------------------------------------
def read_csv_strict(path: Path) -> Tuple[List[str], List[List[str]], List[Tuple[int, int]]]:
    """Đọc CSV, trả (header, rows, broken) với broken = [(line_no, ncols)]."""
    raw = path.read_text(encoding="utf-8-sig", errors="replace")
    rows = list(csv.reader(io.StringIO(raw)))
    if not rows:
        return [], [], []
    header = rows[0]
    n = len(header)
    body, broken = [], []
    for i, r in enumerate(rows[1:], start=2):
        if not r or not any(x.strip() for x in r):
            continue
        if len(r) != n:
            broken.append((i, len(r)))
        else:
            body.append(r)
    return header, body, broken


# --------------------------------------------------------------------------
# R1 + R3: module LLD CSV
# --------------------------------------------------------------------------
_LLD_REQUIRED = ["datamart_entity", "datamart_table", "datamart_attribute", "datamart_column",
                 "etl_logic", "atomic_table", "atomic_column"]
# token không phải tên bảng Atomic khi bóc `a.b` trong etl_logic
_SQL_NOISE = {"case", "when", "then", "else", "end", "cast", "coalesce", "nullif", "sum", "avg",
              "min", "max", "count", "lag", "lead", "over", "partition", "order", "rows",
              "between", "preceding", "current", "row", "where", "and", "or", "not", "in",
              "join", "on", "select", "from", "group", "by", "as", "distinct", "round"}


def check_module_lld(root: Path, module: str, atomic: Dict[str, Set[str]],
                     res: RefAuditResult, mart_tables: Optional[Set[str]] = None) -> Dict[str, str]:
    """Kiểm LLD module. Trả map {logical_entity_lower: physical_table} phục vụ R2.

    mart_tables: tập tên bảng Datamart — dùng để bỏ qua các tham chiếu tới bảng mart
    (self-reference / reuse cross-module). Vi phạm "flatten về Atomic" thuộc Lớp 2 của
    datamart-review, không phải phạm vi Gate 0.
    """
    mart_tables = mart_tables or set()
    lld_dir = root / "Datamart" / "lld" / module
    logical_map: Dict[str, str] = {}
    if not lld_dir.is_dir():
        return logical_map

    for path in sorted(lld_dir.glob("*.csv")):
        header, rows, broken = read_csv_strict(path)
        rel = f"Datamart/lld/{module}/{path.name}"
        for line_no, ncol in broken:
            res.issues.append(RefIssue(
                "L0-CSV-STRUCTURE-BROKEN", "CRITICAL", f"{rel}:{line_no}",
                f"Dòng có {ncol} cột trong khi header có {len(header)} cột — dấu phẩy trong "
                f"etl_logic/description chưa được quote. Ghi lại file bằng csv.writer "
                f"(QUOTE_ALL) thay vì nối chuỗi thủ công."))
        if not header:
            continue
        ix = {n: i for i, n in enumerate(header)}
        if not all(c in ix for c in _LLD_REQUIRED):
            res.issues.append(RefIssue(
                "L0-CSV-STRUCTURE-BROKEN", "CRITICAL", rel,
                f"Thiếu cột bắt buộc: {[c for c in _LLD_REQUIRED if c not in ix]}"))
            continue

        for r in rows:
            res.lld_rows_checked += 1
            logical_map.setdefault(r[ix["datamart_entity"]].strip().lower(),
                                   r[ix["datamart_table"]].strip())
            owner = f"{r[ix['datamart_table']]}.{r[ix['datamart_column']]}"

            # 1a. cặp khai báo atomic_table / atomic_column
            atbl = r[ix["atomic_table"]].strip()
            acol_raw = r[ix["atomic_column"]].strip()
            # atomic_column có thể liệt kê nhiều cột: "market_id / market_code"
            # Bỏ placeholder không phải tên cột: (hardcode), (null), (derived), N/A...
            acols = [c.strip() for c in acol_raw.split("/")
                     if c.strip() and _RE_IDENT.fullmatch(c.strip())]
            if atbl and atbl in atomic and acols:
                missing = [c for c in acols if c not in atomic[atbl]]
                if missing:
                    hints = {c: _suggest(c, atomic[atbl]) for c in missing}
                    detail = ", ".join(
                        f"`{c}`" + (f" (gợi ý: `{hints[c]}`)" if hints[c] else "") for c in missing)
                    res.issues.append(RefIssue(
                        "L0-ATOMIC-COLUMN-NOT-FOUND", "CRITICAL", f"{rel} [{owner}]",
                        f"Cột Atomic không tồn tại trên `{atbl}`: {detail}"))
            elif (atbl and atbl not in atomic and atbl not in mart_tables  # noqa: E501
                  and atbl not in ("Generated", "cdr_dt_dim") and "/" not in atbl):
                res.issues.append(RefIssue(
                    "L0-ATOMIC-COLUMN-NOT-FOUND", "WARNING", f"{rel} [{owner}]",
                    f"Bảng Atomic `{atbl}` không tìm thấy trong DataModel/Atomic/ "
                    f"lẫn DataModel/working/Atomic/lld/."))

            # 1b. mọi tham chiếu `table.column` trong etl_logic
            for t, c in _RE_QUALIFIED.findall(r[ix["etl_logic"]]):
                if t in _SQL_NOISE or t in mart_tables or t not in atomic:
                    continue
                if c not in atomic[t]:
                    near = _suggest(c, atomic[t])
                    res.issues.append(RefIssue(
                        "L0-ATOMIC-COLUMN-NOT-FOUND", "CRITICAL", f"{rel} [{owner}]",
                        f"etl_logic tham chiếu `{t}.{c}` — cột này KHÔNG tồn tại trên Atomic."
                        + (f" Gợi ý gần nhất: `{near}`." if near else "")))
    return logical_map


_RE_QUALIFIED = re.compile(r'\b([a-z][a-z0-9_]{2,})\.([a-z][a-z0-9_]{2,})\b')
_RE_IDENT = re.compile(r'[a-z][a-z0-9_]*')


def _suggest(name: str, pool: Set[str]) -> Optional[str]:
    import difflib
    hits = difflib.get_close_matches(name, sorted(pool), n=1, cutoff=0.6)
    return hits[0] if hits else None


# --------------------------------------------------------------------------
# R2 + R4: Detail Mapping
# --------------------------------------------------------------------------
def load_mart_columns(root: Path) -> Dict[str, Set[str]]:
    master = root / "Datamart" / "lld" / "datamart_attributes.csv"
    out: Dict[str, Set[str]] = {}
    if not master.is_file():
        return out
    header, rows, _ = read_csv_strict(master)
    if not header:
        return out
    ix = {n: i for i, n in enumerate(header)}
    for r in rows:
        # Detail Mapping của một số module ghi mart_column bằng tên logical
        # (`Volatility 30 Days`), số khác ghi physical (`volatility_30_days`) —
        # chấp nhận cả hai, việc thống nhất convention thuộc linter Lớp 3.
        vals = {r[ix["datamart_column"]].strip(), r[ix["datamart_attribute"]].strip()}
        vals.discard("")
        for key in (r[ix["datamart_table"]].strip(), r[ix["datamart_entity"]].strip().lower()):
            if key:
                out.setdefault(key, set()).update(vals)
    return out


_CONV_CACHE: Dict[str, dict] = {}


def load_conventions(root: Path) -> dict:
    """Đọc system/rules/datamart_conventions.yaml (RFC Đ5). Rỗng nếu chưa có file."""
    key = str(root)
    if key in _CONV_CACHE:
        return _CONV_CACHE[key]
    p = root / "system" / "rules" / "datamart_conventions.yaml"
    conv: dict = {}
    if p.is_file():
        try:
            import yaml
            conv = yaml.safe_load(p.read_text(encoding="utf-8")) or {}
        except Exception:
            conv = {}
    _CONV_CACHE[key] = conv
    return conv


def check_conventions(root: Path, module: str, header: List[str], rows: List[List[str]],
                      rel: str, res: RefAuditResult) -> None:
    """R5 [L0-CONVENTION-VIOLATION] — giá trị enum ngoài danh mục cho phép."""
    conv = load_conventions(root)
    if not conv:
        return
    ix = {n: i for i, n in enumerate(header)}
    for field in ("column_role", "tinh_chat"):
        spec = conv.get(field) or {}
        if field not in ix or not spec.get("allowed"):
            continue
        allowed = set(spec["allowed"])
        allowed |= set((spec.get("per_module_override") or {}).get(module, []))
        aliases = spec.get("deprecated_aliases") or {}
        seen: Dict[str, int] = {}
        for r in rows:
            v = r[ix[field]].strip()
            if v not in allowed:
                seen[v] = seen.get(v, 0) + 1
        for v, n in sorted(seen.items(), key=lambda x: -x[1]):
            fix = aliases.get(v)
            res.issues.append(RefIssue(
                "L0-CONVENTION-VIOLATION", "WARNING", rel,
                f"{field} = `{v}` không có trong danh mục cho phép ({n} dòng)."
                + (f" Đổi thành `{fix}`." if fix else
                   " Bổ sung vào system/rules/datamart_conventions.yaml nếu là giá trị hợp lệ mới.")))


def check_detail_mapping(root: Path, module: str, mart: Dict[str, Set[str]],
                         logical_map: Dict[str, str], res: RefAuditResult) -> None:
    dm = resolve_module_path(root, module, "detail_mapping")
    if not dm or not Path(dm).is_file():
        return
    dm = Path(dm)
    header, rows, broken = read_csv_strict(dm)
    rel = f"Datamart/lld/{dm.name}"
    for line_no, ncol in broken:
        res.issues.append(RefIssue(
            "L0-CSV-STRUCTURE-BROKEN", "CRITICAL", f"{rel}:{line_no}",
            f"Dòng có {ncol} cột, header {len(header)} cột."))
    if not header:
        return
    ix = {n: i for i, n in enumerate(header)}
    check_conventions(root, module, header, rows, rel, res)
    if "mart_table" not in ix or "mart_column" not in ix:
        return

    for i, r in enumerate(rows, start=2):
        res.dm_rows_checked += 1
        mt = r[ix["mart_table"]].strip()
        mc = r[ix["mart_column"]].strip()
        if not mt or not mc:
            continue
        key = mt if mt in mart else mt.lower()
        if key not in mart:
            res.issues.append(RefIssue(
                "L0-MART-COLUMN-NOT-FOUND", "CRITICAL", f"{rel}:{i}",
                f"mart_table `{mt}` không có trong Attributes/master registry."))
            continue
        # Dấu "/" vừa có thể là ký tự trong chính tên cột (`EBIT / Lãi vay`),
        # vừa có thể là dấu liệt kê nhiều cột cho 1 slicer
        # (`Business Line Level 1 Code / Classification Business Line Name`).
        # Ưu tiên khớp nguyên chuỗi, chỉ tách khi nguyên chuỗi không khớp.
        cols = mart[key]
        if mc in cols:
            continue
        parts = [c.strip() for c in mc.split("/") if c.strip()]
        if len(parts) > 1 and all(c in cols for c in parts):
            continue
        missing = [c for c in parts if c not in cols] if len(parts) > 1 else [mc]
        if missing:
            hints = {c: _suggest(c, mart[key]) for c in missing}
            detail = ", ".join(f"`{c}`" + (f" (gợi ý: `{hints[c]}`)" if hints[c] else "")
                               for c in missing)
            res.issues.append(RefIssue(
                "L0-MART-COLUMN-NOT-FOUND", "CRITICAL", f"{rel}:{i}",
                f"mart_column không tồn tại trong Attributes của `{mt}`: {detail}"))


# --------------------------------------------------------------------------
# R4: đồng bộ trạng thái HLD ↔ Detail Mapping
# --------------------------------------------------------------------------
_RE_KPI_ROW = re.compile(r'^\|\s*(K_[A-ZĐ]+_\d+)\s*\|.*\|\s*(READY|PENDING)\s*\|\s*$')


def check_status_sync(root: Path, module: str, res: RefAuditResult) -> None:
    hld = resolve_module_path(root, module, "hld")
    dm = resolve_module_path(root, module, "detail_mapping")
    if not hld or not dm:
        return
    hld_status: Dict[str, Set[str]] = {}
    for line in Path(hld).read_text(encoding="utf-8").split("\n"):
        m = _RE_KPI_ROW.match(line.rstrip())
        if m:
            hld_status.setdefault(m.group(1), set()).add(m.group(2))

    header, rows, _ = read_csv_strict(Path(dm))
    if not header:
        return
    ix = {n: i for i, n in enumerate(header)}
    if "kpi_id" not in ix or "mart_table" not in ix:
        return
    role_ix = ix.get("column_role")
    dm_filled: Dict[str, bool] = {}
    dm_derived: Dict[str, bool] = {}
    for r in rows:
        k = r[ix["kpi_id"]].strip()
        filled = bool(r[ix["mart_table"]].strip() or r[ix["mart_column"]].strip())
        dm_filled[k] = dm_filled.get(k, False) or filled
        # Rule L15 Case 2 / L16: DERIVED và DEPRECATED được phép để trống 2 cột mart
        role = r[role_ix].strip().upper() if role_ix is not None else ""
        dm_derived[k] = dm_derived.get(k, False) or role in ("DERIVED", "DEPRECATED")

    for k, filled in sorted(dm_filled.items()):
        st = hld_status.get(k)
        if not st:
            continue
        if (not filled) and dm_derived.get(k):
            continue  # chỉ tiêu BI phái sinh — hợp lệ khi để trống mart_table/mart_column
        if filled and st == {"PENDING"}:
            res.issues.append(RefIssue(
                "L0-HLD-LLD-STATUS-DESYNC", "CRITICAL", f"{k}",
                "Detail Mapping đã điền mart_table/mart_column nhưng bảng KPI trong HLD "
                "vẫn ghi PENDING ở mọi Nhóm — nâng READY ở LLD phải đồng bộ ngược lên HLD."))
        if (not filled) and st == {"READY"}:
            res.issues.append(RefIssue(
                "L0-HLD-LLD-STATUS-DESYNC", "WARNING", f"{k}",
                "HLD ghi READY nhưng Detail Mapping để trống mart_table/mart_column."))


# --------------------------------------------------------------------------
# Điều phối
# --------------------------------------------------------------------------
def audit_module_references(root: Path, module: str) -> RefAuditResult:
    module = normalize_module_name(module)
    res = RefAuditResult(module=module)
    atomic = build_atomic_index(root)
    res.atomic_tables_indexed = len(atomic)
    res.atomic_columns_indexed = sum(len(v) for v in atomic.values())
    mart = load_mart_columns(root)
    mart_tables = {t for t in mart if t and t[0].islower()}
    # Bảng cấu hình / bảng Datamart đã đăng ký trong model registry nhưng chưa có
    # dòng thuộc tính nào (vd risk_weight_config, status_threshold_config — chuyên viên
    # nhập tay trên Kho dữ liệu, không phải entity Atomic). Không coi là thiếu nguồn Atomic.
    model = root / "Datamart" / "datamart_model.yaml"
    if model.is_file():
        mart_tables.update(re.findall(r'^\s*datamart_table:\s*"?([a-z][a-z0-9_]*)"?\s*$',
                                      model.read_text(encoding="utf-8"), re.M))
    logical_map = check_module_lld(root, module, atomic, res, mart_tables)
    check_detail_mapping(root, module, mart, logical_map, res)
    check_status_sync(root, module, res)
    return res


def issue_key(i: "RefIssue") -> str:
    """Khóa ổn định để so sánh giữa 2 lần chạy — dùng cho chế độ --baseline."""
    return f"{i.code}|{i.where}"


def render_report_delta(res: RefAuditResult, baseline_keys: set) -> str:
    """In DELTA so với baseline thay vì lặp lại toàn bộ danh sách issue mỗi lần.

    Lý do: trong phiên marathon nhiều Nhóm, chạy lại Gate 0 sau MỌI Edit (đúng
    hard rule CLAUDE.md) nhưng in lại nguyên 13-16 dòng warning y hệt mỗi lần là
    nguồn phình ngữ cảnh đo được lớn nhất (xem context_window_analysis 2026-09-21,
    mục 2 khoản #2) — vì phần lớn issue là pre-existing, không đổi giữa các lần.
    """
    current: Dict[str, RefIssue] = {issue_key(i): i for i in res.issues}
    cur_keys = set(current)
    new_keys = sorted(cur_keys - baseline_keys)
    resolved_keys = sorted(baseline_keys - cur_keys)
    unchanged = len(cur_keys & baseline_keys)

    L = ["=" * 70,
         f" Datamart Reference Integrity Audit (DELTA vs baseline): {res.module} "
         f"[{'PASS' if res.passed else 'FAIL'}]",
         "=" * 70,
         f"  CRITICAL hiện tại: {len(res.critical)}   WARNING hiện tại: {len(res.issues) - len(res.critical)}",
         f"  Không đổi so với baseline: {unchanged}   Mới phát sinh: {len(new_keys)}   Đã hết: {len(resolved_keys)}"]
    if new_keys:
        L += ["", "-" * 70, " MỚI phát sinh (chưa có trong baseline)", "-" * 70]
        for k in new_keys[:100]:
            i = current[k]
            mark = "[X]" if i.severity == "CRITICAL" else "[!]"
            L.append(f"  {mark} [{i.code}] {i.where}")
            L.append(f"      {i.message}")
    if resolved_keys:
        L += ["", "-" * 70, " ĐÃ HẾT so với baseline", "-" * 70]
        for k in resolved_keys[:100]:
            L.append(f"  [-] {k}")
    if not new_keys and not resolved_keys:
        L.append("\nⓘ Không có thay đổi nào so với baseline.")
    L.append("=" * 70)
    return "\n".join(L)


def render_report(res: RefAuditResult) -> str:
    L = ["=" * 70,
         f" Datamart Reference Integrity Audit: {res.module} "
         f"[{'PASS' if res.passed else 'FAIL'}]",
         "=" * 70,
         f"  Atomic tables indexed:  {res.atomic_tables_indexed}",
         f"  Atomic columns indexed: {res.atomic_columns_indexed}",
         f"  LLD rows checked:       {res.lld_rows_checked}",
         f"  Detail Mapping rows:    {res.dm_rows_checked}",
         f"  CRITICAL: {len(res.critical)}   WARNING: {len(res.issues) - len(res.critical)}"]
    if res.issues:
        L += ["", "-" * 70, " Issues", "-" * 70]
        for i in res.issues[:200]:
            mark = "[X]" if i.severity == "CRITICAL" else "[!]"
            L.append(f"  {mark} [{i.code}] {i.where}")
            L.append(f"      {i.message}")
        if len(res.issues) > 200:
            L.append(f"  ... còn {len(res.issues) - 200} issue nữa")
    L.append("=" * 70)
    return "\n".join(L)
