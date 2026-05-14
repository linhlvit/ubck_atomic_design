"""
Step 1.2 -- gen_mapping_staging
Generate Staging mapping CSV files from gm_staging_entities + gm_staging_attributes.

Usage (from repo root):
    python Mapping/scripts/gen_mapping_staging.py
    python Mapping/scripts/gen_mapping_staging.py --source-system FMS
    python Mapping/scripts/gen_mapping_staging.py --table SECURITIES

Output:
    Mapping/staging/<source_system>/stg_<ss>_<table>.csv

Rules:
    - Source: Bronze schema (Ten Schema SRC from rule_map_schema.csv)
    - Target: Staging schema (Ten Schema STG from rule_map_schema.csv)
    - ETL Handle: Incremental - Delete then Insert
    - Select Fields: * (always all columns)
    - Mapping: 1:1 column pass-through, alias.column_name
    - No technical fields appended
"""
import csv, os, sys, argparse
import pandas as pd

REPO_ROOT   = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REGISTRIES  = os.path.join(REPO_ROOT, 'Mapping', 'registries')
RULES_DIR   = os.path.join(REPO_ROOT, 'system', 'rules')
OUTPUT_BASE = os.path.join(REPO_ROOT, 'Mapping', 'staging')

ALIAS_OVERRIDES = {
    'SECBUSINES':     'se_bu',
    'FUNDCOMBUSINES': 'fu_bu',
    'FUNDCOMTYPE':    'fu_ty',
    'STFFGBRCH':      'st_br',
    'ORGANIZATIONS':  'org',
    'PROFESSIONALS':  'pro',
}


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

def make_alias(table_name: str) -> str:
    if table_name in ALIAS_OVERRIDES:
        return ALIAS_OVERRIDES[table_name]
    if '_' in table_name:
        parts = table_name.split('_')
        return '_'.join(p[:2].lower() for p in parts if p)
    try:
        import wordninja
        words = wordninja.split(table_name.lower())
    except ImportError:
        words = [table_name.lower()]
    segments, buf = [], ''
    for w in words:
        buf += w
        if len(buf) >= 4:
            segments.append(buf[:2])
            buf = ''
    if buf:
        segments.append(buf[:2])
    return '_'.join(segments) if segments else table_name[:2].lower()


def _load_schema_map():
    """Load rule_map_schema.csv by column position (tolerates Vietnamese headers)."""
    path = os.path.join(RULES_DIR, 'rule_map_schema.csv')
    df = pd.read_csv(path)
    result = {}
    for _, row in df.iterrows():
        key = str(row.iloc[0]).strip()
        result[key] = {
            'src': str(row.iloc[1]).strip() if len(df.columns) > 1 else '',
            'stg': str(row.iloc[3]).strip() if len(df.columns) > 3 else '',
        }
    return result


def write_staging_mapping(entity_row, attributes, schema_map, out_path):
    source_system   = entity_row['source_system']
    table_name      = entity_row['table_name']
    staging_table   = entity_row['staging_table']
    etl_handle      = entity_row['etl_handle']
    raw_filter      = entity_row.get('filter', '')
    input_filter    = '' if pd.isna(raw_filter) else str(raw_filter).strip()
    description     = str(entity_row.get('description', '')).strip()

    schemas     = schema_map.get(source_system, {})
    src_schema  = schemas.get('src', 'bronze')
    stg_schema  = schemas.get('stg', 'staging')

    alias = make_alias(table_name)

    rows = []

    # TARGET section
    rows.append(['Target', 'Bang dich', '', '', '', '', '', '', '', '', ''])
    rows.append(['Database', 'Schema', 'Table Name', 'ETL Handle', '', '', '',
                 'Description', 'Last update', 'Update by', 'Update reason'])
    rows.append(['', stg_schema, staging_table, etl_handle, '', '', '',
                 description, '', '', ''])

    # INPUT section
    rows.append(['Input', 'Bang / CTE nguon', '', '', '', '', '', '', '', '', ''])
    rows.append(['#', 'Source Type', 'Schema', 'Table Name', 'Alias',
                 'Select Fields', 'Filter', 'Description', 'Last update', 'Update by', 'Update reason'])
    rows.append(['1', 'physical_table', src_schema, table_name, alias,
                 '*', input_filter, '', '', '', ''])

    # RELATIONSHIP section
    rows.append(['Relationship', 'Quan he giua cac bang / CTE nguon', '', '', '', '', '', '', '', '', ''])
    rows.append(['#', 'Main Alias', 'Join Type', 'Join Alias', 'Join On',
                 '', '', 'Description', 'Last update', 'Update by', 'Update reason'])
    rows.append(['', '', '', '', '', '', '', '', '', '', ''])

    # MAPPING section
    rows.append(['Mapping', 'Mapping truong nguon -> truong dich', '', '', '', '', '', '', '', '', ''])
    rows.append(['#', 'Physical Target Column', 'Transformation', 'Data Type',
                 'Logical Target Column', '', '', 'Description', 'Last update', 'Update by', 'Update reason'])

    for idx, (_, atr) in enumerate(attributes.iterrows(), start=1):
        col  = str(atr['column_name']).strip()
        raw_dtype = atr.get('data_type', '')
        dtype = '' if pd.isna(raw_dtype) else str(raw_dtype).strip()
        raw_desc = atr.get('description', '')
        desc  = '' if pd.isna(raw_desc) else str(raw_desc).strip()
        transf = f'HEX({alias}.{col})' if col.endswith('ID') else f'{alias}.{col}'
        rows.append([str(idx), col.lower(), transf, dtype, '', '', '', desc, '', '', ''])

    # Technical fields
    tech_idx = len(attributes) + 1
    rows.append([str(tech_idx), 'ds_snpst_dt', "to_date(\"etl_date\", 'yyyy-MM-dd')", 'date',
                 '', '', '', 'Ngày dữ liệu', '', '', ''])
    tech_idx += 1
    rows.append([str(tech_idx), 'ds_etl_pcs_tms', 'current_timestamp()', 'timestamp',
                 '', '', '', 'Thời điểm xử lý ETL', '', '', ''])

    # FINAL FILTER section
    rows.append(['Final Filter', 'Dieu kien loc cua Main Transform', '', '', '', '', '', '', '', '', ''])
    rows.append(['#', 'Clause Type', 'Expression', '', '', '', '',
                 'Description', 'Last update', 'Update by', 'Update reason'])
    rows.append(['', '', '', '', '', '', '', '', '', '', ''])

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, 'w', newline='', encoding='utf-8-sig') as f:
        csv.writer(f).writerows(rows)

    print(f'  -> {out_path}')


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def gen_mapping_staging(source_system_filter=None, table_filter=None):
    stg_ent_path = os.path.join(REGISTRIES, 'gm_staging_entities.csv')
    stg_atr_path = os.path.join(REGISTRIES, 'gm_staging_attributes.csv')

    df_ent = pd.read_csv(stg_ent_path)
    df_atr = pd.read_csv(stg_atr_path)

    schema_map = _load_schema_map()

    if source_system_filter:
        df_ent = df_ent[df_ent['source_system'] == source_system_filter.upper()]
    if table_filter:
        tbls = [t.upper() for t in (table_filter if isinstance(table_filter, list) else [table_filter])]
        df_ent = df_ent[df_ent['table_name'].isin(tbls)]

    total = 0
    for _, ent_row in df_ent.iterrows():
        ss    = ent_row['source_system']
        tbl   = ent_row['table_name']
        attrs = df_atr[
            (df_atr['source_system'] == ss) & (df_atr['table_name'] == tbl)
        ].copy()

        staging_table = str(ent_row['staging_table']).strip()
        out_path = os.path.join(OUTPUT_BASE, ss, f'{staging_table}.csv')

        write_staging_mapping(ent_row, attrs, schema_map, out_path)
        total += 1

    print(f'[gen_mapping_staging] {total} file(s) generated.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--source-system', default=None)
    parser.add_argument('--table', default=None, nargs='+')
    args = parser.parse_args()
    gen_mapping_staging(
        source_system_filter=args.source_system,
        table_filter=args.table,
    )
