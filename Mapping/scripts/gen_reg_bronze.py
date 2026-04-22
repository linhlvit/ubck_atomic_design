"""
Step 1 — gen_reg_bronze
Append-mode: run once per source system, all sources accumulate in the same files.

Usage (from repo root):
    python Mapping/scripts/gen_reg_bronze.py FMS
    python Mapping/scripts/gen_reg_bronze.py NHNCK

Reads from:
    Source/<SS>_Tables.csv
    Source/<SS>_Columns.csv

Writes to (append mode):
    Mapping/registries/gm_bronze_entities.csv
    Mapping/registries/gm_bronze_attributes.csv
"""
import pandas as pd, os, sys

REPO_ROOT   = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SOURCE_DIR  = os.path.join(REPO_ROOT, 'Source')
OUTPUT_DIR  = os.path.join(REPO_ROOT, 'Mapping', 'registries')


def gen_bronze(source_system: str):
    tables_path  = os.path.join(SOURCE_DIR, f'{source_system}_Tables.csv')
    columns_path = os.path.join(SOURCE_DIR, f'{source_system}_Columns.csv')

    if not os.path.exists(tables_path):
        raise FileNotFoundError(f'Không tìm thấy: {tables_path}')
    if not os.path.exists(columns_path):
        raise FileNotFoundError(f'Không tìm thấy: {columns_path}')

    df_tables  = pd.read_csv(tables_path)
    df_columns = pd.read_csv(columns_path)

    new_entities = pd.DataFrame({
        'source_system':            source_system,
        'table_name':               df_tables['Tên bảng'],
        'source_system.table_name': source_system + '.' + df_tables['Tên bảng'],
        'technical_table_type':     '',
        'filter':                   '',
        'description':              df_tables['Ý nghĩa bảng'],
    })

    new_attributes = pd.DataFrame({
        'source_system':            source_system,
        'table_name':               df_columns['Tên bảng'],
        'column_name':              df_columns['Tên trường'],
        'source_system.table_name': source_system + '.' + df_columns['Tên bảng'],
        'data_type':                '',
        'description':              df_columns['Mô tả'],
        'pk/fk':                    df_columns['Khóa'].fillna(''),
    })

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    out_ent = os.path.join(OUTPUT_DIR, 'gm_bronze_entities.csv')
    out_atr = os.path.join(OUTPUT_DIR, 'gm_bronze_attributes.csv')

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
    print(f"[gen_bronze] source_system       : {source_system}")
    print(f"[gen_bronze] gm_bronze_entities  : +{len(new_entities)} rows (total {total_ent}) → {out_ent}")
    print(f"[gen_bronze] gm_bronze_attributes: +{len(new_attributes)} rows (total {total_atr}) → {out_atr}")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(__doc__); raise SystemExit(1)
    gen_bronze(sys.argv[1].upper())
