"""
Step 1b -- gen_reg_staging
Append-mode: run once per source system, all sources accumulate in the same files.

Usage (from repo root):
    python Mapping/scripts/gen_reg_staging.py FMS
    python Mapping/scripts/gen_reg_staging.py NHNCK

Reads from:
    Source/<SS>_Tables.csv
    Source/<SS>_Columns.csv

Writes to (append mode):
    Mapping/registries/gm_staging_entities.csv
    Mapping/registries/gm_staging_attributes.csv

gm_staging_entities columns:
    source_system | table_name | staging_table | table_type | etl_handle | filter | description

gm_staging_attributes columns:
    source_system | table_name | staging_table | column_name | data_type | description | pk/fk
"""
import pandas as pd, os, sys

REPO_ROOT   = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SOURCE_DIR  = os.path.join(REPO_ROOT, 'Source')
OUTPUT_DIR  = os.path.join(REPO_ROOT, 'Mapping', 'registries')

ETL_HANDLE  = 'Incremental - Delete then Insert'


def make_staging_table(source_system: str, table_name: str) -> str:
    """stg_fms_agencies (fully lowercase)."""
    return f"stg_{source_system.lower()}_{table_name.lower()}"


def gen_staging(source_system: str):
    tables_path  = os.path.join(SOURCE_DIR, f'{source_system}_Tables.csv')
    columns_path = os.path.join(SOURCE_DIR, f'{source_system}_Columns.csv')

    if not os.path.exists(tables_path):
        raise FileNotFoundError(f'Khong tim thay: {tables_path}')
    if not os.path.exists(columns_path):
        raise FileNotFoundError(f'Khong tim thay: {columns_path}')

    df_tables  = pd.read_csv(tables_path)
    df_columns = pd.read_csv(columns_path)

    staging_tables = df_tables['Tên bảng'].apply(
        lambda t: make_staging_table(source_system, t)
    )

    new_entities = pd.DataFrame({
        'source_system': source_system,
        'table_name':    df_tables['Tên bảng'],
        'staging_table': staging_tables,
        'table_type':    '',
        'etl_handle':    ETL_HANDLE,
        'filter':        '',
        'description':   df_tables['Ý nghĩa bảng'],
    })

    # build staging_table lookup for attributes (join on table_name)
    tbl_to_stg = dict(zip(df_tables['Tên bảng'], staging_tables))
    staging_col = df_columns['Tên bảng'].map(tbl_to_stg).fillna('')

    new_attributes = pd.DataFrame({
        'source_system': source_system,
        'table_name':    df_columns['Tên bảng'],
        'staging_table': staging_col,
        'column_name':   df_columns['Tên trường'].str.upper(),
        'data_type':     '',
        'description':   df_columns['Mô tả'],
        'pk/fk':         df_columns['Khóa'].fillna(''),
    })

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    out_ent = os.path.join(OUTPUT_DIR, 'gm_staging_entities.csv')
    out_atr = os.path.join(OUTPUT_DIR, 'gm_staging_attributes.csv')

    for out_path, new_df in [(out_ent, new_entities), (out_atr, new_attributes)]:
        if os.path.exists(out_path):
            existing = pd.read_csv(out_path)
            existing = existing[existing['source_system'] != source_system]
            combined = pd.concat([existing, new_df], ignore_index=True)
        else:
            combined = new_df
        combined.to_csv(out_path, index=False)

    total_ent = len(pd.read_csv(out_ent))
    total_atr = len(pd.read_csv(out_atr))
    print(f"[gen_staging] source_system        : {source_system}")
    print(f"[gen_staging] gm_staging_entities  : +{len(new_entities)} rows (total {total_ent}) -> {out_ent}")
    print(f"[gen_staging] gm_staging_attributes: +{len(new_attributes)} rows (total {total_atr}) -> {out_atr}")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(__doc__); raise SystemExit(1)
    gen_staging(sys.argv[1].upper())
