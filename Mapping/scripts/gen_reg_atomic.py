"""
Step 2 — gen_reg_atomic
Enrich atomic_entities and atomic_attributes; output to Mapping/registries/.

Usage (from repo root):
    python Mapping/scripts/gen_reg_atomic.py

Reads from:
    Atomic/hld/atomic_entities.csv
    Atomic/lld/atomic_attributes.csv
    system/rules/rule_map_technical_table_type.csv  (or .xlsx)

Writes to:
    Mapping/registries/gm_atomic_entities.csv
    Mapping/registries/gm_atomic_attributes.csv
"""
import pandas as pd, re, os

REPO_ROOT   = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ATOMIC_HLD  = os.path.join(REPO_ROOT, 'Atomic', 'hld')
ATOMIC_LLD  = os.path.join(REPO_ROOT, 'Atomic', 'lld')
RULES_DIR   = os.path.join(REPO_ROOT, 'system', 'rules')
OUTPUT_DIR  = os.path.join(REPO_ROOT, 'Mapping', 'registries')


def read_any(path):
    return pd.read_csv(path) if path.endswith('.csv') else pd.read_excel(path)


def resolve(directory, stem):
    for ext in ('.csv', '.xlsx'):
        p = os.path.join(directory, stem + ext)
        if os.path.exists(p): return p
    raise FileNotFoundError(f'Không tìm thấy {stem}.csv/.xlsx trong {directory}')


def insert_col_after(df, after_col, new_col, values):
    df = df.copy(); df[new_col] = values
    idx = df.columns.get_loc(after_col) + 1
    cols = list(df.columns); cols.remove(new_col); cols.insert(idx, new_col)
    return df[cols]


def _ods_from_entity_source(source_table):
    """'SS.TABLE, SS2.TABLE2' → 'ods_ss_table, ods_ss2_table2'."""
    if not source_table or (isinstance(source_table, float)):
        return ''
    result = []
    for part in str(source_table).split(','):
        segs = part.strip().split('.')
        if len(segs) >= 2:
            result.append(f'ods_{segs[0].lower()}_{segs[1].lower()}')
    return ', '.join(result)


def _ods_table_from_attr(source_system, source_table):
    """source_system='FIMS', source_table='AUTHOANNOUNCE' → 'ods_fims_authoannounce'."""
    if not source_table or (isinstance(source_table, float)) or str(source_table).strip() == '':
        return ''
    return f'ods_{str(source_system).lower()}_{str(source_table).lower()}'


def _ods_col_from_source(source_column):
    """'FIMS.AUTHOANNOUNCE.id' → 'id' (column name only, lowercase)."""
    if not source_column or (isinstance(source_column, float)) or str(source_column).strip() == '':
        return ''
    parts = str(source_column).strip().split('.')
    return parts[-1].lower() if len(parts) >= 2 else str(source_column).strip().lower()


def derive_mapping_type(row):
    if str(row.get('bcv_concept', '')).strip() == 'Shared Entity':
        return 'shared_entity'
    if str(row.get('table_type', '')).strip() == 'Classification':
        return 'cv'
    return 'regular'


def gen_atomic():
    atomic_entity_path  = os.path.join(ATOMIC_HLD, 'atomic_entities.csv')
    atomic_atr_path     = os.path.join(ATOMIC_LLD, 'atomic_attributes.csv')
    rule_tbl_type_path  = resolve(RULES_DIR, 'rule_map_technical_table_type')

    for p in [atomic_entity_path, atomic_atr_path]:
        if not os.path.exists(p):
            raise FileNotFoundError(f'Không tìm thấy: {p}')

    # ── gm_atomic_entities ────────────────────────────────────────────────────
    df_ent      = read_any(atomic_entity_path)
    df_tbl_rule = read_any(rule_tbl_type_path)
    tbl_type_map = dict(zip(df_tbl_rule['Model Table Type'].str.strip(),
                            df_tbl_rule['Technical Table Type'].str.strip()))

    # Load attributes to extract atomic_table per entity
    df_atr = read_any(atomic_atr_path)
    atomic_table_map = df_atr.groupby('atomic_entity')['atomic_table'].first().to_dict()

    mapping_types = df_ent.apply(derive_mapping_type, axis=1)
    drop_cols = [c for c in df_ent.columns if c in ['bcv_core_object', 'bcv_concept', 'status']]
    df_ent = df_ent.drop(columns=drop_cols)

    # Insert atomic_table after atomic_entity
    df_ent['atomic_table'] = df_ent['atomic_entity'].map(atomic_table_map).fillna('')
    df_ent = insert_col_after(df_ent, 'atomic_entity', 'atomic_table',
                              df_ent.pop('atomic_table'))

    tech_types = df_ent['table_type'].map(tbl_type_map).fillna('')
    df_out_ent = insert_col_after(df_ent, 'table_type', 'technical_table_type', tech_types)
    df_out_ent = insert_col_after(df_out_ent, 'technical_table_type', 'filter', '')
    df_out_ent = insert_col_after(df_out_ent, 'filter', 'mapping_type', mapping_types)

    # Rename source_table → ods_table in entities output
    if 'source_table' in df_out_ent.columns:
        df_out_ent = df_out_ent.rename(columns={'source_table': 'ods_table'})
        df_out_ent['ods_table'] = df_out_ent['ods_table'].apply(_ods_from_entity_source)

    # ── gm_atomic_attributes ─────────────────────────────────────────────────
    df_out_atr = df_atr.copy()
    if 'source_table' in df_out_atr.columns:
        df_out_atr['ods_table'] = df_out_atr.apply(
            lambda r: _ods_table_from_attr(r['source_system'], r['source_table']), axis=1
        )
        df_out_atr = df_out_atr.drop(columns=['source_table'])
        # Reinsert at the same position source_table was
        cols = list(df_out_atr.columns)
        cols.remove('ods_table')
        src_sys_idx = cols.index('source_system') + 1
        cols.insert(src_sys_idx, 'ods_table')
        df_out_atr = df_out_atr[cols]
    if 'source_column' in df_out_atr.columns:
        df_out_atr['ods_column'] = df_out_atr['source_column'].apply(_ods_col_from_source)
        df_out_atr = df_out_atr.drop(columns=['source_column'])
        cols = list(df_out_atr.columns)
        cols.remove('ods_column')
        ods_tbl_idx = cols.index('ods_table') + 1
        cols.insert(ods_tbl_idx, 'ods_column')
        df_out_atr = df_out_atr[cols]

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    out_ent = os.path.join(OUTPUT_DIR, 'gm_atomic_entities.csv')
    out_atr = os.path.join(OUTPUT_DIR, 'gm_atomic_attributes.csv')
    df_out_ent.to_csv(out_ent, index=False)
    df_out_atr.to_csv(out_atr, index=False)

    unmapped = df_ent[~df_ent['table_type'].isin(tbl_type_map)]['table_type'].unique()
    mt_dist  = df_out_ent['mapping_type'].value_counts().to_dict()
    print(f"[gen_atomic] Reads from repo root:")
    print(f"[gen_atomic]   Atomic/hld/atomic_entities.csv")
    print(f"[gen_atomic]   Atomic/lld/atomic_attributes.csv")
    print(f"[gen_atomic] gm_atomic_entities   : {len(df_out_ent)} rows -> {out_ent}")
    print(f"[gen_atomic]   mapping_type       : {mt_dist}")
    print(f"[gen_atomic] gm_atomic_attributes : {len(df_out_atr)} rows -> {out_atr}")
    if len(unmapped):
        print(f"[gen_atomic]   WARN table_type chua co rule: {list(unmapped)}")


if __name__ == '__main__':
    gen_atomic()
