#!/usr/bin/env python3
"""
schema_reader.py — Đọc file "DATA DICTIONARY" của CSDL nguồn (Source/DDL UAT*/X_UAT_schema.txt).

Thay thế Source/{SOURCE}_Tables.csv + Source/{SOURCE}_Columns.csv làm đầu vào khảo sát.
File schema đọc được theo `schema_file` khai trong Source/source_systems.csv.

Định dạng file schema (độ rộng cột cố định, ngăn bởi dòng '---'):

    BANG: APPLICATIONS
    Mo ta: <comment bảng, có thể trống>
    ------
    Cot     Kieu du lieu   Null?   Khoa   Lien ket              Mo ta
    ------
    ID      NUMBER(10,0)   NO      PK
    STATUS_ID NUMBER(10,0) NO      FK     APPLICATION_STATUSES.ID   <comment cột>

Dùng như thư viện:
    from schema_reader import load_source, infer_fks
    doc = load_source("NHNCK")
    fks = infer_fks(doc)           # gợi ý FK (inferred) cho cột không có FK ở DB

Dùng như CLI:
    python scripts/schema_reader.py --source NHNCK                    # tóm tắt
    python scripts/schema_reader.py --source NHNCK --table APPLICATIONS
    python scripts/schema_reader.py --source NHNCK --infer-fk         # liệt kê FK inferred
    python scripts/schema_reader.py --source NHNCK --missing-desc     # cột/bảng thiếu mô tả
    python scripts/schema_reader.py --file "Source/DDL UAT 1/X.txt" --json
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from dataclasses import dataclass, field, asdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE_SYSTEMS_CSV = ROOT / "Source" / "source_systems.csv"

# Kiểu dữ liệu Oracle — dùng để tách tên cột dính liền kiểu khi tên cột >= 30 ký tự
_TYPE_KW = (r"NVARCHAR2|VARCHAR2|VARCHAR|NCHAR|CHAR|NUMBER|FLOAT|INTEGER|DATE|"
            r"TIMESTAMP|INTERVAL|NCLOB|CLOB|BLOB|RAW|LONG|BINARY_DOUBLE|BINARY_FLOAT|ROWID|XMLTYPE")
# Kiểu dài ≥ 20 ký tự (VD "TIMESTAMP(6) WITH TIME ZONE") làm cột "Null?" dính liền kiểu: "...ZONEYES"
_NULL_RE = re.compile(r"(?:(?<=\s)|(?<=\))|(?<=ZONE))(YES|NO)(?=\s|$)")
_TYPE_SPLIT_RE = re.compile(rf"^(\S+?)\s*((?:{_TYPE_KW})(?![A-Za-z_]).*)$")
_KEY_RE = re.compile(r"^\s*(PK/FK|PK,FK|PK|FK)(?=\s|$)")
_REF_RE = re.compile(r"^\s*(\S+)\.(\S+)(?=\s|$)")
_TYPE_TAIL_RE = re.compile(rf"(?:{_TYPE_KW})(?:\s*\([^)]*\))?(?:\s+(?:WITH|LOCAL|TIME|ZONE|TO|SECOND|DAY|YEAR|MONTH)(?:\s*\([^)]*\))?)*$")


@dataclass
class Column:
    name: str
    data_type: str
    nullable: bool
    key: str | None = None          # "PK" | "FK" | "PK/FK" | None
    ref_table: str | None = None    # FK ở mức DB (cột "Lien ket")
    ref_column: str | None = None
    comment: str = ""


@dataclass
class Table:
    name: str
    comment: str = ""
    columns: list[Column] = field(default_factory=list)

    @property
    def pk_columns(self) -> list[Column]:
        return [c for c in self.columns if c.key and "PK" in c.key]


@dataclass
class SchemaDoc:
    path: str
    schema_name: str = ""
    tables: dict[str, Table] = field(default_factory=dict)
    warnings: list[str] = field(default_factory=list)


@dataclass
class FkSuggestion:
    table: str
    column: str
    ref_table: str
    ref_column: str
    src: str            # "db" | "inferred"
    confidence: str     # "high" | "medium" | "low" (db luôn "high")


# ──────────────────────────────────────────────────────────────────────────────
# Đọc file
# ──────────────────────────────────────────────────────────────────────────────

def _read_text(path: Path) -> str:
    raw = path.read_bytes()
    for enc in ("utf-8-sig", "cp1258", "cp1252"):
        try:
            return raw.decode(enc)
        except UnicodeDecodeError:
            continue
    return raw.decode("utf-8", errors="replace")


def _parse_column_line(line: str) -> Column | None:
    m = _NULL_RE.search(line)
    if not m:
        return None
    before, after = line[: m.start()].rstrip(), line[m.end():]
    if not before.strip():
        return None

    # Tách tên cột / kiểu dữ liệu: neo kiểu ở CUỐI phần "before" (kiểu luôn nằm sau tên).
    # Không dùng khớp từ-trái: tên dài chứa từ khoá kiểu (VD ..._REVOCATION_DATE DATE) sẽ bị cắt sai.
    sm = _TYPE_TAIL_RE.search(before)
    if not sm:
        return None
    name, dtype = before[:sm.start()].strip(), sm.group(0).strip()
    if not re.fullmatch(r"[A-Za-z0-9_$#]+", name):
        return None
    key = ref_table = ref_col = None
    rest = after
    km = _KEY_RE.match(rest)
    if km:
        key = km.group(1).replace(",", "/")
        rest = rest[km.end():]
        if "FK" in key:
            rm = _REF_RE.match(rest)
            if rm:
                ref_table, ref_col = rm.group(1).upper(), rm.group(2).upper()
                rest = rest[rm.end():]
    return Column(name=name, data_type=dtype, nullable=(m.group(1) == "YES"),
                  key=key, ref_table=ref_table, ref_column=ref_col, comment=rest.strip())


def parse_schema(path: str | Path) -> SchemaDoc:
    """Parse 1 file schema → SchemaDoc. Tên bảng/cột giữ nguyên chữ hoa/thường như trong file."""
    path = Path(path)
    doc = SchemaDoc(path=str(path))
    cur: Table | None = None
    in_cols = False
    last_col: Column | None = None
    dup_lines: dict[str, list[int]] = {}
    dup_tables: dict[str, list[Table]] = {}

    for lineno, raw in enumerate(_read_text(path).splitlines(), 1):
        line = raw.rstrip()
        if line.startswith("DATA DICTIONARY - SCHEMA:"):
            doc.schema_name = line.split(":", 1)[1].strip()
            continue
        if line.startswith("BANG:"):
            cur = Table(name=line.split(":", 1)[1].strip())
            if cur.name in doc.tables:
                dup_lines.setdefault(cur.name, []).append(lineno)
                dup_tables.setdefault(cur.name, []).append(cur)
            else:
                doc.tables[cur.name] = cur
            in_cols, last_col = False, None
            continue
        if cur is None:
            continue
        if line.startswith("Mo ta:") and not in_cols:
            cur.comment = line.split(":", 1)[1].strip()
            continue
        if line.startswith("Cot ") and "Kieu du lieu" in line:
            in_cols = True
            continue
        if not in_cols or not line.strip() or set(line.strip()) <= {"-", "="}:
            continue
        col = _parse_column_line(line)
        if col is None:
            looks_like_column = (len(line) > 50 and not line[0].isspace() and line[:29].strip()
                                 and " " not in line[:29].strip() and line[30:50].strip())
            if looks_like_column:                # dòng giống dòng cột nhưng không parse được → báo, không nuốt vào mô tả
                doc.warnings.append(f"L{lineno}: dòng cột không parse được: {line[:80]!r}")
            elif last_col is not None:           # dòng nối tiếp của mô tả cột nhiều dòng
                last_col.comment = (last_col.comment + " " + line.strip()).strip()
            else:
                doc.warnings.append(f"L{lineno}: không parse được: {line[:80]!r}")
            continue
        cur.columns.append(col)
        last_col = col

    # Cột "Lien ket" rộng 25 ký tự: ref dài hơn thì tràn sang cột mô tả, dính chữ đầu của mô tả
    # (VD "...KEY_DEFINITION.ID" + "FK trỏ…" → "IDFK"). Tách lại theo danh sách cột của bảng đích.
    by_upper = {n.upper(): t for n, t in doc.tables.items()}
    for t in doc.tables.values():
        for c in t.columns:
            if not c.ref_table or not c.ref_column:
                continue
            tgt = by_upper.get(c.ref_table)
            if tgt is None:
                continue
            names = [x.name for x in tgt.columns]
            if c.ref_column in {n.upper() for n in names}:
                continue
            hits = [n for n in names if c.ref_column.startswith(n.upper())]
            if hits:
                best = max(hits, key=len)
                glued = c.ref_column[len(best):]
                c.ref_column = best.upper()
                c.comment = (glued + (" " + c.comment if c.comment else "")).strip()
            else:
                doc.warnings.append(f"FK {t.name}.{c.name} → {c.ref_table}.{c.ref_column}: cột đích không tồn tại")

    # Bảng khai báo trùng (VD GMS_IDS có 2 khối cùng tên): giữ khối nhiều cột hơn, hòa → khối đầu
    for name, extras in dup_tables.items():
        first = doc.tables[name]
        best = max([first] + extras, key=lambda t: len(t.columns))
        doc.tables[name] = best
        doc.warnings.append(
            f"bảng {name} khai báo {1 + len(extras)} lần (dòng {', '.join(map(str, dup_lines[name]))}) "
            f"— giữ khối {len(best.columns)} cột; người thiết kế cần xác nhận")
    return doc


# ──────────────────────────────────────────────────────────────────────────────
# Tra file theo source
# ──────────────────────────────────────────────────────────────────────────────

def schema_path_for(source: str, root: Path = ROOT) -> Path:
    """Tra `schema_file` của SOURCE trong Source/source_systems.csv."""
    csv_path = root / "Source" / "source_systems.csv"
    with open(csv_path, encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            if row.get("source_system", "").strip().upper() == source.upper():
                rel = (row.get("schema_file") or "").strip()
                if not rel:
                    raise FileNotFoundError(
                        f"{source}: cột schema_file trống trong {csv_path.name} "
                        f"(nguồn này không có file schema)")
                p = root / "Source" / rel          # schema_file tính từ thư mục Source/
                if not p.exists():
                    raise FileNotFoundError(f"{source}: file schema không tồn tại: {p}")
                return p
    raise KeyError(f"{source}: không có trong {csv_path}")


def load_source(source: str, root: Path = ROOT) -> SchemaDoc:
    return parse_schema(schema_path_for(source, root))


# ──────────────────────────────────────────────────────────────────────────────
# FK
# ──────────────────────────────────────────────────────────────────────────────

def db_fks(doc: SchemaDoc) -> list[FkSuggestion]:
    """FK khai báo ở mức DB (cột 'Lien ket')."""
    out = []
    for t in doc.tables.values():
        for c in t.columns:
            if c.ref_table:
                out.append(FkSuggestion(t.name, c.name, c.ref_table, c.ref_column or "", "db", "high"))
    return out


def _stem(col: str) -> str | None:
    """PROFESSIONAL_ID → PROFESSIONAL; InvestorId → INVESTOR; không có hậu tố ID → None."""
    up = col.upper()
    if up in ("ID",):
        return None
    if up.endswith("_ID"):
        return up[:-3]
    if up.endswith("ID") and len(up) > 2 and col[-2:] in ("Id", "ID") and not col.isupper():
        return up[:-2]                           # PascalCase: InvestorId
    return None


def _variants(stem: str) -> set[str]:
    v = {stem, stem + "S", stem + "ES"}
    if stem.endswith("Y"):
        v.add(stem[:-1] + "IES")
    return v


def infer_fks(doc: SchemaDoc) -> list[FkSuggestion]:
    """Gợi ý FK (src='inferred') cho cột *_ID chưa có FK ở DB, chỉ khi tên cột khớp tên bảng
    tồn tại trong schema. Chỉ gợi ý khi khớp duy nhất (mơ hồ → bỏ qua, người thiết kế bổ sung
    ở LLD). Bảng đích phải có PK; cột đích = PK đơn (hoặc ID).

    Mức tin cậy:
      high   — stem khớp nguyên tên bảng (số ít/số nhiều)
      medium — bỏ bớt từ đầu của stem (PREVIOUS_CERTIFICATE_ID → CERTIFICATES) hoặc
               khớp phần đuôi tên bảng có tiền tố (COMPANY_TYPE_ID → CAT_COMPANY_TYPE)
    """
    names = {n.upper(): n for n in doc.tables}
    out: list[FkSuggestion] = []
    for t in doc.tables.values():
        for c in t.columns:
            if c.ref_table or (c.key and "PK" in c.key and len(t.pk_columns) == 1):
                continue
            stem = _stem(c.name)
            if not stem:
                continue
            words = stem.split("_")
            found: dict[str, str] = {}           # ref_table(upper) → confidence
            for i in range(len(words)):          # bỏ dần từ đầu: i=0 là stem đầy đủ
                sub = "_".join(words[i:])
                conf = "high" if i == 0 else "medium"
                for cand in _variants(sub):
                    if cand in names and cand != t.name.upper():
                        found.setdefault(cand, conf)
                if found:
                    break
            if not found:                        # khớp đuôi tên bảng có tiền tố
                for up in names:
                    if up == t.name.upper():
                        continue
                    if any(up.endswith("_" + cand) for cand in _variants(stem)):
                        found.setdefault(up, "medium")
            if len(found) != 1:
                continue
            ref_up, conf = next(iter(found.items()))
            ref_tbl = doc.tables[names[ref_up]]
            pks = ref_tbl.pk_columns
            if len(pks) == 1:
                ref_col = pks[0].name
            elif any(x.name.upper() == "ID" for x in ref_tbl.columns):
                ref_col = next(x.name for x in ref_tbl.columns if x.name.upper() == "ID")
            else:
                continue
            out.append(FkSuggestion(t.name, c.name, ref_tbl.name, ref_col, "inferred", conf))
    return out


def all_fks(doc: SchemaDoc) -> list[FkSuggestion]:
    return db_fks(doc) + infer_fks(doc)


# ──────────────────────────────────────────────────────────────────────────────
# Mô tả thiếu — đầu vào cho bước "Suy luận mô tả" của skill source-survey
# ──────────────────────────────────────────────────────────────────────────────

def missing_descriptions(doc: SchemaDoc) -> dict:
    return {
        "tables": [t.name for t in doc.tables.values() if not t.comment],
        "columns": [(t.name, c.name) for t in doc.tables.values() for c in t.columns if not c.comment],
    }


# ──────────────────────────────────────────────────────────────────────────────
# CLI
# ──────────────────────────────────────────────────────────────────────────────

def _main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--source", help="Tên source (tra schema_file trong Source/source_systems.csv)")
    g.add_argument("--file", help="Đường dẫn trực tiếp tới file schema")
    ap.add_argument("--table", help="In chi tiết 1 bảng")
    ap.add_argument("--infer-fk", action="store_true", help="Liệt kê FK inferred")
    ap.add_argument("--missing-desc", action="store_true", help="Liệt kê bảng/cột thiếu mô tả")
    ap.add_argument("--json", action="store_true", help="Xuất JSON toàn bộ (tables + fks)")
    args = ap.parse_args()

    try:
        doc = load_source(args.source) if args.source else parse_schema(args.file)
    except (FileNotFoundError, KeyError) as e:
        print(f"[ERROR] {e}", file=sys.stderr)
        return 2
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

    if args.json:
        print(json.dumps({"schema": doc.schema_name,
                          "tables": [asdict(t) for t in doc.tables.values()],
                          "fks": [asdict(f) for f in all_fks(doc)],
                          "warnings": doc.warnings}, ensure_ascii=False, indent=1))
        return 0

    if args.table:
        t = doc.tables.get(args.table) or next((x for n, x in doc.tables.items()
                                                if n.upper() == args.table.upper()), None)
        if not t:
            print(f"[ERROR] Không có bảng {args.table}", file=sys.stderr)
            return 2
        print(f"{t.name} — {t.comment or '(không có mô tả)'}")
        for c in t.columns:
            ref = f" → {c.ref_table}.{c.ref_column}" if c.ref_table else ""
            print(f"  {c.name:32} {c.data_type:18} {'NULL' if c.nullable else 'NOT NULL':8} "
                  f"{c.key or '':5}{ref}  {c.comment}")
        return 0

    if args.infer_fk:
        for f in infer_fks(doc):
            print(f"{f.table}.{f.column} → {f.ref_table}.{f.ref_column}  [{f.confidence}]")
        return 0

    if args.missing_desc:
        m = missing_descriptions(doc)
        print(f"Bảng thiếu mô tả: {len(m['tables'])}")
        for n in m["tables"]:
            print(f"  {n}")
        print(f"Cột thiếu mô tả: {len(m['columns'])}")
        for tn, cn in m["columns"]:
            print(f"  {tn}.{cn}")
        return 0

    ncols = sum(len(t.columns) for t in doc.tables.values())
    dbf, inf = db_fks(doc), infer_fks(doc)
    m = missing_descriptions(doc)
    print(f"Schema: {doc.schema_name}  ({doc.path})")
    print(f"  Bảng: {len(doc.tables)}  (thiếu mô tả: {len(m['tables'])})")
    print(f"  Cột : {ncols}  (thiếu mô tả: {len(m['columns'])})")
    print(f"  PK  : {sum(len(t.pk_columns) for t in doc.tables.values())} cột")
    print(f"  FK  : {len(dbf)} (DB) + {len(inf)} (inferred)")
    for w in doc.warnings:
        print(f"  [WARN] {w}")
    return 0


if __name__ == "__main__":
    raise SystemExit(_main())
