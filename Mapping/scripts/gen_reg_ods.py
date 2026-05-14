"""
Step 2.1 -- gen_reg_ods
Append-mode: run once per source system, all sources accumulate in the same files.

Usage (from repo root):
    python Mapping/scripts/gen_reg_ods.py FMS

Reads from:
    Mapping/registries/gm_staging_entities.csv
    Mapping/registries/gm_staging_attributes.csv

Writes to (append mode):
    Mapping/registries/gm_ods_entities.csv
    Mapping/registries/gm_ods_attributes.csv

gm_ods_entities columns:
    source_system | staging_table | ods_table | table_type | technical_table | etl_handle | filter | description

gm_ods_attributes columns:
    source_system | staging_table | ods_table | column_name | data_type | description | pk/fk
    - column_name: lowercase (= staging target column name)
"""
import pandas as pd, os, sys

REPO_ROOT  = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REGISTRIES = os.path.join(REPO_ROOT, 'Mapping', 'registries')

ETL_HANDLE = 'Incremental - Append'


def make_ods_table(source_system: str, staging_table: str) -> str:
    """stg_fms_securities → ods_fms_securities."""
    return staging_table.replace('stg_', 'ods_', 1)


def gen_ods(source_system: str):
    stg_ent_path = os.path.join(REGISTRIES, 'gm_staging_entities.csv')
    stg_atr_path = os.path.join(REGISTRIES, 'gm_staging_attributes.csv')

    if not os.path.exists(stg_ent_path):
        raise FileNotFoundError(f'Khong tim thay: {stg_ent_path}. Chay gen_reg_staging.py truoc.')
    if not os.path.exists(stg_atr_path):
        raise FileNotFoundError(f'Khong tim thay: {stg_atr_path}. Chay gen_reg_staging.py truoc.')

    df_stg_ent = pd.read_csv(stg_ent_path)
    df_stg_atr = pd.read_csv(stg_atr_path)

    stg_ent_ss = df_stg_ent[df_stg_ent['source_system'] == source_system].copy()
    stg_atr_ss = df_stg_atr[df_stg_atr['source_system'] == source_system].copy()

    if stg_ent_ss.empty:
        raise ValueError(f"Khong tim thay source_system='{source_system}'. Chay gen_reg_staging.py truoc.")

    ods_tables = stg_ent_ss['staging_table'].apply(lambda s: make_ods_table(source_system, s))

    # ── Entities ──────────────────────────────────────────────────────────────
    new_entities = pd.DataFrame({
        'source_system':   source_system,
        'staging_table':   stg_ent_ss['staging_table'].values,
        'ods_table':       ods_tables.values,
        'table_type':      stg_ent_ss['table_type'].values,
        'technical_table': '',
        'etl_handle':      ETL_HANDLE,
        'filter':          '',
        'description':     stg_ent_ss['description'].values,
    })

    # ── Attributes ────────────────────────────────────────────────────────────
    stg_to_ods = dict(zip(stg_ent_ss['staging_table'], ods_tables.values))
    atr_rows = []

    for stg_tbl in stg_ent_ss['staging_table']:
        ods_tbl = stg_to_ods[stg_tbl]
        group   = stg_atr_ss[stg_atr_ss['staging_table'] == stg_tbl]

        for _, atr in group.iterrows():
            atr_rows.append({
                'source_system': source_system,
                'staging_table': stg_tbl,
                'ods_table':     ods_tbl,
                'column_name':   str(atr['column_name']).strip().lower(),
                'data_type':     '' if pd.isna(atr.get('data_type', '')) else str(atr['data_type']).strip(),
                'description':   '' if pd.isna(atr.get('description', '')) else str(atr['description']).strip(),
                'pk/fk':         '' if pd.isna(atr.get('pk/fk', '')) else str(atr['pk/fk']).strip(),
            })


    new_attributes = pd.DataFrame(atr_rows)

    # ── Write (append mode, replace source_system) ────────────────────────────
    os.makedirs(REGISTRIES, exist_ok=True)
    out_ent = os.path.join(REGISTRIES, 'gm_ods_entities.csv')
    out_atr = os.path.join(REGISTRIES, 'gm_ods_attributes.csv')

    for out_path, new_df in [(out_ent, new_entities), (out_atr, new_attributes)]:
        if os.path.exists(out_path):
            existing = pd.read_csv(out_path)
            existing = existing[existing['source_system'] != source_system]
            # Re-index to new schema (drops removed columns like table_name)
            existing = existing.reindex(columns=new_df.columns)
            combined = pd.concat([existing, new_df], ignore_index=True)
        else:
            combined = new_df
        combined.to_csv(out_path, index=False)

    total_ent = len(pd.read_csv(out_ent))
    total_atr = len(pd.read_csv(out_atr))
    print(f"[gen_ods] source_system       : {source_system}")
    print(f"[gen_ods] gm_ods_entities     : +{len(new_entities)} rows (total {total_ent}) -> {out_ent}")
    print(f"[gen_ods] gm_ods_attributes   : +{len(new_attributes)} rows (total {total_atr}) -> {out_atr}")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(__doc__); raise SystemExit(1)
    gen_ods(sys.argv[1].upper())
