"""Script cập nhật trực tiếp 10 phân hệ Datamart vào tài liệu chuẩn UBCKNN Q5
(UBCKNN_Q5_Tai lieu phan tich thiet ke_v1.0_20260429.docx) bảo toàn 100% template,
bìa, chữ ký, kiến trúc hệ thống, API, Web App mockup và styling.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor

import docx
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Inches, Pt

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

REPO_ROOT = Path(__file__).resolve().parents[4]
SKILL_DIR = REPO_ROOT / ".claude" / "skills" / "datamart-gen-docs"
OUTPUT_DIR = REPO_ROOT / "docs" / "output" / "datamart"
MASTER_DOCX_PATH = SKILL_DIR / "UBCKNN_Q5_Tai lieu phan tich thiet ke_v1.0_20260429.docx"

# Ensure mmdc in PATH
npm_appdata = Path(os.environ.get("APPDATA", "C:/Users/ADMIN/AppData/Roaming")) / "npm"
if npm_appdata.exists() and str(npm_appdata) not in os.environ.get("PATH", ""):
    os.environ["PATH"] = str(npm_appdata) + os.pathsep + os.environ.get("PATH", "")

MODULES = [
    ("TT", "1", "HOẠT ĐỘNG THANH TRA"),
    ("NHNCK", "2", "NGƯỜI HÀNH NGHỀ CHỨNG KHOÁN"),
    ("NDTNN", "3", "NHÀ ĐẦU TƯ NƯỚC NGOÀI"),
    ("QLCB", "4", "QUẢN LÝ CHÀO BÁN"),
    ("GSDC", "5", "GIÁM SÁT CÔNG TY ĐẠI CHÚNG"),
    ("GSTT", "6", "GIÁM SÁT THỊ TRƯỜNG"),
    ("QLQ", "7", "CÔNG TY QUẢN LÝ QUỸ (AMC)"),
    ("QLKD", "8", "HOẠT ĐỘNG CÔNG TY CHỨNG KHOÁN"),
    ("PTTT", "9", "PHÂN TÍCH THỊ TRƯỜNG"),
    ("TKNB", "10", "THỐNG KÊ THỊ TRƯỜNG"),
]


def render_mermaid(mmd_code: str, out_png: Path) -> bool:
    """Render 1 Mermaid code block sang PNG dùng mmdc."""
    out_png = out_png.resolve()
    out_png.parent.mkdir(parents=True, exist_ok=True)
    if out_png.exists() and out_png.stat().st_size > 0:
        return True

    mmdc = shutil.which("mmdc")
    if not mmdc:
        if (npm_appdata / "mmdc.cmd").exists():
            mmdc = str(npm_appdata / "mmdc.cmd")
        elif (npm_appdata / "mmdc.CMD").exists():
            mmdc = str(npm_appdata / "mmdc.CMD")
        elif (npm_appdata / "mmdc").exists():
            mmdc = str(npm_appdata / "mmdc")

    if not mmdc:
        print("[WARN] mmdc not found, diagram will be skipped", file=sys.stderr)
        return False

    with tempfile.NamedTemporaryFile(suffix=".mmd", delete=False, mode="w", encoding="utf-8") as f:
        f.write(mmd_code)
        tmp_mmd = Path(f.name)

    try:
        res = subprocess.run(
            [str(mmdc), "-i", str(tmp_mmd), "-o", str(out_png), "-b", "white", "-s", "2"],
            shell=True,
            capture_output=True, text=True
        )
        if res.returncode != 0:
            print(f"[WARN] mmdc render error for {out_png.name}: {res.stderr}", file=sys.stderr)
        return res.returncode == 0 and out_png.exists() and out_png.stat().st_size > 0
    finally:
        tmp_mmd.unlink(missing_ok=True)


def parse_module_pttk(md_path: Path, temp_img_dir: Path, mod_code: str, mod_idx: str, mod_name: str) -> list[dict]:
    """Phân tích cú pháp 1 file Markdown PTTK thành danh sách các phần tử dữ liệu."""
    text = md_path.read_text(encoding="utf-8")
    lines = text.splitlines()

    elements = []
    
    # 1. Heading cho Module: 3.1.X LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO ...
    elements.append({
        "type": "heading3",
        "text": f"3.1.{mod_idx}  LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO {mod_name}"
    })

    # 2. Heading: 3.1.X.1 Thông tin chung luồng đồng bộ
    elements.append({
        "type": "heading4",
        "text": f"3.1.{mod_idx}.1 Thông tin chung luồng đồng bộ"
    })

    in_info = False
    in_workflow = False
    subgroups = []
    current_subgroup = None

    idx = 0
    while idx < len(lines):
        line = lines[idx]
        stripped = line.strip()

        if re.search(r"^###\s*3\.[12]\.\d+\.1\b", stripped) or (stripped.startswith("###") and "Thông tin chung" in stripped):
            in_info = True
            in_workflow = False
            idx += 1
            continue

        if re.search(r"^###\s*3\.[12]\.\d+\.2\b", stripped) or (stripped.startswith("###") and "Luồng nghiệp vụ" in stripped):
            in_info = False
            in_workflow = True
            elements.append({
                "type": "heading4",
                "text": f"3.1.{mod_idx}.2 Luồng nghiệp vụ"
            })
            idx += 1
            continue

        if in_info:
            if stripped.startswith("- ") or stripped.startswith("* "):
                bullet_text = re.sub(r"^[-*]\s+", "", stripped).strip()
                bullet_text = re.sub(r"[*_`]", "", bullet_text)
                elements.append({
                    "type": "list_item",
                    "text": bullet_text
                })
            idx += 1
            continue

        if in_workflow:
            if stripped.startswith("#### "):
                group_title = stripped.replace("####", "").strip()
                group_title = re.sub(r"^3\.[12]\.\d+\.2\.\d+\s*", "", group_title)
                current_subgroup_idx = len(subgroups) + 1
                full_group_heading = f"3.1.{mod_idx}.2.{current_subgroup_idx} {group_title}"
                
                current_subgroup = {
                    "heading": full_group_heading,
                    "diagram_code": None,
                    "purpose": None,
                    "staging_atomic": [],
                    "atomic_datamart": []
                }
                subgroups.append(current_subgroup)
                idx += 1
                continue

            if stripped.startswith("```mermaid"):
                mmd_lines = []
                idx += 1
                while idx < len(lines) and not lines[idx].strip().startswith("```"):
                    mmd_lines.append(lines[idx])
                    idx += 1
                mmd_code = "\n".join(mmd_lines).strip()
                if current_subgroup:
                    current_subgroup["diagram_code"] = mmd_code
                idx += 1
                continue

            if "**Mục đích:**" in stripped or "Mục đích:" in stripped:
                purpose_text = re.sub(r"^\*{0,2}Mục đích:\*{0,2}\s*", "", stripped).strip()
                if current_subgroup:
                    current_subgroup["purpose"] = purpose_text
                idx += 1
                continue

            if "Staging → Atomic:" in stripped or "Staging -> Atomic:" in stripped:
                idx += 1
                while idx < len(lines):
                    l_sub = lines[idx].strip()
                    if "Atomic → Datamart:" in l_sub or "Atomic -> Datamart:" in l_sub or l_sub.startswith("####") or l_sub.startswith("###") or l_sub.startswith("##"):
                        break
                    if l_sub.startswith("- ") or l_sub.startswith("* "):
                        clean_item = re.sub(r"^[-*]\s+", "", l_sub).strip()
                        if current_subgroup:
                            current_subgroup["staging_atomic"].append(clean_item)
                    idx += 1
                continue

            if "Atomic → Datamart:" in stripped or "Atomic -> Datamart:" in stripped:
                idx += 1
                while idx < len(lines):
                    l_sub = lines[idx].strip()
                    if l_sub.startswith("####") or l_sub.startswith("###") or l_sub.startswith("##"):
                        break
                    if l_sub.startswith("- ") or l_sub.startswith("* "):
                        clean_item = re.sub(r"^[-*]\s+", "", l_sub).strip()
                        if current_subgroup:
                            current_subgroup["atomic_datamart"].append(clean_item)
                    idx += 1
                continue

        idx += 1

    # Thêm subgroups vào elements
    for sg_idx, sg in enumerate(subgroups, 1):
        elements.append({
            "type": "heading5",
            "text": sg["heading"]
        })
        
        # Render diagram nếu có
        if sg["diagram_code"]:
            img_path = temp_img_dir / f"diagram_{mod_code}_{sg_idx}.png"
            if not (img_path.exists() and img_path.stat().st_size > 0):
                render_mermaid(sg["diagram_code"], img_path)
            if img_path.exists() and img_path.stat().st_size > 0:
                elements.append({
                    "type": "image",
                    "path": str(img_path.resolve())
                })

        # Mục đích
        if sg["purpose"]:
            elements.append({
                "type": "purpose",
                "label": "Mục đích: ",
                "text": sg["purpose"]
            })

        # Mô tả luồng
        elements.append({
            "type": "flow_desc_header",
            "text": "Mô tả luồng:"
        })

        if sg["staging_atomic"]:
            elements.append({
                "type": "sub_header",
                "text": "Staging → Atomic:"
            })
            for item in sg["staging_atomic"]:
                elements.append({
                    "type": "desc_item",
                    "text": item
                })

        if sg["atomic_datamart"]:
            elements.append({
                "type": "sub_header",
                "text": "Atomic → Datamart:"
            })
            for item in sg["atomic_datamart"]:
                elements.append({
                    "type": "desc_item",
                    "text": item
                })

    return elements


def update_master_q5_document():
    print(f"=== BẮT ĐẦU CẬP NHẬT TÀI LIỆU CHUẨN UBCKNN Q5 ===")
    print(f"Template gốc: {MASTER_DOCX_PATH} ({MASTER_DOCX_PATH.stat().st_size:,} bytes)")

    if not MASTER_DOCX_PATH.exists():
        raise FileNotFoundError(f"Không tìm thấy template chuẩn tại {MASTER_DOCX_PATH}")

    temp_img_dir = OUTPUT_DIR / "temp_q5_images"
    temp_img_dir.mkdir(parents=True, exist_ok=True)

    # 1. Parse toàn bộ 10 module PTTK
    all_module_elements = []
    total_diagrams = 0
    for mod_code, mod_idx, mod_name in MODULES:
        md_file = OUTPUT_DIR / mod_code / f"DTM_{mod_code}_PTTK.md"
        print(f"Parsing module {mod_code} ({mod_name})...")
        elems = parse_module_pttk(md_file, temp_img_dir, mod_code, mod_idx, mod_name)
        img_count = sum(1 for e in elems if e["type"] == "image")
        total_diagrams += img_count
        print(f"  -> {mod_code}: {len(elems)} elements, {img_count} diagrams rendered.")
        all_module_elements.append((mod_code, elems))

    print(f"\nTổng số lưu đồ đã sinh và sẵn sàng chèn: {total_diagrams}/90 diagrams.")

    # 2. Mở file DOCX gốc
    doc = docx.Document(str(MASTER_DOCX_PATH))

    # 3. Định vị vị trí 3.1 trong tài liệu gốc
    p_etl_idx = None
    p_api_idx = None

    for i, p in enumerate(doc.paragraphs):
        if p.text.strip() == "Phân hệ ETL" and p.style.name.startswith("Heading"):
            p_etl_idx = i
        if p.text.strip().startswith("Phân hệ tích hợp dữ liệu") and p.style.name.startswith("Heading"):
            p_api_idx = i
            break

    if p_etl_idx is None or p_api_idx is None:
        raise ValueError(f"Không xác định được ranh giới Section 3.1: p_etl={p_etl_idx}, p_api={p_api_idx}")

    print(f"Vị trí Section 3.1: từ paragraph {p_etl_idx+1} đến {p_api_idx-1} (tổng {p_api_idx - p_etl_idx - 1} paragraphs cũ)")

    target_anchor = doc.paragraphs[p_api_idx]

    # 4. Chèn toàn bộ nội dung mới của 10 phân hệ trước target_anchor
    print("Đang chèn 10 phân hệ Datamart chuẩn hóa vào Section 3.1...")
    
    for mod_code, elems in all_module_elements:
        for el in elems:
            el_type = el["type"]
            
            if el_type == "heading3":
                p = target_anchor.insert_paragraph_before(el["text"], style="Heading 3")
            
            elif el_type == "heading4":
                p = target_anchor.insert_paragraph_before(el["text"], style="Heading 4")
            
            elif el_type == "heading5":
                p = target_anchor.insert_paragraph_before(el["text"], style="Heading 5")
            
            elif el_type == "list_item":
                p = target_anchor.insert_paragraph_before(el["text"], style="List Paragraph")
            
            elif el_type == "image":
                p = target_anchor.insert_paragraph_before("", style="Normal")
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                run = p.add_run()
                try:
                    run.add_picture(el["path"], width=Inches(6.0))
                except Exception as e:
                    print(f"[WARN] Không thể chèn ảnh {el['path']}: {e}", file=sys.stderr)
            
            elif el_type == "purpose":
                p = target_anchor.insert_paragraph_before("", style="Normal")
                r_label = p.add_run(el["label"])
                r_label.bold = True
                r_text = p.add_run(el["text"])
            
            elif el_type == "flow_desc_header":
                p = target_anchor.insert_paragraph_before("", style="Normal")
                r = p.add_run(el["text"])
                r.bold = True
            
            elif el_type == "sub_header":
                p = target_anchor.insert_paragraph_before("", style="Normal")
                r = p.add_run(el["text"])
                r.italic = True
            
            elif el_type == "desc_item":
                p = target_anchor.insert_paragraph_before("", style="List Paragraph")
                raw = el["text"]
                # Parse bold entity name: **Entity Name:** Description
                m_bold = re.match(r"^\*{0,2}(.*?)\*{0,2}:\s*(.*)$", raw)
                if m_bold:
                    ent_name = m_bold.group(1).replace("*", "").strip()
                    desc_body = m_bold.group(2).strip()
                    r1 = p.add_run(f"{ent_name}: ")
                    r1.bold = True
                    r2 = p.add_run(desc_body)
                else:
                    p.add_run(raw)

    # 5. Xóa các paragraph cũ từ p_etl_idx + 1 đến p_api_idx - 1
    print("Đang xóa các đoạn văn bản cũ của 3.1.1 - 3.1.10 cũ...")
    paragraphs_to_remove = doc.paragraphs[p_etl_idx + 1 : p_api_idx]
    for p in paragraphs_to_remove:
        p._p.getparent().remove(p._p)

    # 6. Lưu file kết quả
    out_docx_1 = OUTPUT_DIR / "UBCKNN_Q5_Tai_lieu_phan_tich_thiet_ke_v1.0_20260429.docx"
    out_docx_2 = OUTPUT_DIR / "UBCKNN_Q5_Tai_lieu_phan_tich_thiet_ke_Datamart_v1.0.docx"
    out_docx_skill = SKILL_DIR / "UBCKNN_Q5_Tai lieu phan tich thiet ke_v1.0_20260429.docx"

    doc.save(str(out_docx_1))
    print(f"\nSaved: {out_docx_1} ({out_docx_1.stat().st_size:,} bytes)")

    try:
        shutil.copy2(out_docx_1, out_docx_2)
        print(f"Saved copy: {out_docx_2}")
    except Exception as e:
        print(f"[INFO] Copy to {out_docx_2.name} skipped (file may be open in Word): {e}")

    try:
        shutil.copy2(out_docx_1, out_docx_skill)
        print(f"Saved template copy: {out_docx_skill}")
    except Exception as e:
        print(f"[INFO] Copy to {out_docx_skill.name} skipped: {e}")

    print(f"\n=== HOÀN TẤT CẬP NHẬT TÀI LIỆU CHUẨN Q5 ===")
    print(f"1. File xuất bản chính thức: {out_docx_1} ({out_docx_1.stat().st_size:,} bytes)")


if __name__ == "__main__":
    update_master_q5_document()
