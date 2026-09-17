# -*- coding: utf-8 -*-
"""
scripts/datamart_common/encoding.py
Encoding detection and safe file reading utilities for Datamart Review skills.
"""
from __future__ import annotations

from pathlib import Path
from typing import Union


def detect_file_encoding(filepath: Union[str, Path]) -> str:
    """Detect file encoding with BOM recognition and fallback order."""
    path = Path(filepath)
    if not path.is_file():
        return "utf-8"

    try:
        with path.open("rb") as f:
            raw = f.read(4)
        if raw.startswith(b"\xef\xbb\xbf"):
            return "utf-8-sig"
        if raw.startswith(b"\xff\xfe") or raw.startswith(b"\xfe\xff"):
            return "utf-16"
    except Exception:
        pass

    # Try utf-8
    try:
        with path.open("r", encoding="utf-8") as f:
            f.read(8192)
        return "utf-8"
    except UnicodeDecodeError:
        pass

    # Fallback to cp1258 (Vietnamese Windows) or latin-1
    try:
        with path.open("r", encoding="cp1258") as f:
            f.read(8192)
        return "cp1258"
    except Exception:
        return "latin-1"


def read_file_safe(filepath: Union[str, Path], default_encoding: str = "utf-8-sig") -> str:
    """Read a text file safely, stripping BOM if present, with encoding fallbacks."""
    path = Path(filepath)
    if not path.is_file():
        return ""

    encodings = [default_encoding, "utf-8", "cp1258", "latin-1"]
    # De-duplicate while preserving order
    seen = set()
    unique_encodings = [e for e in encodings if not (e in seen or seen.add(e))]

    for enc in unique_encodings:
        try:
            content = path.read_text(encoding=enc, errors="strict")
            return content.lstrip("\ufeff")
        except (UnicodeDecodeError, LookupError):
            continue

    # Final fallback with replace
    return path.read_text(encoding="utf-8-sig", errors="replace").lstrip("\ufeff")
