"""Đọc artifacts Silver design (HLD MD, LLD CSV) và biến thành dict cho Jinja2 render.

Schema return cho 1 source:

    {
        "source": "FIMS",
        "source_desc": "Hệ thống quản lý giám sát nhà đầu tư nước ngoài (MySQL)",
        "scope_desc": "Quản lý giám sát nhà đầu tư nước ngoài...",
        "tier_count": 3,
        "total_attrs": 142,
        "silver_diagram_mermaid": "graph TD\\n  ...",
        "entities": [
            {
                "silver_entity": "Disclosure Authorization",
                "description": "...",
                "bcv_concept": "[Arrangement] Authorization",
                "bcv_core_object": "Arrangement",
                "table_type": "Fundamental",
                "source_table": "FIMS.AUTHOANNOUNCE",
                "tier": "T2",
                "attributes": [
                    {
                        "attribute_name": "Disclosure Authorization Id",
                        "description": "...",
                        "data_domain": "Surrogate Key",
                        "nullable": False,
                        "is_primary_key": True,
                        "source_columns": "",
                        "comment": "PK surrogate.",
                        "classification_context": "",
                        "etl_derived_value": "",
                    },
                    ...
                ],
            },
            ...
        ],
        "classifications": [...],   # ref_shared_entity_classifications.csv lọc theo source
        "pendings": [...],          # pending_design.csv lọc theo source
    }
"""

from __future__ import annotations

import csv
import re
from pathlib import Path
from typing import Any


def _read_csv(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def _yn(value: str) -> bool:
    return value.strip().lower() in ("true", "yes", "y", "1", "x")


def load_manifest(repo_root: Path, source: str) -> list[dict[str, str]]:
    rows = _read_csv(repo_root / "Silver" / "lld" / "manifest.csv")
    return [r for r in rows if r["source_system"] == source]


def load_silver_entities(repo_root: Path, source: str) -> list[dict[str, str]]:
    rows = _read_csv(repo_root / "Silver" / "hld" / "silver_entities.csv")
    return [r for r in rows if r["source_table"].split(".", 1)[0] == source]


# FK target syntax in LLD comments:
#   "FK target: <Entity Name>.<Attribute Name>."  hoặc kèm câu sau dấu chấm.
# Pattern: 'Entity' và 'Attribute' đều có thể chứa nhiều từ; dấu kết thúc Attribute là
# '.' theo sau bởi space + chữ HOA (mới câu) hoặc end-of-string.
_FK_TARGET_RE = re.compile(
    r"FK target:\s*([A-Z][^.]*?)\.([A-Z][^.]*?)(?:\.\s|\.$|$)"
)


def _parse_fk_target(comment: str) -> tuple[str, str] | None:
    """Trích (target_entity, target_attribute) từ comment 'FK target: <Entity>.<Attribute>.'.

    Vd: 'FK target: Geographic Area.Geographic Area Id. ID quốc gia...' → ('Geographic Area', 'Geographic Area Id')
    Trả về None nếu không match.
    """
    if not comment:
        return None
    m = _FK_TARGET_RE.search(comment)
    if not m:
        return None
    return m.group(1).strip(), m.group(2).strip()


def load_attributes(repo_root: Path, source: str, lld_filename: str) -> list[dict[str, Any]]:
    path = repo_root / "Silver" / "lld" / source / lld_filename
    rows = _read_csv(path)
    out: list[dict[str, Any]] = []
    for r in rows:
        comment = r.get("comment", "")
        fk_target = _parse_fk_target(comment)
        out.append({
            "attribute_name": r["attribute_name"],
            "description": r["description"],
            "data_domain": r["data_domain"],
            "nullable": _yn(r.get("nullable", "")),
            "is_primary_key": _yn(r.get("is_primary_key", "")),
            "status": r.get("status", ""),
            "source_columns": r.get("source_columns", ""),
            "comment": comment,
            "classification_context": r.get("classification_context", ""),
            "etl_derived_value": r.get("etl_derived_value", ""),
            "fk_target_entity": fk_target[0] if fk_target else "",
            "fk_target_attribute": fk_target[1] if fk_target else "",
        })
    return out


def _to_snake_case(name: str) -> str:
    """Convert 'Disclosure Authorization' → 'disclosure_authorization'."""
    return name.strip().lower().replace("-", "_").replace(" ", "_")


def build_constraints(entity: dict[str, Any]) -> list[dict[str, str]]:
    """Sinh danh sách FK constraint cho 1 entity từ attributes có fk_target_entity non-empty."""
    out: list[dict[str, str]] = []
    for a in entity["attributes"]:
        if not a["fk_target_entity"]:
            continue
        out.append({
            "field": a["attribute_name"],
            "ref_table": a["fk_target_entity"],
            "ref_field": a["fk_target_attribute"],
        })
    return out


def build_dbml(source: str, entities: list[dict[str, Any]]) -> str:
    """Sinh DBML (https://dbml.dbdiagram.io) cho danh sách entities.

    Ref relations sinh từ fk_target_entity / fk_target_attribute.
    Bỏ qua FK trỏ đến entity ngoài source (shared entity của source khác).
    """
    in_scope_tables = {e["silver_entity"] for e in entities}
    lines: list[str] = [f"// Silver Lakehouse — {source}", ""]

    for e in entities:
        table_name = _to_snake_case(e["silver_entity"])
        lines.append(f'Table {table_name} [note: "{e["description"][:200].replace(chr(34), "")}"] {{')
        for a in e["attributes"]:
            field = _to_snake_case(a["attribute_name"])
            domain = a["data_domain"]
            sql_type_map = {
                "Text": "varchar",
                "Date": "date",
                "Timestamp": "timestamp",
                "Currency Amount": "decimal(18,2)",
                "Interest Rate": "decimal(9,6)",
                "Exchange Rate": "decimal(18,6)",
                "Percentage": "decimal(9,6)",
                "Surrogate Key": "bigint",
                "Classification Value": "varchar",
                "Indicator": "varchar",
                "Boolean": "boolean",
                "Small Counter": "int",
            }
            sql_type = sql_type_map.get(domain, "varchar")

            modifiers: list[str] = []
            if a["is_primary_key"]:
                modifiers.append("pk")
            if not a["nullable"]:
                modifiers.append("not null")
            mod_str = f" [{', '.join(modifiers)}]" if modifiers else ""
            lines.append(f"  {field} {sql_type}{mod_str}")
        lines.append("}")
        lines.append("")

    # Refs
    for e in entities:
        from_table = _to_snake_case(e["silver_entity"])
        for a in e["attributes"]:
            if not a["fk_target_entity"]:
                continue
            ref_table = a["fk_target_entity"]
            if ref_table not in in_scope_tables:
                # Cross-source FK — comment out để user xem nhưng không crash dbdiagram
                lines.append(
                    f"// Ref: {from_table}.{_to_snake_case(a['attribute_name'])} > "
                    f"{_to_snake_case(ref_table)}.{_to_snake_case(a['fk_target_attribute'])} "
                    f"// out-of-source: {ref_table} không nằm trong {source}"
                )
                continue
            lines.append(
                f"Ref: {from_table}.{_to_snake_case(a['attribute_name'])} > "
                f"{_to_snake_case(ref_table)}.{_to_snake_case(a['fk_target_attribute'])}"
            )
    return "\n".join(lines) + "\n"


def parse_hld_overview(repo_root: Path, source: str) -> dict[str, str]:
    """Trích metadata từ {SOURCE}_HLD_Overview.md: source_desc + scope_desc + mermaid block."""
    path = repo_root / "Silver" / "hld" / f"{source}_HLD_Overview.md"
    if not path.exists():
        return {"source_desc": "", "scope_desc": "", "silver_diagram_mermaid": ""}

    text = path.read_text(encoding="utf-8")

    desc_match = re.search(r"\*\*Nguồn:\*\*\s*(.+)", text)
    source_desc = desc_match.group(1).strip() if desc_match else ""
    # Strip leading "Hệ thống {SOURCE} — " prefix nếu có (tránh duplicate trong tiêu đề render)
    source_desc = re.sub(rf"^Hệ thống\s+{re.escape(source)}\s*[—-]\s*", "", source_desc)
    # Strip trailing " (DB type)" — vd "(MySQL)", "(Oracle)"
    source_desc = re.sub(r"\s*\([^)]*\)\s*$", "", source_desc)

    scope_match = re.search(r"\*\*Phạm vi:\*\*\s*(.+)", text)
    scope_desc = scope_match.group(1).strip() if scope_match else ""

    mermaid_match = re.search(r"## 7b\..*?\n```mermaid\n(.+?)```", text, re.DOTALL)
    if not mermaid_match:
        mermaid_match = re.search(r"## 6b\..*?\n```mermaid\n(.+?)```", text, re.DOTALL)
    mermaid = mermaid_match.group(1).rstrip() if mermaid_match else ""

    return {
        "source_desc": source_desc,
        "scope_desc": scope_desc,
        "silver_diagram_mermaid": mermaid,
    }


def load_classifications(repo_root: Path, source: str) -> list[dict[str, str]]:
    rows = _read_csv(repo_root / "Silver" / "lld" / "ref_shared_entity_classifications.csv")
    out = []
    for r in rows:
        used_in = r.get("used_in_entities", "")
        src_table = r.get("source_table", "")
        if source in used_in or src_table.startswith(f"{source}."):
            out.append(r)
    return out


def load_pendings(repo_root: Path, source: str) -> list[dict[str, str]]:
    rows = _read_csv(repo_root / "Silver" / "lld" / "pending_design.csv")
    return [r for r in rows if r["source_system"] == source]


def load_source(repo_root: Path, source: str, sample: bool = False, sample_count: int = 2) -> dict[str, Any]:
    """Tổng hợp toàn bộ artifacts cho 1 source.

    sample=True: chỉ lấy `sample_count` entity đầu tiên (theo order manifest).
    """
    manifest_rows = load_manifest(repo_root, source)
    entities_meta = load_silver_entities(repo_root, source)

    meta_lookup: dict[str, dict[str, str]] = {}
    for em in entities_meta:
        key = (em["silver_entity"], em["source_table"])
        meta_lookup[key] = em

    seen: set[str] = set()
    entities: list[dict[str, Any]] = []
    total_attrs = 0
    tiers: set[str] = set()

    rows_to_process = manifest_rows[:sample_count] if sample else manifest_rows

    for row in rows_to_process:
        silver_entity = row["silver_entity"]
        if silver_entity in seen:
            continue
        seen.add(silver_entity)

        src_table_full = f"{row['source_system']}.{row['source_table']}"
        meta = meta_lookup.get((silver_entity, src_table_full), {})

        attributes = load_attributes(repo_root, source, row["lld_file"])
        total_attrs += len(attributes)
        tiers.add(row["group"])

        entity = {
            "silver_entity": silver_entity,
            "table_name": _to_snake_case(silver_entity),
            "source_table": src_table_full,
            "tier": row["group"],
            "lld_file": row["lld_file"],
            "bcv_concept": meta.get("bcv_concept", ""),
            "bcv_core_object": meta.get("bcv_core_object", ""),
            "table_type": meta.get("table_type", ""),
            "description": meta.get("description", ""),
            "attributes": attributes,
        }
        entity["constraints"] = build_constraints(entity)
        entities.append(entity)

    hld_meta = parse_hld_overview(repo_root, source)

    return {
        "source": source,
        "source_desc": hld_meta["source_desc"],
        "scope_desc": hld_meta["scope_desc"],
        "silver_diagram_mermaid": hld_meta["silver_diagram_mermaid"],
        "tier_count": len(tiers),
        "total_attrs": total_attrs,
        "entities": entities,
        "classifications": load_classifications(repo_root, source),
        "pendings": load_pendings(repo_root, source),
        "is_sample": sample,
    }
