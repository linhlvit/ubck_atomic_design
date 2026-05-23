"""
Consolidate toàn bộ DataModel/Atomic/*.yaml thành 1 file duy nhất:
  DataModel/atomic_model.yaml

Schema mới:
  - ldm.source  → ldm.sources (mảng)
  - ldm.id      → bỏ suffix -{SOURCE}.{TABLE}
  - references.brd → mảng
  - attributes[].source_system/source_table/source_column/classification_context
              → attributes[].source_mappings (mảng, 1 entry/source)

Usage:
  python scripts/consolidate_yaml.py [--dry-run]
"""

import re
import sys
import yaml
import csv
import argparse
from pathlib import Path
from collections import defaultdict, OrderedDict

if sys.stdout.encoding != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ATOMIC_DIR  = Path(__file__).parent.parent / "DataModel" / "Atomic"
OUTPUT_FILE = Path(__file__).parent.parent / "DataModel" / "atomic_model.yaml"
REPORT_DIR  = Path(__file__).parent.parent / "docs" / "analysis"


# ── YAML dump helper (preserve unicode, block style) ─────────────────────────
class _Dumper(yaml.Dumper):
    pass

def _str_representer(dumper, data):
    if "\n" in data:
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)

_Dumper.add_representer(str, _str_representer)


def load_yaml(path: Path):
    try:
        with open(path, encoding="utf-8") as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"  [WARN] Cannot parse {path.name}: {e}")
        return None


def strip_source_suffix(id_str: str) -> str:
    """ATM-cstd_bnk-FMS.BANKMONI  →  ATM-cstd_bnk"""
    return re.sub(r"-[^-]+\.[^-]+$", "", id_str)


def normalize_brd(brd_val) -> list[str]:
    """references.brd có thể là str hoặc đã là list."""
    if brd_val is None:
        return []
    if isinstance(brd_val, list):
        return [str(b) for b in brd_val]
    return [str(brd_val)]


def build_source_mapping(attr: dict) -> dict:
    """Tạo 1 source_mapping entry từ các field flat của attribute."""
    return {
        "source_system":          attr.get("source_system"),
        "source_table":           attr.get("source_table"),
        "source_column":          attr.get("source_column"),
        "classification_context": attr.get("classification_context"),
    }


def warn_diff(field: str, canonical_val, other_val, file_a: str, file_b: str, warnings: list):
    if canonical_val != other_val:
        warnings.append(
            f"  DIFF {field}: '{canonical_val}' (canonical={file_a}) vs '{other_val}' ({file_b})"
        )


def merge_entity_group(files: list[Path]) -> tuple[dict, list[str]]:
    """
    Merge N files cùng physical_name thành 1 entity dict.
    Trả về (entity_dict, warnings).
    """
    warnings: list[str] = []
    docs = []
    for f in files:
        d = load_yaml(f)
        if d:
            docs.append((f, d))
    if not docs:
        return None, warnings

    # canonical = file đầu tiên (sort alphabet đã được áp dụng trước khi gọi)
    canon_path, canon = docs[0]

    # ── ldm ──────────────────────────────────────────────────────────────────
    ldm = dict(canon["ldm"])
    ldm["id"]      = strip_source_suffix(ldm["id"])
    ldm["sources"] = []
    ldm.pop("source", None)

    all_brds: list[str] = []
    for _, d in docs:
        src = d["ldm"].get("source", "")
        if src and src not in ldm["sources"]:
            ldm["sources"].append(src)
        brd = normalize_brd(d["ldm"].get("references", {}).get("brd"))
        for b in brd:
            if b not in all_brds:
                all_brds.append(b)
        # warn nếu các field quan trọng khác nhau
        for field in ("table_type", "etl_pattern", "bcv_concept", "bcv_core_object", "status"):
            warn_diff(field, canon["ldm"].get(field), d["ldm"].get(field),
                      canon_path.name, Path(d["ldm"]["id"]).name if "id" in d["ldm"] else "?",
                      warnings)

    refs = ldm.get("references", {}) or {}
    refs["brd"] = all_brds
    ldm["references"] = refs

    # ── attributes ───────────────────────────────────────────────────────────
    # Index canonical attrs by name
    canon_attrs = {a["name"]: dict(a) for a in (canon.get("attributes") or [])}

    # Với mỗi attr trong canonical, thu thập source_mapping từ tất cả files
    # (file nào có attr tên đó thì thêm 1 entry)
    attr_mappings: dict[str, list[dict]] = defaultdict(list)
    for f, d in docs:
        for attr in (d.get("attributes") or []):
            name = attr["name"]
            mapping = build_source_mapping(attr)
            attr_mappings[name].append(mapping)
            # warn diff business_meaning / comment nếu khác canonical
            if name in canon_attrs:
                warn_diff(f"attr[{name}].business_meaning",
                          canon_attrs[name].get("business_meaning"),
                          attr.get("business_meaning"),
                          canon_path.name, f.name, warnings)
                warn_diff(f"attr[{name}].comment",
                          canon_attrs[name].get("comment"),
                          attr.get("comment"),
                          canon_path.name, f.name, warnings)

    # Build final attribute list từ canonical, thay thế source fields bằng source_mappings
    final_attrs = []
    for attr in (canon.get("attributes") or []):
        a = {k: v for k, v in attr.items()
             if k not in ("source_system", "source_table", "source_column", "classification_context")}
        a["source_mappings"] = attr_mappings.get(attr["name"], [build_source_mapping(attr)])
        final_attrs.append(a)

    return {"ldm": ldm, "attributes": final_attrs}, warnings


def consolidate(dry_run: bool):
    yaml_files = sorted(ATOMIC_DIR.rglob("*.yaml"))
    print(f"Tìm thấy {len(yaml_files)} file YAML")
    print(f"Dry-run: {dry_run}\n")

    # Group theo physical_name
    groups: dict[str, list[Path]] = defaultdict(list)
    for f in yaml_files:
        d = load_yaml(f)
        if not d:
            continue
        pname = d.get("ldm", {}).get("physical_name", "")
        if pname:
            groups[pname].append(f)

    print(f"Tìm thấy {len(groups)} logical entities (unique physical_name)\n")

    # Merge từng group
    entities = []
    report_rows = []
    all_warnings = []

    # Sort theo bcv_core_object rồi physical_name
    def sort_key(item):
        pname, files = item
        d = load_yaml(files[0])
        bcv = (d or {}).get("ldm", {}).get("bcv_core_object", "")
        return (bcv, pname)

    for pname, files in sorted(groups.items(), key=sort_key):
        entity, warnings = merge_entity_group(sorted(files))
        if not entity:
            continue

        entities.append(entity)
        sources = entity["ldm"].get("sources", [])
        report_rows.append({
            "physical_name":  pname,
            "logical_name":   entity["ldm"].get("logical_name", ""),
            "bcv_core_object": entity["ldm"].get("bcv_core_object", ""),
            "files_merged":   len(files),
            "sources":        ", ".join(sources),
            "warnings":       len(warnings),
        })
        if warnings:
            all_warnings.append(f"\n[{pname}]")
            all_warnings.extend(warnings)

    print(f"Tổng entities: {len(entities)}")
    print(f"Warnings: {len(all_warnings)} dòng\n")

    if all_warnings:
        print("=== WARNINGS ===")
        for w in all_warnings:
            print(w)
        print()

    # ── Xuất report ──────────────────────────────────────────────────────────
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    suffix = "_dryrun" if dry_run else ""
    report_path = REPORT_DIR / f"consolidate_report{suffix}.csv"
    with open(report_path, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=["physical_name","logical_name","bcv_core_object",
                                          "files_merged","sources","warnings"])
        w.writeheader()
        w.writerows(report_rows)
    print(f"Report → {report_path}")

    if dry_run:
        print("\nDry-run: không ghi file atomic_model.yaml")
        return

    # ── Ghi output ───────────────────────────────────────────────────────────
    output = {
        "schema_type":    "atomic_model",
        "schema_version": "1.0",
        "entities":       entities,
    }
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        yaml.dump(output, f, Dumper=_Dumper,
                  allow_unicode=True, sort_keys=False, default_flow_style=False)
    print(f"\nĐã ghi → {OUTPUT_FILE}")
    print(f"File size: {OUTPUT_FILE.stat().st_size / 1024:.1f} KB")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    consolidate(args.dry_run)


if __name__ == "__main__":
    main()
