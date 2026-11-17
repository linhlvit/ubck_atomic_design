"""Ghép Mục 3.1 (Nhóm chức năng ETL) của 11 phân hệ Datamart vào quyển PTTK theo BẢN MẪU HIỆN HÀNH
(doc_registry.PTTK_TEMPLATE_NAME — bản Viettel review v1.2), bảo toàn 100% phần còn lại của bản mẫu:
bìa, chữ ký, kiến trúc hệ thống, API, Web App mockup, style.

Nguồn nội dung: docs/output/datamart/{MODULE}/DTM_{MODULE}_PTTK.md (đã duyệt ở Phase 2).
Danh sách/thứ tự/tên phân hệ, 5 tầng luồng ETL và đường dẫn bản mẫu lấy từ doc_registry.py.

Luồng 5 tầng (Data Modeler chốt 2026-11-17; comment review #535/#536 trên bản mẫu):
    Staging → ODS → Atomic → Datamart (Dim, Fact) → ClickHouse (bảng phẳng)
ODS là bản 1:1 của Staging — script kiểm máy từng diagram (check_flow_tiers).
Markdown còn 3 tầng kiểu cũ ('Staging → Atomic') vẫn ghép được nhưng bị cảnh báo; --strict biến cảnh báo thành lỗi.

Lưu ý comment review: comment neo trong Mục 3.1 CŨ của bản mẫu bị loại cùng nội dung cũ (script in danh sách id);
comment neo ngoài Mục 3.1 được giữ nguyên.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import docx
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

sys.path.insert(0, str(Path(__file__).resolve().parent))
import doc_registry as R  # noqa: E402

REPO_ROOT = R.REPO_ROOT
SKILL_DIR = R.SKILL_DIR
OUTPUT_DIR = R.OUTPUT_DIR
# Bản mẫu đầu vào = bản hiện hành trong registry (lùi về bản cũ nếu máy chưa có, kèm cảnh báo)
DEFAULT_INPUT_DOCX_PATH = R.find_template("pttk", warn=False) or R.current_template("pttk")
# Tên phát hành (phiên bản/ngày) do người dùng đặt qua --output-docx; mặc định ghi bản nháp cạnh các quyển khác
DEFAULT_OUTPUT_DOCX_PATH = REPO_ROOT / "docs" / "output" / "UBCKNN_Tai_lieu_phan_tich_thiet_ke_generated.docx"
MASTER_DOCX_PATH = DEFAULT_INPUT_DOCX_PATH

# Ensure mmdc in PATH
npm_appdata = Path(os.environ.get("APPDATA", "C:/Users/ADMIN/AppData/Roaming")) / "npm"
if npm_appdata.exists() and str(npm_appdata) not in os.environ.get("PATH", ""):
    os.environ["PATH"] = str(npm_appdata) + os.pathsep + os.environ.get("PATH", "")

# (mã module, số mục X của 3.1.X, tên trong tiêu đề) — lấy từ registry, KHÔNG khai lại ở đây
MODULES = [(m.code, str(m.idx), m.pttk_name) for m in R.MODULES]

_W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
_STEP_LINE = re.compile(
    r"^(Staging|ODS|Atomic|Datamart)\s*(?:→|->)\s*(ODS|Atomic|Datamart|ClickHouse)$"
)
_SUBGRAPH = re.compile(r"^\s*subgraph\s+(\w+)\s*$")
_NODE = re.compile(r"^\s*(\w+)\[\"([^\"]*)\"\]\s*$")
_EDGE = re.compile(r"^\s*(\w+)\s*-->\s*(\w+)\s*$")


def flow_step_label(line: str) -> str | None:
    """'*Staging → ODS:*' / '**ODS -> Atomic:**' / 'Atomic → Datamart:' → nhãn chuẩn 'A → B'; không phải dòng bước → None."""
    t = line.strip().strip("*_").strip().rstrip(":").strip().strip("*_").strip()
    m = _STEP_LINE.match(t)
    return f"{m.group(1)} → {m.group(2)}" if m else None


def parse_flowchart(diagram_code: str) -> tuple[dict[str, dict[str, str]], list[tuple[str, str]]]:
    """Mermaid flowchart → ({subgraph: {node_id: label}}, [(src_id, dst_id), ...])."""
    tiers: dict[str, dict[str, str]] = {}
    edges: list[tuple[str, str]] = []
    cur = None
    for ln in diagram_code.splitlines():
        m = _SUBGRAPH.match(ln)
        if m:
            cur = m.group(1)
            tiers.setdefault(cur, {})
            continue
        if ln.strip() == "end":
            cur = None
            continue
        m = _NODE.match(ln)
        if m and cur:
            tiers[cur][m.group(1)] = m.group(2)
            continue
        m = _EDGE.match(ln)
        if m:
            edges.append((m.group(1), m.group(2)))
    return tiers, edges


def check_flow_tiers(mod_code: str, heading: str, diagram_code: str | None, step_labels: list[str]) -> list[str]:
    """Đối chiếu 1 nhóm thông tin với chuẩn 5 tầng của registry + luật 'ODS 1:1 Staging'. Trả về danh sách cảnh báo."""
    warns: list[str] = []
    where = f"{mod_code} | {heading}"
    legacy = [l for l in step_labels if l in R.LEGACY_FLOW_STEP_LABELS]
    if legacy:
        warns.append(f"{where}: còn bước kiểu cũ {legacy} (3 tầng) — tách thành 'Staging → ODS' + 'ODS → Atomic'")
    missing = [l for l in R.FLOW_STEP_LABELS if l not in step_labels]
    if missing:
        warns.append(f"{where}: thiếu đoạn mô tả {missing}")
    if not diagram_code:
        warns.append(f"{where}: không có diagram mermaid")
        return warns
    tiers, edges = parse_flowchart(diagram_code)
    miss_sub = [t for t in R.FLOW_TIERS if t not in tiers]
    if miss_sub:
        warns.append(f"{where}: diagram thiếu subgraph {miss_sub} (đang có {list(tiers)})")
    extra_sub = [t for t in tiers if t not in R.FLOW_TIERS]
    if extra_sub:
        warns.append(f"{where}: diagram có subgraph ngoài chuẩn {extra_sub}")
    # ODS là bản 1:1 của Staging: mỗi node Staging 'SRC.TABLE' có đúng 1 node ODS 'ODS.SRC.TABLE' và 1 cạnh nối tới nó
    if "Staging" in tiers and "ODS" in tiers:
        stg, ods = tiers["Staging"], tiers["ODS"]
        want = {R.ods_label(lbl): sid for sid, lbl in stg.items()}
        have = {lbl: oid for oid, lbl in ods.items()}
        lack = sorted(set(want) - set(have))
        surplus = sorted(set(have) - set(want))
        if lack:
            warns.append(f"{where}: ODS không 1:1 với Staging — thiếu node ODS {lack}")
        if surplus:
            warns.append(f"{where}: ODS không 1:1 với Staging — node ODS không có bảng Staging tương ứng {surplus}")
        edge_set = set(edges)
        for lbl, sid in want.items():
            oid = have.get(lbl)
            if oid and (sid, oid) not in edge_set:
                warns.append(f"{where}: thiếu cạnh {sid} --> {oid} (Staging → ODS 1:1)")
        atomic_ids = set(tiers.get("Atomic", {}))
        for sid in stg:
            if any(src == sid and dst in atomic_ids for src, dst in edges):
                warns.append(f"{where}: cạnh nhảy cóc {sid} --> Atomic (phải đi qua ODS)")
    # Tầng ClickHouse: nhãn phải ở schema dwh_prod, và chỉ nhận cạnh từ tầng Datamart
    if "ClickHouse" in tiers:
        prefix = R.SCHEMA_CLICKHOUSE + "."
        bad = [lbl for lbl in tiers["ClickHouse"].values() if not lbl.startswith(prefix)]
        if bad:
            warns.append(f"{where}: node ClickHouse không ở schema {R.SCHEMA_CLICKHOUSE}: {bad}")
        dm_ids = set(tiers.get("Datamart", {}))
        for cid in tiers["ClickHouse"]:
            srcs = [src for src, dst in edges if dst == cid]
            if not srcs:
                warns.append(f"{where}: bảng phẳng {cid} không có cạnh từ bảng Datamart nào")
            elif any(src not in dm_ids for src in srcs):
                warns.append(f"{where}: bảng phẳng {cid} nhận cạnh từ node ngoài tầng Datamart")
        # Datamart (Dim, Fact) → bảng phẳng: Dim và Fact đứng cạnh nhau trong tầng Datamart và CÙNG nối sang bảng phẳng
        # (bảng phẳng = Fact JOIN Dim). Cạnh Dim --> Fact nội tầng kéo Dim sang cột Atomic làm vỡ bố cục 5 cột.
        inner = [(a, b) for a, b in edges if a in dm_ids and b in dm_ids]
        if inner:
            warns.append(f"{where}: cạnh nội tầng Datamart {inner} — đổi thành Dim --> bảng phẳng ClickHouse")
    return warns


def render_mermaid(mmd_code: str, out_png: Path) -> bool:
    """Render 1 Mermaid code block sang PNG dùng mmdc với độ nét cao."""
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
        flags = subprocess.CREATE_NO_WINDOW if sys.platform == "win32" else 0
        res = subprocess.run(
            [str(mmdc), "-i", str(tmp_mmd), "-o", str(out_png), "-b", "white", "-s", "2"],
            capture_output=True, text=True,
            creationflags=flags
        )
        if res.returncode != 0:
            print(f"[WARN] mmdc render error for {out_png.name}: {res.stderr}", file=sys.stderr)
        return res.returncode == 0 and out_png.exists() and out_png.stat().st_size > 0
    finally:
        tmp_mmd.unlink(missing_ok=True)


def parse_bullet_item(raw_text: str) -> tuple[str, str]:
    """Phân tách chính xác tên Entity (in đậm) và phần giải thích (thường) từ 1 dòng bullet."""
    raw_text = raw_text.strip()
    
    # Case 1: **Entity Name:** Description OR **Entity Name**: Description
    m = re.match(r"^\*{2}(.*?)\*{2}:?\s*(.*)$", raw_text)
    if m:
        ent = m.group(1).strip().rstrip(":")
        desc = m.group(2).strip().lstrip(":")
        desc = re.sub(r"^\*{1,2}\s*", "", desc)
        return ent, desc
    
    # Case 2: Entity Name: Description
    m2 = re.match(r"^(.*?):\s*(.*)$", raw_text)
    if m2:
        ent = m2.group(1).replace("*", "").strip()
        desc = m2.group(2).replace("**", "").strip()
        return ent, desc
    
    return "", raw_text.replace("**", "").strip()


def parse_module_pttk(md_path: Path, temp_img_dir: Path, mod_code: str, mod_idx: str, mod_name: str,
                      warnings: list[str] | None = None, render: bool = True) -> list[dict]:
    """Phân tích cú pháp 1 file Markdown PTTK thành danh sách các phần tử dữ liệu chuẩn hóa.

    Các đoạn mô tả luồng đọc THEO NHÃN BƯỚC (flow_step_label) nên nhận cả 5 tầng chuẩn lẫn 3 tầng kiểu cũ,
    giữ đúng thứ tự xuất hiện trong Markdown. Cảnh báo lệch chuẩn 5 tầng được nối vào `warnings`.
    """
    text = md_path.read_text(encoding="utf-8")
    lines = text.splitlines()
    elements = []

    # 1. Heading cho Module — đúng dạng bản mẫu v1.2: "3.1.X  Luồng đồng bộ dữ liệu cho nhóm báo cáo {tên}"
    elements.append({
        "type": "heading3",
        "text": R.pttk_module_heading(R.get_module(mod_code)),
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
    current_step = None  # danh sách bullet của bước luồng đang đọc

    def is_h3(st: str) -> bool:
        return st.startswith("###") and not st.startswith("####")

    idx = 0
    while idx < len(lines):
        line = lines[idx]
        stripped = line.strip()

        if re.search(r"^###\s*3\.[12]\.\d+\.1\b", stripped) or (is_h3(stripped) and "Thông tin chung" in stripped):
            in_info = True
            in_workflow = False
            idx += 1
            continue

        if re.search(r"^###\s*3\.[12]\.\d+\.2\b", stripped) or (is_h3(stripped) and "Luồng nghiệp vụ" in stripped):
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
                raw_bullet = re.sub(r"^[-*]\s+", "", stripped).strip()
                ent_name, desc_body = parse_bullet_item(raw_bullet)
                elements.append({
                    "type": "info_item",
                    "label": f"{ent_name}: " if ent_name else "",
                    "value": desc_body
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
                    "steps": [],  # [(nhãn bước 'A → B', [bullet, ...]), ...] theo thứ tự trong Markdown
                }
                current_step = None
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

            if "**Mục đích:**" in stripped or stripped.startswith("Mục đích:"):
                purpose_text = re.sub(r"^\*{0,2}Mục đích:\*{0,2}\s*", "", stripped).strip()
                purpose_text = purpose_text.replace("**", "").strip()
                if current_subgroup:
                    current_subgroup["purpose"] = purpose_text
                current_step = None
                idx += 1
                continue

            step = flow_step_label(stripped)
            if step is not None:
                current_step = []
                if current_subgroup:
                    current_subgroup["steps"].append((step, current_step))
                idx += 1
                continue

            if current_step is not None and (stripped.startswith("- ") or stripped.startswith("* ")):
                current_step.append(re.sub(r"^[-*]\s+", "", stripped).strip())
                idx += 1
                continue

        idx += 1

    # Thêm subgroups vào elements
    for sg_idx, sg in enumerate(subgroups, 1):
        elements.append({
            "type": "heading5",
            "text": sg["heading"]
        })

        if warnings is not None:
            warnings.extend(check_flow_tiers(mod_code, sg["heading"], sg["diagram_code"], [lbl for lbl, _ in sg["steps"]]))

        # Render diagram nếu có — tên file kèm hash nội dung để sửa diagram là render lại (không dính cache cũ)
        if sg["diagram_code"] and render:
            digest = hashlib.sha1(sg["diagram_code"].encode("utf-8")).hexdigest()[:10]
            img_path = temp_img_dir / f"diagram_{mod_code}_{sg_idx}_{digest}.png"
            if not (img_path.exists() and img_path.stat().st_size > 0):
                render_mermaid(sg["diagram_code"], img_path)
            if img_path.exists() and img_path.stat().st_size > 0:
                elements.append({
                    "type": "image",
                    "path": str(img_path.resolve())
                })
            elif warnings is not None:
                warnings.append(f"{mod_code} | {sg['heading']}: mmdc không render được diagram — nhóm này sẽ THIẾU hình")

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

        for step_label, items in sg["steps"]:
            if not items:
                continue
            elements.append({
                "type": "sub_header",
                "text": f"{step_label}:"
            })
            for item in items:
                elements.append({
                    "type": "desc_item",
                    "text": item
                })

    return elements


def drop_unbalanced_comment_marks(doc) -> list[str]:
    """Sau khi xóa đoạn cũ: gỡ dấu neo comment bị lệch cặp (có Start thiếu End, hoặc có range mà mất reference).

    Comment điểm (chỉ có commentReference) là hợp lệ và được giữ. Trả về danh sách id đã gỡ.
    """
    body = doc.element.body
    wid = f"{{{_W_NS}}}id"
    marks: dict[str, dict[str, list]] = {}
    for kind in ("commentRangeStart", "commentRangeEnd", "commentReference"):
        for el in body.iter(f"{{{_W_NS}}}{kind}"):
            marks.setdefault(el.get(wid), {}).setdefault(kind, []).append(el)
    dropped = []
    for cid, d in marks.items():
        has_s, has_e, has_r = "commentRangeStart" in d, "commentRangeEnd" in d, "commentReference" in d
        if (has_s and has_e and has_r) or (not has_s and not has_e and has_r):
            continue
        for kind, els in d.items():
            for el in els:
                target = el.getparent() if kind == "commentReference" else el  # reference nằm trong 1 w:r riêng
                if target.getparent() is not None:
                    target.getparent().remove(target)
        dropped.append(cid)
    return dropped


def comment_ids_in(paragraphs) -> set[str]:
    ids: set[str] = set()
    for p in paragraphs:
        for kind in ("commentRangeStart", "commentRangeEnd", "commentReference"):
            for el in p._p.iter(f"{{{_W_NS}}}{kind}"):
                ids.add(el.get(f"{{{_W_NS}}}id"))
    return ids


def format_paragraph(p, style_name="Normal", space_before=Pt(0), space_after=Pt(3), line_spacing=1.15, left_indent=Pt(0), first_line_indent=Pt(0), align=None, keep_with_next=False):
    """Thiết lập chính xác các thông số lề và khoảng cách cho đoạn văn bản, triệt tiêu hoàn toàn hanging indent từ style gốc."""
    p.style = style_name
    pf = p.paragraph_format
    pf.space_before = space_before
    pf.space_after = space_after
    pf.line_spacing = line_spacing
    pf.left_indent = left_indent
    pf.first_line_indent = first_line_indent
    pf.keep_with_next = keep_with_next
    if align is not None:
        p.alignment = align
    
    # Ghi đè trực tiếp thẻ w:ind trong XML của đoạn để chặn hoàn toàn thuộc tính hanging âm từ style gốc
    pPr = p._p.get_or_add_pPr()
    ind = pPr.find(qn("w:ind"))
    if ind is None:
        ind = OxmlElement("w:ind")
        pPr.append(ind)
    
    left_dxa = int(left_indent.pt * 20) if left_indent is not None else 0
    first_dxa = int(first_line_indent.pt * 20) if first_line_indent is not None else 0
    
    ind.set(qn("w:left"), str(left_dxa))
    if first_dxa < 0:
        ind.set(qn("w:hanging"), str(-first_dxa))
        ind.attrib.pop(qn("w:firstLine"), None)
    else:
        ind.set(qn("w:firstLine"), str(first_dxa))
        ind.attrib.pop(qn("w:hanging"), None)


def add_text_run(p, text, font_name="Times New Roman", font_size=Pt(12), bold=False, italic=False, color=None):
    """Thêm một Run với font Times New Roman và định dạng đồng nhất."""
    run = p.add_run(text)
    run.font.name = font_name
    run.font.size = font_size
    run.bold = bold
    run.italic = italic
    if color:
        run.font.color.rgb = color
    
    rPr = run._r.get_or_add_rPr()
    rFonts = rPr.find(qn("w:rFonts"))
    if rFonts is None:
        rFonts = OxmlElement("w:rFonts")
        rPr.append(rFonts)
    rFonts.set(qn("w:ascii"), font_name)
    rFonts.set(qn("w:hAnsi"), font_name)
    rFonts.set(qn("w:cs"), font_name)
    rFonts.set(qn("w:eastAsia"), font_name)
    return run


def update_master_q5_document(
    input_docx: Path | str | None = None,
    output_docx: Path | str | None = None,
    strict: bool = False,
) -> Path:
    input_docx_path = Path(input_docx).resolve() if input_docx else DEFAULT_INPUT_DOCX_PATH.resolve()
    output_docx_path = Path(output_docx).resolve() if output_docx else DEFAULT_OUTPUT_DOCX_PATH.resolve()

    if not input_docx_path.exists():
        raise FileNotFoundError(f"Không tìm thấy template chuẩn tại {input_docx_path}")

    if input_docx_path == output_docx_path:
        raise ValueError(
            f"Lỗi an toàn: Tệp đầu ra ({output_docx_path}) trùng với tệp mẫu gốc. "
            "Tuyệt đối không được phép ghi đè template gốc!"
        )

    # 1. Đo lường SHA-256 ban đầu của template gốc
    input_bytes = input_docx_path.read_bytes()
    sha_before = hashlib.sha256(input_bytes).hexdigest()

    print(f"=== BẮT ĐẦU CẬP NHẬT TÀI LIỆU CHUẨN UBCKNN Q5 ===")
    print(f"Template gốc: {input_docx_path} ({len(input_bytes):,} bytes)")
    print(f"SHA-256 gốc (trước khi thực hiện): {sha_before}")
    print(f"Tệp đích dự kiến: {output_docx_path}")

    temp_img_dir = OUTPUT_DIR / "temp_q5_images"
    temp_img_dir.mkdir(parents=True, exist_ok=True)

    # 2. Parse toàn bộ module PTTK theo registry (11 phân hệ, thứ tự 3.1.1 → 3.1.11)
    all_module_elements = []
    total_diagrams = 0
    total_groups = 0
    tier_warnings: list[str] = []
    for mod_code, mod_idx, mod_name in MODULES:
        md_file = OUTPUT_DIR / mod_code / f"DTM_{mod_code}_PTTK.md"
        if not md_file.exists():
            raise FileNotFoundError(f"Thiếu {md_file} — chạy Phase 1 (gen Markdown PTTK) cho module {mod_code} trước.")
        print(f"Parsing module {mod_code} ({mod_name})...")
        elems = parse_module_pttk(md_file, temp_img_dir, mod_code, mod_idx, mod_name, warnings=tier_warnings)
        img_count = sum(1 for e in elems if e["type"] == "image")
        grp_count = sum(1 for e in elems if e["type"] == "heading5")
        total_diagrams += img_count
        total_groups += grp_count
        print(f"  -> {mod_code}: {len(elems)} elements, {grp_count} nhóm thông tin, {img_count} diagrams rendered.")
        all_module_elements.append((mod_code, elems))

    print(f"\nTổng số lưu đồ đã sinh và sẵn sàng chèn: {total_diagrams}/{total_groups} nhóm thông tin.")
    if tier_warnings:
        mods_bad = sorted({w.split(" | ")[0] for w in tier_warnings})
        print(f"\n[WARN] {len(tier_warnings)} điểm lệch chuẩn 5 tầng ({' → '.join(R.FLOW_TIERS)}) ở module: {', '.join(mods_bad)}", file=sys.stderr)
        for w in tier_warnings[:40]:
            print(f"   - {w}", file=sys.stderr)
        if len(tier_warnings) > 40:
            print(f"   … và {len(tier_warnings) - 40} cảnh báo nữa", file=sys.stderr)
        if strict:
            raise SystemExit("❌ --strict: Markdown PTTK chưa đạt chuẩn 5 tầng — sinh lại Phase 1 cho các module trên rồi chạy lại.")

    # 3. Đọc file DOCX gốc vào memory từ input_bytes để bảo toàn và tránh lock
    doc_stream = io.BytesIO(input_bytes)
    doc = docx.Document(doc_stream)

    # 4. Định vị vị trí 3.1 trong tài liệu gốc
    p_etl_idx = None
    p_api_idx = None

    all_paragraphs = doc.paragraphs
    for open_title, close_prefix in R.PTTK_SECTION_ANCHORS:
        p_etl_idx = p_api_idx = None
        for i, p in enumerate(all_paragraphs):
            if not p.style.name.startswith("Heading"):
                continue
            t = p.text.strip()
            if p_etl_idx is None and t == open_title:
                p_etl_idx = i
            elif p_etl_idx is not None and t.startswith(close_prefix):
                p_api_idx = i
                break
        if p_etl_idx is not None and p_api_idx is not None:
            print(f"Ranh giới Mục 3.1: '{open_title}' … '{close_prefix}…'")
            break

    if p_etl_idx is None or p_api_idx is None:
        raise ValueError(
            f"Không xác định được ranh giới Section 3.1 theo doc_registry.PTTK_SECTION_ANCHORS "
            f"{R.PTTK_SECTION_ANCHORS}: p_etl={p_etl_idx}, p_api={p_api_idx}"
        )

    print(f"Vị trí Section 3.1: từ paragraph {p_etl_idx+1} đến {p_api_idx-1} (tổng {p_api_idx - p_etl_idx - 1} paragraphs cũ)")

    # Chuẩn hóa paragraph tiêu đề 'Phân hệ ETL' để thẳng hàng tuyệt đối với lề trái
    p_etl = all_paragraphs[p_etl_idx]
    p_etl_pPr = p_etl._p.get_or_add_pPr()
    p_etl_ind = p_etl_pPr.find(qn("w:ind"))
    if p_etl_ind is not None:
        p_etl_pPr.remove(p_etl_ind)

    target_anchor = all_paragraphs[p_api_idx]
    old_section_paragraphs = all_paragraphs[p_etl_idx + 1 : p_api_idx]

    # 5. Chèn toàn bộ nội dung mới của 10 phân hệ trước target_anchor với styling chuẩn mực
    print(f"Đang chèn {len(all_module_elements)} phân hệ Datamart chuẩn hóa vào Section 3.1...")
    
    for mod_code, elems in all_module_elements:
        for el in elems:
            el_type = el["type"]
            
            # --- Heading 3: Module (3.1.x LUỒNG ĐỒNG BỘ DỮ LIỆU CHO NHÓM BÁO CÁO...) ---
            if el_type == "heading3":
                p = target_anchor.insert_paragraph_before("", style="Heading 3")
                format_paragraph(p, style_name="Heading 3", space_before=Pt(14), space_after=Pt(6), line_spacing=1.15, left_indent=Pt(0), first_line_indent=Pt(0), keep_with_next=True)
                add_text_run(p, el["text"], font_size=Pt(13), bold=True, italic=False)
            
            # --- Heading 4: Section (3.1.x.1 Thông tin chung / 3.1.x.2 Luồng nghiệp vụ) ---
            elif el_type == "heading4":
                p = target_anchor.insert_paragraph_before("", style="Heading 4")
                format_paragraph(p, style_name="Heading 4", space_before=Pt(10), space_after=Pt(4), line_spacing=1.15, left_indent=Pt(0), first_line_indent=Pt(0), keep_with_next=True)
                add_text_run(p, el["text"], font_size=Pt(12), bold=True, italic=False)
            
            # --- Info items under 3.1.x.1 ---
            elif el_type == "info_item":
                p = target_anchor.insert_paragraph_before("", style="Normal")
                format_paragraph(p, style_name="Normal", space_before=Pt(1), space_after=Pt(2.5), line_spacing=1.15, left_indent=Pt(18), first_line_indent=Pt(-14))
                add_text_run(p, "•  ", font_size=Pt(12), bold=False)
                if el["label"]:
                    add_text_run(p, el["label"], font_size=Pt(12), bold=True)
                if el["value"]:
                    add_text_run(p, el["value"], font_size=Pt(12), bold=False)

            # --- Heading 5: Subgroup (3.1.x.2.y Nhóm thông tin...) ---
            elif el_type == "heading5":
                p = target_anchor.insert_paragraph_before("", style="Heading 5")
                format_paragraph(p, style_name="Heading 5", space_before=Pt(10), space_after=Pt(4), line_spacing=1.15, left_indent=Pt(0), first_line_indent=Pt(0), keep_with_next=True)
                add_text_run(p, el["text"], font_size=Pt(12), bold=True, italic=True)
            
            # --- Diagram image ---
            elif el_type == "image":
                p = target_anchor.insert_paragraph_before("", style="Normal")
                format_paragraph(p, style_name="Normal", space_before=Pt(6), space_after=Pt(6), left_indent=Pt(0), first_line_indent=Pt(0), align=WD_ALIGN_PARAGRAPH.CENTER)
                run = p.add_run()
                try:
                    run.add_picture(el["path"], width=Inches(6.2))
                except Exception as e:
                    print(f"[WARN] Không thể chèn ảnh {el['path']}: {e}", file=sys.stderr)
            
            # --- Purpose ---
            elif el_type == "purpose":
                p = target_anchor.insert_paragraph_before("", style="Normal")
                format_paragraph(p, style_name="Normal", space_before=Pt(4), space_after=Pt(4), line_spacing=1.15, left_indent=Pt(0), first_line_indent=Pt(0))
                add_text_run(p, el["label"], font_size=Pt(12), bold=True)
                add_text_run(p, el["text"], font_size=Pt(12), bold=False)
            
            # --- Flow description header ---
            elif el_type == "flow_desc_header":
                p = target_anchor.insert_paragraph_before("", style="Normal")
                format_paragraph(p, style_name="Normal", space_before=Pt(6), space_after=Pt(2), line_spacing=1.15, left_indent=Pt(0), first_line_indent=Pt(0), keep_with_next=True)
                add_text_run(p, el["text"], font_size=Pt(12), bold=True)
            
            # --- Sub header (Staging -> Atomic / Atomic -> Datamart) ---
            elif el_type == "sub_header":
                p = target_anchor.insert_paragraph_before("", style="Normal")
                format_paragraph(p, style_name="Normal", space_before=Pt(4), space_after=Pt(2), line_spacing=1.15, left_indent=Pt(0), first_line_indent=Pt(0), keep_with_next=True)
                add_text_run(p, el["text"], font_size=Pt(12), bold=True, italic=True)
            
            # --- Desc item (Table mapping bullet) ---
            elif el_type == "desc_item":
                p = target_anchor.insert_paragraph_before("", style="Normal")
                format_paragraph(p, style_name="Normal", space_before=Pt(1), space_after=Pt(2.5), line_spacing=1.15, left_indent=Pt(18), first_line_indent=Pt(-14))
                add_text_run(p, "•  ", font_size=Pt(12), bold=False)
                ent_name, desc_body = parse_bullet_item(el["text"])
                if ent_name:
                    add_text_run(p, f"{ent_name}: ", font_size=Pt(12), bold=True)
                if desc_body:
                    add_text_run(p, desc_body, font_size=Pt(12), bold=False)

    # 6. Xóa các paragraph cũ từ p_etl_idx + 1 đến p_api_idx - 1
    print("Đang xóa các đoạn văn bản cũ của 3.1 cũ...")
    old_comment_ids = comment_ids_in(old_section_paragraphs)
    for p in old_section_paragraphs:
        p._p.getparent().remove(p._p)
    dropped = drop_unbalanced_comment_marks(doc)
    if old_comment_ids:
        ids = sorted(old_comment_ids, key=lambda x: int(x) if str(x).isdigit() else 0)
        print(f"[INFO] {len(ids)} comment review neo trong Mục 3.1 cũ đã bị loại cùng nội dung cũ: {', '.join(ids)}")
    if dropped:
        print(f"[INFO] Đã gỡ dấu neo lệch cặp của comment: {', '.join(sorted(dropped))}")

    # 7. Lưu file kết quả ra đường dẫn mới riêng biệt
    output_docx_path.parent.mkdir(parents=True, exist_ok=True)
    doc.save(str(output_docx_path))
    print(f"\nSaved output document: {output_docx_path} ({output_docx_path.stat().st_size:,} bytes)")

    # 8. Xác nhận tính toàn vẹn của template gốc
    sha_after = hashlib.sha256(input_docx_path.read_bytes()).hexdigest()
    if sha_before != sha_after:
        raise RuntimeError(
            f"VIOLATION: SHA-256 của template gốc đã bị thay đổi! (Trước: {sha_before}, Sau: {sha_after})"
        )
    print(f"SHA-256 gốc (sau khi chạy - BẢO TOÀN 100%): {sha_after}")

    print(f"\n=== HOÀN TẤT CẬP NHẬT TÀI LIỆU CHUẨN Q5 ===")
    print(f"File xuất bản: {output_docx_path} ({output_docx_path.stat().st_size:,} bytes)")
    return output_docx_path


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Ghép Mục 3.1 (ETL 11 phân hệ Datamart) vào quyển PTTK theo bản mẫu hiện hành (doc_registry)."
    )
    parser.add_argument(
        "--input-docx",
        type=Path,
        default=DEFAULT_INPUT_DOCX_PATH,
        help="Đường dẫn tới file Word mẫu gốc (.docx)"
    )
    parser.add_argument(
        "--output-docx",
        type=Path,
        default=DEFAULT_OUTPUT_DOCX_PATH,
        help="Đường dẫn tới file Word kết quả đầu ra (.docx)"
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Dừng (không ghi file) nếu Markdown PTTK của module nào chưa đạt chuẩn luồng 5 tầng"
    )
    args = parser.parse_args()
    update_master_q5_document(args.input_docx, args.output_docx, strict=args.strict)
