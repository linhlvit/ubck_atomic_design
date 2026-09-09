# -*- coding: utf-8 -*-
"""
scripts/datamart_common/csv_utils.py
Dynamic CSV delimiter detection and parsing utilities for Datamart Review.
"""
from __future__ import annotations

import csv
import io
from collections import Counter
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Union

from .encoding import read_file_safe


def detect_delimiter(raw_text: str) -> str:
    """Auto-detect CSV delimiter (',' or ';') using mode and consistency analysis."""
    sample = raw_text[:8192].lstrip("\ufeff").replace("\r\n", "\n").replace("\r", "\n")
    delim_scores: Dict[str, Tuple[int, float]] = {}

    for delim in (",", ";"):
        try:
            reader = csv.reader(io.StringIO(sample, newline=""), delimiter=delim)
            row_lens = [
                len(r)
                for idx, r in enumerate(reader)
                if idx < 15 and any(c.strip() for c in r) and not (r and r[0].strip().startswith("#"))
            ]
            if not row_lens:
                continue
            mode_len = Counter(row_lens).most_common(1)[0][0]
            consistency = sum(1 for l in row_lens if l == mode_len) / len(row_lens)
            effective_cols = mode_len if mode_len >= 2 else 0
            delim_scores[delim] = (effective_cols, consistency)
        except Exception:
            pass

    if not delim_scores:
        return ","

    best_delim = max(
        delim_scores.keys(),
        key=lambda d: (delim_scores[d][0] >= 2, delim_scores[d][0], delim_scores[d][1]),
    )
    return best_delim


def detect_delimiter_and_header(
    raw_content: str,
) -> Tuple[str, int, List[str], List[List[str]]]:
    """
    Robust delimiter and header row detector using mode & consistency analysis with keyword scoring.
    Returns (delimiter, header_index, header_columns, data_sample_rows).
    """
    raw_content = raw_content.lstrip("\ufeff").replace("\r\n", "\n").replace("\r", "\n")
    delim_scores: Dict[str, Tuple[int, float]] = {}

    for delim in (";", ","):
        try:
            reader = csv.reader(io.StringIO(raw_content, newline=""), delimiter=delim)
            row_lens = [
                len(r)
                for idx, r in enumerate(reader)
                if idx < 15 and any(c.strip() for c in r) and not (r and r[0].strip().startswith("#"))
            ]
            if not row_lens:
                continue
            mode_len = Counter(row_lens).most_common(1)[0][0]
            consistency = sum(1 for l in row_lens if l == mode_len) / len(row_lens)
            effective_cols = mode_len if mode_len >= 2 else 0
            delim_scores[delim] = (effective_cols, consistency)
        except Exception:
            pass

    best_delim = (
        max(
            delim_scores.keys(),
            key=lambda d: (delim_scores[d][0] >= 15, delim_scores[d][0], delim_scores[d][1]),
        )
        if delim_scores
        else ";"
    )

    try:
        reader = csv.reader(io.StringIO(raw_content, newline=""), delimiter=best_delim)
        all_rows = list(reader)
    except csv.Error:
        reader = csv.reader(io.StringIO(raw_content, newline=""), delimiter=best_delim, quoting=csv.QUOTE_NONE)
        all_rows = list(reader)

    if not all_rows:
        return best_delim, 0, [], []

    # Robust header detection: scan top 10 rows with keyword scoring
    best_hdr_idx = 0
    best_score = -1
    for idx in range(min(10, len(all_rows))):
        row = all_rows[idx]
        non_empty = sum(1 for x in row if x.strip())
        row_str = " ".join(x.lower() for x in row)
        score = non_empty
        if "stt" in row_str or "tt" in row_str:
            score += 5
        if "thông tin" in row_str or "chỉ tiêu" in row_str or "tên" in row_str:
            score += 5
        if "phân loại" in row_str:
            score += 5
        if "trạng thái" in row_str:
            score += 5
        if "bảng nguồn" in row_str or "nguồn" in row_str or "khai thác" in row_str:
            score += 5
        if "loại dữ liệu" in row_str or "điều kiện" in row_str or "mô tả" in row_str:
            score += 3

        if score > best_score:
            best_score = score
            best_hdr_idx = idx

    hdr_idx = best_hdr_idx
    header = [x.strip() for x in all_rows[hdr_idx]]
    data_rows = all_rows[hdr_idx + 1 :]
    return best_delim, hdr_idx, header, data_rows


def read_csv_dynamic(
    filepath_or_content: Union[str, Path],
    delimiter: Optional[str] = None,
) -> Tuple[str, List[str], List[Dict[str, str]]]:
    """
    Read CSV file or string content with dynamic delimiter detection,
    stripping BOM, and returning (delimiter, fieldnames, list_of_row_dicts).
    """
    if isinstance(filepath_or_content, Path) or (
        isinstance(filepath_or_content, str)
        and "\n" not in filepath_or_content
        and Path(filepath_or_content).is_file()
    ):
        text = read_file_safe(filepath_or_content)
    else:
        text = str(filepath_or_content).lstrip("\ufeff")

    text = text.replace("\r\n", "\n").replace("\r", "\n")

    if not text.strip():
        return ",", [], []

    delim = delimiter or detect_delimiter(text)
    reader = csv.DictReader(io.StringIO(text, newline=""), delimiter=delim)
    fieldnames = [f.lstrip("\ufeff").strip() for f in (reader.fieldnames or []) if f]

    reader.fieldnames = fieldnames

    rows: List[Dict[str, str]] = []
    for r in reader:
        cleaned_row = {
            (k.lstrip("\ufeff").strip() if k else ""): (v.strip() if v else "")
            for k, v in r.items()
            if k is not None
        }
        if any(cleaned_row.values()):
            rows.append(cleaned_row)

    return delim, fieldnames, rows
