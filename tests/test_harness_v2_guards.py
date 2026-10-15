# -*- coding: utf-8 -*-
"""
tests/test_harness_v2_guards.py — Golden test cho nâng cấp Harness Datamart 2026-10-15.

Chỉ dùng dữ liệu SYNTHETIC trong thư mục tạm — không đọc/ghi artifact thiết kế thật.
  1. clean_description.clean()/find_leaks(): ghi chú nội bộ không lọt ra tài liệu TKCSLD.
  2. csv_io: giữ BOM khi ghi, guard_shrink, dropped_groups/guard_no_drop.
  3. build_registry.py: từ chối ghi khi sinh lại sẽ xóa trọn bảng (sự cố 26 bảng TKNB/VP).
  4. dm_guard.py (hook PreToolUse): deny/ask/allow đúng từng luật R1–R5.
  5. render_datamart_md.py: sinh TKCSLD đúng quy tắc C.4 trên 1 project synthetic.
"""
from __future__ import annotations

import csv
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REVIEW = ROOT / ".claude" / "skills" / "datamart-review" / "scripts"
GENDOCS = ROOT / ".claude" / "skills" / "datamart-gen-docs" / "scripts"
HOOK = ROOT / ".claude" / "hooks" / "dm_guard.py"
for p in (REVIEW, GENDOCS):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

from clean_description import clean, find_leaks  # noqa: E402
from datamart_common.csv_io import (  # noqa: E402
    DesignCsv, WriteGuardError, dropped_groups, guard_no_drop, guard_shrink, read_design_csv, write_design_csv)

LLD_HEADER = ["datamart_entity", "datamart_table", "datamart_attribute", "datamart_column", "nullable",
              "data_domain", "data_type", "key", "description", "etl_logic", "etl_logic_type",
              "source_entity", "atomic_table", "source_attribute", "atomic_column"]


def _write_csv(path: Path, header, rows, bom=False):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8-sig" if bom else "utf-8", newline="") as f:
        w = csv.writer(f, quoting=csv.QUOTE_ALL, lineterminator="\n")
        w.writerow(header)
        w.writerows(rows)


class TestCleanDescription(unittest.TestCase):
    CASES = [
        ("Khối lượng cổ phiếu niêm yết (K_GSDC_1382) [SỬA 2026-10-08] Small Counter/int → Large Counter/bigint",
         "Khối lượng cổ phiếu niêm yết"),
        ("[MỚI 2026-09-24, TKNB Nhóm 9 HNX12] Trái phiếu kèm chứng quyền (K_TKNB_569)", "Trái phiếu kèm chứng quyền"),
        ("Số lượng quỹ tại kỳ. Câu lệnh tham khảo BA (dòng 5) lọc thêm X — nhưng CHƯA được map. Tạm đếm không lọc",
         "Số lượng quỹ tại kỳ"),
        ("FK -> Calendar Date Dimension (vai trò: ngày snapshot thị trường)",
         "Khóa ngoại tới Calendar Date Dimension (vai trò: ngày snapshot thị trường)"),
        ("Khối lượng sở hữu nhà nước (K_GSDC_1389). [TÁCH 2026-10-08] Tách từ bảng cũ", "Khối lượng sở hữu nhà nước"),
        ("Tỷ lệ (%) [0-100]", "Tỷ lệ (%) [0-100]"),
    ]

    def test_golden(self):
        for raw, want in self.CASES:
            with self.subTest(raw=raw[:40]):
                self.assertEqual(clean(raw), want)
                self.assertEqual(find_leaks(clean(raw)), [])

    def test_find_leaks_detects(self):
        self.assertIn("trace_code", find_leaks("Tổng giá trị (K_QLQ_12)"))
        self.assertIn("change_note", find_leaks("Giá [SỬA 2026-01-01] x"))
        self.assertIn("process_note", find_leaks("Theo Câu lệnh tham khảo BA"))


class TestCsvIoGuards(unittest.TestCase):
    def test_bom_preserved_on_rewrite(self):
        with tempfile.TemporaryDirectory() as d:
            for bom in (True, False):
                p = Path(d) / f"x_{bom}.csv"
                _write_csv(p, ["a", "b"], [["1", "x,y"]], bom=bom)
                t = read_design_csv(p)
                t.rows.append(["2", "z"])
                write_design_csv(p, t)
                self.assertEqual(p.read_bytes()[:3] == b"\xef\xbb\xbf", bom)
                self.assertEqual(len(read_design_csv(p).rows), 2)

    def test_guard_shrink(self):
        guard_shrink("f", 100, 85, False)          # co 15% → cho
        guard_shrink("f", 30, 1, False)            # file nhỏ → không áp tỉ lệ
        guard_shrink("f", 100, 10, True)           # đã duyệt
        with self.assertRaises(WriteGuardError):
            guard_shrink("f", 100, 79, False)

    def test_dropped_groups(self):
        old = [["t1", "a"], ["t1", "b"], ["t2", "a"]]
        new = [["t1", "a"]]
        self.assertEqual(dropped_groups(old, new, 0), {"t2": 1})
        with self.assertRaises(WriteGuardError):
            guard_no_drop("m", {"t2": 1}, False)
        guard_no_drop("m", {"t2": 1}, True)


class TestBuildRegistryGuard(unittest.TestCase):
    def test_refuses_to_drop_table_without_per_module_file(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            (root / "CLAUDE.md").write_text("x", encoding="utf-8")
            row = lambda t, c: ["E " + t, t, c, c, "true", "Text", "string", "", "d", "", "direct", "", "", "", ""]  # noqa: E731
            _write_csv(root / "Datamart/lld/M1/DTM_M1_t1.csv", LLD_HEADER, [row("t1", "a")])
            master = root / "Datamart/lld/datamart_attributes.csv"
            _write_csv(master, LLD_HEADER, [row("t1", "a"), row("t_orphan", "x"), row("t_orphan", "y")])
            before = master.read_bytes()
            r = subprocess.run([sys.executable, str(REVIEW / "build_registry.py"), "--root", str(root)],
                               capture_output=True, text=True, encoding="utf-8")
            self.assertNotEqual(r.returncode, 0)
            self.assertIn("t_orphan", r.stdout + r.stderr)
            self.assertEqual(master.read_bytes(), before, "master không được bị ghi khi chốt chặn kích hoạt")


class TestDmGuardHook(unittest.TestCase):
    def _run(self, tool, ti, root):
        env = dict(os.environ, CLAUDE_PROJECT_DIR=str(root))
        env.pop("DM_GUARD", None)
        p = subprocess.run([sys.executable, str(HOOK)], input=json.dumps({"tool_name": tool, "tool_input": ti}),
                           capture_output=True, text=True, encoding="utf-8", env=env)
        self.assertEqual(p.returncode, 0, p.stderr)
        return json.loads(p.stdout)["hookSpecificOutput"]["permissionDecision"] if p.stdout.strip() else None

    def test_rules(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            dm = root / "Datamart/lld/DTM_X_Detail_Mapping.csv"
            dm.parent.mkdir(parents=True)
            dm.write_text("a\n", encoding="utf-8")
            per_table = str(root / "Datamart/lld/X/DTM_X_t.csv")
            cases = [
                ("Read", {"file_path": str(dm)}, "deny"),
                ("Read", {"file_path": str(dm), "limit": 100}, None),
                ("Edit", {"file_path": str(dm)}, "deny"),
                ("Write", {"file_path": str(root / "Datamart/hld/DTM_NEW_HLD.md")}, None),
                ("Edit", {"file_path": per_table}, None),
                ("Bash", {"command": "python s/datamart_progress_analyzer.py -m X | tail -30"}, "deny"),
                ("Bash", {"command": "python s/apply_patch.py -m X --dry-run 2>&1 | head -5"}, "deny"),
                ("Bash", {"command": "python s/datamart_progress_analyzer.py -m X | grep \"Nhóm 3 \""}, None),
                ("Bash", {"command": "git checkout -- Datamart/lld/DTM_X_Detail_Mapping.csv"}, "ask"),
                ("Bash", {"command": "git checkout main"}, None),
                ("Bash", {"command": "python s/build_registry.py --allow-drop"}, "ask"),
            ]
            for tool, ti, want in cases:
                with self.subTest(tool=tool, ti=str(ti)[-60:]):
                    self.assertEqual(self._run(tool, ti, root), want)


class TestRenderDatamartMd(unittest.TestCase):
    def test_render_synthetic_module(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            (root / "CLAUDE.md").write_text("x", encoding="utf-8")
            _write_csv(root / "Datamart/hld/DTM_ZZ_Entities.csv",
                       ["datamart_entity", "table_type", "reuse_status", "status", "description", "source_table", "FKs"],
                       [["Zone Dimension", "dim", "new", "draft", "Chiều vùng (K_ZZ_1)", "zone", ""],
                        ["Fact Zone Snapshot", "fact", "new", "draft", "Snapshot vùng", "zone",
                         "Zone Dimension.Zone Dimension Id"]])
            _write_csv(root / "Datamart/lld/ZZ/DTM_ZZ_zone_dim.csv", LLD_HEADER, [
                ["Zone Dimension", "zone_dim", "Zone Dimension Id", "zone_dim_id", "false", "Surrogate Key", "string",
                 "PK", "PK — Driving: zone", "", "Generated", "Generated", "", "", ""],
                ["Zone Dimension", "zone_dim", "Zone Name", "zone_nm", "true", "Text", "string", "",
                 "Tên vùng [SỬA 2026-10-01] đổi nguồn", "zone.zone_nm", "direct", "Zone", "zone", "Zone Name", "zone_nm"],
            ])
            _write_csv(root / "Datamart/lld/ZZ/DTM_ZZ_fct_zone_snpst.csv", LLD_HEADER, [
                ["Fact Zone Snapshot", "fct_zone_snpst", "Zone Dimension Id", "zone_dim_id", "false", "Surrogate Key",
                 "string", "FK → Zone Dimension", "FK -> Zone Dimension", "LOOKUP zone_dim", "lookup_dim",
                 "Zone Dimension", "zone_dim", "Zone Dimension Id", "zone_dim_id"],
            ])
            atm = root / "DataModel/working/Atomic/aggregate/atomic_attributes.yaml"
            atm.parent.mkdir(parents=True)
            atm.write_text('attributes:\n- atomic_table: "zone"\n  atomic_column: "zone_nm"\n  source_system: "SRC1"\n',
                           encoding="utf-8")
            r = subprocess.run([sys.executable, str(GENDOCS / "render_datamart_md.py"), "-m", "ZZ", "--root", str(root)],
                               capture_output=True, text=True, encoding="utf-8")
            self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
            md = (root / "docs/output/datamart/ZZ/DTM_ZZ_TKCSLD.md").read_text(encoding="utf-8")
            self.assertIn("ZONE_DIMENSION ||--o{ FACT_ZONE_SNAPSHOT", md)
            self.assertIn("| 1 | zone_dim_id | string |  | X | P |  | Khóa đại diện |  |  |  | ETL sinh tự động |", md)
            self.assertIn("| 2 | zone_nm | string | X |  |  |  | Tên vùng | SRC1 | ATM.zone | zone_nm | zone.zone_nm |", md)
            self.assertIn("| Datamart | DTM.zone_dim | zone_dim_id | LOOKUP zone_dim |", md)   # lineage mart→mart
            self.assertNotIn("K_ZZ_1", md)
            self.assertNotIn("[SỬA", md)
            # chạy lần 2 không ghi đè bản đã có
            subprocess.run([sys.executable, str(GENDOCS / "render_datamart_md.py"), "-m", "ZZ", "--root", str(root)],
                           capture_output=True, text=True, encoding="utf-8")
            self.assertTrue((root / "docs/output/datamart/ZZ/DTM_ZZ_TKCSLD.rendered.md").is_file())


if __name__ == "__main__":
    unittest.main()
