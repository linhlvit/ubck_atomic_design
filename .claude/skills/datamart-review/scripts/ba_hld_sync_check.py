# -*- coding: utf-8 -*-
"""
ba_hld_sync_check.py — đối chiếu CẤU TRÚC + NỘI DUNG giữa BA ↔ HLD ↔ Detail Mapping.

VÌ SAO (sự cố GSTT 2026-09-23)
    `datamart_progress_analyzer.py` chỉ so SỐ LƯỢNG theo SỐ Nhóm. Trong một phiên, các lỗi sau
    đều lọt qua nó và qua run_quality_gates.py:
      - BA tách Nhóm 28/29 → 28–31 và dồn số các Nhóm sau, HLD vẫn giữ số cũ; Nhóm 30 báo
        "🟢 Khớp" chỉ vì HLD Nhóm 30 cũ (PTKT) TÌNH CỜ cũng có 14 KPI như BA Nhóm 30 mới.
      - BA gán CHUNG 1 STT cho 2 màn hình khác nhau (STT 31 = bản đồ nhiệt + PTKT), và gán
        nhầm STT cho 1 dòng lẻ (dòng 362 "Giá tham chiếu" ghi STT 26 nhưng Dashboard là Nhóm 24).
      - Nhóm 26: BA yêu cầu GTNN (giá trị) nhưng Detail Mapping dùng KLNN (khối lượng).
      - Nhóm 7/25: thiếu hẳn KPI cho 1 dòng BA, bị che bởi KPI tách thêm ở chỗ khác.
      - Detail Mapping bị 1 commit cắt từ 577 còn 101 dòng; file bị xóa giữa phiên.

KIỂM TRA (mã lỗi)
    S1 [L0-DM-FILE-INTEGRITY]     Detail Mapping/HLD tồn tại; số dòng không tụt >20% so với HEAD
                                  (và HEAD không tụt >20% so với HEAD~1).
    S2 [L1-BA-STT-COLLISION]      1 STT BA chứa ≥2 khối Dashboard khác nhau (khối thiểu số ≥3 dòng)
                                  → BA gộp nhầm 2 màn hình; thiểu số 1–2 dòng mà Dashboard trùng
                                  Nhóm khác → dòng gán nhầm STT (L1-BA-ROW-MISPLACED).
    S3 [L1-GROUP-NUMBER-DRIFT]    Tập số Nhóm BA ≠ HLD ≠ Detail Mapping; hoặc tên Nhóm HLD không
                                  giống tên màn hình BA cùng số (dấu hiệu lệch số dù số lượng khớp).
    S4 [L3-BA-ROW-UNMAPPED]       Dòng BA (Done/Doing/Pending) không ghép được KPI nào trong
                                  Detail Mapping cùng Nhóm (so tên theo token, chịu được hậu tố
                                  "khớp lệnh", "(theo chỉ số)"...).
    S5 [L3-MEASURE-TYPE-MISMATCH] Dòng BA đo GIÁ TRỊ (GT/giá trị/_val) nhưng KPI ghép được đọc cột
                                  khối lượng (_vol), hoặc ngược lại.

DÙNG
    python ba_hld_sync_check.py --module GSTT                 # toàn module
    python ba_hld_sync_check.py --module GSTT --nhom 28 29    # chỉ các Nhóm vừa sửa
    python ba_hld_sync_check.py --module GSTT --strict        # exit 1 nếu có lỗi S1/S2/S3/S5

    S4 là CẢNH BÁO (so tên mờ có thể nhầm) — phải đọc và giải trình từng dòng, không bỏ qua.
"""
from __future__ import annotations

import argparse
import collections
import csv
import difflib
import re
import subprocess
import sys
import unicodedata
from pathlib import Path

_script_dir = Path(__file__).resolve().parent
if str(_script_dir) not in sys.path:
    sys.path.insert(0, str(_script_dir))
for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from datamart_common import find_project_root  # noqa: E402
from datamart_common.ba_parser import group_ba_items, parse_ba_file, profile_for, resolve_ba_path  # noqa: E402

RE_NHOM = re.compile(r"Nhóm\s+(\d+)")
STOP = {"theo", "của", "và", "các", "trong", "cho", "tại"}
VAL_WORDS = ("gt", "giá trị", "gtgd", "gtnn", "value", "_val")
VOL_WORDS = ("kl", "khối lượng", "klgd", "klnn", "volume", "_vol")


def norm(s: str) -> str:
    s = unicodedata.normalize("NFC", (s or "").lower()).replace("\n", " ")
    s = re.sub(r"[^\w%+/ ]", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    # đồng nghĩa viết tắt BA ↔ tên KPI (GT = giá trị, KL = khối lượng, NĐTNN/NN = nước ngoài)
    for a, b in (("giá trị giao dịch", "gtgd"), ("khối lượng giao dịch", "klgd"), ("giá trị", "gt"),
                 ("khối lượng", "kl"), ("nước ngoài", "nn"), ("nđtnn", "nn")):
        s = s.replace(a, b)
    return s


def toks(s: str) -> set:
    return {t for t in norm(s).replace("/", " ").split() if t not in STOP}


def name_score(a: str, b: str) -> float:
    ta, tb = toks(a), toks(b)
    if not ta or not tb:
        return 0.0
    small, big = (ta, tb) if len(ta) <= len(tb) else (tb, ta)
    contain = len(small & big) / len(small)
    jaccard = len(ta & tb) / len(ta | tb)
    # contain cho phép hậu tố ("KLGD" ↔ "KLGD khớp lệnh"); jaccard ưu tiên cặp dài tương đương
    return max(0.6 * contain + 0.4 * jaccard, difflib.SequenceMatcher(None, norm(a), norm(b)).ratio())


def screen_key(dash: str) -> str:
    """Phần màn hình của cột Dashboard — bỏ khoảng trắng/biến thể nhỏ."""
    return norm(dash)[:120]


def kind(text: str) -> str:
    t = " " + norm(text) + " "
    is_val = any(f" {w} " in t or w in t for w in ("gtnn", "gtgd", "giá trị", "_val")) or re.search(r"(^| )gt( |$)", t)
    is_vol = any(w in t for w in ("klnn", "klgd", "khối lượng", "_vol")) or re.search(r"(^| )kl( |$)", t)
    if is_val and not is_vol:
        return "VAL"
    if is_vol and not is_val:
        return "VOL"
    return ""


def git_lines(root: Path, rev: str, rel: str) -> int:
    try:
        out = subprocess.run(["git", "show", f"{rev}:{rel}"], cwd=root, capture_output=True, timeout=60)
        return out.stdout.count(b"\n") if out.returncode == 0 else -1
    except Exception:
        return -1


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[1])
    ap.add_argument("-m", "--module", required=True)
    ap.add_argument("--nhom", nargs="*", help="Chỉ kiểm các Nhóm này (S3 tập Nhóm vẫn kiểm toàn module)")
    ap.add_argument("--strict", action="store_true")
    args = ap.parse_args()
    root = find_project_root()
    M = args.module.upper()
    hld = root / f"Datamart/hld/DTM_{M}_HLD.md"
    dm_rel = f"Datamart/lld/DTM_{M}_Detail_Mapping.csv"
    dm = root / dm_rel
    errors, warns = [], []

    # ---------- S1
    print("S1 [L0-DM-FILE-INTEGRITY]")
    for p in (hld, dm):
        if not p.exists():
            errors.append(f"S1 thiếu file {p.relative_to(root)} — kiểm `git status` (có thể bị xóa), khôi phục từ Datamart/context/.backup/ trước khi làm tiếp")
    if dm.exists():
        cur = dm.read_bytes().count(b"\n")
        head, prev = git_lines(root, "HEAD", dm_rel), git_lines(root, "HEAD~1", dm_rel)
        print(f"   Detail Mapping: working={cur} | HEAD={head} | HEAD~1={prev}")
        if head > 0 and cur < 0.8 * head:
            errors.append(f"S1 Detail Mapping working ({cur}) < 80% HEAD ({head}) — nghi bị cắt/ghi đè")
        if head > 0 and prev > 0 and head < 0.8 * prev:
            if cur >= 0.8 * prev:
                warns.append(f"S1 HEAD ({head}) < 80% HEAD~1 ({prev}) — commit gần nhất đã cắt Detail Mapping; working copy ({cur}) đã khôi phục, cần COMMIT bản khôi phục")
            else:
                errors.append(f"S1 HEAD ({head}) < 80% HEAD~1 ({prev}) — commit gần nhất đã cắt Detail Mapping, khôi phục từ HEAD~1 trước")
    if errors:
        for e in errors:
            print("   ❌", e)
        return 1

    # ---------- đọc BA / HLD / DM
    ba_path = resolve_ba_path(root, M)
    items, _ = parse_ba_file(ba_path, profile_for(root, M), include_deleted=False)
    groups = group_ba_items(items)
    ba_live = {g: [x for x in its if x.mapping_status.strip().lower() in ("done", "doing", "pending", "hoàn thành")]
               for g, its in groups.items()}
    hld_titles = {}
    for line in hld.read_text(encoding="utf-8-sig").splitlines():
        m = re.match(r"^#### Nhóm (\d+)\s*-\s*(.*)", line)
        if m:
            hld_titles[m.group(1)] = m.group(2)
    dm_rows = collections.defaultdict(list)
    for r in csv.DictReader(open(dm, encoding="utf-8-sig")):
        m = RE_NHOM.match(r["nhom"])
        if m:
            dm_rows[m.group(1)].append(r)
    only = set(args.nhom or [])
    sel = lambda g: not only or g in only

    # ---------- S2
    print("S2 [L1-BA-STT-COLLISION / L1-BA-ROW-MISPLACED]")
    majority = {}
    for g, its in groups.items():
        c = collections.Counter(screen_key(x.dashboard) for x in its if x.dashboard)
        if c:
            majority[g] = c.most_common(1)[0][0]
    n2 = 0
    for g, its in groups.items():
        if not g.isdigit() or not sel(g):
            continue
        c = collections.Counter(screen_key(x.dashboard) for x in its if x.dashboard)
        for scr, cnt in c.items():
            if scr == majority[g]:
                continue
            lines = [x.line_num for x in its if screen_key(x.dashboard) == scr]
            owner = [h for h, s in majority.items() if s == scr and h != g]
            if cnt >= 3:
                errors.append(f"S2 STT {g}: {cnt} dòng (dòng {lines[0]}–{lines[-1]}) Dashboard khác khối chính — BA gộp 2 màn hình chung 1 STT: \"{scr[:70]}\"")
            elif owner:
                errors.append(f"S2 STT {g}: dòng {lines} có Dashboard của Nhóm {owner[0]} — BA gán nhầm STT (thiết kế theo Dashboard, ghi Open Issue)")
            else:
                warns.append(f"S2 STT {g}: dòng {lines} Dashboard lệch nhẹ khối chính (\"{scr[:60]}\") — đọc lại")
            n2 += 1
    for g in groups:
        if not g.isdigit():
            warns.append(f"S2 có {len(groups[g])} dòng BA không có STT hợp lệ (khóa '{g}') — dòng {[x.line_num for x in groups[g]][:5]}")
    print(f"   {n2} khối lệch")

    # ---------- S3
    print("S3 [L1-GROUP-NUMBER-DRIFT]")
    sba = {g for g in groups if g.isdigit() and ba_live.get(g)}
    shl, sdm = set(hld_titles), set(dm_rows)
    for name, s in (("HLD", shl), ("Detail Mapping", sdm)):
        miss, extra = sorted(sba - s, key=int), sorted(s - sba, key=int)
        if miss:
            errors.append(f"S3 BA có Nhóm {miss} nhưng {name} không có")
        if extra:
            warns.append(f"S3 {name} có Nhóm {extra} nhưng BA không có Nhóm đó (hoặc BA chưa có dòng Done/Doing/Pending)")
    for g in sorted(sba & shl, key=int):
        if not sel(g):
            continue
        ba_scr = groups[g][0].dashboard if groups[g] else ""
        tail = re.split(r">>|/", ba_scr)[-1]
        sc = max(name_score(ba_scr, hld_titles[g]), name_score(tail, hld_titles[g]))
        if sc < 0.35:
            warns.append(f"S3 Nhóm {g}: tên HLD \"{hld_titles[g][:60]}\" không giống màn hình BA \"{ba_scr[:60]}\" (score {sc:.2f}) — kiểm lệch số Nhóm")

    # ---------- S4 + S5
    print("S4/S5 [L3-BA-ROW-UNMAPPED / L3-MEASURE-TYPE-MISMATCH]")
    for g in sorted(sba & sdm, key=int):
        if not sel(g):
            continue
        kpis = collections.OrderedDict()
        for r in dm_rows[g]:
            if r["column_role"] == "DEPRECATED":
                continue
            kpis.setdefault(r["kpi_id"], []).append(r)
        cand = list(kpis.items())
        # ghép tối ưu toàn cục: xếp mọi cặp theo điểm, cùng loại measure +0.15, ngược loại −0.3
        pairs = []
        for i, x in enumerate(ba_live[g]):
            bname = x.name.split(chr(10))[0]
            bk = kind(x.name + " " + x.source_column)
            for j, (k, rs) in enumerate(cand):
                s = name_score(bname, rs[0]["kpi_name"])
                dk = kind(rs[0]["kpi_name"])
                if bk and dk:
                    s += 0.15 if bk == dk else -0.3
                pairs.append((s, i, j))
        pairs.sort(reverse=True)
        ui, uj, match = set(), set(), {}
        for s, i, j in pairs:
            if s < 0.5 or i in ui or j in uj:
                continue
            ui.add(i); uj.add(j); match[i] = (j, s)
        for i, x in enumerate(ba_live[g]):
            if i not in match:
                bs, bj = max(((s, jj) for s, ii, jj in pairs if ii == i), default=(0.0, None))
                hint = ""
                if bj is not None and bs >= 0.5:
                    hint = f" — ứng viên gần nhất {cand[bj][0]} \"{cand[bj][1][0]['kpi_name'][:40]}\" đã ghép với dòng BA khác (BA có 2 dòng cùng nghĩa, hoặc thiếu 1 KPI)"
                warns.append(f"S4 Nhóm {g} dòng BA {x.line_num} \"{x.name.split(chr(10))[0][:60]}\" [{x.classification}] — không ghép được KPI (best {bs:.2f}){hint}")
                continue
            k, rs = cand[match[i][0]]
            ba_kind = kind(x.name + " " + x.source_column)
            dm_text = " ".join(r["mart_column"] + " " + r["logic"] for r in rs)
            dm_kind = "VAL" if "_val" in dm_text and "_vol" not in dm_text else ("VOL" if "_vol" in dm_text and "_val" not in dm_text else "")
            if ba_kind and dm_kind and ba_kind != dm_kind:
                errors.append(f"S5 Nhóm {g} dòng BA {x.line_num} \"{x.name[:50]}\" đo {ba_kind} nhưng {k} \"{rs[0]['kpi_name']}\" đọc cột {dm_kind}")
        if len(ba_live[g]) > len(kpis):
            warns.append(f"S4 Nhóm {g}: BA {len(ba_live[g])} dòng > Detail Mapping {len(kpis)} KPI hiệu lực")

    print()
    for e in errors:
        print("❌", e)
    for w in warns:
        print("🟡", w)
    print(f"\nTỔNG: {len(errors)} lỗi, {len(warns)} cảnh báo")
    return 1 if (args.strict and errors) else 0


if __name__ == "__main__":
    sys.exit(main())
