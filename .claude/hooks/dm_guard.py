# -*- coding: utf-8 -*-
"""
dm_guard.py — PreToolUse hook bảo vệ artifact thiết kế Datamart (2026-10-15).

Biến các QUY TẮC CỨNG trong CLAUDE.md thành chốt chặn máy (không phụ thuộc agent nhớ rule):

  R1  Read trực tiếp 4 nhóm file lớn (BA_analyst_*.csv, DTM_*_HLD.md, DTM_*_Detail_Mapping.csv,
      datamart_attributes.csv) → DENY, trừ khi đọc 1 cửa sổ nhỏ (limit ≤ 300 dòng).
      → dùng ba_slice.py / ctx_slice.py / grep.
  R2  Edit/Write/MultiEdit lên file ĐÃ TỒN TẠI thuộc 4 nhóm trên → DENY.
      → dùng apply_patch.py / apply_kpi_patch.py (--dry-run trước). Write file MỚI (module mới) vẫn cho.
  R3  Pipe output của gate/analyzer/apply_patch qua `| tail` / `| head` → DENY.
      Sự cố thật: GSTT 2026-09-22 (bảng delta bị cắt), K_QLQ_45 (diff --dry-run bị cắt).
  R4  `git checkout -- / git restore / git reset --hard / git stash` chạm file thiết kế → ASK.
      Sự cố thật: QLQ 2026-10-14 "khôi phục" nhầm Detail Mapping bị user chủ động cắt.
  R5  Cờ phá chốt chặn (--allow-shrink / --allow-drop / --fix-order) → ASK.

Tắt tạm (human chủ động): đặt biến môi trường DM_GUARD=off trước khi mở phiên.
Input: JSON PreToolUse trên stdin. Output: JSON hookSpecificOutput.permissionDecision (deny/ask) hoặc im lặng.
"""
from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path

PROTECTED = [
    (re.compile(r"(^|/)BRD/BA/BA_analyst_[^/]+\.csv$", re.I), "BA analyst",
     "ba_slice.py --module {M} --index rồi --nhom {N} --print"),
    (re.compile(r"(^|/)Datamart/hld/DTM_[^/]+_HLD\.md$", re.I), "HLD Datamart",
     "ctx_slice.py --module {M} --sections / --nhom {N}"),
    (re.compile(r"(^|/)Datamart/lld/DTM_[^/]+_Detail_Mapping\.csv$", re.I), "Detail Mapping",
     "ctx_slice.py --module {M} --nhom {N}; lld_selfcheck.py cho toàn module"),
    (re.compile(r"(^|/)Datamart/lld/datamart_attributes\.csv$", re.I), "master registry",
     "grep, hoặc file per-table trong Datamart/lld/{M}/"),
]
READ_WINDOW_MAX = 300

GATE_SCRIPTS = (r"datamart_progress_analyzer|apply_patch|apply_kpi_patch|ba_hld_sync_check|"
                r"run_quality_gates|check_references|check_orphan|check_parity|lld_selfcheck|build_registry")
# cùng 1 lệnh (dừng ở ; hoặc &&, nhưng vẫn khớp khi có 2>&1)
RE_TRUNCATE = re.compile(rf"({GATE_SCRIPTS})\.py\b(?:(?!&&)[^\n;])*\|\s*(tail|head)\b", re.I)
DESIGN_PATHS = r"(Datamart/|BRD/|DataModel/|system/rules/)"
RE_GIT_RESTORE = re.compile(
    rf"\bgit\s+(checkout\s+(\S+\s+)?--\s+[^\n;&]*{DESIGN_PATHS}|restore\s+[^\n;&]*{DESIGN_PATHS}"
    rf"|reset\s+--hard|stash(\s|$)|checkout\s+--\s+\.|clean\s+-[a-z]*f)", re.I)
RE_BYPASS_FLAG = re.compile(r"\.py\b[^\n;&]*\s--(allow-shrink|allow-drop|fix-order)\b", re.I)


def _decide(decision: str, reason: str) -> None:
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": decision,
        "permissionDecisionReason": reason,
    }}, ensure_ascii=True))
    sys.exit(0)


def _rel(p: str) -> str:
    s = p.replace("\\", "/")
    root = (os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()).replace("\\", "/").rstrip("/")
    if root and s.lower().startswith(root.lower() + "/"):
        s = s[len(root) + 1:]
    return s


def _protected(rel: str):
    for rx, label, alt in PROTECTED:
        if rx.search(rel):
            return label, alt
    return None


def main() -> None:
    if os.environ.get("DM_GUARD", "").lower() == "off":
        return
    try:
        data = json.load(sys.stdin)
    except Exception:
        return
    tool = data.get("tool_name", "")
    ti = data.get("tool_input") or {}

    if tool in ("Read", "Edit", "Write", "MultiEdit", "NotebookEdit"):
        path = ti.get("file_path") or ti.get("notebook_path") or ""
        if not path:
            return
        rel = _rel(path)
        hit = _protected(rel)
        if not hit:
            return
        label, alt = hit
        if tool == "Read":
            limit = ti.get("limit")
            if isinstance(limit, int) and 0 < limit <= READ_WINDOW_MAX:
                return
            _decide("deny",
                    f"[dm_guard R1] Không Read nguyên file {label} ({rel}) — CLAUDE.md 'TRẦN NGỮ CẢNH 500K'. "
                    f"Dùng: {alt}. (Cửa sổ nhỏ limit ≤ {READ_WINDOW_MAX} dòng thì được.)")
        if tool == "Write" and not Path(path).exists():
            return  # tạo file mới (module mới) — cho phép
        _decide("deny",
                f"[dm_guard R2] Không {tool} tay file {label} ({rel}). Ghi qua apply_patch.py "
                f"(nguyên khối Nhóm) hoặc apply_kpi_patch.py (thêm 1 KPI) với --dry-run trước. "
                f"Lý do: sửa tay file lớn từng sinh Nhóm trùng / phá thứ tự TC6 / mất dòng.")

    if tool in ("Bash", "PowerShell"):
        cmd = ti.get("command") or ""
        if RE_TRUNCATE.search(cmd):
            _decide("deny",
                    "[dm_guard R3] Không cắt output gate/analyzer/apply_patch bằng tail/head — bảng delta và "
                    "diff --dry-run nằm giữa output (sự cố GSTT 2026-09-22, K_QLQ_45). Lọc đích danh bằng "
                    "grep \"Nhóm N \" hoặc dùng run_quality_gates.py --nhom N.")
        if RE_GIT_RESTORE.search(cmd.replace("\\", "/")):
            _decide("ask",
                    "[dm_guard R4] Lệnh git này có thể ghi đè file thiết kế. Trước khi khôi phục: đọc MEMORY.md "
                    "(cắt chủ ý?), xem mtime (phiên khác đang ghi?), và hỏi human (sự cố QLQ 2026-10-14).")
        if RE_BYPASS_FLAG.search(cmd):
            _decide("ask",
                    "[dm_guard R5] Cờ này vượt chốt chặn mất dữ liệu (--allow-shrink/--allow-drop) hoặc ghi đè "
                    "thứ tự Detail Mapping (--fix-order). Chỉ chạy khi human đã duyệt rõ.")


if __name__ == "__main__":
    main()
