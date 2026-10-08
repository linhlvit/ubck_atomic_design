# -*- coding: utf-8 -*-
"""
tests/test_challenger_r3_1_adversarial.py — Empirical Adversarial Challenge Suite
Role: challenger_r3_1 (teamwork_preview_challenger)

Adversarially validates:
1. YAML Model Integrity (Duplicate key AST loader, mandatory keys, column types, VP entities).
2. ClickHouse Flat Tables (Gate 4 compliance, 1:1 projection match, parameterization, engine syntax).
3. Workspace Parity & Catalog Integrity (byte-for-byte parity, verify scripts, KPI Index alignment).
"""
import csv
import filecmp
from pathlib import Path
import re
import subprocess
import sys
import unittest
import yaml

REPO_ROOT = Path(__file__).resolve().parents[1]
WORKSPACE_ROOT = REPO_ROOT.parent

# Custom YAML loader to detect duplicate keys
class DuplicateKeyError(Exception):
    pass

def dict_constructor(loader, node):
    mapping = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=False)
        if key in mapping:
            raise DuplicateKeyError(f"Duplicate mapping key '{key}' at line {key_node.start_mark.line}")
        mapping[key] = loader.construct_object(value_node, deep=False)
    return mapping

StrictSafeLoader = yaml.SafeLoader
StrictSafeLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, dict_constructor)


class TestAdversarialYamlModel(unittest.TestCase):
    """Challenge 1: YAML Model Integrity & Schema Validation."""

    @classmethod
    def setUpClass(cls):
        cls.yaml_path = REPO_ROOT / "Datamart" / "datamart_model.yaml"
        with open(cls.yaml_path, "r", encoding="utf-8") as f:
            cls.model = yaml.load(f, Loader=StrictSafeLoader)
        cls.entities = cls.model.get("entities", [])
        cls.vp_entities = [e for e in cls.entities if e.get("module") == "VP"]

    def test_01_no_duplicate_keys_in_entire_yaml(self):
        """StrictSafeLoader parses the entire datamart_model.yaml without DuplicateKeyError."""
        self.assertGreater(len(self.entities), 0)

    def test_02_all_entities_contain_mandatory_keys(self):
        """Every entity has mandatory structural metadata."""
        mandatory_keys = {"id", "logical_name", "datamart_table", "table_type", "module", "status", "columns"}
        for e in self.entities:
            tbl = e.get("datamart_table", "UNKNOWN")
            for k in mandatory_keys:
                self.assertIn(k, e, f"Entity {tbl} missing mandatory key '{k}'")
                self.assertTrue(e[k], f"Entity {tbl} has empty value for '{k}'")

    def test_03_vp_entities_count_and_physical_names(self):
        """VP module must have 7 registered entities including newly added OTC bond & share auction."""
        self.assertEqual(len(self.vp_entities), 7, f"Expected 7 VP entities, found {len(self.vp_entities)}")
        vp_tables = {e["datamart_table"] for e in self.vp_entities}
        expected_tables = {
            "fct_scr_mkt_indx_snpst",
            "fct_derv_tdg_snpst",
            "fct_derv_prc_snpst",
            "fct_lst_crp_bnd_snpst",
            "fct_lst_crp_bnd_indy_trm_snpst",
            "fct_otc_bnd_snpst",
            "fct_share_auction_snpst",
        }
        self.assertEqual(vp_tables, expected_tables)

    def test_04_vp_source_atomic_binding(self):
        """fct_otc_bnd_snpst and fct_share_auction_snpst must bind to internal_statistical_report."""
        otc = next(e for e in self.vp_entities if e["datamart_table"] == "fct_otc_bnd_snpst")
        auction = next(e for e in self.vp_entities if e["datamart_table"] == "fct_share_auction_snpst")
        
        self.assertIn("internal_statistical_report", otc["source_atomic"])
        self.assertIn("internal_statistical_report", auction["source_atomic"])

    def test_05_vp_column_schema_and_types(self):
        """Check column uniqueness, non-empty PK, and valid data types for VP entities."""
        valid_types = {"string", "int", "float", "date", "datetime", "boolean", "decimal"}
        for e in self.vp_entities:
            tbl = e["datamart_table"]
            cols = e.get("columns", [])
            self.assertGreater(len(cols), 0, f"Entity {tbl} has no columns")
            
            col_names = [c["physical_name"] for c in cols]
            self.assertEqual(len(col_names), len(set(col_names)), f"Duplicate columns in {tbl}: {col_names}")
            
            pks = [c for c in cols if c.get("key") == "PK"]
            self.assertGreaterEqual(len(pks), 1, f"No PK column defined in {tbl}")
            for pk in pks:
                self.assertFalse(pk.get("nullable", True), f"PK {pk['physical_name']} in {tbl} must be non-nullable")

            for c in cols:
                pname = c["physical_name"]
                dtype = c.get("data_type", "").lower()
                self.assertIn(dtype, valid_types, f"Invalid data_type '{dtype}' in {tbl}.{pname}")
                self.assertIn("logical_name", c, f"Missing logical_name in {tbl}.{pname}")


class TestAdversarialClickhouseFlatTables(unittest.TestCase):
    """Challenge 2: ClickHouse Flat Tables (Gate 4 Compliance, DDL/DML Alignment)."""

    def test_01_gate4_audit_module_vp_programmatic(self):
        """audit_module_flat_table(REPO_ROOT, 'VP') passes Gate 4 with 0 issues."""
        sys.path.insert(0, str(REPO_ROOT / ".claude" / "skills" / "datamart-review" / "scripts"))
        from datamart_flat_table_checker import audit_module_flat_table
        res = audit_module_flat_table(REPO_ROOT, "VP")
        self.assertEqual(res.status, "PASS")
        self.assertEqual(res.critical_count, 0)
        self.assertEqual(res.warning_count, 0)
        self.assertEqual(res.total_tables_ddl, 2)
        self.assertEqual(res.total_tables_dml, 2)

    def test_02_sql_files_multi_location_parity(self):
        """Flat table SQL files in Datamart/flat-table/ and Datamart/flat-table/VP/ must be identical."""
        f1_root = REPO_ROOT / "Datamart" / "flat-table" / "01_create_vp_flat_tables.sql"
        f1_vp = REPO_ROOT / "Datamart" / "flat-table" / "VP" / "01_create_vp_flat_tables.sql"
        f2_root = REPO_ROOT / "Datamart" / "flat-table" / "02_populate_vp_flat_tables.sql"
        f2_vp = REPO_ROOT / "Datamart" / "flat-table" / "VP" / "02_populate_vp_flat_tables.sql"

        self.assertTrue(filecmp.cmp(f1_root, f1_vp, shallow=False), "01_create_vp_flat_tables.sql desynchronized")
        self.assertTrue(filecmp.cmp(f2_root, f2_vp, shallow=False), "02_populate_vp_flat_tables.sql desynchronized")

    def test_03_exact_1_to_1_projection_match(self):
        """Verify exact 1:1 column projection order and name match between CREATE and INSERT SELECT."""
        ddl_file = REPO_ROOT / "Datamart" / "flat-table" / "VP" / "01_create_vp_flat_tables.sql"
        dml_file = REPO_ROOT / "Datamart" / "flat-table" / "VP" / "02_populate_vp_flat_tables.sql"

        with open(ddl_file, "r", encoding="utf-8") as f:
            ddl_text = f.read()
        with open(dml_file, "r", encoding="utf-8") as f:
            dml_text = f.read()

        # Parse DDL columns
        ddl_tables = {}
        for m in re.finditer(r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?([a-zA-Z0-9_\.]+)[^(]*\((.*?)\)\s*ENGINE", ddl_text, re.DOTALL | re.IGNORECASE):
            tbl = m.group(1).strip()
            cols = [line.strip().rstrip(",").split()[0] for line in m.group(2).splitlines() if line.strip() and not line.strip().startswith("--")]
            ddl_tables[tbl] = cols

        # Parse DML columns
        dml_tables = {}
        for m in re.finditer(r"INSERT\s+INTO\s+([a-zA-Z0-9_\.]+)\s+SELECT\s+(.*?)\s+FROM\s+", dml_text, re.DOTALL | re.IGNORECASE):
            tbl = m.group(1).strip()
            cols = [line.strip().rstrip(",").split()[-1].split(".")[-1] for line in m.group(2).splitlines() if line.strip() and not line.strip().startswith("--")]
            dml_tables[tbl] = cols

        self.assertEqual(set(ddl_tables.keys()), set(dml_tables.keys()))
        for tbl in ddl_tables:
            self.assertEqual(ddl_tables[tbl], dml_tables[tbl], f"Column projection mismatch in table {tbl}")

    def test_04_parameterization_and_engine(self):
        """Check :etl_date parameterization, ReplicatedReplacingMergeTree engine and PARTITION BY."""
        ddl_file = REPO_ROOT / "Datamart" / "flat-table" / "VP" / "01_create_vp_flat_tables.sql"
        dml_file = REPO_ROOT / "Datamart" / "flat-table" / "VP" / "02_populate_vp_flat_tables.sql"

        ddl = ddl_file.read_text(encoding="utf-8")
        dml = dml_file.read_text(encoding="utf-8")

        self.assertIn(":etl_date", dml)
        self.assertIn("ReplicatedReplacingMergeTree()", ddl)
        self.assertIn("PARTITION BY toYYYYMM(assumeNotNull(cdr_dt))", ddl)
        self.assertIn("TRUNCATE TABLE IF EXISTS datamart.vp_fact_share_auction_snapshot_flat", dml)


class TestAdversarialCatalogAndParity(unittest.TestCase):
    """Challenge 3: Catalog Integrity, Workspace Parity & KPI Index Alignment."""

    def test_01_catalog_parity(self):
        """Root docs/datamart_data_source_catalog.md and ubck_atomic_design/docs/... are 100% byte identical."""
        c1 = WORKSPACE_ROOT / "docs" / "datamart_data_source_catalog.md"
        c2 = REPO_ROOT / "docs" / "datamart_data_source_catalog.md"
        self.assertTrue(filecmp.cmp(c1, c2, shallow=False), "Catalog desynchronization detected")

    def test_02_feasibility_matrix_parity(self):
        """Root docs/datamart_11_subsystems_feasibility_matrix.md and ubck_atomic_design/docs/... are identical."""
        m1 = WORKSPACE_ROOT / "docs" / "datamart_11_subsystems_feasibility_matrix.md"
        m2 = REPO_ROOT / "docs" / "datamart_11_subsystems_feasibility_matrix.md"
        self.assertTrue(filecmp.cmp(m1, m2, shallow=False), "Feasibility matrix desynchronization detected")

    def test_03_verify_catalog_script_passes(self):
        """verify_catalog.py runs successfully with exit code 0."""
        cmd = [sys.executable, str(REPO_ROOT / "scripts" / "verify_catalog.py")]
        res = subprocess.run(cmd, cwd=str(REPO_ROOT), capture_output=True, text=True, encoding="utf-8", errors="replace")
        self.assertEqual(res.returncode, 0, f"verify_catalog.py failed: {res.stderr or res.stdout}")
        self.assertIn("Overall Status  : PASS", res.stdout)

    def test_04_test_catalog_adversarial_passes(self):
        """test_catalog_adversarial.py runs successfully with exit code 0."""
        cmd = [sys.executable, str(REPO_ROOT / "scripts" / "test_catalog_adversarial.py")]
        res = subprocess.run(cmd, cwd=str(REPO_ROOT), capture_output=True, text=True, encoding="utf-8", errors="replace")
        self.assertEqual(res.returncode, 0, f"test_catalog_adversarial.py failed: {res.stderr or res.stdout}")
        self.assertIn("RESULTS SUMMARY: 32 Passed | 0 Warnings | 0 Errors", res.stdout)

    def test_05_vp_kpi_index_counts_and_unblocking(self):
        """KPI Index must have 149 VP rows, with unblocked Groups 11-13 (K_VP_48-57) and Group 43 (K_VP_144-149) as READY."""
        kpi_csv = REPO_ROOT / "Datamart" / "index" / "kpi_index.csv"
        with open(kpi_csv, "r", encoding="utf-8") as f:
            rows = [r for r in csv.DictReader(f) if r.get("module") == "VP"]

        self.assertEqual(len(rows), 149)
        kpi_map = {r["kpi_id"]: r for r in rows}

        # Groups 11-13 unblocked KPIs
        for i in range(48, 58):
            kid = f"K_VP_{i}"
            self.assertEqual(kpi_map[kid]["hld_status"], "READY", f"{kid} expected READY")
            self.assertEqual(kpi_map[kid]["mart_table"], "Fact OTC Bond Snapshot")

        # K_VP_58, 59 remain PENDING awaiting BM29
        self.assertEqual(kpi_map["K_VP_58"]["hld_status"], "PENDING")
        self.assertEqual(kpi_map["K_VP_59"]["hld_status"], "PENDING")

        # Group 43 auction unblocked KPIs
        for i in range(144, 150):
            kid = f"K_VP_{i}"
            self.assertEqual(kpi_map[kid]["hld_status"], "READY", f"{kid} expected READY")
            self.assertEqual(kpi_map[kid]["mart_table"], "Fact Share Auction Snapshot")

    def test_06_vp_hld_issues_closure(self):
        """Issues O_VP_3 and O_VP_4 must be marked Resolved in DTM_VP_HLD.md."""
        hld_text = (REPO_ROOT / "Datamart" / "hld" / "DTM_VP_HLD.md").read_text(encoding="utf-8")
        self.assertRegex(hld_text, r"O_VP_3.*Resolved")
        self.assertRegex(hld_text, r"O_VP_4.*Resolved")


if __name__ == "__main__":
    unittest.main()
