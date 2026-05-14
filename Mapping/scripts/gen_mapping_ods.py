"""
Step 2.2 -- gen_mapping_ods
Generate ODS mapping CSV files from gm_ods_entities + gm_ods_attributes.

Usage (from repo root):
    python Mapping/scripts/gen_mapping_ods.py
    python Mapping/scripts/gen_mapping_ods.py --source-system FMS
    python Mapping/scripts/gen_mapping_ods.py --table SECURITIES

Output:
    Mapping/ods/<source_system>/ods_<ss>_<table>.csv

Rules:
    - Source: staging table (Tên Schema STG from rule_map_schema.csv)
    - Target: ODS table    (Tên Schema ODS from rule_map_schema.csv)
    - ETL Handle: Incremental - Append
    - Mapping: 1:1 pass-through, alias.column (all lowercase)
    - column_name from gm_ods_attributes is already lowercase
    - ds_snpst_dt and ds_etl_pcs_tms appended explicitly after regular attributes
"""
import csv, os, argparse
import pandas as pd

REPO_ROOT   = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REGISTRIES  = os.path.join(REPO_ROOT, 'Mapping', 'registries')
RULES_DIR   = os.path.join(REPO_ROOT, 'system', 'rules')
OUTPUT_BASE = os.path.join(REPO_ROOT, 'Mapping', 'ods')

ALIAS_OVERRIDES = {
    'SECBUSINES':     'se_bu',
    'FUNDCOMBUSINES': 'fu_bu',
    'FUNDCOMTYPE':    'fu_ty',
    'STFFGBRCH':      'st_br',
    'ORGANIZATIONS':  'org',
    'PROFESSIONALS':  'pro',
}

TECH_FIELD_DESC = {
    'ds_snpst_dt':     'Ngày dữ liệu',
    'ds_etl_pcs_tms':  'Thời gian xử lý ETL',
    'ds_rcrd_st':      'Trạng thái bản ghi trên Atomic (ACTIVE / INACTIVE)',
    'ds_rcrd_eff_dt':  'Ngày hiệu lực của bản ghi',
    'ds_rcrd_end_dt':  'Ngày hết hiệu lực của bản ghi',
    'ds_rcrd_isrt_dt': 'Thời điểm ETL insert bản ghi vào Atomic lần đầu',
    'ds_rcrd_udt_dt':  'Thời điểm ETL cập nhật bản ghi gần nhất',
}


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

def make_alias(table_key: str) -> str:
    """Derive short alias from table name (uppercase key for override lookup)."""
    upper = table_key.upper()
    if upper in ALIAS_OVERRIDES:
        return ALIAS_OVERRIDES[upper]
    if '_' in table_key:
        parts = table_key.split('_')
        return '_'.join(p[:2].lower() for p in parts if p)
    try:
        import wordninja
        words = wordninja.split(table_key.lower())
    except ImportError:
        words = [table_key.lower()]
    segments, buf = [], ''
    for w in words:
        buf += w
        if len(buf) >= 4:
            segments.append(buf[:2])
            buf = ''
    if buf:
        segments.append(buf[:2])
    return '_'.join(segments) if segments else table_key[:2].lower()


def _extract_table_key(staging_table: str, source_system: str) -> str:
    """'stg_fms_securities' → 'SECURITIES' (for alias override lookup)."""
    prefix = f'stg_{source_system.lower()}_'
    key = staging_table[len(prefix):] if staging_table.startswith(prefix) else staging_table
    return key.upper()


def _load_schema_map():
    path = os.path.join(RULES_DIR, 'rule_map_schema.csv')
    df   = pd.read_csv(path)
    cols = list(df.columns)
    result = {}
    for _, row in df.iterrows():
        key = str(row.iloc[0]).strip()
        result[key] = {
            'stg': str(row.iloc[3]).strip() if len(cols) > 3 else '',
            'ods': str(row.iloc[5]).strip() if len(cols) > 5 else '',
        }
    return result


def write_ods_mapping(entity_row, attributes, schema_map, out_path):
    source_system = entity_row['source_system']
    staging_table = str(entity_row['staging_table']).strip()
    ods_table     = str(entity_row['ods_table']).strip()
    etl_handle    = entity_row['etl_handle']
    raw_filter    = entity_row.get('filter', '')
    input_filter  = '' if pd.isna(raw_filter) else str(raw_filter).strip()
    description   = str(entity_row.get('description', '')).strip()

    schemas    = schema_map.get(source_system, {})
    stg_schema = schemas.get('stg', 'staging')
    ods_schema = schemas.get('ods', 'ods')

    table_key = _extract_table_key(staging_table, source_system)
    alias     = make_alias(table_key)

    rows = []

    # TARGET
    rows.append(['Target', 'Bang dich', '', '', '', '', '', '', '', '', ''])
    rows.append(['Database', 'Schema', 'Table Name', 'ETL Handle', '', '', '',
                 'Description', 'Last update', 'Update by', 'Update reason'])
    rows.append(['', ods_schema, ods_table, etl_handle, '', '', '', description, '', '', ''])

    # INPUT
    rows.append(['Input', 'Bang / CTE nguon', '', '', '', '', '', '', '', '', ''])
    rows.append(['#', 'Source Type', 'Schema', 'Table Name', 'Alias',
                 'Select Fields', 'Filter', 'Description', 'Last update', 'Update by', 'Update reason'])
    rows.append(['1', 'physical_table', stg_schema, staging_table, alias,
                 '*', input_filter, '', '', '', ''])

    # RELATIONSHIP
    rows.append(['Relationship', 'Quan he giua cac bang / CTE nguon', '', '', '', '', '', '', '', '', ''])
    rows.append(['#', 'Main Alias', 'Join Type', 'Join Alias', 'Join On',
                 '', '', 'Description', 'Last update', 'Update by', 'Update reason'])
    rows.append(['', '', '', '', '', '', '', '', '', '', ''])

    # MAPPING
    rows.append(['Mapping', 'Mapping truong nguon -> truong dich', '', '', '', '', '', '', '', '', ''])
    rows.append(['#', 'Physical Target Column', 'Transformation', 'Data Type',
                 'Logical Target Column', '', '', 'Description', 'Last update', 'Update by', 'Update reason'])

    for idx, (_, atr) in enumerate(attributes.iterrows(), start=1):
        col   = str(atr['column_name']).strip()
        dtype = '' if pd.isna(atr.get('data_type', '')) else str(atr['data_type']).strip()
        desc  = TECH_FIELD_DESC.get(col) or ('' if pd.isna(atr.get('description', '')) else str(atr['description']).strip())
        transf = f'{alias}.{col}'
        rows.append([str(idx), col, transf, dtype, '', '', '', desc, '', '', ''])

    # Technical fields — appended explicitly regardless of gm_ registry
    base_idx = len(attributes) + 1
    rows.append([str(base_idx),     'ds_snpst_dt',    "to_date(\"etl_date\", 'yyyy-MM-dd')", 'date',      '', '', '', TECH_FIELD_DESC['ds_snpst_dt'],    '', '', ''])
    rows.append([str(base_idx + 1), 'ds_etl_pcs_tms', 'current_timestamp()',                 'timestamp', '', '', '', TECH_FIELD_DESC['ds_etl_pcs_tms'], '', '', ''])

    # FINAL FILTER
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

def gen_mapping_ods(source_system_filter=None, table_filter=None):
    ods_ent_path = os.path.join(REGISTRIES, 'gm_ods_entities.csv')
    ods_atr_path = os.path.join(REGISTRIES, 'gm_ods_attributes.csv')

    df_ent = pd.read_csv(ods_ent_path)
    df_atr = pd.read_csv(ods_atr_path)
    schema_map = _load_schema_map()

    if source_system_filter:
        df_ent = df_ent[df_ent['source_system'] == source_system_filter.upper()]
    if table_filter:
        tbls = [t.upper() for t in (table_filter if isinstance(table_filter, list) else [table_filter])]
        mask = df_ent['staging_table'].str.upper().apply(lambda s: any(s.endswith('_' + t) for t in tbls)) | \
               df_ent['ods_table'].str.upper().apply(lambda s: any(s.endswith('_' + t) for t in tbls))
        df_ent = df_ent[mask]

    total = 0
    for _, ent_row in df_ent.iterrows():
        ss            = ent_row['source_system']
        staging_table = str(ent_row['staging_table']).strip()
        attrs = df_atr[
            (df_atr['source_system'] == ss) &
            (df_atr['staging_table'] == staging_table)
        ].copy()

        ods_table = str(ent_row['ods_table']).strip()
        out_path  = os.path.join(OUTPUT_BASE, ss, f'{ods_table}.csv')

        write_ods_mapping(ent_row, attrs, schema_map, out_path)
        total += 1

    print(f'[gen_mapping_ods] {total} file(s) generated.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--source-system', default=None)
    parser.add_argument('--table',         default=None, nargs='+')
    args = parser.parse_args()
    gen_mapping_ods(
        source_system_filter=args.source_system,
        table_filter=args.table,
    )
