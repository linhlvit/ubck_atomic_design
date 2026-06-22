#!/usr/bin/env python3
"""Oracle MCP Server — ThanhTra source system (schema: INSPECT, login: viewssc).

user_* views are auto-translated to all_* WHERE owner='INSPECT' so SKILL
queries work without modification.
"""

import json
import os
import re
import tempfile

import oracledb
from mcp.server.fastmcp import FastMCP

ORACLE_USER = "viewssc"
ORACLE_PASSWORD = "Vtit#2026"
ORACLE_DSN = "171.254.93.74:1520/pdb1"
ORACLE_SCHEMA = "INSPECT"

mcp = FastMCP("oracle-thanhtra")

# Map user_* → inline subquery scoped to INSPECT schema
# Allows SKILL.md queries (which use user_* views) to work without modification.
_USER_VIEW_MAP = {
    "user_tables":       f"(SELECT * FROM all_tables WHERE owner='{ORACLE_SCHEMA}')",
    "user_tab_comments": f"(SELECT * FROM all_tab_comments WHERE owner='{ORACLE_SCHEMA}')",
    "user_tab_columns":  f"(SELECT * FROM all_tab_columns WHERE owner='{ORACLE_SCHEMA}')",
    "user_col_comments": f"(SELECT * FROM all_col_comments WHERE owner='{ORACLE_SCHEMA}')",
    "user_constraints":  f"(SELECT * FROM all_constraints WHERE owner='{ORACLE_SCHEMA}')",
    "user_cons_columns": f"(SELECT * FROM all_cons_columns WHERE owner='{ORACLE_SCHEMA}')",
}


def _translate_sql(sql: str) -> str:
    """Replace user_* view references with all_* scoped to ORACLE_SCHEMA."""
    for user_view, subquery in _USER_VIEW_MAP.items():
        sql = re.sub(rf"\b{user_view}\b", subquery, sql, flags=re.IGNORECASE)
    return sql


def get_connection():
    return oracledb.connect(user=ORACLE_USER, password=ORACLE_PASSWORD, dsn=ORACLE_DSN)


def _serialize_value(val):
    if val is None:
        return None
    if isinstance(val, (int, float, bool)):
        return val
    if hasattr(val, "read"):  # LOB
        return val.read()
    return str(val)


@mcp.tool()
def list_tables() -> str:
    """List all tables in the ThanhTra Oracle schema (INSPECT) with their comments."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT t.table_name, c.comments
        FROM all_tables t
        LEFT JOIN all_tab_comments c
          ON c.owner = t.owner AND c.table_name = t.table_name
        WHERE t.owner = :schema
        ORDER BY t.table_name
    """, schema=ORACLE_SCHEMA)
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    result = [{"table_name": r[0], "comments": r[1]} for r in rows]
    return json.dumps(result, ensure_ascii=False, indent=2)


@mcp.tool()
def query_oracle(sql: str) -> str:
    """Execute a SELECT query against the ThanhTra Oracle database (schema: INSPECT).

    user_* views (user_tables, user_tab_columns, user_constraints, etc.) are
    automatically translated to the equivalent all_* views filtered by the
    INSPECT schema — no need to rewrite SKILL queries.

    Args:
        sql: SQL SELECT statement to execute

    Returns:
        JSON with keys: columns, rows, row_count.
        If result exceeds 500 KB, saves to temp file and returns the path.
    """
    translated = _translate_sql(sql)
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(translated)
    columns = [col[0] for col in cursor.description]
    rows = cursor.fetchall()
    cursor.close()
    conn.close()

    data = {
        "columns": columns,
        "rows": [[_serialize_value(v) for v in row] for row in rows],
        "row_count": len(rows),
    }

    json_str = json.dumps(data, ensure_ascii=False, default=str, indent=2)

    if len(json_str) > 500_000:
        tmp_path = os.path.join(tempfile.gettempdir(), "oracle_result_thanhtra.json")
        with open(tmp_path, "w", encoding="utf-8") as f:
            f.write(json_str)
        return json.dumps(
            {
                "status": "large_result",
                "row_count": len(rows),
                "columns": columns,
                "file": tmp_path,
                "hint": f"python -c \"import json; d=json.load(open(r'{tmp_path}')); print(d['rows'][:3])\"",
            },
            ensure_ascii=False,
        )

    return json_str


if __name__ == "__main__":
    mcp.run()
