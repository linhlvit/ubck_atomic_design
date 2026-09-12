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

    if artifact_type in ("entities", "hld_entities", "entities_csv"):
        hld_dir = root / "Datamart" / "hld"
        if not hld_dir.exists():
            return None
        for m in unique_candidates:
            # CSV candidate
            candidate = hld_dir / f"DTM_{m}_Entities.csv"
            if candidate.exists():
                return candidate
            candidate_lower = hld_dir / f"DTM_{m}_entities.csv"
            if candidate_lower.exists():
                return candidate_lower
            # Case-insensitive search
            for f in hld_dir.glob("*.csv"):
                if f.name.upper() == f"DTM_{m.upper()}_ENTITIES.CSV":
                    return f
            # MD fallback if requested or CSV absent
            candidate_md = hld_dir / f"DTM_{m}_Entities.md"
            if candidate_md.exists():
                return candidate_md
        return None

    if artifact_type in ("flat_table", "flat_tables", "flat_table_sql", "create_flat_table"):
        ft_dir = root / "Datamart" / "flat-table"
        if not ft_dir.exists():
            return None
        for m in unique_candidates:
            subdirs = [ft_dir / m, ft_dir / m.lower(), ft_dir / m.upper()]
            if mod_stripped != m:
                subdirs.extend([ft_dir / mod_stripped, ft_dir / mod_stripped.lower(), ft_dir / mod_stripped.upper()])
            for sdir in subdirs:
                if sdir.is_dir():
                    candidate1 = sdir / f"01_create_{m.lower()}_flat_tables.sql"
                    if candidate1.exists():
                        return candidate1
                    candidate1_strip = sdir / f"01_create_{mod_stripped.lower()}_flat_tables.sql"
                    if candidate1_strip.exists():
                        return candidate1_strip
                    for f in sdir.glob("01_create*.sql"):
                        return f
                    for f in sdir.glob("*.sql"):
                        if "create" in f.name.lower():
                            return f
            for d in ft_dir.iterdir():
                if d.is_dir() and (d.name.upper() == m.upper() or d.name.upper() == mod_stripped.upper()):
                    for f in d.glob("01_create*.sql"):
                        return f
                    for f in d.glob("*.sql"):
                        if "create" in f.name.lower():
                            return f
        return None

    return None


def resolve_entities_csv(root_dir: Path, module: str) -> Optional[Path]:
    """Resolve DTM_{MODULE}_Entities.csv path."""
    return resolve_module_path(root_dir, module, "entities")


def resolve_flat_table_sql(
    root_dir: Path,
    module: str,
    script_num: str = "01",
) -> Optional[Path]:
    """Resolve Flat Table SQL file path (e.g. 01_create or 02_populate)."""
    if script_num == "01" or "create" in script_num.lower():
        return resolve_module_path(root_dir, module, "flat_table")

    root = Path(root_dir)
    ft_dir = root / "Datamart" / "flat-table"
    if not ft_dir.exists():
        return None
    mod_norm = normalize_module_name(module)
    mod_stripped = strip_accents(mod_norm)
    for m in [mod_norm, mod_stripped, module.strip()]:
        for sdir in [ft_dir / m, ft_dir / m.lower(), ft_dir / m.upper()]:
            if sdir.is_dir():
                cand = sdir / f"02_populate_{m.lower()}_flat_tables.sql"
                if cand.exists():
                    return cand
                for f in sdir.glob("02_populate*.sql"):
                    return f
    return None


def get_available_modules(root_dir: Path) -> List[str]:
    """Discover all available Datamart module codes in the repository."""
    root = Path(root_dir)
    found_modules: set[str] = set()

    hld_dir = root / "Datamart" / "hld"
    if hld_dir.is_dir():
        for f in hld_dir.glob("DTM_*_Entities.csv"):
            parts = f.stem.split("_")
            if len(parts) >= 2:
                found_modules.add(normalize_module_name(parts[1]))

    lld_dir = root / "Datamart" / "lld"
    if lld_dir.is_dir():
        for d in lld_dir.iterdir():
            if d.is_dir() and d.name not in ("__pycache__",):
                found_modules.add(normalize_module_name(d.name))

    ft_dir = root / "Datamart" / "flat-table"
    if ft_dir.is_dir():
        for d in ft_dir.iterdir():
            if d.is_dir() and d.name not in ("__pycache__",):
                found_modules.add(normalize_module_name(d.name))

    ordered = sorted([m for m in found_modules if m.upper() != "COMMON"])
    if "Common" in found_modules or "COMMON" in found_modules:
        ordered.append("Common")
    return ordered


def get_module_files(root_dir: Path, module: str) -> Dict[str, Optional[Path]]:
    """Retrieve all standard artifact paths for a module."""
    return {
        "ba": resolve_module_path(root_dir, module, "ba"),
        "hld": resolve_module_path(root_dir, module, "hld"),
        "detail_mapping": resolve_module_path(root_dir, module, "detail_mapping"),
        "attributes": resolve_module_path(root_dir, module, "attributes"),
        "entities": resolve_module_path(root_dir, module, "entities"),
        "flat_table": resolve_module_path(root_dir, module, "flat_table"),
    }


def find_project_root(start_path: Optional[str | Path] = None) -> Path:
    """Auto-detect repository root directory containing 'Datamart'."""
    p = Path(start_path).resolve() if start_path else Path.cwd().resolve()
    # Check current and parents
    curr: Optional[Path] = p
    while curr is not None and curr != curr.parent:
        if (curr / "Datamart").is_dir():
            return curr
        if (curr / "ubck_atomic_design" / "Datamart").is_dir():
            return curr / "ubck_atomic_design"
        curr = curr.parent
    return p

