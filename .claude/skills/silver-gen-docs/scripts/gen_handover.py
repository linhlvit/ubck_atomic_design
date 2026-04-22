"""CLI sinh tài liệu Word bàn giao Silver Lakehouse — Thiết kế CSDL.

MVP scope: chỉ DB Design.

Modes:
    sample  — render 1-2 entity đại diện cho 1 source ra file MD review nhanh
    full    — render fragment đầy đủ cho 1 source vào docs/output/fragments/
    docx    — gom tất cả fragment + render master + Pandoc convert (Phase 2)

Usage:
    python gen_handover.py --source FIMS --mode sample
    python gen_handover.py --source FIMS --mode full
    python gen_handover.py --mode docx
"""

from __future__ import annotations

import argparse
import sys
from datetime import datetime
from pathlib import Path

# Thêm scripts/ vào sys.path để import data_loader, render_md, filters
SCRIPTS_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPTS_DIR))

import data_loader as DL
import render_md as RM


# Repo root = tổ tiên cách 4 cấp: scripts/ → silver-gen-docs/ → skills/ → .claude/ → repo
REPO_ROOT = SCRIPTS_DIR.parents[3]
TEMPLATES_DIR = REPO_ROOT / "docs" / "templates"
OUTPUT_DIR = REPO_ROOT / "docs" / "output"
FRAGMENTS_DIR = OUTPUT_DIR / "fragments"


def cmd_sample(source: str, sample_count: int = 2) -> Path:
    """Render sample MD cho 1 source. Output: docs/output/{SOURCE}/sample_dbdesign.md + {SOURCE}.dbml."""
    source_data = DL.load_source(REPO_ROOT, source, sample=True, sample_count=sample_count)
    if not source_data["entities"]:
        raise SystemExit(f"ERROR: Không tìm thấy entity nào cho source '{source}' trong manifest.csv")

    env = RM.make_env(TEMPLATES_DIR)
    fragment = RM.render_fragment(env, source_data, idx=1)

    out_dir = OUTPUT_DIR / source
    out_dir.mkdir(parents=True, exist_ok=True)

    md_file = out_dir / "sample_dbdesign.md"
    md_file.write_text(fragment, encoding="utf-8")

    dbml_file = out_dir / f"{source}.dbml"
    dbml_file.write_text(DL.build_dbml(source, source_data["entities"]), encoding="utf-8")

    print(f"DBML: {dbml_file}", file=sys.stderr)
    return md_file


def cmd_full(source: str) -> Path:
    """Render fragment đầy đủ cho 1 source. Idempotent — chỉ ghi đè file của source đó.

    Sinh đồng thời:
    - docs/output/fragments/{SOURCE}_dbdesign.md
    - docs/output/fragments/{SOURCE}.dbml
    """
    source_data = DL.load_source(REPO_ROOT, source, sample=False)
    if not source_data["entities"]:
        raise SystemExit(f"ERROR: Không tìm thấy entity nào cho source '{source}' trong manifest.csv")

    env = RM.make_env(TEMPLATES_DIR)
    # idx tạm = 1 ở fragment level; idx thực sẽ inject lại ở mode docx khi gom master
    fragment = RM.render_fragment(env, source_data, idx="{IDX}")

    FRAGMENTS_DIR.mkdir(parents=True, exist_ok=True)
    md_file = FRAGMENTS_DIR / f"{source}_dbdesign.md"
    md_file.write_text(fragment, encoding="utf-8")

    dbml_file = FRAGMENTS_DIR / f"{source}.dbml"
    dbml_file.write_text(DL.build_dbml(source, source_data["entities"]), encoding="utf-8")

    print(f"DBML: {dbml_file}", file=sys.stderr)
    return md_file


def _load_sources_order() -> list[str] | None:
    """Đọc docs/output/sources_order.txt nếu có. 1 source/dòng, bỏ qua dòng trống/comment."""
    order_file = OUTPUT_DIR / "sources_order.txt"
    if not order_file.exists():
        return None
    sources: list[str] = []
    for line in order_file.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        sources.append(line)
    return sources


def cmd_docx() -> Path:
    """Gom tất cả fragment, render master MD, convert sang DOCX bằng Pandoc.

    Phase 2 — chưa triển khai đầy đủ. Hiện chỉ build master MD interim.
    """
    if not FRAGMENTS_DIR.exists():
        raise SystemExit(f"ERROR: Không tìm thấy {FRAGMENTS_DIR}. Chạy '--mode full --source X' trước.")

    fragment_files = sorted(FRAGMENTS_DIR.glob("*_dbdesign.md"))
    if not fragment_files:
        raise SystemExit(f"ERROR: Không có fragment nào trong {FRAGMENTS_DIR}.")

    # Discover sources từ tên file
    discovered = [f.stem.replace("_dbdesign", "") for f in fragment_files]
    order = _load_sources_order()
    if order:
        sources = [s for s in order if s in discovered]
        unordered = [s for s in discovered if s not in sources]
        sources.extend(sorted(unordered))
    else:
        sources = sorted(discovered)

    # Load source data + render fragment với idx đúng
    sources_data: list[dict] = []
    fragments_text: list[str] = []
    all_classifications: list[dict] = []
    all_pendings: list[dict] = []

    for idx, source in enumerate(sources, start=1):
        sd = DL.load_source(REPO_ROOT, source, sample=False)
        sources_data.append(sd)
        # Đọc fragment text từ file đã gen sẵn, replace placeholder {IDX}
        frag_text = (FRAGMENTS_DIR / f"{source}_dbdesign.md").read_text(encoding="utf-8")
        frag_text = frag_text.replace("{IDX}", str(idx))
        fragments_text.append(frag_text)
        for c in sd["classifications"]:
            all_classifications.append({**c, "source": source})
        all_pendings.extend(sd["pendings"])

    env = RM.make_env(TEMPLATES_DIR)
    generated_at = datetime.now().strftime("%Y-%m-%d")
    master_md = RM.render_master(
        env=env,
        sources_data=sources_data,
        sources=sources,
        fragments=fragments_text,
        all_classifications=all_classifications,
        all_pendings=all_pendings,
        generated_at=generated_at,
    )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    master_file = OUTPUT_DIR / "silver_dbdesign.md"
    master_file.write_text(master_md, encoding="utf-8")

    print(f"Master MD interim: {master_file}", file=sys.stderr)
    print("TODO Phase 2: chạy Pandoc convert sang docx.", file=sys.stderr)
    return master_file


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--mode", required=True, choices=["sample", "full", "docx"])
    parser.add_argument("--source", help="Source system code (FIMS, IDS, ...). Bắt buộc cho mode sample/full.")
    parser.add_argument("--sample-count", type=int, default=2, help="Số entity trong sample mode (default 2)")
    args = parser.parse_args()

    if args.mode in ("sample", "full") and not args.source:
        parser.error(f"--source bắt buộc cho mode {args.mode}")

    if args.mode == "sample":
        out = cmd_sample(args.source, args.sample_count)
        print(f"OK sample: {out}")
    elif args.mode == "full":
        out = cmd_full(args.source)
        print(f"OK fragment: {out}")
    elif args.mode == "docx":
        out = cmd_docx()
        print(f"OK master MD: {out}")


if __name__ == "__main__":
    main()
