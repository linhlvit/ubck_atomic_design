"""
Chuyển logical name → physical name trong comment FK target / Lookup pair
của các entity có source FMS.

Trước:  FK target: Discretionary Investment Investor.Discretionary Investment Investor Id.
Sau:    FK target: dscr_ivsm_ivsr.dscr_ivsm_ivsr_id.

Usage:
  # Cập nhật atomic_model.yaml (consolidated)
  python scripts/physicalize_fk_comments.py [--dry-run]

  # Cập nhật các file YAML gốc trong DataModel/Atomic/ (source FMS)
  python scripts/physicalize_fk_comments.py --target yaml-files [--dry-run]
"""

import re
import sys
import yaml
import csv
import argparse
from pathlib import Path

if sys.stdout.encoding != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

MODEL_FILE  = Path(__file__).parent.parent / "DataModel" / "atomic_model.yaml"
ATOMIC_DIR  = Path(__file__).parent.parent / "DataModel" / "Atomic"
REPORT_DIR  = Path(__file__).parent.parent / "docs" / "analysis"
SOURCE_FILTER = "FMS"

# Regex khớp dòng comment trong raw YAML
# Double-quoted: cho phép single-quote bên trong; dừng ở double-quote đóng
# Single-quoted: cho phép double-quote bên trong; dừng ở single-quote đóng
RE_COMMENT_DOUBLE = re.compile(
    r'([ \t]+comment:\s*")(FK target:|Lookup pair:)(.*?)(")'
)
RE_COMMENT_SINGLE = re.compile(
    r"([ \t]+comment:\s*')(FK target:|Lookup pair:)(.*?)(')"
)


# ── YAML dump helper ──────────────────────────────────────────────────────────
class _Dumper(yaml.Dumper):
    pass

def _str_representer(dumper, data):
    if "\n" in data:
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)

_Dumper.add_representer(str, _str_representer)


def build_lookup(entities: list[dict]) -> tuple[dict[str, str], dict[tuple, str]]:
    """
    Trả về:
      entity_lookup: logical_name → physical_name (entity)
      attr_lookup:   (entity_logical_name, attr_logical_name) → attr_physical_name
    """
    entity_lookup: dict[str, str] = {}
    attr_lookup: dict[tuple, str] = {}

    for e in entities:
        ldm = e.get("ldm", {})
        elog = ldm.get("logical_name", "").strip()
        ephys = ldm.get("physical_name", "").strip()
        if not elog or not ephys:
            continue
        entity_lookup[elog] = ephys

        for attr in (e.get("attributes") or []):
            alog = attr.get("name", "").strip()
            aphys = attr.get("physical_name", "").strip()
            if alog and aphys:
                attr_lookup[(elog, alog)] = aphys

    return entity_lookup, attr_lookup


def transform_comment(
    comment: str,
    entity_lookup: dict[str, str],
    attr_lookup: dict[tuple, str],
    self_attr_lookup: dict[str, str] | None = None,
) -> tuple[str, bool]:
    """
    Đổi logical → physical trong comment (nếu match).
    Trả về (new_comment, changed).

    Xử lý 2 pattern:
      FK target: {EntityLog}.{AttrLog}[. any text. Classification:...]
      Lookup pair: {EntityLog}.{AttrLog}. Pair with {IdAttrLog}[. any text. Classification:...]

    self_attr_lookup: physical_name của attr thuộc entity hiện tại (dùng khi Pair with trỏ
    về attr của entity hiện tại, ví dụ shared entity dùng "Involved Party Id").
    """
    # ── FK target ─────────────────────────────────────────────────────────────
    # Cho phép bất kỳ text nào giữa AttrLog và Classification (hoặc cuối chuỗi)
    m = re.match(
        r'^(FK target:\s+)(.+?)\.(.+?)\.(.*?)$',
        comment
    )
    if m:
        prefix = m.group(1)
        elog   = m.group(2).strip()
        alog   = m.group(3).strip()
        rest   = "." + m.group(4)   # giữ lại toàn bộ phần sau (kể cả Classification)
        ephys  = entity_lookup.get(elog)
        aphys  = attr_lookup.get((elog, alog))
        if ephys and aphys:
            return f"{prefix}{ephys}.{aphys}{rest}", True
        return comment, False

    # ── Lookup pair ───────────────────────────────────────────────────────────
    m = re.match(
        r'^(Lookup pair:\s+)(.+?)\.(.+?)\.\s*(Pair with\s+)(.+?)\.(.*?)$',
        comment
    )
    if m:
        prefix   = m.group(1)
        elog     = m.group(2).strip()
        alog     = m.group(3).strip()
        pair_kw  = m.group(4)
        id_alog  = m.group(5).strip()
        rest     = "." + m.group(6)
        ephys    = entity_lookup.get(elog)
        aphys    = attr_lookup.get((elog, alog))
        # Thử tìm id_aphys từ entity đích trước, nếu không thì từ self_attr_lookup
        id_aphys = attr_lookup.get((elog, id_alog))
        if id_aphys is None and self_attr_lookup:
            id_aphys = self_attr_lookup.get(id_alog)
        if ephys and aphys and id_aphys:
            return f"{prefix}{ephys}.{aphys}. {pair_kw}{id_aphys}{rest}", True
        return comment, False

    return comment, False


def physicalize(dry_run: bool):
    print(f"Model file: {MODEL_FILE}")
    print(f"Source filter: {SOURCE_FILTER}  |  Dry-run: {dry_run}\n")

    with open(MODEL_FILE, encoding="utf-8") as f:
        model = yaml.safe_load(f)

    entities = model.get("entities", [])

    # Bước 1: build lookup từ toàn bộ model
    entity_lookup, attr_lookup = build_lookup(entities)
    print(f"Lookup: {len(entity_lookup)} entities, {len(attr_lookup)} attributes\n")

    # Bước 2: rewrite comments cho entity có FMS trong sources
    report_rows = []
    changed_count = 0
    not_found: set[str] = set()

    for e in entities:
        ldm = e.get("ldm", {})
        if SOURCE_FILTER not in (ldm.get("sources") or []):
            continue
        entity_name = ldm.get("logical_name", "")

        # Build self_attr_lookup: logical attr name → physical attr name cho entity hiện tại
        self_attr_lookup = {
            a.get("name", ""): a.get("physical_name", "")
            for a in (e.get("attributes") or [])
            if a.get("name") and a.get("physical_name")
        }

        for attr in (e.get("attributes") or []):
            comment = attr.get("comment")
            if not comment or not isinstance(comment, str):
                continue
            comment = comment.strip()
            if not (comment.startswith("FK target:") or comment.startswith("Lookup pair:")):
                continue

            new_comment, changed = transform_comment(comment, entity_lookup, attr_lookup, self_attr_lookup)

            if changed:
                report_rows.append({
                    "entity": entity_name,
                    "attr": attr.get("name", ""),
                    "comment_old": comment,
                    "comment_new": new_comment,
                })
                if not dry_run:
                    attr["comment"] = new_comment
                changed_count += 1
            else:
                # Kiểm tra xem có phải entity/attr không tìm thấy không
                m = re.match(r'^(?:FK target|Lookup pair):\s+(.+?)\.', comment)
                if m:
                    elog = m.group(1).strip()
                    if elog not in entity_lookup:
                        not_found.add(elog)

    print(f"Comments {'sẽ được' if dry_run else 'đã được'} cập nhật: {changed_count}")

    if not_found:
        print(f"\n[WARN] Entity không tìm thấy trong lookup ({len(not_found)}):")
        for n in sorted(not_found):
            print(f"  - {n}")

    # Report
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    suffix = "_dryrun" if dry_run else ""
    report_path = REPORT_DIR / f"physicalize_fk_comments_FMS{suffix}.csv"
    with open(report_path, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=["entity", "attr", "comment_old", "comment_new"])
        w.writeheader()
        w.writerows(report_rows)
    print(f"\nReport → {report_path}")

    # Sample
    if report_rows:
        print("\nSample (5 mẫu đầu):")
        for r in report_rows[:5]:
            print(f"  [{r['entity']}] {r['attr']}")
            print(f"    OLD: {r['comment_old']}")
            print(f"    NEW: {r['comment_new']}")
            print()

    # Ghi file
    if not dry_run:
        with open(MODEL_FILE, "w", encoding="utf-8") as f:
            yaml.dump(model, f, Dumper=_Dumper,
                      allow_unicode=True, sort_keys=False, default_flow_style=False)
        print(f"Đã ghi → {MODEL_FILE}")


def physicalize_yaml_files(dry_run: bool):
    """Xử lý các file YAML gốc trong DataModel/Atomic/ (source=FMS), raw text replace."""
    # Build lookup từ atomic_model.yaml
    with open(MODEL_FILE, encoding="utf-8") as f:
        model = yaml.safe_load(f)
    entity_lookup, attr_lookup = build_lookup(model.get("entities", []))
    print(f"Lookup: {len(entity_lookup)} entities, {len(attr_lookup)} attributes\n")

    yaml_files = sorted(ATOMIC_DIR.rglob("*.yaml"))
    report_rows = []
    files_changed = 0
    not_found: set[str] = set()

    for fpath in yaml_files:
        try:
            doc = yaml.safe_load(open(fpath, encoding="utf-8"))
        except Exception:
            continue
        if not doc or doc.get("ldm", {}).get("source") != SOURCE_FILTER:
            continue

        entity_name = doc.get("ldm", {}).get("logical_name", "")
        # self_attr_lookup: logical attr name → physical attr name của entity này
        self_attr_lookup = {
            a.get("name", ""): a.get("physical_name", "")
            for a in (doc.get("attributes") or [])
            if a.get("name") and a.get("physical_name")
        }
        raw = fpath.read_text(encoding="utf-8")
        new_raw = raw

        for regex in (RE_COMMENT_DOUBLE, RE_COMMENT_SINGLE):
            for m in regex.finditer(raw):
                prefix    = m.group(1)   # indent + 'comment: "'
                kw        = m.group(2)   # 'FK target:' hoặc 'Lookup pair:'
                body_rest = m.group(3)   # phần còn lại
                close_q   = m.group(4)   # quote đóng
                full_body = kw + body_rest

                new_body, changed = transform_comment(full_body, entity_lookup, attr_lookup, self_attr_lookup)

                if changed:
                    old_line = m.group(0)
                    new_line = f"{prefix}{new_body}{close_q}"
                    new_raw = new_raw.replace(old_line, new_line, 1)
                    report_rows.append({
                        "file": fpath.name,
                        "entity": entity_name,
                        "comment_old": full_body,
                        "comment_new": new_body,
                    })
                else:
                    mx = re.match(r'^(?:FK target|Lookup pair):\s+(.+?)\.', full_body)
                    if mx:
                        elog = mx.group(1).strip()
                        if elog not in entity_lookup:
                            not_found.add(elog)

        if new_raw != raw:
            files_changed += 1
            if not dry_run:
                fpath.write_text(new_raw, encoding="utf-8")

    print(f"Files {'sẽ được' if dry_run else 'đã được'} cập nhật: {files_changed}")
    print(f"Comments {'sẽ được' if dry_run else 'đã được'} cập nhật: {len(report_rows)}")

    if not_found:
        print(f"\n[WARN] Entity không tìm thấy ({len(not_found)}):")
        for n in sorted(not_found):
            print(f"  - {n}")

    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    suffix = "_dryrun" if dry_run else ""
    report_path = REPORT_DIR / f"physicalize_fk_comments_yaml{suffix}.csv"
    with open(report_path, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=["file", "entity", "comment_old", "comment_new"])
        w.writeheader()
        w.writerows(report_rows)
    print(f"\nReport → {report_path}")

    if report_rows:
        print("\nSample (5 mẫu đầu):")
        for r in report_rows[:5]:
            print(f"  [{r['entity']}] {r['file']}")
            print(f"    OLD: {r['comment_old']}")
            print(f"    NEW: {r['comment_new']}")
            print()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--target", choices=["atomic-model", "yaml-files"], default="atomic-model",
                        help="atomic-model: cập nhật atomic_model.yaml; yaml-files: cập nhật file gốc DataModel/Atomic/")
    args = parser.parse_args()

    if args.target == "yaml-files":
        print(f"Target: DataModel/Atomic/ (source={SOURCE_FILTER})  |  Dry-run: {args.dry_run}\n")
        physicalize_yaml_files(args.dry_run)
    else:
        physicalize(args.dry_run)


if __name__ == "__main__":
    main()
