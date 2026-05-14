"""
gen_code_atomic — Convert atomic mapping CSV → formatted SQL (dbt ref syntax).

Usage (from repo root):
    python Code/scripts/gen_code_atomic.py Mapping/atomic/FMS/fund_management_company_fms_securities.csv
    python Code/scripts/gen_code_atomic.py --source-system FMS
    python Code/scripts/gen_code_atomic.py --entity "Fund Management Company"
    python Code/scripts/gen_code_atomic.py --all
    python Code/scripts/gen_code_atomic.py --stdout <file>

Reads from:
    Mapping/atomic/<SS>/<entity>.csv

Writes to:
    Code/atomic/<SS>/<entity>.sql

Rules:
- FROM uses dbt ref(): {{ ref('<ods_table>') }}
- etl_date pattern (in filter or transform) → to_date('{{ var("etl_date") }}','yyyy-MM-dd'), no CAST
- hash_id(...) → kept as-is, no CAST
- Other expressions with Data Type → CAST(expr AS dtype)
- Empty transformation → CAST(NULL AS dtype) or NULL
- CTE patterns: physical_table standalone | derived_cte pair | unpivot_cte pair
- Shared entity detected by unpivot_cte rows; UNION ALL across legs
"""
import csv, os, sys, argparse, glob, re

REPO_ROOT   = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MAPPING_DIR = os.path.join(REPO_ROOT, 'Mapping', 'atomic')
CODE_DIR    = os.path.join(REPO_ROOT, 'Code', 'atomic')

_ETL_DATE_MAPPING = "to_date(\"etl_date\", 'yyyy-MM-dd')"
_ETL_DATE_SQL     = "to_date('{{ var(\"etl_date\") }}','yyyy-MM-dd')"


# ── Parse mapping CSV ─────────────────────────────────────────────────────────

SECTION_BANNERS = {'Target', 'Input', 'Relationship', 'Mapping', 'Final Filter'}

def parse_mapping_csv(path):
    with open(path, 'r', encoding='utf-8-sig') as f:
        rows = list(csv.reader(f))

    sections = {'target': [], 'input': [], 'relationship': [], 'mapping': [], 'filter': []}
    section_key = {
        'Target': 'target', 'Input': 'input', 'Relationship': 'relationship',
        'Mapping': 'mapping', 'Final Filter': 'filter',
    }
    current, pending_header = None, False

    for row in rows:
        if not row or not any(c.strip() for c in row):
            continue
        c0 = row[0].strip()
        if c0 in SECTION_BANNERS:
            current = section_key[c0]
            pending_header = True
            continue
        if pending_header:
            pending_header = False
            continue
        if current:
            sections[current].append(row)
    return sections


# ── Helpers ───────────────────────────────────────────────────────────────────

def get(row, idx, default=''):
    return row[idx].strip() if idx < len(row) else default


def _sub_etl(expr):
    """Replace etl_date mapping pattern with dbt var syntax."""
    return expr.replace(_ETL_DATE_MAPPING, _ETL_DATE_SQL)


def format_where(expr, indent='    '):
    """Apply etl_date substitution then split at AND/OR onto separate lines."""
    expr = _sub_etl(expr)
    parts = re.split(r'\s+(AND|OR)\s+', expr, flags=re.IGNORECASE)
    if len(parts) == 1:
        return expr
    cont = indent + '    '
    result = parts[0].strip()
    for i in range(1, len(parts), 2):
        result += f"\n{cont}{parts[i].upper()} {parts[i+1].strip()}"
    return result


def _render_expr(transf, dtype):
    """Build rendered expression for SELECT column.

    - etl_date pattern    → dbt var, no CAST
    - hash_id(...)        → generate_surrogate_key_bigint macro, no CAST
    - current_timestamp() → as-is, no CAST
    - empty transf        → CAST(NULL AS dtype) or NULL
    - others              → CAST(expr AS dtype) or expr
    """
    expr = transf if transf else 'NULL'
    if _ETL_DATE_MAPPING in expr:
        return _sub_etl(expr)
    if expr.lower() == 'current_timestamp()':
        return expr
    if expr.lower().startswith('hash_id('):
        inner = expr[8:-1]  # strip 'hash_id(' and final ')'
        return f"{{{{ generate_surrogate_key_bigint({inner}) }}}}"
    if dtype:
        return f"CAST({expr} AS {dtype})"
    return expr


# ── CTE builders ──────────────────────────────────────────────────────────────

def _make_from(table):
    """Always use dbt ref()."""
    return f"{{{{ ref('{table}') }}}}"


def build_physical_cte(row):
    table = get(row, 3)
    alias = get(row, 4)
    sel   = get(row, 5) or '*'
    filt  = get(row, 6)

    cte = f"{alias} AS (\n    SELECT {sel}\n    FROM {_make_from(table)}"
    if filt:
        cte += f"\n    WHERE {format_where(filt)}"
    cte += "\n)"
    return cte


def build_merged_derived_cte(phys_row, derv_row):
    """Merge physical_table + derived_cte into 1 pre-aggregate CTE."""
    p_table  = get(phys_row, 3)
    p_filter = get(phys_row, 6)
    d_alias  = get(derv_row, 4)
    d_sel    = get(derv_row, 5)
    d_filter = get(derv_row, 6)

    group_by, where_extra = '', ''
    if d_filter.upper().startswith('GROUP BY'):
        group_by = d_filter
    elif d_filter:
        where_extra = d_filter

    cte = f"{d_alias} AS (\n    SELECT {d_sel}\n    FROM {_make_from(p_table)}"
    wheres = [w for w in (p_filter, where_extra) if w]
    if wheres:
        cte += f"\n    WHERE {format_where(' AND '.join(wheres))}"
    if group_by:
        cte += f"\n    {group_by}"
    cte += "\n)"
    return cte


def smart_split_args(s):
    """Split by top-level commas (ignore commas inside quotes/parens)."""
    result, current, depth, in_quote = [], '', 0, False
    for ch in s:
        if ch == "'":
            in_quote = not in_quote; current += ch
        elif not in_quote and ch == '(':
            depth += 1; current += ch
        elif not in_quote and ch == ')':
            depth -= 1; current += ch
        elif not in_quote and depth == 0 and ch == ',':
            result.append(current.strip()); current = ''
        else:
            current += ch
    if current.strip():
        result.append(current.strip())
    return result


def format_lateral_view(lateral_view, indent='    '):
    """Reformat LATERAL VIEW stack(N, ...) to multi-line, 1 leg per line."""
    m = re.match(r'(LATERAL\s+VIEW\s+stack\s*\(\s*)(\d+)\s*,\s*(.*?)\)\s*(.*)$',
                 lateral_view, re.IGNORECASE | re.DOTALL)
    if not m:
        return f"{indent}{lateral_view}"
    _, n_str, args_str, suffix = m.groups()
    n    = int(n_str)
    args = smart_split_args(args_str)
    if n <= 0 or len(args) % n != 0:
        return f"{indent}{lateral_view}"
    vpl  = len(args) // n
    legs = [args[i * vpl:(i + 1) * vpl] for i in range(n)]
    leg_indent = indent + '    '
    lines = [f"{indent}LATERAL VIEW stack({n},"]
    for i, leg in enumerate(legs):
        suffix_comma = ',' if i < len(legs) - 1 else ''
        lines.append(f"{leg_indent}{', '.join(leg)}{suffix_comma}")
    lines.append(f"{indent}) {suffix.strip()}".rstrip())
    return '\n'.join(lines)


def build_unpivot_cte(phys_row, unpv_row):
    """physical_table + unpivot_cte → CTE with LATERAL VIEW stack()."""
    p_table  = get(phys_row, 3)
    p_filter = get(phys_row, 6)
    u_alias  = get(unpv_row, 4)
    u_sel    = get(unpv_row, 5)
    u_filter = get(unpv_row, 6)

    lines        = [l.strip() for l in u_sel.split('\n') if l.strip()]
    select_part  = lines[0] if lines else ''
    lateral_view = ' '.join(lines[1:]) if len(lines) > 1 else ''

    cte = f"{u_alias} AS (\n    SELECT {select_part}\n    FROM {_make_from(p_table)}"
    if lateral_view:
        cte += f"\n{format_lateral_view(lateral_view)}"
    wheres = [w for w in (p_filter, u_filter) if w]
    if wheres:
        cte += f"\n    WHERE {format_where(' AND '.join(wheres))}"
    cte += "\n)"
    return cte


def build_ctes(input_rows):
    """Group input rows → CTEs (pair detection: row[i+1].src == row[i].alias)."""
    ctes, i = [], 0
    while i < len(input_rows):
        row = input_rows[i]
        if get(row, 1) != 'physical_table':
            i += 1; continue
        alias = get(row, 4)
        if i + 1 < len(input_rows):
            nxt   = input_rows[i + 1]
            ntype = get(nxt, 1)
            nsrc  = get(nxt, 3)
            if nsrc == alias:
                if ntype == 'derived_cte':
                    ctes.append(build_merged_derived_cte(row, nxt)); i += 2; continue
                if ntype == 'unpivot_cte':
                    ctes.append(build_unpivot_cte(row, nxt));        i += 2; continue
        ctes.append(build_physical_cte(row))
        i += 1
    return ctes


# ── Main SELECT ───────────────────────────────────────────────────────────────

def build_select_columns(mapping_rows, leg_idx=None):
    """Return list of formatted 'expr  AS target' strings.

    leg_idx: for shared entity — pick the leg_idx-th part of ';'-separated transformations.
    """
    items = []
    for r in mapping_rows:
        tgt   = get(r, 1)
        transf = get(r, 2)
        dtype  = get(r, 3)
        if not tgt:
            continue
        if leg_idx is not None and ';' in transf:
            parts  = [p.strip() for p in transf.split(';')]
            transf = parts[leg_idx] if leg_idx < len(parts) else parts[-1]
        items.append((_render_expr(transf, dtype), tgt))

    if not items:
        return []
    max_e = min(max(len(e) for e, _ in items), 72)
    return [f"{expr}{' ' * max(1, max_e - len(expr) + 1)}AS {tgt}" for expr, tgt in items]


def format_select_cols(cols, indent='    '):
    lines = []
    for i, col in enumerate(cols):
        suffix = ',' if i < len(cols) - 1 else ''
        lines.append(f"{indent}{col}{suffix}")
    return '\n'.join(lines)


def extract_leg_aliases_from_union(union_expr):
    return [m.group(1) for m in re.finditer(r'SELECT\s+\*\s+FROM\s+(\w+)', union_expr, re.IGNORECASE)]


def build_final_select(sections):
    mapping_rows = sections['mapping']
    rel_rows     = sections['relationship']
    filter_rows  = sections['filter']
    input_rows   = sections['input']

    where, group_by, having, order_by, union_expr = [], '', '', '', ''
    for r in filter_rows:
        ctype, expr = get(r, 1), get(r, 2)
        if not expr: continue
        up = ctype.upper()
        if   up == 'WHERE':    where.append(expr)
        elif up == 'GROUP BY': group_by   = expr
        elif up == 'HAVING':   having     = expr
        elif up == 'ORDER BY': order_by   = expr
        elif up == 'UNION ALL': union_expr = expr

    primary = next((get(r, 1) for r in rel_rows if get(r, 1)), None)
    if not primary:
        primary = next((get(r, 4) for r in input_rows if get(r, 1) == 'physical_table'), None)

    joins = [
        f"    {get(r,2)} {get(r,3)} ON {get(r,4)}"
        for r in rel_rows if get(r,2) and get(r,3) and get(r,4)
    ]

    # Shared entity detection — triggered by unpivot_cte rows OR UNION ALL in Final Filter
    unpivot_aliases = [get(r, 4) for r in input_rows if get(r, 1) == 'unpivot_cte']
    if unpivot_aliases or union_expr:
        leg_aliases = extract_leg_aliases_from_union(union_expr) if union_expr else unpivot_aliases
        parts = []
        for idx, leg in enumerate(leg_aliases):
            cols = build_select_columns(mapping_rows, leg_idx=idx)
            parts.append("SELECT\n" + format_select_cols(cols) + f"\nFROM {leg}")
        return "\nUNION ALL\n".join(parts)

    # Regular case
    cols = build_select_columns(mapping_rows)
    sql  = "SELECT\n" + format_select_cols(cols)
    if primary:
        sql += f"\nFROM {primary}"
    if joins:
        sql += "\n" + "\n".join(joins)
    if where:
        sql += f"\nWHERE {format_where(' AND '.join(where), indent='')}"
    if group_by:
        sql += f"\nGROUP BY {group_by}"
    if having:
        sql += f"\nHAVING {having}"
    if order_by:
        sql += f"\nORDER BY {order_by}"
    return sql


# ── Program header ────────────────────────────────────────────────────────────

def build_program_header(mapping_csv_path):
    file_base    = os.path.splitext(os.path.basename(mapping_csv_path))[0]
    program_name = ' '.join((w[0].upper() + w[1:]) if w else w for w in file_base.split('_'))
    divider      = '*' + '-' * 68 + '*'
    return (
        "/*\n"
        f"{divider}\n"
        f"* Program code: {file_base}\n"
        f"* Program name: {program_name}\n"
        f"* Created by: \n"
        f"* Created date: \n"
        f"{divider}\n"
        f"* Modified management\n"
        f"* Date\t\t\t\tUser\t\t\t\tDescription\n"
        f"* \n"
        f"{divider}\n"
        "*/\n"
    )


# ── Assemble ──────────────────────────────────────────────────────────────────

def generate_sql(mapping_csv_path):
    sections = parse_mapping_csv(mapping_csv_path)
    ctes     = build_ctes(sections['input'])
    main     = build_final_select(sections)

    sql = build_program_header(mapping_csv_path)
    if ctes:
        sql += "\nWITH " + ",\n\n".join(ctes) + "\n\n"
    sql += main + "\n;\n"
    return sql


# ── CLI ───────────────────────────────────────────────────────────────────────

def resolve_inputs(args):
    if args.file:
        return [os.path.abspath(args.file)]
    pattern = os.path.join(MAPPING_DIR, '*', '*.csv')
    files   = glob.glob(pattern)
    if args.source_system:
        files = [f for f in files
                 if os.sep + args.source_system + os.sep in f or f'/{args.source_system}/' in f]
    if args.entity:
        snakes = [re.sub(r'\s+', '_', e.lower()) for e in args.entity]
        files = [f for f in files if any(os.path.basename(f).startswith(s) for s in snakes)]
    if args.table:
        tbls = [t.lower() for t in args.table]
        files = [f for f in files if any(t in os.path.basename(f) for t in tbls)]
    return files


def main():
    parser = argparse.ArgumentParser(description='Generate atomic SQL from mapping CSV.')
    parser.add_argument('file',            nargs='?', default=None, help='Single mapping CSV path')
    parser.add_argument('--source-system', default=None,            help='Filter by source system (e.g. FMS)')
    parser.add_argument('--entity',        default=None, nargs='+', help='Filter by entity name (one or more, e.g. "Fund Management Company")')
    parser.add_argument('--table',         default=None, nargs='+', help='Filter by table keyword in filename (one or more)')
    parser.add_argument('--all',           action='store_true',     help='Process all atomic mapping files')
    parser.add_argument('--stdout',        action='store_true',     help='Print SQL to stdout instead of writing file')
    args = parser.parse_args()

    if not args.file and not args.all and not args.source_system and not args.entity and not args.table:
        parser.error('Provide a file path, --source-system, --entity, --table, or --all')

    files = resolve_inputs(args)
    if not files:
        print('No mapping files matched.', file=sys.stderr)
        sys.exit(1)

    generated = []
    for f in files:
        sql = generate_sql(f)
        if args.stdout:
            print(sql)
            continue
        ss_name  = os.path.basename(os.path.dirname(f))
        out_dir  = os.path.join(CODE_DIR, ss_name)
        os.makedirs(out_dir, exist_ok=True)
        base     = os.path.splitext(os.path.basename(f))[0]
        out_path = os.path.join(out_dir, f'{base}.sql')
        with open(out_path, 'w', encoding='utf-8') as g:
            g.write(sql)
        generated.append(out_path)

    if not args.stdout:
        print(f'[gen_code_atomic] Done. {len(generated)} file(s) generated:')
        for p in generated:
            print(f'  {os.path.relpath(p, REPO_ROOT)}')


if __name__ == '__main__':
    main()
