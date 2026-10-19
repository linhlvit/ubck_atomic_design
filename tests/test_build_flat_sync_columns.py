# -*- coding: utf-8 -*-
"""Hồi quy build_flat_tables.sync_columns (--sync-columns).

Lỗi gốc (2026-10-19, QLKD opr_individual_violation_hist): cột mới ở ĐẦU bảng bị chèn vào ngay dưới dòng
`INSERT INTO ...` (trước `SELECT`) vì regex projection khớp nhầm từ khóa `SELECT`.
"""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parents[1] / ".claude" / "skills" / "datamart-review" / "scripts"
sys.path.insert(0, str(SCRIPTS))

import build_flat_tables as bft  # noqa: E402

DDL = """CREATE TABLE IF NOT EXISTS datamart.m_t_flat ON CLUSTER 'my_cluster'
(
    -- From: T
    b_code                                       Nullable(String)        COMMENT 'b',
    c_code                                       Nullable(String)        COMMENT 'c'
)
ENGINE = ReplicatedReplacingMergeTree()
ORDER BY (b_code)
;
"""

DML = """TRUNCATE TABLE IF EXISTS datamart.m_t_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.m_t_flat
SELECT
    -- From: T
    f.b_code,
    f.c_code

FROM datamart.t f
;
"""


def _cols(*names):
    return [(n, "Text", True, n) for n in names]


class SyncColumnsTest(unittest.TestCase):
    def _run(self, order, ddl=DDL, dml=DML):
        return bft.sync_columns(ddl, dml, "m", {"t": _cols(*order)}, ["t"])

    def test_first_column_goes_into_select_list_not_insert_header(self):
        d, m, added, skipped = self._run(["a_code", "b_code", "c_code"])
        self.assertEqual(skipped, [])
        self.assertEqual([a[1] for a in added], ["a_code"])
        ml = m.split("\n")
        i_ins = next(i for i, x in enumerate(ml) if x.startswith("INSERT INTO"))
        self.assertEqual(ml[i_ins + 1], "SELECT")            # không có gì chen giữa INSERT và SELECT
        self.assertEqual(ml[i_ins + 2].strip(), "-- From: T")
        self.assertEqual(ml[i_ins + 3].strip(), "f.a_code,")  # cột đầu nằm đầu danh sách SELECT, có alias
        self.assertEqual(ml[i_ins + 4].strip(), "f.b_code,")
        dl = d.split("\n")
        k = next(i for i, x in enumerate(dl) if "a_code" in x)
        self.assertTrue(dl[k + 1].lstrip().startswith("b_code"))  # DDL: trước b_code, sau comment '-- From:'
        self.assertEqual(dl[k - 1].strip(), "-- From: T")

    def test_middle_and_last_column_keep_order_and_commas(self):
        d, m, added, _ = self._run(["b_code", "x_code", "c_code", "z_code"])
        self.assertEqual([a[1] for a in added], ["x_code", "z_code"])
        ml = [x.strip() for x in m.split("\n")]
        k = ml.index("f.b_code,")
        self.assertEqual(ml[k:k + 4], ["f.b_code,", "f.x_code,", "f.c_code,", "f.z_code"])
        dl = d.split("\n")
        self.assertTrue(next(x for x in dl if "c_code" in x).rstrip().endswith(","))
        self.assertFalse(next(x for x in dl if "z_code" in x).rstrip().endswith(","))

    def test_crlf_preserved(self):
        d, m, added, _ = self._run(["a_code", "b_code", "c_code"], DDL.replace("\n", "\r\n"), DML.replace("\n", "\r\n"))
        self.assertEqual(len(added), 1)
        self.assertEqual(m.count("\n"), m.count("\r\n"))
        self.assertEqual(d.count("\n"), d.count("\r\n"))

    def test_first_column_with_complex_first_projection(self):
        dml = DML.replace("    f.b_code,", "    COALESCE(f.b_code, '') AS b_code,")
        d, m, added, skipped = self._run(["a_code", "b_code", "c_code"], dml=dml)
        self.assertEqual(skipped, [])
        ml = [x.strip() for x in m.split("\n")]
        k = ml.index("SELECT")
        self.assertEqual(ml[k + 1:k + 4], ["-- From: T", "f.a_code,", "COALESCE(f.b_code, '') AS b_code,"])


if __name__ == "__main__":
    unittest.main()
