"""
Step 3 — gen_mapping_silver
Routes by mapping_type:
  regular       : 1 SSC = 1 sheet → 1 file per entity per source system
  shared_entity : 1 source_system = 1 sheet (unpivot_cte pattern)
  cv            : placeholder

Usage (from repo root):
    python Mapping/scripts/gen_mapping_silver.py
    python Mapping/scripts/gen_mapping_silver.py --entity "Fund Management Company"
    python Mapping/scripts/gen_mapping_silver.py --source-system FMS

Reads from:
    Mapping/registries/gm_silver_entities.csv
    Mapping/registries/gm_silver_attributes.csv
    Mapping/registries/gm_bronze_attributes.csv
    system/templates/mapping_template.csv

Writes to:
    Mapping/silver/<source_system>/<entity_snake>.csv
"""
import csv, pandas as pd, re, os, sys, argparse, wordninja

REPO_ROOT    = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REGISTRY_DIR = os.path.join(REPO_ROOT, 'Mapping', 'registries')
MAPPING_DIR  = os.path.join(REPO_ROOT, 'Mapping', 'silver')
TEMPLATE     = os.path.join(REPO_ROOT, 'system', 'templates', 'mapping_template.csv')

SILVER_ENT_PATH = os.path.join(REGISTRY_DIR, 'gm_silver_entities.csv')
SILVER_ATR_PATH = os.path.join(REGISTRY_DIR, 'gm_silver_attributes.csv')
BRONZE_ATR_PATH = os.path.join(REGISTRY_DIR, 'gm_bronze_attributes.csv')

NUM_COLS = 11

# ── CSV-based sheet abstraction ──────────────────────────────────────────────

class CSVSheet:
    """Minimal worksheet abstraction that stores cells in a dict and dumps to CSV."""
    def __init__(self, num_cols=NUM_COLS):
        self._cells = {}          # (row, col) -> value
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
    """Load CSV template into a CSVSheet (1-indexed rows/cols)."""
    ws = CSVSheet()
    with open(path, 'r', encoding='utf-8-sig') as f:
        reader = csv.reader(f)
        for r_idx, row in enumerate(reader, start=1):
            for c_idx, val in enumerate(row, start=1):
                if val:
                    ws.set(r_idx, c_idx, val)
    return ws


# ── Primitives that mirror the old openpyxl helpers ──────────────────────────

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
def get_ssc(ctx):
    m = re.search(r"'([^']+)'", str(ctx)); return m.group(1) if m else 'UNKNOWN'

COL_TO_TYPE = {
    'email':'EMAIL','fax':'FAX','telephone':'PHONE','website':'WEBSITE',
    'mobilenumber':'MOBILE','phonenumber':'PHONE',
    'email_kd':'EMAIL','fax_kd':'FAX','dien_thoai_kd':'PHONE','dien_thoai':'PHONE',
    'dia_chi':'ADDRESS','dia_chi_tsc':'HEAD_OFFICE','mota_diachi_kd':'BUSINESS',
}
def col_to_type(col): return COL_TO_TYPE.get(col.lower(), col.upper().replace('_',' '))

def get_source_tables(grp):
    ordered, seen, info = [], set(), {}
    for _, row in grp.iterrows():
        raw = str(row['source_column']) if pd.notna(row['source_column']) else ''
        domain = str(row['data_domain'])
        _, tbl, col = parse_source_col(raw)
        if not tbl: continue
        if tbl not in seen:
            ordered.append(tbl); seen.add(tbl)
            info[tbl] = {'cols': [], 'array_attrs': []}
        if col and col not in info[tbl]['cols']: info[tbl]['cols'].append(col)
        if domain == 'Array<Text>' and col:
            info[tbl]['array_attrs'].append({'attr_name': str(row['silver_attribute']),
                'col_name': col, 'snake_name': to_snake(str(row['silver_attribute']))})
    return [{'table_name': t, 'alias': make_alias(t),
             'cols': info[t]['cols'], 'array_attrs': info[t]['array_attrs']} for t in ordered]

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
    for entity, grp in df_atr.groupby('silver_entity'):
        rows = grp[(grp['data_domain'] == 'Classification Value') &
                   grp['comment'].astype(str).str.contains('SOURCE_SYSTEM', na=False)]
        if not rows.empty:
            val = extract_quoted(str(rows.iloc[0]['classification_context']))
            if val: ssc_map[entity] = val
    return ssc_map

def detect_unpivot_legs(ssc_grp):
    sk_rows = ssc_grp[ssc_grp['data_domain'] == 'Surrogate Key']
    id_raw  = sk_rows.iloc[0]['source_column'] if not sk_rows.empty else ''
    _, _, id_col = parse_source_col(str(id_raw))
    id_col = id_col or 'id'
    text_rows = ssc_grp[(ssc_grp['data_domain'] == 'Text') &
                         ssc_grp['source_column'].notna() &
                         (ssc_grp['source_column'].astype(str) != 'nan')]
    legs = []
    for _, row in text_rows.iterrows():
        _, _, val_col = parse_source_col(str(row['source_column']))
        if val_col and val_col != id_col:
            legs.append((col_to_type(val_col), val_col))
    return id_col, legs

def make_unpivot_select(id_col, legs, passthrough=None):
    parts = [f"ip_code={id_col}"] + [f"{t}:{c}" for t, c in legs]
    if passthrough: parts += passthrough
    return ' | '.join(parts)

def get_transformation(row, source_tables, pk_code_col, own_ssc, entity_ssc_map):
    domain  = str(row['data_domain'])
    comment = str(row['comment'])  if pd.notna(row['comment'])  else ''
    col_raw = str(row['source_column']) if pd.notna(row['source_column']) else ''
    attr    = str(row['silver_attribute'])
    ctx     = str(row['classification_context']) if pd.notna(row['classification_context']) else ''
    _, src_tbl, col = parse_source_col(col_raw)
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
        return (f"{alias}.{to_snake(attr)}", '') if (alias and col) else ('', '')
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

def write_target(ws, tmpl_ws, r, entity_name, etl_handle, description):
    copy_tmpl_row(tmpl_ws, T['target_banner'], ws, r)
    r += 1; copy_tmpl_row(tmpl_ws, T['target_header'], ws, r)
    r += 1; blank_row(ws, r)
    put(ws, r, 2, 'silver'); put(ws, r, 3, entity_name)
    put(ws, r, 4, etl_handle); put(ws, r, 8, description)
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

def write_regular_sheet(ws, tmpl_ws, entity_name, meta, src_grp, ssc, df_bz_atr, entity_ssc_map):
    src_full     = str(meta.get('source_table', ''))
    source_table = src_full.split(',')[0].strip().split('.')[-1].upper()
    etl_handle   = str(meta.get('technical_table_type', ''))
    description  = str(meta.get('description', ''))
    own_ssc      = ssc
    source_tables = get_source_tables(src_grp)
    if not source_tables:
        source_tables = [{'table_name': source_table, 'alias': make_alias(source_table),
                          'cols': [], 'array_attrs': []}]
    primary = source_tables[0]
    pk_code_col = {}
    pk_rows = src_grp[(src_grp['data_domain'] == 'Surrogate Key') & src_grp['is_primary_key']]
    for _, pk_row in pk_rows.iterrows():
        nxt = src_grp[(src_grp.index > pk_row.name) &
                      (src_grp['data_domain'] == 'Text') & (~src_grp['is_primary_key'])]
        if not nxt.empty:
            _, _, code_col = parse_source_col(
                str(nxt.iloc[0]['source_column']) if pd.notna(nxt.iloc[0]['source_column']) else '')
            pk_code_col[pk_row['silver_attribute']] = code_col or '??'
    r = 1
    r = write_target(ws, tmpl_ws, r, entity_name, etl_handle, description)
    copy_tmpl_row(tmpl_ws, T['input_banner'], ws, r)
    r += 1; copy_tmpl_row(tmpl_ws, T['input_header'], ws, r); r += 1
    join_info = {}; input_seq = 1
    for tbl_info in source_tables:
        tbl = tbl_info['table_name']; alias = tbl_info['alias']
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
            put(ws,r,2,'physical_table'); put(ws,r,3,'bronze'); put(ws,r,4,tbl)
            put(ws,r,5,raw_alias); put(ws,r,6,', '.join(cols))
            put(ws,r,7,"data_date = to_date('{{ var(\"etl_date\") }}', 'yyyy-MM-dd')")
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
            put(ws,r,2,'physical_table'); put(ws,r,3,'bronze'); put(ws,r,4,tbl)
            put(ws,r,5,alias); put(ws,r,6,', '.join(cols))
            put(ws,r,7,"data_date = to_date('{{ var(\"etl_date\") }}', 'yyyy-MM-dd')")
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
    for seq, (_, atr) in enumerate(src_grp.iterrows(), start=1):
        transf, _ = get_transformation(atr, source_tables, pk_code_col, own_ssc, entity_ssc_map)
        blank_row(ws, r)
        put(ws,r,1,seq); put(ws,r,2,to_snake(str(atr['silver_attribute'])))
        put(ws,r,3,transf); put(ws,r,4,str(atr.get('silver_data_type','')))
        put(ws,r,8,str(atr['description']) if pd.notna(atr['description']) else '')
        r+=1
    r = write_final_filter(ws, tmpl_ws, r)
    return r

def write_shared_entity_sheet(ws, tmpl_ws, entity_name, meta, sys_grp, sys_name, df_bz_atr, entity_ssc_map):
    etl_handle  = str(meta.get('technical_table_type', ''))
    description = str(meta.get('description', ''))
    sys_grp = sys_grp.copy()
    sys_grp['_ssc'] = sys_grp['classification_context'].apply(get_ssc)
    ssc_list = list(dict.fromkeys(sys_grp['_ssc'].tolist()))
    sk_rows       = sys_grp[sys_grp['data_domain'] == 'Surrogate Key']
    ssc_attr_rows = sys_grp[sys_grp['silver_attribute'] == 'Source System Code']
    type_attr_rows = sys_grp[(sys_grp['data_domain'] == 'Classification Value') &
                              (sys_grp['silver_attribute'] != 'Source System Code')]
    ip_id_attr = to_snake(sk_rows.iloc[0]['silver_attribute'])       if not sk_rows.empty       else 'involved_party_id'
    ssc_attr   = to_snake(ssc_attr_rows.iloc[0]['silver_attribute']) if not ssc_attr_rows.empty else 'source_system_code'
    type_attr  = to_snake(type_attr_rows.iloc[0]['silver_attribute'])if not type_attr_rows.empty else 'type_code'
    val_attr = 'address_value'
    for _, vrow in sys_grp[(sys_grp['data_domain'] == 'Text') & sys_grp['source_column'].notna()].iterrows():
        _, _, vc = parse_source_col(str(vrow['source_column']))
        if vc and vc != 'id': val_attr = to_snake(vrow['silver_attribute']); break
    r = 1
    r = write_target(ws, tmpl_ws, r, entity_name, etl_handle, description)
    copy_tmpl_row(tmpl_ws, T['input_banner'], ws, r)
    r += 1; copy_tmpl_row(tmpl_ws, T['input_header'], ws, r); r += 1
    input_seq = 1; leg_aliases = []; leg_sscs = []
    for ssc in ssc_list:
        ssc_grp = sys_grp[sys_grp['_ssc'] == ssc].copy()
        id_col, legs = detect_unpivot_legs(ssc_grp)
        if not legs: continue
        sk_row = ssc_grp[ssc_grp['data_domain'] == 'Surrogate Key']
        id_raw = sk_row.iloc[0]['source_column'] if not sk_row.empty else ''
        _, src_tbl, _ = parse_source_col(str(id_raw))
        src_tbl   = src_tbl or ssc.split('_', 1)[-1]
        alias     = make_alias(src_tbl); leg_alias = f"leg_{alias}"
        leg_aliases.append(leg_alias); leg_sscs.append(ssc)
        val_cols    = [c for _, c in legs]
        select_phys = ', '.join([id_col] + val_cols)
        blank_row(ws, r); put(ws,r,1,input_seq); input_seq+=1
        put(ws,r,2,'physical_table'); put(ws,r,3,'bronze')
        put(ws,r,4,src_tbl); put(ws,r,5,alias); put(ws,r,6,select_phys)
        put(ws,r,7,"data_date = to_date('{{ var(\"etl_date\") }}', 'yyyy-MM-dd')")
        r+=1
        # LATERAL VIEW stack(N, 'TYPE1', col1, 'TYPE2', col2, ...) lv AS type_code, address_value
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
    # Mỗi target column liệt kê expression cho từng leg, ngăn cách bằng ";"
    # source_system_code: literal SSC fix per leg (như regular table)
    def list_per_leg(pattern):
        if not leg_aliases: return ''
        return '; '.join(
            pattern.format(leg=leg, ssc=ssc) for leg, ssc in zip(leg_aliases, leg_sscs)
        )
    for seq, tgt, pattern, dtype in [
        (1, ip_id_attr,            "hash_id('{ssc}', {leg}.ip_code)", 'string'),
        (2, 'involved_party_code', '{leg}.ip_code',                   'string'),
        (3, ssc_attr,              "'{ssc}'",                         'string'),
        (4, type_attr,             '{leg}.type_code',                 'string'),
        (5, val_attr,              '{leg}.address_value',             'string'),
    ]:
        blank_row(ws, r)
        put(ws,r,1,seq); put(ws,r,2,tgt); put(ws,r,3,list_per_leg(pattern)); put(ws,r,4,dtype)
        r+=1
    n_legs = len(leg_aliases)
    union_expr = '\nUNION ALL\n'.join(f"SELECT * FROM {leg}" for leg in leg_aliases) if n_legs > 1 else None
    r = write_final_filter(ws, tmpl_ws, r, union_expr=union_expr)
    return r

def write_cv_sheet(ws, tmpl_ws, entity_name, meta, src_grp, ssc, df_bz_atr, entity_ssc_map):
    r = 1
    r = write_target(ws, tmpl_ws, r, entity_name,
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

    df_sil_ent     = pd.read_csv(SILVER_ENT_PATH)
    df_sil_atr     = pd.read_csv(SILVER_ATR_PATH)
    df_bz_atr      = pd.read_csv(BRONZE_ATR_PATH)
    tmpl_ws        = load_csv_template(TEMPLATE)
    entity_ssc_map = build_entity_ssc_map(df_sil_atr)
    mt_map         = dict(zip(df_sil_ent['silver_entity'],
                              df_sil_ent.get('mapping_type', pd.Series('regular', index=df_sil_ent.index))))

    entities = df_sil_atr['silver_entity'].unique()
    if entity_filter: entities = [e for e in entities if e == entity_filter]

    generated = []

    for entity_name in entities:
        grp_all = df_sil_atr[df_sil_atr['silver_entity'] == entity_name].reset_index(drop=True).copy()
        grp_all['_ssc'] = grp_all['classification_context'].apply(get_ssc)

        ent_row      = df_sil_ent[df_sil_ent['silver_entity'] == entity_name]
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
                out_path = os.path.join(out_dir, f'{entity_snake}_{sys_name}.csv')
                ws = CSVSheet()
                write_shared_entity_sheet(ws, tmpl_ws, entity_name, meta, sys_grp, sys_name,
                                          df_bz_atr, entity_ssc_map)
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
                ssc_suffix = f'_{ssc}' if len(ssc_list) > 1 else ''
                out_path = os.path.join(out_dir, f'{entity_snake}{ssc_suffix}.csv')
                ws = CSVSheet()
                if mapping_type == 'regular':
                    write_regular_sheet(ws, tmpl_ws, entity_name, meta, src_grp, ssc,
                                        df_bz_atr, entity_ssc_map)
                elif mapping_type == 'cv':
                    write_cv_sheet(ws, tmpl_ws, entity_name, meta, src_grp, ssc,
                                   df_bz_atr, entity_ssc_map)
                ws.save_csv(out_path)
                generated.append(out_path)

    print(f"[gen_mapping] Done. {len(generated)} file(s) generated:")
    for p in generated:
        rel = os.path.relpath(p, REPO_ROOT)
        print(f"  {rel}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--entity', default=None)
    parser.add_argument('--source-system', default=None)
    args = parser.parse_args()
    gen_mapping(entity_filter=args.entity, source_system_filter=args.source_system)
