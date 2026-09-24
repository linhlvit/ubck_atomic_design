import csv
import sys
import re
import difflib
from collections import Counter, defaultdict
from pathlib import Path

WORKSPACE_ROOT = Path(r"C:\Workspace\Design_DW\ubck_atomic_design")

def clean_kpi_name(name: str) -> str:
    if not name:
        return ""
    n = re.sub(r"\((?:reuse\s+từ|chiều\s*lọc|tham\s*số\s*lọc|filter|slicer).*?\)", "", name, flags=re.IGNORECASE)
    n = re.sub(r"\[(?:reuse\s+từ|chiều\s*lọc|tham\s*số\s*lọc|filter|slicer).*?\]", "", n, flags=re.IGNORECASE)
    n = re.sub(r"\s*\(\s*%\s*\)", "", n)
    n = re.sub(r"[\u2010\u2011\u2012\u2013\u2014\u2015\u2212\-]+", "-", n)
    n = re.sub(r"\s*-\s*", " - ", n)
    n = re.sub(r"\s+", " ", n).strip(" -:–—[]%")
    return n.lower()

def strip_qualifiers(name: str) -> str:
    return re.sub(r"\s*\([^)]*\)", "", name).strip()

def read_file_safe(filepath: Path) -> str:
    raw = filepath.read_bytes()
    if raw.startswith(b"\xef\xbb\xbf"):
        return raw.decode("utf-8-sig", errors="replace").lstrip("\ufeff")
    for enc in ("utf-8", "cp1258", "latin-1"):
        try:
            return raw.decode(enc)
        except UnicodeDecodeError:
            pass
    return raw.decode("latin-1", errors="replace")

def main():
    sys.stdout.reconfigure(encoding="utf-8")
    ba_path = WORKSPACE_ROOT / "BRD" / "BA" / "BA_analyst_PTTT.csv"
    mapping_path = WORKSPACE_ROOT / "Datamart" / "lld" / "DTM_PTTT_Detail_Mapping.csv"

    # 1. Đọc BA data
    ba_content = read_file_safe(ba_path).replace("\r\n", "\n").replace("\r", "\n")
    delim = ";" if ba_content[:1000].count(";") > ba_content[:1000].count(",") else ","
    reader = csv.reader(ba_content.splitlines(), delimiter=delim)
    all_rows = list(reader)

    hdr_idx = 0
    for idx, row in enumerate(all_rows[:10]):
        row_str = " ".join(c.lower() for c in row)
        if ("thông tin" in row_str or "chỉ tiêu" in row_str) and ("stt" in row_str or "tt" in row_str):
            hdr_idx = idx
            break

    headers = [c.strip().lower() for c in all_rows[hdr_idx]]
    
    def find_col(aliases):
        for a in aliases:
            for idx, h in enumerate(headers):
                if a in h:
                    return idx
        return -1

    name_idx = find_col(["thông tin", "tên chỉ tiêu", "chỉ tiêu"])
    trang_thai_idx = find_col(["trạng thái mapping", "trạng thái"])
    nguon_idx = find_col(["bảng nguồn", "nguồn dữ liệu", "nguồn"])
    nhom_yc_idx = find_col(["nhóm yêu cầu", "nhóm yc"])
    dashboard_col_idx = find_col(["dashboard/báo cáo", "dashboard"])

    ba_dashboard_rows = []
    ba_by_clean = defaultdict(list)
    ba_by_stripped = defaultdict(list)

    for row in all_rows[hdr_idx + 1:]:
        if not any(c.strip() for c in row):
            continue
        nhom_yc = row[nhom_yc_idx].strip() if nhom_yc_idx >= 0 and nhom_yc_idx < len(row) else ""
        if "dashboard" not in nhom_yc.lower():
            continue
        
        raw_name = row[name_idx].strip() if name_idx >= 0 and name_idx < len(row) else ""
        if not raw_name or "tên chiều/chỉ tiêu" in raw_name.lower():
            continue
        
        st = row[trang_thai_idx].strip() if trang_thai_idx >= 0 and trang_thai_idx < len(row) else ""
        nguon = row[nguon_idx].strip() if nguon_idx >= 0 and nguon_idx < len(row) else ""
        dash = row[dashboard_col_idx].strip() if dashboard_col_idx >= 0 and dashboard_col_idx < len(row) else ""
        
        item = {"raw_name": raw_name, "status": st, "nguon": nguon, "dashboard": dash, "row": row}
        ba_dashboard_rows.append(item)

        c_name = clean_kpi_name(raw_name)
        if c_name:
            ba_by_clean[c_name].append(item)
            sq = strip_qualifiers(c_name)
            if sq:
                ba_by_stripped[sq].append(item)

    ba_keys = list(ba_by_clean.keys())

    def match_ba(kpi_name):
        c_name = clean_kpi_name(kpi_name)
        if not c_name:
            return None
        if c_name in ba_by_clean:
            return ba_by_clean[c_name][0]
        sq = strip_qualifiers(c_name)
        if sq and sq in ba_by_stripped:
            return ba_by_stripped[sq][0]
        close = difflib.get_close_matches(c_name, ba_keys, n=1, cutoff=0.82)
        if close:
            return ba_by_clean[close[0]][0]
        return None

    # 2. Đọc Datamart Detail Mapping
    dtm_content = read_file_safe(mapping_path).replace("\r\n", "\n").replace("\r", "\n")
    dtm_delim = ";" if dtm_content[:500].count(";") > dtm_content[:500].count(",") else ","
    dtm_reader = csv.DictReader(dtm_content.splitlines(), delimiter=dtm_delim)

    tab_stats = defaultdict(lambda: {"total": 0, "ready": 0, "pending": 0, "pending_items": []})
    all_dm_pending = []
    total_dashboard = 0
    total_ready = 0

    for r in dtm_reader:
        tab = r.get("tab", "").strip()
        if tab.upper() in ("DATA EXPLORER",):
            continue
        total_dashboard += 1
        ma_ct = r.get("kpi_id", "").strip()
        kpi_name = r.get("kpi_name", "").strip()
        nhom = r.get("nhom", "").strip()
        mart_table = r.get("mart_table", "").strip()
        ghi_chu = r.get("ghi_chu", "").strip()
        tinh_chat = r.get("tinh_chat", "").strip()
        column_role = r.get("column_role", "").strip()

        is_pending = (
            "pending" in ghi_chu.lower()
            or "pending" in tinh_chat.lower()
            or column_role.upper() == "PENDING"
            or not mart_table
        ) and "resolved" not in ghi_chu.lower()

        tab_stats[tab]["total"] += 1
        item_dict = {
            "tab": tab,
            "nhom": nhom,
            "ma_ct": ma_ct,
            "kpi_name": kpi_name,
            "mart_table": mart_table,
            "ghi_chu": ghi_chu,
        }

        if is_pending:
            tab_stats[tab]["pending"] += 1
            tab_stats[tab]["pending_items"].append(item_dict)
            all_dm_pending.append(item_dict)
        else:
            tab_stats[tab]["ready"] += 1
            total_ready += 1

    # 3. Phân loại lý do Pending theo match với BA
    reasons = defaultdict(list)
    for it in all_dm_pending:
        ba_info = match_ba(it["kpi_name"]) or {}
        ba_status = ba_info.get("status", "").upper()
        ba_nguon = ba_info.get("nguon", "")
        kpi_name_lower = it["kpi_name"].lower()
        ghi_chu_lower = it["ghi_chu"].lower()

        if not ba_info:
            reasons["Không tìm thấy trong BA (Chỉ tiêu Datamart tự sinh/thiếu đối ứng)"].append(it)
        elif ba_status and ba_status not in ("DONE", "HOÀN THÀNH", "HOAN THANH"):
            reasons["BA chưa phân tích xong (BA Pending/Chưa có mapping)"].append(it)
        elif not ba_nguon or ba_nguon == "N/A" or "chưa có" in ba_nguon.lower():
            reasons["Chưa có nguồn dữ liệu từ BA (Nguồn N/A hoặc rỗng)"].append(it)
        elif "vsdc" in ba_nguon.lower() or "vsd" in kpi_name_lower or "thị phần" in kpi_name_lower:
            reasons["Thiếu nguồn dữ liệu ngoại lai (VSDC, v.v.)"].append(it)
        elif "chưa thiết kế fact" in ghi_chu_lower or not it["mart_table"]:
            reasons["Datamart chưa thiết kế Fact/Dim (Có nguồn nhưng thiếu Fact)"].append(it)
        else:
            reasons["Chờ hoàn thiện logic / Fact phụ trong Datamart"].append(it)

    print("=================================================================")
    print("BÁO CÁO TIẾN ĐỘ THIẾT KẾ DATAMART PHÂN HỆ PTTT - NHÓM DASHBOARD")
    print("=================================================================")
    print(f"Tổng số chỉ tiêu Dashboard trong BA: {len(ba_dashboard_rows)}")
    ba_done_count = sum(1 for b in ba_dashboard_rows if b['status'].upper() in ('DONE', 'HOÀN THÀNH', 'HOAN THANH'))
    ba_pending_count = len(ba_dashboard_rows) - ba_done_count
    print(f"  + BA Done   : {ba_done_count} ({(ba_done_count/len(ba_dashboard_rows)*100):.1f}%)")
    print(f"  + BA Pending: {ba_pending_count} ({(ba_pending_count/len(ba_dashboard_rows)*100):.1f}%)")

    print(f"\nTổng số chỉ tiêu Dashboard trong Datamart LLD Mapping: {total_dashboard}")
    pct_ready = (total_ready / total_dashboard * 100) if total_dashboard else 0
    pct_pending = (len(all_dm_pending) / total_dashboard * 100) if total_dashboard else 0
    print(f"  + READY  : {total_ready} ({pct_ready:.1f}%)")
    print(f"  + PENDING: {len(all_dm_pending)} ({pct_pending:.1f}%)")

    print("\n--- CHI TIẾT TIẾN ĐỘ THEO TỪNG TAB DASHBOARD ---")
    for tab, st in tab_stats.items():
        tot = st["total"]
        rdy = st["ready"]
        pnd = st["pending"]
        rdy_pct = (rdy / tot * 100) if tot else 0
        pnd_pct = (pnd / tot * 100) if tot else 0
        print(f"• {tab}: {tot} chỉ tiêu")
        print(f"    - READY  : {rdy} ({rdy_pct:.1f}%)")
        print(f"    - PENDING: {pnd} ({pnd_pct:.1f}%)")

    print("\n--- PHÂN TÍCH NGUYÊN NHÂN CÁC CHỈ TIÊU PENDING ---")
    for r, items in sorted(reasons.items(), key=lambda x: len(x[1]), reverse=True):
        print(f"\n[{r}]: {len(items)} chỉ tiêu")
        tab_counts = Counter(it["tab"] for it in items)
        for t, count in tab_counts.most_common():
            print(f"  - {t}: {count} chỉ tiêu")
            # print first 3 examples
            sample = [it["kpi_name"] for it in items if it["tab"] == t][:3]
            for s in sample:
                print(f"      * {s}")

if __name__ == "__main__":
    main()
