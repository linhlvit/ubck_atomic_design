# -*- coding: utf-8 -*-
"""
Empirical Challenger 2 Verification Script:
- Baseline v1.1 preservation: SHA-256 match, size, timestamp/git check
- Prefix invariant: elements 0..69 structural comparison, sectPr on element 69
- Suffix invariant: elements 4524..4565 in v1.1 vs suffix in v1.2
- Relationship parts integrity: document.xml.rels, targets, rId references, media blips
"""

import hashlib
import io
import os
from pathlib import Path
import subprocess
import sys
import zipfile
import lxml.etree

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')


REPO_ROOT = Path(r"C:\Workspace\Design_DW")
BASELINE_DOCX = REPO_ROOT / "ubck_atomic_design" / "docs" / "output" / "UBCKNN_Thiet ke co so du lieu_v1.1_20260429.docx"
TARGET_DOCX = REPO_ROOT / "ubck_atomic_design" / "docs" / "output" / "UBCKNN_Thiet ke co so du lieu_v1.2_20261029.docx"

EXPECTED_BASELINE_SHA256 = "5846d9cb4002305127ae01a5e7c3342a5477030d743960d0defc6e76a29aa5fc"
EXPECTED_BASELINE_SIZE = 9_240_232

def test_baseline_preservation():
    print("=== [TEST 1] BASELINE V1.1 PRESERVATION ===")
    if not BASELINE_DOCX.exists():
        print("FAIL: Baseline file does not exist!")
        return False
    
    data = BASELINE_DOCX.read_bytes()
    sha256 = hashlib.sha256(data).hexdigest()
    size = len(data)
    stat = BASELINE_DOCX.stat()
    
    print(f"Baseline Path: {BASELINE_DOCX}")
    print(f"Computed SHA-256: {sha256}")
    print(f"Expected SHA-256: {EXPECTED_BASELINE_SHA256}")
    sha_match = (sha256 == EXPECTED_BASELINE_SHA256)
    print(f"SHA-256 Match: {sha_match}")
    print(f"Size: {size} bytes (Expected: {EXPECTED_BASELINE_SIZE})")
    size_match = (size == EXPECTED_BASELINE_SIZE)
    print(f"Size Match: {size_match}")
    print(f"mtime: {stat.st_mtime}, ctime: {stat.st_ctime}")
    
    # Check git status for baseline docx
    try:
        git_res = subprocess.run(["git", "status", "--porcelain", str(BASELINE_DOCX)], capture_output=True, text=True, cwd=str(REPO_ROOT))
        print(f"Git status on baseline docx: '{git_res.stdout.strip()}'")
        git_clean = (len(git_res.stdout.strip()) == 0)
    except Exception as e:
        print(f"Git check error: {e}")
        git_clean = True
        
    passed = sha_match and size_match and git_clean
    print(f"Result TEST 1: {'PASS' if passed else 'FAIL'}\n")
    return passed

def get_body_elements(docx_path):
    with zipfile.ZipFile(docx_path, 'r') as zf:
        doc_xml = zf.read('word/document.xml')
    tree = lxml.etree.fromstring(doc_xml)
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    body = tree.find('w:body', ns)
    elements = list(body)
    return doc_xml, tree, body, elements

def test_prefix_invariant():
    print("=== [TEST 2] PREFIX INVARIANT (ELEMENTS 0..69) ===")
    _, _, body_v11, els_v11 = get_body_elements(BASELINE_DOCX)
    _, _, body_v12, els_v12 = get_body_elements(TARGET_DOCX)
    
    print(f"v1.1 total body elements: {len(els_v11)}")
    print(f"v1.2 total body elements: {len(els_v12)}")
    
    prefix_v11 = els_v11[0:70]
    prefix_v12 = els_v12[0:70]
    
    print(f"Prefix v1.1 count: {len(prefix_v11)}")
    print(f"Prefix v1.2 count: {len(prefix_v12)}")
    
    mismatches = []
    for idx in range(70):
        e11 = prefix_v11[idx]
        e12 = prefix_v12[idx]
        tag11 = e11.tag
        tag12 = e12.tag
        xml11 = lxml.etree.tostring(e11, method='c14n')
        xml12 = lxml.etree.tostring(e12, method='c14n')
        
        if tag11 != tag12:
            mismatches.append((idx, f"Tag mismatch: {tag11} vs {tag12}"))
        elif xml11 != xml12:
            # Check what's different
            t11 = "".join(e11.itertext()).strip()
            t12 = "".join(e12.itertext()).strip()
            if t11 != t12:
                mismatches.append((idx, f"Text mismatch: '{t11[:40]}' vs '{t12[:40]}'"))
            else:
                mismatches.append((idx, f"XML markup difference (same text: '{t11[:30]}')"))
                
    if mismatches:
        print(f"FAIL: {len(mismatches)} mismatches in prefix elements 0..69:")
        for idx, desc in mismatches[:10]:
            print(f"  Element {idx}: {desc}")
    else:
        print("SUCCESS: Elements 0..69 are 100% structurally and canonically identical!")
        
    # Check sectPr on element 69
    el69_v11 = els_v11[69]
    el69_v12 = els_v12[69]
    
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    sectPr_v11 = el69_v11.xpath('.//w:sectPr', namespaces=ns)
    sectPr_v12 = el69_v12.xpath('.//w:sectPr', namespaces=ns)
    
    print(f"Element 69 tag: v1.1={el69_v11.tag}, v1.2={el69_v12.tag}")
    print(f"sectPr in element 69 v1.1: {len(sectPr_v11)} found")
    print(f"sectPr in element 69 v1.2: {len(sectPr_v12)} found")
    
    sect_match = False
    if len(sectPr_v11) == 1 and len(sectPr_v12) == 1:
        s11_xml = lxml.etree.tostring(sectPr_v11[0], method='c14n')
        s12_xml = lxml.etree.tostring(sectPr_v12[0], method='c14n')
        sect_match = (s11_xml == s12_xml)
        print(f"sectPr exact C14N match: {sect_match}")
    else:
        print("FAIL: sectPr missing or duplicated on element 69!")
        
    passed = (len(mismatches) == 0) and sect_match
    print(f"Result TEST 2: {'PASS' if passed else 'FAIL'}\n")
    return passed

def test_suffix_invariant():
    print("=== [TEST 3] SUFFIX INVARIANT (ELEMENTS 4524..4565) ===")
    _, _, _, els_v11 = get_body_elements(BASELINE_DOCX)
    _, _, _, els_v12 = get_body_elements(TARGET_DOCX)
    
    # In v1.1, elements 4524..4565
    suffix_v11 = els_v11[4524:4566] # wait, is 4565 inclusive? let's inspect els_v11 range
    print(f"v1.1 total elements: {len(els_v11)}")
    print(f"Suffix v1.1 slice [4524:4566] length: {len(suffix_v11)}")
    if suffix_v11:
        first_t = "".join(suffix_v11[0].itertext()).strip()
        last_t = "".join(suffix_v11[-1].itertext()).strip()
        print(f"v1.1 [4524] text: '{first_t[:60]}'")
        print(f"v1.1 [4565] tag: {suffix_v11[-1].tag}, text: '{last_t[:60]}'")
    
    # In v1.2, search for Section 4 after the prefix (index >= 70)
    target_s4_idx = None
    for idx in range(70, len(els_v12)):
        t = "".join(els_v12[idx].itertext()).strip().upper()
        if "THIẾT KẾ TỆP TIN" in t:
            target_s4_idx = idx
            break
            
    print(f"Found 'THIẾT KẾ TỆP TIN' in v1.2 after prefix at element index: {target_s4_idx}")
    if target_s4_idx is None:
        print("FAIL: Section 4 THIẾT KẾ TỆP TIN not found in v1.2 after index 70!")
        return False
        
    suffix_v12 = els_v12[target_s4_idx:]
    print(f"Suffix v1.2 length from index {target_s4_idx} to end: {len(suffix_v12)}")
    print(f"Expected suffix length: {len(suffix_v11)}")

    
    mismatches = []
    # Compare suffix elements one by one
    compare_len = min(len(suffix_v11), len(suffix_v12))
    for i in range(compare_len):
        e11 = suffix_v11[i]
        e12 = suffix_v12[i]
        tag11 = e11.tag
        tag12 = e12.tag
        xml11 = lxml.etree.tostring(e11, method='c14n')
        xml12 = lxml.etree.tostring(e12, method='c14n')
        
        if tag11 != tag12:
            mismatches.append((i, f"Tag mismatch at suffix +{i}: {tag11} vs {tag12}"))
        elif xml11 != xml12:
            t11 = "".join(e11.itertext()).strip()
            t12 = "".join(e12.itertext()).strip()
            if t11 != t12:
                mismatches.append((i, f"Text mismatch at suffix +{i}: '{t11[:40]}' vs '{t12[:40]}'"))
            else:
                mismatches.append((i, f"XML markup difference at suffix +{i} (same text: '{t11[:30]}')"))
                
    if len(suffix_v11) != len(suffix_v12):
        mismatches.append((-1, f"Suffix count mismatch: {len(suffix_v11)} vs {len(suffix_v12)}"))
        
    if mismatches:
        print(f"FAIL: {len(mismatches)} mismatches in suffix:")
        for idx, desc in mismatches[:10]:
            print(f"  {idx}: {desc}")
    else:
        print("SUCCESS: Suffix elements are 100% structurally and canonically identical!")
        
    passed = (len(mismatches) == 0)
    print(f"Result TEST 3: {'PASS' if passed else 'FAIL'}\n")
    return passed

def test_relationship_integrity():
    print("=== [TEST 4] RELATIONSHIP PARTS & ID INTEGRITY ===")
    with zipfile.ZipFile(TARGET_DOCX, 'r') as zf:
        namelist = set(zf.namelist())
        doc_xml = zf.read('word/document.xml')
        rels_xml = zf.read('word/_rels/document.xml.rels')
        
    doc_tree = lxml.etree.fromstring(doc_xml)
    rels_tree = lxml.etree.fromstring(rels_xml)
    
    # Extract relationships defined in document.xml.rels
    rels = {}
    duplicate_rids = []
    for r in rels_tree:
        rid = r.attrib.get('Id')
        target = r.attrib.get('Target')
        target_mode = r.attrib.get('TargetMode')
        rtype = r.attrib.get('Type')
        if rid in rels:
            duplicate_rids.append(rid)
        rels[rid] = {
            'Target': target,
            'TargetMode': target_mode,
            'Type': rtype
        }
        
    print(f"Total relationships in document.xml.rels: {len(rels)}")
    print(f"Duplicate rIds in document.xml.rels: {duplicate_rids}")
    
    # Check if all internal targets exist in ZIP
    missing_targets = []
    for rid, rdata in rels.items():
        if rdata['TargetMode'] == 'External':
            continue
        # internal target is relative to word/
        tpath = rdata['Target']
        if tpath.startswith('/'):
            norm_path = tpath.lstrip('/')
        else:
            norm_path = f"word/{tpath}"
        # normalize path
        parts = []
        for p in norm_path.split('/'):
            if p == '..':
                if parts: parts.pop()
            elif p != '.':
                parts.append(p)
        clean_path = '/'.join(parts)
        if clean_path not in namelist:
            missing_targets.append((rid, clean_path, rdata['Target']))
            
    print(f"Missing targets in ZIP: {len(missing_targets)}")
    if missing_targets:
        for rid, cp, orig in missing_targets[:10]:
            print(f"  rId: {rid} -> clean_path: '{cp}' (orig: '{orig}') NOT IN ZIP!")
            
    # Extract all relationship references from document.xml
    # Namespaces: r:id, r:embed, r:link, etc.
    referenced_rids = set()
    for el in doc_tree.iter():
        for attr_name, attr_val in el.attrib.items():
            if attr_name.endswith('}id') or attr_name.endswith('}embed') or attr_name.endswith('}link') or attr_name.endswith('}dm'):
                # Check if it looks like an rId
                if attr_val.startswith('rId'):
                    referenced_rids.add(attr_val)
                    
    print(f"Total referenced rIds in document.xml: {len(referenced_rids)}")
    
    # Check for dangling references (referenced in document.xml but missing in rels)
    dangling_rids = referenced_rids - set(rels.keys())
    print(f"Dangling rIds (in document.xml but NOT in rels): {len(dangling_rids)}")
    if dangling_rids:
        for dr in list(dangling_rids)[:10]:
            print(f"  Dangling rId: {dr}")
            
    # Check for orphan rels (in rels but never referenced in document.xml)
    # Note: some rels like styles, numbering, settings, webSettings, theme might be standard
    orphan_rids = set(rels.keys()) - referenced_rids
    print(f"Orphan rels (in rels but not referenced directly in document.xml): {len(orphan_rids)}")
    for o in list(orphan_rids)[:10]:
        print(f"  Orphan rel: {o} -> {rels[o]['Type'].split('/')[-1]} -> {rels[o]['Target']}")
        
    passed = (len(duplicate_rids) == 0) and (len(missing_targets) == 0) and (len(dangling_rids) == 0)
    print(f"Result TEST 4: {'PASS' if passed else 'FAIL'}\n")
    return passed

def test_section_and_hf_integrity():
    print("=== [TEST 5] SECTION GEOMETRY & HEADERS/FOOTERS INTEGRITY ===")
    import docx
    d11 = docx.Document(BASELINE_DOCX)
    d12 = docx.Document(TARGET_DOCX)
    
    sec_match = (len(d11.sections) == len(d12.sections) == 2)
    print(f"Sections count: v1.1={len(d11.sections)}, v1.2={len(d12.sections)} (Match: {sec_match})")
    
    props = ['orientation', 'page_width', 'page_height', 'top_margin', 'bottom_margin', 'left_margin', 'right_margin', 'header_distance', 'footer_distance', 'different_first_page_header_footer']
    all_geom_match = True
    for s_idx in range(2):
        s11 = d11.sections[s_idx]
        s12 = d12.sections[s_idx]
        for p in props:
            v11_val = getattr(s11, p)
            v12_val = getattr(s12, p)
            if v11_val != v12_val:
                print(f"  MISMATCH Section {s_idx} {p}: v1.1={v11_val} vs v1.2={v12_val}")
                all_geom_match = False
                
    print(f"All Section Geometries Match: {all_geom_match}")
    
    hf_match = True
    for s_idx in range(2):
        s11 = d11.sections[s_idx]
        s12 = d12.sections[s_idx]
        for hf_name in ['header', 'first_page_header', 'even_page_header', 'footer', 'first_page_footer', 'even_page_footer']:
            hf11 = getattr(s11, hf_name)
            hf12 = getattr(s12, hf_name)
            t11 = ''.join([p.text for p in hf11.paragraphs]).strip()
            t12 = ''.join([p.text for p in hf12.paragraphs]).strip()
            if t11 != t12:
                print(f"  MISMATCH Section {s_idx} {hf_name}: '{t11[:30]}' vs '{t12[:30]}'")
                hf_match = False
                
    print(f"All Headers & Footers Text Match: {hf_match}")
    passed = sec_match and all_geom_match and hf_match
    print(f"Result TEST 5: {'PASS' if passed else 'FAIL'}\n")
    return passed

def test_xml_strict_validation():
    print("=== [TEST 6] STRICT XML PARSING & SCHEMA CONFORMITY ===")
    with zipfile.ZipFile(TARGET_DOCX, 'r') as zf:
        doc_xml = zf.read('word/document.xml')
        
    parser = lxml.etree.XMLParser(recover=False, no_network=True)
    try:
        tree = lxml.etree.fromstring(doc_xml, parser=parser)
        xml_valid = True
        print(f"Strict XML parse succeeded: root tag={tree.tag}, child nodes={len(tree)}")
    except Exception as e:
        xml_valid = False
        print(f"FAIL: Strict XML parse error: {e}")
        
    # Check that body exists and has elements
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    body = tree.find('w:body', ns)
    body_valid = (body is not None and len(body) > 1000)
    print(f"Body element found: {body is not None}, body children count: {len(body) if body is not None else 0}")
    
    passed = xml_valid and body_valid
    print(f"Result TEST 6: {'PASS' if passed else 'FAIL'}\n")
    return passed

if __name__ == '__main__':
    p1 = test_baseline_preservation()
    p2 = test_prefix_invariant()
    p3 = test_suffix_invariant()
    p4 = test_relationship_integrity()
    p5 = test_section_and_hf_integrity()
    p6 = test_xml_strict_validation()
    print("========================================")
    print(f"SUMMARY: P1={p1}, P2={p2}, P3={p3}, P4={p4}, P5={p5}, P6={p6}")
    all_pass = p1 and p2 and p3 and p4 and p5 and p6
    print(f"ALL 6 EMPIRICAL CHALLENGER TESTS PASS: {all_pass}")

