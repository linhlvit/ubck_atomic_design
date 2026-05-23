"""
Phân tích pattern trong trường comment của các file YAML DataModel/Atomic.

Output:
  1. Thống kê tần suất từng pattern
  2. Sample data cho mỗi pattern (tối đa 3 ví dụ)
  3. Xuất ra CSV + in ra console
"""

import re
import sys
import yaml
import csv
from pathlib import Path
from collections import defaultdict

# Fix console encoding on Windows
if sys.stdout.encoding != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# ── Cấu hình ──────────────────────────────────────────────────────────────────
ATOMIC_DIR = Path(__file__).parent.parent / "DataModel" / "Atomic"
OUTPUT_CSV = Path(__file__).parent.parent / "docs" / "analysis" / "comment_pattern_stats.csv"
SAMPLE_CSV = Path(__file__).parent.parent / "docs" / "analysis" / "comment_pattern_samples.csv"
MAX_SAMPLES = 3

# ── Pattern definitions ────────────────────────────────────────────────────────
# Mỗi pattern: (label, regex) — kiểm tra theo thứ tự, khớp đầu tiên thắng
PATTERNS = [
    ("PK surrogate",            r"^PK surrogate"),
    ("BK chính",                r"BK chính"),
    ("BK. ",                    r"\bBK\b"),                          # BK. (không phải BK chính)
    ("FK target",               r"FK target:"),
    ("Lookup pair",             r"Lookup pair:"),
    ("Scheme only",             r"^Scheme:\s*\w"),                   # Scheme: XYZ (ngắn, không kèm ghi chú)
    ("Scheme + note",           r"^Scheme:.*\.\s+\S"),               # Scheme: XYZ. <ghi chú thêm>
    ("BCV Term (exact)",        r'^BCV Term:'),
    ("BCV (exact)",             r'^BCV:\s+"[^"]+"'),
    ("BCV (gan nhat)",           r"BCV:\s+g[aầ]n nh[aấ]t"),
    ("BCV (other)",             r"\bBCV\b"),
    ("Denormalized",            r"[Dd]enormalized"),
    ("Hardcode",                r"[Hh]ardcode"),
    ("ETL derived",             r"ETL"),
    ("Audit note",              r"[Aa]udit"),
    ("Snapshot",                r"[Ss]napshot"),
    ("Mã người dùng",           r"Mã người dùng"),
    ("ds_ technical field",     r"\bds_"),
    ("null / empty",            r"^null$"),
]

PATTERN_OTHER = "Other"

def classify_comment(comment: str) -> str:
    if comment is None or str(comment).strip().lower() == "null":
        return "null"
    text = str(comment).strip()
    for label, pattern in PATTERNS:
        if re.search(pattern, text):
            return label
    return PATTERN_OTHER


def load_yaml_safe(path: Path):
    """Load YAML, bỏ qua file lỗi."""
    try:
        with open(path, encoding="utf-8") as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"  [WARN] Bỏ qua {path.name}: {e}")
        return None


def analyze():
    yaml_files = sorted(ATOMIC_DIR.rglob("*.yaml"))
    print(f"Tìm thấy {len(yaml_files)} file YAML trong {ATOMIC_DIR}\n")

    # pattern_label → list of {"file", "entity", "attr", "comment"}
    pattern_map: dict[str, list[dict]] = defaultdict(list)
    total_attrs = 0

    for fpath in yaml_files:
        doc = load_yaml_safe(fpath)
        if not doc:
            continue
        entity = doc.get("ldm", {}).get("logical_name", fpath.stem)
        source = doc.get("ldm", {}).get("source", "")
        attrs = doc.get("attributes", []) or []
        for attr in attrs:
            total_attrs += 1
            comment = attr.get("comment")
            label = classify_comment(comment)
            pattern_map[label].append({
                "file": fpath.name,
                "source": source,
                "entity": entity,
                "attr": attr.get("name", ""),
                "comment": str(comment).strip() if comment is not None else "null",
            })

    # ── In thống kê ────────────────────────────────────────────────────────────
    print(f"{'Pattern':<30} {'Count':>6}  {'%':>6}  {'Sample attr (entity)':}")
    print("-" * 90)

    stats_rows = []
    sample_rows = []

    for label, entries in sorted(pattern_map.items(), key=lambda x: -len(x[1])):
        count = len(entries)
        pct = count / total_attrs * 100
        sample_str = f"{entries[0]['attr']} ({entries[0]['entity']})" if entries else ""
        print(f"  {label:<28} {count:>6}  {pct:>5.1f}%  {sample_str}")
        stats_rows.append({"pattern": label, "count": count, "pct": round(pct, 2)})

        # lấy tối đa MAX_SAMPLES ví dụ đa dạng (khác source nếu có)
        seen_sources = set()
        samples = []
        for e in entries:
            if e["source"] not in seen_sources or len(samples) == 0:
                samples.append(e)
                seen_sources.add(e["source"])
            if len(samples) >= MAX_SAMPLES:
                break
        for s in samples:
            sample_rows.append({
                "pattern": label,
                "source": s["source"],
                "entity": s["entity"],
                "attr": s["attr"],
                "comment": s["comment"],
                "file": s["file"],
            })

    print("-" * 90)
    print(f"  {'TOTAL':<28} {total_attrs:>6}  100.0%\n")

    # ── Xuất CSV ────────────────────────────────────────────────────────────────
    OUTPUT_CSV.parent.mkdir(parents=True, exist_ok=True)

    with open(OUTPUT_CSV, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=["pattern", "count", "pct"])
        w.writeheader()
        w.writerows(stats_rows)
    print(f"Đã xuất thống kê → {OUTPUT_CSV}")

    with open(SAMPLE_CSV, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=["pattern", "source", "entity", "attr", "comment", "file"])
        w.writeheader()
        w.writerows(sample_rows)
    print(f"Đã xuất sample     → {SAMPLE_CSV}")


if __name__ == "__main__":
    analyze()
