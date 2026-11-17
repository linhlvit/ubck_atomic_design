"""pttk_facts.py — dữ kiện máy sinh cho PTTK mục 3.1 (0 token LLM, không suy diễn).

Hai phần của PTTK mà LLM KHÔNG được tự viết giá trị (comment review trên template PTTK v1.2):

  job-info  Khối "3.1.X.1 Thông tin chung luồng đồng bộ" (7 dòng) — đọc reference/etl_job_info.yaml,
            CHỈ in giá trị của dòng `confirmed: true` (comment #305: không để trống; nhưng giá trị chưa
            xác nhận thì không được in vào tài liệu gửi khách hàng).
  flat      Tầng thứ 5 "Datamart → ClickHouse" — danh sách bảng phẳng của phân hệ đọc từ DDL thật
            Datamart/flat-table/{M}/01_create_*_flat_tables.sql (tên bảng, bảng Datamart nguồn, ENGINE,
            PARTITION BY, ORDER BY), in dưới schema dwh_prod (comment #501, #524–#534).

Usage:
  python pttk_facts.py job-info -m TT                # in khối Markdown 3.1.1.1
  python pttk_facts.py job-info -m ALL --status      # bảng trạng thái xác nhận của 11 phân hệ
  python pttk_facts.py job-info -m TT --apply        # thay khối 3.1.X.1 trong DTM_TT_PTTK.md (sao lưu .bak-<ts>)
  python pttk_facts.py flat -m TT                    # bảng phẳng + node mermaid + câu mô tả mẫu
  python pttk_facts.py flat -m TT --table fct_penalty_decision   # chỉ bảng phẳng của 1 bảng Datamart
  python pttk_facts.py lint -m TT                    # kiểm Markdown PTTK với chuẩn 5 tầng + ODS 1:1 Staging (không render)
  python pttk_facts.py lint -m ALL --summary         # tóm tắt số cảnh báo theo module

Luồng 5 tầng: Staging → ODS (1:1 Staging) → Atomic → Datamart (Dim, Fact) → ClickHouse (bảng phẳng, schema dwh_prod).
"""

from __future__ import annotations

import argparse
import csv
import datetime as _dt
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import doc_registry as R  # noqa: E402

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

REPO_ROOT = R.REPO_ROOT
FLAT_DIR = REPO_ROOT / "Datamart" / "flat-table"
LLD_DIR = REPO_ROOT / "Datamart" / "lld"


# ════════════════════════════════════════════════════════════════════════════════════════════
# job-info
# ════════════════════════════════════════════════════════════════════════════════════════════
def load_job_info() -> dict:
    import yaml

    if not R.JOB_INFO_PATH.is_file():
        raise SystemExit(f"❌ Thiếu {R.JOB_INFO_PATH}")
    data = yaml.safe_load(R.JOB_INFO_PATH.read_text(encoding="utf-8")) or {}
    return data.get("modules", {})


def job_info_lines(module: str, info: dict) -> tuple[list[str], list[str]]:
    """(7 dòng bullet Markdown, danh sách khóa chưa xác nhận)."""
    fields = info.get(module, {})
    lines, pending = [], []
    for key, label in R.JOB_INFO_FIELDS:
        f = fields.get(key) or {}
        value = " ".join(str(f.get("value") or "").split())
        if f.get("confirmed") is True and value:
            lines.append(f"- {label}: {value}")
        else:
            lines.append(f"- {label}:")
            pending.append(key)
    return lines, pending


def job_info_block(module: str, info: dict) -> tuple[str, list[str]]:
    mod = R.get_module(module)
    lines, pending = job_info_lines(mod.code, info)
    head = f"### 3.1.{mod.idx}.1 Thông tin chung luồng đồng bộ"
    return head + "\n\n" + "\n".join(lines) + "\n", pending


_INFO_HEAD = re.compile(r"^###\s+3\.[12]\.\d+\.1\b.*$", re.MULTILINE)
_NEXT_HEAD = re.compile(r"^#{1,4}\s+", re.MULTILINE)


def apply_job_info(module: str, info: dict, write: bool) -> int:
    mod = R.get_module(module)
    md = R.OUTPUT_DIR / mod.code / f"DTM_{mod.code}_PTTK.md"
    if not md.is_file():
        print(f"❌ {mod.code}: chưa có {md} — chạy Phase 1 trước.", file=sys.stderr)
        return 1
    text = md.read_text(encoding="utf-8")
    m = _INFO_HEAD.search(text)
    if not m:
        print(f"❌ {mod.code}: không tìm thấy heading '### 3.1.X.1 …' trong {md.name}", file=sys.stderr)
        return 1
    nxt = _NEXT_HEAD.search(text, m.end())
    end = nxt.start() if nxt else len(text)
    block, pending = job_info_block(mod.code, info)
    new_text = text[: m.start()] + block + "\n" + text[end:]
    if new_text == text:
        print(f"= {mod.code}: khối 3.1.{mod.idx}.1 đã khớp cấu hình ({7 - len(pending)}/7 dòng có giá trị).")
        return 0
    old_block = text[m.start():end].strip().splitlines()
    new_block = block.strip().splitlines()
    print(f"~ {mod.code}: khối 3.1.{mod.idx}.1 thay đổi ({7 - len(pending)}/7 dòng có giá trị):")
    for ln in old_block:
        if ln not in new_block:
            print(f"    - {ln}")
    for ln in new_block:
        if ln not in old_block:
            print(f"    + {ln}")
    if write:
        ts = _dt.datetime.now().strftime("%Y%m%d-%H%M%S")
        bak = md.with_name(md.name + f".bak-{ts}")
        bak.write_text(text, encoding="utf-8", newline="")
        with md.open("w", encoding="utf-8", newline="") as f:
            f.write(new_text)
        print(f"    → đã ghi {md} (sao lưu {bak.name})")
    else:
        print("    (dry-run — thêm --apply để ghi)")
    return 0


def job_info_status(modules: list[str], info: dict) -> None:
    print("| Phân hệ | " + " | ".join(lbl for _k, lbl in R.JOB_INFO_FIELDS) + " | Đã xác nhận |")
    print("|---|" + "---|" * (len(R.JOB_INFO_FIELDS) + 1))
    total_ok = 0
    for code in modules:
        fields = info.get(code, {})
        cells, ok = [], 0
        for key, _label in R.JOB_INFO_FIELDS:
            f = fields.get(key) or {}
            if f.get("confirmed") is True and str(f.get("value") or "").strip():
                cells.append("✅")
                ok += 1
            elif str(f.get("value") or "").strip():
                cells.append("đề xuất")
            else:
                cells.append("trống")
        total_ok += ok
        print(f"| {code} | " + " | ".join(cells) + f" | {ok}/7 |")
    n = len(modules) * len(R.JOB_INFO_FIELDS)
    print(f"\nTổng: {total_ok}/{n} dòng đã xác nhận. 'đề xuất' = có giá trị gợi ý trong {R.JOB_INFO_PATH.name} "
          "nhưng chưa `confirmed: true` → tài liệu để trống dòng đó.")


# ════════════════════════════════════════════════════════════════════════════════════════════
# flat
# ════════════════════════════════════════════════════════════════════════════════════════════
_CREATE = re.compile(r"^CREATE TABLE IF NOT EXISTS\s+(\w+)\.(\w+)", re.MULTILINE)


def _entity_names(module: str) -> dict[str, str]:
    """datamart_table → datamart_entity, đọc dòng đầu của từng LLD per-table (kể cả lld/Common)."""
    out: dict[str, str] = {}
    for d in (LLD_DIR / module, LLD_DIR / "Common"):
        if not d.is_dir():
            continue
        for p in sorted(d.glob("DTM_*.csv")):
            try:
                with p.open(encoding="utf-8-sig", newline="") as f:
                    row = next(csv.DictReader(f), None)
            except Exception:
                row = None
            if row and row.get("datamart_table"):
                out.setdefault(row["datamart_table"].strip(), (row.get("datamart_entity") or "").strip())
    return out


def _table_kind(mart_table: str) -> str:
    if mart_table.startswith("fct_") or mart_table.endswith(("_rpt", "_rpt_snpst")):
        return "Fact"
    if mart_table.startswith("opr_"):
        return "Operational"
    if mart_table.endswith("_dim"):
        return "Dimension"
    return "Khác"


def parse_flat_ddl(module: str) -> list[dict]:
    """Mỗi bảng phẳng của phân hệ: tên, bảng Datamart nguồn, engine/partition/order by — chỉ đọc DDL thật."""
    mod = R.get_module(module)
    d = FLAT_DIR / mod.code
    files = sorted(d.glob("01_create_*_flat_tables.sql")) if d.is_dir() else []
    if not files:
        return []
    names = _entity_names(mod.code)
    rows: list[dict] = []
    for fp in files:
        text = fp.read_text(encoding="utf-8")
        marks = list(_CREATE.finditer(text))
        for i, m in enumerate(marks):
            body = text[m.start(): marks[i + 1].start() if i + 1 < len(marks) else len(text)]
            # phần đuôi sau dấu ')' đóng danh sách cột
            tail = body[body.rfind("\n)") if "\n)" in body else 0:]
            flat = m.group(2)
            mart = flat
            if mart.startswith(mod.flat_prefix + "_"):
                mart = mart[len(mod.flat_prefix) + 1:]
            if mart.endswith("_flat"):
                mart = mart[: -len("_flat")]

            def grab(kw: str) -> str:
                g = re.search(rf"^{kw}\s*=?\s*(.+)$", tail, re.MULTILINE)
                return g.group(1).strip() if g else ""

            # '-- From: FCT_X' (khối đầu = bảng driving) rồi '-- From: CALENDAR DATE DIMENSION' … = các Dimension được JOIN
            froms = [re.sub(r"\s+", " ", x).strip() for x in re.findall(r"^\s*--\s*From:\s*(.+?)\s*$", body, re.MULTILINE)]
            joins = [x.title() for x in froms[1:] if "DIMENSION" in x.upper()]

            rows.append({
                "joins": joins,
                "flat": flat,
                "ddl_db": m.group(1),
                "mart_table": mart,
                "mart_entity": names.get(mart, ""),
                "kind": _table_kind(mart),
                "engine": grab("ENGINE"),
                "partition": grab("PARTITION BY"),
                "order": grab("ORDER BY"),
                "file": fp.name,
            })
    return rows


def print_flat(module: str, only_table: str | None) -> int:
    mod = R.get_module(module)
    rows = parse_flat_ddl(mod.code)
    if only_table:
        rows = [r for r in rows if r["mart_table"] == only_table or r["flat"] == only_table]
    if not rows:
        print(f"⚠ {mod.code}: không có bảng phẳng nào"
              + (f" cho '{only_table}'" if only_table else "")
              + f" trong {FLAT_DIR / mod.code} — tầng ClickHouse của diagram ghi 'chưa có bảng phẳng', KHÔNG tự đặt tên.")
        return 0
    ch = R.SCHEMA_CLICKHOUSE
    dbs = sorted({r["ddl_db"] for r in rows})
    print(f"## Bảng phẳng ClickHouse của phân hệ {mod.code} — {len(rows)} bảng (nguồn: Datamart/flat-table/{mod.code}/)\n")
    if dbs != [ch]:
        print(f"> Lưu ý: DDL trong repo đang khai database `{', '.join(dbs)}`; tài liệu in schema `{ch}` theo comment review #501 "
              f"(schema chính thức trên ClickHouse). Đây là lệch tên database giữa DDL repo và tài liệu — báo Data Modeler, không tự sửa DDL.\n")
    print("| STT | Bảng phẳng ClickHouse | Bảng Datamart nguồn (dtm) | Tên logical | Loại | Dimension được JOIN vào bảng phẳng | ENGINE | PARTITION BY | ORDER BY |")
    print("|---|---|---|---|---|---|---|---|---|")
    for i, r in enumerate(rows, 1):
        print(f"| {i} | `{ch}.{r['flat']}` | `{R.SCHEMA_DATAMART}.{r['mart_table']}` | {r['mart_entity'] or '(không thấy LLD)'} | {r['kind']} "
              f"| {', '.join(r['joins']) or '—'} | `{r['engine']}` | `{r['partition'] or '—'}` | `{r['order'] or '—'}` |")
    missing = [r["mart_table"] for r in rows if not r["mart_entity"]]
    if missing:
        print(f"\n> ⚠ Không tìm thấy LLD per-table cho: {', '.join(missing)} — kiểm tra tên bảng Datamart nguồn trước khi đưa vào diagram.")
    print("\n### Node mermaid cho subgraph ClickHouse (ID = tên bảng phẳng, label = schema.bảng)\n")
    print("```")
    print("  subgraph ClickHouse")
    for r in rows:
        print(f"    {r['flat']}[\"{ch}.{r['flat']}\"]")
    print("  end")
    for r in rows:
        print(f"  {r['mart_table']} --> {r['flat']}")
    print("```")
    print()
    print("Dimension được JOIN vào bảng phẳng (cột 'Dimension được JOIN') nối `{id_dim} --> {bảng phẳng}`, KHÔNG nối `dim --> fact`.")
    print("\n### Dòng mô tả cho đoạn '*Datamart → ClickHouse:*' (giữ nguyên tên bảng/engine/partition/order by — chỉ viết thêm ý nghĩa nghiệp vụ)\n")
    for r in rows:
        part = f", phân vùng `{r['partition']}`" if r["partition"] else ""
        order = f", khóa sắp xếp `{r['order']}`" if r["order"] else ""
        print(f"- **{ch}.{r['flat']}:** Bảng phẳng phục vụ khai thác báo cáo/dashboard, trải phẳng từ "
              f"{R.SCHEMA_DATAMART}.{r['mart_table']}; engine `{r['engine']}`{part}{order}")
    return 0


# ════════════════════════════════════════════════════════════════════════════════════════════
# lint
# ════════════════════════════════════════════════════════════════════════════════════════════
def lint_module(module: str) -> list[str]:
    """Cảnh báo lệch chuẩn của DTM_{M}_PTTK.md: 5 tầng, ODS 1:1 Staging, schema dwh_prod, thiếu đoạn mô tả."""
    import update_q5_with_datamart_modules as U  # import muộn: kéo theo python-docx

    mod = R.get_module(module)
    md = R.OUTPUT_DIR / mod.code / f"DTM_{mod.code}_PTTK.md"
    if not md.is_file():
        return [f"{mod.code} | (module): chưa có {md.name} — chạy Phase 1 trước"]
    warns: list[str] = []
    U.parse_module_pttk(md, Path("."), mod.code, str(mod.idx), mod.pttk_name, warnings=warns, render=False)
    return warns


def lint(modules: list[str], summary: bool) -> int:
    total = 0
    for code in modules:
        w = lint_module(code)
        total += len(w)
        if summary:
            print(f"{code:6s} {'OK' if not w else str(len(w)) + ' cảnh báo'}")
        else:
            print(f"=== {code}: {len(w)} cảnh báo")
            for x in w:
                print(f"  - {x}")
    print()
    print(f"Tổng: {total} cảnh báo" + (" — Markdown PTTK đạt chuẩn 5 tầng." if total == 0 else
          " — sinh lại Phase 1 (SKILL.md Bước 2) cho module có cảnh báo; update_q5_with_datamart_modules.py --strict sẽ dừng khi còn cảnh báo."))
    return 1 if total else 0


def _modules_arg(v: str) -> list[str]:
    return [m.code for m in R.MODULES] if v.upper() == "ALL" else [R.get_module(v).code]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    j = sub.add_parser("job-info", help="Khối 3.1.X.1 Thông tin chung luồng đồng bộ từ etl_job_info.yaml")
    j.add_argument("-m", "--module", required=True, help="Mã module hoặc ALL")
    j.add_argument("--status", action="store_true", help="In bảng trạng thái xác nhận")
    j.add_argument("--apply", action="store_true", help="Ghi khối vào DTM_{M}_PTTK.md (mặc định chỉ in / dry-run)")
    j.add_argument("--check", action="store_true", help="Dry-run so khối trong DTM_{M}_PTTK.md với cấu hình")
    f = sub.add_parser("flat", help="Bảng phẳng ClickHouse (tầng 5) của phân hệ, đọc từ DDL flat")
    f.add_argument("-m", "--module", required=True, help="Mã module hoặc ALL")
    f.add_argument("--table", default=None, help="Chỉ lấy bảng phẳng của 1 bảng Datamart (VD fct_penalty_decision)")
    l = sub.add_parser("lint", help="Kiểm DTM_{M}_PTTK.md với chuẩn 5 tầng + ODS 1:1 Staging (không render, không cần template)")
    l.add_argument("-m", "--module", required=True, help="Mã module hoặc ALL")
    l.add_argument("--summary", action="store_true", help="Chỉ in số cảnh báo theo module")
    a = ap.parse_args()

    mods = _modules_arg(a.module)
    rc = 0
    if a.cmd == "job-info":
        info = load_job_info()
        if a.status:
            job_info_status(mods, info)
        elif a.apply or a.check:
            for code in mods:
                rc |= apply_job_info(code, info, write=a.apply)
        else:
            for code in mods:
                block, pending = job_info_block(code, info)
                print(block)
                if pending:
                    print(f"<!-- {code}: {len(pending)}/7 dòng để trống vì chưa `confirmed: true` trong etl_job_info.yaml: "
                          f"{', '.join(pending)} -->\n", file=sys.stderr)
    elif a.cmd == "lint":
        rc = lint(mods, a.summary)
    else:
        for code in mods:
            rc |= print_flat(code, a.table)
            print()
    return rc


if __name__ == "__main__":
    raise SystemExit(main())
