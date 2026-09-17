# Comprehensive E2E Testing Infrastructure (`TEST_INFRA.md`)
## Quality Gatekeeping & Verification Architecture for Datamart Review

- **Author**: E2E Test Writer 1 (`teamwork_preview_test_writer`)
- **Version**: 1.0.0
- **Workspace Root**: `C:\Workspace\Design_DW\ubck_atomic_design\`
- **Target Subsystem**: `.claude/skills/datamart-review/`
- **Specification Source**: `ORIGINAL_REQUEST.md`, `PROJECT.md`, `explorer_survey_2/survey_report.md`, `explorer_survey_3_r1/survey_report.md`

---

## 1. Executive Summary & Testing Philosophy

The `datamart-review` skill serves as the primary automated quality guardian across the entire Datamart lifecycle (BA ↔ HLD ↔ LLD ↔ Flat Table). The mission of this End-to-End (E2E) Testing Infrastructure is to guarantee that all automated audit scripts and technical review rules operate with **100% precision, zero false positives, robust encoding resilience on Windows, and strict adherence to architectural contracts**.

### Core Testing Principles:

1. **Progressive Testability**:
   - Tests are strictly decoupled into independent layers.
   - Ground truth invariants of the repository are verifiable immediately, while CLI and engine integration tests adapt gracefully across implementation milestones (M0 → M2 → M4).
2. **Authoritative Ground Truth (Empirical Reference)**:
   - Rather than relying solely on synthetic mocks, the test suite derives expected outputs directly from the production repository artifacts across `Datamart/lld/`, `Datamart/hld/`, `Datamart/flat-table/`, and `BRD/BA/`.
   - Positive and negative controls are anchored to empirical real-world conditions (`TKNB` as 100% clean negative control, `GSTT` as Branch B orphan + registry desync positive control, `QLCB` as entity normalization + etl_logic diff positive control).
3. **Dual Validation Strategy**:
   - **Layer A (Direct Data Invariant Tests)**: Validates that ground-truth invariants in the repository are recognized and mathematically consistent with survey baselines.
   - **Layer B (Automation Tool Integration Tests)**: Exercises the actual Python engines (`orphan_checker.py`, `parity_checker.py`, `datamart_date_fk_checker.py`, `datamart_progress_analyzer.py`) and CLI entrypoints to verify output contracts, exit codes, and JSON reporting.
4. **Zero External Dependencies (Standard Library Native)**:
   - The test infrastructure runs natively on Python 3.9+ using standard libraries (`unittest`, `pathlib`, `csv`, `json`, `subprocess`, `tempfile`, `re`).
   - Runs out-of-the-box on Windows without requiring `pip install` or external test packages.
5. **Adversarial & Environment Hardening**:
   - UTF-8 with BOM (`\xef\xbb\xbf`) and duplicate BOM (`\ufeff\ufeff`).
   - Dynamic delimiters: Comma (`,`) vs Semicolon (`;`).
   - Multi-line `etl_logic` strings containing complex SQL (`CASE WHEN`, `JOIN`, subqueries, unquoted commas).
   - Line ending variations (`\r\n` CRLF vs `\n` LF).
   - Python CSV 128KB field size limit on Windows expanded to 2GB (`csv.field_size_limit(2147483647)`).
   - Windows console stream encoding safety (`sys.stdout.reconfigure(encoding="utf-8")`).
6. **Strict Read-Only Discipline**:
   - Tests **never** mutate production files, git tracking, or master registries during execution.
   - All write-based test cases use isolated temporary directories (`tempfile.TemporaryDirectory`).

---

## 2. The 4-Tier Testing Methodology

The test suite is partitioned into four structured tiers, moving from granular feature units to real-world integration workloads:

```
+-------------------------------------------------------------------------------+
|                       TIER 4: REAL-WORLD WORKLOADS                           |
|       - TKNB: Negative Control (100% Clean Match, 22 Entities, 0 Discrepancy) |
|       - GSTT: Positive Control (Branch B Orphans + Missing Master Row)        |
|       - QLCB: Positive Control (Entity Suffix Normalization + ETL Logic Diff) |
+-------------------------------------------------------------------------------+
                                        ^
                                        |
+-------------------------------------------------------------------------------+
|                   TIER 3: CROSS-FEATURE COMBINATIONS                          |
|       - CLI Flag Permutations (--strict + --json, -o + --strict)              |
|       - Flag Precedence (--warn-only overrides --strict)                      |
|       - Repository-Wide Execution (--module all with mixed , and ;)           |
|       - Sequential Quality Pipeline (Date FK -> Orphan -> Parity)             |
+-------------------------------------------------------------------------------+
                                        ^
                                        |
+-------------------------------------------------------------------------------+
|                    TIER 2: BOUNDARY & CORNER CASES                            |
|       - Empty files (0-byte, header-only, empty SQL DDL)                      |
|       - UTF-8 BOM, no-BOM, duplicate BOM (\ufeff\ufeff)                       |
|       - Delimiter Sniffing (comma vs semicolon mode consistency)              |
|       - Multi-line SQL / etl_logic cells with 35+ unquoted commas            |
|       - Line Endings (CRLF vs LF normalization)                               |
|       - Non-existent modules & missing master files (Exit code 2)             |
+-------------------------------------------------------------------------------+
                                        ^
                                        |
+-------------------------------------------------------------------------------+
|                        TIER 1: FEATURE COVERAGE                               |
|       - Feature 5 & 7: 3-Way Orphan Checker Engine & CLI Happy Paths          |
|       - Feature 6 & 8: ETL Logic Parity Checker Engine & CLI Happy Paths      |
|       - Feature 3 & 4: Branch A/B Protocol & Master Registry Protection Rules |
|       - Feature 9: Date FK Checker & Progress Analyzer Backward Compatibility |
+-------------------------------------------------------------------------------+
```

### 2.1 Tier 1: Feature Coverage (Unit & Interface Contracts)
- **Target File**: `tests/test_e2e_tier1_features.py`
- **Objective**: Verify that every individual feature (F1–F9) satisfies its interface contract under standard, expected conditions.
- **Key Test Scenarios**:
  - `test_01_orphan_checker_contract_clean_fact_table`: Tests 3-way alignment where LLD table, HLD entity, and Flat Table SQL match cleanly -> Expected Status: `PASS`.
  - `test_02_orphan_checker_dimension_filtering`: Verifies that dimension entities (`table_type='dim'`) are excluded from flat table requirements and do NOT produce false positive orphans.
  - `test_03_orphan_checker_conformed_reuse_handling`: Verifies that entities with `reuse_status in ('reuse', 'partial', 'conformed')` are recognized as owned by upstream modules without being flagged as missing.
  - `test_04_orphan_checker_branch_a_incomplete_detection`: Verifies that an entity required by active KPIs but lacking LLD or Flat Table SQL is categorized as `BRANCH_A` (Action: complete missing artifacts).
  - `test_05_orphan_checker_branch_b_deprecated_detection`: Verifies that a deprecated entity with 0 active KPIs is categorized as `BRANCH_B` (Action: all-tier cleanup).
  - `test_06_parity_checker_contract_clean_match`: Verifies that identical module CSV and master registry rows yield status `PASS` with 0 mismatches.
  - `test_07_parity_checker_missing_in_master_detection`: Verifies that an attribute in module CSV absent from master registry is flagged as `MISSING_IN_MASTER`.
  - `test_08_parity_checker_missing_in_module_detection`: Verifies that an attribute in master registry absent from module CSV is flagged as `MISSING_IN_MODULE`.
  - `test_09_parity_checker_content_mismatch_detection`: Verifies that differing `etl_logic` expressions (e.g. `JOIN` vs `LEFT JOIN`) are flagged as `CONTENT_MISMATCH` with before/after diffs.
  - `test_10_date_fk_checker_happy_path_and_conformed_whitelist`: Verifies Date FK checker passes clean tables and recognizes `cdr_dt_dim` whitelist.
  - `test_11_progress_analyzer_backward_compatibility`: Verifies Progress Analyzer runs with existing arguments and extracts progress correctly.
  - `test_12_cli_flags_presence_and_help`: Verifies CLI scripts support `-m`, `--strict`, `--json`, `-o`, `-v`, `--root`.

### 2.2 Tier 2: Boundary & Corner Cases (Robustness & Edge Handling)
- **Target File**: `tests/test_e2e_tier2_boundaries.py`
- **Objective**: Verify system stability against malformed, extreme, or edge-case inputs without crashes or false positives.
- **Key Test Scenarios**:
  - `test_01_empty_csv_zero_bytes`: Evaluates parser resilience when encountering a 0-byte CSV file -> Graceful empty result, no crash.
  - `test_02_header_only_csv_zero_data_rows`: Evaluates parser resilience when encountering a CSV with header but 0 data rows.
  - `test_03_empty_sql_ddl_file`: Evaluates SQL parser handling of an empty or comment-only `.sql` DDL file.
  - `test_04_bom_utf8_sig_and_double_bom`: Tests BOM stripping for UTF-8-sig (`\xef\xbb\xbf`) and anomalous duplicate BOM (`\ufeff\ufeff` as observed in PTTT).
  - `test_05_crlf_vs_lf_line_endings_in_etl_logic`: Tests that identical `etl_logic` differing only in `\r\n` vs `\n` is normalized and NOT flagged as a content mismatch.
  - `test_06_semicolon_delimiter_sniffing`: Tests automatic delimiter sniffing on `;`-delimited CSV files (e.g. `FMS`, `NDTNN`, `TT`, `VP`).
  - `test_07_multiline_sql_with_unquoted_commas`: Tests parsing of complex multi-line SQL with 30+ commas inside a semicolon-delimited CSV.
  - `test_08_comment_and_annotation_diffs`: Tests handling of date annotations like `(Sửa 2026-08)` or `[MỚI 2026-09-07]`.
  - `test_09_case_sensitivity_and_accent_folding`: Tests normalization of accented Vietnamese module names (`GSĐC` ↔ `GSDC`).
  - `test_10_nonexistent_module_exit_code`: Verifies that querying a non-existent module returns exit code 2.
  - `test_11_missing_master_registry_exit_code`: Verifies that a missing master registry file triggers exit code 2.

### 2.3 Tier 3: Cross-Feature Combinations (Integration & Pipelines)
- **Target File**: `tests/test_e2e_tier3_combinations.py`
- **Objective**: Verify interactions between flags, execution modes, and sequential pipelines.
- **Key Test Scenarios**:
  - `test_01_strict_combined_with_json`: Tests that when `--strict` triggers exit code 1 due to violations, stdout still produces strictly valid, parseable JSON.
  - `test_02_file_output_combined_with_strict`: Tests that `-o <file>` writes the report to disk while `--strict` simultaneously returns exit code 1.
  - `test_03_warn_only_overrides_strict`: Tests that `--warn-only` suppresses exit code 1 even when `--strict` is passed and violations exist.
  - `test_04_module_all_with_mixed_delimiters`: Tests running audits across multiple modules having mixed `,` and `;` delimiters in a single execution.
  - `test_05_sequential_quality_gate_pipeline`: Tests executing Date FK Checker → Orphan Checker → Parity Checker sequentially without state corruption or file locking on Windows.
  - `test_06_complex_module_with_mixed_table_types`: Tests a module containing new Facts, reused Facts, new Dims, conformed Dims, and Operational reports simultaneously.

### 2.4 Tier 4: Real-World Workloads (Empirical Repository Baselines)
- **Target File**: `tests/test_e2e_tier4_real_workloads.py`
- **Objective**: Execute audits directly against production repository data (`Datamart/`) to verify real baselines.
- **Key Test Scenarios**:
  - **Module TKNB (Gold Standard Benchmark - Negative Control)**:
    - `test_01_tknb_real_3way_orphan_clean_baseline`: Verifies 22 HLD operational entities match 1:1:1 to 22 LLD CSVs and 22 ClickHouse flat tables. 0 orphans, status `PASS`.
    - `test_02_tknb_real_parity_clean_baseline`: Verifies 159 attributes in `Datamart/lld/TKNB/*.csv` match `datamart_attributes.csv` 100%. 0 missing, 0 diffs, status `PASS`.
    - `test_03_tknb_real_date_fk_clean_baseline`: Verifies 0 Date FK violations on TKNB.
  - **Module GSTT (Positive Control - Branch B Orphan + Missing Master Row)**:
    - `test_04_gstt_real_branch_b_orphan_detected`: Verifies that `Fact Public Company Shareholding` and/or `Legal Entity Dimension` in `DTM_GSTT_Entities.csv` are detected as Branch B orphans (deprecated in HLD, missing in LLD/Flat).
    - `test_05_gstt_real_master_registry_desync_detected`: Verifies that `fct_stock_portfolio_snpst.free_float_share_quantity` (added 2026-09-07 in module file) is detected as MISSING in master `datamart_attributes.csv` (102 vs 101 attributes).
    - `test_06_gstt_real_date_fk_violations_detected`: Verifies detection of `cdr_dt_dim_id` on Fact tables in GSTT.
  - **Module QLCB (Positive Control - Entity Normalization + ETL Logic Divergence)**:
    - `test_07_qlcb_real_entity_suffix_normalization`: Verifies entity normalization handles the missing `Snapshot` suffix in HLD (`Fact Securities Offering` vs `fct_securities_offering_snpst`).
    - `test_08_qlcb_real_etl_logic_divergence_detected`: Verifies detection of `JOIN` vs `LEFT JOIN` on `opr_securities_offering_360_profile.classification_business_line_nm`.
    - `test_09_qlcb_real_date_fk_clean_baseline`: Verifies 0 Date FK violations on QLCB.

---

## 3. Feature Inventory Coverage Matrix (F1 to F11)

| Feature ID | Feature Name | Primary Tier | Test Modules Covering Feature | Test Method / Verification Anchor |
|---|---|:---:|---|---|
| **F1** | SKILL.md Standardization | Tier 1 | `test_e2e_tier1_features.py` | `test_skill_md_gate_and_scenario_standards` |
| **F2** | Reference Docs Synchronization | Tier 1 | `test_e2e_tier1_features.py` | `test_reference_docs_rules_sync` |
| **F3** | 3-Way Orphan Protocol (Branch A/B) | Tier 1, Tier 4 | `test_e2e_tier1_features.py`<br>`test_e2e_tier4_real_workloads.py` | `test_04_orphan_checker_branch_a_incomplete_detection`<br>`test_05_orphan_checker_branch_b_deprecated_detection`<br>`test_04_gstt_real_branch_b_orphan_detected` |
| **F4** | Registry Sync Protection Rule | Tier 1, Tier 4 | `test_e2e_tier1_features.py`<br>`test_e2e_tier4_real_workloads.py` | `test_07_parity_checker_missing_in_master_detection`<br>`test_05_gstt_real_master_registry_desync_detected` |
| **F5** | Reusable Orphan Engine | Tier 1, Tier 2 | `test_e2e_tier1_features.py`<br>`test_e2e_tier2_boundaries.py` | `test_01_orphan_checker_contract_clean_fact_table`<br>`test_02_orphan_checker_dimension_filtering`<br>`test_03_orphan_checker_conformed_reuse_handling` |
| **F6** | Reusable Parity Engine | Tier 1, Tier 2 | `test_e2e_tier1_features.py`<br>`test_e2e_tier2_boundaries.py` | `test_06_parity_checker_contract_clean_match`<br>`test_09_parity_checker_content_mismatch_detection`<br>`test_05_crlf_vs_lf_line_endings_in_etl_logic` |
| **F7** | 3-Way Orphan Checker CLI | Tier 1, Tier 3 | `test_e2e_tier1_features.py`<br>`test_e2e_tier3_combinations.py` | `test_12_cli_flags_presence_and_help`<br>`test_01_strict_combined_with_json`<br>`test_02_file_output_combined_with_strict` |
| **F8** | Parity Checker CLI | Tier 1, Tier 3 | `test_e2e_tier1_features.py`<br>`test_e2e_tier3_combinations.py` | `test_12_cli_flags_presence_and_help`<br>`test_01_strict_combined_with_json`<br>`test_03_warn_only_overrides_strict` |
| **F9** | Backward Compatibility | Tier 1, Tier 3 | `test_e2e_tier1_features.py`<br>`test_e2e_tier3_combinations.py` | `test_10_date_fk_checker_happy_path_and_conformed_whitelist`<br>`test_11_progress_analyzer_backward_compatibility`<br>`test_05_sequential_quality_gate_pipeline` |
| **F10** | Real-Data Verification | Tier 4 | `test_e2e_tier4_real_workloads.py` | `test_01_tknb_real_3way_orphan_clean_baseline`<br>`test_02_tknb_real_parity_clean_baseline`<br>`test_04_gstt_real_branch_b_orphan_detected`<br>`test_05_gstt_real_master_registry_desync_detected`<br>`test_07_qlcb_real_entity_suffix_normalization`<br>`test_08_qlcb_real_etl_logic_divergence_detected` |
| **F11** | Comprehensive E2E Testing | All Tiers | `run_tests.py`<br>All Tier Test Files | Complete 4-tier suite execution and reporting via `tests/run_tests.py` |

---

## 4. Test Infrastructure Architecture & File Layout

```
ubck_atomic_design/
├── TEST_INFRA.md                                  # This file (Infrastructure & Methodology)
├── TEST_READY.md                                  # Test Suite Readiness & Execution Manual
└── tests/
    ├── run_tests.py                               # Unified Test Runner CLI
    ├── test_e2e_tier1_features.py                 # Tier 1: Feature & Interface Contract Tests
    ├── test_e2e_tier2_boundaries.py               # Tier 2: Boundary & Corner Case Tests
    ├── test_e2e_tier3_combinations.py             # Tier 3: Cross-Feature Combination Tests
    ├── test_e2e_tier4_real_workloads.py           # Tier 4: Real-World Workload Tests (TKNB, GSTT, QLCB)
    ├── test_datamart_date_fk_checker.py           # Existing Date FK tests (Preserved)
    └── test_datamart_progress_analyzer.py         # Existing Progress Analyzer tests (Preserved)
```

---

## 5. Test Runner Specification (`tests/run_tests.py`)

The unified test runner provides an automated execution harness with comprehensive terminal reporting:

### Command Line Interface:
```bash
# Run the entire 4-tier E2E test suite (default)
python tests/run_tests.py

# Run a specific tier
python tests/run_tests.py --tier 1
python tests/run_tests.py --tier 2
python tests/run_tests.py --tier 3
python tests/run_tests.py --tier 4

# Run all tests in the repository (including legacy tests)
python tests/run_tests.py --all

# Output detailed test summary as JSON
python tests/run_tests.py --json

# Verbose execution with standard unittest output
python tests/run_tests.py -v
```

### Standard Python Unittest Discovery:
The suite conforms 100% to standard Python `unittest`, making it directly discoverable:
```bash
python -m unittest discover -s tests -p "test_e2e_*.py"
```

### Exit Code Guarantees:
- `0`: All executed test cases passed successfully (or skipped due to planned progressive milestones).
- `1`: One or more test cases failed or produced an error.
- `2`: Configuration, argument, or directory discovery error.

---

## 6. Environment Prerequisites & Compatibility

- **Operating System**: Windows 10/11, Windows Server, Linux, macOS.
- **Python Version**: Python 3.9+ (tested on Python 3.10 / 3.11 / 3.12).
- **Encoding Requirements**: Standard console configured for UTF-8 (`PYTHONIOENCODING=utf-8` recommended if running in non-UTF-8 terminals).
- **Disk Requirements**: Zero modifications to source files; temporary scratch data written to system temp directory.
