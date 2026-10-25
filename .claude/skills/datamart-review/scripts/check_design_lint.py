# -*- coding: utf-8 -*-
"""
check_design_lint.py — Gate 8: Design Lint (các lỗi thực tế không Gate 0–7 nào bắt được).

Bổ sung 2026-09-25 sau phiên NDTNN/PTTT/TKNB/GSTT:
  D1 [L1-HLD-KPI-ROW-CELLS]   Dòng bảng KPI HLD không đúng 7 cột (VD chèn ghi chú thành ô riêng → 8 cột).
                              check_hld_5b chỉ đếm SỐ BẢNG 7 cột, không soi từng dòng.
  D2 [L2-TABLE-ZERO-USAGE]    Bảng Datamart có LLD nhưng 0 dòng Detail Mapping tham chiếu (mart_table hoặc
                              physical name trong logic). check_orphan PASS nếu bảng còn đủ 3 tầng
                              LLD/Entities/Flat, dù không còn KPI nào dùng → phải chạy All-Tier Cleanup.
  D3 [L4-FLAT-COMMENT-PARAM]  Dòng comment flat SQL có ':etl_date' dính ký tự khác khoảng trắng/xuống dòng
                              (VD ':etl_date.') — check_flat_table hiểu nhầm là tham số lạ → Gate 4 FAIL giả.

Bổ sung 2026-09-26 (review Cluster 4 GSTT — K_GSTT_92/119/75/76/124/125 lọt lưới nhiều tháng):
  D4 [L3-DERIVED-NON-INLINE] Cột `logic` của dòng `column_role=DERIVED` tham chiếu thẳng mã KPI khác
                              (`K_{MODULE}_N`) thay vì inline công thức vật lý — vi phạm quy tắc đã ghi ở
                              `datamart-lld-design/reference/phase2_detail_mapping.md` và
                              `datamart-review/reference/review_checklist.md`, nhưng chưa Gate nào tự động
                              kiểm tới nay. Chỉ soi phần TRƯỚC dấu `[` đầu tiên (ghi chú/annotation trong
                              ngoặc vuông được phép nhắc tên KPI khác để tra lịch sử, không tính là phụ
                              thuộc công thức). Ngoại lệ YoY (theo tài liệu): nếu logic/ghi_chú có nhắc
                              "YoY"/"yoy" → hạ xuống WARNING thay vì ERROR, vẫn in ra để xác nhận tay.

Bổ sung 2026-10-01 (module TT — K_TT_62 từng chiếm 5 dòng Detail Mapping):
  D5 [L3-KPI-ROW-MULTIPLIED] Quy tắc L18 — KPI có dòng `column_role=MEASURE` phải đúng 1 dòng; WHERE/GROUP BY
                              nằm trong `logic` MEASURE, không sinh dòng FILTER/GROUP_BY/SLICER đi kèm cùng
                              `kpi_id`. Chỉ ÁP DỤNG cho module trong L18_MODULES (đã chuyển sang kiểu 1 dòng/KPI);
                              module khác (GSDC, GSTT...) giữ kiểu cũ nên bị bỏ qua, trừ khi thêm `--l18`
                              (khi đó mức WARNING, chỉ để đo mức độ nhân dòng).

Bổ sung 2026-10-09 (review PTTT Nhóm 12 — Fact nối giao dịch HNX bằng symbol, Data Modeler chuyển sang snapshot):
  D6 [L3-HNX-ISSUE-CODE-JOIN]            `etl_logic` nối `security_trading_snapshot.symbol` với
                              `securities_trade.security_symbol_code` mà không có nhánh `isin_code` — HNX lưu ISSUE_CODE (ISIN)
                              ở cột này nên giao dịch HNX bị rơi. WARNING (quy tắc A17, datamart-lld-design).
  D7 [L3-CUMULATIVE-SNAPSHOT-NOT-DEDUPED] `SUM/AVG(security_trading_snapshot.<cột cộng dồn từ đầu ngày>)` không có điều kiện
                              `trading_time` — mỗi ngày có nhiều bản ghi intraday, mỗi bản ghi đã là số cộng dồn nên SUM nhiều bản
                              ghi nhân lặp. Phải lấy bản ghi `trading_time` mới nhất của symbol × trading_dt. WARNING (A18).

Bổ sung 2026-10-15 (đánh giá Harness v2.0 — tài liệu TKCSLD sinh bằng render_datamart_md.py):
  D8 [L2-DESC-DOC-LEAK]      Mô tả cột LLD sau clean_description.clean() còn mã KPI/O_, [SỬA …], ghi chú BA/quy trình
                              → lọt vào tài liệu gửi UBCKNN. ERROR. Định nghĩa rò rỉ dùng chung với renderer.
  D9 [L2-LINEAGE-SLASH-PAIR] source_entity↔atomic_table hoặc source_attribute↔atomic_column lệch số phần tử '/'.
                              WARNING (đo 2026-10-15: 78 dòng toàn repo).

Bổ sung 2026-10-23 (Fact `fct_securities_company_financial_structure_snpst` QLKD không khai báo khóa dòng — luật A22):
  D10 [L2-FACT-NO-ROW-KEY]   Fact (LLD per-table) không có cột `key = PK`. ERROR; riêng Fact đã có trước 2026-10-23 và nằm trong
                              `reference/fact_row_key_baseline.yaml` chỉ in 1 dòng thông tin `[i]` (nợ có tên, không chặn). PK phải
                              `nullable = false`, đúng 1 cột PK/Fact (L2-FACT-PK-INVALID, ERROR); tên còn trong baseline dù đã có PK → WARNING (gỡ tên).
  D11 [L4-FLAT-ORDERBY-MISSING-PK] Flat ClickHouse của Fact có PK mà `ORDER BY` không chứa cột PK. ERROR — ReplicatedReplacingMergeTree
                              dedup theo ORDER BY nên các dòng cùng (ngày, 1 dim) bị gộp thành 1 khi merge (mất dữ liệu).

Bổ sung 2026-10-24 (QLQ `fund_management_company_dim.fmc_id` sinh bằng hash khác id Atomic, trong khi 3 bảng khác carry `fmc_id` Atomic bằng direct):
  D12 [L2-DIM-PK-GENERATED-CARRIED] PK Dimension là `Generated` nhưng cùng module có cột `direct` mang id Atomic của đúng entity driving
                              (PK Atomic, hoặc FK Atomic có comment `FK target: <driving>.<pk>`). Các cột đó chỉ join được vào PK Dim nếu
                              PK Dim = id Atomic → ERROR; sửa: PK Dim `direct` ← `<driving>.<pk>` (luật A23). Dim không có cột carry thì
                              giữ `Generated` (Fact nối Dim qua lookup BK nên không phụ thuộc cách sinh PK Dim).

Bổ sung 2026-10-24 (rà soát QLQ 28 Nhóm: Detail Mapping dùng `cdr_dt_dim.cdr_year`, `investment_fund.fund_tp_code`, `branch_tp_code`… — cột không tồn tại,
Gate 0 vẫn PASS vì chỉ kiểm cặp `mart_table`/`mart_column`, không kiểm các `bảng.cột` viết TRONG cột `logic`):
  D13 [L0-DM-LOGIC-COLUMN-NOT-FOUND] `bảng.cột` trong cột `logic` của Detail Mapping (bỏ phần ghi chú trong `[...]`) hoặc trong ô Công thức của
                              bảng KPI HLD (chỉ phần trong dấu backtick), mà `bảng` là bảng Datamart/Atomic đã biết còn `cột` không có ở Attributes CSV /
                              YAML Atomic. ERROR (luật A24). Nợ có từ trước nằm trong `reference/dm_logic_column_baseline.yaml` (chỉ in `[i]`, không chặn);
                              mục baseline đã hết vi phạm → WARNING (gỡ tên). Sinh lại baseline: `--print-dm-logic-baseline`.

  D14 [L1-HLD-MAPPING-ROW-CELLS] Dòng của bảng "Bảng mapping nguồn" (header `| Tên KPI | Bảng nguồn (BA) | Atomic entity | Atomic table |`) không
                              đúng 4 ô — VD dán cả công thức/ghi chú KPI vào dòng mapping (K_QLQ_35: 7 ô). ERROR.

Mức độ: D1, D3, D4 (không phải ngoại lệ YoY), D5 (module trong L18_MODULES), D12, D13 (ngoài baseline), D14 = ERROR; D2, D4 (ngoại lệ YoY),
D5 (ép bằng --l18 trên module ngoài L18_MODULES) = WARNING (dimension có thể
được dùng qua JOIN của module khác — xác nhận tay).
Exit 1 nếu có ERROR, hoặc có WARNING khi --strict.

Usage:
    python scripts/check_design_lint.py --module GSTT
    python scripts/check_design_lint.py --module ALL --strict
"""
from __future__ import annotations

import argparse
import csv
import re
import sys
from pathlib import Path

_script_dir = Path(__file__).resolve().parent
if str(_script_dir) not in sys.path:
    sys.path.insert(0, str(_script_dir))
for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from datamart_common import find_project_root, get_available_modules  # noqa: E402
from datamart_common.module_resolver import resolve_module_path  # noqa: E402

KPI_HEADER = re.compile(r"^\|\s*KPI ID\s*\|.*\|\s*Trạng thái\s*\|\s*$")
MAP_HEADER = re.compile(r"^\|\s*Tên KPI\s*\|\s*Bảng nguồn.*\|\s*Atomic table\s*\|\s*$")
KPI_REF = re.compile(r"K_[A-Z0-9]+_\d+")

# Module đã chuyển sang Quy tắc L18 (1 KPI có MEASURE = 1 dòng Detail Mapping). Thêm module vào đây khi
# chuyển đổi/thiết kế mới; GSDC/GSTT... chưa chuyển nên không có trong tập này.
L18_MODULES = {"TT", "QLKD", "VP"}  # QLKD thêm 2026-10-19 sau khi gộp 113 KPI (FILTER/SLICER -> WHERE/GROUP BY của MEASURE); VP thêm 2026-10-25 (thiết kế lại từ đầu theo L18)


def cells(line: str) -> int:
    # bỏ nội dung trong backtick để '|' trong công thức không bị đếm nhầm
    s = re.sub(r"`[^`]*`", "``", line.strip())
    s = s.replace("\\|", "")
    return s.count("|") - 1


def check_hld(hld: Path):
    out = []
    lines = hld.read_text(encoding="utf-8-sig").splitlines()
    in_tbl, want = False, 0
    for i, ln in enumerate(lines, 1):
        if KPI_HEADER.match(ln):
            in_tbl, want = True, cells(ln)
            continue
        if in_tbl:
            if not ln.startswith("|"):
                in_tbl = False
                continue
            if re.match(r"^\|\s*-{3,}", ln):
                continue
            n = cells(ln)
            if n != want:
                kid = ln.split("|")[1].strip()
                out.append(("ERROR", "L1-HLD-KPI-ROW-CELLS", f"{hld.name}:{i} {kid} có {n} cột, bảng KPI yêu cầu {want}"))
    # D14 — bảng "Bảng mapping nguồn": mọi dòng đúng số ô của header (4)
    in_map, want_m = False, 0
    for i, ln in enumerate(lines, 1):
        if MAP_HEADER.match(ln):
            in_map, want_m = True, cells(ln)
            continue
        if in_map:
            if not ln.startswith("|"):
                in_map = False
                continue
            if re.match(r"^\|\s*-{3,}", ln):
                continue
            n = cells(ln)
            if n != want_m:
                kid = ln.split("|")[1].strip()
                out.append(("ERROR", "L1-HLD-MAPPING-ROW-CELLS", f"{hld.name}:{i} {kid} có {n} ô, bảng mapping nguồn yêu cầu {want_m} (Tên KPI | Bảng nguồn (BA) | Atomic entity | Atomic table) — không dán công thức/ghi chú KPI vào dòng mapping"))
    return out


def lld_tables(root: Path, module: str):
    d = root / "Datamart" / "lld" / module
    res = {}
    if not d.exists():
        return res
    for f in sorted(d.glob("*.csv")):
        try:
            with open(f, encoding="utf-8-sig", newline="") as fh:
                for r in csv.DictReader(fh):
                    t = (r.get("datamart_table") or "").strip()
                    e = (r.get("datamart_entity") or "").strip()
                    if t:
                        res.setdefault(t, (e, f.name))
                        break
        except Exception:
            continue
    return res


def check_usage(root: Path, module: str):
    out = []
    dm = resolve_module_path(root, module, "detail_mapping")
    if not dm or not Path(dm).exists():
        return out
    with open(dm, encoding="utf-8-sig", newline="") as fh:
        rows = list(csv.DictReader(fh))
    blob_logic = "\n".join((r.get("logic") or "") for r in rows)
    ents = {(r.get("mart_table") or "").strip() for r in rows}
    for t, (e, fname) in lld_tables(root, module).items():
        if e in ents or re.search(r"\b" + re.escape(t) + r"\b", blob_logic):
            continue
        out.append(("WARNING", "L2-TABLE-ZERO-USAGE",
                    f"{t} ({e}, {fname}) — 0 dòng Detail Mapping {module} tham chiếu. Nếu không module nào dùng → All-Tier Cleanup (Nhánh B); nếu là Dimension dùng qua JOIN module khác → ghi rõ ở Section 4 HLD"))
    return out


def check_derived_inline(root: Path, module: str):
    out = []
    dm = resolve_module_path(root, module, "detail_mapping")
    if not dm or not Path(dm).exists():
        return out
    with open(dm, encoding="utf-8-sig", newline="") as fh:
        rows = list(csv.DictReader(fh))
    for i, r in enumerate(rows, 2):
        if (r.get("column_role") or "").strip() != "DERIVED":
            continue
        logic = r.get("logic") or ""
        kpi_id = (r.get("kpi_id") or "").strip()
        formula_part = logic.split("[", 1)[0]  # bỏ phần ghi chú trong ngoặc vuông, chỉ soi công thức thật
        refs = sorted({m for m in KPI_REF.findall(formula_part) if m != kpi_id})
        if not refs:
            continue
        ghi_chu = r.get("ghi_chu") or ""
        is_yoy = "yoy" in (logic + ghi_chu).lower()
        level = "WARNING" if is_yoy else "ERROR"
        note = " (có nhắc YoY — xác nhận tay đây là ngoại lệ hợp lệ, không phải lười inline)" if is_yoy else ""
        out.append((level, "L3-DERIVED-NON-INLINE",
                    f"{Path(dm).name}:{i} {kpi_id} (Nhóm: {(r.get('nhom') or '')[:30]}) — logic tham chiếu "
                    f"{', '.join(refs)} thay vì inline công thức vật lý xuống physical_table.physical_column{note}"))
    return out


def check_one_row_per_kpi(root: Path, module: str, force: bool = False):
    """D5 — Quy tắc L18: KPI có MEASURE phải đúng 1 dòng Detail Mapping."""
    out = []
    if module.upper() not in L18_MODULES and not force:
        return out
    dm = resolve_module_path(root, module, "detail_mapping")
    if not dm or not Path(dm).exists():
        return out
    with open(dm, encoding="utf-8-sig", newline="") as fh:
        rows = list(csv.DictReader(fh))
    by = {}
    for i, r in enumerate(rows, 2):
        # Khóa gom = (Nhóm, kpi_id) — 2026-10-25 (VP): KPI dùng lại ở Nhóm khác (Reuse Case 1) có dòng MEASURE riêng
        # theo từng Nhóm trong Detail Mapping; L18 chỉ cấm nhân dòng TRONG CÙNG 1 Nhóm (FILTER/SLICER đi kèm MEASURE).
        by.setdefault(((r.get("nhom") or "").strip(), (r.get("kpi_id") or "").strip()), []).append((i, r))
    level = "ERROR" if module.upper() in L18_MODULES else "WARNING"
    for (_nhom, kpi_id), lst in by.items():
        if not any((r.get("column_role") or "").strip() == "MEASURE" for _, r in lst) or len(lst) == 1:
            continue
        roles = {}
        for _, r in lst:
            roles[(r.get("column_role") or "").strip()] = roles.get((r.get("column_role") or "").strip(), 0) + 1
        detail = ", ".join(f"{k}×{v}" for k, v in roles.items())
        out.append((level, "L3-KPI-ROW-MULTIPLIED",
                    f"{Path(dm).name}:{lst[0][0]}-{lst[-1][0]} {kpi_id} có {len(lst)} dòng ({detail}) — KPI có MEASURE "
                    f"phải đúng 1 dòng, gộp WHERE/GROUP BY vào logic MEASURE (Quy tắc L18)"))
    return out


_RE_HNX_JOIN = re.compile(r"security_trading_snapshot\.symbol\s*=\s*securities_trade\.security_symbol_code"
                          r"|securities_trade\.security_symbol_code\s*=\s*security_trading_snapshot\.symbol")
_CUMULATIVE_FALLBACK = ("total_trading_vol", "total_trading_val", "pt_total_traded_vol", "pt_total_traded_val")


def cumulative_snapshot_cols(root: Path):
    """Cột của security_trading_snapshot mà Atomic mô tả là số cộng dồn từ đầu ngày (đọc từ YAML, có fallback)."""
    cols = set()
    for p in (root / "DataModel" / "Atomic").rglob("dm_atm_security_trading_snapshot-*.yaml"):
        txt = p.read_text(encoding="utf-8")
        for m in re.finditer(r"physical_name:\s*(\w+)\n\s*business_meaning:\s*(.*)\n", txt):
            if re.search(r"từ đầu ngày|cộng dồn|lũy kế|luỹ kế", m.group(2), re.I):
                cols.add(m.group(1))
    return cols or set(_CUMULATIVE_FALLBACK)


def lint_etl_text(etl: str, cum_cols, desc: str = ""):
    """D6/D7 trên 1 chuỗi etl_logic. Trả list (level, code, msg_tail)."""
    out = []
    reviewed = "HNX-KEY-REVIEWED" in (desc or "") or "HNX-KEY-REVIEWED" in etl  # đã rà: ghi lý do + Open Issue trong description
    if _RE_HNX_JOIN.search(etl) and "isin_code" not in etl and not reviewed:
        out.append(("WARNING", "L3-HNX-ISSUE-CODE-JOIN",
                    "nối security_trading_snapshot.symbol = securities_trade.security_symbol_code không có nhánh isin_code — "
                    "HNX lưu ISSUE_CODE (ISIN) ở cột này nên giao dịch HNX bị rơi (A17)"))
    if cum_cols and "trading_time" not in etl:
        m = re.search(r"\b(?:SUM|AVG)\(\s*security_trading_snapshot\.(" + "|".join(sorted(cum_cols)) + r")\b", etl)
        if m:
            out.append(("WARNING", "L3-CUMULATIVE-SNAPSHOT-NOT-DEDUPED",
                        f"SUM/AVG(security_trading_snapshot.{m.group(1)}) — cột cộng dồn từ đầu ngày nhưng không có điều kiện trading_time "
                        f"(lấy bản ghi mới nhất của symbol × trading_dt) → nhân lặp các bản ghi intraday (A18)"))
    return out


def check_lld_etl_patterns(root: Path, module: str):
    out = []
    d = root / "Datamart" / "lld" / module
    if not d.exists():
        r = resolve_module_path(root, module, "attributes")
        d = Path(r) if r else d
    if not d.exists():
        return out
    cum = cumulative_snapshot_cols(root)
    for f in sorted(d.glob("*.csv")):
        try:
            with open(f, encoding="utf-8-sig", newline="") as fh:
                for r in csv.DictReader(fh):
                    for lvl, code, msg in lint_etl_text(r.get("etl_logic") or "", cum, r.get("description") or ""):
                        out.append((lvl, code, f"{f.name} [{r.get('datamart_table')}.{r.get('datamart_column')}] {msg}"))
        except Exception:
            continue
    return out


def _clean_desc_fns():
    """clean()/find_leaks() dùng CHUNG với render_datamart_md.py — 1 định nghĩa 'rò rỉ' cho cả Gate lẫn tài liệu."""
    p = _script_dir.parent.parent / "datamart-gen-docs" / "scripts"
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))
    try:
        from clean_description import clean, find_leaks  # noqa: E402
        return clean, find_leaks
    except Exception:
        return None, None


def check_lld_desc_and_lineage(root: Path, module: str):
    """D8 [L2-DESC-DOC-LEAK] (ERROR): mô tả cột SAU clean_description vẫn còn mã KPI/O_, [SỬA …], ghi chú BA/
           quy trình → sẽ lọt vào tài liệu TKCSLD gửi UBCKNN (đo 2026-10-15: bản clean cũ để lọt 238/2449 dòng).
       D9 [L2-LINEAGE-SLASH-PAIR] (WARNING): số phần tử tách bởi '/' lệch theo CẶP — source_entity↔atomic_table
           hoặc source_attribute↔atomic_column. (So 4 cột cùng lúc là sai: 1 entity thường đi với nhiều attribute.)
    """
    out = []
    clean, find_leaks = _clean_desc_fns()
    d = root / "Datamart" / "lld" / module
    if not d.exists():
        r = resolve_module_path(root, module, "attributes")   # GSĐC → GSDC, NĐTNN → NDTNN
        d = Path(r) if r else d
    if not d.exists():
        return out
    n = lambda v: len([x for x in (v or "").split("/") if x.strip()])  # noqa: E731
    for f in sorted(d.glob("*.csv")):
        try:
            with open(f, encoding="utf-8-sig", newline="") as fh:
                rows = list(csv.DictReader(fh))
        except Exception:
            continue
        for r in rows:
            where = f"{f.name} [{r.get('datamart_table')}.{r.get('datamart_column')}]"
            if clean:
                leaks = find_leaks(clean(r.get("description") or ""))
                if leaks:
                    out.append(("ERROR", "L2-DESC-DOC-LEAK",
                                f"{where} mô tả sau clean còn {leaks} — chuyển ghi chú sang ghi_chu Detail Mapping / HLD"))
            se, at = n(r.get("source_entity")), n(r.get("atomic_table"))
            sa, ac = n(r.get("source_attribute")), n(r.get("atomic_column"))
            if (se and at and se != at) or (sa and ac and sa != ac):
                out.append(("WARNING", "L2-LINEAGE-SLASH-PAIR",
                            f"{where} entity/table {se}/{at}, attribute/column {sa}/{ac} — lineage lệch cặp"))
    return out


def check_flat(root: Path, module: str):
    out = []
    d = root / "Datamart" / "flat-table" / module
    if not d.exists():
        return out
    for f in sorted(d.glob("*.sql")):
        for i, ln in enumerate(f.read_text(encoding="utf-8-sig").splitlines(), 1):
            if ln.lstrip().startswith("--") and re.search(r":etl_date[^\s;)]", ln):
                out.append(("ERROR", "L4-FLAT-COMMENT-PARAM", f"{f.name}:{i} comment chứa ':etl_date' dính ký tự — Gate 4 sẽ báo tham số lạ; viết lại comment"))
    return out


_BASELINE_FILE = _script_dir.parent / "reference" / "fact_row_key_baseline.yaml"


def load_fact_key_baseline():
    """Đọc baseline A22 (yaml phẳng: `MODULE:` rồi `  - table`) → {MODULE: {table}} — không phụ thuộc PyYAML."""
    res, cur = {}, None
    if not _BASELINE_FILE.exists():
        return res
    for ln in _BASELINE_FILE.read_text(encoding="utf-8-sig").splitlines():
        s = ln.strip()
        if not s or s.startswith("#"):
            continue
        if not ln.startswith((" ", "\t")) and s.endswith(":"):
            cur = s[:-1].strip().upper()
            res.setdefault(cur, set())
        elif s.startswith("- ") and cur:
            res[cur].add(s[2:].strip())
    return res


def fact_tables_with_rows(root: Path, module: str):
    """{table: [rows]} của các Fact trong LLD per-table của module (Fact = tên fct_/fact_ hoặc entity bắt đầu 'Fact ')."""
    d = root / "Datamart" / "lld" / module
    res = {}
    if not d.exists():
        return res
    for f in sorted(d.glob("*.csv")):
        try:
            with open(f, encoding="utf-8-sig", newline="") as fh:
                rows = list(csv.DictReader(fh))
        except Exception:
            continue
        if not rows:
            continue
        t = (rows[0].get("datamart_table") or "").strip()
        e = (rows[0].get("datamart_entity") or "").strip()
        if t.startswith(("fct_", "fact_")) or e.startswith("Fact "):
            res[t] = rows
    return res


def check_fact_row_key(root: Path, module: str):
    """D10 [L2-FACT-NO-ROW-KEY] + L2-FACT-PK-INVALID: mỗi Fact khai báo đúng 1 cột key = PK (A22)."""
    out = []
    base = load_fact_key_baseline().get(module.upper(), set())
    owed = []
    for t, rows in fact_tables_with_rows(root, module).items():
        pks = [r for r in rows if (r.get("key") or "").strip() == "PK"]
        if not pks:
            if t in base:
                owed.append(t)
            else:
                out.append(("ERROR", "L2-FACT-NO-ROW-KEY",
                            f"{t}: Fact không khai báo cột key = PK (khóa dòng/khóa MERGE) — luật A22: PK = id dòng Atomic driving "
                            f"(direct) khi grain = 1 dòng nguồn, hoặc surrogate hash toàn bộ cột grain (Generated) khi Fact gộp"))
            continue
        if len(pks) > 1:
            out.append(("ERROR", "L2-FACT-PK-INVALID", f"{t}: có {len(pks)} cột key = PK, Fact chỉ được đúng 1 PK"))
        for r in pks:
            if (r.get("nullable") or "").strip().lower() != "false":
                out.append(("ERROR", "L2-FACT-PK-INVALID", f"{t}.{r.get('datamart_column')}: PK phải nullable = false"))
            col = r.get("datamart_column")
            typ = (r.get("etl_logic_type") or "").strip().lower()
            etl = r.get("etl_logic") or ""
            desc = r.get("description") or ""
            if typ == "direct":
                if not (r.get("atomic_column") or "").strip():
                    out.append(("ERROR", "L2-FACT-PK-INVALID", f"{t}.{col}: PK Dạng A (direct) phải map cột id của entity Atomic driving — atomic_column đang trống"))
            elif typ == "generated":
                if not re.search(r"grain|hash", desc, re.I):
                    out.append(("ERROR", "L2-FACT-PK-INVALID", f"{t}.{col}: PK Dạng B (Generated) phải ghi trong description các cột grain được hash (có chữ 'grain' hoặc 'hash')"))
            elif typ == "computed" and re.search(r"hash", etl, re.I):
                pass  # PK hash viết tường minh trong etl_logic (VD cityHash64(...)) — chấp nhận như Dạng B
            else:
                out.append(("ERROR", "L2-FACT-PK-INVALID", f"{t}.{col}: etl_logic_type của PK Fact phải là direct (Dạng A: id dòng Atomic) hoặc Generated (Dạng B: hash cột grain), đang là '{typ}'"))
        if t in base:
            out.append(("WARNING", "L2-FACT-BASELINE-STALE", f"{t} đã có PK — gỡ khỏi reference/fact_row_key_baseline.yaml"))
    if owed:
        out.append(("INFO", "L2-FACT-NO-ROW-KEY-BASELINE",
                    f"{len(owed)} Fact nợ khóa dòng (baseline A22, chưa có PK): {', '.join(sorted(owed))}"))
    return out


def check_flat_orderby_pk(root: Path, module: str):
    """D11 [L4-FLAT-ORDERBY-MISSING-PK]: flat DDL của Fact có PK phải đưa PK vào ORDER BY."""
    out = []
    d = root / "Datamart" / "flat-table" / module
    if not d.exists():
        return out
    pk_of = {}
    for t, rows in fact_tables_with_rows(root, module).items():
        for r in rows:
            if (r.get("key") or "").strip() == "PK":
                pk_of[t] = (r.get("datamart_column") or "").strip()
                break
    if not pk_of:
        return out
    for f in sorted(d.glob("*.sql")):
        if "populate" in f.name:
            continue
        txt = f.read_text(encoding="utf-8-sig")
        for t, pk in pk_of.items():
            m = re.search(r"CREATE TABLE IF NOT EXISTS datamart\.%s_%s_flat\b(.*?)\n;" % (re.escape(module.lower()), re.escape(t)), txt, re.S)
            if not m:
                continue
            ob = re.search(r"\nORDER BY \((.*)\)\s*\n", m.group(1))
            if not ob or not re.search(r"(?<![A-Za-z0-9_])%s(?![A-Za-z0-9_])" % re.escape(pk), ob.group(1)):
                out.append(("ERROR", "L4-FLAT-ORDERBY-MISSING-PK",
                            f"{f.name}: flat của {t} có ORDER BY ({ob.group(1) if ob else '?'}) không chứa PK `{pk}` — "
                            f"ReplacingMergeTree sẽ gộp các dòng cùng khóa sắp xếp; sửa ORDER BY thành (…, {pk})"))
    return out


_RE_DRIVING = re.compile(r"Driving:\s*([a-z0-9_]+)")
_RE_FK_TARGET = re.compile(r"FK target:\s*([a-z0-9_]+)\.([a-z0-9_]+)")
_ATOMIC_ID_CACHE: dict = {}


def atomic_id_columns(root: Path):
    """{(atomic_table, atomic_column): (entity mà cột đó mang id, là PK của entity?)}: PK của entity (→ chính nó) và FK có comment `FK target: X.col` (→ X).

    Đọc YAML Atomic chính thức bằng regex (cùng cách `cumulative_snapshot_cols`, không cần PyYAML); cache theo root vì chế độ ALL gọi nhiều lần.
    """
    key = str(root)
    if key in _ATOMIC_ID_CACHE:
        return _ATOMIC_ID_CACHE[key]
    res, pk_of = {}, {}
    for p in sorted((root / "DataModel" / "Atomic").rglob("dm_atm_*.yaml")):
        txt = p.read_text(encoding="utf-8")
        head, _, body = txt.partition("\nattributes:")
        m = re.search(r"physical_name:\s*(\w+)", head)
        if not m:
            continue
        ent = m.group(1)
        for blk in re.split(r"\r?\n  - name:", body)[1:]:
            c = re.search(r"physical_name:\s*(\w+)", blk)
            if not c:
                continue
            col = c.group(1)
            if re.search(r"is_primary_key:\s*true", blk):
                res[(ent, col)] = (ent, True)
                pk_of[ent] = col
                continue
            fk = _RE_FK_TARGET.search(re.sub(r"\r?\n\s+", " ", blk))
            if fk:
                res[(ent, col)] = (fk.group(1), False)
    _ATOMIC_ID_CACHE[key] = (res, pk_of)
    return res, pk_of


def check_dim_pk_carried(root: Path, module: str):
    """D12 [L2-DIM-PK-GENERATED-CARRIED]: PK Dim `Generated` mà cột khác của module carry id Atomic của entity driving bằng direct (A23)."""
    out = []
    d = root / "Datamart" / "lld" / module
    if not d.exists():
        return out
    id_cols, pk_of = atomic_id_columns(root)
    dims, carried = {}, {}
    for f in sorted(d.glob("*.csv")):
        try:
            with open(f, encoding="utf-8-sig", newline="") as fh:
                rows = list(csv.DictReader(fh))
        except Exception:
            continue
        if not rows:
            continue
        t = (rows[0].get("datamart_table") or "").strip()
        e = (rows[0].get("datamart_entity") or "").strip()
        if t.endswith("_dim") or e.endswith(" Dimension"):
            pk = next((r for r in rows if (r.get("key") or "").strip() == "PK"), None)
            if pk and ((pk.get("etl_logic_type") or "").strip().lower() == "generated" or (pk.get("source_entity") or "").strip() == "Generated"):
                m = _RE_DRIVING.search(pk.get("description") or "")
                drv = m.group(1) if m else next(((r.get("atomic_table") or "").strip() for r in rows
                                                 if (r.get("key") or "").strip() == "BK" and (r.get("atomic_table") or "").strip()), "")
                if drv:
                    dims[t] = (drv, pk.get("datamart_column"), f.name)
        for r in rows:
            if (r.get("etl_logic_type") or "").strip().lower() != "direct":
                continue
            hit = id_cols.get(((r.get("atomic_table") or "").strip(), (r.get("atomic_column") or "").strip()))
            if hit and (r.get("key") or "").strip() != "PK":
                carried.setdefault(hit[0], []).append((t, r.get("datamart_column"), hit[1]))
    for t, (drv, pkcol, fname) in sorted(dims.items()):
        # cột thuộc tính của CHÍNH Dim đó chép id Atomic của nó (VD securities_company_dim.sc_id) không phải FK trỏ vào PK Dim → bỏ qua;
        # FK tự tham chiếu (VD fund_management_company_dim.parent_fmc_id) vẫn tính vì trỏ sang dòng khác của chính PK Dim.
        cols = [f"{ct}.{cc}" for ct, cc, is_pk in carried.get(drv, []) if not (ct == t and is_pk)]
        if cols:
            out.append(("ERROR", "L2-DIM-PK-GENERATED-CARRIED",
                        f"{fname} [{t}.{pkcol}] PK là Generated nhưng {len(cols)} cột carry id Atomic của `{drv}` bằng direct "
                        f"({', '.join(cols[:4])}{'…' if len(cols) > 4 else ''}) — chỉ nối được vào PK Dim nếu PK = id Atomic; "
                        f"đặt PK direct ← {drv}.{pk_of.get(drv, '<pk>')} (A23)"))
    return out


_DM_LOGIC_BASELINE_FILE = _script_dir.parent / "reference" / "dm_logic_column_baseline.yaml"
_RE_BRACKET_NOTE = re.compile(r"\[[^\]]*\]")
_ref_cache = {}


def load_dm_logic_baseline():
    """Đọc baseline A24 (yaml phẳng: `MODULE:` rồi `  - KPI_ID|bảng.cột` hoặc `  - HLD:KPI_ID|bảng.cột`) → {MODULE: {khóa}}."""
    res, cur = {}, None
    if not _DM_LOGIC_BASELINE_FILE.exists():
        return res
    for ln in _DM_LOGIC_BASELINE_FILE.read_text(encoding="utf-8-sig").splitlines():
        s = ln.strip()
        if not s or s.startswith("#"):
            continue
        if not ln.startswith((" ", "\t")) and s.endswith(":"):
            cur = s[:-1].strip().upper()
            res.setdefault(cur, set())
        elif s.startswith("- ") and cur:
            res[cur].add(s[2:].strip())
    return res


def _ref_index(root: Path):
    key = str(root)
    if key not in _ref_cache:
        from datamart_common import reference_checker as rc
        atomic = rc.build_atomic_index(root)
        mart = rc.load_mart_columns(root)
        mart_tables = {t for t in mart if t and t[0].islower()}
        _ref_cache[key] = (rc, atomic, mart, mart_tables)
    return _ref_cache[key]


def dm_logic_violations(root: Path, module: str):
    """D13 — [(nguồn 'DM'|'HLD', kpi_id, bảng, cột, loại 'mart'|'atomic', gợi ý)] cho mọi `bảng.cột` không tồn tại."""
    rc, atomic, mart, mart_tables = _ref_index(root)
    out = []

    def scan(text, where, kpi):
        seen = set()
        for t, c in rc._RE_QUALIFIED.findall(text):
            if t in rc._SQL_NOISE or (t, c) in seen:
                continue
            seen.add((t, c))
            if t in mart_tables and t in mart:
                kind, pool = "mart", mart[t]
            elif t in atomic:
                kind, pool = "atomic", atomic[t]
            else:
                continue
            if c not in pool:
                out.append((where, kpi, t, c, kind, rc._suggest(c, pool)))

    dm = resolve_module_path(root, module, "detail_mapping")
    if dm and Path(dm).exists():
        with open(dm, encoding="utf-8-sig", newline="") as fh:
            for r in csv.DictReader(fh):
                scan(_RE_BRACKET_NOTE.sub(" ", r.get("logic") or ""), "DM", (r.get("kpi_id") or "").strip())
    hld = resolve_module_path(root, module, "hld")
    if hld and Path(hld).exists():
        for ln in Path(hld).read_text(encoding="utf-8-sig").splitlines():
            if not re.match(r"\| K_[A-Z0-9]+_\d+ \|", ln):
                continue
            s = re.sub(r"`[^`]*`", lambda m: m.group(0).replace("|", "\x00"), ln)
            cs = [c.strip().replace("\x00", "|") for c in s.strip().strip("|").split("|")]
            if len(cs) != 7:
                continue
            for tick in re.findall(r"`([^`]*)`", cs[4]):
                scan(tick, "HLD", cs[0])
    return out


def dm_logic_keys(root: Path, module: str):
    keys = {}
    for where, kpi, t, c, kind, near in dm_logic_violations(root, module):
        keys.setdefault(("HLD:" if where == "HLD" else "") + f"{kpi}|{t}.{c}", (where, kpi, t, c, kind, near))
    return keys


def check_logic_column_refs(root: Path, module: str):
    """D13 [L0-DM-LOGIC-COLUMN-NOT-FOUND] — luật A24: cột viết trong `logic` Detail Mapping / công thức HLD phải tồn tại thật."""
    out = []
    base = load_dm_logic_baseline().get(module.upper(), set())
    found = dm_logic_keys(root, module)
    owed = 0
    for key, (where, kpi, t, c, kind, near) in sorted(found.items()):
        if key in base:
            owed += 1
            continue
        src = "công thức bảng KPI HLD" if where == "HLD" else "cột logic Detail Mapping"
        where_txt = "Attributes CSV của bảng Datamart" if kind == "mart" else "YAML Atomic"
        out.append(("ERROR", "L0-DM-LOGIC-COLUMN-NOT-FOUND",
                    f"{kpi}: {src} tham chiếu `{t}.{c}` — cột này KHÔNG có trong {where_txt}."
                    + (f" Gợi ý gần nhất: `{near}`." if near else "")
                    + " Luật A24: grep cột trước khi viết (Attributes CSV / YAML Atomic); cột đã đổi tên/bị xóa thì sửa cả HLD và Detail Mapping."))
    stale = sorted(base - set(found))
    if stale:
        out.append(("WARNING", "L0-DM-LOGIC-BASELINE-STALE",
                    f"{len(stale)} mục baseline A24 không còn vi phạm — gỡ khỏi reference/dm_logic_column_baseline.yaml: {', '.join(stale[:5])}"
                    + (" …" if len(stale) > 5 else "")))
    if owed:
        out.append(("INFO", "L0-DM-LOGIC-COLUMN-BASELINE",
                    f"{owed} tham chiếu cột lệch nợ từ trước (baseline A24) — sửa dần, gỡ khỏi baseline khi xong"))
    return out


def run(root: Path, module: str, force_l18: bool = False):
    issues = []
    hld = resolve_module_path(root, module, "hld")
    if hld and Path(hld).exists():
        issues += check_hld(Path(hld))
    issues += check_usage(root, module)
    issues += check_derived_inline(root, module)
    issues += check_one_row_per_kpi(root, module, force_l18)
    issues += check_flat(root, module)
    issues += check_lld_etl_patterns(root, module)
    issues += check_lld_desc_and_lineage(root, module)
    issues += check_fact_row_key(root, module)
    issues += check_flat_orderby_pk(root, module)
    issues += check_dim_pk_carried(root, module)
    issues += check_logic_column_refs(root, module)
    return issues


def main():
    ap = argparse.ArgumentParser(description="Gate 8 — Design Lint")
    ap.add_argument("-m", "--module", required=True)
    ap.add_argument("--strict", action="store_true")
    ap.add_argument("--root", default=None)
    ap.add_argument("--l18", action="store_true",
                    help="Ép kiểm Quy tắc L18 (D5) cả module chưa thuộc L18_MODULES — chỉ WARNING, để đo mức nhân dòng")
    ap.add_argument("--print-dm-logic-baseline", action="store_true",
                    help="In yaml baseline A24 (mọi vi phạm hiện tại của --module) rồi thoát — chỉ dùng khi human duyệt nợ có từ trước")
    a = ap.parse_args()
    root = Path(a.root) if a.root else find_project_root()
    mods = get_available_modules(root) if a.module.upper() == "ALL" else [a.module]
    if a.print_dm_logic_baseline:
        for m in mods:
            ks = sorted(dm_logic_keys(root, m))
            if ks:
                print(f"{m.upper()}:")
                for k in ks:
                    print(f"  - {k}")
        sys.exit(0)
    err = warn = 0
    for m in mods:
        iss = run(root, m, a.l18)
        e = sum(1 for x in iss if x[0] == "ERROR"); n_info = sum(1 for x in iss if x[0] == "INFO"); w = len(iss) - e - n_info
        err += e; warn += w
        print(f"== Design Lint {m}: {e} ERROR, {w} WARNING" + (f", {n_info} INFO" if n_info else ""))
        for lvl, code, msg in iss:
            print(f"  [{'X' if lvl == 'ERROR' else 'i' if lvl == 'INFO' else '!'}] [{code}] {msg}")
    ok = err == 0 and (warn == 0 or not a.strict)
    print("PASS" if ok else "FAIL")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
