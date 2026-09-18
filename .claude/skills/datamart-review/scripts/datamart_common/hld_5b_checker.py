# -*- coding: utf-8 -*-
"""
datamart_common/hld_5b_checker.py — Bước 5B: self-check cấu trúc DTM_{MODULE}_HLD.md

Tự động hoá 14 mục (#0–#13) của Bước 5B trong skill `datamart-hld-design`.
Trước đây 14 mục này chỉ là checklist chữ — người/agent phải tự đọc mắt, nên thực tế
bị bỏ sót (PTTT 2026-09-18: Section 3 còn giữ Fact đã bãi bỏ và tên vật lý cũ trong khi
Section 1 & 5 đã tuyên bố Resolved; 18 khối erDiagram thiếu Source_System_Code;
36 Fact dùng `Snapshot_Date_Id` thay vì `Snapshot_Date_Dimension_Id`).

Dùng:
    from datamart_common.hld_5b_checker import audit_hld_5b, render_5b_report
"""

from __future__ import annotations

import collections
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import List, Optional


@dataclass
class Check:
    no: int
    code: str
    status: str            # PASS | FAIL | MANUAL
    detail: str = ""


@dataclass
class Hld5bResult:
    module: str
    path: Path
    checks: List[Check] = field(default_factory=list)

    @property
    def failed(self) -> List[Check]:
        return [c for c in self.checks if c.status == "FAIL"]

    @property
    def passed(self) -> bool:
        return not self.failed


SECTION_ORDER = ["Data Lineage", "Tổng quan báo cáo", "Mô hình tổng thể",
                 "Reuse Analysis", "Vấn đề mở"]
KPI_HEADER_7 = "| KPI ID | Tên KPI | Đơn vị | Tính chất | Công thức | Ghi chú | Trạng thái |"


def audit_hld_5b(hld_path: Path, module: str) -> Hld5bResult:
    T = hld_path.read_text(encoding="utf-8")
    lines = T.split("\n")
    res = Hld5bResult(module=module, path=hld_path)

    def add(no, code, ok, detail=""):
        res.checks.append(Check(no, code, "MANUAL" if ok is None else ("PASS" if ok else "FAIL"), detail))

    # ---- #0 Cấu trúc Section + bảng KPI 7 cột + heading Cụm ----
    secs = re.findall(r"^## Section (\d+) — (.+)$", T, re.M)
    ok_sec = len(secs) == 5 and all(SECTION_ORDER[i] in secs[i][1] for i in range(min(5, len(secs))))
    bad_cum = [l for l in lines if re.match(r"^#{1,4} Cụm \d", l)]
    nhom = len(re.findall(r"^#### Nhóm \d+", T, re.M))
    kpi7 = T.count(KPI_HEADER_7)
    add(0, "L1-SECTION-STRUCTURE", ok_sec and not bad_cum and kpi7 >= nhom,
        f"{len(secs)} Section, {nhom} Nhóm, {kpi7} bảng KPI 7 cột, {len(bad_cum)} heading Cụm sai cấp")

    er_blocks = re.findall(r"```mermaid\n\s*erDiagram\n(.*?)```", T, re.S)

    # ---- #1 entity trong quan hệ phải có block định nghĩa cùng khối ----
    miss = []
    for b in er_blocks:
        defined = set(re.findall(r"^\s{4}(\w+)\s*\{", b, re.M))
        for m in re.finditer(r"^\s*(\w+)\s*\|\|--o\{\s*(\w+)", b, re.M):
            miss += [e for e in m.groups() if e not in defined]
    add(1, "L1-ERD-MISSING-ENTITY-BLOCK", not miss, f"thiếu: {sorted(set(miss))[:5]}")

    # ---- #2 cấm Fact-to-Fact ----
    f2f = [f"{m.group(1)}->{m.group(2)}" for b in er_blocks
           for m in re.finditer(r"^\s*(\w+)\s*\|\|--o\{\s*(\w+)", b, re.M)
           if m.group(1).startswith("Fact")]
    add(2, "L1-FACT-TO-FACT-RELATION", not f2f, f"{f2f[:3]}")

    # ---- #3 Dimension phải có Source_System_Code ----
    nosrc = []
    for b in er_blocks:
        for m in re.finditer(r"^\s{4}(\w+)\s*\{\n(.*?)^\s{4}\}", b, re.M | re.S):
            if m.group(1).endswith("_Dimension") and "Source_System_Code" not in m.group(2):
                nosrc.append(m.group(1))
    add(3, "L1-MISSING-SOURCE-SYSTEM-CODE", not nosrc, f"{sorted(set(nosrc))[:5]}")

    # ---- #4/#5/#6 flowchart Section 1 ----
    s1 = T.split("## Section 2")[0]
    fcs = re.findall(r"```mermaid\n\s*flowchart LR\n(.*?)```", s1, re.S)
    bad4 = [i for i, f in enumerate(fcs)
            if not ('SRC["Staging"]' in f and 'SIL["Atomic"]' in f and 'GOLD["Datamart"]' in f)]
    add(4, "L1-FLOWCHART-3-SUBGRAPHS", not bad4, f"{len(fcs)} flowchart, lỗi idx {bad4[:5]}")

    bad5 = []
    for i, f in enumerate(fcs):
        g = re.search(r"subgraph GOLD\[.*?\]\n(.*?)\n    end", f, re.S)
        if not g:
            bad5.append((i, "thiếu subgraph GOLD"))
            continue
        labels = re.findall(r'^\s*\w+\["?(.*?)"?\]\s*$', g.group(1), re.M)
        marts = [n for n in labels if "Dimension" not in n]
        if len(marts) != 1:
            bad5.append((i, marts))
    add(5, "L1-CLUSTER-MULTIPLE-MARTS", not bad5, f"{bad5[:4]}")

    dots = re.findall(r"^\s*(\w+\.\w+)\[", s1, re.M)
    add(6, "L1-STAGING-NODE-DOT-SYNTAX", not dots, f"{dots[:5]}")

    # ---- #7 code fence cân bằng ----
    nf = len(re.findall(r"^```", T, re.M))
    add(7, "L1-UNBALANCED-CODE-FENCE", nf % 2 == 0, f"{nf} fence")

    # ---- #8 KPI_ID: cấm trùng khai sinh; dải rời rạc chỉ cảnh báo nếu chưa giải trình ----
    ids = sorted({int(x) for x in re.findall(rf"K_{re.escape(module)}_(\d+)", T)})
    gaps = [i for i in range(1, max(ids) + 1) if i not in ids] if ids else []
    documented = bool(re.search(r"(quy ước|đánh số|numbering).{0,120}(số dòng BA|BA row)", T, re.I | re.S))
    add(8, "L1-DUPLICATE-KPI-ID", (not gaps) or documented,
        f"max={max(ids) if ids else 0}, {len(gaps)} ID trống"
        + ("" if not gaps else " — cần ghi chú quy ước đánh số trong HLD nếu là cố ý"))

    add(9, "L1-ATOMIC-SOURCE-NOT-FOUND", None, "dùng check_references.py (Gate 0)")
    add(10, "L1-COUNT-DELTA-MISMATCH", None, "dùng datamart_progress_analyzer.py")

    # ---- #11 block cùng tên phải giống hệt ----
    blocks = collections.defaultdict(set)
    for m in re.finditer(r"^\s{4}(\w+)\s*\{\n(.*?)^\s{4}\}", T, re.M | re.S):
        blocks[m.group(1)].add(tuple(sorted(x.strip() for x in m.group(2).strip().split("\n"))))
    inc = [n for n, v in blocks.items() if len(v) > 1]
    add(11, "L1-INCONSISTENT-ENTITY-BLOCKS", not inc, f"{inc}")

    add(12, "L1-READY-MEASURE-MISSING-FROM-ERD", None, "rà thủ công theo Nhóm vừa sửa")

    # ---- #13 Role-Playing Date FK ----
    viol = []
    for b in er_blocks:
        for m in re.finditer(r"^\s{4}(Fact_\w+)\s*\{\n(.*?)^\s{4}\}", b, re.M | re.S):
            name, body = m.group(1), m.group(2)
            if "Calendar_Date_Dimension_Id" in body:
                viol.append(f"{name}: dùng Calendar_Date_Dimension_Id generic")
            if re.search(r"\bSnapshot_Date_Id\b", body):
                viol.append(f"{name}: Snapshot_Date_Id (thiếu _Dimension)")
            if name.endswith("_Snapshot") and "Snapshot_Date_Dimension_Id" not in body:
                viol.append(f"{name}: thiếu Snapshot_Date_Dimension_Id")
    add(13, "L1-DATE-FK-VIOLATION", not viol, f"{sorted(set(viol))[:6]}")

    return res


def render_5b_report(res: Hld5bResult) -> str:
    L = ["=" * 78,
         f" BƯỚC 5B SELF-CHECK — {res.path.name} (14 mục #0–#13)",
         "=" * 78]
    for c in res.checks:
        L.append(f"#{c.no:<2} [{c.code}] {c.status}  {c.detail}")
    L += ["=" * 78, f"TỔNG: {len(res.failed)} mục FAIL"]
    return "\n".join(L)
