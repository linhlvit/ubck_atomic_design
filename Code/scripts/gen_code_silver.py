"""
gen_code_silver — Convert mapping CSV → formatted SQL.

Usage (from repo root):
    python Code/scripts/gen_code_silver.py Mapping/silver/FIMS/fund_management_company_FIMS_FUNDCOMPANY.csv
    python Code/scripts/gen_code_silver.py --all
    python Code/scripts/gen_code_silver.py --entity "Fund Management Company"

Reads from:
    Mapping/silver/<SS>/<entity>.csv

Writes to:
    Code/silver/<SS>/<entity>.sql

Pattern rules:
- physical_table standalone → 1 CTE
- physical_table + derived_cte pair → gộp thành 1 CTE (SELECT agg FROM table WHERE ... GROUP BY ...)
- physical_table + unpivot_cte pair → 1 CTE với UNION ALL các legs
- UNION ALL trong Final Filter (shared_entity) → duplicate main SELECT cho mỗi leg
"""
import csv, os, sys, argparse, glob, re

REPO_ROOT   = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MAPPING_DIR = os.path.join(REPO_ROOT, 'Mapping', 'silver')
CODE_DIR    = os.path.join(REPO_ROOT, 'Code', 'silver')


# ── Parse ─────────────────────────────────────────────────────────────────────

SECTION_BANNERS = {'Target', 'Input', 'Relationship', 'Mapping', 'Final Filter'}

def parse_mapping_csv(path):
    """Return dict of section → list of data rows (headers + banners skipped)."""
    with open(path, 'r', encoding='utf-8-sig') as f:
        rows = list(csv.reader(f))

    sections = {'target': [], 'input': [], 'relationship': [], 'mapping': [], 'filter': []}
    section_key = {'Target':'target','Input':'input','Relationship':'relationship',
                   'Mapping':'mapping','Final Filter':'filter'}
    current = None
    pending_header = False

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


# ── CTE builders ──────────────────────────────────────────────────────────────

def get(row, idx, default=''):
    return row[idx].strip() if idx < len(row) else default

def format_where(expr, indent='    '):
    """Split WHERE expression at AND/OR boundaries for readability.

    '<indent>WHERE' stays on first line; each subsequent AND/OR gets its own line
    indented 4 spaces deeper.
    """
    parts = re.split(r'\s+(AND|OR)\s+', expr, flags=re.IGNORECASE)
    if len(parts) == 1:
        return expr
    cont_indent = indent + '    '
    result = parts[0].strip()
    for i in range(1, len(parts), 2):
        op = parts[i].upper()
        cond = parts[i + 1].strip()
        result += f"\n{cont_indent}{op} {cond}"
    return result


def build_physical_cte(row):
    schema, table, alias, sel, filt = get(row,2), get(row,3), get(row,4), get(row,5), get(row,6)
    source = f"{schema}.{table}" if schema else table
    cte = f"{alias} AS (\n    SELECT {sel}\n    FROM {source}"
    if filt:
        cte += f"\n    WHERE {format_where(filt)}"
    cte += "\n)"
    return cte

def build_merged_derived_cte(phys_row, derv_row):
    """Merge physical_table + derived_cte into 1 CTE (pre-aggregate at source)."""
    p_schema, p_table, p_filter = get(phys_row,2), get(phys_row,3), get(phys_row,6)
    d_alias, d_sel, d_filter = get(derv_row,4), get(derv_row,5), get(derv_row,6)
    source = f"{p_schema}.{p_table}" if p_schema else p_table

    group_by, where_extra = '', ''
    if d_filter.upper().startswith('GROUP BY'):
        group_by = d_filter
    elif d_filter:
        where_extra = d_filter

    cte = f"{d_alias} AS (\n    SELECT {d_sel}\n    FROM {source}"
    wheres = [w for w in (p_filter, where_extra) if w]
    if wheres:
        cte += f"\n    WHERE {format_where(' AND '.join(wheres))}"
    if group_by:
        cte += f"\n    {group_by}"
    cte += "\n)"
    return cte

def parse_unpivot_select(sel):
    """'ip_code=id | TYPE1:col1 | TYPE2:col2 | passthrough' → (id_col, legs, passthroughs)."""
    parts = [p.strip() for p in sel.split('|')]
    id_col, legs, pass_cols = None, [], []
    for p in parts:
        if p.startswith('ip_code='):
            id_col = p.split('=', 1)[1].strip()
        elif ':' in p:
            t, c = p.split(':', 1)
            legs.append((t.strip(), c.strip()))
        else:
            pass_cols.append(p)
    return id_col, legs, pass_cols

def build_unpivot_cte(phys_row, unpv_row):
    """physical_table + unpivot_cte → 1 CTE với UNION ALL các legs."""
    p_schema, p_table, p_filter = get(phys_row,2), get(phys_row,3), get(phys_row,6)
    u_alias, u_sel, u_filter = get(unpv_row,4), get(unpv_row,5), get(unpv_row,6)
    source = f"{p_schema}.{p_table}" if p_schema else p_table

    id_col, legs, pass_cols = parse_unpivot_select(u_sel)

    leg_sqls = []
    for type_code, val_col in legs:
        cols_lines = [
            f"        {id_col} AS ip_code",
            f"        '{type_code}' AS type_code",
            f"        {val_col} AS address_value",
        ]
        for pc in pass_cols:
            cols_lines.append(f"        {pc}")
        wheres = []
        if p_filter:
            wheres.append(p_filter)
        if u_filter:
            # replace 'address_value' placeholder with actual column for per-leg filter
            wheres.append(u_filter.replace('address_value', val_col))
        leg_sql = "    SELECT\n" + ",\n".join(cols_lines) + f"\n    FROM {source}"
        if wheres:
            leg_sql += f"\n    WHERE {format_where(' AND '.join(wheres))}"
        leg_sqls.append(leg_sql)

    body = "\n    UNION ALL\n".join(leg_sqls)
    return f"{u_alias} AS (\n{body}\n)"


def build_ctes(input_rows):
    """Group input rows into CTEs (pair detection: row[i+1].col3 == row[i].col4)."""
    ctes, i = [], 0
    while i < len(input_rows):
        row = input_rows[i]
        stype = get(row, 1)
        if stype != 'physical_table':
            i += 1
            continue
        alias = get(row, 4)
        # Check pairing
        if i + 1 < len(input_rows):
            nxt = input_rows[i + 1]
            ntype, nsrc = get(nxt, 1), get(nxt, 3)
            if nsrc == alias:
                if ntype == 'derived_cte':
                    ctes.append(build_merged_derived_cte(row, nxt))
                    i += 2
                    continue
                if ntype == 'unpivot_cte':
                    ctes.append(build_unpivot_cte(row, nxt))
                    i += 2
                    continue
        ctes.append(build_physical_cte(row))
        i += 1
    return ctes


# ── Main SELECT ───────────────────────────────────────────────────────────────

def build_select_columns(mapping_rows, alias_substitution=None):
    """Return list of formatted column SQL strings.

    Rules:
    - hash_id(...) transformations: keep as-is (not cast).
    - Other transformations: format as <transf> :: <data_type>.
    - Empty transformation: NULL :: <data_type>.
    """
    items = []
    for r in mapping_rows:
        tgt = get(r, 1)
        transf = get(r, 2)
        dtype = get(r, 3) or 'string'
        if not tgt:
            continue
        if alias_substitution:
            for old, new in alias_substitution.items():
                transf = re.sub(rf'\b{re.escape(old)}\b', new, transf)
        expr = transf if transf else 'NULL'
        is_hash = expr.lower().startswith('hash_id(')
        rendered = expr if is_hash else f"{expr} :: {dtype}"
        items.append((rendered, tgt))

    max_e = max((len(e) for e, _ in items), default=0)
    max_e = min(max_e, 72)

    cols = []
    for expr, tgt in items:
        pad = ' ' * max(1, max_e - len(expr) + 1)
        cols.append(f"{expr}{pad}AS {tgt}")
    return cols


def format_select_cols(cols, indent='    '):
    """Join column strings with trailing commas (except last)."""
    lines = []
    for i, col in enumerate(cols):
        suffix = ',' if i < len(cols) - 1 else ''
        lines.append(f"{indent}{col}{suffix}")
    return '\n'.join(lines)


def extract_leg_aliases_from_union(union_expr):
    """'SELECT * FROM leg_a\\nUNION ALL\\nSELECT * FROM leg_b' → ['leg_a','leg_b']."""
    return [m.group(1) for m in re.finditer(r'SELECT\s+\*\s+FROM\s+(\w+)', union_expr, re.IGNORECASE)]


def build_final_select(sections):
    """Return the SELECT + FROM + JOIN + WHERE ... block (or UNION ALL for shared_entity)."""
    mapping_rows = sections['mapping']
    rel_rows     = sections['relationship']
    filter_rows  = sections['filter']
    input_rows   = sections['input']

    # Parse filter clauses
    where, group_by, having, order_by, union_expr = [], '', '', '', ''
    for r in filter_rows:
        ctype, expr = get(r, 1), get(r, 2)
        if not expr: continue
        up = ctype.upper()
        if up == 'WHERE':     where.append(expr)
        elif up == 'GROUP BY': group_by = expr
        elif up == 'HAVING':   having = expr
        elif up == 'ORDER BY': order_by = expr
        elif up == 'UNION ALL': union_expr = expr

    # Primary alias
    primary = None
    if rel_rows:
        for r in rel_rows:
            if get(r, 1):
                primary = get(r, 1); break

    # Joins
    joins = []
    for r in rel_rows:
        jt, ja, jo = get(r, 2), get(r, 3), get(r, 4)
        if jt and ja and jo:
            joins.append(f"    {jt} {ja} ON {jo}")

    # Shared entity detection: có unpivot_cte trong input section
    unpivot_aliases = [get(r, 4) for r in input_rows if get(r, 1) == 'unpivot_cte']

    if unpivot_aliases:
        # Lấy leg list từ UNION ALL clause nếu có, fallback về unpivot_aliases
        leg_aliases = extract_leg_aliases_from_union(union_expr) if union_expr else unpivot_aliases
        # first_leg = alias hardcoded trong mapping transformations
        first_leg = None
        for r in mapping_rows:
            m = re.search(r'\b(leg_\w+)\b', get(r, 2))
            if m: first_leg = m.group(1); break
        if first_leg is None and leg_aliases:
            first_leg = leg_aliases[0]

        parts = []
        for leg in leg_aliases:
            substitution = {first_leg: leg} if first_leg and leg != first_leg else None
            cols = build_select_columns(mapping_rows, substitution)
            sel = "SELECT\n" + format_select_cols(cols) + f"\nFROM {leg}"
            parts.append(sel)
        return "\nUNION ALL\n".join(parts)

    # Regular case
    cols = build_select_columns(mapping_rows)
    sql = "SELECT\n" + format_select_cols(cols)
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


# ── Assemble ──────────────────────────────────────────────────────────────────

def build_program_header(mapping_csv_path):
    """Build standard program header block comment."""
    file_base = os.path.splitext(os.path.basename(mapping_csv_path))[0]
    program_name = ' '.join((w[0].upper() + w[1:]) if w else w for w in file_base.split('_'))
    divider = '*' + '-' * 68 + '*'
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


def generate_sql(mapping_csv_path):
    sections = parse_mapping_csv(mapping_csv_path)

    ctes = build_ctes(sections['input'])
    main = build_final_select(sections)

    sql = build_program_header(mapping_csv_path)
    if ctes:
        sql += "\nWITH " + ",\n\n".join(ctes) + "\n\n"
    sql += main + "\n;\n"
    return sql


def resolve_inputs(args):
    """Return list of mapping CSV paths to process."""
    if args.file:
        return [os.path.abspath(args.file)]
    pattern = os.path.join(MAPPING_DIR, '*', '*.csv')
    files = glob.glob(pattern)
    if args.entity:
        snake = re.sub(r'\s+', '_', args.entity.lower())
        files = [f for f in files if os.path.basename(f).startswith(snake)]
    if args.source_system:
        files = [f for f in files if os.sep + args.source_system + os.sep in f
                                      or f'/{args.source_system}/' in f]
    return files


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('file', nargs='?', default=None, help='Single mapping CSV path')
    parser.add_argument('--entity', default=None)
    parser.add_argument('--source-system', default=None)
    parser.add_argument('--all', action='store_true', help='Process all mapping files')
    parser.add_argument('--stdout', action='store_true', help='Print SQL to stdout instead of writing file')
    args = parser.parse_args()

    if not args.file and not args.all and not args.entity and not args.source_system:
        parser.error('Provide a file path, --entity, --source-system, or --all')

    files = resolve_inputs(args)
    if not files:
        print("No mapping files matched.", file=sys.stderr)
        sys.exit(1)

    generated = []
    for f in files:
        sql = generate_sql(f)
        if args.stdout:
            print(sql)
            continue
        ss_name = os.path.basename(os.path.dirname(f))
        out_dir = os.path.join(CODE_DIR, ss_name)
        os.makedirs(out_dir, exist_ok=True)
        base = os.path.splitext(os.path.basename(f))[0]
        out_path = os.path.join(out_dir, f'{base}.sql')
        with open(out_path, 'w', encoding='utf-8') as g:
            g.write(sql)
        generated.append(out_path)

    if not args.stdout:
        print(f"[gen_code_silver] Done. {len(generated)} file(s) generated:")
        for p in generated:
            print(f"  {os.path.relpath(p, REPO_ROOT)}")


if __name__ == '__main__':
    main()
