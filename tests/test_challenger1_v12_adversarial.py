"""
Empirical Challenger 1: Adversarial Verification Suite
Validates UBCKNN v1.2 Database Design docx against ground truth catalog:
- Table completeness & schema correctness
- Column metadata integrity (5,787 columns across 12 attributes)
- XML strict stress testing of word/document.xml and all XML parts
- Primary key tables and constraint consistency
- Baseline v1.1 SHA-256 and prefix/suffix preservation
"""

import os
import sys
import json
import zipfile
import re
import hashlib
from typing import Dict, List, Any, Tuple
import pytest
from lxml import etree

if sys.stdout and hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
if sys.stderr and hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8')

DOCX_PATH = r"C:\Workspace\Design_DW\ubck_atomic_design\docs\output\UBCKNN_Thiet ke co so du lieu_v1.2_20261029.docx"
GROUND_TRUTH_PATH = r"C:\Workspace\Design_DW\.agents\teamwork\spec_miner_survey_2\all_subsystems.json"
V1_1_PATH = r"C:\Workspace\Design_DW\ubck_atomic_design\docs\output\UBCKNN_Thiet ke co so du lieu_v1.1_20260429.docx"
EXPECTED_V1_1_HASH = "5846d9cb4002305127ae01a5e7c3342a5477030d743960d0defc6e76a29aa5fc"

NS = {
    'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
    'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
    'm': 'http://schemas.openxmlformats.org/officeDocument/2006/math',
    'v': 'urn:schemas-microsoft-com:vml',
    'wp': 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',
    'w10': 'urn:schemas-microsoft-com:office:word',
    'a': 'http://schemas.openxmlformats.org/drawingml/2006/main',
    'pic': 'http://schemas.openxmlformats.org/drawingml/2006/picture',
}

# Module-level caches
_CACHED_GROUND_TRUTH = None
_CACHED_ROOT = None
_CACHED_SECTION2_DATA = None


def get_ground_truth():
    global _CACHED_GROUND_TRUTH
    if _CACHED_GROUND_TRUTH is None:
        with open(GROUND_TRUTH_PATH, 'r', encoding='utf-8') as f:
            _CACHED_GROUND_TRUTH = json.load(f)
    return _CACHED_GROUND_TRUTH


def get_document_root():
    global _CACHED_ROOT
    if _CACHED_ROOT is None:
        with zipfile.ZipFile(DOCX_PATH, 'r') as z:
            doc_xml = z.read('word/document.xml')
        strict_parser = etree.XMLParser(recover=False, resolve_entities=False, no_network=True)
        _CACHED_ROOT = etree.fromstring(doc_xml, parser=strict_parser)
    return _CACHED_ROOT


def get_paragraph_text(p_elem) -> str:
    texts = p_elem.xpath('.//w:t/text()', namespaces=NS)
    return ''.join(texts).strip()


def get_table_matrix(tbl_elem) -> List[List[str]]:
    matrix = []
    rows = tbl_elem.xpath('./w:tr', namespaces=NS)
    for row in rows:
        cells = row.xpath('./w:tc', namespaces=NS)
        row_vals = []
        for cell in cells:
            cell_text = ''.join(cell.xpath('.//w:t/text()', namespaces=NS)).strip()
            row_vals.append(cell_text)
        matrix.append(row_vals)
    return matrix


def get_section2_data():
    global _CACHED_SECTION2_DATA
    if _CACHED_SECTION2_DATA is not None:
        return _CACHED_SECTION2_DATA
        
    root = get_document_root()
    body = root.find('w:body', NS)
    assert body is not None, "w:body missing in document.xml!"
    
    in_section_2 = False
    current_subsys = None
    current_detail_table = None
    
    subsystems_found = []
    subsystems_dict = {}
    
    for child in body:
        tag = etree.QName(child).localname
        if tag == 'p':
            text = get_paragraph_text(child)
            pStyle = child.xpath('.//w:pStyle/@w:val', namespaces=NS)
            style = pStyle[0] if pStyle else ''
            
            if 'Heading1' in style and 'CƠ SỞ DỮ LIỆU' in text:
                in_section_2 = True
                continue
            
            if 'Heading1' in style and ('KHO DỮ LIỆU' in text or 'KHO DỮ LIỆU' in text):
                in_section_2 = False
                break
                
            if not in_section_2:
                continue
                
            m_h2 = re.match(r'^2\.(\d+)\s+([A-Z0-9_]+)\s*—\s*(.*)$', text)
            if 'Heading2' in style and m_h2:
                idx = int(m_h2.group(1))
                code = m_h2.group(2)
                title = m_h2.group(3)
                current_subsys = {
                    'index': idx,
                    'code': code,
                    'title': title,
                    'header_text': text,
                    't0_table': None,
                    't1_overview_table': None,
                    't1_rows': [],
                    'detail_tables': [],
                }
                subsystems_found.append(current_subsys)
                subsystems_dict[code] = current_subsys
                current_detail_table = None
                continue
                
            m_h3 = re.match(r'^2\.\d+\.\d+\s+Bảng\s+(.*)$', text)
            if 'Heading3' in style and m_h3:
                bname = m_h3.group(1).strip()
                current_detail_table = {
                    'heading_text': text,
                    'business_name': bname,
                    'metadata': {},
                    'data_dictionary_table': None,
                    'columns': [],
                    'pk_table': None,
                    'fk_table': None,
                    'has_index': False,
                    'has_trigger': False,
                }
                if current_subsys:
                    current_subsys['detail_tables'].append(current_detail_table)
                continue
                
            if current_detail_table and current_detail_table['data_dictionary_table'] is None:
                for meta_key in ['Mô tả', 'Đường dẫn lưu trữ', 'Phân vùng', 'Thời gian lưu trữ', 'Định dạng lưu trữ']:
                    if text.startswith(meta_key + ':'):
                        val = text[len(meta_key) + 1:].strip()
                        current_detail_table['metadata'][meta_key] = val
                        
            if 'Heading4' in style:
                if 'Index' in text and current_detail_table:
                    current_detail_table['has_index'] = True
                elif 'Trigger' in text and current_detail_table:
                    current_detail_table['has_trigger'] = True

        elif tag == 'tbl' and in_section_2 and current_subsys:
            matrix = get_table_matrix(child)
            if not matrix:
                continue
            header = matrix[0]
            
            if len(header) == 1 and ('Mô hình quan hệ dữ liệu' in header[0] or 'Mô hình' in header[0]):
                current_subsys['t0_table'] = matrix
            elif len(header) >= 4 and header[0] == 'STT' and header[1] == 'Thực thể' and header[2] == 'Tên bảng':
                current_subsys['t1_overview_table'] = matrix
                current_subsys['t1_rows'] = matrix[1:]
            elif len(header) == 12 and header[0] == 'STT' and header[1] == 'Tên trường' and header[2] == 'Tên cột':
                if current_detail_table:
                    current_detail_table['data_dictionary_table'] = matrix
                    for row in matrix[1:]:
                        col_obj = {
                            'stt': row[0] if len(row) > 0 else '',
                            'name_vi': row[1] if len(row) > 1 else '',
                            'col_name': row[2] if len(row) > 2 else '',
                            'data_type': row[3] if len(row) > 3 else '',
                            'nullable': row[4] if len(row) > 4 else '',
                            'unique': row[5] if len(row) > 5 else '',
                            'pf_key': row[6] if len(row) > 6 else '',
                            'default': row[7] if len(row) > 7 else '',
                            'desc': row[8] if len(row) > 8 else '',
                            'schema_table': row[9] if len(row) > 9 else '',
                            'source_field': row[10] if len(row) > 10 else '',
                            'etl_rules': row[11] if len(row) > 11 else '',
                        }
                        current_detail_table['columns'].append(col_obj)
            elif len(header) == 2 and header[0] == 'Tên trường' and header[1] == 'Tên cột':
                if current_detail_table:
                    current_detail_table['pk_table'] = matrix[1:]
            elif len(header) == 5 and header[0] == 'Tên trường' and header[1] == 'Tên cột' and 'Bảng tham chiếu' in header[2]:
                if current_detail_table:
                    current_detail_table['fk_table'] = matrix[1:]
                    
    _CACHED_SECTION2_DATA = {
        'subsystems': subsystems_found,
        'subsystems_dict': subsystems_dict,
    }
    return _CACHED_SECTION2_DATA


# ==============================================================================
# PYTEST TEST CASES
# ==============================================================================

def test_xml_strict_stress_parsing():
    """
    Stress-test XML strict parsing on every XML/rels file in docx zip archive.
    Ensures zero XML syntax errors, unclosed tags, or malformed namespaces.
    """
    strict_parser = etree.XMLParser(recover=False, resolve_entities=False, no_network=True)
    with zipfile.ZipFile(DOCX_PATH, 'r') as z:
        all_files = z.namelist()
        assert 'word/document.xml' in all_files, "word/document.xml missing from docx archive!"
        
        doc_xml_bytes = z.read('word/document.xml')
        assert len(doc_xml_bytes) > 40_000_000, f"document.xml suspiciously small: {len(doc_xml_bytes)} bytes"
        
        # Test word/document.xml
        root = etree.fromstring(doc_xml_bytes, parser=strict_parser)
        assert root.tag == '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}document'
        assert len(root.nsmap) >= 30, f"Expected >= 30 namespaces, got {len(root.nsmap)}"
        
        # Test all XML and rels files
        xml_files = [f for f in all_files if f.endswith('.xml') or f.endswith('.rels')]
        assert len(xml_files) >= 30
        for f in xml_files:
            content = z.read(f)
            etree.fromstring(content, parser=strict_parser)


def test_subsystem_count_and_sequence():
    """
    Verify all 17 subsystems present in exact expected sequence (2.1 to 2.17).
    """
    gt = get_ground_truth()
    sec2 = get_section2_data()
    subsystems = sec2['subsystems']
    
    assert len(subsystems) == 17, f"Expected 17 subsystems, got {len(subsystems)}"
    gt_codes = [s['subsys_code'] for s in gt]
    ex_codes = [s['code'] for s in subsystems]
    assert ex_codes == gt_codes, f"Codes mismatch:\nGT: {gt_codes}\nDOCX: {ex_codes}"
    
    for i, s in enumerate(subsystems, 1):
        assert s['index'] == i, f"Expected index {i}, got {s['index']} for {s['code']}"


def test_table0_erd_presence():
    """
    Verify all 17 subsystems have Table 0 (Mô hình quan hệ dữ liệu).
    """
    sec2 = get_section2_data()
    for s in sec2['subsystems']:
        assert s['t0_table'] is not None, f"Missing Table 0 in subsystem {s['code']}"
        header = s['t0_table'][0]
        assert 'Mô hình quan hệ dữ liệu' in header[0] or 'Mô hình' in header[0]


def test_table1_overview_completeness():
    """
    Verify all 17 Table 1 overview tables match ground truth exactly (274 total rows).
    """
    gt = get_ground_truth()
    sec2 = get_section2_data()
    
    total_t1_rows = 0
    gt_total_overview = sum(len(s.get('overview_tables', [])) for s in gt)
    
    for gt_sub, ex_sub in zip(gt, sec2['subsystems']):
        gt_ov = gt_sub.get('overview_tables', [])
        ex_t1 = ex_sub['t1_rows']
        total_t1_rows += len(ex_t1)
        
        assert len(ex_t1) == len(gt_ov), f"{ex_sub['code']}: DOCX rows {len(ex_t1)} != GT {len(gt_ov)}"
        for row_i, (g_row, e_row) in enumerate(zip(gt_ov, ex_t1)):
            gt_entity = g_row.get('entity', '')
            gt_pname = g_row.get('physical_name', '')
            assert e_row[1] == gt_entity, f"{ex_sub['code']} row {row_i+1} entity: expected '{gt_entity}', got '{e_row[1]}'"
            assert e_row[2] == gt_pname, f"{ex_sub['code']} row {row_i+1} physical_name: expected '{gt_pname}', got '{e_row[2]}'"
            
    assert total_t1_rows == 274, f"Expected 274 overview table rows, got {total_t1_rows}"
    assert total_t1_rows == gt_total_overview


def test_detail_tables_and_columns_integrity():
    """
    Verify all 378 detail tables and all 5,787 columns across all 12 metadata attributes.
    Detects any truncated cells, missing rows, empty tables, or encoding anomalies.
    """
    gt = get_ground_truth()
    sec2 = get_section2_data()
    
    total_detail_tables = 0
    total_columns = 0
    anomalies = []
    
    gt_total_detail = sum(len(s.get('detail_tables', [])) for s in gt)
    gt_total_cols = sum(sum(len(t.get('columns', [])) for t in s.get('detail_tables', [])) for s in gt)
    
    for gt_sub, ex_sub in zip(gt, sec2['subsystems']):
        gt_details = gt_sub.get('detail_tables', [])
        ex_details = ex_sub['detail_tables']
        total_detail_tables += len(ex_details)
        
        assert len(ex_details) == len(gt_details), f"{ex_sub['code']}: detail tables {len(ex_details)} != GT {len(gt_details)}"
        
        for t_idx, (gt_t, ex_t) in enumerate(zip(gt_details, ex_details)):
            gt_cols = gt_t.get('columns', [])
            ex_cols = ex_t['columns']
            total_columns += len(ex_cols)
            
            assert len(ex_cols) == len(gt_cols), f"{ex_sub['code']}.{gt_t.get('physical_name')}: cols {len(ex_cols)} != GT {len(gt_cols)}"
            
            # Check every column across all 12 attributes
            for c_idx, (gc, ec) in enumerate(zip(gt_cols, ex_cols)):
                for attr in ['stt', 'name_vi', 'col_name', 'data_type', 'nullable', 'unique', 'pf_key', 'default', 'desc', 'schema_table', 'source_field', 'etl_rules']:
                    gt_val = str(gc.get(attr, '')).strip()
                    ex_val = str(ec.get(attr, '')).strip()
                    if gt_val != ex_val:
                        anomalies.append(f"{ex_sub['code']}.{gt_t.get('physical_name')} col {c_idx+1} ({gc.get('col_name')}) [{attr}]: GT='{gt_val}' != DOCX='{ex_val}'")
                        
                # Check encoding anomalies
                for k, v in ec.items():
                    if '\ufffd' in v:
                        anomalies.append(f"U+FFFD in {ex_sub['code']}.{gt_t.get('physical_name')} col {c_idx+1} [{k}]")
                    if '??' in v:
                        anomalies.append(f"Mojibake '??' in {ex_sub['code']}.{gt_t.get('physical_name')} col {c_idx+1} [{k}]")

    assert total_detail_tables == 378, f"Expected 378 detail tables, got {total_detail_tables}"
    assert total_detail_tables == gt_total_detail
    assert total_columns == 5787, f"Expected 5,787 columns, got {total_columns}"
    assert total_columns == gt_total_cols
    assert len(anomalies) == 0, f"Found {len(anomalies)} column metadata discrepancies!\nFirst 5: {anomalies[:5]}"


def test_primary_key_tables_integrity():
    """
    Verify exactly 282 primary key tables in Section 2, matching ground truth pk_columns 100%.
    """
    gt = get_ground_truth()
    sec2 = get_section2_data()
    
    total_pk_tables = 0
    pk_mismatches = []
    
    for gt_sub, ex_sub in zip(gt, sec2['subsystems']):
        for gt_t, ex_t in zip(gt_sub.get('detail_tables', []), ex_sub['detail_tables']):
            gt_pks = gt_t.get('pk_columns', [])
            has_gt_pk = gt_pks and len(gt_pks) > 0 and gt_pks != ['Không có khóa chính.'] and gt_pks != ['N/A']
            ex_pk_table = ex_t['pk_table']
            
            if has_gt_pk:
                assert ex_pk_table is not None, f"{ex_sub['code']}.{gt_t.get('physical_name')}: missing PK table"
                total_pk_tables += 1
                assert len(ex_pk_table) == len(gt_pks), f"{ex_sub['code']}.{gt_t.get('physical_name')}: PK rows {len(ex_pk_table)} != {len(gt_pks)}"
                for p_idx, (g_pk, e_pk) in enumerate(zip(gt_pks, ex_pk_table)):
                    assert e_pk[1] == g_pk.get('col_name', ''), f"{ex_sub['code']}.{gt_t.get('physical_name')} PK col mismatch"
            else:
                assert ex_pk_table is None, f"{ex_sub['code']}.{gt_t.get('physical_name')}: unexpected PK table"
                
    assert total_pk_tables == 282, f"Expected 282 PK tables, got {total_pk_tables}"


def test_detail_table_metadata_lines():
    """
    Verify 100% of metadata lines (Mô tả, Đường dẫn lưu trữ, Phân vùng, Thời gian lưu trữ, Định dạng lưu trữ).
    """
    gt = get_ground_truth()
    sec2 = get_section2_data()
    
    meta_keys_map = {
        'Mô tả': 'description',
        'Đường dẫn lưu trữ': 'storage_path',
        'Phân vùng': 'partitions',
        'Thời gian lưu trữ': 'retention',
        'Định dạng lưu trữ': 'format',
    }
    
    meta_mismatches = []
    for gt_sub, ex_sub in zip(gt, sec2['subsystems']):
        for gt_t, ex_t in zip(gt_sub.get('detail_tables', []), ex_sub['detail_tables']):
            for docx_key, gt_key in meta_keys_map.items():
                gt_val = str(gt_t.get(gt_key, '') or '').strip()
                ex_val = str(ex_t['metadata'].get(docx_key, '') or '').strip()
                if gt_val != ex_val:
                    meta_mismatches.append(f"{ex_sub['code']}.{gt_t.get('physical_name')} [{docx_key}]: GT='{gt_val}' != DOCX='{ex_val}'")
                    
    assert len(meta_mismatches) == 0, f"Found {len(meta_mismatches)} metadata mismatches!\nFirst 5: {meta_mismatches[:5]}"


def test_baseline_v11_hash_and_preservation():
    """
    Verify baseline v1.1 hash is untouched and prefix/suffix elements are 100% byte-for-byte identical.
    """
    with open(V1_1_PATH, 'rb') as f:
        v1_1_hash = hashlib.sha256(f.read()).hexdigest()
    assert v1_1_hash == EXPECTED_V1_1_HASH, f"Baseline v1.1 altered! Got {v1_1_hash}"
    
    with zipfile.ZipFile(V1_1_PATH, 'r') as z1:
        v1_root = etree.fromstring(z1.read('word/document.xml'))
    v1_children = list(v1_root.find('w:body', NS))
    target_children = list(get_document_root().find('w:body', NS))
    
    assert len(v1_children) == 4566, f"Expected 4566 elements in v1.1, got {len(v1_children)}"
    assert len(target_children) == 10111, f"Expected 10111 elements in v1.2, got {len(target_children)}"
    
    # Prefix: elements 0..69
    for i in range(70):
        t1_c14n = etree.tostring(v1_children[i], method='c14n')
        t2_c14n = etree.tostring(target_children[i], method='c14n')
        assert t1_c14n == t2_c14n, f"Prefix element {i} differs!"
        
    # Suffix: elements 4524..4565 (last 42 elements)
    v1_suffix = v1_children[4524:]
    t2_suffix = target_children[-len(v1_suffix):]
    assert len(v1_suffix) == 42
    for i, (v1_el, t2_el) in enumerate(zip(v1_suffix, t2_suffix)):
        t1_c14n = etree.tostring(v1_el, method='c14n')
        t2_c14n = etree.tostring(t2_el, method='c14n')
        assert t1_c14n == t2_c14n, f"Suffix element {4524+i} differs!"


def main():
    print("=== CHALLENGER 1 ADVERSARIAL RUNNER ===")
    test_xml_strict_stress_parsing()
    print("PASS: test_xml_strict_stress_parsing")
    test_subsystem_count_and_sequence()
    print("PASS: test_subsystem_count_and_sequence")
    test_table0_erd_presence()
    print("PASS: test_table0_erd_presence")
    test_table1_overview_completeness()
    print("PASS: test_table1_overview_completeness")
    test_detail_tables_and_columns_integrity()
    print("PASS: test_detail_tables_and_columns_integrity")
    test_primary_key_tables_integrity()
    print("PASS: test_primary_key_tables_integrity")
    test_detail_table_metadata_lines()
    print("PASS: test_detail_table_metadata_lines")
    test_baseline_v11_hash_and_preservation()
    print("PASS: test_baseline_v11_hash_and_preservation")
    print("=== ALL ADVERSARIAL TESTS PASSED (100% EMPIRICAL CONFIRMATION) ===")


if __name__ == '__main__':
    main()
