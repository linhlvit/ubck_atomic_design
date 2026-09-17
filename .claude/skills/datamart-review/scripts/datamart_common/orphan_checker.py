# -*- coding: utf-8 -*-
"""
scripts/datamart_common/orphan_checker.py
3-Way Orphan Entity Checker Engine for Datamart Review.
Audits consistency across:
- Tier A: LLD Attributes CSV (Datamart/lld/{MODULE}/*.csv)
- Tier B: HLD Entities CSV (Datamart/hld/DTM_{MODULE}_Entities.csv)
- Tier C: Flat Table SQL DDL (Datamart/flat-table/{MODULE}/01_create_{module}_flat_tables.sql)

Implements Ralph Kimball Dimensional Modeling exceptions:
1. Dimension Denormalization: Dimension tables denormalize into Facts and are excluded from Flat Table SQL.
2. Conformed / Reused Table Recognition: Shared entities owned by another module are not duplicated.
3. Automated 2-Branch Resolution:
   - Branch A: Table active (measures exist, needed) -> Complete missing Phase 2/3 artifacts.
   - Branch B: Table deprecated / abandoned -> All-Tier Cleanup Protocol.
"""
from __future__ import annotations

import csv
from dataclasses import asdict, dataclass, field
from enum import Enum
import json
from pathlib import Path
import re
import sys
from typing import Any, Dict, List, Optional, Set, Tuple

# Reconfigure stdout for Windows console UTF-8 support
if sys.platform.startswith("win"):
    if hasattr(sys.stdout, "reconfigure"):
        try:
            sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        except Exception:
            pass
    if hasattr(sys.stderr, "reconfigure"):
        try:
            sys.stderr.reconfigure(encoding="utf-8", errors="replace")
        except Exception:
            pass

try:
    csv.field_size_limit(min(sys.maxsize, 2147483647))
except (OverflowError, AttributeError):
    pass

from .csv_utils import read_csv_dynamic
from .encoding import read_file_safe
from .module_resolver import (
    find_project_root,
    get_available_modules,
    normalize_module_name,
    resolve_entities_csv,
    resolve_flat_table_sql,
    resolve_module_path,
    strip_accents,
)


class ResolutionBranch(str, Enum):
    BRANCH_A_COMPLETE_MISSING = "BRANCH_A_COMPLETE_MISSING"
    BRANCH_B_ALL_TIER_CLEANUP = "BRANCH_B_ALL_TIER_CLEANUP"


class OrphanType(str, Enum):
    HLD_ONLY = "HLD_ONLY"
    LLD_ONLY = "LLD_ONLY"
    FLAT_TABLE_ONLY = "FLAT_TABLE_ONLY"
    LLD_AND_FLAT_MISSING_HLD = "LLD_AND_FLAT_MISSING_HLD"
    HLD_AND_LLD_MISSING_FLAT = "HLD_AND_LLD_MISSING_FLAT"
    HLD_AND_FLAT_MISSING_LLD = "HLD_AND_FLAT_MISSING_LLD"


@dataclass
class OrphanItem:
    module: str
    entity_name: str
    table_name: str
    table_type: str  # 'fact', 'operational', 'dim', or 'unknown'
    reuse_status: str  # 'new', 'reuse', 'partial', 'conformed'
    orphan_type: OrphanType
    branch: ResolutionBranch
    in_tier_a_lld: bool
    in_tier_b_hld: bool
    in_tier_c_flat: bool
    active_measures_count: int
    reason: str
    remediation_action: str
    source_files: Dict[str, str] = field(default_factory=dict)

    def to_dict(self) -> Dict[str, Any]:
        d = asdict(self)
        d["orphan_type"] = self.orphan_type.value
        d["branch"] = self.branch.value
        return d


@dataclass
class OrphanCheckResult:
    module: str
    tier_a_lld_tables: Set[str] = field(default_factory=set)
    tier_b_hld_entities: Set[str] = field(default_factory=set)
    tier_c_flat_tables: Set[str] = field(default_factory=set)
    orphans: List[OrphanItem] = field(default_factory=list)
    branch_a_missing: List[OrphanItem] = field(default_factory=list)
    branch_b_orphans: List[OrphanItem] = field(default_factory=list)
    conformed_reused_tables: Set[str] = field(default_factory=set)
    denormalized_dims: Set[str] = field(default_factory=set)
    naming_warnings: List[str] = field(default_factory=list)
    status: str = "PASS"
    summary: Dict[str, Any] = field(default_factory=dict)
    module_results: Dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "module": self.module,
            "tier_a_lld_tables": sorted(list(self.tier_a_lld_tables)),
            "tier_b_hld_entities": sorted(list(self.tier_b_hld_entities)),
            "tier_c_flat_tables": sorted(list(self.tier_c_flat_tables)),
            "orphans": [o.to_dict() for o in self.orphans],
            "branch_a_missing": [o.to_dict() for o in self.branch_a_missing],
            "branch_b_orphans": [o.to_dict() for o in self.branch_b_orphans],
            "conformed_reused_tables": sorted(list(self.conformed_reused_tables)),
            "denormalized_dims": sorted(list(self.denormalized_dims)),
            "naming_warnings": self.naming_warnings,
            "status": self.status,
            "summary": self.summary,
            "module_results": {k: v.to_dict() if hasattr(v, "to_dict") else v for k, v in self.module_results.items()},
        }


# Backward-compatible alias
OrphanAuditResult = OrphanCheckResult


def normalize_entity_key(name: str) -> str:
    """Normalize entity name for fuzzy matching across HLD and LLD."""
    s = name.strip().lower()
    for suffix in [
        " snapshot dimension",
        " dimension",
        " snapshot",
        " dim",
        " snpst",
        " report",
        " list",
        " profile",
        " activity",
    ]:
        if s.endswith(suffix):
            s = s[: -len(suffix)].strip()
    s = re.sub(r"[\s_\-]+", " ", s)
    return s


def extract_flat_tables_from_sql(sql_content: str, module: str) -> Dict[str, str]:
    """
    Extract flat table definitions from 01_create_{module}_flat_tables.sql.
    Returns mapping: base_physical_table_name -> raw_flat_table_name.
    e.g. 'fct_stock_portfolio_snpst' -> 'gstt_fct_stock_portfolio_snpst_flat'
    """
    pattern = re.compile(
        r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:datamart\.)?([a-zA-Z0-9_]+)",
        re.IGNORECASE,
    )
    raw_tables = pattern.findall(sql_content)
    result: Dict[str, str] = {}

    mod_norm = normalize_module_name(module).lower()
    mod_strip = strip_accents(mod_norm).lower()

    for raw in raw_tables:
        base = raw
        if base.endswith("_flat"):
            base = base[:-5]

        # Strip module prefix if present (e.g. gstt_, tknb_, qlcb_)
        for prefix in (f"{mod_norm}_", f"{mod_strip}_", f"{module.lower()}_"):
            if base.lower().startswith(prefix):
                base = base[len(prefix):]
                break

        result[base.lower()] = raw

    return result


def load_detail_mapping_measures(
    detail_mapping_path: Optional[Path],
) -> Tuple[Dict[str, int], Dict[str, bool]]:
    """
    Load active MEASURE count and deprecation status per mart_table from DTM_{MODULE}_Detail_Mapping.csv.
    Returns (active_measures_dict, all_deprecated_dict).
    """
    if not detail_mapping_path or not detail_mapping_path.is_file():
        return {}, {}

    _, _, rows = read_csv_dynamic(detail_mapping_path)
    table_measures: Dict[str, int] = {}
    table_total: Dict[str, int] = {}
    table_deprecated: Dict[str, int] = {}

    for r in rows:
        table = r.get("mart_table", "").strip()
        if not table:
            continue
        role = r.get("column_role", "").strip().upper()
        logic = r.get("logic", "").strip().lower()

        table_total[table] = table_total.get(table, 0) + 1
        is_dep = role == "DEPRECATED" or "deprecated" in logic or "hủy" in logic or "loại" in logic

        if is_dep:
            table_deprecated[table] = table_deprecated.get(table, 0) + 1
        elif role == "MEASURE":
            table_measures[table] = table_measures.get(table, 0) + 1

    all_dep: Dict[str, bool] = {}
    for t, tot in table_total.items():
        all_dep[t] = table_deprecated.get(t, 0) == tot

    return table_measures, all_dep


def classify_resolution_branch(
    entity_name: str,
    table_name: str,
    module: str,
    active_measures_count: int,
    is_all_deprecated: bool,
    is_in_lld: bool,
    is_in_flat: bool,
    description_text: str = "",
    sql_notes: str = "",
) -> Tuple[ResolutionBranch, str, str]:
    """
    Classifies an orphan into Branch A (Complete missing) vs Branch B (Cleanup).
    Returns (branch, reason, remediation_action).
    """
    text_corpus = f"{description_text} {sql_notes}".lower()
    deprecated_indicators = [
        "đã loại",
        "loại khỏi hld",
        "loại bỏ",
        "đã hủy",
        "bị hủy",
        "bị loại",
        "deprecated",
        "không còn measure",
        "không dùng",
        "chưa có csdl - map biểu mẫu",
    ]
    is_explicitly_deprecated = any(ind in text_corpus for ind in deprecated_indicators)

    # 1. Implemented in LLD and Flat Table but missing in HLD -> Branch A
    if is_in_lld and is_in_flat:
        return (
            ResolutionBranch.BRANCH_A_COMPLETE_MISSING,
            "Table is implemented in LLD attributes and Flat Table SQL DDL, but omitted from HLD Entities.",
            f"Add entity '{entity_name}' ({table_name}) to Datamart/hld/DTM_{module}_Entities.csv and DTM_{module}_Entities.md (Complete Phase 2 HLD).",
        )

    # 2. Implemented in LLD only with active measures or not deprecated -> Branch A
    if is_in_lld and (active_measures_count > 0 or not (is_all_deprecated or is_explicitly_deprecated)):
        return (
            ResolutionBranch.BRANCH_A_COMPLETE_MISSING,
            "Table has LLD attribute definitions and active indicators, but lacks HLD entity registration or Flat Table SQL.",
            f"Complete missing HLD entity definition and generate 01_create_{module.lower()}_flat_tables.sql entry for '{table_name}'.",
        )

    # 3. Explicitly deprecated or all measures deprecated / 0 measures -> Branch B
    if is_explicitly_deprecated or is_all_deprecated or active_measures_count == 0:
        return (
            ResolutionBranch.BRANCH_B_ALL_TIER_CLEANUP,
            "Entity is explicitly documented as deprecated/removed or has 0 active measures in Detail Mapping.",
            f"Execute All-Tier Cleanup Protocol: Remove ghost entity '{entity_name}' from Datamart/hld/DTM_{module}_Entities.csv and DTM_{module}_Entities.md.",
        )

    # 4. Fallback to Branch A if active measures exist
    if active_measures_count > 0:
        return (
            ResolutionBranch.BRANCH_A_COMPLETE_MISSING,
            f"Entity has {active_measures_count} active measures in Detail Mapping.",
            f"Complete Phase 2/3 artifacts for entity '{entity_name}'.",
        )

    return (
        ResolutionBranch.BRANCH_B_ALL_TIER_CLEANUP,
        "Entity has no corresponding LLD or Flat Table and lacks active measures.",
        f"Clean up entity '{entity_name}' from HLD specification.",
    )


def audit_module_orphans(
    module: str,
    root_dir: Optional[str | Path] = None,
) -> OrphanCheckResult:
    """
    Perform 3-way orphan check across Tier A (LLD), Tier B (HLD), and Tier C (Flat Table SQL)
    for a single module.
    """
    root = find_project_root(root_dir)
    mod_norm = normalize_module_name(module)
    mod_strip = strip_accents(mod_norm)

    result = OrphanCheckResult(module=mod_norm)

    # 1. Tier A: Gather LLD Tables from Datamart/lld/{MODULE}/*.csv
    lld_dir = root / "Datamart" / "lld" / mod_norm
    if not lld_dir.is_dir():
        lld_dir = root / "Datamart" / "lld" / mod_strip

    tier_a_tables: Dict[str, Dict[str, Any]] = {}
    lld_entity_to_table: Dict[str, str] = {}

    if lld_dir.is_dir():
        for csv_f in lld_dir.glob("*.csv"):
            _, _, rows = read_csv_dynamic(csv_f)
            for r in rows:
                p_table = r.get("datamart_table", "").strip()
                l_entity = r.get("datamart_entity", "").strip()
                p_col = r.get("datamart_column", "").strip()

                if not p_table:
                    continue

                p_table_lower = p_table.lower()
                result.tier_a_lld_tables.add(p_table_lower)

                if p_table_lower not in tier_a_tables:
                    t_type = "fact"
                    if p_table_lower.endswith("_dim") or "_dim" in p_table_lower:
                        t_type = "dim"
                    elif p_table_lower.startswith("opr_") or "_rpt" in p_table_lower:
                        t_type = "operational"

                    tier_a_tables[p_table_lower] = {
                        "table_name": p_table_lower,
                        "entity_name": l_entity or p_table,
                        "file_path": str(csv_f),
                        "table_type": t_type,
                        "columns": set(),
                    }

                if p_col:
                    tier_a_tables[p_table_lower]["columns"].add(p_col)

                if l_entity:
                    lld_entity_to_table[l_entity] = p_table_lower
                    if not tier_a_tables[p_table_lower]["entity_name"]:
                        tier_a_tables[p_table_lower]["entity_name"] = l_entity

    # 2. Tier B: Gather HLD Entities from Datamart/hld/DTM_{MODULE}_Entities.csv
    entities_csv_path = resolve_entities_csv(root, mod_norm)
    tier_b_entities: Dict[str, Dict[str, Any]] = {}

    if entities_csv_path and entities_csv_path.is_file():
        _, _, ent_rows = read_csv_dynamic(entities_csv_path)
        for r in ent_rows:
            entity_name = r.get("datamart_entity", "").strip()
            if not entity_name:
                continue

            result.tier_b_hld_entities.add(entity_name)
            tier_b_entities[entity_name] = {
                "entity_name": entity_name,
                "table_type": r.get("table_type", "fact").strip().lower(),
                "reuse_status": r.get("reuse_status", "new").strip().lower(),
                "status": r.get("status", "draft").strip().lower(),
                "description": r.get("description", "").strip(),
                "source_table": r.get("source_table", "").strip(),
                "fks": r.get("FKs", "").strip(),
                "file_path": str(entities_csv_path),
            }

    # 3. Tier C: Gather Flat Tables from Datamart/flat-table/{MODULE}/01_create_*.sql
    flat_sql_path = resolve_flat_table_sql(root, mod_norm, script_num="01")
    tier_c_flat_map: Dict[str, str] = {}
    sql_text = ""

    if flat_sql_path and flat_sql_path.is_file():
        sql_text = read_file_safe(flat_sql_path)
        tier_c_flat_map = extract_flat_tables_from_sql(sql_text, mod_norm)
        for base_t, raw_t in tier_c_flat_map.items():
            result.tier_c_flat_tables.add(base_t)

    # 4. Load Detail Mapping active measures
    detail_mapping_path = resolve_module_path(root, mod_norm, "detail_mapping")
    active_measures, all_deprecated = load_detail_mapping_measures(detail_mapping_path)

    # 5. Build 3-way Matching Matrix
    lld_by_norm_entity: Dict[str, str] = {
        normalize_entity_key(ent): tbl for ent, tbl in lld_entity_to_table.items()
    }
    hld_by_norm_entity: Dict[str, str] = {
        normalize_entity_key(ent): ent for ent in tier_b_entities.keys()
    }

    # Step A: Evaluate all HLD Entities (Tier B)
    for ent_name, ent_info in tier_b_entities.items():
        t_type = ent_info["table_type"]
        reuse_status = ent_info["reuse_status"]
        is_dim = t_type == "dim" or ent_name.lower().endswith(" dimension")

        # Check conformed reuse
        is_conformed = reuse_status in ("reuse", "partial", "conformed")
        if is_conformed:
            result.conformed_reused_tables.add(ent_name)
            continue

        # Check dimension denormalization
        if is_dim:
            result.denormalized_dims.add(ent_name)

        # Attempt to map to LLD physical table
        matched_table: Optional[str] = None
        if ent_name in lld_entity_to_table:
            matched_table = lld_entity_to_table[ent_name]
        else:
            norm_k = normalize_entity_key(ent_name)
            if norm_k in lld_by_norm_entity:
                matched_table = lld_by_norm_entity[norm_k]
                result.naming_warnings.append(
                    f"Entity '{ent_name}' in HLD matched to LLD table '{matched_table}' via normalized name."
                )

        in_lld = matched_table is not None and matched_table in tier_a_tables
        in_flat = False
        if matched_table:
            in_flat = matched_table in tier_c_flat_map
        else:
            norm_snake = re.sub(r"[\s\-]+", "_", normalize_entity_key(ent_name))
            for ft_base in tier_c_flat_map:
                if norm_snake in ft_base or ft_base in norm_snake:
                    in_flat = True
                    matched_table = ft_base
                    break

        # Check orphan condition for Tier B entity
        is_orphan = False
        orphan_type = OrphanType.HLD_ONLY

        if is_dim:
            if not in_lld:
                is_orphan = True
                orphan_type = OrphanType.HLD_ONLY
        else:
            if not in_lld and not in_flat:
                is_orphan = True
                orphan_type = OrphanType.HLD_ONLY
            elif in_lld and not in_flat:
                is_orphan = True
                orphan_type = OrphanType.HLD_AND_LLD_MISSING_FLAT
            elif not in_lld and in_flat:
                is_orphan = True
                orphan_type = OrphanType.HLD_AND_FLAT_MISSING_LLD

        if is_orphan:
            act_measures = active_measures.get(ent_name, 0)
            is_dep = all_deprecated.get(ent_name, False)

            branch, reason, remediation = classify_resolution_branch(
                entity_name=ent_name,
                table_name=matched_table or ent_name,
                module=mod_norm,
                active_measures_count=act_measures,
                is_all_deprecated=is_dep,
                is_in_lld=in_lld,
                is_in_flat=in_flat,
                description_text=ent_info.get("description", ""),
                sql_notes=sql_text,
            )

            item = OrphanItem(
                module=mod_norm,
                entity_name=ent_name,
                table_name=matched_table or "(unmapped)",
                table_type=t_type,
                reuse_status=reuse_status,
                orphan_type=orphan_type,
                branch=branch,
                in_tier_a_lld=in_lld,
                in_tier_b_hld=True,
                in_tier_c_flat=in_flat,
                active_measures_count=act_measures,
                reason=reason,
                remediation_action=remediation,
                source_files={
                    "hld": str(entities_csv_path or ""),
                    "lld": str(tier_a_tables.get(matched_table, {}).get("file_path", "")),
                    "flat_table": str(flat_sql_path or ""),
                },
            )
            result.orphans.append(item)
            if branch == ResolutionBranch.BRANCH_A_COMPLETE_MISSING:
                result.branch_a_missing.append(item)
            else:
                result.branch_b_orphans.append(item)

    # Step B: Evaluate all LLD Tables (Tier A) to check if missing in HLD or Flat Table
    for p_table, lld_info in tier_a_tables.items():
        l_entity = lld_info["entity_name"]
        t_type = lld_info["table_type"]
        is_dim = t_type == "dim" or p_table.endswith("_dim")

        if is_dim:
            result.denormalized_dims.add(p_table)

        in_hld = l_entity in tier_b_entities
        if not in_hld:
            norm_k = normalize_entity_key(l_entity)
            if norm_k in hld_by_norm_entity:
                in_hld = True

        in_flat = p_table in tier_c_flat_map

        already_reported = any(o.table_name.lower() == p_table for o in result.orphans)
        if already_reported:
            continue

        is_orphan = False
        orphan_type = OrphanType.LLD_ONLY

        if is_dim:
            if not in_hld:
                is_orphan = True
                orphan_type = OrphanType.LLD_ONLY
        else:
            if not in_hld and in_flat:
                is_orphan = True
                orphan_type = OrphanType.LLD_AND_FLAT_MISSING_HLD
            elif not in_hld and not in_flat:
                is_orphan = True
                orphan_type = OrphanType.LLD_ONLY
            elif in_hld and not in_flat:
                is_orphan = True
                orphan_type = OrphanType.HLD_AND_LLD_MISSING_FLAT

        if is_orphan:
            act_measures = active_measures.get(l_entity, 0)
            is_dep = all_deprecated.get(l_entity, False)

            branch, reason, remediation = classify_resolution_branch(
                entity_name=l_entity,
                table_name=p_table,
                module=mod_norm,
                active_measures_count=act_measures,
                is_all_deprecated=is_dep,
                is_in_lld=True,
                is_in_flat=in_flat,
                description_text="",
                sql_notes=sql_text,
            )

            item = OrphanItem(
                module=mod_norm,
                entity_name=l_entity,
                table_name=p_table,
                table_type=t_type,
                reuse_status="new",
                orphan_type=orphan_type,
                branch=branch,
                in_tier_a_lld=True,
                in_tier_b_hld=in_hld,
                in_tier_c_flat=in_flat,
                active_measures_count=act_measures,
                reason=reason,
                remediation_action=remediation,
                source_files={
                    "lld": lld_info.get("file_path", ""),
                    "flat_table": str(flat_sql_path or ""),
                },
            )
            result.orphans.append(item)
            if branch == ResolutionBranch.BRANCH_A_COMPLETE_MISSING:
                result.branch_a_missing.append(item)
            else:
                result.branch_b_orphans.append(item)

    # Step C: Evaluate Flat Tables (Tier C)
    for ft_base, raw_flat in tier_c_flat_map.items():
        if ft_base in tier_a_tables:
            continue
        already_reported = any(o.table_name.lower() == ft_base for o in result.orphans)
        if already_reported:
            continue

        item = OrphanItem(
            module=mod_norm,
            entity_name=raw_flat,
            table_name=ft_base,
            table_type="fact",
            reuse_status="new",
            orphan_type=OrphanType.FLAT_TABLE_ONLY,
            branch=ResolutionBranch.BRANCH_B_ALL_TIER_CLEANUP,
            in_tier_a_lld=False,
            in_tier_b_hld=False,
            in_tier_c_flat=True,
            active_measures_count=0,
            reason="Flat table exists in SQL DDL but has no corresponding LLD attributes file or HLD entity.",
            remediation_action=f"Remove orphaned SQL definition '{raw_flat}' or create LLD attributes.",
            source_files={"flat_table": str(flat_sql_path or "")},
        )
        result.orphans.append(item)
        result.branch_b_orphans.append(item)

    # Final summary and status
    result.status = "PASS" if len(result.orphans) == 0 else "FAIL"
    result.summary = {
        "module": mod_norm,
        "status": result.status,
        "total_lld_tables": len(result.tier_a_lld_tables),
        "total_hld_entities": len(result.tier_b_hld_entities),
        "total_flat_tables": len(result.tier_c_flat_tables),
        "total_orphans": len(result.orphans),
        "branch_a_count": len(result.branch_a_missing),
        "branch_b_count": len(result.branch_b_orphans),
        "conformed_reused_count": len(result.conformed_reused_tables),
        "denormalized_dims_count": len(result.denormalized_dims),
        "naming_warnings_count": len(result.naming_warnings),
    }

    return result


def audit_all_orphans(
    root_dir: Optional[str | Path] = None,
) -> Dict[str, OrphanCheckResult]:
    """Run 3-way orphan check across all available modules in repository."""
    root = find_project_root(root_dir)
    modules = get_available_modules(root)
    results: Dict[str, OrphanCheckResult] = {}
    for mod in modules:
        if mod.upper() == "COMMON":
            continue
        results[mod] = audit_module_orphans(mod, root_dir=root)
    return results


def check_orphan_3way(
    module: str,
    root_dir: Optional[str | Path] = None,
) -> OrphanCheckResult:
    """
    Interface contract function for 3-way orphan checking.
    Accepts specific module name (e.g. 'GSTT', 'QLCB', 'TKNB') or 'all'.
    """
    root = find_project_root(root_dir)
    mod = module.strip()

    if mod.lower() == "all":
        all_results = audit_all_orphans(root_dir=root)
        aggregated = OrphanCheckResult(module="all")
        for m_name, res in all_results.items():
            aggregated.tier_a_lld_tables.update(res.tier_a_lld_tables)
            aggregated.tier_b_hld_entities.update(res.tier_b_hld_entities)
            aggregated.tier_c_flat_tables.update(res.tier_c_flat_tables)
            aggregated.orphans.extend(res.orphans)
            aggregated.branch_a_missing.extend(res.branch_a_missing)
            aggregated.branch_b_orphans.extend(res.branch_b_orphans)
            aggregated.conformed_reused_tables.update(res.conformed_reused_tables)
            aggregated.denormalized_dims.update(res.denormalized_dims)
            aggregated.naming_warnings.extend(res.naming_warnings)
            aggregated.module_results[m_name] = res

        aggregated.status = "PASS" if len(aggregated.orphans) == 0 else "FAIL"
        aggregated.summary = {
            "module": "all",
            "status": aggregated.status,
            "total_modules_audited": len(all_results),
            "total_orphans": len(aggregated.orphans),
            "total_branch_a": len(aggregated.branch_a_missing),
            "total_branch_b": len(aggregated.branch_b_orphans),
        }
        return aggregated

    return audit_module_orphans(mod, root_dir=root)


def generate_orphan_markdown_report(
    check_result: OrphanCheckResult | List[OrphanCheckResult],
) -> str:
    """Format OrphanCheckResult into a comprehensive human-readable Markdown report."""
    results = check_result if isinstance(check_result, list) else [check_result]

    lines = [
        "# Datamart 3-Way Orphan Entity Audit Report",
        "",
        "> Audit Scope: Tier A (LLD Attributes CSV) ↔ Tier B (HLD Entities CSV) ↔ Tier C (Flat Table SQL DDL)",
        "",
    ]

    total_orphans = sum(len(r.orphans) for r in results)
    total_branch_a = sum(len(r.branch_a_missing) for r in results)
    total_branch_b = sum(len(r.branch_b_orphans) for r in results)
    overall_status = "PASS" if total_orphans == 0 else "FAIL"

    lines.append("## Executive Summary")
    lines.append(f"- **Overall Status**: `{overall_status}`")
    lines.append(f"- **Total Orphan Entities Detected**: `{total_orphans}`")
    lines.append(f"  - **Branch A (Incomplete — Complete Missing Artifacts)**: `{total_branch_a}`")
    lines.append(f"  - **Branch B (Deprecated — All-Tier Cleanup Protocol)**: `{total_branch_b}`")
    lines.append("")

    lines.append("## Module Audit Matrix")
    lines.append("| Module | LLD Tables | HLD Entities | Flat Tables | Conformed Reused | Dims Denorm | Orphans | Status |")
    lines.append("|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|")

    for r in results:
        if r.module == "all" and r.module_results:
            for sub_mod, sub_r in sorted(r.module_results.items()):
                lines.append(
                    f"| **{sub_mod}** | {len(sub_r.tier_a_lld_tables)} | {len(sub_r.tier_b_hld_entities)} | "
                    f"{len(sub_r.tier_c_flat_tables)} | {len(sub_r.conformed_reused_tables)} | "
                    f"{len(sub_r.denormalized_dims)} | {len(sub_r.orphans)} | `{sub_r.status}` |"
                )
            break
        else:
            lines.append(
                f"| **{r.module}** | {len(r.tier_a_lld_tables)} | {len(r.tier_b_hld_entities)} | "
                f"{len(r.tier_c_flat_tables)} | {len(r.conformed_reused_tables)} | "
                f"{len(r.denormalized_dims)} | {len(r.orphans)} | `{r.status}` |"
            )
    lines.append("")

    all_orphans: List[OrphanItem] = []
    for r in results:
        all_orphans.extend(r.orphans)

    if not all_orphans:
        lines.append("## Detailed Discrepancies")
        lines.append("No orphan entities detected across audited scope. All Fact/Operational tables are coherent.")
        lines.append("")
    else:
        branch_a = [o for o in all_orphans if o.branch == ResolutionBranch.BRANCH_A_COMPLETE_MISSING]
        branch_b = [o for o in all_orphans if o.branch == ResolutionBranch.BRANCH_B_ALL_TIER_CLEANUP]

        if branch_a:
            lines.append("### Branch A: Incomplete Entities (Active Measures Exist — Action: Complete Missing Artifacts)")
            lines.append("| Module | Entity Name | Table Name | Type | Missing Tier | Active Measures | Remediation Action |")
            lines.append("|---|---|---|:---:|---|:---:|---|")
            for o in branch_a:
                missing_str = o.orphan_type.value.replace("_", " ")
                lines.append(
                    f"| {o.module} | `{o.entity_name}` | `{o.table_name}` | {o.table_type} | "
                    f"{missing_str} | {o.active_measures_count} | {o.remediation_action} |"
                )
            lines.append("")

        if branch_b:
            lines.append("### Branch B: Deprecated / Abandoned Entities (0 Measures — Action: All-Tier Cleanup Protocol)")
            lines.append("| Module | Entity Name | Table Name | Type | Detected In | Reason | Remediation Action |")
            lines.append("|---|---|---|:---:|---|---|---|")
            for o in branch_b:
                detected_in = []
                if o.in_tier_b_hld:
                    detected_in.append("HLD")
                if o.in_tier_a_lld:
                    detected_in.append("LLD")
                if o.in_tier_c_flat:
                    detected_in.append("Flat SQL")
                det_str = " + ".join(detected_in) or "None"
                lines.append(
                    f"| {o.module} | `{o.entity_name}` | `{o.table_name}` | {o.table_type} | "
                    f"{det_str} | {o.reason} | {o.remediation_action} |"
                )
            lines.append("")

    all_warnings: List[str] = []
    for r in results:
        all_warnings.extend(r.naming_warnings)
    if all_warnings:
        lines.append("## Naming & Normalization Notes")
        for w in all_warnings:
            lines.append(f"- {w}")
        lines.append("")

    return "\n".join(lines)
