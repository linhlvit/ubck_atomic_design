"""
build_glossary.py
=================
Tạo business_glossary.csv và glossary_mappings.csv từ silver_attributes.csv (NHNCK).

Output:
  DG/glossary/business_glossary.csv   — 1 dòng = 1 business term
  DG/glossary/glossary_mappings.csv   — traceability (term x entity x attribute)

Tiêu chí lọc attribute:
  - source_system = NHNCK
  - data_domain != Surrogate Key
  - Loại: Source System Code, Created Timestamp, Updated Timestamp
  - Loại attribute ' Id' khi có cặp ' Code' trong cùng entity

Primary entity detection (để xác định primary_grain):
  1. Entity có is_primary_key = true cho attribute này
  2. Entity ngắn nhất (general nhất) — fallback
"""

import csv
import sys
import io
from collections import defaultdict, OrderedDict
from pathlib import Path

if sys.stdout.encoding and sys.stdout.encoding.lower() not in ('utf-8', 'utf-8-sig'):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
if sys.stderr.encoding and sys.stderr.encoding.lower() not in ('utf-8', 'utf-8-sig'):
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

SCRIPT_DIR = Path(__file__).parent
REPO_ROOT = SCRIPT_DIR.parent.parent   # ubck_atomic_design/
ATTRS_PATH = REPO_ROOT / 'Silver' / 'lld' / 'silver_attributes.csv'
SILVER_ENTITIES_PATH = REPO_ROOT / 'Silver' / 'hld' / 'silver_entities.csv'
OUT_GLOSSARY = SCRIPT_DIR / 'business_glossary.csv'
OUT_MAPPINGS = SCRIPT_DIR / 'glossary_mappings.csv'

EXCLUDE_ATTRS = {'Source System Code', 'Created Timestamp', 'Updated Timestamp'}
EXCLUDE_DOMAINS = {'Surrogate Key'}

GRAIN_MAP = {
    'Securities Practitioner': 'theo từng người hành nghề',
    'Securities Practitioner Conduct Violation': 'theo từng vi phạm',
    'Securities Practitioner License Application': 'theo từng hồ sơ CCHN',
    'Securities Practitioner License Application Verification Status': 'theo từng lần phê duyệt hồ sơ',
    'Securities Practitioner License Application Processing Activity Log': 'theo từng thao tác xử lý hồ sơ',
    'Securities Practitioner License Application Document Attachment': 'theo từng tài liệu đính kèm hồ sơ',
    'Securities Practitioner License Application Education Certificate Document': 'theo từng văn bằng đính kèm hồ sơ',
    'Securities Practitioner License Application Fee': 'theo từng khoản phí hồ sơ',
    'Securities Practitioner License Certificate Document': 'theo từng chứng chỉ hành nghề',
    'Securities Practitioner License Certificate Document Activity Log': 'theo từng thao tác trên chứng chỉ',
    'Securities Practitioner License Certificate Document Status History': 'theo từng thay đổi trạng thái chứng chỉ',
    'Securities Practitioner License Certificate Group Document': 'theo từng nhóm chứng chỉ',
    'Securities Practitioner License Certificate Group Member': 'theo từng thành viên trong nhóm chứng chỉ',
    'Securities Practitioner License Decision Document': 'theo từng quyết định hành chính',
    'Securities Practitioner Organization Employment Report': 'theo từng báo cáo tuyển dụng',
    'Securities Practitioner Identity Verification Record': 'theo từng lần xác thực danh tính',
    'Securities Practitioner Qualification Examination Assessment': 'theo từng đợt thi',
    'Securities Practitioner Qualification Examination Assessment Result': 'theo từng kết quả thi',
    'Securities Practitioner Qualification Examination Assessment Fee': 'theo từng mức phí thi',
    'Securities Practitioner Professional Training Class': 'theo từng khóa đào tạo',
    'Securities Practitioner Professional Training Class Enrollment': 'theo từng lượt đăng ký học',
    'Securities Practitioner Related Party': 'theo từng quan hệ thân nhân',
    'Securities Practitioner Employment Status': 'theo từng trạng thái công tác',
    'Securities Organization Reference': 'theo từng tổ chức thành viên',
    'Regulatory Authority Organization Unit': 'theo từng đơn vị/phòng ban UBCKNN',
    'Involved Party Alternative Identification': 'theo từng giấy tờ định danh',
    'Involved Party Electronic Address': 'theo từng địa chỉ điện tử',
    'Involved Party Postal Address': 'theo từng địa chỉ bưu chính',
}

GFIELDS = ['term_id', 'parent_term_id', 'term_name', 'definition', 'primary_grain',
           'data_domain', 'source_tags', 'entity_tags', 'status', 'notes']
MFIELDS = ['term_id', 'silver_entity', 'silver_attribute', 'entity_grain', 'mapping_type']

# Homonym splitting: attributes that carry genuinely different meanings across entities.
# Each entry defines how to split 1 "merged" term into parent + children.
#
# Structure:
#   attr_name → {
#     'parent_name': display name for the abstract parent term (no mapping rows),
#     'children': [
#       {
#         'entities': set of silver_entity that belong to this child,
#         'term_name': override term name for child (if different from attr_name),
#         'primary_entity_override': which entity is home for this child,
#       },
#       ...
#     ]
#   }
#
# Parent term: has no mapping rows (abstract); child terms inherit all mappings.
HOMONYM_SPLITS: dict[str, dict] = {
    'Identification Number': {
        'parent_name': 'Identification Number',
        'children': [
            {
                'entities': {
                    'Securities Practitioner Conduct Violation',
                    'Securities Practitioner Professional Training Class Enrollment',
                    'Securities Practitioner Organization Employment Report',
                },
                'term_name': 'Identification Number',
                'note': 'Số CMND/CCCD/CMT của người hành nghề (snapshot tại thời điểm ghi nhận)',
                'primary_entity': 'Securities Practitioner Organization Employment Report',
            },
            {
                'entities': {
                    'Involved Party Alternative Identification',
                },
                'term_name': 'Identification Number',
                'note': 'Số quyết định thành lập hoặc giấy phép hoạt động của tổ chức',
                'primary_entity': 'Involved Party Alternative Identification',
            },
        ],
    },
    'Exam Number': {
        'parent_name': 'Exam Number',
        'children': [
            {
                'entities': {
                    'Securities Practitioner Professional Training Class Enrollment',
                },
                'term_name': 'Exam Number',
                'note': 'Số dự thi của học viên trong khóa đào tạo',
                'primary_entity': 'Securities Practitioner Professional Training Class Enrollment',
            },
            {
                'entities': {
                    'Securities Practitioner Qualification Examination Assessment Result',
                },
                'term_name': 'Exam Number',
                'note': 'Số báo danh của thí sinh trong đợt thi cấp chứng chỉ',
                'primary_entity': 'Securities Practitioner Qualification Examination Assessment Result',
            },
        ],
    },
    'Assignee Officer Code': {
        'parent_name': 'Assignee Officer Code',
        'children': [
            {
                'entities': {
                    'Securities Practitioner Professional Training Class Enrollment',
                    'Securities Practitioner License Application',
                },
                'term_name': 'Assignee Officer Code',
                'note': 'Mã cán bộ được phân công xử lý hồ sơ / khóa học',
                'primary_entity': 'Securities Practitioner License Application',
            },
            {
                'entities': {
                    'Securities Practitioner License Application Document Attachment',
                    'Securities Practitioner License Application Education Certificate Document',
                },
                'term_name': 'Assignee Officer Code',
                'note': 'Mã người được phân công thẩm định tài liệu đính kèm hồ sơ',
                'primary_entity': 'Securities Practitioner License Application Document Attachment',
            },
        ],
    },
}


def get_grain(entity: str) -> str:
    return GRAIN_MAP.get(entity, f'theo từng {entity}')


# Entities có table_type = Fundamental — ưu tiên là primary
FUNDAMENTAL_ENTITIES: set[str] = set()  # populated in main()

# Explicit primary entity override for ambiguous cases
# key = attr_name, value = primary entity name
PRIMARY_ENTITY_OVERRIDE: dict[str, str] = {
    'Full Name': 'Securities Practitioner',
    'Date Of Birth': 'Securities Practitioner Organization Employment Report',
    'Birth Year': 'Securities Practitioner',
    'Country Code': 'Securities Practitioner',
    'Workplace Name': 'Securities Practitioner',
    'Relationship Type Code': 'Securities Practitioner',
    'Occupation Name': 'Securities Practitioner',
    'Involved Party Code': 'Involved Party Alternative Identification',
    'Identity Reference Code': 'Involved Party Alternative Identification',
    'Issue Date': 'Involved Party Alternative Identification',
    'Attachment File Path': 'Securities Practitioner Qualification Examination Assessment',
}


def get_primary_entity(attr_name: str, entity_rows: dict) -> str:
    """
    Xác định entity 'chủ' của term:
    1. Override thủ công (cho các trường hợp ambiguous)
    2. Entity có is_primary_key = true cho attribute này
    3. Entity Fundamental ngắn nhất (general nhất)
    4. Entity ngắn nhất — fallback
    """
    # Priority 1: explicit override
    override = PRIMARY_ENTITY_OVERRIDE.get(attr_name)
    if override and override in entity_rows:
        return override

    # Priority 2: is_primary_key = true
    for entity, row in entity_rows.items():
        if row.get('is_primary_key', '').strip().lower() == 'true':
            return entity

    # Priority 3: Fundamental entity ngắn nhất
    fundamental = [e for e in entity_rows if e in FUNDAMENTAL_ENTITIES]
    if fundamental:
        return min(fundamental, key=len)

    # Fallback: shortest entity name
    return min(entity_rows.keys(), key=len)


def load_filtered_attrs(source_system: str = 'NHNCK') -> list[dict]:
    rows = []
    seen: set = set()
    with open(ATTRS_PATH, encoding='utf-8-sig', newline='') as f:
        for row in csv.DictReader(f):
            if row['source_system'] != source_system:
                continue
            entity = row['silver_entity']
            attr = row['silver_attribute']
            key = (entity, attr)
            if key in seen:
                continue
            seen.add(key)
            if row['data_domain'] in EXCLUDE_DOMAINS:
                continue
            if attr in EXCLUDE_ATTRS:
                continue
            rows.append(row)
    return rows


def filter_id_pairs(rows: list[dict]) -> list[dict]:
    """Loại attribute ' Id' khi cùng entity có ' Code' tương ứng."""
    entity_attrs: dict[str, set] = defaultdict(set)
    for row in rows:
        entity_attrs[row['silver_entity']].add(row['silver_attribute'])

    result = []
    for row in rows:
        attr = row['silver_attribute']
        entity = row['silver_entity']
        if attr.endswith(' Id'):
            code_pair = attr[:-3] + ' Code'
            if code_pair in entity_attrs[entity]:
                continue
        result.append(row)
    return result


def build_glossary(rows: list[dict]) -> tuple[list[dict], list[dict]]:
    # Group by attr_name, preserving order of first appearance
    attr_order: OrderedDict[str, dict] = OrderedDict()
    for row in rows:
        attr = row['silver_attribute']
        entity = row['silver_entity']
        if attr not in attr_order:
            attr_order[attr] = {}
        attr_order[attr][entity] = row

    glossary_rows = []
    mapping_rows = []
    seq = 1

    for attr_name, entity_rows in attr_order.items():

        # --- Homonym split: this attr has genuinely different meanings per entity set ---
        if attr_name in HOMONYM_SPLITS:
            split = HOMONYM_SPLITS[attr_name]

            # 1. Emit abstract parent term (no mapping rows, no entity_tags)
            parent_term_id = f'NHNCK_{seq:03d}'
            seq += 1
            glossary_rows.append({
                'term_id': parent_term_id,
                'parent_term_id': '',
                'term_name': split['parent_name'],
                'definition': '',
                'primary_grain': '',
                'data_domain': '',
                'source_tags': 'NHNCK',
                'entity_tags': '',
                'status': 'draft',
                'notes': 'Abstract parent — see child terms for specific meanings',
            })

            # 2. Emit one child term per child definition
            for child in split['children']:
                child_entities = child['entities']
                # Filter entity_rows to only entities in this child group
                child_entity_rows = {e: r for e, r in entity_rows.items() if e in child_entities}
                if not child_entity_rows:
                    continue

                child_term_id = f'NHNCK_{seq:03d}'
                seq += 1

                primary_entity = child.get('primary_entity')
                if primary_entity not in child_entity_rows:
                    primary_entity = min(child_entity_rows.keys(), key=len)
                primary_grain = get_grain(primary_entity)
                meta = child_entity_rows.get(primary_entity) or next(iter(child_entity_rows.values()))
                child_entities_list = list(child_entity_rows.keys())

                glossary_rows.append({
                    'term_id': child_term_id,
                    'parent_term_id': parent_term_id,
                    'term_name': child.get('term_name', attr_name),
                    'definition': meta.get('description', ''),
                    'primary_grain': primary_grain,
                    'data_domain': meta.get('data_domain', ''),
                    'source_tags': 'NHNCK',
                    'entity_tags': ' | '.join(child_entities_list),
                    'status': 'draft',
                    'notes': child.get('note', meta.get('comment', '')),
                })

                for entity in child_entities_list:
                    is_primary = (entity == primary_entity)
                    mapping_rows.append({
                        'term_id': child_term_id,
                        'silver_entity': entity,
                        'silver_attribute': attr_name,
                        'entity_grain': get_grain(entity),
                        'mapping_type': 'primary' if is_primary else 'reference',
                    })
            continue  # skip the normal single-term path below

        # --- Normal case: 1 attr = 1 term ---
        entities = list(entity_rows.keys())
        primary_entity = get_primary_entity(attr_name, entity_rows)
        primary_grain = get_grain(primary_entity)
        term_id = f'NHNCK_{seq:03d}'
        seq += 1

        # Use description from primary entity if available, else first entity
        meta = entity_rows.get(primary_entity) or entity_rows[entities[0]]

        glossary_rows.append({
            'term_id': term_id,
            'parent_term_id': '',
            'term_name': attr_name,
            'definition': meta.get('description', ''),
            'primary_grain': primary_grain,
            'data_domain': meta.get('data_domain', ''),
            'source_tags': 'NHNCK',
            'entity_tags': ' | '.join(entities),
            'status': 'draft',
            'notes': meta.get('comment', ''),
        })

        for entity in entities:
            is_primary = (entity == primary_entity)
            mapping_rows.append({
                'term_id': term_id,
                'silver_entity': entity,
                'silver_attribute': attr_name,
                'entity_grain': get_grain(entity),
                'mapping_type': 'primary' if is_primary else 'reference',
            })

    return glossary_rows, mapping_rows


def write_csv(path: Path, fields: list[str], rows: list[dict]):
    with open(path, 'w', encoding='utf-8-sig', newline='') as f:
        w = csv.DictWriter(f, fieldnames=fields, lineterminator='\n', extrasaction='ignore')
        w.writeheader()
        w.writerows(rows)
    print(f'  Ghi: {path}', file=sys.stderr)


def load_fundamental_entities() -> set[str]:
    entities_path = SILVER_ENTITIES_PATH
    result = set()
    with open(entities_path, encoding='utf-8-sig', newline='') as f:
        for row in csv.DictReader(f):
            if row.get('table_type', '').strip().lower() == 'fundamental':
                result.add(row['silver_entity'])
    return result


def main():
    global FUNDAMENTAL_ENTITIES
    FUNDAMENTAL_ENTITIES = load_fundamental_entities()
    print(f'Loaded {len(FUNDAMENTAL_ENTITIES)} Fundamental entities', file=sys.stderr)
    print('Load và lọc silver_attributes...', file=sys.stderr)
    rows = load_filtered_attrs('NHNCK')
    rows = filter_id_pairs(rows)
    print(f'  {len(rows)} attribute rows sau lọc', file=sys.stderr)

    print('Build glossary...', file=sys.stderr)
    glossary_rows, mapping_rows = build_glossary(rows)
    print(f'  {len(glossary_rows)} terms, {len(mapping_rows)} mappings', file=sys.stderr)

    write_csv(OUT_GLOSSARY, GFIELDS, glossary_rows)
    write_csv(OUT_MAPPINGS, MFIELDS, mapping_rows)
    print('Hoàn thành.', file=sys.stderr)


if __name__ == '__main__':
    main()
