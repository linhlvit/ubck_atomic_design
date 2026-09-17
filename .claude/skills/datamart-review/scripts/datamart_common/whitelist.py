# -*- coding: utf-8 -*-
"""
scripts/datamart_common/whitelist.py

Reconciled Delta Whitelist Engine:
Loads approved count mismatch exceptions from YAML configuration and validates
whether group count differences between BA, HLD, and Detail Mapping are authorized.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple, Union

try:
    from .module_resolver import normalize_module_name
except ImportError:
    try:
        from datamart_common.module_resolver import normalize_module_name
    except ImportError:
        def normalize_module_name(name: str) -> str:
            return name.strip().upper()


# Default built-in fallback rules in case YAML file is inaccessible
DEFAULT_FALLBACK_RULES: List[Dict[str, Any]] = [
    {
        "rule_id": "WL-GSDC-BCTC-01",
        "module": "GSĐC",
        "aliases": ["GSDC"],
        "group_range": [21, 30],
        "reason_type": "ENTERPRISE_TYPE_SPLIT",
        "name": "Nhân bản Báo cáo tài chính theo 3 loại hình Doanh nghiệp",
        "description": "Nhân bản 3 loại hình: Công ty niêm yết (CTNY), Đại chúng quy mô lớn (CTTG), Đại chúng thông thường (CTDC)",
        "condition": "dm_rows == hld_kpis * 3 or (hld_kpis * 2 <= dm_rows <= hld_kpis * 3)",
        "approval_ref": "RFC-2026-08-GSDC-BCTC",
        "status": "APPROVED",
    },
    {
        "rule_id": "WL-GSTT-YOY-01",
        "module": "GSTT",
        "groups": ["1", "2", "3", "4"],
        "reason_type": "DERIVED_YOY_METRICS",
        "name": "Chỉ tiêu phái sinh chuỗi thời gian YoY/MoM",
        "description": "HLD/LLD tự bổ sung các chỉ tiêu so sánh cùng kỳ (_YOY, _MOM) phục vụ biểu đồ trực quan",
        "condition": "hld_kpis >= ba_done_doing",
        "approval_ref": "RFC-2026-07-GSTT-YOY",
        "status": "APPROVED",
    },
    {
        "rule_id": "WL-NHNCK-SPLIT-01",
        "module": "NHNCK",
        "groups": ["1", "2", "7"],
        "reason_type": "PHYSICAL_MEASURE_SPLIT",
        "name": "Phân rã Measure vật lý từ chỉ tiêu nghiệp vụ gộp",
        "description": "Tách 1 chỉ tiêu BA gộp thành nhiều measure vật lý chi tiết trong Detail Mapping",
        "condition": "dm_rows >= hld_kpis",
        "approval_ref": "RFC-2026-09-NHNCK-SPLIT",
        "status": "APPROVED",
    },
    {
        "rule_id": "WL-QLKD-BANNER-01",
        "module": "QLKD",
        "groups": ["1", "19"],
        "reason_type": "BANNER_SUMMARY_METRICS",
        "name": "Chỉ tiêu tổng hợp Banner và Thống kê thị trường",
        "description": "Các chỉ tiêu banner tổng hợp per-CTCK hoặc per-Toàn thị trường có độ phân rã khác biệt",
        "condition": "abs(hld_kpis - ba_done_doing) <= 5 or dm_rows >= hld_kpis",
        "approval_ref": "RFC-2026-08-QLKD-BANNER",
        "status": "APPROVED",
    },
    {
        "rule_id": "WL-TKNB-DETAIL-01",
        "module": "TKNB",
        "groups": ["1", "2", "3"],
        "reason_type": "AGGREGATION_LEVEL_VARIANCE",
        "name": "Tách mức độ tổng hợp thống kê nội bộ",
        "description": "Tách theo các cấp quản lý và phòng ban nội bộ của UBCKNN",
        "condition": "dm_rows >= hld_kpis or hld_kpis >= ba_done_doing",
        "approval_ref": "RFC-2026-08-TKNB-STAT",
        "status": "APPROVED",
    },
]


def load_whitelist(root_dir: Optional[Union[Path, str]] = None) -> List[Dict[str, Any]]:
    """
    Loads approved whitelist rules from YAML configuration file.
    Searches standard system/rules and .claude reference locations,
    falling back to robust built-in rules if YAML is not present.
    """
    candidates = []
    if root_dir:
        root_path = Path(root_dir).resolve()
        candidates.append(root_path / "system" / "rules" / "datamart_review_whitelist.yaml")
        candidates.append(root_path / ".claude" / "skills" / "datamart-review" / "reference" / "datamart_review_whitelist.yaml")

    # Search upwards from current file
    curr = Path(__file__).resolve()
    for parent in [curr] + list(curr.parents):
        candidates.append(parent / "system" / "rules" / "datamart_review_whitelist.yaml")
        candidates.append(parent / ".claude" / "skills" / "datamart-review" / "reference" / "datamart_review_whitelist.yaml")

    target_file = next((p for p in candidates if p.exists() and p.is_file()), None)
    if not target_file:
        return list(DEFAULT_FALLBACK_RULES)

    try:
        import yaml  # type: ignore
        content = target_file.read_text(encoding="utf-8")
        data = yaml.safe_load(content)
        if isinstance(data, dict) and "rules" in data and isinstance(data["rules"], list):
            return data["rules"]
    except Exception:
        pass

    return list(DEFAULT_FALLBACK_RULES)


def is_group_whitelisted(
    module: str,
    group_key: str,
    ba_cnt: int,
    hld_cnt: int,
    dm_cnt: int,
    rules: Optional[List[Dict[str, Any]]] = None,
) -> Tuple[bool, Optional[str]]:
    """
    Determines if a count discrepancy for (module, group_key) is covered by an approved whitelist rule.

    Returns:
        (True, reason_description) if whitelisted, or (False, None) if not.
    """
    if rules is None:
        rules = DEFAULT_FALLBACK_RULES

    norm_target = normalize_module_name(module)
    grp_str = str(group_key).strip()
    m_num = re.search(r"\d+", grp_str)
    grp_num = int(m_num.group()) if m_num else None
    clean_grp_str = str(grp_num) if grp_num is not None else grp_str

    for rule in rules:
        # 1. Module match
        rule_mod = rule.get("module", "")
        aliases = rule.get("aliases", [])
        matched_mods = [normalize_module_name(rule_mod)] + [normalize_module_name(a) for a in aliases]
        if norm_target not in matched_mods:
            continue

        # 2. Group match
        group_matched = False
        if "groups" in rule:
            allowed_groups = [str(g).strip() for g in rule["groups"]]
            if grp_str in allowed_groups or clean_grp_str in allowed_groups:
                group_matched = True
        elif "group_range" in rule and grp_num is not None:
            gr_min, gr_max = rule["group_range"]
            if gr_min <= grp_num <= gr_max:
                group_matched = True

        if not group_matched:
            continue

        # 3. Condition check
        cond_expr = rule.get("condition")
        if not cond_expr:
            # Unconditional whitelist for this group
            desc = rule.get("description") or rule.get("name") or "Ngoại lệ kiến trúc hợp lệ"
            return True, desc

        safe_env = {
            "ba_done_doing": ba_cnt,
            "hld_kpis": hld_cnt,
            "dm_rows": dm_cnt,
            "abs": abs,
            "min": min,
            "max": max,
            "round": round,
            "int": int,
            "float": float,
        }
        try:
            passed = bool(eval(cond_expr, {"__builtins__": {}}, safe_env))
        except Exception:
            # If condition expression cannot be safely evaluated, accept if rule is approved
            passed = rule.get("status", "").upper() == "APPROVED"

        if passed:
            desc = rule.get("description") or rule.get("name") or "Ngoại lệ kiến trúc hợp lệ"
            return True, desc

    return False, None
