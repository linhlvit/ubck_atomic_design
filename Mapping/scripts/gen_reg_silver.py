"""
Step 2 — gen_reg_silver
Enrich silver_entities and silver_attributes; output to Mapping/registries/.

Usage (from repo root):
    python Mapping/scripts/gen_reg_silver.py

Reads from:
    Silver/hld/silver_entities.csv
    Silver/lld/silver_attributes.csv
    Silver/lld/attr_Classification_Value.csv
    system/rules/rule_map_technical_table_type.csv  (or .xlsx)
    system/rules/rule_map_data_type.csv             (or .xlsx)

Writes to:
    Mapping/registries/gm_silver_entities.csv
    Mapping/registries/gm_silver_attributes.csv
"""
import pandas as pd, re, os, sys

REPO_ROOT    = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SILVER_HLD   = os.path.join(REPO_ROOT, 'Silver', 'hld')
SILVER_LLD   = os.path.join(REPO_ROOT, 'Silver', 'lld')
RULES_DIR    = os.path.join(REPO_ROOT, 'system', 'rules')
OUTPUT_DIR   = os.path.join(REPO_ROOT, 'Mapping', 'registries')


def read_any(path):
    return pd.read_csv(path) if path.endswith('.csv') else pd.read_excel(path)


def resolve(directory, stem):
    for ext in ('.csv', '.xlsx'):
        p = os.path.join(directory, stem + ext)
        if os.path.exists(p): return p
    raise FileNotFoundError(f'Không tìm thấy {stem}.csv/.xlsx trong {directory}')


def decimal_width(dtype):
    m = re.match(r'decimal\((\d+),(\d+)\)', str(dtype).strip())
    return int(m.group(1)) + int(m.group(2)) if m else 0


def build_data_type_rules(rule_path):
    df = read_any(rule_path)
    rules = [{'keyword': str(r['Include In Name']).strip().lower(),
               'data_type': str(r['Data Type']).strip(),
               'width': decimal_width(str(r['Data Type']))}
             for _, r in df.iterrows()]
    rules.sort(key=lambda r: r['width'], reverse=True)
    return rules


def get_silver_data_type(attr_name, rules):
    words = [w.lower() for w in str(attr_name).split()]
    decimal_matches, other_match = [], None
    for rule in rules:
        if rule['keyword'] in words:
            if rule['width'] > 0: decimal_matches.append(rule)
            elif other_match is None: other_match = rule
    if decimal_matches: return decimal_matches[0]['data_type']
    if other_match: return other_match['data_type']
    return 'string'


def insert_col_after(df, after_col, new_col, values):
    df = df.copy(); df[new_col] = values
    idx = df.columns.get_loc(after_col) + 1
    cols = list(df.columns); cols.remove(new_col); cols.insert(idx, new_col)
    return df[cols]


def normalize_attr_columns(df):
    """
    Xử lý 2 dạng tên cột có thể có trong silver_attributes.csv:
      A) Consolidated (tên chuẩn pipeline): silver_attribute, source_column  → giữ nguyên
      B) Individual attr file format      : attribute_name, source_columns   → rename
    """
    col_map = {}
    if 'attribute_name' in df.columns and 'silver_attribute' not in df.columns:
        col_map['attribute_name'] = 'silver_attribute'
    if 'source_columns' in df.columns and 'source_column' not in df.columns:
        col_map['source_columns'] = 'source_column'
    return df.rename(columns=col_map) if col_map else df


def derive_mapping_type(row):
    if str(row.get('bcv_concept', '')).strip() == 'Shared Entity':
        return 'shared_entity'
    if str(row.get('table_type', '')).strip() == 'Classification':
        return 'cv'
    return 'regular'


def gen_silver():
    silver_entity_path  = os.path.join(SILVER_HLD, 'silver_entities.csv')
    silver_atr_path     = os.path.join(SILVER_LLD, 'silver_attributes.csv')
    cv_attr_path        = os.path.join(SILVER_LLD, 'attr_Classification_Value.csv')
    rule_tbl_type_path  = resolve(RULES_DIR, 'rule_map_technical_table_type')
    rule_data_type_path = resolve(RULES_DIR, 'rule_map_data_type')

    for p in [silver_entity_path, silver_atr_path, cv_attr_path]:
        if not os.path.exists(p):
            raise FileNotFoundError(f'Không tìm thấy: {p}')

    # ── gm_silver_entities ────────────────────────────────────────────────────
    df_ent      = read_any(silver_entity_path)
    df_tbl_rule = read_any(rule_tbl_type_path)
    tbl_type_map = dict(zip(df_tbl_rule['Model Table Type'].str.strip(),
                            df_tbl_rule['Technical Table Type'].str.strip()))

    mapping_types = df_ent.apply(derive_mapping_type, axis=1)
    drop_cols = [c for c in df_ent.columns if c in ['bcv_core_object', 'bcv_concept', 'status']]
    df_ent = df_ent.drop(columns=drop_cols)

    tech_types = df_ent['table_type'].map(tbl_type_map).fillna('')
    df_out_ent = insert_col_after(df_ent, 'table_type', 'technical_table_type', tech_types)
    df_out_ent = insert_col_after(df_out_ent, 'technical_table_type', 'filter', '')
    df_out_ent = insert_col_after(df_out_ent, 'filter', 'mapping_type', mapping_types)
    df_out_ent['source_table'] = df_out_ent['source_table'].str.upper()

    CV_ENTITY = 'Classification Value'
    if CV_ENTITY not in df_out_ent['silver_entity'].values:
        cv_row = pd.DataFrame([{
            'silver_entity': CV_ENTITY, 'table_type': 'Classification',
            'technical_table_type': 'SCD1', 'filter': '', 'mapping_type': 'cv',
            'description': 'Bảng danh mục phân loại dùng chung.',
            'source_table': '(multiple — see ref_shared_entity_classifications)',
        }])
        df_out_ent = pd.concat([df_out_ent, cv_row], ignore_index=True)

    # ── gm_silver_attributes ──────────────────────────────────────────────────
    df_atr = normalize_attr_columns(read_any(silver_atr_path))
    rules  = build_data_type_rules(rule_data_type_path)
    data_types = df_atr['silver_attribute'].apply(lambda n: get_silver_data_type(n, rules))
    df_out_atr = insert_col_after(df_atr, 'silver_attribute', 'silver_data_type', data_types)

    if CV_ENTITY not in df_out_atr['silver_entity'].values:
        df_cv = normalize_attr_columns(read_any(cv_attr_path))
        cv_rows = []
        for _, row in df_cv.iterrows():
            cv_rows.append({
                'bcv_core_object': 'Classification', 'silver_entity': CV_ENTITY,
                'silver_attribute': row.get('silver_attribute', row.get('attribute_name', '')),
                'silver_data_type': 'string',
                'description': row.get('description', ''),
                'data_domain': row.get('data_domain', ''),
                'nullable': row.get('nullable', True),
                'is_primary_key': row.get('is_primary_key', False),
                'source_system': '', 'source_table': '',
                'source_column': row.get('source_column', row.get('source_columns', '')),
                'comment': row.get('comment', ''),
                'classification_context': row.get('classification_context', ''),
                'etl_derived_value': row.get('etl_derived_value', ''),
            })
        df_out_atr = pd.concat([df_out_atr, pd.DataFrame(cv_rows)], ignore_index=True)

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    out_ent = os.path.join(OUTPUT_DIR, 'gm_silver_entities.csv')
    out_atr = os.path.join(OUTPUT_DIR, 'gm_silver_attributes.csv')
    df_out_ent.to_csv(out_ent, index=False)
    df_out_atr.to_csv(out_atr, index=False)

    unmapped = df_ent[~df_ent['table_type'].isin(tbl_type_map)]['table_type'].unique()
    mt_dist  = df_out_ent['mapping_type'].value_counts().to_dict()
    print(f"[gen_silver] Reads from repo root:")
    print(f"[gen_silver]   Silver/hld/silver_entities.csv")
    print(f"[gen_silver]   Silver/lld/silver_attributes.csv")
    print(f"[gen_silver]   Silver/lld/attr_Classification_Value.csv")
    print(f"[gen_silver] gm_silver_entities   : {len(df_out_ent)} rows → {out_ent}")
    print(f"[gen_silver]   mapping_type       : {mt_dist}")
    print(f"[gen_silver] gm_silver_attributes : {len(df_out_atr)} rows → {out_atr}")
    if len(unmapped):
        print(f"[gen_silver]   ⚠️  table_type chưa có rule: {list(unmapped)}")


if __name__ == '__main__':
    gen_silver()
