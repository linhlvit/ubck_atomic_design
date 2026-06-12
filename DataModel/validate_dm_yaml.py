"""
validate_dm_yaml.py
-------------------
Phase 4b: Validate mọi dm_atm_*.yaml trong DataModel/Atomic/ theo schemas/dm.schema.json.

Usage:
  python DataModel/validate_dm_yaml.py [--source NHNCK] [--fail-fast]

  --source:    Chỉ validate files của source này
  --fail-fast: Dừng ngay khi gặp lỗi đầu tiên

Exit code: 0 nếu tất cả pass, 1 nếu có bất kỳ lỗi.
"""

import argparse
import json
import re
import sys
from pathlib import Path

import yaml
import jsonschema

ROOT       = Path(__file__).resolve().parent.parent
SCHEMA_PATH = ROOT / "schemas" / "dm.schema.json"
ATOMIC_DIR  = ROOT / "DataModel" / "Atomic"


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--source", help="Only validate files for this source (e.g. NHNCK)")
    p.add_argument("--fail-fast", action="store_true", help="Stop on first error")
    return p.parse_args()


def load_schema(path: Path) -> dict:
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def collect_yaml_files(source_filter: str | None) -> list[Path]:
    files = []
    for subdir in sorted(ATOMIC_DIR.iterdir()):
        if not subdir.is_dir():
            continue
        for yf in sorted(subdir.glob("dm_atm_*.yaml")):
            if source_filter:
                # filename pattern: dm_atm_{table}-{SOURCE}.{TABLE}.yaml
                m = re.search(r"-([A-Za-z][A-Za-z0-9]+)\.", yf.name)
                if not m or m.group(1) != source_filter:
                    continue
            files.append(yf)
    return files


def validate_file(yf: Path, schema: dict, validator_cls) -> list[str]:
    """Return list of error messages for this file (empty = valid)."""
    with open(yf, encoding="utf-8") as f:
        try:
            doc = yaml.safe_load(f)
        except yaml.YAMLError as e:
            return [f"YAML parse error: {e}"]

    errors = []
    for err in sorted(validator_cls(schema).iter_errors(doc), key=lambda e: list(e.absolute_path)):
        path = ".".join(str(p) for p in err.absolute_path) or "(root)"
        errors.append(f"  [{path}] {err.message}")
    return errors


def main():
    args = parse_args()

    if not SCHEMA_PATH.exists():
        print(f"ERROR: Schema not found: {SCHEMA_PATH}", file=sys.stderr)
        sys.exit(1)

    schema = load_schema(SCHEMA_PATH)
    validator_cls = jsonschema.Draft7Validator

    files = collect_yaml_files(args.source)
    if not files:
        print(f"No files found" + (f" for source={args.source}" if args.source else "") + ".")
        sys.exit(0)

    print(f"Schema : {SCHEMA_PATH.relative_to(ROOT)}")
    print(f"Files  : {len(files)}" + (f" (source={args.source})" if args.source else ""))
    print()

    passed = failed = 0

    for yf in files:
        rel = yf.relative_to(ROOT)
        errors = validate_file(yf, schema, validator_cls)
        if errors:
            failed += 1
            print(f"FAIL  {rel}")
            for e in errors:
                print(e)
            print()
            if args.fail_fast:
                print("(--fail-fast: stopping)")
                break
        else:
            passed += 1
            print(f"OK    {rel}")

    print()
    print(f"{'=' * 60}")
    print(f"Passed: {passed}  Failed: {failed}  Total: {passed + failed}")

    sys.exit(0 if failed == 0 else 1)


if __name__ == "__main__":
    main()
