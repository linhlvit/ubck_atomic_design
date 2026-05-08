"""Đọc artifacts Atomic design (HLD MD, LLD CSV) và biến thành dict cho Jinja2 render.

Schema return cho 1 source:

    {
        "source": "FIMS",
        "source_desc": "Hệ thống quản lý giám sát nhà đầu tư nước ngoài (MySQL)",
        "scope_desc": "Quản lý giám sát nhà đầu tư nước ngoài...",
        "tier_count": 3,
        "total_attrs": 142,
        "atomic_diagram_mermaid": "graph TD\\n  ...",
        "entities": [
            {
                "atomic_entity": "Disclosure Authorization",
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

# Match các format heading UID — dùng finditer, capture (uid_code, label):
#   "## FIMS_UID03 — label"       → WORD_UIDnn  (g1,g2)
#   "## UID-01 — label"           → UID-nn      (g1,g2)
#   "## UID1 — label"             → UIDn        (g3,g4)  GSGD
#   "## UID01 — label"            → UIDnn       (g3,g4)  NHNCK
#   "## DCST-01. label"           → WORD-nn.    (g5,g6)  DCST
#   "## QLRR001 — label"          → WORDnnn     (g7,g8)  QLRR
#   "## FMS.1 — label"            → WORD.n      (g9,g10) FMS
#   "## 1. SCMS_UID01 — label"    → N. WORD_UIDnn (optional numeric prefix via (?:\d+\.\s+)?)
_UID_HEADING_RE = re.compile(
    r"^## (?:\d+\.\s+)?(?:"
    r"(?:\w+_UID|UID-)(\w+)\s+[—-]\s+(.+)"   # FIMS_UID03 / UID-01 / SCMS (after numeric prefix)
    r"|UID(\d+)\s+[—-]\s+(.+)"                # UID1 / UID01 (no dash)
    r"|[A-Z]+-(\w+)\.\s+(.+)"                 # DCST-01. / DCST-SYS.
    r"|[A-Z]+(\d+)\s+[—-]\s+(.+)"             # QLRR001 / SOURCE_PREFIX+digits
    r"|[A-Z]+\.(\d+)\s+[—-]\s+(.+)"           # FMS.1 — label
    r")",
    re.MULTILINE
)
_GREEN_ENTITY_RE = re.compile(
    r"🟢\s+(?!`CV:)(?!↳)"
    r"(?:\*\*([A-Z][^*|(\n<]+?)\*\*"      # **Bold Entity Name**
    r"|\*([A-Z][^*|(\n<]+?)\*"            # *Italic Entity Name*
    r"|([A-Z][^|*\n(<]+?)(?:\s*[*|(<]|$))"  # plain Entity Name
)


def _read_csv(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def _yn(value: str) -> bool:
    return value.strip().lower() in ("true", "yes", "y", "1", "x")


def parse_uid_groups(repo_root: Path, source: str) -> list[dict]:
    """Parse BRD/Source/{SOURCE}_Source_Analysis.md → list of UID group dicts.

    Returns: [{"uid": "UID03", "label": "...", "entities": ["Stock Exchange", ...]}, ...]
    Only groups that have at least 1 Atomic entity are returned.
    """
    path = repo_root / "BRD" / "Source" / f"{source}_Source_Analysis.md"
    if not path.exists():
        return []

    text = path.read_text(encoding="utf-8")
    # finditer trả về từng match heading; body = text từ sau heading này đến heading tiếp theo
    matches = list(_UID_HEADING_RE.finditer(text))
    groups = []
    for idx, m in enumerate(matches):
        # group(1,2) = FIMS_UID / UID-NN
        # group(3,4) = UID1 / UID01 (no dash)
        # group(5,6) = DCST-01. / SOURCE-XX.
        # group(7,8) = QLRR001 / SOURCE_PREFIX+digits
        # group(9,10) = FMS.1 — label
        uid_code = (m.group(1) or m.group(3) or m.group(5) or m.group(7) or m.group(9) or "").strip()
        label = (m.group(2) or m.group(4) or m.group(6) or m.group(8) or m.group(10) or "").strip()
        if not uid_code:
            continue
        body_start = m.end()
        body_end = matches[idx + 1].start() if idx + 1 < len(matches) else len(text)
        body = text[body_start:body_end]

        entities: list[str] = []
        for em in _GREEN_ENTITY_RE.finditer(body):
            # group(1) = **Bold**, group(2) = *Italic*, group(3) = plain
            name = (em.group(1) or em.group(2) or em.group(3) or "").strip().rstrip("*").strip()
            if name and name not in entities:
                entities.append(name)
        if entities:
            # Chuẩn hoá uid_code thành dạng "UID01" nếu là số, hoặc giữ nguyên ("SYS", "OUT")
            uid_norm = f"UID{uid_code.zfill(2)}" if uid_code.isdigit() else f"UID{uid_code}"
            groups.append({"uid": uid_norm, "label": label, "entities": entities})
    return groups


def load_manifest(repo_root: Path, source: str) -> list[dict[str, str]]:
    rows = _read_csv(repo_root / "Atomic" / "lld" / "manifest.csv")
    return [r for r in rows if r["source_system"] == source]


def load_atomic_entities(repo_root: Path, source: str) -> list[dict[str, str]]:
    rows = _read_csv(repo_root / "Atomic" / "hld" / "atomic_entities.csv")
    # source_table có thể là multi-value "FMS.SECURITIES, FIMS.FUNDCOMPANY, ..."
    return [r for r in rows if any(t.strip().split(".", 1)[0] == source for t in r["source_table"].split(","))]


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


def load_all_attributes(repo_root: Path) -> list[dict[str, str]]:
    """Đọc atomic_attributes.csv một lần, cache trong module scope."""
    return _read_csv(repo_root / "Atomic" / "lld" / "atomic_attributes.csv")


def load_attributes(
    repo_root: Path,
    source: str,
    atomic_entity: str,
    source_table: str = "",  # nếu truyền vào, lọc thêm theo source_table (dùng cho shared entity)
    _lld_filename: str = "",
) -> list[dict[str, Any]]:
    """Lấy attributes từ atomic_attributes.csv, lọc theo source_system + atomic_entity (+ source_table nếu có)."""
    all_rows = load_all_attributes(repo_root)
    rows = [
        r for r in all_rows
        if r.get("source_system") == source and r.get("atomic_entity") == atomic_entity
        and (not source_table or r.get("source_table") == source_table)
    ]
    out: list[dict[str, Any]] = []
    for r in rows:
        comment = r.get("comment", "")
        fk_target = _parse_fk_target(comment)
        raw_src_col = r.get("source_column", "")
        src_col_parts = raw_src_col.split(".") if raw_src_col else []
        # source_column có dạng "SYSTEM.TABLE.COLUMN" — tách lấy phần cuối
        src_col_name = src_col_parts[-1] if src_col_parts else ""
        out.append({
            "attribute_name": r["atomic_attribute"],
            "atomic_column": r.get("atomic_column", ""),
            "atomic_table": r.get("atomic_table", ""),
            "source_system": r.get("source_system", ""),
            "source_table": r.get("source_table", ""),
            "source_column": raw_src_col,
            "source_column_name": src_col_name,
            "description": r["description"],
            "data_domain": r["data_domain"],
            "data_type": r.get("data_type", ""),
            "nullable": _yn(r.get("nullable", "")),
            "is_primary_key": _yn(r.get("is_primary_key", "")),
            "status": r.get("status", ""),
            "source_columns": r.get("source_column", ""),
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


def _dbml_type(data_type: str) -> str:
    """Convert data_type từ atomic_attributes.csv sang kiểu hợp lệ trong DBML.

    Quy tắc: string → varchar, array<...> → varchar, còn lại giữ nguyên.
    """
    t = (data_type or "").strip()
    if not t:
        return "varchar"
    if t == "string":
        return "varchar"
    if t.startswith("array<"):
        return "varchar"
    return t


def build_constraints(entity: dict[str, Any], all_attrs: list[dict[str, Any]] | None = None) -> list[dict[str, str]]:
    """Sinh danh sách FK constraint cho 1 entity từ attributes có fk_target_entity non-empty.

    all_attrs: toàn bộ atomic_attributes.csv (để lookup ref_col từ ref_table + ref_attribute_name).
    """
    # Xây lookup: (atomic_entity, attribute_name) → atomic_column
    ref_col_lookup: dict[tuple[str, str], str] = {}
    if all_attrs:
        for r in all_attrs:
            key = (r.get("atomic_entity", ""), r.get("atomic_attribute", ""))
            if key not in ref_col_lookup:
                ref_col_lookup[key] = r.get("atomic_column", "")

    out: list[dict[str, str]] = []
    seen: set[tuple[str, str, str, str]] = set()
    for a in entity["attributes"]:
        if not a["fk_target_entity"]:
            continue
        key = (a["attribute_name"], a.get("atomic_column", ""), a["fk_target_entity"], a["fk_target_attribute"])
        if key in seen:
            continue
        seen.add(key)
        ref_col = ref_col_lookup.get((a["fk_target_entity"], a["fk_target_attribute"]), "")
        out.append({
            "field": a["attribute_name"],
            "col": a.get("atomic_column", ""),
            "ref_table": a["fk_target_entity"],
            "ref_field": a["fk_target_attribute"],
            "ref_col": ref_col,
        })
    return out


def build_dbml(
    source: str,
    entities: list[dict[str, Any]],
    uid_groups: list[dict] | None = None,
    note: str = "",
) -> str:
    """Sinh DBML mức bảng (table-only, không liệt kê cột) cho danh sách entities.

    source: phải là identifier hợp lệ trong DBML (không có khoảng trắng, em dash, v.v.)
    note: chuỗi hiển thị tự do cho Project.Note (có thể chứa ký tự đặc biệt).
    uid_groups: nếu truyền vào, thêm TableGroup blocks phân theo mảng nghiệp vụ.
    """
    display = note or f"Atomic Lakehouse — {source}"
    # Dedup theo atomic_entity để DBML không bị lặp bảng khi shared entity có nhiều source_table
    seen_tables: set[str] = set()
    in_scope_tables = {e["atomic_entity"] for e in entities}
    lines: list[str] = [
        f"// {display}",
        "",
        f'Project {source} {{',
        f'  database_type: "Delta Lake"',
        f'  Note: "{display}"',
        "}",
        "",
    ]

    for e in entities:
        # Tên bảng dùng logical name (atomic_entity), quoted để DBML chấp nhận khoảng trắng
        entity_name = e["atomic_entity"]
        if not entity_name:
            continue  # skip entity chưa có attributes (atomic_entity rỗng)
        if entity_name in seen_tables:
            continue
        seen_tables.add(entity_name)
        tbl_note = e["description"][:200].replace('"', "") if e.get("description") else ""
        lines.append(f'Table "{entity_name}" [note: "{tbl_note}"] {{')
        seen_fields: set[str] = set()
        # Sinh PK field(s) — dùng logical name (quoted), nhất quán với tên entity
        for a in e["attributes"]:
            if a["is_primary_key"]:
                col = a["attribute_name"]
                if col not in seen_fields:
                    seen_fields.add(col)
                    dtype = _dbml_type(a.get("data_type", ""))
                    lines.append(f'  "{col}" {dtype} [pk]')
        # Sinh FK field(s) — cần khai báo để Ref hợp lệ
        for a in e["attributes"]:
            if not a["is_primary_key"] and a.get("fk_target_entity"):
                col = a["attribute_name"]
                if col not in seen_fields:
                    seen_fields.add(col)
                    dtype = _dbml_type(a.get("data_type", ""))
                    lines.append(f'  "{col}" {dtype}')
        # Fallback nếu không có PK lẫn FK (shared entity không có PK riêng)
        if not any(a["is_primary_key"] or a.get("fk_target_entity") for a in e["attributes"]):
            lines.append('  "_id" bigint')
        lines.append("}")
        lines.append("")

    # TableGroup blocks — phân theo mảng nghiệp vụ (UID groups)
    if uid_groups:
        for g in uid_groups:
            group_tables = [
                e["atomic_entity"]
                for e in entities
                if e["atomic_entity"] in g["entities"]
                and e["atomic_entity"] in seen_tables
            ]
            # dedup (shared entity có thể xuất hiện nhiều lần trong entities)
            seen_group: set[str] = set()
            unique_tables = [t for t in group_tables if not (t in seen_group or seen_group.add(t))]
            if not unique_tables:
                continue
            lines.append(f'TableGroup "{g["uid"]} — {g["label"]}" {{')
            for t in unique_tables:
                lines.append(f'  "{t}"')
            lines.append("}")
            lines.append("")

    # Refs — dedup theo cặp (from_table.from_col > ref_table.ref_col)
    seen_refs: set[tuple[str, str, str, str]] = set()
    for e in entities:
        from_table = e["atomic_entity"]
        if not from_table:
            continue  # skip entity chưa có attributes
        for a in e["attributes"]:
            if not a["fk_target_entity"]:
                continue
            ref_table = a["fk_target_entity"]
            from_col = a["attribute_name"]
            ref_col = a["fk_target_attribute"]
            ref_key = (from_table, from_col, ref_table, ref_col)
            if ref_key in seen_refs:
                continue
            seen_refs.add(ref_key)
            if ref_table not in in_scope_tables:
                lines.append(
                    f'// Ref: "{from_table}"."{from_col}" > "{ref_table}"."{ref_col}"'
                    f" // out-of-source"
                )
                continue
            lines.append(f'Ref: "{from_table}"."{from_col}" > "{ref_table}"."{ref_col}"')
    return "\n".join(lines) + "\n"


def parse_hld_overview(repo_root: Path, source: str) -> dict[str, str]:
    """Trích metadata từ {SOURCE}_HLD_Overview.md: source_desc + scope_desc + mermaid block."""
    path = repo_root / "Atomic" / "hld" / f"{source}_HLD_Overview.md"
    if not path.exists():
        return {"source_desc": "", "scope_desc": "", "atomic_diagram_mermaid": ""}

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
        "atomic_diagram_mermaid": mermaid,
    }


def load_classifications(repo_root: Path, source: str) -> list[dict[str, str]]:
    rows = _read_csv(repo_root / "Atomic" / "lld" / "ref_shared_entity_classifications.csv")
    out = []
    for r in rows:
        used_in = r.get("used_in_entities", "")
        src_table = r.get("source_table", "")
        if source in used_in or src_table.startswith(f"{source}."):
            out.append(r)
    return out


def load_pendings(repo_root: Path, source: str) -> list[dict[str, str]]:
    rows = _read_csv(repo_root / "Atomic" / "lld" / "pending_design.csv")
    return [r for r in rows if r["source_system"] == source]


def load_source(repo_root: Path, source: str, sample: bool = False, sample_count: int = 2) -> dict[str, Any]:
    """Tổng hợp toàn bộ artifacts cho 1 source.

    sample=True: chỉ lấy `sample_count` entity đầu tiên (theo order manifest).
    """
    manifest_rows = load_manifest(repo_root, source)
    entities_meta = load_atomic_entities(repo_root, source)

    # source_table trong atomic_entities.csv có thể là multi-value "FMS.SECURITIES, FIMS.FUNDCOMPANY, ..."
    # Tạo 1 entry trong meta_lookup cho mỗi source table riêng lẻ
    meta_lookup: dict[str, dict[str, str]] = {}
    for em in entities_meta:
        for src_tbl in em["source_table"].split(","):
            key = (em["atomic_entity"], src_tbl.strip())
            meta_lookup[key] = em

    seen: set[tuple[str, str]] = set()
    entities: list[dict[str, Any]] = []
    total_attrs = 0
    tiers: set[str] = set()

    # Load toàn bộ atomic_attributes 1 lần để dùng cho FK ref_col lookup
    all_attrs_global = load_all_attributes(repo_root)

    # Đếm số source_table khác nhau cho mỗi atomic_entity để nhận diện shared entity
    from collections import Counter
    entity_src_count: Counter = Counter(row["atomic_entity"] for row in manifest_rows)

    rows_to_process = manifest_rows[:sample_count] if sample else manifest_rows

    for row in rows_to_process:
        atomic_entity = row["atomic_entity"]
        src_table = row["source_table"]
        dedup_key = (atomic_entity, src_table)
        if dedup_key in seen:
            continue
        seen.add(dedup_key)

        src_table_full = f"{row['source_system']}.{src_table}"
        meta = meta_lookup.get((atomic_entity, src_table_full), {})

        # Shared entity: lọc attributes theo cả source_table để tách ra từng section riêng
        attributes = load_attributes(repo_root, source, atomic_entity, source_table=src_table)
        total_attrs += len(attributes)
        tiers.add(row["group"])

        atomic_table = attributes[0]["atomic_table"] if attributes else _to_snake_case(atomic_entity)
        entity = {
            "atomic_entity": atomic_entity,
            "atomic_table": atomic_table,
            "table_name": atomic_table,
            "is_shared": entity_src_count[atomic_entity] > 1,
            "source_system": row["source_system"],
            "source_table": src_table,
            "source_table_full": src_table_full,
            "tier": row["group"],
            "lld_file": row.get("lld_file", ""),
            "bcv_concept": meta.get("bcv_concept", ""),
            "bcv_core_object": meta.get("bcv_core_object", ""),
            "table_type": meta.get("table_type", ""),
            "description": meta.get("description", ""),
            "attributes": attributes,
        }
        entity["constraints"] = build_constraints(entity, all_attrs=all_attrs_global)
        entity["primary_keys"] = [a for a in attributes if a["is_primary_key"]]
        entities.append(entity)

    hld_meta = parse_hld_overview(repo_root, source)

    # Chỉ giữ UID groups có ít nhất 1 entity được thiết kế (có trong entities list)
    loaded_entity_names = {e["atomic_entity"] for e in entities}
    uid_groups = [
        g for g in parse_uid_groups(repo_root, source)
        if any(name in loaded_entity_names for name in g["entities"])
    ]

    # Danh sách bảng dedup theo atomic_entity (shared entity xuất hiện nhiều lần → giữ lần đầu)
    seen_entity_names: set[str] = set()
    unique_entities: list[dict[str, Any]] = []
    for e in entities:
        if e["atomic_entity"] not in seen_entity_names:
            seen_entity_names.add(e["atomic_entity"])
            unique_entities.append(e)

    return {
        "source": source,
        "source_desc": hld_meta["source_desc"],
        "scope_desc": hld_meta["scope_desc"],
        "atomic_diagram_mermaid": hld_meta["atomic_diagram_mermaid"],
        "tier_count": len(tiers),
        "total_attrs": total_attrs,
        "entities": entities,
        "unique_entities": unique_entities,
        "classifications": load_classifications(repo_root, source),
        "pendings": load_pendings(repo_root, source),
        "is_sample": sample,
        "uid_groups": uid_groups,
    }
