# -*- coding: utf-8 -*-
"""
build_model_yaml.py — RFC Đ3 (phần 2): đồng bộ khối `columns` của `Datamart/datamart_model.yaml`
theo master registry, giữ nguyên toàn bộ metadata cấp entity và comment header.

Vì sao không dump lại cả file: `yaml.dump()` xoá sạch 28 dòng comment quy tắc ghi registry và
reformat 100% file — một lần thêm 6 entity từng sinh diff 27.885 dòng.
Script này chỉ thay phần `columns:` của từng entity, giữ nguyên `logical_name`, `description`,
`modules_using`, `reuse_status`... do người thiết kế curate.

Entity `module: SHARED` được bỏ qua mặc định (registry entity-level là nguồn sự thật cho chúng),
trừ khi truyền `--include-shared`.

Usage:
    python scripts/build_model_yaml.py
    python scripts/build_model_yaml.py --check
"""
from __future__ import annotations

import argparse
import collections
import sys
from pathlib import Path

_script_dir = Path(__file__).resolve().parent
if str(_script_dir) not in sys.path:
    sys.path.insert(0, str(_script_dir))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

try:
    import yaml
except ImportError:
    print("ERROR: cần PyYAML — pip install pyyaml")
    sys.exit(2)

from datamart_common import find_project_root  # noqa: E402
from datamart_common.csv_io import read_design_csv  # noqa: E402

MODEL_REL = "Datamart/datamart_model.yaml"
MASTER_REL = "Datamart/lld/datamart_attributes.csv"

ENT_ORDER = ["id", "logical_name", "datamart_table", "table_type", "module", "status",
             "reuse_status", "description", "source_atomic", "modules_using", "columns"]
COL_ORDER = ["logical_name", "physical_name", "data_domain", "data_type", "nullable",
             "key", "description", "source_atomic_table", "source_atomic_column"]


def q(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if v is None:
        return "null"
    if isinstance(v, (int, float)):
        return str(v)
    return '"%s"' % str(v).replace("\\", "\\\\").replace('"', '\\"')


def dump_entity(e) -> str:
    out, first = [], True
    for f in ENT_ORDER:
        if f not in e:
            continue
        pre = "  - " if first else "    "
        first = False
        v = e[f]
        if f in ("source_atomic", "modules_using"):
            out.append("%s%s:" % (pre, f))
            for x in (v or []):
                out.append("      - %s" % q(x))
        elif f == "columns":
            out.append("%s%s:" % (pre, f))
            for c in v or []:
                cf = True
                for k in COL_ORDER:
                    if k not in c:
                        continue
                    cpre = "      - " if cf else "        "
                    cf = False
                    out.append("%s%s: %s" % (cpre, k, q(c[k])))
        else:
            out.append("%s%s: %s" % (pre, f, q(v)))
    return "\n".join(out)


def build_columns(master_rows, ix, table):
    """Cột của 1 bảng, dedupe theo physical_name (bảng multi-source lặp cột)."""
    out, seen = [], set()
    for r in master_rows:
        if r[ix["datamart_table"]].strip() != table:
            continue
        phys = r[ix["datamart_column"]].strip()
        if phys in seen:
            continue
        seen.add(phys)
        atbl = r[ix["atomic_table"]].strip()
        acol = r[ix["atomic_column"]].strip()
        out.append({
            "logical_name": r[ix["datamart_attribute"]],
            "physical_name": phys,
            "data_domain": r[ix["data_domain"]],
            "data_type": r[ix["data_type"]],
            "nullable": r[ix["nullable"]].strip().lower() == "true",
            "key": r[ix["key"]],
            "description": r[ix["description"]],
            "source_atomic_table": atbl or None,
            "source_atomic_column": ("%s.%s" % (atbl, acol)) if atbl and acol else None,
        })
    return out


def main() -> None:
    ap = argparse.ArgumentParser(description="RFC Đ3 — đồng bộ columns của datamart_model.yaml")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--include-shared", action="store_true",
                    help="Đồng bộ cả entity module=SHARED (mặc định bỏ qua)")
    ap.add_argument("--root", default=None)
    args = ap.parse_args()

    root = find_project_root(args.root) if args.root else find_project_root()
    model_path = root / MODEL_REL
    master = read_design_csv(root / MASTER_REL, strict=True)
    ix = master.ix

    raw = model_path.read_text(encoding="utf-8")
    model = yaml.safe_load(raw)

    changed = []
    for e in model["entities"]:
        if e.get("module") == "SHARED" and not args.include_shared:
            continue
        tbl = e["datamart_table"]
        want = build_columns(master.rows, ix, tbl)
        if not want:
            continue
        have = e.get("columns") or []
        if have != want:
            changed.append((tbl, len(have), len(want)))
        e["columns"] = want

    if args.check:
        if not changed:
            print(f"✅ datamart_model.yaml khớp master registry ({len(model['entities'])} entity).")
            sys.exit(0)
        print(f"❌ LỆCH ở {len(changed)} entity:")
        for t, a, b in changed[:25]:
            print(f"   {t:55} {a} -> {b} cột")
        print("   Chạy: python scripts/build_model_yaml.py")
        sys.exit(1)

    hdr = raw[:raw.index("\nentities:") + len("\nentities:")]
    body = hdr + "\n"
    for e in model["entities"]:
        body += "\n" + dump_entity(e) + "\n"
    model_path.write_text(body, encoding="utf-8", newline="\n")

    chk = yaml.safe_load(model_path.read_text(encoding="utf-8"))
    ncmt = sum(1 for l in model_path.read_text(encoding="utf-8").split("\n") if l.startswith("#"))
    print(f"✅ Đã đồng bộ {MODEL_REL}: {len(chk['entities'])} entity, "
          f"{len(changed)} entity đổi columns, giữ {ncmt} dòng comment header.")


if __name__ == "__main__":
    main()
