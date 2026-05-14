"""
Step 3 — gen_mapping_atomic
Routes by mapping_type:
  regular       : 1 SSC = 1 sheet → 1 file per entity per source system
  shared_entity : 1 source_system = 1 sheet (unpivot_cte pattern)
  cv            : placeholder

Usage (from repo root):
    python Mapping/scripts/gen_mapping_atomic.py
    python Mapping/scripts/gen_mapping_atomic.py --entity "Fund Management Company"
    python Mapping/scripts/gen_mapping_atomic.py --source-system FMS

Reads from:
    Mapping/registries/gm_atomic_entities.csv
    Mapping/registries/gm_atomic_attributes.csv
    Mapping/registries/gm_bronze_attributes.csv  (dung de detect_join)
    system/templates/mapping_template.csv
    system/rules/rule_map_schema.csv
    system/rules/rule_map_technical_table_type.csv

Source trong INPUT section la bang ODS (ods_<ss>_<table>), schema lay tu cot Ten Schema ODS.

Writes to:
    Mapping/atomic/<source_system>/<entity_snake>_<ssc_lower>.csv
"""
import csv, pandas as pd, re, os, sys, argparse, wordninja

REPO_ROOT    = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REGISTRY_DIR = os.path.join(REPO_ROOT, 'Mapping', 'registries')
MAPPING_DIR  = os.path.join(REPO_ROOT, 'Mapping', 'atomic')
TEMPLATE     = os.path.join(REPO_ROOT, 'system', 'templates', 'mapping_template.csv')
RULES_DIR    = os.path.join(REPO_ROOT, 'system', 'rules')

ATOMIC_ENT_PATH = os.path.join(REGISTRY_DIR, 'gm_atomic_entities.csv')
ATOMIC_ATR_PATH = os.path.join(REGISTRY_DIR, 'gm_atomic_attributes.csv')
BRONZE_ATR_PATH = os.path.join(REGISTRY_DIR, 'gm_bronze_attributes.csv')

NUM_COLS = 11

# ── Schema map (SSC → oracle schema) ─────────────────────────────────────────

def load_schema_map():
    """Return map: source_system -> ODS schema (Ten Schema ODS, col index 5)."""
    path = os.path.join(RULES_DIR, 'rule_map_schema.csv')
    df = pd.read_csv(path)
    return dict(zip(df.iloc[:, 0].str.strip(), df.iloc[:, 5].str.strip()))

# ── Technical fields map (Technical Table Type → list of field names) ─────────

def load_tech_fields():
    path = os.path.join(RULES_DIR, 'rule_map_technical_table_type.csv')
    df = pd.read_csv(path)
    result = {}
    for _, row in df.iterrows():
        tech_type = str(row['Technical Table Type']).strip()
        fields_str = str(row.get('Technical Field', '')).strip()
        if fields_str and fields_str != 'nan':
            fields = [f.strip() for f in fields_str.split(',') if f.strip()]
        else:
            fields = []
        result[tech_type] = fields
    return result

# ── CSV-based sheet abstraction ───────────────────────────────────────────────

class CSVSheet:
    """Minimal worksheet abstraction that stores cells in a dict and dumps to CSV."""
    def __init__(self, num_cols=NUM_COLS):
        self._cells = {}
        self._num_cols = num_cols

    def cell(self, row, column, value=None):
        if value is not None:
            self._cells[(row, column)] = value
        return self._cells.get((row, column))

    def set(self, row, col, val):
        self._cells[(row, col)] = val

    def get(self, row, col):
        return self._cells.get((row, col), '')

    def to_rows(self):
        if not self._cells:
            return []
        max_row = max(r for r, _ in self._cells)
        rows = []
        for r in range(1, max_row + 1):
            rows.append([self._cells.get((r, c), '') for c in range(1, self._num_cols + 1)])
        return rows

    def save_csv(self, path):
        with open(path, 'w', newline='', encoding='utf-8-sig') as f:
            writer = csv.writer(f)
            for row in self.to_rows():
                writer.writerow([v if v is not None else '' for v in row])


def load_csv_template(path):
    ws = CSVSheet()
    with open(path, 'r', encoding='utf-8-sig') as f:
        reader = csv.reader(f)
        for r_idx, row in enumerate(reader, start=1):
            for c_idx, val in enumerate(row, start=1):
                if val:
                    ws.set(r_idx, c_idx, val)
    return ws


# ── Primitives ────────────────────────────────────────────────────────────────

def copy_tmpl_row(tmpl_ws, t_row, ws, d_row, n=NUM_COLS):
    for col in range(1, n + 1):
        ws.set(d_row, col, tmpl_ws.get(t_row, col))

def put(ws, row, col, val, flag=False):
    ws.set(row, col, val if val is not None else '')

def blank_row(ws, row, n=NUM_COLS, flag=False):
    for col in range(1, n + 1):
        put(ws, row, col, '')


# ── Alias ─────────────────────────────────────────────────────────────────────
ALIAS_OVERRIDES = {
    'SECBUSINES': 'se_bu', 'FUNDCOMBUSINES': 'fu_bu',
    'FUNDCOMTYPE': 'fu_ty', 'STFFGBRCH': 'st_br',
    'ORGANIZATIONS': 'org', 'PROFESSIONALS': 'pro',
}

def _split_compound(word):
    parts = wordninja.split(word.lower())
    merged, buf = [], ''
    for p in parts:
        buf += p
        if len(buf) >= 4: merged.append(buf); buf = ''
    if buf:
        (merged.append(buf) if len(buf) >= 2 else
         (merged.__setitem__(-1, merged[-1]+buf) if merged else merged.append(buf)))
    return merged

def make_alias(tbl):
    name = re.sub(r'_(snp|stg|hist|v\d+)$', '', tbl, flags=re.IGNORECASE).upper()
    if name in ALIAS_OVERRIDES: return ALIAS_OVERRIDES[name]
    parts = name.split('_')
    segs  = parts if len(parts) > 1 else _split_compound(parts[0])
    return '_'.join(p[:2].lower() for p in segs if p)

def to_snake(name): return re.sub(r'\s+', '_', str(name).strip()).lower()

def extract_quoted(text):
    m = re.search(r"'([^']+)'", str(text)); return m.group(1) if m else ''

def parse_source_col(raw):
    """3-part SOURCE.TABLE.col  or  4-part SOURCE.SCHEMA.TABLE.col"""
    if not raw or str(raw) == 'nan': return None, None, None
    parts = str(raw).strip().split('.')
    if len(parts) == 4: return parts[0].upper(), parts[2].upper(), parts[3].lower()
    if len(parts) == 3: return parts[0].upper(), parts[1].upper(), parts[2].lower()
    return None, None, None

def row_source_info(row):
    """Extract (src_sys, tbl, col) from registry columns: source_system + ods_table + ods_column.
    For Array<Text>: tbl is the junction table extracted from comment 'Pure junction <TABLE> →'.
    For others: tbl is derived from ods_table by stripping the 'ods_<ss>_' prefix.
    """
    src_sys = str(row['source_system']).strip().upper() if pd.notna(row['source_system']) else ''
    ods_tbl = str(row['ods_table']).strip() if pd.notna(row['ods_table']) else ''
    col     = str(row['ods_column']).strip() if pd.notna(row['ods_column']) else ''
    domain  = str(row['data_domain'])
    if domain == 'Array<Text>':
        if not col:
            return src_sys, '', col
        comment = str(row['comment']) if pd.notna(row['comment']) else ''
        m = re.search(r'Pure junction\s+(\w+)', comment, re.IGNORECASE)
        tbl = m.group(1).upper() if m else ''
    elif ods_tbl and src_sys:
        prefix = f'ods_{src_sys.lower()}_'
        tbl = ods_tbl[len(prefix):].upper() if ods_tbl.lower().startswith(prefix) else ods_tbl.upper()
    else:
        tbl = ods_tbl.upper() if ods_tbl else ''
    return src_sys, tbl, col

def get_ssc(ctx):
    m = re.search(r"'([^']+)'", str(ctx)); return m.group(1) if m else 'UNKNOWN'

def extract_ctx_vals(ctx):
    """Return all single-quoted values from classification_context."""
    return re.findall(r"'([^']+)'", str(ctx))

COL_TO_TYPE = {
    'email':'EMAIL','fax':'FAX','telephone':'PHONE','website':'WEBSITE',
    'mobilenumber':'MOBILE','phonenumber':'PHONE',
    'email_kd':'EMAIL','fax_kd':'FAX','dien_thoai_kd':'PHONE','dien_thoai':'PHONE',
    'dia_chi':'ADDRESS','dia_chi_tsc':'HEAD_OFFICE','mota_diachi_kd':'BUSINESS',
}
def col_to_type(col): return COL_TO_TYPE.get(col.lower(), col.upper().replace('_',' '))

def get_source_tables(grp, schema_map=None):
    """Return ordered list of source tables with schema info per table."""
    ordered, seen, info = [], set(), {}
    for _, row in grp.iterrows():
        domain  = str(row['data_domain'])
        src_sys, tbl, col = row_source_info(row)
        if not tbl: continue
        if tbl not in seen:
            ordered.append(tbl); seen.add(tbl)
            schema = schema_map.get(src_sys, 'bronze') if (schema_map and src_sys) else 'bronze'
            info[tbl] = {'cols': [], 'array_attrs': [], 'source_system': src_sys, 'schema': schema}
        if col and col not in info[tbl]['cols']:
            info[tbl]['cols'].append(col)
        if domain == 'Array<Text>' and col:
            info[tbl]['array_attrs'].append({
                'attr_name': str(row['atomic_attribute']),
                'col_name': col,
                'snake_name': str(row['atomic_column']),
            })
    return [{'table_name': t,
             'ods_table': f"ods_{info[t]['source_system'].lower()}_{t.lower()}" if info[t]['source_system'] else t.lower(),
             'alias': make_alias(t),
             'schema': info[t]['schema'],
             'cols': info[t]['cols'],
             'array_attrs': info[t]['array_attrs']} for t in ordered]

def detect_join(main_table, main_alias, sec_info, df_bz_atr):
    sec_table = sec_info['table_name']; sec_alias = sec_info['alias']
    sec_cols  = df_bz_atr[df_bz_atr['table_name'].str.upper() == sec_table.upper()]
    main_pk   = df_bz_atr[(df_bz_atr['table_name'].str.upper() == main_table.upper()) &
                           (df_bz_atr['pk/fk'] == 'PK')]
    pk_col = main_pk.iloc[0]['column_name'].lower() if not main_pk.empty else 'id'
    for _, fk_row in sec_cols.iterrows():
        if main_table.upper() in str(fk_row.get('description', '')).upper():
            fk_col = str(fk_row['column_name']).lower()
            return f"{main_alias}.{pk_col} = {sec_alias}.{fk_col}", fk_col
    return f"{main_alias}.{pk_col} = {sec_alias}.??", None

def build_entity_ssc_map(df_atr):
    ssc_map = {}
    for entity, grp in df_atr.groupby('atomic_entity'):
        rows = grp[(grp['data_domain'] == 'Classification Value') &
                   grp['comment'].astype(str).str.contains('SOURCE_SYSTEM', na=False)]
        if not rows.empty:
            val = extract_quoted(str(rows.iloc[0]['classification_context']))
            if val: ssc_map[entity] = val
    return ssc_map

def get_select_fields(cols, tbl, df_bz_atr):
    """Return '*' only if cols covers ALL columns of tbl in df_bz_atr, else list cols."""
    if not cols:
        return ', '.join(cols) if cols else '*'
    total = len(df_bz_atr[df_bz_atr['table_name'].str.upper() == tbl.upper()])
    return '*' if (total > 0 and len(cols) >= total) else ', '.join(cols)

def detect_unpivot_legs(ssc_grp):
    sk_rows = ssc_grp[ssc_grp['data_domain'] == 'Surrogate Key']
    id_col  = str(sk_rows.iloc[0]['ods_column']).strip() if (not sk_rows.empty and pd.notna(sk_rows.iloc[0]['ods_column'])) else ''
    id_col  = id_col or 'id'
    text_rows = ssc_grp[(ssc_grp['data_domain'] == 'Text') &
                         ssc_grp['ods_column'].notna() &
                         (ssc_grp['ods_column'].astype(str) != 'nan')]
    legs = []
    for _, row in text_rows.iterrows():
        val_col = str(row['ods_column']).strip() if pd.notna(row['ods_column']) else ''
        if val_col and val_col != id_col:
            legs.append((col_to_type(val_col), val_col))
    return id_col, legs

def get_transformation(row, source_tables, pk_code_col, own_ssc, entity_ssc_map):
    domain  = str(row['data_domain'])
    comment = str(row['comment'])  if pd.notna(row['comment'])  else ''
    attr    = str(row['atomic_attribute'])
    ctx     = str(row['classification_context']) if pd.notna(row['classification_context']) else ''
    _, src_tbl, col = row_source_info(row)
    alias = source_tables[0]['alias'] if source_tables else ''
    if src_tbl:
        for t in source_tables:
            if t['table_name'].upper() == src_tbl.upper(): alias = t['alias']; break
    if attr == 'Source System Code':
        ssc_val = extract_quoted(ctx)
        return (f"'{ssc_val}'", '') if ssc_val else ('', '')
    if domain == 'Surrogate Key' and row['is_primary_key']:
        return f"hash_id('{own_ssc}', {alias}.{pk_code_col.get(attr,'??')})", ''
    if domain == 'Surrogate Key':
        m = re.search(r'FK target:\s*(.+?)\.\s*\w', comment)
        target_entity = m.group(1).strip() if m else ''
        target_ssc    = entity_ssc_map.get(target_entity, '')
        if target_ssc and col: return f"hash_id('{target_ssc}', {alias}.{col})", ''
        return '', ''
    if domain == 'Classification Value' and 'SOURCE_SYSTEM' in comment:
        return f"'{extract_quoted(ctx)}'", ''
    if domain == 'Array<Text>':
        return (f"{alias}.{str(row['atomic_column'])}", '') if (alias and col) else ('', '')
    if col: return f"{alias}.{col}", ''
    return '', ''

T = {
    'target_banner':1,'target_header':2,
    'input_banner':4,'input_header':5,
    'rel_banner':11,'rel_header':12,
    'map_banner':16,'map_header':17,
    'flt_banner':35,'flt_header':36,
    'flt_where':37,'flt_groupby':38,'flt_having':39,'flt_orderby':40,'flt_union':41,
}

TARGET_SCHEMA = 'atomic."env_name"_atm'

TECH_FIELD_META = {
    'ds_etl_pcs_tms':  ('ETL Processing Timestamp', 'timestamp'),
    'ds_snpst_dt':     ('Snapshot Date',            'date'),
    'ds_rcrd_st':      ('Record Status',            'int'),
    'ds_rcrd_eff_dt':  ('Record Effective Date',    'date'),
    'ds_rcrd_end_dt':  ('Record End Date',          'date'),
    'ds_rcrd_isrt_dt': ('Record Insert Date',       'date'),
    'ds_rcrd_udt_dt':  ('Record Update Date',       'date'),
}

def write_target(ws, tmpl_ws, r, atomic_table, etl_handle, description):
    copy_tmpl_row(tmpl_ws, T['target_banner'], ws, r)
    r += 1; copy_tmpl_row(tmpl_ws, T['target_header'], ws, r)
    r += 1; blank_row(ws, r)
    put(ws, r, 2, TARGET_SCHEMA)
    put(ws, r, 3, atomic_table)
    put(ws, r, 4, etl_handle)
    put(ws, r, 8, description)
    r += 1
    return r

def write_final_filter(ws, tmpl_ws, r, union_expr=None, where=None,
                        group_by=None, having=None, order_by=None):
    clauses = [('flt_where',where),('flt_groupby',group_by),
               ('flt_having',having),('flt_orderby',order_by),('flt_union',union_expr)]
    active = [(key, expr) for key, expr in clauses if expr]
    copy_tmpl_row(tmpl_ws, T['flt_banner'], ws, r)
    r += 1; copy_tmpl_row(tmpl_ws, T['flt_header'], ws, r); r += 1
    for seq, (key, expr) in enumerate(active, start=1):
        copy_tmpl_row(tmpl_ws, T[key], ws, r)
        ws.set(r, 1, seq)
        ws.set(r, 3, expr)
        r += 1
    return r

def write_regular_sheet(ws, tmpl_ws, entity_name, meta, src_grp, ssc,
                        df_bz_atr, entity_ssc_map, schema_map, tech_fields_map):
    src_full     = str(meta.get('source_table', ''))
    source_table = src_full.split(',')[0].strip().split('.')[-1].upper()
    etl_handle   = str(meta.get('technical_table_type', ''))
    description  = str(meta.get('description', ''))
    atomic_table = str(meta.get('atomic_table', to_snake(entity_name)))
    own_ssc      = ssc
    source_tables = get_source_tables(src_grp, schema_map)
    if not source_tables:
        src_sys_fallback = str(src_grp.iloc[0].get('source_system', '')).strip().upper() if len(src_grp) > 0 else ''
        schema_fallback = schema_map.get(src_sys_fallback, 'bronze')
        source_tables = [{'table_name': source_table, 'alias': make_alias(source_table),
                          'schema': schema_fallback, 'cols': [], 'array_attrs': []}]
    primary = source_tables[0]
    pk_code_col = {}
    pk_rows = src_grp[(src_grp['data_domain'] == 'Surrogate Key') & src_grp['is_primary_key']]
    for _, pk_row in pk_rows.iterrows():
        nxt = src_grp[(src_grp.index > pk_row.name) &
                      (src_grp['data_domain'] == 'Text') & (~src_grp['is_primary_key'])]
        if not nxt.empty:
            code_col = str(nxt.iloc[0]['ods_column']).strip() if pd.notna(nxt.iloc[0]['ods_column']) else ''
            pk_code_col[pk_row['atomic_attribute']] = code_col or '??'
    r = 1
    r = write_target(ws, tmpl_ws, r, atomic_table, etl_handle, description)
    copy_tmpl_row(tmpl_ws, T['input_banner'], ws, r)
    r += 1; copy_tmpl_row(tmpl_ws, T['input_header'], ws, r); r += 1
    join_info = {}; input_seq = 1
    for tbl_info in source_tables:
        tbl = tbl_info['table_name']; alias = tbl_info['alias']
        schema = tbl_info['schema']
        cols = list(tbl_info['cols']); is_arr = bool(tbl_info['array_attrs'])
        if is_arr:
            join_on, fk_col = detect_join(primary['table_name'], primary['alias'], tbl_info, df_bz_atr)
            join_info[tbl] = (join_on, fk_col, alias)
            if fk_col and fk_col not in cols: cols = [fk_col] + cols
            raw_alias = f"{alias}_raw"
            agg_exprs = [f"array_agg({a['col_name']}) AS {a['snake_name']}" for a in tbl_info['array_attrs']]
            _, fk2, _ = join_info.get(tbl, ('', None, alias))
            select_agg = (f"{fk2}, " if fk2 else '') + ', '.join(agg_exprs)
            group_by   = f"GROUP BY {fk2}" if fk2 else '🚩 GROUP BY ??'
            blank_row(ws,r); put(ws,r,1,input_seq); input_seq+=1
            put(ws,r,2,'physical_table'); put(ws,r,3,schema); put(ws,r,4,tbl_info['ods_table'])
            put(ws,r,5,raw_alias); put(ws,r,6,get_select_fields(cols, tbl, df_bz_atr))
            put(ws,r,7,'ds_snpst_dt = to_date("etl_date", \'yyyy-MM-dd\')')
            r+=1
            blank_row(ws,r); put(ws,r,1,input_seq); input_seq+=1
            put(ws,r,2,'derived_cte'); put(ws,r,3,''); put(ws,r,4,raw_alias)
            put(ws,r,5,alias); put(ws,r,6,select_agg); put(ws,r,7,group_by)
            r+=1
        else:
            if tbl != primary['table_name']:
                join_on, fk_col = detect_join(primary['table_name'], primary['alias'], tbl_info, df_bz_atr)
                join_info[tbl] = (join_on, fk_col, alias)
                if fk_col and fk_col not in cols: cols = [fk_col] + cols
            blank_row(ws,r); put(ws,r,1,input_seq); input_seq+=1
            put(ws,r,2,'physical_table'); put(ws,r,3,schema); put(ws,r,4,tbl_info['ods_table'])
            put(ws,r,5,alias); put(ws,r,6,get_select_fields(cols, tbl, df_bz_atr))
            put(ws,r,7,'ds_snpst_dt = to_date("etl_date", \'yyyy-MM-dd\')')
            r+=1
    copy_tmpl_row(tmpl_ws, T['rel_banner'], ws, r)
    r += 1; copy_tmpl_row(tmpl_ws, T['rel_header'], ws, r); r += 1
    if join_info:
        for seq, (tbl, (join_on, fk_col, sec_alias)) in enumerate(join_info.items(), start=1):
            blank_row(ws, r); put(ws,r,1,seq); put(ws,r,2,primary['alias'])
            put(ws,r,3,'LEFT JOIN'); put(ws,r,4,sec_alias); put(ws,r,5,join_on)
            r+=1
    else:
        blank_row(ws, r); r += 1
    copy_tmpl_row(tmpl_ws, T['map_banner'], ws, r)
    r += 1; copy_tmpl_row(tmpl_ws, T['map_header'], ws, r); r += 1
    seq = 1
    for _, atr in src_grp.iterrows():
        transf, _ = get_transformation(atr, source_tables, pk_code_col, own_ssc, entity_ssc_map)
        blank_row(ws, r)
        put(ws,r,1,seq); seq+=1
        put(ws,r,2,str(atr['atomic_column']))          # Physical Target Column
        put(ws,r,3,transf)
        put(ws,r,4,str(atr.get('data_type','')))
        put(ws,r,5,str(atr['atomic_attribute']))       # Logical Target Column
        put(ws,r,8,str(atr['description']) if pd.notna(atr['description']) else '')
        r+=1
    # Technical fields (transformation left empty)
    tech_fields = tech_fields_map.get(etl_handle, [])
    for tf in tech_fields:
        log_name, dtype = TECH_FIELD_META.get(tf, ('', ''))
        blank_row(ws, r)
        put(ws,r,1,seq); seq+=1
        put(ws,r,2,tf)        # Physical Target Column
        # Transformation: empty (col 3)
        put(ws,r,4,dtype)     # Data Type
        put(ws,r,5,log_name)  # Logical Target Column
        r+=1
    r = write_final_filter(ws, tmpl_ws, r)
    return r

# ── Alt ID (direct-select per leg, classification_context has | separator) ────

def build_alt_id_legs(sys_grp, schema_map):
    """Each unique classification_context = 1 leg (direct SELECT, no unpivot)."""
    ctx_col = 'classification_context'
    unique_ctxs = list(dict.fromkeys(sys_grp[ctx_col].fillna('').tolist()))
    legs = []
    alias_count = {}
    for ctx in unique_ctxs:
        ctx_grp = sys_grp[sys_grp[ctx_col] == ctx].reset_index(drop=True)
        vals = extract_ctx_vals(ctx)
        ssc_val     = vals[0] if len(vals) > 0 else ''
        id_type_val = vals[1] if len(vals) > 1 else ''
        src_sys = None; src_tbl = None
        for _, row in ctx_grp.iterrows():
            s, t, _ = row_source_info(row)
            if t: src_sys = s; src_tbl = t; break
        if not src_tbl:
            src_tbl = ssc_val.split('_', 1)[-1] if '_' in ssc_val else ssc_val
            src_sys  = ssc_val.split('_')[0] if ssc_val else ''
        base = make_alias(src_tbl)
        if base not in alias_count:
            alias = base; alias_count[base] = 1
        else:
            alias_count[base] += 1
            alias = f"{base}_{alias_count[base]}"
        schema = schema_map.get(src_sys, 'bronze') if (schema_map and src_sys) else 'bronze'
        ods_table = f"ods_{src_sys.lower()}_{src_tbl.lower()}" if src_sys and src_tbl else src_tbl or ''
        sel_cols = []
        for _, row in ctx_grp.iterrows():
            col = str(row['ods_column']).strip() if pd.notna(row['ods_column']) else ''
            if col and col not in sel_cols: sel_cols.append(col)
        legs.append({'ctx': ctx, 'ssc_val': ssc_val, 'id_type_val': id_type_val,
                     'src_sys': src_sys, 'src_tbl': src_tbl, 'ods_table': ods_table,
                     'alias': alias, 'schema': schema, 'sel_cols': sel_cols, 'ctx_grp': ctx_grp})
    return legs

def get_alt_id_leg_transf(row, leg):
    """Compute transformation for one attribute row in one alt_id leg."""
    domain  = str(row['data_domain'])
    comment = str(row['comment']) if pd.notna(row['comment']) else ''
    attr    = str(row['atomic_attribute'])
    _, _, col = row_source_info(row)
    alias = leg['alias']
    ssc_val = leg['ssc_val']
    id_type_val = leg['id_type_val']
    if attr == 'Source System Code' or (domain == 'Classification Value' and 'SOURCE_SYSTEM' in comment):
        return f"'{ssc_val}'"
    if domain == 'Surrogate Key':
        if col: return f"hash_id('{ssc_val}', {alias}.{col})"
        return f"hash_id('{ssc_val}', {alias}.??)"
    if domain == 'Classification Value' and not col and id_type_val:
        return f"'{id_type_val}'"
    if col: return f"{alias}.{col}"
    return ''

def write_alt_id_sheet(ws, tmpl_ws, entity_name, meta, sys_grp, sys_name,
                       df_bz_atr, entity_ssc_map, schema_map, tech_fields_map):
    """Alt Identification: direct SELECT per leg, classification_context has | separator."""
    etl_handle   = str(meta.get('technical_table_type', ''))
    atomic_table = str(meta.get('atomic_table', to_snake(entity_name)))
    description  = str(meta.get('description', ''))
    legs = build_alt_id_legs(sys_grp, schema_map)
    r = 1
    r = write_target(ws, tmpl_ws, r, atomic_table, etl_handle, description)
    # INPUT
    copy_tmpl_row(tmpl_ws, T['input_banner'], ws, r)
    r += 1; copy_tmpl_row(tmpl_ws, T['input_header'], ws, r); r += 1
    for seq, leg in enumerate(legs, start=1):
        blank_row(ws, r); put(ws,r,1,seq)
        put(ws,r,2,'physical_table'); put(ws,r,3,leg['schema'])
        put(ws,r,4,leg['ods_table']); put(ws,r,5,leg['alias'])
        put(ws,r,6,get_select_fields(leg['sel_cols'], leg['src_tbl'], df_bz_atr))
        put(ws,r,7,'ds_snpst_dt = to_date("etl_date", \'yyyy-MM-dd\')')
        r += 1
    # RELATIONSHIP — empty
    copy_tmpl_row(tmpl_ws, T['rel_banner'], ws, r)
    r += 1; copy_tmpl_row(tmpl_ws, T['rel_header'], ws, r); r += 1
    blank_row(ws, r); r += 1
    # MAPPING — unique attrs in first-appearance order across all legs
    copy_tmpl_row(tmpl_ws, T['map_banner'], ws, r)
    r += 1; copy_tmpl_row(tmpl_ws, T['map_header'], ws, r); r += 1
    seen = {}
    for leg in legs:
        for _, row in leg['ctx_grp'].iterrows():
            col_key = str(row['atomic_column'])
            if col_key not in seen: seen[col_key] = row
    seq = 1
    for phys_col, ref_row in seen.items():
        leg_exprs = []
        for leg in legs:
            match = leg['ctx_grp'][leg['ctx_grp']['atomic_column'] == phys_col]
            if match.empty: leg_exprs.append('')
            else:           leg_exprs.append(get_alt_id_leg_transf(match.iloc[0], leg))
        blank_row(ws, r)
        put(ws,r,1,seq); seq+=1
        put(ws,r,2,phys_col)
        put(ws,r,3,'; '.join(leg_exprs))
        put(ws,r,4,str(ref_row.get('data_type','')))
        put(ws,r,5,str(ref_row['atomic_attribute']))
        put(ws,r,8,str(ref_row['description']) if pd.notna(ref_row['description']) else '')
        r += 1
    # Technical fields
    tech_fields = tech_fields_map.get(etl_handle, [])
    for tf in tech_fields:
        log_name, dtype = TECH_FIELD_META.get(tf, ('', ''))
        blank_row(ws, r); put(ws,r,1,seq); seq+=1
        put(ws,r,2,tf); put(ws,r,4,dtype); put(ws,r,5,log_name); r += 1
    # FINAL FILTER — UNION ALL
    union_expr = ('\nUNION ALL\n'.join(f"SELECT * FROM {leg['alias']}" for leg in legs)
                  if len(legs) > 1 else None)
    r = write_final_filter(ws, tmpl_ws, r, union_expr=union_expr)
    return r


# ── Unpivot / LATERAL VIEW (Electronic Address, Postal Address) ───────────────

def write_unpivot_sheet(ws, tmpl_ws, entity_name, meta, sys_grp, sys_name,
                        df_bz_atr, entity_ssc_map, schema_map, tech_fields_map):
    etl_handle   = str(meta.get('technical_table_type', ''))
    atomic_table = str(meta.get('atomic_table', to_snake(entity_name)))
    description  = str(meta.get('description', ''))
    sys_grp = sys_grp.copy()
    sys_grp['_ssc'] = sys_grp['classification_context'].apply(get_ssc)
    ssc_list = list(dict.fromkeys(sys_grp['_ssc'].tolist()))
    sk_rows        = sys_grp[sys_grp['data_domain'] == 'Surrogate Key']
    ssc_attr_rows  = sys_grp[sys_grp['atomic_attribute'] == 'Source System Code']
    type_attr_rows = sys_grp[(sys_grp['data_domain'] == 'Classification Value') &
                              (sys_grp['atomic_attribute'] != 'Source System Code')]
    # Use atomic_column for physical target, atomic_attribute for logical
    ip_id_col  = sk_rows.iloc[0]['atomic_column']        if not sk_rows.empty       else 'ip_id'
    ip_id_attr = sk_rows.iloc[0]['atomic_attribute']     if not sk_rows.empty       else 'Involved Party Id'
    ssc_col    = ssc_attr_rows.iloc[0]['atomic_column']  if not ssc_attr_rows.empty else 'src_stm_code'
    ssc_attr   = ssc_attr_rows.iloc[0]['atomic_attribute'] if not ssc_attr_rows.empty else 'Source System Code'
    type_col   = type_attr_rows.iloc[0]['atomic_column'] if not type_attr_rows.empty else 'type_code'
    type_attr  = type_attr_rows.iloc[0]['atomic_attribute'] if not type_attr_rows.empty else 'Type Code'
    val_col    = 'address_value'; val_attr = 'Address Value'
    for _, vrow in sys_grp[(sys_grp['data_domain'] == 'Text') & sys_grp['ods_column'].notna()].iterrows():
        vc = str(vrow['ods_column']).strip() if pd.notna(vrow['ods_column']) else ''
        if vc and vc != 'id':
            val_col  = str(vrow['atomic_column'])
            val_attr = str(vrow['atomic_attribute'])
            break
    # ip_code physical col: the code col after the SK
    ip_code_col = 'ip_code'
    ip_code_attr = 'Involved Party Code'
    code_rows = sys_grp[(sys_grp['data_domain'] == 'Text') & (~sys_grp['is_primary_key'])]
    if not code_rows.empty:
        ip_code_col  = str(code_rows.iloc[0]['atomic_column'])
        ip_code_attr = str(code_rows.iloc[0]['atomic_attribute'])
    r = 1
    r = write_target(ws, tmpl_ws, r, atomic_table, etl_handle, description)
    copy_tmpl_row(tmpl_ws, T['input_banner'], ws, r)
    r += 1; copy_tmpl_row(tmpl_ws, T['input_header'], ws, r); r += 1
    input_seq = 1; leg_aliases = []; leg_sscs = []
    for ssc in ssc_list:
        ssc_grp = sys_grp[sys_grp['_ssc'] == ssc].copy()
        id_col, legs = detect_unpivot_legs(ssc_grp)
        if not legs: continue
        sk_row = ssc_grp[ssc_grp['data_domain'] == 'Surrogate Key']
        if not sk_row.empty:
            src_sys, src_tbl, _ = row_source_info(sk_row.iloc[0])
        else:
            src_sys, src_tbl = '', ''
        src_tbl   = src_tbl or ssc.split('_', 1)[-1]
        src_sys   = src_sys or ssc.split('_')[0]
        schema    = schema_map.get(src_sys, 'bronze') if schema_map else 'bronze'
        ods_tbl   = f"ods_{src_sys.lower()}_{src_tbl.lower()}"
        alias     = make_alias(src_tbl); leg_alias = f"leg_{alias}"
        leg_aliases.append(leg_alias); leg_sscs.append(ssc)
        val_cols    = [c for _, c in legs]
        sel_cols    = list(dict.fromkeys([id_col] + val_cols))
        blank_row(ws, r); put(ws,r,1,input_seq); input_seq+=1
        put(ws,r,2,'physical_table'); put(ws,r,3,schema)
        put(ws,r,4,ods_tbl); put(ws,r,5,alias)
        put(ws,r,6,get_select_fields(sel_cols, src_tbl, df_bz_atr))
        put(ws,r,7,'ds_snpst_dt = to_date("etl_date", \'yyyy-MM-dd\')')
        r+=1
        stack_args = ', '.join([f"'{t}', {c}" for t, c in legs])
        stack_expr = f"stack({len(legs)}, {stack_args}) AS (type_code, address_value)"
        unpivot_sel = (f"{id_col} AS ip_code, type_code, address_value\n"
                       f"LATERAL VIEW {stack_expr}")
        blank_row(ws,r); put(ws,r,1,input_seq); input_seq+=1
        put(ws,r,2,'unpivot_cte'); put(ws,r,3,'')
        put(ws,r,4,alias); put(ws,r,5,leg_alias)
        put(ws,r,6,unpivot_sel); put(ws,r,7,'address_value IS NOT NULL')
        r+=1
    copy_tmpl_row(tmpl_ws, T['rel_banner'], ws, r)
    r += 1; copy_tmpl_row(tmpl_ws, T['rel_header'], ws, r); r += 1
    blank_row(ws, r); r += 1
    copy_tmpl_row(tmpl_ws, T['map_banner'], ws, r)
    r += 1; copy_tmpl_row(tmpl_ws, T['map_header'], ws, r); r += 1
    def list_per_leg(pattern):
        if not leg_aliases: return ''
        return '; '.join(
            pattern.format(leg=leg, ssc=ssc) for leg, ssc in zip(leg_aliases, leg_sscs)
        )
    for seq, (phys_col, log_attr, pattern, dtype) in [
        (1, ip_id_col,  ip_id_attr,  "hash_id('{ssc}', {leg}.ip_code)", 'string'),
        (2, ip_code_col, ip_code_attr, '{leg}.ip_code',                  'string'),
        (3, ssc_col,    ssc_attr,    "'{ssc}'",                          'string'),
        (4, type_col,   type_attr,   '{leg}.type_code',                  'string'),
        (5, val_col,    val_attr,    '{leg}.address_value',               'string'),
    ]:
        blank_row(ws, r)
        put(ws,r,1,seq)
        put(ws,r,2,phys_col)                  # Physical Target Column
        put(ws,r,3,list_per_leg(pattern))
        put(ws,r,4,dtype)
        put(ws,r,5,log_attr)                  # Logical Target Column
        r+=1
    # Technical fields
    tech_fields = tech_fields_map.get(etl_handle, [])
    seq = 6
    for tf in tech_fields:
        log_name, dtype = TECH_FIELD_META.get(tf, ('', ''))
        blank_row(ws, r)
        put(ws,r,1,seq); seq+=1
        put(ws,r,2,tf)
        put(ws,r,4,dtype)
        put(ws,r,5,log_name)
        r+=1
    n_legs = len(leg_aliases)
    union_expr = '\nUNION ALL\n'.join(f"SELECT * FROM {leg}" for leg in leg_aliases) if n_legs > 1 else None
    r = write_final_filter(ws, tmpl_ws, r, union_expr=union_expr)
    return r


def write_shared_entity_sheet(ws, tmpl_ws, entity_name, meta, sys_grp, sys_name,
                               df_bz_atr, entity_ssc_map, schema_map, tech_fields_map):
    """Route to alt_id (direct SELECT) or unpivot (LATERAL VIEW) based on context format."""
    sample_ctx = sys_grp['classification_context'].dropna()
    is_alt_id  = not sample_ctx.empty and '|' in str(sample_ctx.iloc[0])
    fn = write_alt_id_sheet if is_alt_id else write_unpivot_sheet
    return fn(ws, tmpl_ws, entity_name, meta, sys_grp, sys_name,
              df_bz_atr, entity_ssc_map, schema_map, tech_fields_map)


def write_cv_sheet(ws, tmpl_ws, entity_name, meta, src_grp, ssc,
                   df_bz_atr, entity_ssc_map, schema_map, tech_fields_map):
    atomic_table = str(meta.get('atomic_table', to_snake(entity_name)))
    r = 1
    r = write_target(ws, tmpl_ws, r, atomic_table,
                     str(meta.get('technical_table_type', '')), str(meta.get('description', '')))
    copy_tmpl_row(tmpl_ws, T['input_banner'], ws, r)
    r += 1; copy_tmpl_row(tmpl_ws, T['input_header'], ws, r); r += 1
    blank_row(ws, r)
    put(ws, r, 2, '🚧 Classification Value — mapping pattern chưa được định nghĩa')
    r += 1
    r = write_final_filter(ws, tmpl_ws, r)
    return r


def gen_mapping(entity_filter=None, source_system_filter=None):
    if not os.path.exists(TEMPLATE):
        raise FileNotFoundError(f'Template không tìm thấy: {TEMPLATE}')

    df_atm_ent     = pd.read_csv(ATOMIC_ENT_PATH)
    df_atm_atr     = pd.read_csv(ATOMIC_ATR_PATH)
    df_bz_atr      = pd.read_csv(BRONZE_ATR_PATH)
    tmpl_ws        = load_csv_template(TEMPLATE)
    schema_map     = load_schema_map()
    tech_fields_map = load_tech_fields()
    entity_ssc_map = build_entity_ssc_map(df_atm_atr)
    mt_map         = dict(zip(df_atm_ent['atomic_entity'],
                              df_atm_ent.get('mapping_type', pd.Series('regular', index=df_atm_ent.index))))

    entities = df_atm_atr['atomic_entity'].unique()
    if entity_filter:
        ef = entity_filter if isinstance(entity_filter, list) else [entity_filter]
        entities = [e for e in entities if e in ef]

    generated = []

    for entity_name in entities:
        grp_all = df_atm_atr[df_atm_atr['atomic_entity'] == entity_name].reset_index(drop=True).copy()
        grp_all['_ssc'] = grp_all['classification_context'].apply(get_ssc)

        ent_row      = df_atm_ent[df_atm_ent['atomic_entity'] == entity_name]
        meta         = ent_row.iloc[0].to_dict() if not ent_row.empty else {}
        mapping_type = mt_map.get(entity_name, 'regular')

        entity_snake = re.sub(r'\s+', '_', entity_name.lower())

        if mapping_type == 'shared_entity':
            sys_list = list(dict.fromkeys(grp_all['source_system'].dropna().tolist()))
            if source_system_filter:
                sys_list = [s for s in sys_list if s.upper() == source_system_filter.upper()]
            for sys_name in sys_list:
                sys_grp = grp_all[grp_all['source_system'] == sys_name].reset_index(drop=True)
                out_dir = os.path.join(MAPPING_DIR, sys_name)
                os.makedirs(out_dir, exist_ok=True)
                out_path = os.path.join(out_dir, f'{entity_snake}_{sys_name.lower()}.csv')
                ws = CSVSheet()
                write_shared_entity_sheet(ws, tmpl_ws, entity_name, meta, sys_grp, sys_name,
                                          df_bz_atr, entity_ssc_map, schema_map, tech_fields_map)
                ws.save_csv(out_path)
                generated.append(out_path)
        else:
            ssc_list = list(dict.fromkeys(grp_all['_ssc'].tolist()))
            for ssc in ssc_list:
                sys_name = ssc.split('_')[0]
                if source_system_filter and sys_name.upper() != source_system_filter.upper():
                    continue
                src_grp = grp_all[grp_all['_ssc'] == ssc].drop(columns='_ssc').reset_index(drop=True)
                out_dir = os.path.join(MAPPING_DIR, sys_name)
                os.makedirs(out_dir, exist_ok=True)
                ssc_suffix = f'_{ssc.lower()}' if len(ssc_list) > 1 else ''
                out_path = os.path.join(out_dir, f'{entity_snake}{ssc_suffix}.csv')
                ws = CSVSheet()
                if mapping_type == 'regular':
                    write_regular_sheet(ws, tmpl_ws, entity_name, meta, src_grp, ssc,
                                        df_bz_atr, entity_ssc_map, schema_map, tech_fields_map)
                elif mapping_type == 'cv':
                    write_cv_sheet(ws, tmpl_ws, entity_name, meta, src_grp, ssc,
                                   df_bz_atr, entity_ssc_map, schema_map, tech_fields_map)
                ws.save_csv(out_path)
                generated.append(out_path)

    print(f"[gen_mapping] Done. {len(generated)} file(s) generated:")
    for p in generated:
        rel = os.path.relpath(p, REPO_ROOT)
        print(f"  {rel}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--entity', default=None, nargs='+')
    parser.add_argument('--source-system', default=None)
    args = parser.parse_args()
    gen_mapping(entity_filter=args.entity, source_system_filter=args.source_system)
