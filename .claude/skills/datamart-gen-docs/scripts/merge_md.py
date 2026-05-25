"""Phase 2.5: Gộp các file Markdown từng module thành 1 file tổng.

Chạy sau khi tất cả module đã được phê duyệt (Phase 2) và trước khi build DOCX tổng (Phase 3).

Usage:
    # Gộp PTTK
    python merge_md.py --modules TT FMS GSTT --type pttk

    # Gộp TKCSLD
    python merge_md.py --modules TT FMS GSTT --type tkcsld

    # Gộp cả 2
    python merge_md.py --modules TT FMS GSTT --type both

    # Chỉ định file output tổng (mặc định: DTM_ALL_PTTK.md)
    python merge_md.py --modules TT FMS GSTT --type pttk --output-name PTTK_Datamart_Total

Output:
    docs/output/datamart/DTM_{OUTPUT_NAME}_PTTK.md
    docs/output/datamart/DTM_{OUTPUT_NAME}_TKCSLD.md

Heading numbering:
    PTTK  — tự động renumber 3.2.X bắt đầu từ X=1
    TKCSLD — giữ nguyên cấu trúc từng module, chèn page break giữa các module
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[4]
OUTPUT_DIR = REPO_ROOT / "docs" / "output" / "datamart"

_PAGE_BREAK = "\n\n---\n\n"  # pandoc converts --- to page break with --reference-doc; fallback dùng \newpage
_PAGE_BREAK_LATEX = "\n\n\\newpage\n\n"


def _md_path(module: str, doc_type: str) -> Path:
    return OUTPUT_DIR / module / f"DTM_{module}_{doc_type.upper()}.md"


def _out_path(name: str, doc_type: str) -> Path:
    return OUTPUT_DIR / f"DTM_{name}_{doc_type.upper()}.md"


# ─── PTTK renumber ───────────────────────────────────────────────────────────

# Match heading dạng: ## 3.2.X ... hoặc ### 3.2.X.1 ... hoặc #### 3.2.X.2.1 ...
_PTTK_TOP = re.compile(r"^(#{1,2}\s+)3\.2\.(\d+)([\s\S]?)(.*)$", re.MULTILINE)
_PTTK_SUB = re.compile(r"^(#{3,6}\s+)3\.2\.(\d+)\.(\S+)(.*)$", re.MULTILINE)


def _renumber_pttk(text: str, new_x: int) -> str:
    """Thay 3.2.X → 3.2.{new_x} trong toàn bộ text của 1 module."""
    # Tìm X hiện tại (lấy số đầu tiên xuất hiện)
    m = _PTTK_TOP.search(text)
    if not m:
        return text
    old_x = m.group(2)

    # Thay tất cả 3.2.{old_x}. và 3.2.{old_x} (word boundary)
    text = re.sub(
        r"3\.2\." + re.escape(old_x) + r"(?=[\.\s\n]|$)",
        f"3.2.{new_x}",
        text,
        flags=re.MULTILINE,
    )
    return text


# ─── Merge logic ─────────────────────────────────────────────────────────────

def merge(modules: list[str], doc_type: str, output_name: str) -> Path:
    parts: list[str] = []
    missing: list[str] = []

    for m in modules:
        p = _md_path(m, doc_type)
        if not p.exists():
            missing.append(str(p))
        else:
            parts.append((m, p.read_text(encoding="utf-8")))

    if missing:
        print(
            "ERROR: Các file sau chưa tồn tại — chạy Phase 1 trước:\n"
            + "\n".join(f"  {f}" for f in missing),
            file=sys.stderr,
        )
        sys.exit(1)

    merged_sections: list[str] = []

    if doc_type == "pttk":
        for idx, (module, text) in enumerate(parts, start=1):
            renumbered = _renumber_pttk(text, idx)
            merged_sections.append(renumbered.strip())
    else:
        # TKCSLD: giữ nguyên nội dung, chèn page break giữa module
        for module, text in parts:
            merged_sections.append(text.strip())

    separator = _PAGE_BREAK_LATEX
    final = separator.join(merged_sections) + "\n"

    out = _out_path(output_name, doc_type)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(final, encoding="utf-8")

    print(f"OK: {out}  ({len(parts)} module: {', '.join(m for m, _ in parts)})")
    return out


# ─── CLI ─────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--modules", required=True, nargs="+",
        metavar="MODULE",
        help="Danh sách mã module theo thứ tự cần merge (VD: TT FMS GSTT)",
    )
    parser.add_argument(
        "--type", required=True, choices=["pttk", "tkcsld", "both"],
        help="Loại tài liệu",
    )
    parser.add_argument(
        "--output-name", default="ALL",
        metavar="NAME",
        help="Tên file output (mặc định: ALL → DTM_ALL_PTTK.md)",
    )
    args = parser.parse_args()

    modules = [m.upper() for m in args.modules]
    types = ["pttk", "tkcsld"] if args.type == "both" else [args.type]

    for t in types:
        merge(modules, t, args.output_name.upper())


if __name__ == "__main__":
    main()
