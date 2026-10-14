#!/usr/bin/env python3
"""Tự kiểm A19 — giới hạn ngày cho bảng Atomic snapshot/event trong etl_logic Datamart.

Quét `Datamart/lld/{MODULE}/*.csv` (file per-table, cột `etl_logic`), bắt 4 lỗi:

  [R1] File tham chiếu bảng snapshot/event nhưng KHÔNG cell nào chứa điều kiện ngày
       `<bảng>.<cột> (=|BETWEEN|>=|<=) ... :etl_date` (dòng lookup_date chỉ lọc src_stm_code).
  [R3] Subquery/CTE `(SELECT ... FROM <snapshot/event> ...)` không có :etl_date/BETWEEN BÊN TRONG.
  [R4] "Bản ghi mới nhất" trên toàn lịch sử: MAX(<cột ngày>) hoặc ROW_NUMBER ... ORDER BY <cột ngày> DESC
       mà cell không có :etl_date/BETWEEN.
  [R6] LAG/LEAD sắp xếp theo cột ngày (liên ngày) trong file mà bảng chỉ bị khóa `= :etl_date`
       (không có BETWEEN) → LAG luôn NULL.

Heuristic tĩnh, không thay thế review: có thể báo thừa (VD cell đã bị chặn gián tiếp qua JOIN ngày) hoặc
sót (điều kiện ngày viết bằng alias). Marker ngoại lệ có truy vết trong cell/description:
`[DATE-BOUND-REVIEWED <ngày>: <lý do>; O_xxx]`.

Cách chạy (từ thư mục gốc repo):
  python .claude/skills/datamart-review/scripts/check_date_bound.py --module GSTT
  python .claude/skills/datamart-review/scripts/check_date_bound.py --module ALL --summary
  python ... --module GSTT --strict        # exit 1 nếu có phát hiện
  python ... --module GSTT --file fct_hose_securities_trade   # chỉ 1 file vừa sinh (TC12 của datamart-lld-design)

Quy tắc gốc: A19 trong `.claude/skills/datamart-lld-design/SKILL.md`. Chưa nằm trong run_quality_gates.py.
"""
import argparse
import csv
import glob
import os
import re
import sys

try:
    import yaml
except ImportError:  # pragma: no cover
    yaml = None

csv.field_size_limit(10**9)
sys.stdout.reconfigure(encoding='utf-8')

DATE_COLS = r'(?:trading_dt|trade_dt|order_dt|ds_snpst_dt)'
MARKER = 'DATE-BOUND-REVIEWED'
# Bảng snapshot/event/History không (hoặc không còn) nằm trong dm_manifest.yaml — bổ sung tay khi gặp.
#  - listed_share_info: VSDC ODS, chỉ có mapping md, có ds_snpst_dt.
#  - securities_trade / securities_order: ORDERTRADE (Fact Append); manifest 2026-10-14 không còn entry
#    ORDERTRADE (Atomic Team gỡ file YAML) nhưng Datamart GSTT/NDTNN/PTTT vẫn đọc → phải vẫn được quét.
EXTRA_TABLES = {'listed_share_info', 'securities_trade', 'securities_order'}


def repo_root():
    here = os.path.abspath(os.path.dirname(__file__))
    for _ in range(6):
        if os.path.isdir(os.path.join(here, 'Datamart')) and os.path.isdir(os.path.join(here, 'DataModel')):
            return here
        here = os.path.dirname(here)
    return os.getcwd()


def load_tables(root):
    path = os.path.join(root, 'DataModel', 'Atomic', 'dm_manifest.yaml')
    names = set(EXTRA_TABLES)
    if yaml and os.path.exists(path):
        man = yaml.safe_load(open(path, encoding='utf-8'))
        for e in man.get('entries', []):
            if e.get('table_type') in ('Fact Snapshot', 'Fact Append'):
                names.add(e['physical_name'])
    return names


def bounded(text, t=None):
    """Có điều kiện ngày trực tiếp (bảng t nếu chỉ định, nếu không thì bất kỳ)."""
    pre = rf'\b{t}\.' if t else r'\b\w+\.'
    pats = [
        rf'{pre}{DATE_COLS}\s*(=|<=|>=|<|>)\s*[^\s,)]*:etl_date',
        rf'{pre}{DATE_COLS}\s+BETWEEN\b',
        rf':etl_date\s*(=|>=|<=)\s*{pre}{DATE_COLS}',
    ]
    return any(re.search(p, text, re.I) for p in pats) or bool(re.search(r':etl_date', text) and re.search(r'BETWEEN', text, re.I))


def subqueries(text):
    out, i = [], 0
    while True:
        j = text.upper().find('(SELECT', i)
        if j < 0:
            return out
        depth, k = 0, j
        while k < len(text):
            depth += (text[k] == '(') - (text[k] == ')')
            if depth == 0:
                break
            k += 1
        out.append(text[j + 1:k])
        i = k + 1


def scan_module(root, module, tables, only=None):
    findings = []
    for path in sorted(glob.glob(os.path.join(root, 'Datamart', 'lld', module, '*.csv'))):
        if only and only not in os.path.basename(path):
            continue
        rows = list(csv.DictReader(open(path, encoding='utf-8-sig')))
        if not rows or 'etl_logic' not in rows[0]:
            continue
        fname = os.path.basename(path)
        refs_in_file = set()
        bound_tables = set()   # bảng bị khóa ngày TRỰC TIẾP ở ít nhất 1 cell của file
        file_has_bound = False
        file_has_between = False
        for r in rows:
            L = r['etl_logic'] or ''
            for t in tables:
                if re.search(rf'\b{t}\b', L):
                    refs_in_file.add(t)
                    if bounded(L, t):
                        file_has_bound = True
                        bound_tables.add(t)
            if re.search(r'BETWEEN', L, re.I) and ':etl_date' in L:
                file_has_between = True
        if not refs_in_file:
            continue
        marker_file = any(MARKER in (r.get('description') or '') for r in rows)
        if not file_has_bound and not marker_file:
            findings.append(('R1', fname, '*', f'không cell nào khóa ngày cho {sorted(refs_in_file)}'))
        for r in rows:
            col = r['datamart_column']
            L = r['etl_logic'] or ''
            if MARKER in L or MARKER in (r.get('description') or ''):
                continue
            for s in subqueries(L):
                for t in tables:
                    if re.search(rf'\b(FROM|JOIN)\s+{t}\b', s, re.I) and not bounded(s):
                        findings.append(('R3', fname, col, f'subquery trên {t} không có điều kiện ngày bên trong'))
                        break
            outer = L
            for s in subqueries(L):
                outer = outer.replace(s, ' ')
            touched = [t for t in tables if re.search(rf'\b{t}\b', outer)]
            if touched and not bounded(outer):
                latest = (re.search(rf'MAX\(\s*[\w.]*{DATE_COLS}\s*\)', outer, re.I)
                          or re.search(rf'order by\s+[^)]*?\b[\w.]*{DATE_COLS}\s+desc', outer, re.I))
                if latest:
                    findings.append(('R4', fname, col, f'lấy bản ghi mới nhất trên toàn lịch sử của {touched}'))
            if touched and re.search(r'\b(LAG|LEAD)\s*\(', outer, re.I) and not file_has_between:
                # chỉ bắt khi LAG/LEAD sắp xếp theo cột ngày của CHÍNH bảng đã bị khóa = :etl_date
                m = re.search(rf'order by\s+[^)]*?\b(\w+)\.{DATE_COLS}\b', outer, re.I)
                if m and m.group(1) in bound_tables:
                    findings.append(('R6', fname, col,
                                     f'LAG/LEAD liên ngày theo {m.group(1)} nhưng bảng này chỉ khóa = :etl_date (luôn NULL)'))
    return findings


def main():
    ap = argparse.ArgumentParser(description='A19 — kiểm giới hạn ngày bảng snapshot/event')
    ap.add_argument('-m', '--module', required=True, help='Tên module hoặc ALL')
    ap.add_argument('--strict', action='store_true', help='exit 1 nếu có phát hiện')
    ap.add_argument('--summary', action='store_true', help='chỉ in tổng hợp theo file')
    ap.add_argument('--file', default=None, help='chỉ quét file có tên chứa chuỗi này (VD fct_hose_securities_trade)')
    args = ap.parse_args()

    root = repo_root()
    tables = load_tables(root)
    if args.module.upper() == 'ALL':
        modules = sorted(d for d in os.listdir(os.path.join(root, 'Datamart', 'lld'))
                         if os.path.isdir(os.path.join(root, 'Datamart', 'lld', d)))
    else:
        modules = [args.module]

    total = 0
    for m in modules:
        fs = scan_module(root, m, tables, args.file)
        total += len(fs)
        files = {}
        for code, f, col, msg in fs:
            files.setdefault(f, []).append((code, col, msg))
        print(f'== A19 date-bound {m}: {len(fs)} phát hiện / {len(files)} file ' + ('✅' if not fs else '❌'))
        for f, items in files.items():
            by = {}
            for code, col, msg in items:
                by.setdefault(code, []).append(col)
            print(f'   {f}: ' + ', '.join(f'{c}×{len(v)}' for c, v in sorted(by.items())))
            if not args.summary:
                seen = set()
                for code, col, msg in items:
                    key = (code, msg)
                    if key in seen:
                        continue
                    seen.add(key)
                    cols = [c for cd, c, mm in items if (cd, mm) == key]
                    print(f'     [{code}] {msg} — cột: {", ".join(cols[:6])}{" …" if len(cols) > 6 else ""}')
    print(f'TỔNG: {total} phát hiện')
    sys.exit(1 if (args.strict and total) else 0)


if __name__ == '__main__':
    main()
