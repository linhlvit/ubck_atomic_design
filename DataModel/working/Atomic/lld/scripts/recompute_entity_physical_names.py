"""
recompute_entity_physical_names.py
====================================
Audit + migrate `entity_physical_name` trong atomic_entities.yaml khi thuật toán
abbreviate_domain_prefix() hoặc system/rules/rule_domain_prefix_abbreviations.csv thay đổi
(xem `.claude/skills/atomic-lld-design/SKILL.md` mục "QUY TẮC ĐẶT physical_name").

Giữ nguyên `domain_prefix` đã lưu (quyết định nghiệp vụ, LOCKED) — chỉ recompute lại
`entity_physical_name` từ domain_prefix hiện có bằng transform_table_name() mới nhất,
so sánh với giá trị cũ. KHÔNG tự sinh domain_prefix mới (khác propose_domain_prefix.py).

Cách dùng:
  python DataModel/working/Atomic/lld/scripts/recompute_entity_physical_names.py
      # in bang diff (atomic_entity | domain_prefix | old | new), KHONG ghi file
  python DataModel/working/Atomic/lld/scripts/recompute_entity_physical_names.py --apply
      # ghi de entity_physical_name cho cac dong khac nhau vao atomic_entities.yaml
"""

import argparse
import importlib.util as _ilu
import sys
from pathlib import Path

import yaml

SCRIPT_DIR = Path(__file__).resolve().parent

# Import transform_physical_names.py (cùng thư mục) để dùng lại transform_table_name/DQDumper.
_spec = _ilu.spec_from_file_location("transform_physical_names", SCRIPT_DIR / "transform_physical_names.py")
tfn = _ilu.module_from_spec(_spec)
_spec.loader.exec_module(tfn)

ATOMIC_ENTITIES = tfn.ATOMIC_ENTITIES


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Audit/migrate entity_physical_name theo abbreviate_domain_prefix() moi nhat"
    )
    parser.add_argument("--apply", action="store_true", help="Ghi de atomic_entities.yaml (mac dinh chi in diff)")
    args = parser.parse_args()

    data = yaml.safe_load(ATOMIC_ENTITIES.read_text(encoding="utf-8")) or {}
    entities = data.get("entities", [])

    diffs = []
    for e in entities:
        name = e.get("atomic_entity", "") or ""
        dp = e.get("domain_prefix", "") or ""
        old_epn = e.get("entity_physical_name", "") or ""
        if not old_epn:
            continue
        try:
            new_epn = tfn.transform_table_name(dp, name)
        except ValueError as ex:
            print(f"  [SKIP] '{name}': {ex}", file=sys.stderr)
            continue
        if new_epn != old_epn:
            diffs.append((name, dp, old_epn, new_epn))
            e["entity_physical_name"] = new_epn  # áp dụng in-memory; ghi file chỉ khi --apply

    print(f"{len(diffs)} entity co entity_physical_name thay doi:\n", file=sys.stderr)
    for name, dp, old, new in diffs:
        print(f"  [{dp}] {name}", file=sys.stderr)
        print(f"    {old}  ->  {new}", file=sys.stderr)

    if not diffs:
        print("Khong co thay doi.", file=sys.stderr)
        return

    if args.apply:
        with open(ATOMIC_ENTITIES, "w", encoding="utf-8") as f:
            yaml.dump(data, f, Dumper=tfn.DQDumper, allow_unicode=True, sort_keys=False, default_flow_style=False)
        print(f"\nDa ghi {len(diffs)} thay doi vao {ATOMIC_ENTITIES}", file=sys.stderr)
    else:
        print("\n[DRY-RUN] Chua ghi file. Chay lai voi --apply de ap dung.", file=sys.stderr)


if __name__ == "__main__":
    main()
