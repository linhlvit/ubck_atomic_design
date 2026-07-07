"""
propose_domain_prefix.py
=========================
Script migration MỘT LẦN: đề xuất `domain_prefix` cho từng entity đã có trong
atomic_entities.yaml (entity nào chưa có cột này), để Data Modeler review trước khi
ingest ngược vào atomic_entities.yaml (xem mục 5 kế hoạch migration physical name).

Thuật toán cụm (per source_system):
  - Tách atomic_entity thành list từ (lowercase).
  - Dựng trie theo từ; với mỗi entity, đi sâu nhất có thể dọc theo path của chính nó
    miễn là node đó còn được >= 2 entity khác trong CÙNG source_system đi qua.
    → domain_prefix = phần path đã đi được (rỗng nếu ngay từ đầu không ai chia sẻ).
  - 3 shared entity Involved Party (Postal/Electronic Address, Alt Identification) gán
    cứng domain_prefix = "Involved Party" (không chạy heuristic).
  - Entity xuất hiện ở nhiều source_system mà mỗi partition đề xuất domain_prefix khác
    nhau → gắn cờ CONFLICT (liệt kê cả 2 đề xuất, Data Modeler tự chọn).

Output: DataModel/working/Atomic/lld/domain_prefix_review.csv (KHÔNG tự ghi vào
atomic_entities.yaml — chỉ để Data Modeler review/sửa tay 1 lượt).

Cách dùng:
  python DataModel/working/Atomic/lld/scripts/propose_domain_prefix.py
"""

import sys
import csv
import importlib.util as _ilu
from pathlib import Path

import yaml

SCRIPT_DIR   = Path(__file__).resolve().parent
LLD_DIR      = SCRIPT_DIR.parent
PROJECT_ROOT = LLD_DIR.parent.parent.parent.parent

ATOMIC_ENTITIES = LLD_DIR.parent / "hld" / "atomic_entities.yaml"
YAML_MANIFEST   = LLD_DIR / "manifest.yaml"
OUT_CSV         = LLD_DIR / "domain_prefix_review.csv"

# Cùng danh sách shared entity với aggregate_atomic.py — domain_prefix cố định.
SHARED_ENTITIES = {
    "Involved Party Postal Address",
    "Involved Party Electronic Address",
    "Involved Party Alt Identification",
}
SHARED_DOMAIN_PREFIX = "Involved Party"

# Import transform_physical_names.py (cùng thư mục) để dùng lại transform_table_name/full_words.
_spec = _ilu.spec_from_file_location("transform_physical_names", SCRIPT_DIR / "transform_physical_names.py")
tfn = _ilu.module_from_spec(_spec)
_spec.loader.exec_module(tfn)


def load_entities() -> list[dict]:
    data = yaml.safe_load(ATOMIC_ENTITIES.read_text(encoding="utf-8")) or {}
    return data.get("entities", [])


def load_manifest_lld_file(atomic_entity: str) -> str | None:
    """Trả về lld_file đầu tiên map với atomic_entity (dùng để đọc old entity_physical_name)."""
    if not YAML_MANIFEST.exists():
        return None
    data = yaml.safe_load(YAML_MANIFEST.read_text(encoding="utf-8")) or {}
    for e in data.get("entries", []):
        if e.get("atomic_entity") == atomic_entity and e.get("lld_file"):
            return e["lld_file"]
    return None


def read_old_entity_physical_name(lld_file: str) -> str:
    for candidate in (LLD_DIR / lld_file, LLD_DIR / Path(lld_file).name):
        if candidate.exists():
            data = yaml.safe_load(candidate.read_text(encoding="utf-8")) or {}
            return (data.get("metadata", {}) or {}).get("entity_physical_name", "") or ""
    return ""


def source_systems_of(source_table: str) -> list[str]:
    systems = []
    for part in (source_table or "").split(","):
        part = part.strip()
        if "." in part:
            systems.append(part.split(".", 1)[0])
    # unique, preserve order
    seen = set()
    result = []
    for s in systems:
        if s not in seen:
            seen.add(s)
            result.append(s)
    return result


def build_trie(entity_names: list[str]) -> dict:
    """Trie đơn giản dạng nested dict, mỗi node có '_count'."""
    root: dict = {"_count": 0}
    for name in entity_names:
        words = name.strip().lower().split()
        node = root
        node["_count"] += 1
        for w in words:
            node = node.setdefault(w, {"_count": 0})
            node["_count"] += 1
    return root


MIN_PREFIX_WORDS = 2  # 1 từ đơn (VD "Securities") quá chung chung, dễ overmatch — bắt buộc >= 2 từ


def longest_shared_prefix(name: str, trie: dict) -> str:
    """Đi sâu nhất dọc theo path của `name` trong trie miễn là node đó có count >= 2.
    Chỉ chấp nhận nếu depth >= MIN_PREFIX_WORDS — 1 từ chung chung không đủ để coi là
    Domain Prefix thật (tránh sinh initials 1 ký tự vô nghĩa như "s_order")."""
    words = name.strip().lower().split()
    node = trie
    depth = 0
    for w in words:
        child = node.get(w)
        if not child or child["_count"] < 2:
            break
        node = child
        depth += 1
    if depth < MIN_PREFIX_WORDS:
        return ""
    # Lấy lại đúng case gốc (Title Case) từ tên entity gốc, không phải bản lowercase.
    original_words = name.strip().split()
    return " ".join(original_words[:depth])


def main() -> None:
    entities = load_entities()
    print(f"Doc {len(entities)} entities tu atomic_entities.yaml", file=sys.stderr)

    # Partition theo source_system (1 entity co the thuoc nhieu partition)
    partitions: dict[str, list[str]] = {}
    entity_systems: dict[str, list[str]] = {}
    for e in entities:
        name = e["atomic_entity"]
        systems = source_systems_of(e.get("source_table", ""))
        entity_systems[name] = systems
        for s in systems:
            partitions.setdefault(s, []).append(name)

    tries = {s: build_trie(names) for s, names in partitions.items()}

    rows = []
    for e in entities:
        name = e["atomic_entity"]
        systems = entity_systems.get(name, [])

        if name in SHARED_ENTITIES:
            proposals = [SHARED_DOMAIN_PREFIX]
        else:
            proposals = []
            for s in systems:
                dp = longest_shared_prefix(name, tries[s])
                if dp not in proposals:
                    proposals.append(dp)

        flag = "OK"
        if not proposals:
            proposals = [""]
        if len(proposals) > 1:
            flag = "CONFLICT"
            domain_prefix = proposals[0]  # placeholder — Data Modeler tu chon
        else:
            domain_prefix = proposals[0]

        if not domain_prefix:
            cluster_size = 1
            if flag == "OK":
                flag = "NO_CLUSTER"
        else:
            cluster_size = sum(
                1 for other in entities
                if other["atomic_entity"] != name
                and other["atomic_entity"].lower().startswith(domain_prefix.lower())
                and set(entity_systems.get(other["atomic_entity"], [])) & set(systems)
            ) + 1

        try:
            entity_physical_name = tfn.transform_table_name(domain_prefix, name)
            bcv_term = name[len(domain_prefix):].strip() if domain_prefix else name
            if domain_prefix and not bcv_term:
                flag = "HEAD_EMPTY_BCV" if flag == "OK" else flag
        except ValueError:
            entity_physical_name = ""
            bcv_term = name
            flag = "ERROR"

        lld_file = load_manifest_lld_file(name)
        old_epn = read_old_entity_physical_name(lld_file) if lld_file else ""

        rows.append({
            "atomic_entity": name,
            "source_system(s)": ", ".join(systems),
            "cluster_size": cluster_size,
            "proposed_domain_prefix": domain_prefix,
            "proposed_bcv_term": bcv_term,
            "proposed_entity_physical_name": entity_physical_name,
            "old_entity_physical_name": old_epn,
            "flag": flag,
            "other_proposals": "; ".join(p for p in proposals if p != domain_prefix),
        })

    rows.sort(key=lambda r: (r["proposed_domain_prefix"] or "￿", r["atomic_entity"]))

    fieldnames = list(rows[0].keys()) if rows else []
    with open(OUT_CSV, "w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    n_conflict = sum(1 for r in rows if r["flag"] == "CONFLICT")
    n_nocluster = sum(1 for r in rows if r["flag"] == "NO_CLUSTER")
    n_head = sum(1 for r in rows if r["flag"] == "HEAD_EMPTY_BCV")
    n_clusters = len({r["proposed_domain_prefix"] for r in rows if r["proposed_domain_prefix"]})
    print(f"Ghi: {OUT_CSV}", file=sys.stderr)
    print(f"  {len(rows)} entities, {n_clusters} cum domain_prefix", file=sys.stderr)
    print(f"  OK={len(rows)-n_conflict-n_nocluster-n_head} NO_CLUSTER={n_nocluster} HEAD_EMPTY_BCV={n_head} CONFLICT={n_conflict}", file=sys.stderr)


if __name__ == "__main__":
    main()
