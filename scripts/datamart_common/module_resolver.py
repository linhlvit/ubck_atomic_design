# -*- coding: utf-8 -*-
"""
scripts/datamart_common/module_resolver.py
Module alias resolution and artifact file discovery utilities for Datamart Review.
"""
from __future__ import annotations

import unicodedata
from pathlib import Path
from typing import Dict, List, Optional


MODULE_ALIASES: Dict[str, str] = {
    "GSDC": "GSĐC",
    "GSĐC": "GSĐC",
    "GSTT": "GSTT",
    "QLKD": "QLKD",
    "TT": "TT",
    "NHNCK": "NHNCK",
    "PTTT": "PTTT",
    "QLQ": "QLQ",
    "FMS": "QLQ",
    "QLCB": "QLCB",
    "TKNB": "TKNB",
    "VP": "VP",
    "NDTNN": "NDTNN",
}


def strip_accents(s: str) -> str:
    """Strip Vietnamese diacritics for flexible file matching."""
    s = s.replace("Đ", "D").replace("đ", "d")
    nfkd = unicodedata.normalize("NFKD", s)
    return "".join([c for c in nfkd if not unicodedata.combining(c)])


def normalize_module_name(module_name: str) -> str:
    """Normalize module name to standard uppercase representation."""
    cleaned = module_name.strip().upper()
    return MODULE_ALIASES.get(cleaned, cleaned)


def resolve_module_path(
    root_dir: Path,
    module: str,
    artifact_type: str = "ba",
) -> Optional[Path]:
    """
    Resolve artifact file path given project root, module name, and artifact type.
    artifact_type: 'ba', 'hld', 'detail_mapping', or 'attributes'.
    """
    mod_norm = normalize_module_name(module)
    mod_stripped = strip_accents(mod_norm)
    candidates_mod = [mod_norm, mod_stripped, module.strip()]
    # De-duplicate while preserving order
    unique_candidates = []
    for c in candidates_mod:
        if c not in unique_candidates:
            unique_candidates.append(c)

    root = Path(root_dir)

    if artifact_type == "ba":
        ba_dir = root / "BRD" / "BA"
        if not ba_dir.exists():
            return None
        for m in unique_candidates:
            # Single file
            candidate = ba_dir / f"BA_analyst_{m}.csv"
            if candidate.exists():
                return candidate
            # Part 1 if multipart
            candidate_part1 = ba_dir / f"BA_analyst_{m}_part1.csv"
            if candidate_part1.exists():
                return candidate_part1
            # Case-insensitive search in directory
            for f in ba_dir.glob("*.csv"):
                f_name_upper = f.name.upper()
                if f"BA_ANALYST_{m.upper()}" in f_name_upper:
                    return f
        return None

    if artifact_type == "hld":
        hld_dir = root / "Datamart" / "hld"
        if not hld_dir.exists():
            return None
        for m in unique_candidates:
            candidate = hld_dir / f"DTM_{m}_HLD.md"
            if candidate.exists():
                return candidate
            for f in hld_dir.glob("*.md"):
                if f"DTM_{m.upper()}_HLD" in f.name.upper():
                    return f
        return None

    if artifact_type == "detail_mapping":
        lld_dir = root / "Datamart" / "lld"
        if not lld_dir.exists():
            return None
        for m in unique_candidates:
            candidate = lld_dir / f"DTM_{m}_Detail_Mapping.csv"
            if candidate.exists():
                return candidate
            for f in lld_dir.glob("*.csv"):
                if f"DTM_{m.upper()}_DETAIL_MAPPING" in f.name.upper():
                    return f
        return None

    if artifact_type == "attributes":
        lld_dir = root / "Datamart" / "lld"
        if not lld_dir.exists():
            return None
        # Check module-specific folder first
        for m in unique_candidates:
            mod_sub = lld_dir / m
            if mod_sub.is_dir():
                return mod_sub
        # Master attributes file
        master_attr = lld_dir / "datamart_attributes.csv"
        if master_attr.exists():
            return master_attr
        return None

    return None


def get_module_files(root_dir: Path, module: str) -> Dict[str, Optional[Path]]:
    """Retrieve all four standard artifact paths for a module."""
    return {
        "ba": resolve_module_path(root_dir, module, "ba"),
        "hld": resolve_module_path(root_dir, module, "hld"),
        "detail_mapping": resolve_module_path(root_dir, module, "detail_mapping"),
        "attributes": resolve_module_path(root_dir, module, "attributes"),
    }
