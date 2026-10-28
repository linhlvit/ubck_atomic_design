# -*- coding: utf-8 -*-
"""dm_guard R6 (2026-10-28): không đọc/grep BRD/BA/Old versions/ (BA bản cũ) trừ khi user chỉ đích danh — ASK; R1/R3 giữ nguyên."""
from __future__ import annotations

import json
import os
import subprocess
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GUARD = ROOT / ".claude" / "hooks" / "dm_guard.py"


def decide(tool, **ti):
    env = dict(os.environ, CLAUDE_PROJECT_DIR=str(ROOT))
    env.pop("DM_GUARD", None)
    r = subprocess.run([sys.executable, str(GUARD)], input=json.dumps({"tool_name": tool, "tool_input": ti}),
                       capture_output=True, text=True, env=env, encoding="utf-8")
    return json.loads(r.stdout)["hookSpecificOutput"]["permissionDecision"] if r.stdout.strip() else None


class OldVersionsGuard(unittest.TestCase):
    def test_bash_names_old_versions(self):
        self.assertEqual(decide("Bash", command='ls "BRD/BA/Old versions/"'), "ask")

    def test_recursive_grep_on_dot_without_exclusion(self):
        self.assertEqual(decide("Bash", command='grep -rln "x" --include=*.csv .'), "ask")

    def test_recursive_grep_with_exclusion_ok(self):
        self.assertIsNone(decide("Bash", command='grep -rln "x" --exclude-dir="Old versions" .'))

    def test_rg_with_negated_glob_ok(self):
        self.assertIsNone(decide("Bash", command="rg -l x . -g '!**/Old versions/**'"))

    def test_scoped_grep_ok(self):
        self.assertIsNone(decide("Bash", command='grep -rn "sheet_code" Datamart/lld'))

    def test_read_old_versions(self):
        self.assertEqual(decide("Read", file_path=str(ROOT / "BRD" / "BA" / "Old versions" / "x.csv"), limit=50), "ask")

    def test_grep_tool_path_old_versions(self):
        self.assertEqual(decide("Grep", pattern="x", path=str(ROOT / "BRD" / "BA" / "Old versions")), "ask")

    def test_grep_tool_scoped_ok(self):
        self.assertIsNone(decide("Grep", pattern="x", path=str(ROOT / "Datamart")))

    def test_glob_old_versions(self):
        self.assertEqual(decide("Glob", pattern="BRD/BA/Old versions/*.csv"), "ask")


class ExistingRulesStillHold(unittest.TestCase):
    def test_r3_tail_after_apply_patch_denied(self):
        self.assertEqual(decide("Bash", command="python x/apply_patch.py -m QLQ --quiet 2>&1 | tail -5"), "deny")

    def test_r1_read_whole_detail_mapping_denied(self):
        self.assertEqual(decide("Read", file_path=str(ROOT / "Datamart" / "lld" / "DTM_QLQ_Detail_Mapping.csv")), "deny")


if __name__ == "__main__":
    unittest.main()
