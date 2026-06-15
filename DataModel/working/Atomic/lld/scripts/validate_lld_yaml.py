"""
validate_lld_yaml.py
====================
Validate các file lld_*.yaml (schema_type: lld_source_table) và
entity_*.yaml (schema_type: entity_consolidation) theo JSON Schema.

Cách dùng:
  python DataModel/working/Atomic/lld/scripts/validate_lld_yaml.py --source NHNCK
  python DataModel/working/Atomic/lld/scripts/validate_lld_yaml.py              # validate toàn bộ
  python DataModel/working/Atomic/lld/scripts/validate_lld_yaml.py --entities   # chỉ validate entity_*.yaml
  python DataModel/working/Atomic/lld/scripts/validate_lld_yaml.py --file DataModel/working/Atomic/lld/NHNCK/lld_NHNCK_VIOLATIONS.yaml
"""

import sys
import io
import json
import argparse
from pathlib import Path

# Fix encoding trên Windows terminal
if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf-8-sig"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

try:
    import yaml
except ImportError:
    print("[ERROR] PyYAML không có. Cài: pip install pyyaml")
    sys.exit(1)

try:
    import jsonschema
    from jsonschema import validate as jvalidate, ValidationError
except ImportError:
    print("[ERROR] jsonschema không có. Cài: pip install jsonschema")
    sys.exit(1)

SCRIPT_DIR    = Path(__file__).parent
LLD_DIR       = SCRIPT_DIR.parent
ROOT          = LLD_DIR.parent.parent.parent.parent
SCHEMAS_DIR   = ROOT / "schemas"
LLD_SCHEMA_FILE      = SCHEMAS_DIR / "lld_source_table.schema.json"
ENTITY_SCHEMA_FILE   = SCHEMAS_DIR / "entity_consolidation.schema.json"


# ---------------------------------------------------------------------------
# Loaders
# ---------------------------------------------------------------------------

def load_schema(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def load_yaml_file(path):
    with open(path, encoding="utf-8") as f:
        return yaml.safe_load(f)


# ---------------------------------------------------------------------------
# Validation checks (ngoài JSON Schema)
# ---------------------------------------------------------------------------

SHARED_ENTITIES = {
    "Involved Party Postal Address",
    "Involved Party Electronic Address",
    "Involved Party Alternative Identification",
}


def extra_checks_lld(data, filepath):
    """Kiểm tra thêm ngoài JSON Schema."""
    issues = []
    meta = data.get("metadata", {})
    attrs = data.get("attributes", [])
    entity = meta.get("atomic_entity", "")
    is_shared = entity in SHARED_ENTITIES

    # E1: Source System Code phải có trong attributes
    src_codes = [a for a in attrs if a.get("attribute_name") == "Source System Code"]
    if not src_codes:
        issues.append("E1: Thiếu attribute 'Source System Code'")

    # E2: Phải có ít nhất 1 PK (ngoại trừ shared entities dùng composite key không đánh dấu PK)
    pks = [a for a in attrs if a.get("is_primary_key") is True]
    if not pks and not is_shared:
        issues.append("E2: Không có attribute nào is_primary_key=true")

    # E3: PK không được nullable
    for a in pks:
        if a.get("nullable") is True:
            issues.append(f"E3: PK '{a['attribute_name']}' có nullable=true (mâu thuẫn)")

    # E4: Classification Value có context SCHEME=VALUE phải có etl_derived_value
    for a in attrs:
        if a.get("data_domain") != "Classification Value":
            continue
        ctx = a.get("classification_context") or ""
        etl = a.get("etl_derived_value") or ""
        if "=" in ctx and not ctx.endswith("=(source)") and not etl:
            issues.append(
                f"E4: '{a['attribute_name']}' — ctx='{ctx}' nhưng etl_derived_value trống"
            )

    # E5: Source System Code phải có classification_context = SOURCE_SYSTEM=...
    for a in src_codes:
        ctx = a.get("classification_context") or ""
        if not ctx.startswith("SOURCE_SYSTEM="):
            issues.append(
                f"E5: Source System Code — classification_context='{ctx}' (phải là SOURCE_SYSTEM=...)"
            )
        etl = a.get("etl_derived_value") or ""
        if not etl:
            issues.append("E5: Source System Code — etl_derived_value trống")

    # E6: source_columns dùng đúng 3 phần SOURCE.table.column
    for a in attrs:
        for sc in (a.get("source_columns") or []):
            if sc and sc.count(".") < 2:
                issues.append(
                    f"E6: '{a['attribute_name']}' — source_column '{sc}' không đủ 3 phần"
                )

    return issues


def extra_checks_entity(data, filepath):
    """Kiểm tra cơ bản cho entity_consolidation."""
    issues = []
    attrs = data.get("attributes", [])
    entity_name = data.get("entity", {}).get("entity_name", "")
    is_shared = entity_name in SHARED_ENTITIES

    # Phải có PK (ngoại trừ shared entities dùng composite key)
    pks = [a for a in attrs if a.get("is_primary_key") is True]
    if not pks and not is_shared:
        issues.append("E1: Không có attribute nào is_primary_key=true")

    # source_mappings phải có key cho mọi source trong entity.sources
    sources = data.get("sources", [])
    expected_keys = {f"{s['source_system']}.{s['source_table']}" for s in sources}
    for a in attrs:
        sm = a.get("source_mappings") or {}
        missing = expected_keys - set(sm.keys())
        if missing:
            issues.append(
                f"E2: '{a['attribute_name']}' — source_mappings thiếu: {', '.join(sorted(missing))}"
            )

    return issues


# ---------------------------------------------------------------------------
# Validate one file
# ---------------------------------------------------------------------------

def validate_file(path, lld_schema, entity_schema, verbose=False):
    """Returns (ok: bool, errors: list[str])"""
    try:
        data = load_yaml_file(path)
    except yaml.YAMLError as e:
        return False, [f"YAML parse error: {e}"]

    if not isinstance(data, dict):
        return False, ["File không phải YAML dict"]

    schema_type = data.get("schema_type", "")

    if schema_type == "lld_source_table":
        schema = lld_schema
        extra_fn = extra_checks_lld
    elif schema_type == "entity_consolidation":
        schema = entity_schema
        extra_fn = extra_checks_entity
    else:
        return False, [f"schema_type không nhận dạng được: '{schema_type}'"]

    errors = []

    # JSON Schema validation
    try:
        jvalidate(instance=data, schema=schema)
    except ValidationError as e:
        # Trim long path info
        path_str = " > ".join(str(p) for p in e.absolute_path) if e.absolute_path else "root"
        errors.append(f"Schema: [{path_str}] {e.message}")

    # Extra checks
    extras = extra_fn(data, path)
    errors.extend(extras)

    return len(errors) == 0, errors


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Validate lld_*.yaml và entity_*.yaml theo JSON Schema"
    )
    parser.add_argument("--source",   help="Chỉ validate source này, VD: NHNCK")
    parser.add_argument("--entities", action="store_true",
                        help="Chỉ validate entity_*.yaml trong entities/")
    parser.add_argument("--file",     help="Validate 1 file cụ thể (đường dẫn từ project root)")
    parser.add_argument("--verbose",  action="store_true", help="In chi tiết cả file OK")
    args = parser.parse_args()

    if not LLD_SCHEMA_FILE.exists():
        print(f"[ERROR] Không tìm thấy {LLD_SCHEMA_FILE.relative_to(ROOT)}")
        sys.exit(1)
    if not ENTITY_SCHEMA_FILE.exists():
        print(f"[ERROR] Không tìm thấy {ENTITY_SCHEMA_FILE.relative_to(ROOT)}")
        sys.exit(1)

    lld_schema    = load_schema(LLD_SCHEMA_FILE)
    entity_schema = load_schema(ENTITY_SCHEMA_FILE)

    # Build file list
    files = []
    if args.file:
        p = ROOT / args.file if not Path(args.file).is_absolute() else Path(args.file)
        files = [p]
    elif args.entities:
        entities_dir = LLD_DIR / "entities"
        if entities_dir.exists():
            files = sorted(entities_dir.glob("entity_*.yaml"))
    else:
        if args.source:
            src_dir = LLD_DIR / args.source
            if not src_dir.exists():
                print(f"[ERROR] Không tìm thấy thư mục {src_dir.relative_to(ROOT)}")
                sys.exit(1)
            files = sorted(src_dir.glob("lld_*.yaml"))
        else:
            files = sorted(LLD_DIR.rglob("lld_*.yaml"))
            entities_dir = LLD_DIR / "entities"
            if entities_dir.exists():
                files += sorted(entities_dir.glob("entity_*.yaml"))

    if not files:
        print("Không tìm thấy file nào để validate.")
        return

    print(f"\nValidate {len(files)} files...\n")
    ok_count = fail_count = 0

    for filepath in files:
        ok, errors = validate_file(filepath, lld_schema, entity_schema, args.verbose)
        rel = filepath.relative_to(ROOT)
        if ok:
            ok_count += 1
            if args.verbose:
                print(f"  ✓  {rel}")
        else:
            fail_count += 1
            print(f"  ✗  {rel}")
            for e in errors:
                print(f"       {e}")

    print(f"\n{'=' * 60}")
    print(f"Kết quả: Passed={ok_count}  Failed={fail_count}  Total={ok_count + fail_count}")
    if fail_count > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
