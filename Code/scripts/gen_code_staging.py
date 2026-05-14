"""
gen_code_staging — Convert staging mapping CSV → formatted SQL (dbt source syntax).

Usage (from repo root):
    python Code/scripts/gen_code_staging.py Mapping/staging/FMS/stg_fms_securities.csv
    python Code/scripts/gen_code_staging.py --source-system FMS
    python Code/scripts/gen_code_staging.py --table stg_fms_securities
    python Code/scripts/gen_code_staging.py --all
    python Code/scripts/gen_code_staging.py --stdout Mapping/staging/FMS/stg_fms_securities.csv

Reads from:
    Mapping/staging/<SS>/stg_<ss>_<table>.csv

Writes to:
    Code/staging/<SS>/stg_<ss>_<table>.sql

Rules:
- FROM uses dbt source(): {{ source('source_<ss_lower>', 'raw_<table_lower>') }}
  e.g. FMS → {{ source('source_fms', 'raw_securities') }}
- Physical Target Column → lowercase (target alias)
- CAST applied only when Data Type column is non-empty: <transf> :: <dtype>
- No WHERE rendered when filter is empty
"""
import csv, os, sys, argparse, glob, re

REPO_ROOT   = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MAPPING_DIR = os.path.join(REPO_ROOT, 'Mapping', 'staging')
CODE_DIR    = os.path.join(REPO_ROOT, 'Code', 'staging')


# ── Parse mapping CSV ─────────────────────────────────────────────────────────

SECTION_BANNERS = {'Target', 'Input', 'Relationship', 'Mapping', 'Final Filter'}

def parse_mapping_csv(path):
    """Return dict section → list of data rows (banner + header rows skipped)."""
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


def format_where(expr, indent='    '):
    """Split WHERE expression at top-level AND/OR onto separate lines."""
    parts = re.split(r'\s+(AND|OR)\s+', expr, flags=re.IGNORECASE)
    if len(parts) == 1:
        return expr
    cont = indent + '    '
    result = parts[0].strip()
    for i in range(1, len(parts), 2):
        result += f"\n{cont}{parts[i].upper()} {parts[i+1].strip()}"
    return result


# ── CTE builder ───────────────────────────────────────────────────────────────

def build_cte(row, dbt_src_var):
    """Build one CTE block for a physical_table input row."""
    table_name = get(row, 3)
    alias      = get(row, 4)
    sel        = get(row, 5) or '*'
    filt       = get(row, 6)

    dbt_ref = f"{{{{ source('{dbt_src_var}', 'raw_{table_name.lower()}') }}}}"
    cte = f"{alias} AS (\n    SELECT {sel}\n    FROM {dbt_ref}"
    if filt:
        cte += f"\n    WHERE {format_where(filt)}"
    cte += "\n)"
    return cte


def build_ctes(input_rows, dbt_src_var):
    return [build_cte(r, dbt_src_var) for r in input_rows if get(r, 1) == 'physical_table']


# ── etl_date conversion ───────────────────────────────────────────────────────

_ETL_DATE_MAPPING = "to_date(\"etl_date\", 'yyyy-MM-dd')"
_ETL_DATE_SQL     = "to_date('{{ var(\"etl_date\") }}','yyyy-MM-dd')"

def _render_expr(transf, dtype):
    """Build rendered expression: etl_date → dbt var (no CAST), current_timestamp() → as-is (no CAST), else CAST if dtype set."""
    expr = transf if transf else 'NULL'
    if _ETL_DATE_MAPPING in expr:
        return expr.replace(_ETL_DATE_MAPPING, _ETL_DATE_SQL)
    if expr.lower() == 'current_timestamp()':
        return expr
    return f"CAST({expr} AS {dtype})" if dtype else expr


# ── Main SELECT ───────────────────────────────────────────────────────────────

def build_select_columns(mapping_rows):
    """Return list of formatted 'expr  AS target' strings.

    - Physical Target Column as-is (already lowercase)
    - etl_date mapping pattern → dbt var syntax, no CAST
    - CAST applied only when Data Type is non-empty: CAST(expr AS dtype)
    - Empty transformation → NULL
    """
    items = []
    for r in mapping_rows:
        tgt    = get(r, 1)
        transf = get(r, 2)
        dtype  = get(r, 3)
        if not tgt:
            continue
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


def build_final_select(sections):
    mapping_rows = sections['mapping']
    rel_rows     = sections['relationship']
    filter_rows  = sections['filter']

    # WHERE clauses
    where = [get(r, 2) for r in filter_rows if get(r, 1).upper() == 'WHERE' and get(r, 2)]

    # Primary alias from Relationship → fallback to first physical_table alias
    primary = next((get(r, 1) for r in rel_rows if get(r, 1)), None)
    if not primary:
        primary = next((get(r, 4) for r in sections['input'] if get(r, 1) == 'physical_table'), None)

    # Joins
    joins = [
        f"    {get(r,2)} {get(r,3)} ON {get(r,4)}"
        for r in rel_rows if get(r,2) and get(r,3) and get(r,4)
    ]

    cols = build_select_columns(mapping_rows)
    sql  = "SELECT\n" + format_select_cols(cols)
    if primary:
        sql += f"\nFROM {primary}"
    if joins:
        sql += "\n" + "\n".join(joins)
    if where:
        sql += f"\nWHERE {format_where(' AND '.join(where), indent='')}"
    return sql


# ── Program header ────────────────────────────────────────────────────────────

def build_program_header(mapping_csv_path):
    file_base = os.path.splitext(os.path.basename(mapping_csv_path))[0]
    # stg_<ss>_<table> → "Staging SS TABLE"
    parts = file_base.split('_')                 # ['stg', 'fms', 'securities', ...]
    ss    = parts[1].upper() if len(parts) > 1 else ''
    table = '_'.join(parts[2:]).upper() if len(parts) > 2 else ''
    program_name = f"Staging {ss} {table}".strip()
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
    ss          = os.path.basename(os.path.dirname(mapping_csv_path))
    dbt_src_var = f'source_{ss.lower()}'

    sections = parse_mapping_csv(mapping_csv_path)
    ctes     = build_ctes(sections['input'], dbt_src_var)
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
    if args.table:
        tbls = [t.lower() for t in args.table]
        files = [f for f in files if any(os.path.basename(f).startswith(t) for t in tbls)]
    return files


def main():
    parser = argparse.ArgumentParser(description='Generate staging SQL from mapping CSV.')
    parser.add_argument('file',            nargs='?', default=None, help='Single mapping CSV path')
    parser.add_argument('--source-system', default=None,            help='Filter by source system (e.g. FMS)')
    parser.add_argument('--table',         default=None, nargs='+', help='Filter by table filename prefix (one or more)')
    parser.add_argument('--all',           action='store_true',     help='Process all staging mapping files')
    parser.add_argument('--stdout',        action='store_true',     help='Print SQL to stdout instead of writing file')
    args = parser.parse_args()

    if not args.file and not args.all and not args.source_system and not args.table:
        parser.error('Provide a file path, --source-system, --table, or --all')

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
        print(f'[gen_code_staging] Done. {len(generated)} file(s) generated:')
        for p in generated:
            print(f'  {os.path.relpath(p, REPO_ROOT)}')


if __name__ == '__main__':
    main()
