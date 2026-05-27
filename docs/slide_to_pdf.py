"""
slide_to_pdf.py — Convert HTML slide deck to PDF via Chrome headless.

Usage:
    python slide_to_pdf.py <input.html> [output.pdf]

If output.pdf is omitted, saves alongside the input file with .pdf extension.

Requirements: Google Chrome installed at the default Windows path.
"""

import sys
import re
import subprocess
import tempfile
import os
from pathlib import Path

CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"


def make_print_html(src: Path) -> str:
    html = src.read_text(encoding="utf-8")

    # 1. Remove overflow:hidden on body so all content renders
    html = re.sub(r"(body\s*\{[^}]*?)overflow\s*:\s*hidden\s*;?", r"\1", html)

    # 2. Show all slides: remove display:none, make .slide always flex
    #    Pattern: .slide { ... display:none; ... }
    html = re.sub(
        r"(\.slide\s*\{[^}]*?)display\s*:\s*none\s*;?",
        r"\1display: flex;",
        html,
    )

    # 3. Remove position:absolute / inset:0 that stack slides on top of each other
    html = re.sub(
        r"(\.slide\s*\{[^}]*?)position\s*:\s*absolute\s*;?",
        r"\1position: relative;",
        html,
    )
    html = re.sub(
        r"(\.slide\s*\{[^}]*?)inset\s*:\s*0\s*;?",
        r"\1",
        html,
    )

    # 4. Make .deck a normal block (not relative/fixed container)
    html = re.sub(
        r"(\.deck\s*\{[^}]*?)width\s*:\s*100vw\s*;?",
        r"\1width: 100%;",
        html,
    )
    html = re.sub(
        r"(\.deck\s*\{[^}]*?)height\s*:\s*100vh\s*;?",
        r"\1",
        html,
    )
    html = re.sub(
        r"(\.deck\s*\{[^}]*?)position\s*:\s*relative\s*;?",
        r"\1",
        html,
    )

    # 5. Each slide = one printed page; opacity always 1
    html = re.sub(
        r"(\.slide\s*\{[^}]*?)opacity\s*:\s*0\s*;?",
        r"\1opacity: 1;",
        html,
    )

    # 6. Inject print CSS before </style>
    print_css = """
  /* ── injected by slide_to_pdf.py ── */
  body { overflow: visible !important; }
  .slide {
    position: relative !important;
    display: flex !important;
    opacity: 1 !important;
    min-height: 100vh;
    width: 100%;
    page-break-after: always;
    break-after: page;
  }
  .slide:last-of-type { page-break-after: avoid; break-after: avoid; }
  #prev, #next, #counter { display: none !important; }
  @media print {
    body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
  }
"""
    html = html.replace("</style>", print_css + "</style>", 1)

    return html


def convert(src: Path, dst: Path) -> None:
    if not src.exists():
        sys.exit(f"ERROR: input file not found: {src}")
    if not Path(CHROME).exists():
        sys.exit(f"ERROR: Chrome not found at: {CHROME}")

    print_html = make_print_html(src)

    # Write to a temp file next to the source so relative paths resolve
    tmp = src.with_stem(src.stem + "_printable")
    tmp.write_text(print_html, encoding="utf-8")

    file_url = "file:///" + tmp.as_posix().replace(" ", "%20")
    cmd = [
        CHROME,
        "--headless=new",
        "--disable-gpu",
        "--no-sandbox",
        f"--print-to-pdf={dst}",
        "--print-to-pdf-no-header",
        "--no-margins",
        file_url,
    ]

    print(f"  Input : {src}")
    print(f"  Output: {dst}")
    print(f"  Slides: {print_html.count('class=\"slide')}")

    try:
        subprocess.run(cmd, check=True, capture_output=True, timeout=120)
    finally:
        tmp.unlink(missing_ok=True)

    size_kb = dst.stat().st_size / 1024
    print(f"  Done  : {size_kb:.1f} KB")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    src = Path(sys.argv[1]).resolve()
    dst = Path(sys.argv[2]).resolve() if len(sys.argv) >= 3 else src.with_suffix(".pdf")

    convert(src, dst)
