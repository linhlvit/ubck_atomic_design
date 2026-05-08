"""Jinja2 render engine cho atomic-gen-docs.

Render fragment per-source và master template.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any

from jinja2 import Environment, FileSystemLoader, StrictUndefined

import filters as F


def make_env(templates_dir: Path) -> Environment:
    env = Environment(
        loader=FileSystemLoader(str(templates_dir)),
        undefined=StrictUndefined,
        trim_blocks=False,
        lstrip_blocks=False,
        keep_trailing_newline=True,
    )
    env.filters["data_domain_to_sql"] = F.data_domain_to_sql
    env.filters["x_or_blank"] = F.x_or_blank
    env.filters["pk_fk_label"] = F.pk_fk_label
    env.filters["default_value"] = F.default_value
    env.filters["etl_rule"] = F.etl_rule
    return env


def render_fragment(env: Environment, source_data: dict[str, Any], idx: int) -> str:
    template = env.get_template("atomic_dbdesign_fragment.md")
    return template.render(idx=idx, **source_data)


def render_master(
    env: Environment,
    sources_data: list[dict[str, Any]],
    sources: list[str],
    fragments: list[str],
    all_classifications: list[dict[str, str]],
    all_pendings: list[dict[str, str]],
    generated_at: str,
) -> str:
    template = env.get_template("atomic_dbdesign.md")
    sources_data_with_fragment = []
    for sd, frag in zip(sources_data, fragments):
        sources_data_with_fragment.append({**sd, "fragment": frag})
    total_entities = sum(len(sd["entities"]) for sd in sources_data)
    grand_total_attrs = sum(sd["total_attrs"] for sd in sources_data)
    return template.render(
        sources=sources,
        sources_data=sources_data_with_fragment,
        all_classifications=all_classifications,
        all_pendings=all_pendings,
        generated_at=generated_at,
        total_entities=total_entities,
        grand_total_attrs=grand_total_attrs,
    )
