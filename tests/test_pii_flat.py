# -*- coding: utf-8 -*-
"""
tests/test_pii_flat.py — mã hóa cột PII ở bước nạp flat (pii_flat.py + Gate 8 D28).

  1. encrypt_populate: bọc cột PII trong INSERT ... SELECT, giữ nguyên comment/định dạng, idempotent,
     không đụng cột không PII, bỏ qua biểu thức có comment nội dòng, cột cuối trước FROM.
  2. unencrypted / is_pii / pa_of: nhận diện cột chưa mã hóa, ngoại lệ `exclude`, hậu tố `_stg`, PA2.
  3. tag_ddl: gắn nhãn vào COMMENT (có/không có COMMENT sẵn), giữ CRLF, idempotent; non_string_pii.
  4. Gate 8 D28 (check_design_lint.check_flat_pii) trên fixture tạm: ERROR khi plaintext, ERROR khi còn cú pháp cũ
     3 tham số (`:aes_iv_hex`), sạch khi đã mã hóa theo cú pháp hiện hành.
  5. Chuyển cú pháp cũ (drop_legacy_iv / legacy_iv_calls): chỉ bỏ đúng `, :aes_iv_hex`, idempotent, giữ CRLF.
  6. Thuật toán = macro dbt `encrypt_cbc_deterministic`: known-answer test bằng cài đặt tham chiếu Python (cryptography), vector
     trong file UDF phải khớp, IV suy ra theo giá trị (hai giá trị chung tiền tố có IV khác nhau), bố cục Spark Base64(IV | ct).
  7. Hồi quy trên repo thật: mọi 02_populate_*.sql đều không còn cột PII plaintext và không còn cú pháp cũ.
"""
from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = REPO_ROOT / ".claude" / "skills" / "datamart-review" / "scripts"
if str(SCRIPTS) not in sys.path:
    sys.path.insert(0, str(SCRIPTS))

import pii_flat as P  # noqa: E402

REGISTRY_YAML = """\
version: 1
params: [":aes_key_hex"]
columns:
  identification_nbr: ID_DOC
  full_nm: NAME
  account_nbr: ACCOUNT
pa2:
  tables: [m_opr_profile_flat]
  columns: [identification_nbr]
exclude:
  - m_opr_skip_flat.full_nm
"""

POPULATE = """\
TRUNCATE TABLE IF EXISTS datamart.m_opr_profile_flat ON CLUSTER 'my_cluster';
INSERT INTO datamart.m_opr_profile_flat
SELECT
    -- From: OPERATIONAL Profile
    o.profile_code,
    o.full_nm,
    COALESCE(o.alt_id, '') AS identification_nbr,
    o.status_nm,
    o.account_nbr

FROM datamart.opr_profile o
;
"""


def make_root(populate: str | None = None, ddl: str | None = None) -> Path:
    root = Path(tempfile.mkdtemp(prefix="pii_flat_test_"))
    (root / "system" / "rules").mkdir(parents=True)
    (root / "system" / "rules" / "pii_columns.yaml").write_text(REGISTRY_YAML, encoding="utf-8")
    d = root / "Datamart" / "flat-table" / "M"
    d.mkdir(parents=True)
    if populate is not None:
        (d / "02_populate_m_flat_tables.sql").write_text(populate, encoding="utf-8")
    if ddl is not None:
        (d / "01_create_m_flat_tables.sql").write_text(ddl, encoding="utf-8")
    return root


class EncryptPopulate(unittest.TestCase):
    def setUp(self):
        self.reg = P.load_registry(make_root())

    def test_wraps_pii_only_and_keeps_layout(self):
        new, wrapped, skipped = P.encrypt_populate(POPULATE, self.reg)
        self.assertEqual([c for _, c, _ in wrapped], ["full_nm", "identification_nbr", "account_nbr"])
        self.assertEqual(skipped, [])
        self.assertIn("fn_pii_encrypt(o.full_nm, :aes_key_hex) AS full_nm,", new)
        # biểu thức có alias: alias giữ nguyên, biểu thức gốc nằm trong hàm
        self.assertIn("fn_pii_encrypt(COALESCE(o.alt_id, ''), :aes_key_hex) AS identification_nbr,", new)
        # cột cuối trước FROM + dòng trống trước FROM còn nguyên
        self.assertIn("fn_pii_encrypt(o.account_nbr, :aes_key_hex) AS account_nbr\n\nFROM datamart.opr_profile o", new)
        # cột không PII và comment không đổi
        self.assertIn("    o.profile_code,\n", new)
        self.assertIn("    o.status_nm,\n", new)
        self.assertIn("    -- From: OPERATIONAL Profile\n", new)

    def test_idempotent(self):
        once, _, _ = P.encrypt_populate(POPULATE, self.reg)
        twice, wrapped, _ = P.encrypt_populate(once, self.reg)
        self.assertEqual(once, twice)
        self.assertEqual(wrapped, [])

    def test_inline_comment_is_skipped_not_corrupted(self):
        sql = POPULATE.replace("o.full_nm,", "o.full_nm -- tên\n    ,")
        new, wrapped, skipped = P.encrypt_populate(sql, self.reg)
        self.assertEqual([c for _, c, _ in skipped], ["full_nm"])
        self.assertNotIn("fn_pii_encrypt(o.full_nm", new)
        self.assertIn("o.full_nm -- tên", new)

    def test_from_inside_function_is_not_projection_end(self):
        sql = ("INSERT INTO datamart.m_opr_profile_flat SELECT\n"
               "    extract(YEAR FROM o.d) AS yr,\n"
               "    o.full_nm\n"
               "FROM datamart.t o;\n")
        new, wrapped, _ = P.encrypt_populate(sql, self.reg)
        self.assertEqual([c for _, c, _ in wrapped], ["full_nm"])
        self.assertIn("extract(YEAR FROM o.d) AS yr,", new)

    def test_crlf_preserved(self):
        crlf = POPULATE.replace("\n", "\r\n")
        new, _, _ = P.encrypt_populate(crlf, self.reg)
        self.assertEqual(new.count("\r\n"), new.count("\n"))

    def test_wrapper_has_no_iv_parameter(self):
        new, _, _ = P.encrypt_populate(POPULATE, self.reg)
        self.assertNotIn(":aes_iv_hex", new)
        self.assertEqual(self.reg["params"], [":aes_key_hex"])


LEGACY_POPULATE = POPULATE.replace("o.full_nm,", "fn_pii_encrypt(o.full_nm, :aes_key_hex, :aes_iv_hex) AS full_nm,") \
    .replace("o.account_nbr", "fn_pii_encrypt(o.account_nbr,\n        :aes_key_hex ,\n        :aes_iv_hex) AS account_nbr")


class LegacyMigration(unittest.TestCase):
    def setUp(self):
        self.reg = P.load_registry(make_root())

    def test_detects_legacy_calls(self):
        self.assertEqual(sorted(c for _, c in P.legacy_iv_calls(LEGACY_POPULATE)), ["account_nbr", "full_nm"])
        self.assertEqual(P.legacy_iv_calls(POPULATE), [])

    def test_drop_removes_only_iv_param_and_is_idempotent(self):
        new, n = P.drop_legacy_iv(LEGACY_POPULATE)
        self.assertEqual(n, 2)
        self.assertNotIn("aes_iv_hex", new)
        self.assertIn("fn_pii_encrypt(o.full_nm, :aes_key_hex) AS full_nm,", new)
        self.assertIn("    o.profile_code,\n", new)   # phần còn lại không đổi
        again, n2 = P.drop_legacy_iv(new)
        self.assertEqual((again, n2), (new, 0))
        # sau migrate: 2 cột đã bọc không bị bọc lần 2; chỉ identification_nbr (chưa bọc) được bọc
        done, wrapped, _ = P.encrypt_populate(new, self.reg)
        self.assertEqual([c for _, c, _ in wrapped], ["identification_nbr"])
        self.assertEqual(P.legacy_iv_calls(done), [])

    def test_crlf_preserved(self):
        crlf = LEGACY_POPULATE.replace("\n", "\r\n")
        new, _ = P.drop_legacy_iv(crlf)
        self.assertEqual(new.count("\r\n"), new.count("\n"))


class Registry(unittest.TestCase):
    def setUp(self):
        self.reg = P.load_registry(make_root())

    def test_unencrypted_detects_plaintext_then_clears(self):
        found = P.unencrypted(POPULATE, self.reg)
        self.assertEqual(sorted(c for _, c in found), ["account_nbr", "full_nm", "identification_nbr"])
        new, _, _ = P.encrypt_populate(POPULATE, self.reg)
        self.assertEqual(P.unencrypted(new, self.reg), [])

    def test_exclude_and_stg_suffix(self):
        self.assertFalse(P.is_pii(self.reg, "datamart.m_opr_skip_flat", "full_nm"))
        self.assertFalse(P.is_pii(self.reg, "datamart.m_opr_skip_flat_stg", "full_nm"))
        self.assertTrue(P.is_pii(self.reg, "datamart.m_opr_profile_flat_stg", "full_nm"))

    def test_pa2_only_for_listed_table_and_column(self):
        self.assertEqual(P.pa_of(self.reg, "datamart.m_opr_profile_flat", "identification_nbr"), "PA2")
        self.assertEqual(P.pa_of(self.reg, "datamart.m_opr_profile_flat", "full_nm"), "PA1")
        self.assertEqual(P.pa_of(self.reg, "datamart.other_flat", "identification_nbr"), "PA1")


DDL = """\
CREATE TABLE IF NOT EXISTS datamart.m_opr_profile_flat ON CLUSTER 'my_cluster'
(
    profile_code        String       COMMENT 'Mã hồ sơ',
    full_nm             Nullable(String)  COMMENT 'Họ tên',
    identification_nbr  Nullable(String),
    account_nbr         Nullable(Date)    COMMENT 'sai kiểu'
)
ENGINE = MergeTree
ORDER BY (profile_code)
;
"""


class Ddl(unittest.TestCase):
    def setUp(self):
        self.reg = P.load_registry(make_root())

    def test_tag_with_and_without_comment(self):
        new, tagged = P.tag_ddl(DDL, self.reg)
        self.assertEqual([c for _, c in tagged], ["full_nm", "identification_nbr", "account_nbr"])
        self.assertIn("COMMENT 'Họ tên [PII mã hóa AES-256-CBC Base64 - PA1]',", new)
        self.assertIn("identification_nbr  Nullable(String) COMMENT '[PII mã hóa AES-256-CBC Base64 - PA2]',", new)
        self.assertIn("COMMENT 'Mã hồ sơ',", new)  # cột không PII không đổi

    def test_tag_idempotent_and_crlf(self):
        once, _ = P.tag_ddl(DDL.replace("\n", "\r\n"), self.reg)
        twice, tagged = P.tag_ddl(once, self.reg)
        self.assertEqual(once, twice)
        self.assertEqual(tagged, [])
        self.assertEqual(once.count("\r\n"), once.count("\n"))

    def test_non_string_pii_flagged(self):
        bad = P.non_string_pii(DDL, self.reg)
        self.assertEqual([(c, ty) for _, c, ty in bad], [("account_nbr", "Nullable(Date)")])


class Gate8D28(unittest.TestCase):
    def _run(self, root):
        import check_design_lint as L
        return L.check_flat_pii(root, "M")

    def test_error_on_plaintext_and_clean_after_encrypt(self):
        root = make_root(POPULATE, DDL.replace("Nullable(Date)", "Nullable(String)"))
        issues = self._run(root)
        errs = [i for i in issues if i[1] == "L4-FLAT-PII-NOT-ENCRYPTED"]
        self.assertEqual(len(errs), 3)
        self.assertTrue(all(i[0] == "ERROR" for i in errs))
        reg = P.load_registry(root)
        new, _, _ = P.encrypt_populate(POPULATE, reg)
        (root / "Datamart" / "flat-table" / "M" / "02_populate_m_flat_tables.sql").write_text(new, encoding="utf-8")
        self.assertEqual([i for i in self._run(root) if i[1] == "L4-FLAT-PII-NOT-ENCRYPTED"], [])

    def test_error_on_legacy_iv_syntax(self):
        root = make_root(LEGACY_POPULATE, DDL.replace("Nullable(Date)", "Nullable(String)"))
        errs = [i for i in self._run(root) if i[1] == "L4-FLAT-PII-LEGACY-IV"]
        self.assertEqual(len(errs), 2)
        self.assertTrue(all(i[0] == "ERROR" for i in errs))
        # sau khi chuyển cú pháp thì hết lỗi LEGACY-IV
        (root / "Datamart" / "flat-table" / "M" / "02_populate_m_flat_tables.sql").write_text(
            P.drop_legacy_iv(LEGACY_POPULATE)[0], encoding="utf-8")
        self.assertEqual([i for i in self._run(root) if i[1] == "L4-FLAT-PII-LEGACY-IV"], [])

    def test_warning_on_non_string_ddl(self):
        root = make_root("", DDL)
        warns = [i for i in self._run(root) if i[1] == "L4-FLAT-PII-COLUMN-TYPE"]
        self.assertEqual(len(warns), 1)
        self.assertEqual(warns[0][0], "WARNING")

    def test_module_without_registry_is_skipped(self):
        root = make_root(POPULATE)
        (root / "system" / "rules" / "pii_columns.yaml").unlink()
        self.assertEqual(self._run(root), [])


# ----------------------------------------------------------------------------------------------
# Thuật toán: cài đặt tham chiếu của macro dbt `encrypt_cbc_deterministic` (Spark SQL), dùng thư viện cryptography.
#   base64(aes_encrypt(CAST(c AS STRING), key, 'CBC', 'PKCS', substring(unhex(sha2(concat(base64(key), CAST(c AS STRING)), 256)), 1, 16)))
# Spark gắn IV vào đầu output của aes_encrypt CBC => Base64(IV | ciphertext).
# ----------------------------------------------------------------------------------------------
UDF_SQL = REPO_ROOT / "Datamart" / "flat-table" / "Common" / "00_create_pii_encryption_function.sql"
KAT_KEY = b"K" * 32     # khóa giả 32 byte, KHÔNG phải khóa thật
KAT_VECTORS = {
    "NGUYEN VAN A": "iQHFdRKpgwP1etaeajNnWhcirpT1rdQUocamw1vVXjo=",
    "038090012345": "e5wPMAE4v0AS9vZ54EMwnthdEajrTIZEA4RqSLC7ZDE=",
    "": "1w6LEUpT2rI1nDtumVUzD0se4YbHX0Q4uNeyJjNAlLc=",
}

try:
    from cryptography.hazmat.primitives import padding as _padding
    from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
    HAVE_CRYPTO = True
except ImportError:  # pragma: no cover
    HAVE_CRYPTO = False


def ref_encrypt(plain: str, key: bytes) -> str:
    import base64
    import hashlib
    iv = hashlib.sha256(base64.b64encode(key) + plain.encode("utf-8")).digest()[:16]
    padder = _padding.PKCS7(128).padder()
    data = padder.update(plain.encode("utf-8")) + padder.finalize()
    enc = Cipher(algorithms.AES(key), modes.CBC(iv)).encryptor()
    return base64.b64encode(iv + enc.update(data) + enc.finalize()).decode("ascii")


def ref_decrypt(b64: str, key: bytes) -> str:
    """Giống aes_decrypt(unbase64(x), key, 'CBC', 'PKCS') của Spark: IV nằm ở 16 byte đầu."""
    import base64
    raw = base64.b64decode(b64)
    dec = Cipher(algorithms.AES(key), modes.CBC(raw[:16])).decryptor()
    unp = _padding.PKCS7(128).unpadder()
    return (unp.update(dec.update(raw[16:]) + dec.finalize()) + unp.finalize()).decode("utf-8")


@unittest.skipUnless(HAVE_CRYPTO, "cần thư viện cryptography")
class AlgorithmMatchesDbtMacro(unittest.TestCase):
    def test_known_answer_vectors(self):
        for plain, expected in KAT_VECTORS.items():
            self.assertEqual(ref_encrypt(plain, KAT_KEY), expected, repr(plain))

    def test_vectors_in_udf_file_match_reference(self):
        sql = UDF_SQL.read_text(encoding="utf-8")
        for plain, expected in KAT_VECTORS.items():
            self.assertIn(expected, sql, f"vector của {plain!r} trong file UDF không khớp macro")

    def test_roundtrip_like_spark_aes_decrypt(self):
        for plain in list(KAT_VECTORS) + ["Nguyễn Văn Á", "a" * 100]:
            self.assertEqual(ref_decrypt(ref_encrypt(plain, KAT_KEY), KAT_KEY), plain)

    def test_deterministic(self):
        self.assertEqual(ref_encrypt("038090012345", KAT_KEY), ref_encrypt("038090012345", KAT_KEY))

    def test_iv_depends_on_value_so_common_prefix_is_not_leaked(self):
        import base64
        a = base64.b64decode(ref_encrypt("0380900123451", KAT_KEY))
        b = base64.b64decode(ref_encrypt("0380900123452", KAT_KEY))
        self.assertNotEqual(a[:16], b[:16])        # IV khác nhau
        self.assertNotEqual(a[16:32], b[16:32])    # nên khối ciphertext đầu cũng khác (IV cố định thì 2 khối này trùng)

    def test_key_change_changes_output(self):
        self.assertNotEqual(ref_encrypt("038090012345", KAT_KEY), ref_encrypt("038090012345", b"L" * 32))

    def test_output_layout_is_iv_plus_padded_blocks(self):
        import base64
        raw = base64.b64decode(ref_encrypt("038090012345", KAT_KEY))   # 12 ký tự -> 1 khối 16 byte
        self.assertEqual(len(raw), 16 + 16)
        self.assertEqual(len(base64.b64decode(ref_encrypt("", KAT_KEY))), 16 + 16)   # chuỗi rỗng -> 1 khối đệm


class RealRepoRegression(unittest.TestCase):
    """Mọi flat thật phải không còn cột PII plaintext; đúng 72 cột đã bọc ở 6 module tại thời điểm triển khai (2026-11-12)."""

    def test_no_plaintext_pii_in_any_populate(self):
        reg = P.load_registry(REPO_ROOT)
        leaks, wrapped = [], 0
        for f in sorted((REPO_ROOT / "Datamart" / "flat-table").rglob("02_populate_*.sql")):
            txt = f.read_text(encoding="utf-8-sig")
            leaks += [(f.parent.name, t.split(".")[-1], c) for t, c in P.unencrypted(txt, reg)]
            wrapped += sum(1 for p in P.iter_projections(txt) if P.is_wrapped(p["code"]))
        self.assertEqual(leaks, [], f"cột PII còn plaintext: {leaks}")
        self.assertGreaterEqual(wrapped, 72)

    def test_every_wrapped_column_is_registered(self):
        reg = P.load_registry(REPO_ROOT)
        stray = []
        for f in sorted((REPO_ROOT / "Datamart" / "flat-table").rglob("02_populate_*.sql")):
            for p in P.iter_projections(f.read_text(encoding="utf-8-sig")):
                if P.is_wrapped(p["code"]) and not P.is_pii(reg, p["table"], p["alias"] or ""):
                    stray.append((f.parent.name, p["table"], p["alias"]))
        self.assertEqual(stray, [], "cột đã bọc hàm mã hóa nhưng không nằm trong registry")

    def test_no_legacy_iv_param_anywhere_in_flat(self):
        reg = P.load_registry(REPO_ROOT)
        legacy = []
        for f in sorted((REPO_ROOT / "Datamart" / "flat-table").rglob("*.sql")):
            txt = f.read_text(encoding="utf-8-sig")
            legacy += [(f.name, t.split(".")[-1], c) for t, c in P.legacy_iv_calls(txt)]
            if f.name.startswith("02_populate"):
                self.assertNotIn(P.LEGACY_IV_PARAM, txt, f"{f.name} còn tham số IV cũ")
        self.assertEqual(legacy, [])
        self.assertEqual(reg["params"], [":aes_key_hex"])

    def test_udf_file_exists_and_matches_registry_function(self):
        import re
        sql = UDF_SQL.read_text(encoding="utf-8")
        # định nghĩa hàm = phần từ CREATE FUNCTION tới dấu ';' đầu tiên (bỏ phần comment kiểm thử)
        m = re.search(r"CREATE FUNCTION IF NOT EXISTS " + P.FUNC + r"\b.*?;", sql, re.S)
        self.assertIsNotNone(m, "thiếu CREATE FUNCTION fn_pii_encrypt")
        body = m.group(0)
        self.assertIn("(v, key_hex) ->", body)             # 2 tham số, không còn iv_hex
        self.assertNotIn("iv_hex", body)
        for token in ("aes-256-cbc", "SHA256", "base64Encode", "unhex(key_hex)", "encrypt("):
            self.assertIn(token, body)
        # khóa không được nằm trong repo: chỉ có tham số hàm, không có literal hex 32/64 ký tự
        self.assertIsNone(re.search(r"'[0-9a-fA-F]{32,64}'", sql))


if __name__ == "__main__":
    unittest.main()
